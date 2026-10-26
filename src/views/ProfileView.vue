<script setup>
import { computed, onMounted } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import { useAuthStore } from '@/stores/auth'
import { useBuildStore } from '@/stores/builds'
import { useUiStore } from '@/stores/ui'

const auth = useAuthStore()
const builds = useBuildStore()
const ui = useUiStore()

const profile = computed(() => auth.profile)
const displayName = computed(() => auth.displayName || auth.user?.login || 'Погасший')
const bio = computed(() => auth.meta.bio || '')

const level = computed(() => {
  const saved = builds.savedBuilds[0]
  if (!saved) return null
  return Object.values(saved.stats).reduce((sum, value) => sum + Number(value || 0), 0)
})

const tiles = computed(() => [
  {
    label: 'УРОВЕНЬ',
    value: level.value === null ? '—' : String(level.value),
    note: level.value === null ? 'Нет сохранённых билдов' : 'По текущему билду',
  },
  {
    label: 'БИЛДОВ',
    value: String(profile.value?.buildsCount ?? builds.savedBuilds.length),
    note: 'Сохранено',
  },
  {
    label: 'РОЛЬ',
    value: auth.roleLabel,
    note: 'Права доступа',
  },
])

const currentBuild = computed(() => {
  const saved = builds.savedBuilds[0]
  return {
    className: saved?.name ?? '—',
    weapon: saved?.itemName ?? '—',
    magic: saved?.focus ?? '—',
  }
})

function logout() {
  auth.logout()
  ui.notify('Вы вышли из аккаунта', 'info')
}

onMounted(() => auth.loadProfile())
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--profile profile">
        <header class="profile__head">
          <p class="eyebrow">ПРОФИЛЬ</p>
          <h1 class="profile__name">{{ displayName }}</h1>
          <p v-if="bio" class="profile__bio">{{ bio }}</p>
          <RouterLink to="/profile/edit" class="profile__edit">
            Изменить
          </RouterLink>
        </header>

        <div class="profile__tiles">
          <div v-for="tile in tiles" :key="tile.label" class="profile-tile">
            <p class="profile-tile__label">{{ tile.label }}</p>
            <p class="profile-tile__value">{{ tile.value }}</p>
            <p class="profile-tile__note">{{ tile.note }}</p>
          </div>
        </div>

        <section class="profile__build">
          <h2 class="profile__build-title">Текущий билд</h2>
          <div class="profile__build-grid">
            <div class="profile-build-cell">
              <p class="profile-build-cell__label">КЛАСС</p>
              <p class="profile-build-cell__value">{{ currentBuild.className }}</p>
            </div>
            <div class="profile-build-cell">
              <p class="profile-build-cell__label">ОРУЖИЕ</p>
              <p class="profile-build-cell__value">{{ currentBuild.weapon }}</p>
            </div>
            <div class="profile-build-cell">
              <p class="profile-build-cell__label">АКЦЕНТ</p>
              <p class="profile-build-cell__value">{{ currentBuild.magic }}</p>
            </div>
          </div>
        </section>

        <div class="profile__actions">
          <RouterLink to="/profile/edit" class="btn btn--primary">
            <AppIcon name="edit" :size="17" />
            Редактировать профиль
          </RouterLink>
          <RouterLink to="/community" class="btn btn--ghost">
            <AppIcon name="users" :size="17" />
            Сообщество
          </RouterLink>
        </div>

        <dl class="profile__facts">
          <div>
            <dt>Логин</dt>
            <dd>{{ auth.user?.login }}</dd>
          </div>
          <div>
            <dt>Роль</dt>
            <dd>{{ auth.roleLabel }}</dd>
          </div>
          <div>
            <dt>Дата регистрации</dt>
            <dd>
              {{
                profile
                  ? new Date(profile.createdAt).toLocaleDateString('ru-RU')
                  : '—'
              }}
            </dd>
          </div>
        </dl>

        <div class="profile__foot">
          <RouterLink v-if="auth.isModerator" to="/admin" class="link-arrow">
            Перейти в панель управления
            <AppIcon name="arrow-right" :size="15" />
          </RouterLink>
          <button type="button" class="profile__logout" @click="logout">
            <AppIcon name="logout" :size="16" />
            Выйти из аккаунта
          </button>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.page-panel--profile {
  max-width: 492px;
  margin: 0 auto;
  padding: 30px 30px 24px;
}

.profile {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.profile__head {
  position: relative;
  padding: 0;
  border-radius: 0;
  background: none;
  box-shadow: none;
  text-align: center;
}

.profile__name {
  margin-top: 10px;
  font-size: 30px;
  line-height: 1.2;
}

.profile__bio {
  margin-top: 10px;
  color: $ink-soft;
  font-size: 13.5px;
  line-height: 1.55;
}

.profile__edit {
  display: inline-block;
  margin-top: 10px;
  color: $link;
  font-size: 13px;
  font-weight: 600;
}

.profile__tiles {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  margin-top: 96px;
}

.profile-tile {
  padding: 22px 14px 20px;
  border-radius: 12px;
  background: #fff;
  box-shadow: $shadow-card;
  text-align: center;
}

.profile-tile__label {
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.1em;
  color: $muted;
}

.profile-tile__value {
  margin-top: 10px;
  font-size: 26px;
  font-weight: 700;
  line-height: 1.1;
  color: $ink-strong;
}

.profile-tile__note {
  margin-top: 4px;
  color: $muted;
  font-size: 11.5px;
}

.profile__build {
  margin-top: 12px;
  padding: 24px 22px;
  border-radius: 12px;
  background: #fff;
  box-shadow: $shadow-card;
}

.profile__build-title {
  font-size: 15px;
  font-weight: 700;
}

.profile__build-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-top: 16px;
}

.profile-build-cell__label {
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.1em;
  color: $muted;
}

.profile-build-cell__value {
  margin-top: 4px;
  font-size: 13px;
  font-weight: 600;
  line-height: 1.35;
}

.profile__actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 14px;
}

.profile__facts {
  display: grid;
  gap: 10px;
  margin: 20px 0 0;
  padding: 16px 18px;
  border-radius: 12px;
  background: rgba(245, 246, 248, 0.86);

  div {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 16px;
  }

  dt {
    color: $muted;
    font-size: 12.5px;
  }

  dd {
    margin: 0;
    font-size: 13px;
    font-weight: 600;
  }
}

.profile__foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-top: 18px;
  padding: 0 2px;
}

.profile__logout {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  padding: 0;
  border: 0;
  background: none;
  color: $ink-soft;
  font-size: 12.5px;

  &:hover {
    color: $red-ink;
  }
}

.profile__foot .link-arrow {
  font-size: 12.5px;
}

@include media-max(520px) {
  .profile__tiles,
  .profile__build-grid {
    grid-template-columns: 1fr;
  }

  .profile__actions {
    grid-template-columns: 1fr;
  }

  .profile__foot {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
