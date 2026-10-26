<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import BaseModal from '@/components/BaseModal.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { EMPLOYEE_STATUSES, ROLE_OPTIONS } from '@/data/categories'
import { useAdminStore } from '@/stores/admin'
import { useUiStore } from '@/stores/ui'

const admin = useAdminStore()
const ui = useUiStore()
const route = useRoute()

const search = ref('')
const roleFilter = ref('')
const statusFilter = ref('')

const modalOpen = ref(false)
const editing = ref(null)
const form = ref({ login: '', password: '', roleId: 1 })
const formError = ref('')
const saving = ref(false)

const filtered = computed(() =>
  admin.employees.filter((employee) => {
    const query = search.value.trim().toLowerCase()
    const matchesSearch =
      !query ||
      employee.displayName.toLowerCase().includes(query) ||
      employee.login.toLowerCase().includes(query)
    const matchesRole = !roleFilter.value || employee.roleId === Number(roleFilter.value)
    const matchesStatus = !statusFilter.value || employee.status === statusFilter.value
    return matchesSearch && matchesRole && matchesStatus
  }),
)

function formatDate(value) {
  if (!value) return '—'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return '—'
  return date.toLocaleDateString('ru-RU', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

function openCreate() {
  editing.value = null
  form.value = { login: '', password: '', roleId: 1 }
  formError.value = ''
  modalOpen.value = true
}

function openEdit(employee) {
  editing.value = employee
  form.value = { login: employee.login, password: '', roleId: employee.roleId }
  formError.value = ''
  modalOpen.value = true
}

async function save() {
  formError.value = ''

  if (form.value.login.trim().length < 3) {
    formError.value = 'Логин должен содержать минимум 3 символа.'
    return
  }

  if (!editing.value && form.value.password.length < 4) {
    formError.value = 'Пароль должен содержать минимум 4 символа.'
    return
  }

  saving.value = true
  const result = await admin.saveEmployee({
    id: editing.value?.id,
    login: form.value.login.trim(),
    password: form.value.password,
    roleId: form.value.roleId,
  })
  saving.value = false

  if (!result.ok) {
    formError.value = result.message || 'Не удалось сохранить сотрудника.'
    return
  }

  ui.notify(
    editing.value ? 'Данные сотрудника обновлены' : 'Сотрудник зарегистрирован',
    'success',
  )
  modalOpen.value = false
}

async function remove() {
  if (!editing.value) return
  const result = await admin.removeEmployee(editing.value.id)
  if (!result.ok) {
    formError.value = result.message
    return
  }
  ui.notify('Сотрудник удалён', 'info')
  modalOpen.value = false
}

function toggleBlock(employee) {
  admin.toggleBlock(employee.id)
  ui.notify(
    employee.status === 'blocked'
      ? `Доступ ${employee.displayName} заблокирован`
      : `Доступ ${employee.displayName} восстановлен`,
    employee.status === 'blocked' ? 'error' : 'success',
  )
}

onMounted(async () => {
  await admin.loadEmployees()
  if (route.query.new === '1') openCreate()
})
</script>

<template>
  <div class="page">
    <div class="container container--flush">
      <section class="page-panel page-panel--wide employees">
        <header class="employees__head">
          <div>
            <h1 class="page-title">Управление сотрудниками Wiki</h1>
            <p class="page-subtitle">
              Назначение ролей, регулирование прав доступа и аудит продуктивности
            </p>
          </div>
          <button type="button" class="btn btn--gold" @click="openCreate">
            <AppIcon name="plus" :size="17" />
            Добавить сотрудника
          </button>
        </header>

        <div class="employees__toolbar">
          <input
            v-model="search"
            type="search"
            class="input input--search employees__search"
            placeholder="Поиск по имени сотрудника..."
          />
          <select v-model="roleFilter" class="select employees__select">
            <option value="">Все роли</option>
            <option v-for="role in ROLE_OPTIONS" :key="role.value" :value="role.value">
              {{ role.label }}
            </option>
          </select>
          <select v-model="statusFilter" class="select employees__select">
            <option value="">Все статусы</option>
            <option v-for="(status, key) in EMPLOYEE_STATUSES" :key="key" :value="key">
              {{ status.label }}
            </option>
          </select>
        </div>

        <div class="employees__table-wrap">
          <table class="data-table">
            <thead>
              <tr>
                <th>Сотрудник</th>
                <th>Роль</th>
                <th>В базе с</th>
                <th>Статус</th>
                <th class="employees__actions-col">Действия</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="employee in filtered" :key="employee.id">
                <td>
                  <div class="employee">
                    <span class="employee__avatar">{{ employee.displayName.charAt(0) }}</span>
                    <div>
                      <p class="employee__name">{{ employee.displayName }}</p>
                      <p class="employee__login">
                        <span
                          class="employee__dot"
                          :class="{ 'employee__dot--online': employee.online }"
                        />
                        {{ employee.login }}
                      </p>
                    </div>
                  </div>
                </td>
                <td>{{ employee.roleLabel }}</td>
                <td>{{ formatDate(employee.createdAt) }}</td>
                <td>
                  <StatusBadge
                    :label="EMPLOYEE_STATUSES[employee.status]?.label ?? employee.status"
                    :tone="EMPLOYEE_STATUSES[employee.status]?.tone ?? 'neutral'"
                  />
                </td>
                <td>
                  <div class="employee__row-actions">
                    <button type="button" class="btn btn--sm btn--ghost" @click="openEdit(employee)">
                      Изменить
                    </button>
                    <button
                      type="button"
                      class="btn btn--sm"
                      :class="employee.status === 'blocked' ? 'btn--success' : 'btn--danger'"
                      @click="toggleBlock(employee)"
                    >
                      {{ employee.status === 'blocked' ? 'Разблокировать' : 'Блок' }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>

          <p v-if="!filtered.length" class="employees__empty">
            Сотрудники не найдены. Измените фильтры или добавьте нового сотрудника.
          </p>
        </div>

        <p v-if="admin.source === 'demo'" class="employees__note">
          EldenApi недоступен: список сотрудников и статусы берутся из локального демо-набора.
        </p>
      </section>
    </div>

    <BaseModal
      :open="modalOpen"
      :title="editing ? 'Редактирование сотрудника' : 'Новый сотрудник'"
      :subtitle="
        editing
          ? 'Измените логин или роль. Пароль можно не менять.'
          : 'Создайте учётную запись и назначьте роль доступа.'
      "
      @close="modalOpen = false"
    >
      <form class="employee-form" @submit.prevent="save">
        <label class="field">
          <span class="field__label">Логин</span>
          <input v-model="form.login" type="text" class="input" required />
        </label>

        <label class="field">
          <span class="field__label">
            {{ editing ? 'Новый пароль' : 'Пароль' }}
          </span>
          <input
            v-model="form.password"
            type="password"
            class="input"
            :placeholder="editing ? 'Оставьте пустым, чтобы не менять' : '••••••••'"
            :required="!editing"
          />
        </label>

        <label class="field">
          <span class="field__label">Роль</span>
          <select v-model.number="form.roleId" class="select">
            <option v-for="role in ROLE_OPTIONS" :key="role.value" :value="role.value">
              {{ role.label }}
            </option>
          </select>
        </label>

        <p v-if="formError" class="employee-form__error">{{ formError }}</p>
      </form>

      <template #footer>
        <button
          v-if="editing"
          type="button"
          class="btn btn--danger employee-form__delete"
          @click="remove"
        >
          <AppIcon name="trash" :size="16" />
          Удалить
        </button>
        <button type="button" class="btn btn--ghost" @click="modalOpen = false">Отмена</button>
        <button type="button" class="btn btn--primary" :disabled="saving" @click="save">
          {{ saving ? 'Сохраняем…' : 'Сохранить' }}
        </button>
      </template>
    </BaseModal>
  </div>
</template>

<style scoped lang="scss">
.employees {
  padding-top: 26px;
}

.employees__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
}

.employees__toolbar {
  display: flex;
  gap: 14px;
  margin-top: 22px;
}

.employees__search {
  flex: 1;
  max-width: 806px;
}

.employees__select {
  width: 238px;
}

.employees__table-wrap {
  margin-top: 20px;
}

.employees__actions-col {
  text-align: right;
}

.employee {
  display: flex;
  align-items: center;
  gap: 12px;
}

.employee__avatar {
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: rgba(88, 112, 172, 0.16);
  color: $header-deep;
  font-size: 15px;
  font-weight: 700;
  flex: none;
}

.employee__name {
  font-size: 14px;
  font-weight: 600;
  color: $ink-strong;
}

.employee__login {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 2px;
  color: $muted;
  font-size: 11.5px;
}

.employee__dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(56, 57, 59, 0.25);
}

.employee__dot--online {
  background: $green;
}

.employee__row-actions {
  display: flex;
  justify-content: flex-end;
  gap: 6px;
}

.employees__empty {
  padding: 30px 0;
  color: $muted;
  font-size: 13.5px;
  text-align: center;
}

.employees__note {
  margin-top: 18px;
  color: $muted;
  font-size: 12px;
}

.employee-form {
  display: grid;
  gap: 16px;
}

.employee-form__error {
  padding: 10px 12px;
  border-radius: 8px;
  background: $red-soft;
  color: $red-ink;
  font-size: 13px;
}

.employee-form__delete {
  margin-right: auto;
  padding-inline: 4px;
}

@include media-max(900px) {
  .employees__head {
    flex-direction: column;
  }

  .employees__toolbar {
    flex-direction: column;
  }

  .employees__select {
    width: 100%;
  }

  .employees__table-wrap {
    overflow-x: auto;
  }

  .data-table {
    min-width: 780px;
  }
}
</style>
