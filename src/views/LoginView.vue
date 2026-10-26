<script setup>
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const auth = useAuthStore()
const route = useRoute()
const router = useRouter()
const ui = useUiStore()

const form = ref({ login: '', password: '' })
const showPassword = ref(false)
const remember = ref(true)
const error = ref('')
const submitting = ref(false)

async function submit() {
  error.value = ''

  if (!form.value.login.trim() || !form.value.password.trim()) {
    error.value = 'Введите логин и пароль.'
    return
  }

  submitting.value = true
  const result = await auth.login(form.value.login.trim(), form.value.password)
  submitting.value = false

  if (!result.ok) {
    error.value = result.message || 'Не удалось войти.'
    return
  }

  ui.notify(
    result.demo
      ? 'Вход выполнен в демо-режиме: EldenApi недоступен.'
      : `С возвращением, ${auth.displayName}!`,
    result.demo ? 'info' : 'success',
  )

  const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/profile'
  router.push(redirect)
}

function forgot() {
  ui.notify('Восстановление пароля появится после подключения почтового сервиса.', 'info')
}
</script>

<template>
  <div class="page auth-page">
    <div class="container">
      <section class="page-panel page-panel--auth auth-card">
        <header class="auth-card__head">
          <h1 class="auth-card__title">Вход в аккаунт</h1>
          <p class="auth-card__subtitle">Вернитесь к исследованиям Междуземья</p>
        </header>

        <form class="auth-form" @submit.prevent="submit">
          <label class="field">
            <span class="field__label">Логин</span>
            <input
              v-model="form.login"
              type="text"
              class="input"
              autocomplete="username"
              placeholder="tarnished@eldenring.com"
              required
            />
          </label>

          <label class="field">
            <span class="field__label">Пароль</span>
            <span class="auth-form__password">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                class="input"
                autocomplete="current-password"
                placeholder="••••••••"
                required
              />
              <button
                type="button"
                class="auth-form__eye"
                :aria-label="showPassword ? 'Скрыть пароль' : 'Показать пароль'"
                @click="showPassword = !showPassword"
              >
                <AppIcon :name="showPassword ? 'block' : 'lock'" :size="17" />
              </button>
            </span>
          </label>

          <div class="auth-form__row">
            <label class="checkbox">
              <input v-model="remember" type="checkbox" />
              Запомнить меня
            </label>
            <button type="button" class="auth-form__forgot" @click="forgot">
              Забыли пароль?
            </button>
          </div>

          <p v-if="error" class="auth-form__error">{{ error }}</p>

          <button type="submit" class="btn btn--primary btn--block" :disabled="submitting">
            {{ submitting ? 'Входим…' : 'Войти в аккаунт' }}
          </button>
        </form>

        <p class="auth-card__footer">
          Впервые на EldenWiki?
          <RouterLink to="/register" class="link">Создать аккаунт</RouterLink>
        </p>

        <p class="auth-card__hint">
          Тестовый доступ к панели администратора: логин <strong>tarnished</strong>, пароль
          <strong>123456</strong>. Новые аккаунты регистрируются с ролью игрока.
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
  padding-top: 145px;
  padding-bottom: 40px;
}

.auth-card {
  padding-top: 44px;
}

.auth-card__head {
  text-align: center;
}

.auth-card__title {
  font-size: clamp(26px, 3vw, 34px);
  line-height: 1.2;
}

.auth-card__subtitle {
  margin-top: 10px;
  color: $ink-soft;
  font-size: 14px;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 18px;
  margin-top: 34px;
}

.auth-form__password {
  position: relative;
  display: block;
}

.auth-form__password .input {
  padding-right: 44px;
}

.auth-form__eye {
  position: absolute;
  top: 50%;
  right: 12px;
  display: grid;
  place-items: center;
  width: 28px;
  height: 28px;
  padding: 0;
  border: 0;
  border-radius: 6px;
  background: none;
  color: $muted;
  transform: translateY(-50%);

  &:hover {
    color: $ink;
  }
}

.auth-form__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  margin-top: 6px;
}

.auth-form__forgot {
  padding: 0;
  border: 0;
  background: none;
  color: $link;
  font-size: 13px;
  font-weight: 500;

  &:hover {
    color: $link-hover;
    text-decoration: underline;
  }
}

.auth-form > .btn {
  margin-top: 12px;
}

.auth-form__error {
  padding: 10px 12px;
  border-radius: 8px;
  background: $red-soft;
  color: $red-ink;
  font-size: 13px;
}

.auth-card__footer {
  margin-top: 22px;
  color: $ink-soft;
  font-size: 13.5px;
  text-align: center;
}

.auth-card__hint {
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px solid $paper-line;
  color: $muted;
  font-size: 12px;
  line-height: 1.5;
  text-align: center;

  strong {
    color: $ink-soft;
  }
}
</style>
