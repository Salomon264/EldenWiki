<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import ItemPreviewCard from '@/components/ItemPreviewCard.vue'
import { CATEGORY_BY_KEY } from '@/data/categories'
import { useWikiStore } from '@/stores/wiki'

const props = defineProps({
  category: { type: String, required: true },
  id: { type: [String, Number], required: true },
})

const wiki = useWikiStore()
const item = ref(null)
const loading = ref(true)

const meta = computed(() => CATEGORY_BY_KEY[props.category])

const metaRows = computed(() => {
  if (!item.value) return []
  const rows = [{ label: 'Тип', value: item.value.itemType }]
  if (item.value.damageType) rows.push({ label: 'Тип урона', value: item.value.damageType })
  if (item.value.weight !== undefined) rows.push({ label: 'Вес', value: item.value.weight })
  return rows
})

async function load() {
  loading.value = true
  await wiki.loadArticles()
  item.value = await wiki.loadItem(props.id)
  loading.value = false
}

onMounted(load)
watch(() => props.id, load)
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--article article">
        <div v-if="loading" class="article__loading">Загружаем карточку…</div>

        <div v-else-if="item" class="article__layout">
          <article class="article__content">
            <h1 class="article__title">{{ item.name }}</h1>

            <ul class="article__meta">
              <li v-for="row in metaRows" :key="row.label">
                {{ row.label }}: <strong>{{ row.value }}</strong>
              </li>
            </ul>

            <section class="article__block">
              <h2 class="article__h2">Описание</h2>
              <p class="article__text">{{ item.description || 'Описание пока не заполнено.' }}</p>
            </section>

            <p v-if="item.skill" class="article__skill">
              Уникальный навык: «{{ item.skill }}»
            </p>

            <p v-else-if="item.effect" class="article__skill">
              Эффект: {{ item.effect }}
            </p>

            <section v-if="item.obtain" class="article__block">
              <h2 class="article__h2">Как получить</h2>
              <p class="article__text">{{ item.obtain }}</p>
            </section>

            <div v-if="item.tags?.length" class="article__tags">
              <span v-for="tag in item.tags" :key="tag" class="article__tag">#{{ tag }}</span>
            </div>

            <div class="article__actions">
              <RouterLink :to="`/wiki/${category}`" class="btn btn--ghost btn--sm">
                <AppIcon name="arrow-left" :size="16" />
                Назад в каталог
              </RouterLink>
              <RouterLink to="/build-helper" class="btn btn--outline btn--sm">
                <AppIcon name="spark" :size="16" />
                Собрать билд с этим предметом
              </RouterLink>
            </div>
          </article>

          <ItemPreviewCard :item="item" />
        </div>

        <div v-else class="article__not-found">
          <h1 class="page-title">Запись не найдена</h1>
          <p class="page-subtitle">
            Возможно, предмет был удалён или ссылка устарела. Вернитесь в
            <RouterLink :to="`/wiki/${category}`" class="link">каталог</RouterLink>.
          </p>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.article {
  padding-top: 58px;
}

.article__layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 372px;
  gap: 78px;
  margin-top: 30px;
  align-items: start;
}

.article__title {
  font-size: clamp(26px, 2.6vw, 32px);
  line-height: 1.2;
}

.article__meta {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-top: 14px;
  padding: 0;
  list-style: none;
  color: $ink-soft;
  font-size: 14px;

  strong {
    color: $ink-strong;
    font-weight: 600;
  }
}

.article__block {
  margin-top: 30px;
}

.article__h2 {
  font-size: 20px;
  line-height: 1.3;
}

.article__text {
  margin-top: 10px;
  color: $ink-soft;
  font-size: 15px;
  line-height: 1.68;
  white-space: pre-line;
}

.article__skill {
  margin-top: 22px;
  color: $ink-strong;
  font-size: 15px;
  font-weight: 600;
}

.article__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 26px;
}

.article__tag {
  padding: 5px 10px;
  border-radius: 999px;
  background: rgba(88, 112, 172, 0.12);
  color: $header-deep;
  font-size: 12px;
  font-weight: 500;
}

.article__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 30px;
  padding-top: 22px;
  border-top: 1px solid rgba(56, 57, 59, 0.14);
}

.article__loading {
  padding: 60px 0;
  color: $muted;
  font-size: 14px;
}

.article__not-found {
  padding: 40px 0 20px;
}

@include media-max(1050px) {
  .article__layout {
    grid-template-columns: 1fr;
    gap: 32px;
  }
}
</style>
