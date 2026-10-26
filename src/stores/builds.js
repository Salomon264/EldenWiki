import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { loadWeaponModel, modelInfo, normalizeWeaponName, predictWeapon } from '@/ml/weaponModel'
import { useWikiStore } from './wiki'

const STORAGE_KEY = 'eldenwiki.builds'

function readBuilds() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : []
  } catch {
    return []
  }
}

// Поля формы подбора. Порядок признаков задаёт metadata.features модели,
// здесь только порядок и подписи полей на экране.
export const STAT_FIELDS = [
  { key: 'strength', label: 'Сила' },
  { key: 'dexterity', label: 'Ловкость' },
  { key: 'faith', label: 'Вера' },
  { key: 'intelligence', label: 'Мудрость' },
  { key: 'arcane', label: 'Колдовство' },
]

const DEFAULT_STATS = {
  strength: 12,
  dexterity: 16,
  faith: 10,
  intelligence: 10,
  arcane: 10,
}

export const useBuildStore = defineStore('builds', () => {
  const wiki = useWikiStore()

  const savedBuilds = ref(readBuilds())
  const stats = ref({ ...DEFAULT_STATS })
  const note = ref('')
  const buildName = ref('Мой билд')

  // Состояние модели и последнее предсказание.
  const model = ref(null)
  const modelError = ref('')
  const modelLoading = ref(false)
  const prediction = ref(null)
  const predicting = ref(false)

  const total = computed(() =>
    Object.values(stats.value).reduce((sum, value) => sum + Number(value || 0), 0),
  )

  // Характеристика, которая у персонажа сильнее всего — по ней описываем акцент.
  const dominantStat = computed(() => {
    let best = STAT_FIELDS[0]
    let bestValue = -1
    for (const field of STAT_FIELDS) {
      const value = Number(stats.value[field.key] || 0)
      if (value > bestValue) {
        bestValue = value
        best = field
      }
    }
    return best
  })

  const recommendedItem = computed(() => prediction.value?.item ?? null)

  const focus = computed(() => {
    if (!prediction.value?.ready) return '—'
    return recommendedItem.value?.damageType || `упор на ${dominantStat.value.label.toLowerCase()}`
  })

  const modelReady = computed(() => Boolean(model.value))

  function findByWeaponName(name) {
    const normalized = normalizeWeaponName(name)
    if (!normalized) return null
    return wiki.allItems().find((item) => normalizeWeaponName(item.name) === normalized) ?? null
  }

  // Предсказание по модели: оружие ищется среди записей вики, чтобы сразу
  // показать карточку с типом, весом и способом получения.
  function predict() {
    if (!model.value) return
    predicting.value = true
    try {
      const result = predictWeapon(stats.value, wiki.byCategory('weapon'))
      prediction.value = result.ready ? { ...result, item: findByWeaponName(result.weapon) } : result
    } finally {
      predicting.value = false
    }
  }

  async function loadModel(force = false) {
    modelLoading.value = true
    try {
      await wiki.loadArticles()
      const state = await loadWeaponModel(force)
      model.value = modelInfo()
      modelError.value = state.error
      if (state.meta) predict()
    } catch (err) {
      modelError.value = err.message
    } finally {
      modelLoading.value = false
    }
  }

  function persist() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(savedBuilds.value))
  }

  function saveBuild(author) {
    const item = recommendedItem.value
    const build = {
      id: `build-${Date.now()}`,
      name: buildName.value.trim() || 'Без названия',
      createdAt: new Date().toISOString(),
      author: author || 'Гость',
      stats: { ...stats.value },
      itemId: item?.id ?? null,
      itemName: prediction.value?.weapon ?? '—',
      note: note.value,
      focus: focus.value,
      confidence: prediction.value?.ready ? Math.round(prediction.value.confidence * 100) : null,
    }
    savedBuilds.value = [build, ...savedBuilds.value]
    persist()
    return build
  }

  function removeBuild(id) {
    savedBuilds.value = savedBuilds.value.filter((build) => build.id !== id)
    persist()
  }

  function reset() {
    stats.value = { ...DEFAULT_STATS }
    note.value = ''
    buildName.value = 'Мой билд'
    predict()
  }

  return {
    savedBuilds,
    stats,
    note,
    buildName,
    model,
    modelError,
    modelLoading,
    modelReady,
    prediction,
    predicting,
    total,
    focus,
    dominantStat,
    recommendedItem,
    predict,
    loadModel,
    saveBuild,
    removeBuild,
    reset,
  }
})
