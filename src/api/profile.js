import { request } from './http'

export function getProfile(id) {
  return request(`/profile/${id}`)
}

export function updateProfile(id, payload) {
  return request(`/profile/${id}`, { method: 'PUT', body: payload })
}
