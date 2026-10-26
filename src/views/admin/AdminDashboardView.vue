<script setup>
import { computed, onMounted } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import { useAdminStore } from '@/stores/admin'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'
import { useWikiStore } from '@/stores/wiki'

const admin = useAdminStore()
const auth = useAuthStore()
const ui = useUiStore()
const wiki = useWikiStore()

const stats = computed(() => admin.stats)

const cards = computed(() => [
  {
    label: 'Всего статей в Wiki',
    value: wiki.allItems().length.toLocaleString('ru-RU'),
    note: wiki.source === 'api' ? 'по данным EldenApi' : 'локальный набор',
    icon: 'book',
    tone: 'neutral',
  },
  {
    label: 'На проверке модераторов',
    value: `${stats.value.pending} материалов`,
    note: stats.value.pending ? 'Требует внимания' : 'Очередь пуста',
    icon: 'queue',
    tone: 'warning',
  },
  {
    label: 'Сотрудники Wiki',
    value: `${stats.value.employees} аккаунтов`,
    note: `${stats.value.editors} с правами модератора`,
    icon: 'users',
    tone: 'success',
  },
  {
    label: 'Категорий в каталоге',
    value: `${wiki.categories.length} разделов`,
    note: 'Снаряжение и материалы',
    icon: 'book',
    tone: 'neutral',
  },
])

const activity = computed(() =>
  wiki.allItems().slice(0, 5).map((item) => ({
    id: item.id,
    title: item.name,
    category: item.itemType || item.category,
    author: 'EldenApi',
    time: 'в базе',
  })),
)

const quickActions = [
  {
    title: 'Зарегистрировать сотрудника',
    text: 'Выдать права модератора или редактора',
    to: '/admin/employees?new=1',
    icon: 'users',
  },
  {
    title: 'Сводный экспорт БД',
    text: 'Резервное копирование статей в JSON/CSV',
    action: 'export',
    icon: 'download',
  },
  {
    title: 'Настройки глобальных фильтров',
    text: 'Управление автоцензурой и спам-листом',
    action: 'filters',
    icon: 'filter',
  },
]

function exportDatabase() {
  const payload = {
    exportedAt: new Date().toISOString(),
    exportedBy: auth.user?.login,
    articles: wiki.allItems(),
    employees: admin.employees,
    moderation: admin.moderation,
  }
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `eldenwiki-export-${new Date().toISOString().slice(0, 10)}.json`
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
  ui.notify('Экспорт базы подготовлен', 'success')
}

function runAction(item) {
  if (item.action === 'export') exportDatabase()
  if (item.action === 'filters') {
    ui.notify('Глобальные фильтры появятся после подключения серверных настроек.', 'info')
  }
}

onMounted(() => {
  admin.loadEmployees()
  wiki.loadArticles()
})
</script>

<template>
  <div class="page">
    <div class="container container--flush">
      <section class="page-panel page-panel--wide dashboard">
        <header class="dashboard__head">
          <div>
            <h1 class="page-title">Главная панель администратора</h1>
            <p class="page-subtitle">
              Контроль контента, активности сотрудников и состояния базы знаний Междуземья
            </p>
          </div>
          <RouterLink to="/admin/items/new" class="btn btn--gold">
            <AppIcon name="plus" :size="17" />
            Новая запись
          </RouterLink>
        </header>

        <div class="stat-grid">
          <article v-for="card in cards" :key="card.label" class="stat-card">
            <div class="stat-card__top">
              <p class="stat-card__label">{{ card.label }}</p>
              <span class="stat-card__icon" :class="`stat-card__icon--${card.tone}`">
                <AppIcon :name="card.icon" :size="16" />
              </span>
            </div>
            <p class="stat-card__value">{{ card.value }}</p>
            <p class="stat-card__note" :class="`stat-card__note--${card.tone}`">{{ card.note }}</p>
          </article>
        </div>

        <div class="dashboard__grid">
          <article class="panel-card panel-card--quick">
            <h2 class="panel-card__title">Быстрые действия</h2>
            <ul class="quick">
              <li v-for="item in quickActions" :key="item.title">
                <RouterLink v-if="item.to" :to="item.to" class="quick__row">
                  <span class="quick__icon"><AppIcon :name="item.icon" :size="17" /></span>
                  <span class="quick__body">
                    <span class="quick__title">{{ item.title }}</span>
                    <span class="quick__text">{{ item.text }}</span>
                  </span>
                  <AppIcon name="chevron-right" :size="16" class="quick__chevron" />
                </RouterLink>
                <button v-else type="button" class="quick__row" @click="runAction(item)">
                  <span class="quick__icon"><AppIcon :name="item.icon" :size="17" /></span>
                  <span class="quick__body">
                    <span class="quick__title">{{ item.title }}</span>
                    <span class="quick__text">{{ item.text }}</span>
                  </span>
                  <AppIcon name="chevron-right" :size="16" class="quick__chevron" />
                </button>
              </li>
            </ul>
          </article>

          <article class="panel-card panel-card--activity">
            <div class="panel-card__head">
              <h2 class="panel-card__title">Последняя активность в Wiki</h2>
              <button type="button" class="panel-card__link" @click="ui.notify('Полный журнал правок появится после подключения API.', 'info')">
                Показать все логи
              </button>
            </div>

            <div class="activity">
              <ul class="activity__list">
                <li v-for="entry in activity" :key="entry.id" class="activity__row">
                  <div class="activity__body">
                    <p class="activity__title">{{ entry.title }}</p>
                    <p class="activity__cat">{{ entry.category }}</p>
                  </div>
                  <span class="activity__author">{{ entry.author }}</span>
                  <span class="activity__time">{{ entry.time }}</span>
                </li>
              </ul>
            </div>
          </article>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.dashboard {
  padding-top: 26px;
}

.dashboard__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 22px;
  margin-top: 30px;
}

.stat-card {
  padding: 20px 22px 18px;
  border-radius: 14px;
  background: $paper;
  box-shadow: $shadow-card;
}

.stat-card__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.stat-card__label {
  color: $ink-soft;
  font-size: 12.5px;
  line-height: 1.4;
}

.stat-card__icon {
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border-radius: 8px;
  background: rgba(88, 112, 172, 0.12);
  color: $header-deep;
  flex: none;
}

.stat-card__icon--warning {
  background: $amber-soft;
  color: $amber-ink;
}

.stat-card__icon--success {
  background: $green-soft;
  color: $green-ink;
}

.stat-card__icon--danger {
  background: $red-soft;
  color: $red-ink;
}

.stat-card__value {
  margin-top: 14px;
  font-size: 26px;
  font-weight: 700;
  line-height: 1.15;
  color: $ink-strong;
}

.stat-card__note {
  margin-top: 6px;
  color: $muted;
  font-size: 12px;
}

.stat-card__note--warning {
  color: $amber-ink;
}

.stat-card__note--success {
  color: $green-ink;
}

.stat-card__note--danger {
  color: $red-ink;
}

.dashboard__grid {
  display: grid;
  grid-template-columns: minmax(0, 500px) minmax(0, 1fr);
  gap: 22px;
  margin-top: 22px;
  align-items: start;
}

.panel-card {
  padding: 22px 24px 24px;
  border-radius: 14px;
  background: $paper;
  box-shadow: $shadow-card;
}

.panel-card__title {
  font-size: 16px;
  font-weight: 700;
}

.panel-card__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;
}

.panel-card__link {
  padding: 0;
  border: 0;
  background: none;
  color: $link;
  font-size: 12.5px;
  font-weight: 600;

  &:hover {
    text-decoration: underline;
  }
}

.quick {
  margin-top: 14px;
  list-style: none;
}

.quick__row {
  display: flex;
  align-items: center;
  gap: 14px;
  width: 100%;
  padding: 14px 0;
  border: 0;
  border-bottom: 1px solid $paper-line;
  background: none;
  color: $ink;
  text-align: left;

  &:last-child {
    border-bottom: 0;
    padding-bottom: 4px;
  }

  &:hover {
    color: $link;

    .quick__icon {
      background: rgba(17, 108, 216, 0.14);
      color: $link;
    }

    .quick__chevron {
      transform: translateX(3px);
    }
  }
}

.quick__icon {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border-radius: 9px;
  background: rgba(88, 112, 172, 0.12);
  color: $header-deep;
  flex: none;
  transition: background-color 0.18s $ease;
}

.quick__body {
  display: flex;
  flex-direction: column;
  gap: 2px;
  flex: 1;
}

.quick__title {
  font-size: 13.5px;
  font-weight: 600;
}

.quick__text {
  color: $muted;
  font-size: 12px;
}

.quick__chevron {
  color: $muted;
  transition: transform 0.18s $ease;
}

.activity {
  margin-top: 12px;
}

.activity__list {
  list-style: none;
}

.activity__row {
  display: flex;
  align-items: baseline;
  gap: 14px;
  padding: 12px 0;
  border-bottom: 1px solid $paper-line;

  &:last-child {
    border-bottom: 0;
  }
}

.activity__body {
  flex: 1;
}

.activity__title {
  font-size: 13.5px;
  font-weight: 600;
  color: $ink-strong;
}

.activity__cat {
  margin-top: 2px;
  color: $muted;
  font-size: 11.5px;
}

.activity__author {
  color: $ink-soft;
  font-size: 12px;
  white-space: nowrap;
}

.activity__time {
  width: 82px;
  color: $muted;
  font-size: 11.5px;
  text-align: right;
  white-space: nowrap;
}

.panel-card--warnings {
  margin-top: 22px;
}

.warnings {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 14px;
  padding-left: 18px;
  color: $ink-soft;
  font-size: 13px;
  line-height: 1.55;

  li::marker {
    color: $red;
  }
}


@include media-max(1280px) {
  .stat-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .dashboard__grid {
    grid-template-columns: 1fr;
  }
}

@include media-max(900px) {
  .activity__row {
    flex-wrap: wrap;
  }
}

@include media-max(700px) {
  .dashboard__head {
    flex-direction: column;
  }

  .stat-grid {
    grid-template-columns: 1fr;
  }
}
</style>
