// Слой модели подбора оружия.
//
// Артефакты модели лежат в public/ml:
//   elden_ring_weapon_best.json — метаданные KNeighborsClassifier
//     (параметры, порядок признаков, 200 классов в порядке LabelEncoder);
//   weapon-dataset.json — обучающая выборка (создаётся scripts/export-model-data.py
//     из elden_ring_weapons.csv или из сохранённой модели .joblib/.pkl).
//
// Если обучающей выборки в проекте нет, считаем базу из оружия вики: у предметов
// есть требования по пяти характеристикам, этого достаточно, чтобы KNN работал
// на реальных данных, а не на вымышленных. Интерфейс при этом показывает,
// из какой базы идёт подбор.

import { knnPredict } from './knn'

const BASE = import.meta.env.BASE_URL ?? '/'
const MODEL_URL = `${BASE}ml/elden_ring_weapon_best.json`
const DATASET_URL = `${BASE}ml/weapon-dataset.json`

// Имя признака из модели -> ключ характеристики в форме подбора.
const FEATURE_ALIASES = {
  сила: 'strength',
  str: 'strength',
  ловкость: 'dexterity',
  dex: 'dexterity',
  мудрость: 'intelligence',
  int: 'intelligence',
  intel: 'intelligence',
  интеллект: 'intelligence',
  вера: 'faith',
  fai: 'faith',
  колдовство: 'arcane',
  arc: 'arcane',
  архана: 'arcane',
}

// Требование предмета -> ключ характеристики.
const REQUIREMENT_ALIASES = {
  сила: 'strength',
  ловкость: 'dexterity',
  мудрость: 'intelligence',
  вера: 'faith',
  колдовство: 'arcane',
}

const state = {
  meta: null,
  dataset: null, // { samples: number[][], labels: string[] }
  datasetSource: 'none', // none | model | wiki
  datasetNote: '',
  error: '',
  loaded: false,
}

export function normalizeWeaponName(name) {
  return String(name ?? '')
    .toLowerCase()
    .replace(/ё/g, 'е')
    .replace(/[«»"'’`]/g, '')
    .replace(/\s+/g, ' ')
    .trim()
}

function featureKey(feature) {
  return FEATURE_ALIASES[String(feature).trim().toLowerCase()] ?? null
}

// Форма подбора -> вектор модели в том порядке признаков, который в metadata.features.
export function statsToVector(stats, features) {
  return features.map((feature) => {
    const key = featureKey(feature)
    const value = key ? Number(stats?.[key]) : Number.NaN
    return Number.isFinite(value) ? value : 0
  })
}

// Выборка из предметов вики: берём только те, у которых есть требования
// хотя бы по одной характеристике.
export function datasetFromWikiItems(items, features) {
  const samples = []
  const labels = []

  for (const item of items ?? []) {
    const requirements = item?.requirements
    if (!Array.isArray(requirements) || requirements.length === 0) continue

    const byKey = new Map()
    for (const row of requirements) {
      const key = REQUIREMENT_ALIASES[String(row?.label ?? '').trim().toLowerCase()]
      if (key) byKey.set(key, Number(row.value) || 0)
    }
    if (byKey.size === 0) continue

    const vector = features.map((feature) => {
      const key = featureKey(feature)
      return key && byKey.has(key) ? byKey.get(key) : 0
    })

    // Строка из одних нулей — это не броня и не талисман, а предмет без
    // требований: по такому KNN отличить одно оружие от другого не может.
    if (vector.every((value) => value === 0)) continue

    samples.push(vector)
    labels.push(item.name)
  }

  return { samples, labels }
}

async function fetchJson(url) {
  const response = await fetch(url, { headers: { Accept: 'application/json' } })
  if (!response.ok) throw new Error(`${response.status}`)
  // SPA-хостинг и dev-сервер Vite отдают 200 с index.html на любой путь,
  // поэтому проверяем тип ответа, а не только статус.
  if (!(response.headers.get('content-type') ?? '').includes('json')) {
    throw new Error('ответ не JSON')
  }
  return response.json()
}

// Загружаем метаданные модели и, если повезёт, обучающую выборку.
export async function loadWeaponModel(force = false) {
  if (state.loaded && !force) return state

  try {
    state.meta = await fetchJson(MODEL_URL)
    state.error = ''
  } catch (err) {
    state.meta = null
    state.loaded = true
    state.error = `Не удалось загрузить модель (${err.message})`
    return state
  }

  try {
    const raw = await fetchJson(DATASET_URL)
    const samples = Array.isArray(raw?.samples) ? raw.samples : []
    const labels = Array.isArray(raw?.labels) ? raw.labels : []
    if (samples.length && samples.length === labels.length) {
      state.dataset = { samples, labels }
      state.datasetSource = 'model'
      state.datasetNote = raw?.note ?? `обучающая выборка модели: ${samples.length} объектов`
    }
  } catch {
    state.dataset = null
  }

  state.loaded = true
  return state
}

export function modelInfo() {
  const meta = state.meta
  if (!meta) return null

  const params = meta.model_params ?? {}
  return {
    name: meta.model ?? 'KNeighborsClassifier',
    task: meta.task ?? '',
    features: meta.features ?? [],
    classes: Array.isArray(meta.classes) ? meta.classes.length : 0,
    k: params.n_neighbors ?? 5,
    weights: params.weights ?? 'distance',
    trainedSamples: meta.n_samples ?? 0,
    datasetFile: meta.dataset_file ?? '',
    source: state.datasetSource,
    note: state.datasetNote,
  }
}

/**
 * Предсказание оружия по характеристикам.
 * @param {object} stats      форма { strength, dexterity, intelligence, faith, arcane }
 * @param {Array} items       предметы вики — источник базы, если нет обучающей выборки
 */
export function predictWeapon(stats, items = []) {
  if (!state.meta) return { ready: false, reason: state.error || 'Модель не загружена' }

  const features = state.meta.features ?? []
  let samples = state.dataset?.samples ?? []
  let labels = state.dataset?.labels ?? []
  let source = state.datasetSource

  if (!samples.length) {
    const wiki = datasetFromWikiItems(items, features)
    samples = wiki.samples
    labels = wiki.labels
    source = 'wiki'
  }

  if (!samples.length) {
    return { ready: false, reason: 'Нет оружия с заполненными требованиями — предсказание недоступно' }
  }

  const params = state.meta.model_params ?? {}
  const query = statsToVector(stats, features)
  const result = knnPredict({
    query,
    samples,
    labels,
    classes: state.meta.classes ?? null,
    k: params.n_neighbors ?? 5,
    weights: params.weights ?? 'distance',
  })

  if (!result.label) return { ready: false, reason: 'Не удалось построить предсказание' }

  return {
    ready: true,
    weapon: result.label,
    confidence: result.confidence,
    candidates: result.candidates,
    neighbors: result.neighbors,
    query,
    source,
    datasetSize: samples.length,
  }
}
