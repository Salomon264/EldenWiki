// Токен хранится в памяти модуля, чтобы не дублировать его в localStorage.
let authToken = null

export function setAuthToken(token) {
  authToken = token
}

export function getAuthToken() {
  return authToken
}
