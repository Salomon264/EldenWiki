<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import ImagePlaceholder from '@/components/ImagePlaceholder.vue'
import { CATEGORY_BY_KEY } from '@/data/categories'
import { useWikiStore } from '@/stores/wiki'

const props = defineProps({
  category: { type: String, required: true },
})

const wiki = useWikiStore()
const activeTab = ref(0)

const meta = computed(() => CATEGORY_BY_KEY[props.category])

// Стеммы для фильтрации по вкладкам: значения совпадают с itemType из API.
const TAB_FILTERS = {
  Катаны: 'катан',
  'Большие мечи': 'больш',
  Кинжалы: 'кинжал',
  Копья: 'копь',
  Шлемы: 'шлем',
  Доспехи: 'доспех',
  Наручи: 'наруч',
  Поножи: 'понож',
  'Малые щиты': 'малый',
  'Средние щиты': 'средн',
  'Большие щиты': 'больш',
  'Усиление атаки': 'атак',
  Защитные: 'защит',
  Утилитарные: 'утилит',
  Чары: 'чары',
  Молитвы: 'молитв',
  'Камни ковки': 'камен',
  Цветы: 'цвет',
  Руны: 'рун',
}

const items = computed(() => {
  const list = wiki.byCategory(props.category)
  const tab = meta.value?.tabs[activeTab.value] ?? ''
  const stem = TAB_FILTERS[tab]
  if (!stem) return list
  return list.filter((item) => String(item.itemType).toLowerCase().includes(stem))
})

watch(
  () => props.category,
  () => {
    activeTab.value = 0
  },
)

onMounted(() => wiki.loadArticles())
</script>

<template>
  <div class="page">
    <div class="container">
      <section v-if="meta" class="page-panel page-panel--wiki wiki">
        <header class="wiki__head">
          <h1 class="page-title">{{ meta.label }}</h1>
          <p class="page-subtitle">{{ meta.subtitle }}</p>
        </header>

        <div class="wiki__description">
          <h2 class="wiki__h2">Описание</h2>
          <p class="wiki__text">{{ meta.description }}</p>
        </div>

        <nav class="tabs" aria-label="Подкатегории">
          <button
            v-for="(tab, index) in meta.tabs"
            :key="tab"
            type="button"
            class="tabs__item"
            :class="{ 'is-active': activeTab === index }"
            @click="activeTab = index"
          >
            {{ tab }}
          </button>
        </nav>

        <div class="wiki__list-head">
          <h2 class="wiki__h3">{{ meta.listTitle }}</h2>
          <span class="wiki__count">{{ items.length }} записей</span>
        </div>

        <div v-if="wiki.loading && !items.length" class="wiki__grid">
          <div v-for="index in 5" :key="index" class="item-card item-card--skeleton" />
        </div>

        <div v-else-if="items.length" class="wiki__grid">
          <RouterLink
            v-for="item in items"
            :key="item.id"
            :to="`/wiki/${category}/${item.id}`"
            class="item-card"
          >
            <div class="item-card__media">
              <ImagePlaceholder :label="item.name" :icon="meta.icon" ratio="square" />
            </div>
            <span class="item-card__name">{{ item.name }}</span>
            <span class="item-card__type">{{ item.itemType }}</span>
          </RouterLink>
        </div>

        <div v-else class="wiki__empty">
          <AppIcon name="search" :size="26" />
          <p>В этой подкатегории пока нет записей. Загляните позже — база пополняется.</p>
          <button type="button" class="btn btn--ghost btn--sm" @click="activeTab = 0">
            Показать все
          </button>
        </div>

        <div v-if="wiki.source === 'api'" class="wiki__source">
          Данные загружены из EldenApi. Недостающие описания и характеристики отображаются из
          справочника вики.
        </div>
      </section>

      <div v-else class="page-panel page-panel--wiki wiki">
        <h1 class="page-title">Каталог не найден</h1>
        <p class="page-subtitle">
          Такого раздела нет. Вернитесь на
          <RouterLink to="/" class="link">главную</RouterLink> и выберите нужный каталог.
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.wiki {
  padding-top: 26px;
}

.wiki__head {
  max-width: 760px;
}

.wiki__description {
  margin-top: 26px;
}

.wiki__h2 {
  font-size: 22px;
  line-height: 1.3;
}

.wiki__text {
  margin-top: 10px;
  max-width: 800px;
  color: $ink-soft;
  font-size: 15px;
  line-height: 1.62;
}

.tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 28px;
  margin-top: 30px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(56, 57, 59, 0.16);
}

.tabs__item {
  position: relative;
  padding: 4px 0 10px;
  border: 0;
  background: none;
  color: $ink-soft;
  font-size: 14px;
  font-weight: 500;

  &::after {
    content: '';
    position: absolute;
    left: 0;
    right: 0;
    bottom: -13px;
    height: 2px;
    border-radius: 2px;
    background: transparent;
    transition: background-color 0.18s $ease;
  }

  &:hover {
    color: $ink-strong;
  }

  &.is-active {
    color: $ink-strong;
    font-weight: 600;

    &::after {
      background: $ink-strong;
    }
  }
}

.wiki__list-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;
  margin-top: 28px;
}

.wiki__h3 {
  font-size: 20px;
}

.wiki__count {
  color: $muted;
  font-size: 12.5px;
}

.wiki__grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 30px 26px;
  margin-top: 24px;
}

.item-card {
  display: flex;
  flex-direction: column;
  gap: 10px;
  color: $ink;
  text-align: center;
  transition: transform 0.2s $ease;

  &:hover {
    color: $link;
    transform: translateY(-3px);
  }
}

.item-card__media {
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 10px 24px rgba(24, 30, 52, 0.12);
}

.item-card__name {
  font-size: 13px;
  font-weight: 500;
  line-height: 1.35;
}

.item-card__type {
  display: none;
}

.item-card--skeleton {
  height: 210px;
  background: linear-gradient(100deg, #dfe6e9 20%, #eef2f4 40%, #dfe6e9 60%);
  background-size: 220% 100%;
  animation: shimmer 1.3s linear infinite;
}

@keyframes shimmer {
  to {
    background-position: -220% 0;
  }
}

.wiki__empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  margin-top: 22px;
  padding: 44px 20px;
  border: 1px dashed rgba(56, 57, 59, 0.24);
  border-radius: 14px;
  color: $ink-soft;
  font-size: 14px;
  text-align: center;
}

.wiki__source {
  margin-top: 26px;
  padding-top: 16px;
  border-top: 1px solid rgba(56, 57, 59, 0.14);
  color: $muted;
  font-size: 12px;
}

@include media-max(900px) {
  .wiki__grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 22px 18px;
  }

  .tabs {
    gap: 18px;
  }
}

@include media-max(620px) {
  .wiki__grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
