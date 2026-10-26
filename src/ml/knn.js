// KNeighborsClassifier (scikit-learn) на чистом JS.
//
// Логика один в один повторяет sklearn.neighbors.KNeighborsClassifier с
// weights='distance' и метрикой «евклидово расстояние», на которой обучена
// модель elden_ring_weapon_best.json:
//   1. считаем расстояния от запроса до всех объектов выборки;
//   2. берём k ближайших;
//   3. вес соседа = 1 / расстояние (нулевое расстояние получает вес 1,
//      остальные соседи — 0; если всех k соседей разделяет 0 — вес 1/k);
//   4. голоса суммируем по классам, побеждает класс с максимальной суммой
//      (при равенстве — тот, у кого меньше индекс класса, как у np.argmax).

export function euclideanDistance(a, b) {
  let sum = 0
  for (let i = 0; i < a.length; i += 1) {
    const diff = Number(a[i]) - Number(b[i])
    sum += diff * diff
  }
  return Math.sqrt(sum)
}

// Полное расстояние до нуля (0.0000001) sklearn считает «нулевым».
const ZERO_DISTANCE = 1e-12

function neighborWeights(distances, weights) {
  if (weights !== 'distance') return distances.map(() => 1)

  const zeroCount = distances.filter((d) => d <= ZERO_DISTANCE).length
  if (zeroCount === 0) return distances.map((d) => 1 / d)
  if (zeroCount === distances.length) {
    const share = 1 / distances.length
    return distances.map(() => share)
  }
  return distances.map((d) => (d <= ZERO_DISTANCE ? 1 : 0))
}

// Индекс класса по названию. Порядок классов берётся из модели
// (metadata.classes == LabelEncoder.classes_), поэтому предсказанный индекс
// совпадает с idx из model.predict(...) в Python.
function classIndexOf(label, classes, seen) {
  if (!Array.isArray(classes) || classes.length === 0) {
    // Классов нет — нумеруем по первому появлению в выборке.
    if (!seen.has(label)) seen.set(label, seen.size)
    return seen.get(label)
  }
  const index = classes.indexOf(label)
  return index === -1 ? Number.MAX_SAFE_INTEGER : index
}

/**
 * Предсказание по методу k ближайших соседей.
 *
 * @param {number[]} query        вектор запроса [сила, ловкость, мудрость, вера, колдовство]
 * @param {number[][]} samples    объекты выборки
 * @param {string[]} labels       названия классов каждого объекта
 * @param {string[]} classes      порядок классов из модели (опционально)
 * @param {number} k              число соседей
 * @param {'distance'|'uniform'} weights
 * @returns {{label: string|null, index: number, confidence: number,
 *            neighbors: Array, candidates: Array}}
 */
export function knnPredict({
  query,
  samples,
  labels,
  classes = null,
  k = 5,
  weights = 'distance',
}) {
  const empty = { label: null, index: -1, confidence: 0, neighbors: [], candidates: [] }
  if (!Array.isArray(query) || !Array.isArray(samples) || samples.length === 0) return empty

  const features = query.length
  const seen = new Map()
  const scored = []

  for (let i = 0; i < samples.length; i += 1) {
    const label = labels[i]
    if (label === undefined || label === null) continue
    scored.push({
      label,
      distance: euclideanDistance(query, samples[i].slice(0, features)),
    })
  }
  if (scored.length === 0) return empty

  scored.sort((a, b) => a.distance - b.distance)

  const neighbors = scored.slice(0, Math.max(1, Math.min(k, scored.length)))
  const weightsList = neighborWeights(neighbors.map((n) => n.distance), weights)

  const totals = new Map()
  neighbors.forEach((neighbor, i) => {
    totals.set(neighbor.label, (totals.get(neighbor.label) ?? 0) + weightsList[i])
  })

  const total = [...totals.values()].reduce((sum, value) => sum + value, 0)
  let bestLabel = null
  let bestWeight = -1
  let bestIndex = Number.MAX_SAFE_INTEGER

  for (const [label, weight] of totals) {
    const index = classIndexOf(label, classes, seen)
    const better =
      weight > bestWeight + ZERO_DISTANCE ||
      (Math.abs(weight - bestWeight) <= ZERO_DISTANCE && index < bestIndex)
    if (better) {
      bestLabel = label
      bestWeight = weight
      bestIndex = index
    }
  }

  const candidates = [...totals.entries()]
    .map(([label, weight]) => ({
      label,
      weight,
      share: total > 0 ? weight / total : 0,
      distance: Math.min(...neighbors.filter((n) => n.label === label).map((n) => n.distance)),
    }))
    .sort((a, b) => b.weight - a.weight || a.distance - b.distance)

  return {
    label: bestLabel,
    index: Array.isArray(classes) ? classes.indexOf(bestLabel) : bestIndex,
    confidence: total > 0 ? bestWeight / total : 0,
    neighbors: neighbors.map((neighbor, i) => ({ ...neighbor, weight: weightsList[i] })),
    candidates,
  }
}
