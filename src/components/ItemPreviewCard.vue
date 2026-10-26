<script setup>
import { computed } from 'vue'
import AppIcon from './AppIcon.vue'
import ImagePlaceholder from './ImagePlaceholder.vue'
import { CATEGORY_BY_KEY } from '@/data/categories'

const props = defineProps({
  item: { type: Object, default: null },
  label: { type: String, default: 'ПРЕДПРОСМОТР КАРТОЧКИ' },
  showRequirements: { type: Boolean, default: true },
  emptyText: { type: String, default: 'Выберите предмет, чтобы увидеть карточку' },
  compact: { type: Boolean, default: false },
})

const categoryIcon = computed(
  () => CATEGORY_BY_KEY[props.item?.category]?.icon ?? 'sword',
)

const metaRows = computed(() => {
  if (!props.item) return []
  const rows = [{ label: 'Тип оружия', value: props.item.itemType || '—' }]
  if (props.item.damageType) rows.push({ label: 'Тип урона', value: props.item.damageType })
  rows.push({ label: 'Вес', value: formatWeight(props.item.weight) })
  return rows
})

const requirements = computed(() =>
  (props.item?.requirements ?? []).filter((row) => Number(row.value) > 0),
)

const stats = computed(() => props.item?.stats ?? [])

function formatWeight(value) {
  const numeric = Number(value)
  if (Number.isNaN(numeric)) return '—'
  return numeric % 1 === 0 ? numeric.toFixed(1) : String(numeric)
}
</script>

<template>
  <aside class="preview" :class="{ 'preview--compact': compact }">
    <p class="preview__label">{{ label }}</p>

    <template v-if="item">
      <div class="preview__media">
        <ImagePlaceholder
          :label="item.name"
          :icon="categoryIcon"
          :ratio="compact ? 'wide' : 'square'"
        />
      </div>

      <h3 class="preview__name">{{ item.name }}</h3>
      <p v-if="item.effect" class="preview__effect">{{ item.effect }}</p>

      <dl class="preview__meta">
        <div v-for="row in metaRows" :key="row.label" class="preview__meta-row">
          <dt>{{ row.label }}</dt>
          <dd>{{ row.value }}</dd>
        </div>
      </dl>

      <div v-if="showRequirements && requirements.length" class="preview__section">
        <p class="preview__section-title">Требования и характеристики</p>
        <dl class="preview__list">
          <div v-for="row in requirements" :key="`req-${row.label}`" class="preview__list-row">
            <dt>{{ row.label }}</dt>
            <dd>{{ row.value }}</dd>
          </div>
          <div v-for="row in stats" :key="`stat-${row.label}`" class="preview__list-row">
            <dt>{{ row.label }}</dt>
            <dd>{{ row.value }}</dd>
          </div>
        </dl>
      </div>

      <slot />
    </template>

    <div v-else class="preview__empty">
      <AppIcon name="image" :size="26" />
      <p>{{ emptyText }}</p>
    </div>
  </aside>
</template>

<style scoped lang="scss">
.preview {
  display: flex;
  flex-direction: column;
  padding: 26px 26px 30px;
  border-radius: 16px;
  background: $paper;
  box-shadow: $shadow-card;
}

.preview__label {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  color: $muted;
}

.preview__media {
  margin-top: 22px;
}

.preview__name {
  margin-top: 18px;
  font-size: 22px;
  line-height: 1.25;
  text-align: center;
}

.preview__effect {
  margin-top: 8px;
  color: $ink-soft;
  font-size: 13px;
  line-height: 1.45;
  text-align: center;
}

.preview__meta {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin: 20px 0 0;
  padding-top: 16px;
  border-top: 1px solid $paper-line;
}

.preview__meta-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;

  dt {
    color: $muted;
    font-size: 13px;
  }

  dd {
    margin: 0;
    font-size: 14px;
    font-weight: 600;
  }
}

.preview__section {
  margin-top: 20px;
  padding-top: 18px;
  border-top: 1px solid $paper-line;
}

.preview__section-title {
  font-size: 14px;
  font-weight: 700;
  color: $ink-strong;
}

.preview__list {
  display: flex;
  flex-direction: column;
  gap: 9px;
  margin: 14px 0 0;
}

.preview__list-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;

  dt {
    color: $ink-soft;
    font-size: 13px;
  }

  dd {
    margin: 0;
    font-size: 13px;
    font-weight: 600;
  }
}

.preview__empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
  margin-top: 24px;
  padding: 40px 18px;
  border: 1px dashed $paper-line-strong;
  border-radius: 12px;
  color: $muted;
  font-size: 13px;
  text-align: center;
}

.preview--compact {
  padding: 20px;
}
</style>
