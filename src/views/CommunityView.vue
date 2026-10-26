<script setup>
import { onMounted } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import { useAdminStore } from '@/stores/admin'
import { useWikiStore } from '@/stores/wiki'

const admin = useAdminStore()
const wiki = useWikiStore()

const rules = [
  'Пишите по существу: карточка должна содержать проверенные игровые данные.',
  'Указывайте источник получения предмета и версию игры, если механика менялась.',
  'Не удаляйте чужие правки без обсуждения — используйте комментарий к правке.',
  'Соблюдайте уважительный тон: оскорбления и спам блокируются без предупреждения.',
  'Изображения загружайте только с прозрачным фоном и в формате PNG до 2 МБ.',
]

onMounted(() => {
  admin.loadEmployees()
  wiki.loadArticles()
})
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--wiki community">
        <header class="community__head">
          <h1 class="page-title">Сообщество EldenWiki</h1>
          <p class="page-subtitle">
            Свежие правки, команда проекта и правила, по которым живёт вики Междуземья.
          </p>
        </header>

        <div class="community__grid">
          <section class="community__col">
            <h2 class="section-title">Свежие правки</h2>
            <ul class="feed">
              <li v-for="entry in admin.activity" :key="entry.id" class="feed__row">
                <span class="feed__mark" />
                <div class="feed__body">
                  <p class="feed__title">{{ entry.title }}</p>
                  <p class="feed__meta">{{ entry.category }} · {{ entry.author }}</p>
                </div>
                <span class="feed__time">{{ entry.time }}</span>
              </li>
            </ul>

            <h2 id="rules" class="section-title community__rules-title">Правила вики</h2>
            <ol class="rules">
              <li v-for="rule in rules" :key="rule">{{ rule }}</li>
            </ol>
          </section>

          <aside id="admins" class="community__aside">
            <h2 class="section-title">Администрация</h2>
            <ul class="team">
              <li v-for="person in admin.employees.filter((item) => item.roleId >= 2)" :key="person.id" class="team__row">
                <span class="team__avatar">{{ person.displayName.charAt(0) }}</span>
                <div class="team__body">
                  <p class="team__name">{{ person.displayName }}</p>
                  <p class="team__role">{{ person.roleLabel }} · {{ person.login }}</p>
                </div>
                <span v-if="person.online" class="team__online">онлайн</span>
              </li>
            </ul>

            <div class="community__note">
              <AppIcon name="users" :size="18" />
              <p>
                Хотите помочь с каталогами? Зарегистрируйтесь и предложите правку —
                модераторы проверят её в очереди.
              </p>
            </div>

            <RouterLink to="/build-helper" class="btn btn--gold btn--block community__cta">
              Собрать билд
            </RouterLink>
          </aside>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.community {
  padding-top: 34px;
}

.community__head {
  max-width: 720px;
}

.community__grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 340px;
  gap: 40px;
  margin-top: 32px;
  align-items: start;
}

.feed {
  margin-top: 18px;
  list-style: none;
}

.feed__row {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 14px 0;
  border-bottom: 1px solid rgba(56, 57, 59, 0.12);
}

.feed__mark {
  width: 8px;
  height: 8px;
  margin-top: 6px;
  border-radius: 50%;
  background: $header;
  flex: none;
}

.feed__body {
  flex: 1;
}

.feed__title {
  font-size: 14px;
  font-weight: 600;
  color: $ink-strong;
}

.feed__meta {
  margin-top: 3px;
  color: $muted;
  font-size: 12.5px;
}

.feed__time {
  color: $muted;
  font-size: 12px;
  white-space: nowrap;
}

.community__rules-title {
  margin-top: 34px;
}

.rules {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 16px;
  padding-left: 20px;
  color: $ink-soft;
  font-size: 14px;
  line-height: 1.6;

  li::marker {
    color: $header;
    font-weight: 700;
  }
}

.team {
  margin-top: 16px;
  list-style: none;
}

.team__row {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 11px 0;
  border-bottom: 1px solid rgba(56, 57, 59, 0.12);
}

.team__avatar {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(88, 112, 172, 0.16);
  color: $header-deep;
  font-size: 14px;
  font-weight: 700;
  flex: none;
}

.team__body {
  flex: 1;
}

.team__name {
  font-size: 13.5px;
  font-weight: 600;
}

.team__role {
  margin-top: 2px;
  color: $muted;
  font-size: 12px;
}

.team__online {
  color: $green;
  font-size: 11.5px;
  font-weight: 600;
}

.community__note {
  display: flex;
  gap: 10px;
  margin-top: 20px;
  padding: 14px;
  border-radius: 10px;
  background: rgba(88, 112, 172, 0.1);
  color: $header-deep;
  font-size: 12.5px;
  line-height: 1.55;
}

.community__cta {
  margin-top: 18px;
}

@include media-max(980px) {
  .community__grid {
    grid-template-columns: 1fr;
    gap: 30px;
  }
}
</style>
