<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const auth = useAuthStore()
const router = useRouter()
const ui = useUiStore()

const form = ref({
  login: auth.user?.login ?? '',
  email: auth.meta.email ?? '',
  displayName: auth.meta.displayName ?? auth.user?.login ?? '',
  newPassword: '',
})

const error = ref('')
const saving = ref(false)

const initial = computed(() => (form.value.displayName || 'Г').charAt(0).toUpperCase())

async function submit() {
  error.value = ''

  if (form.value.login.trim().length < 3) {
    error.value = 'Логин должен содержать минимум 3 символа.'
    return
  }

  if (form.value.newPassword && form.value.newPassword.length < 4) {
    error.value = 'Новый пароль должен содержать минимум 4 символа.'
    return
  }

  saving.value = true
  const result = await auth.saveProfile({
    login: form.value.login.trim(),
    newPassword: form.value.newPassword,
    displayName: form.value.displayName.trim(),
    email: form.value.email.trim(),
  })
  saving.value = false

  if (!result.ok) {
    error.value = result.message || 'Не удалось сохранить профиль.'
    return
  }

  ui.notify('Профиль обновлён', 'success')
  router.push('/profile')
}

function cancel() {
  router.push('/profile')
}
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--profile edit">
        <header class="edit__head">
          <p class="eyebrow">ПРОФИЛЬ</p>
          <div class="edit__avatar">{{ initial }}</div>
          <h1 class="edit__name">{{ form.displayName || auth.displayName }}</h1>
          <RouterLink to="/profile" class="edit__back">Изменить</RouterLink>
        </header>

        <form class="edit__form" @submit.prevent="submit">
          <label class="field">
            <span class="field__label">Логин</span>
            <input v-model="form.login" type="text" class="input" required />
          </label>

          <label class="field">
            <span class="field__label">Почта</span>
            <input v-model="form.email" type="email" class="input" />
            <span class="field__hint">
              Почта хранится локально: в EldenApi поле email пока не предусмотрено.
            </span>
          </label>

          <label class="field">
            <span class="field__label">Никнейм</span>
            <input v-model="form.displayName" type="text" class="input" maxlength="40" />
          </label>

          <label class="field">
            <span class="field__label">Новый пароль</span>
            <input
              v-model="form.newPassword"
              type="password"
              class="input"
              autocomplete="new-password"
              placeholder="Оставьте пустым, чтобы не менять"
            />
          </label>

          <p v-if="error" class="edit__error">{{ error }}</p>

          <div class="edit__actions">
            <button type="submit" class="btn btn--primary" :disabled="saving">
              {{ saving ? 'Сохраняем…' : 'Сохранить' }}
            </button>
            <button type="button" class="btn btn--ghost" @click="cancel">Отмена</button>
          </div>
        </form>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.page-panel--profile {
  max-width: 560px;
  margin: 0 auto;
  padding: 34px 34px 30px;
}

.edit__head {
  position: relative;
  text-align: center;
}

.edit__avatar {
  display: grid;
  place-items: center;
  width: 64px;
  height: 64px;
  margin: 14px auto 0;
  border-radius: 50%;
  background: rgba(88, 112, 172, 0.16);
  color: $header-deep;
  font-size: 24px;
  font-weight: 700;
}

.edit__name {
  margin-top: 12px;
  font-size: 26px;
  line-height: 1.2;
}

.edit__back {
  display: inline-block;
  margin-top: 8px;
  color: $link;
  font-size: 12.5px;
  font-weight: 600;
}

.edit__form {
  display: grid;
  gap: 16px;
  margin-top: 26px;
}

.edit__error {
  padding: 10px 12px;
  border-radius: 8px;
  background: $red-soft;
  color: $red-ink;
  font-size: 13px;
}

.edit__actions {
  display: flex;
  gap: 12px;
  margin-top: 6px;
}
</style>
