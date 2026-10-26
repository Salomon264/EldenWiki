<script setup>
import { computed, ref } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import StatusBadge from '@/components/StatusBadge.vue'
import { useAdminStore } from '@/stores/admin'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const admin = useAdminStore()
const auth = useAuthStore()
const ui = useUiStore()

const search = ref('')
const category = ref('')

const STATUS_META = {
  pending: { label: 'Ожидает проверки', tone: 'warning' },
  approved: { label: 'Одобрено', tone: 'success' },
  rejected: { label: 'Отклонено', tone: 'danger' },
}

const categories = computed(() => [
  ...new Set(admin.moderation.map((entry) => entry.category)),
])

const pendingCount = computed(
  () => admin.moderation.filter((entry) => entry.status === 'pending').length,
)

const filtered = computed(() =>
  admin.moderation.filter((entry) => {
    const query = search.value.trim().toLowerCase()
    const matchesSearch =
      !query ||
      entry.title.toLowerCase().includes(query) ||
      entry.author.toLowerCase().includes(query)
    const matchesCategory = !category.value || entry.category === category.value
    return matchesSearch && matchesCategory
  }),
)

function decide(entry, status) {
  admin.setModerationStatus(entry.id, status, auth.displayName)
  ui.notify(
    status === 'approved'
      ? `Статья «${entry.title}» одобрена и опубликована`
      : `Правка «${entry.title}» отклонена`,
    status === 'approved' ? 'success' : 'error',
  )
}
</script>

<template>
  <div class="page">
    <div class="container container--flush">
      <section class="page-panel page-panel--wide moderation">
        <header class="moderation__head">
          <div>
            <h1 class="page-title">Панель модератора статей</h1>
            <p class="page-subtitle">
              Проверяйте новые правки от сообщества, пресекайте спам и верифицируйте
              характеристики
            </p>
          </div>
        </header>

        <div class="moderation__stats">
          <article class="moderation-stat">
            <p class="moderation-stat__label">Всего в очереди проверки</p>
            <p class="moderation-stat__value">{{ pendingCount + 11 }} статей</p>
          </article>
          <article class="moderation-stat">
            <p class="moderation-stat__label">Среднее время проверки</p>
            <p class="moderation-stat__value">15 минут</p>
          </article>
          <article class="moderation-stat">
            <p class="moderation-stat__label">Проверено вами сегодня</p>
            <p class="moderation-stat__value">34 статьи</p>
          </article>
        </div>

        <div class="moderation__toolbar">
          <input
            v-model="search"
            type="search"
            class="input input--search moderation__search"
            placeholder="Поиск по статьям на проверке..."
          />
          <select v-model="category" class="select moderation__select">
            <option value="">Все категории</option>
            <option v-for="item in categories" :key="item" :value="item">{{ item }}</option>
          </select>
        </div>

        <div class="moderation__queue">
          <article v-for="entry in filtered" :key="entry.id" class="queue-card">
            <div class="queue-card__main">
              <div class="queue-card__head">
                <h2 class="queue-card__title">{{ entry.title }}</h2>
                <StatusBadge
                  :label="STATUS_META[entry.status].label"
                  :tone="STATUS_META[entry.status].tone"
                />
              </div>

              <p class="queue-card__label">КОММЕНТАРИЙ К ПРАВКЕ</p>
              <p class="queue-card__comment">{{ entry.comment }}</p>
              <p class="queue-card__author">Автор: {{ entry.author }}</p>
            </div>

            <div class="queue-card__side">
              <span class="queue-card__time">{{ entry.time }}</span>

              <div v-if="entry.status === 'pending'" class="queue-card__actions">
                <button
                  type="button"
                  class="btn btn--danger btn--sm"
                  @click="decide(entry, 'rejected')"
                >
                  Отклонить
                </button>
                <button
                  type="button"
                  class="btn btn--success btn--sm"
                  @click="decide(entry, 'approved')"
                >
                  <AppIcon name="check" :size="15" />
                  Одобрить и выпустить
                </button>
              </div>

              <p v-else class="queue-card__resolved">
                <template v-if="entry.status === 'approved'">
                  Опубликовано<template v-if="entry.reviewer"> · {{ entry.reviewer }}</template>
                </template>
                <template v-else>
                  Отклонено<template v-if="entry.reviewer"> · {{ entry.reviewer }}</template>
                </template>
              </p>
            </div>
          </article>

          <p v-if="!filtered.length" class="moderation__empty">
            В очереди нет статей, подходящих под фильтр. Отличная работа!
          </p>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.moderation {
  padding-top: 26px;
}

.moderation__stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 18px;
  margin-top: 22px;
}

.moderation-stat {
  padding: 18px 22px;
  border-radius: 12px;
  background: $paper;
  box-shadow: $shadow-card;
}

.moderation-stat__label {
  color: $ink-soft;
  font-size: 12.5px;
}

.moderation-stat__value {
  margin-top: 8px;
  font-size: 20px;
  font-weight: 700;
  color: $ink-strong;
}

.moderation__toolbar {
  display: flex;
  gap: 14px;
  margin-top: 20px;
}

.moderation__search {
  flex: 1;
}

.moderation__select {
  width: 198px;
}

.moderation__queue {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-top: 18px;
}

.queue-card {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
  padding: 22px 24px;
  border-radius: 12px;
  background: $paper;
  box-shadow: $shadow-card;
}

.queue-card__main {
  flex: 1;
  min-width: 0;
}

.queue-card__head {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.queue-card__title {
  font-size: 16px;
  font-weight: 700;
}

.queue-card__label {
  margin-top: 14px;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.1em;
  color: $muted;
}

.queue-card__comment {
  margin-top: 5px;
  color: $ink-soft;
  font-size: 13.5px;
  line-height: 1.5;
}

.queue-card__author {
  margin-top: 10px;
  color: $muted;
  font-size: 12px;
}

.queue-card__side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 16px;
  flex: none;
}

.queue-card__time {
  color: $muted;
  font-size: 12px;
  white-space: nowrap;
}

.queue-card__actions {
  display: flex;
  align-items: center;
  gap: 10px;
}

.queue-card__resolved {
  color: $green-ink;
  font-size: 12.5px;
  font-weight: 600;
}

.moderation__empty {
  padding: 32px 0;
  color: $muted;
  font-size: 13.5px;
  text-align: center;
}

@include media-max(1000px) {
  .moderation__stats {
    grid-template-columns: 1fr;
  }

  .queue-card {
    flex-direction: column;
  }

  .queue-card__side {
    align-items: flex-start;
    width: 100%;
  }
}

@include media-max(700px) {
  .moderation__toolbar {
    flex-direction: column;
  }

  .moderation__select {
    width: 100%;
  }
}
</style>
