import { getAuthToken } from './token'

// В dev-режиме запросы идут через прокси Vite на http://localhost:8080.
const BASE_URL = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/$/, '')
const DEFAULT_TIMEOUT = 6000

export class ApiError extends Error {
  constructor(message, status) {
    super(message)
    this.name = 'ApiError'
    this.status = status
  }

  get isNetworkError() {
    return this.status === 0
  }
}

function extractMessage(payload, fallback) {
  if (typeof payload === 'string' && payload.trim()) {
    return payload.trim()
  }

  if (payload && typeof payload === 'object') {
    if (typeof payload.message === 'string') return payload.message
    if (typeof payload.title === 'string') return payload.title
    if (payload.errors && typeof payload.errors === 'object') {
      const first = Object.values(payload.errors)[0]
      if (Array.isArray(first) && typeof first[0] === 'string') return first[0]
    }
  }

  return fallback
}

export async function request(path, options = {}) {
  const controller = new AbortController()
  const timeout = window.setTimeout(
    () => controller.abort(),
    options.timeout ?? DEFAULT_TIMEOUT,
  )

  if (options.signal) {
    options.signal.addEventListener('abort', () => controller.abort(), { once: true })
  }

  const headers = { Accept: 'application/json' }
  const token = getAuthToken()
  if (token) headers.Authorization = `Bearer ${token}`
  if (options.body !== undefined) headers['Content-Type'] = 'application/json'

  try {
    const response = await fetch(`${BASE_URL}${path}`, {
      method: options.method ?? 'GET',
      headers,
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
      signal: controller.signal,
    })

    if (!response.ok) {
      let payload = null
      const contentType = response.headers.get('content-type') ?? ''
      if (contentType.includes('json')) {
        payload = await response.json().catch(() => null)
      } else {
        payload = await response.text().catch(() => '')
      }
      throw new ApiError(
        extractMessage(payload, `Ошибка запроса (${response.status})`),
        response.status,
      )
    }

    if (response.status === 204) return undefined

    const contentType = response.headers.get('content-type') ?? ''
    if (contentType.includes('json')) return await response.json()
    return await response.text()
  } catch (error) {
    if (error instanceof ApiError) throw error
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw new ApiError('Сервер не ответил вовремя', 0)
    }
    throw new ApiError('Не удалось связаться с сервером', 0)
  } finally {
    window.clearTimeout(timeout)
  }
}

export const apiBaseUrl = BASE_URL
