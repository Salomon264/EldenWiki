import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import {
  createEmployee as createEmployeeRequest,
  deleteEmployee as deleteEmployeeRequest,
  getEmployees,
  updateEmployee as updateEmployeeRequest,
} from '@/api/employees'
import { ROLE_LABELS } from '@/data/categories'
import { DEMO_EMPLOYEES, DEMO_MODERATION } from '@/data/demo'

const STATE_KEY = 'eldenwiki.adminState'

function readState() {
  try {
    const raw = localStorage.getItem(STATE_KEY)
    return raw ? JSON.parse(raw) : {}
  } catch {
    return {}
  }
}

const persisted = readState()

const STATUSES = ['active', 'vacation', 'blocked']

function normalizeEmployee(employee, index = 0) {
  const override = persisted.employees?.[employee.id] || {}
  const roleId = override.roleId ?? employee.roleId
  return {
    id: employee.id,
    login: employee.login,
    displayName: employee.login,
    roleId,
    role: employee.role,
    roleLabel: ROLE_LABELS[roleId] ?? employee.role,
    createdAt: employee.createdAt,
    status: override.status || STATUSES[index % 3],
    online: override.online ?? false,
    demo: Boolean(employee.demo),
  }
}

export const useAdminStore = defineStore('admin', () => {
  const employees = ref([])
  const moderation = ref(persisted.moderation || DEMO_MODERATION)
  const source = ref('idle')
  const loading = ref(false)
  const error = ref('')

  const stats = computed(() => ({
    pending: moderation.value.filter((item) => item.status === 'pending').length,
    editors: employees.value.filter((item) => item.roleId >= 2).length,
    employees: employees.value.length,
  }))

  function persist() {
    localStorage.setItem(
      STATE_KEY,
      JSON.stringify({ moderation: moderation.value, employees: persisted.employees || {} }),
    )
  }

  function rememberEmployee(employee, patch) {
    const map = persisted.employees || {}
    map[employee.id] = { ...(map[employee.id] || {}), ...patch }
    persisted.employees = map
    localStorage.setItem(
      STATE_KEY,
      JSON.stringify({ moderation: moderation.value, employees: map }),
    )
  }

  async function loadEmployees(force = false) {
    if (source.value !== 'idle' && !force) return
    loading.value = true
    error.value = ''
    try {
      const data = await getEmployees()
      employees.value = data.map(normalizeEmployee)
      source.value = 'api'
    } catch (err) {
      employees.value = DEMO_EMPLOYEES.map(normalizeEmployee)
      source.value = 'demo'
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  async function saveEmployee(payload) {
    const { id, login, password, roleId } = payload
    if (source.value === 'api') {
      try {
        if (id) {
          await updateEmployeeRequest(id, { login, password: password || null, roleId })
        } else {
          const created = await createEmployeeRequest({ login, password, roleId })
          employees.value = [...employees.value, normalizeEmployee(created, employees.value.length)]
          return { ok: true }
        }
      } catch (err) {
        return { ok: false, message: err.message }
      }
    }

    if (id) {
      const target = employees.value.find((item) => item.id === id)
      if (target) {
        target.login = login
        target.roleId = roleId
        target.roleLabel = ROLE_LABELS[roleId]
        rememberEmployee(target, { roleId })
      }
    } else {
      const nextId = Math.max(0, ...employees.value.map((item) => item.id)) + 1
      employees.value = [
        ...employees.value,
        {
          id: nextId,
          login,
          displayName: login,
          roleId,
          role: 'player',
          roleLabel: ROLE_LABELS[roleId],
          createdAt: new Date().toISOString(),
          status: 'active',
          online: false,
          demo: true,
        },
      ]
    }
    return { ok: true, demo: source.value === 'demo' }
  }

  async function removeEmployee(id) {
    if (source.value === 'api') {
      try {
        await deleteEmployeeRequest(id)
      } catch (err) {
        return { ok: false, message: err.message }
      }
    }
    employees.value = employees.value.filter((item) => item.id !== id)
    return { ok: true }
  }

  function toggleBlock(id) {
    const target = employees.value.find((item) => item.id === id)
    if (!target) return
    target.status = target.status === 'blocked' ? 'active' : 'blocked'
    target.online = target.status === 'active' ? target.online : false
    rememberEmployee(target, { status: target.status, online: target.online })
  }

  function setModerationStatus(id, status, reviewer) {
    const target = moderation.value.find((item) => item.id === id)
    if (!target) return
    target.status = status
    target.reviewer = reviewer
    target.time = 'только что'
    persist()
  }

  function addModerationEntry(entry) {
    moderation.value = [
      {
        id: Date.now(),
        status: 'pending',
        time: 'только что',
        author: entry.author || 'Вы',
        ...entry,
      },
      ...moderation.value,
    ]
    persist()
  }

  return {
    employees,
    moderation,
    source,
    loading,
    error,
    stats,
    loadEmployees,
    saveEmployee,
    removeEmployee,
    toggleBlock,
    setModerationStatus,
    addModerationEntry,
  }
})
