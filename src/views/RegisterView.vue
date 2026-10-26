<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const auth = useAuthStore()
const router = useRouter()
const ui = useUiStore()

const form = ref({ login: '', password: '', confirm: '' })
const error = ref('')
const submitting = ref(false)
const accepted = ref(false)

async function submit() {
  error.value = ''

  if (form.value.login.trim().length < 3) {
    error.value = 'Логин должен содержать минимум 3 символа.'
    return
  }

  if (form.value.password.length < 4) {
    error.value = 'Пароль должен содержать минимум 4 символа.'
    return
  }

  if (form.value.password !== form.value.confirm) {
    error.value = 'Пароли не совпадают.'
    return
  }

  if (!accepted.value) {
    error.value = 'Примите правила вики, чтобы продолжить.'
    return
  }

  submitting.value = true
  const result = await auth.register(form.value.login.trim(), form.value.password)
  submitting.value = false

  if (!result.ok) {
    error.value = result.message || 'Не удалось создать аккаунт.'
    return
  }

  ui.notify(
    result.demo
      ? 'Аккаунт создан в демо-режиме: EldenApi недоступен.'
      : 'Аккаунт создан. Добро пожаловать в Междуземье!',
    result.demo ? 'info' : 'success',
  )
  router.push('/profile')
}
</script>

<template>
  <div class="page auth-page">
    <div class="container">
      <section class="page-panel page-panel--auth auth-card">
        <header class="auth-card__head">
          <h1 class="auth-card__title">Создание аккаунта</h1>
          <p class="auth-card__subtitle">
            Присоединяйтесь к исследователям Междуземья и собирайте собственные билды
          </p>
        </header>

        <form class="auth-form" @submit.prevent="submit">
          <label class="field">
            <span class="field__label">Логин</span>
            <input
              v-model="form.login"
              type="text"
              class="input"
              autocomplete="username"
              placeholder="tarnished"
              required
            />
          </label>

          <label class="field">
            <span class="field__label">Пароль</span>
            <input
              v-model="form.password"
              type="password"
              class="input"
              autocomplete="new-password"
              placeholder="••••••••"
              required
            />
          </label>

          <label class="field">
            <span class="field__label">Повторите пароль</span>
            <input
              v-model="form.confirm"
              type="password"
              class="input"
              autocomplete="new-password"
              placeholder="••••••••"
              required
            />
          </label>

          <label class="checkbox">
            <input v-model="accepted" type="checkbox" />
            Я принимаю правила вики и кодекс сообщества
          </label>

          <p v-if="error" class="auth-form__error">{{ error }}</p>

          <button type="submit" class="btn btn--primary btn--block" :disabled="submitting">
            {{ submitting ? 'Создаём…' : 'Зарегистрироваться' }}
          </button>
        </form>

        <p class="auth-card__footer">
          Уже есть аккаунт?
          <RouterLink to="/login" class="link">Войти</RouterLink>
        </p>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.auth-page {
  display: flex;
  align-items: flex-start;
  min-height: calc(100vh - 100px);
  padding-top: 100px;
  padding-bottom: 40px;
}

.auth-card {
  padding-top: 44px;
}

.auth-card__head {
  text-align: center;
}

.auth-card__title {
  font-size: clamp(26px, 3vw, 32px);
  line-height: 1.2;
}

.auth-card__subtitle {
  margin-top: 10px;
  color: $ink-soft;
  font-size: 14px;
  line-height: 1.5;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-top: 28px;
}

.auth-form__error {
  padding: 10px 12px;
  border-radius: 8px;
  background: $red-soft;
  color: $red-ink;
  font-size: 13px;
}

.auth-card__footer {
  margin-top: 20px;
  color: $ink-soft;
  font-size: 13.5px;
  text-align: center;
}
</style>
