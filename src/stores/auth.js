import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { login as loginRequest, register as registerRequest } from '@/api/auth'
import { setAuthToken } from '@/api/token'
import { getProfile, updateProfile as updateProfileRequest } from '@/api/profile'
import { ROLE_LABELS } from '@/data/categories'

const SESSION_KEY = 'eldenwiki.session'
const META_KEY = 'eldenwiki.profileMeta'

function readSession() {
  try {
    const raw = localStorage.getItem(SESSION_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

function readMeta() {
  try {
    const raw = localStorage.getItem(META_KEY)
    return raw ? JSON.parse(raw) : null
  } catch {
    return null
  }
}

function demoUser(login) {
  const normalized = String(login || '').toLowerCase()
  let roleId = 1
  if (normalized.includes('admin')) roleId = 3
  else if (normalized.includes('moder')) roleId = 2

  return {
    id: 3,
    login,
    roleId,
    role: ['player', 'player', 'moderator', 'admin'][roleId],
    token: 'demo-token',
    expiresAt: new Date(Date.now() + 86400000).toISOString(),
  }
}

export const useAuthStore = defineStore('auth', () => {
  const saved = readSession()
  const user = ref(saved?.user ?? null)
  const token = ref(saved?.token ?? null)
  const demoMode = ref(saved?.demoMode ?? false)
  const profile = ref(null)
  const loading = ref(false)
  const error = ref('')
  const meta = ref({ ...(readMeta() || {}) })

  if (token.value) setAuthToken(token.value)

  const isAuthenticated = computed(() => Boolean(user.value))
  const roleId = computed(() => user.value?.roleId ?? 0)
  const roleLabel = computed(() => ROLE_LABELS[roleId.value] ?? 'Гость')
  const isAdmin = computed(() => roleId.value === 3)
  const isModerator = computed(() => roleId.value >= 2)
  const displayName = computed(() => meta.value.displayName || user.value?.login || 'Гость')

  function persist() {
    localStorage.setItem(
      SESSION_KEY,
      JSON.stringify({ user: user.value, token: token.value, demoMode: demoMode.value }),
    )
  }

  function persistMeta() {
    localStorage.setItem(META_KEY, JSON.stringify(meta.value))
  }

  function applyAuth(payload) {
    user.value = {
      id: payload.id,
      login: payload.login,
      roleId: payload.roleId,
      role: payload.role,
    }
    token.value = payload.token
    setAuthToken(payload.token)
    persist()
  }

  async function login(login, password) {
    loading.value = true
    error.value = ''
    try {
      const response = await loginRequest({ login, password })
      demoMode.value = false
      applyAuth(response)
      await loadProfile()
      return { ok: true }
    } catch (err) {
      if (err.status === 0) {
        // Бэкенд недоступен — входим в демонстрационном режиме,
        // чтобы интерфейс можно было проверить без сервера.
        demoMode.value = true
        applyAuth(demoUser(login))
        profile.value = null
        return { ok: true, demo: true }
      }
      error.value = err.message
      return { ok: false, message: err.message }
    } finally {
      loading.value = false
    }
  }

  async function register(login, password) {
    loading.value = true
    error.value = ''
    try {
      const response = await registerRequest({ login, password })
      demoMode.value = false
      applyAuth(response)
      await loadProfile()
      return { ok: true }
    } catch (err) {
      if (err.status === 0) {
        demoMode.value = true
        applyAuth(demoUser(login))
        return { ok: true, demo: true }
      }
      error.value = err.message
      return { ok: false, message: err.message }
    } finally {
      loading.value = false
    }
  }

  async function loadProfile() {
    if (!user.value) return null
    if (demoMode.value) return null
    try {
      profile.value = await getProfile(user.value.id)
      return profile.value
    } catch {
      profile.value = null
      return null
    }
  }

  async function saveProfile({ login, newPassword, displayName, email }) {
    if (!user.value) return { ok: false, message: 'Требуется вход' }
    loading.value = true
    try {
      if (!demoMode.value) {
        await updateProfileRequest(user.value.id, {
          login,
          newPassword: newPassword || null,
        })
        user.value.login = login
        persist()
      } else {
        user.value.login = login
        persist()
      }

      meta.value = {
        ...meta.value,
        displayName: displayName || login,
        email: email || meta.value.email,
      }
      persistMeta()
      return { ok: true }
    } catch (err) {
      return { ok: false, message: err.message }
    } finally {
      loading.value = false
    }
  }

  function logout() {
    user.value = null
    token.value = null
    profile.value = null
    demoMode.value = false
    setAuthToken(null)
    localStorage.removeItem(SESSION_KEY)
  }

  return {
    user,
    token,
    profile,
    demoMode,
    loading,
    error,
    meta,
    isAuthenticated,
    roleId,
    roleLabel,
    isAdmin,
    isModerator,
    displayName,
    login,
    register,
    loadProfile,
    saveProfile,
    logout,
  }
})
