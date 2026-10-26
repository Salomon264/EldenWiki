<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppIcon from './AppIcon.vue'
import { CATEGORIES } from '@/data/categories'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const ui = useUiStore()

const openMenu = ref('')
const userMenuOpen = ref(false)

const gearLinks = CATEGORIES.map((category) => ({
  label: category.label,
  to: `/wiki/${category.key}`,
  icon: category.icon,
}))

const worldLinks = [
  { label: 'Лор и сюжет', to: '/lore', icon: 'book' },
  { label: 'Механики и билды', to: '/mechanics', icon: 'flame' },
  { label: 'Помощник билдов', to: '/build-helper', icon: 'spark' },
]

const communityLinks = [
  { label: 'Свежие правки', to: '/community', icon: 'queue' },
  { label: 'Правила вики', to: '/community#rules', icon: 'book' },
]

const isAdminSection = computed(() => route.path.startsWith('/admin'))
const canManage = computed(() => auth.isModerator)

const adminLinks = computed(() => [
  { label: 'Панель управления', to: '/admin', exact: true },
  { label: 'Сотрудники', to: '/admin/employees' },
  { label: 'Проверка статей', to: '/admin/moderation' },
])

const initial = computed(() => (auth.displayName || 'Г').trim().charAt(0).toUpperCase())

function isActive(to) {
  if (to === '/') return route.path === '/'
  return route.path.startsWith(to.split('#')[0])
}

function toggleMenu(name) {
  openMenu.value = openMenu.value === name ? '' : name
  userMenuOpen.value = false
}

function closeAll() {
  openMenu.value = ''
  userMenuOpen.value = false
}

function logout() {
  auth.logout()
  closeAll()
  ui.notify('Вы вышли из аккаунта', 'info')
  router.push('/')
}

function onDocumentClick(event) {
  if (!event.target.closest('.app-header__nav, .app-header__user')) {
    closeAll()
  }
}

function onKeydown(event) {
  if (event.key === 'Escape') closeAll()
}

onMounted(() => {
  document.addEventListener('click', onDocumentClick)
  document.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
  document.removeEventListener('keydown', onKeydown)
})

watch(() => route.fullPath, closeAll)
</script>

<template>
  <header class="app-header">
    <div class="app-header__inner">
      <RouterLink to="/" class="app-header__logo" aria-label="EldenWiki — на главную">
        EldenWiki
      </RouterLink>

      <nav v-if="isAdminSection" class="app-header__nav app-header__nav--admin">
        <RouterLink
          v-for="link in adminLinks"
          :key="link.to"
          :to="link.to"
          class="app-header__link"
          :class="{ 'is-active': isActive(link.to) }"
        >
          {{ link.label }}
        </RouterLink>
      </nav>

      <nav v-else class="app-header__nav">
        <div class="nav-item" :class="{ 'is-open': openMenu === 'gear' }">
          <button
            type="button"
            class="app-header__link"
            :class="{ 'is-active': route.path.startsWith('/wiki') }"
            :aria-expanded="openMenu === 'gear'"
            @click.stop="toggleMenu('gear')"
          >
            Снаряжение
            <AppIcon name="chevron-down" :size="15" class="nav-item__chevron" />
          </button>
          <Transition name="slide">
            <div v-if="openMenu === 'gear'" class="nav-dropdown">
              <RouterLink
                v-for="link in gearLinks"
                :key="link.to"
                :to="link.to"
                class="nav-dropdown__item"
              >
                <AppIcon :name="link.icon" :size="18" />
                {{ link.label }}
              </RouterLink>
            </div>
          </Transition>
        </div>

        <div class="nav-item" :class="{ 'is-open': openMenu === 'world' }">
          <button
            type="button"
            class="app-header__link"
            :class="{ 'is-active': ['/lore', '/mechanics', '/build-helper'].includes(route.path) }"
            :aria-expanded="openMenu === 'world'"
            @click.stop="toggleMenu('world')"
          >
            Мир Elden Ring
            <AppIcon name="chevron-down" :size="15" class="nav-item__chevron" />
          </button>
          <Transition name="slide">
            <div v-if="openMenu === 'world'" class="nav-dropdown">
              <RouterLink
                v-for="link in worldLinks"
                :key="link.to"
                :to="link.to"
                class="nav-dropdown__item"
              >
                <AppIcon :name="link.icon" :size="18" />
                {{ link.label }}
              </RouterLink>
            </div>
          </Transition>
        </div>

        <div class="nav-item" :class="{ 'is-open': openMenu === 'community' }">
          <button
            type="button"
            class="app-header__link"
            :class="{ 'is-active': route.path.startsWith('/community') }"
            :aria-expanded="openMenu === 'community'"
            @click.stop="toggleMenu('community')"
          >
            Сообщество
            <AppIcon name="chevron-down" :size="15" class="nav-item__chevron" />
          </button>
          <Transition name="slide">
            <div v-if="openMenu === 'community'" class="nav-dropdown">
              <RouterLink
                v-for="link in communityLinks"
                :key="link.to"
                :to="link.to"
                class="nav-dropdown__item"
              >
                <AppIcon :name="link.icon" :size="18" />
                {{ link.label }}
              </RouterLink>
            </div>
          </Transition>
        </div>
      </nav>

      <div class="app-header__spacer" />

      <div class="app-header__user">
        <template v-if="auth.isAuthenticated">
          <button
            type="button"
            class="user-chip"
            :aria-expanded="userMenuOpen"
            @click.stop="userMenuOpen = !userMenuOpen"
          >
            <span class="user-chip__text">
              <span class="user-chip__name">{{ auth.displayName }}</span>
              <span class="user-chip__role">{{ auth.roleLabel }}</span>
            </span>
            <span class="user-chip__avatar">{{ initial }}</span>
          </button>
          <Transition name="slide">
            <div v-if="userMenuOpen" class="user-dropdown">
              <RouterLink to="/profile" class="nav-dropdown__item">
                <AppIcon name="user" :size="18" />
                Профиль
              </RouterLink>
              <RouterLink v-if="canManage" to="/admin" class="nav-dropdown__item">
                <AppIcon name="dashboard" :size="18" />
                Панель управления
              </RouterLink>
              <button type="button" class="nav-dropdown__item" @click="logout">
                <AppIcon name="logout" :size="18" />
                Выйти
              </button>
            </div>
          </Transition>
        </template>
        <RouterLink v-else to="/login" class="app-header__login">
          Войти
          <AppIcon name="user" :size="19" />
        </RouterLink>
      </div>
    </div>
  </header>
</template>

<style scoped lang="scss">
.app-header {
  position: relative;
  z-index: 40;
  width: 100%;
  background: $header;
  box-shadow: 0 2px 0 rgba(8, 12, 26, 0.18);
}

.app-header__inner {
  display: flex;
  align-items: center;
  gap: 56px;
  height: 100px;
  padding: 0 56px;

  @include media-max(1200px) {
    gap: 22px;
    padding: 0 28px;
  }

  @include media-max(900px) {
    height: 76px;
    padding: 0 18px;
    gap: 16px;
  }
}

.app-header__logo {
  flex: none;
  color: #fff;
  font-size: 36px;
  font-weight: 800;
  letter-spacing: -0.03em;
  line-height: 1;

  &:hover {
    color: #fff;
  }

  @include media-max(900px) {
    font-size: 26px;
  }
}

.app-header__nav {
  display: flex;
  align-items: center;
  gap: 30px;

  @include media-max(900px) {
    display: none;
  }
}

.app-header__nav--admin {
  gap: 34px;
}

.nav-item {
  position: relative;
}

.app-header__link {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 0;
  border: 0;
  background: none;
  color: #fff;
  font-size: 17.5px;
  font-weight: 500;
  letter-spacing: 0.01em;
  text-decoration: none;
  opacity: 0.94;
  transition: opacity 0.18s $ease;

  &:hover,
  &.is-active {
    opacity: 1;
    color: #fff;
  }

  &.is-active {
    font-weight: 600;
  }
}

.nav-item__chevron {
  opacity: 0.85;
  transition: transform 0.2s $ease;
}

.nav-item.is-open .nav-item__chevron {
  transform: rotate(180deg);
}

.nav-dropdown {
  position: absolute;
  top: calc(100% + 14px);
  left: -16px;
  z-index: 60;
  min-width: 232px;
  padding: 8px;
  border-radius: 12px;
  background: #f5f6f8;
  box-shadow: $shadow-pop;

  &::before {
    content: '';
    position: absolute;
    top: -6px;
    left: 28px;
    width: 12px;
    height: 12px;
    background: #f5f6f8;
    transform: rotate(45deg);
    border-radius: 2px;
  }
}

.nav-dropdown__item {
  display: flex;
  align-items: center;
  gap: 11px;
  width: 100%;
  padding: 10px 12px;
  border: 0;
  border-radius: 8px;
  background: none;
  color: $ink;
  font-size: 14px;
  font-weight: 500;
  text-align: left;
  text-decoration: none;

  &:hover {
    background: rgba(88, 112, 172, 0.1);
    color: $header;
  }
}

.app-header__spacer {
  flex: 1;
}

.app-header__user {
  position: relative;
  flex: none;
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 6px 6px 6px 0;
  border: 0;
  background: none;
  color: #fff;
  text-align: right;
}

.user-chip__text {
  display: flex;
  flex-direction: column;
  line-height: 1.25;
}

.user-chip__name {
  font-size: 15px;
  font-weight: 600;
}

.user-chip__role {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.78);
}

.user-chip__avatar {
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1px solid rgba(255, 255, 255, 0.55);
  background: rgba(24, 30, 52, 0.28);
  font-size: 17px;
  font-weight: 700;
}

.user-dropdown {
  position: absolute;
  top: calc(100% + 14px);
  right: 0;
  z-index: 60;
  min-width: 218px;
  padding: 8px;
  border-radius: 12px;
  background: #f5f6f8;
  box-shadow: $shadow-pop;
}

.app-header__login {
  display: inline-flex;
  align-items: center;
  gap: 20px;
  margin-right: 14px;
  color: #fff;
  font-size: 18px;
  font-weight: 500;

  &:hover {
    color: #fff;
    opacity: 0.85;
  }
}

@include media-max(900px) {
  .user-chip__text {
    display: none;
  }

  .user-chip__avatar {
    width: 38px;
    height: 38px;
  }
}
</style>
