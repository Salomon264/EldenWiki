import { request } from './http'

export function getArticles(query = {}) {
  const params = new URLSearchParams()
  if (query.category) params.set('category', query.category)
  if (query.typeId !== undefined && query.typeId !== null) {
    params.set('typeId', String(query.typeId))
  }
  if (query.search) params.set('search', query.search)
  const suffix = params.toString() ? `?${params.toString()}` : ''
  return request(`/articles${suffix}`)
}

export function getCategories() {
  return request('/articles/categories')
}

export function getArticle(id) {
  return request(`/articles/${id}`)
}

export function updateArticle(id, payload) {
  return request(`/articles/${id}`, { method: 'PUT', body: payload })
}

export function deleteArticle(id) {
  return request(`/articles/${id}`, { method: 'DELETE' })
}
