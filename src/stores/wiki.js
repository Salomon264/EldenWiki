import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getArticle, getArticles, getCategories } from '@/api/articles'
import { DEMO_ITEMS } from '@/data/demo'

const LOCAL_ITEMS_KEY = 'eldenwiki.localItems'

function readLocalItems() {
  try {
    const raw = localStorage.getItem(LOCAL_ITEMS_KEY)
    return raw ? JSON.parse(raw) : []
  } catch {
    return []
  }
}

function normalizeApiItem(item) {
  return {
    id: item.id,
    name: item.name,
    category: item.category,
    itemType: item.itemType,
    weight: item.weight,
  }
}

export const useWikiStore = defineStore('wiki', () => {
  const items = ref([])
  const categories = ref([])
  const loading = ref(false)
  const error = ref('')
  const source = ref('idle') // idle | api | demo
  const localItems = ref(readLocalItems())

  function allItems() {
    const merged = new Map()

    // Данные из API дополняем описанием, требованиями и характеристиками
    // из справочника: в EldenApi эти поля пока не отдаются.
    for (const item of items.value) {
      const detail =
        DEMO_ITEMS.find((entry) => entry.id === item.id) ||
        DEMO_ITEMS.find((entry) => entry.name === item.name)
      merged.set(item.id, {
        ...detail,
        ...item,
        description: detail?.description ?? item.description,
        requirements: detail?.requirements,
        stats: detail?.stats,
        effect: item.effect ?? detail?.effect,
        obtain: item.obtain ?? detail?.obtain,
      })
    }

    for (const item of localItems.value) {
      if (!merged.has(item.id)) merged.set(item.id, item)
    }

    for (const item of DEMO_ITEMS) {
      if (!merged.has(item.id)) merged.set(item.id, item)
    }

    return [...merged.values()]
  }

  function byCategory(category) {
    return allItems().filter((item) => item.category === category)
  }

  function findById(id) {
    const numeric = Number(id)
    return allItems().find((item) => item.id === numeric) || null
  }

  function findByName(name) {
    return allItems().find((item) => item.name === name) || null
  }

  async function loadArticles(force = false) {
    if (source.value !== 'idle' && !force) return
    loading.value = true
    error.value = ''
    try {
      const [articles, summary] = await Promise.all([getArticles(), getCategories()])
      items.value = articles.map(normalizeApiItem)
      categories.value = summary
      source.value = 'api'
    } catch (err) {
      items.value = []
      categories.value = Object.entries(
        DEMO_ITEMS.reduce((acc, item) => {
          acc[item.category] = (acc[item.category] || 0) + 1
          return acc
        }, {}),
      ).map(([category, count]) => ({ category, count }))
      source.value = 'demo'
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  async function loadItem(id) {
    const numeric = Number(id)
    const local = findById(numeric)
    if (local && local.demo) return local

    try {
      const article = await getArticle(numeric)
      const demoMatch = DEMO_ITEMS.find((item) => item.name === article.name)
      return {
        ...demoMatch,
        ...article,
        requirements: demoMatch?.requirements,
        stats: demoMatch?.stats,
        description: demoMatch?.description ?? article.effect,
        demo: false,
      }
    } catch {
      return local
    }
  }

  function addLocalItem(item) {
    const nextId = Math.max(200, ...localItems.value.map((entry) => entry.id)) + 1
    const created = { ...item, id: nextId, demo: true }
    localItems.value = [created, ...localItems.value]
    localStorage.setItem(LOCAL_ITEMS_KEY, JSON.stringify(localItems.value))
    return created
  }

  function removeLocalItem(id) {
    localItems.value = localItems.value.filter((item) => item.id !== Number(id))
    localStorage.setItem(LOCAL_ITEMS_KEY, JSON.stringify(localItems.value))
  }

  return {
    items,
    categories,
    loading,
    error,
    source,
    localItems,
    allItems,
    byCategory,
    findById,
    findByName,
    loadArticles,
    loadItem,
    addLocalItem,
    removeLocalItem,
  }
})
