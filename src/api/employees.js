import { request } from './http'

export function getEmployees() {
  return request('/employees')
}

export function createEmployee(payload) {
  return request('/employees', { method: 'POST', body: payload })
}

export function updateEmployee(id, payload) {
  return request(`/employees/${id}`, { method: 'PUT', body: payload })
}

export function deleteEmployee(id) {
  return request(`/employees/${id}`, { method: 'DELETE' })
}
