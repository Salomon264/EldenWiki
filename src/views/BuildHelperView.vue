<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import ItemPreviewCard from '@/components/ItemPreviewCard.vue'
import { STAT_FIELDS, useBuildStore } from '@/stores/builds'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const build = useBuildStore()
const auth = useAuthStore()
const ui = useUiStore()

const previewRef = ref(null)

const model = computed(() => build.model)
const prediction = computed(() => build.prediction)

// Оружие из ответа модели. Если статьи в вики нет — показываем карточку
// с названием, которое назвала модель, а не пустой блок.
const previewItem = computed(() => {
  const result = prediction.value
  if (!result?.ready) return null
  if (result.item) return result.item
  return {
    name: result.weapon,
    category: 'weapon',
    itemType: 'Статьи в вики пока нет',
    weight: null,
    requirements: [],
    stats: [],
  }
})

const wikiItem = computed(() => prediction.value?.item ?? null)

const weightsLabel = computed(() => {
  const weights = model.value?.weights
  if (weights === 'distance') return 'по расстоянию'
  if (weights === 'uniform') return 'равные'
  return weights || '—'
})

// Из какой базы считает KNN: настоящая выборка модели или оружие из вики.
const isModelBase = computed(() => prediction.value?.ready && prediction.value.source === 'model')

const baseLabel = computed(() => {
  if (!prediction.value?.ready) return 'база не готова'
  return isModelBase.value
    ? `обучающая выборка: ${prediction.value.datasetSize}`
    : `оружие вики: ${prediction.value.datasetSize}`
})

const confidencePercent = computed(() => {
  if (!prediction.value?.ready) return 0
  return Math.round(prediction.value.confidence * 100)
})

const candidates = computed(() => (prediction.value?.candidates ?? []).slice(0, 5))

const summary = computed(() => {
  const result = prediction.value
  if (!result) return 'Заполните характеристики — модель подберёт оружие.'
  if (!result.ready) return result.reason
  const percent = Math.round(result.confidence * 100)
  if (result.item) {
    return `Модель подобрала «${result.weapon}» (похожесть ${percent}%): ближайшие требования к вашему набору характеристик.`
  }
  return `Модель назвала «${result.weapon}» (похожесть ${percent}%), но такой статьи в вики пока нет.`
})

function download(payload, filename) {
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  link.remove()
  URL.revokeObjectURL(url)
}

function save() {
  const saved = build.saveBuild(auth.isAuthenticated ? auth.displayName : 'Гость')
  ui.notify(`Билд «${saved.name}» сохранён`, 'success')
}

function downloadCurrent() {
  download(
    {
      name: build.buildName,
      stats: build.stats,
      model: model.value ? { name: model.value.name, k: model.value.k, weights: model.value.weights } : null,
      predictedWeapon: prediction.value?.weapon ?? null,
      confidence: prediction.value?.ready ? Number(prediction.value.confidence.toFixed(3)) : null,
      base: prediction.value?.source ?? null,
      focus: build.focus,
      note: build.note,
      createdAt: new Date().toISOString(),
    },
    `${(build.buildName || 'build').replace(/\s+/g, '-').toLowerCase()}.json`,
  )
  ui.notify('Файл билда скачан', 'success')
}

function downloadSaved(saved) {
  download(saved, `${saved.name.replace(/\s+/g, '-').toLowerCase()}.json`)
}

function applyBuild(saved) {
  build.stats = { ...saved.stats }
  build.buildName = saved.name
  build.note = saved.note
  ui.notify(`Загружен билд «${saved.name}»`, 'info')
}

function removeSaved(saved) {
  build.removeBuild(saved.id)
  ui.notify('Билд удалён', 'info')
}

function pick() {
  build.predict()
  previewRef.value?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  ui.notify(summary.value, 'info')
}

// Характеристику меняешь — предсказание пересчитывается сразу.
watch(
  () => ({ ...build.stats }),
  () => build.predict(),
  { deep: true },
)

onMounted(() => build.loadModel())
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--article helper">
        <header class="helper__head">
          <div>
            <h1 class="page-title">Помощник билдов</h1>
            <p class="page-subtitle">Заполните характеристики вашего персонажа</p>
          </div>
          <button type="button" class="btn btn--gold" @click="pick">
            Подбор
            <AppIcon name="spark" :size="17" />
          </button>
        </header>

        <div class="model">
          <div class="model__head">
            <p class="eyebrow">Модель подбора</p>
            <span v-if="build.modelLoading" class="small muted">Загружаем модель…</span>
          </div>

          <div v-if="model" class="model__chips">
            <span class="model__chip"><b>{{ model.name }}</b></span>
            <span class="model__chip">соседей k = {{ model.k }}</span>
            <span class="model__chip">веса: {{ weightsLabel }}</span>
            <span class="model__chip">признаков: {{ model.features.length }}</span>
            <span class="model__chip">оружия в словаре: {{ model.classes }}</span>
            <span class="model__chip model__chip--base">{{ baseLabel }}</span>
          </div>

          <p v-if="model" class="model__note">{{ baseNote }}</p>
          <p v-else-if="build.modelError" class="model__note model__note--error">
            {{ build.modelError }}
          </p>
        </div>

        <div class="helper__layout">
          <form class="helper__form" @submit.prevent="pick">
            <div class="helper__form-head">
              <h2 class="helper__h2">Характеристики</h2>
              <span class="helper__total">Сумма: {{ build.total }}</span>
            </div>

            <div class="helper__fields">
              <label v-for="field in STAT_FIELDS" :key="field.key" class="stat-field">
                <span class="stat-field__label">{{ field.label }}</span>
                <input
                  v-model.number="build.stats[field.key]"
                  type="number"
                  min="1"
                  max="99"
                  class="input"
                  :aria-label="field.label"
                />
              </label>
            </div>

            <div class="helper__extra">
              <label class="field">
                <span class="field__label">Название билда</span>
                <input v-model="build.buildName" type="text" class="input" maxlength="60" />
              </label>
              <label class="field">
                <span class="field__label">Заметка</span>
                <textarea
                  v-model="build.note"
                  class="textarea"
                  placeholder="Например: прыжковые атаки, тяжёлый щит, инфузия Heavy"
                />
              </label>
            </div>

            <div class="helper__actions">
              <button type="submit" class="btn btn--primary" :disabled="!build.modelReady">
                Сгенерировать
              </button>
              <button type="button" class="btn btn--ghost" @click="save">
                <AppIcon name="save" :size="17" />
                Сохранить билд
              </button>
              <button type="button" class="btn btn--outline" @click="downloadCurrent">
                <AppIcon name="download" :size="17" />
                Скачать
              </button>
              <button type="button" class="btn btn--outline" @click="build.reset()">Сбросить</button>
            </div>

            <p class="helper__summary">{{ summary }}</p>

            <div v-if="candidates.length" class="candidates">
              <p class="eyebrow">Варианты модели</p>
              <ul class="candidates__list">
                <li v-for="candidate in candidates" :key="candidate.label" class="candidate">
                  <span class="candidate__name">{{ candidate.label }}</span>
                  <span class="candidate__bar" aria-hidden="true">
                    <span class="candidate__fill" :style="{ width: `${Math.round(candidate.share * 100)}%` }" />
                  </span>
                  <span class="candidate__value">{{ Math.round(candidate.share * 100) }}%</span>
                  <span class="candidate__distance">d={{ candidate.distance.toFixed(1) }}</span>
                </li>
              </ul>
            </div>
          </form>

          <div ref="previewRef">
            <ItemPreviewCard
              :item="previewItem"
              :label="previewItem ? 'РЕКОМЕНДАЦИЯ МОДЕЛИ' : 'ПРЕДПРОСМОТР КАРТОЧКИ'"
              :empty-text="
                prediction && !prediction.ready
                  ? prediction.reason
                  : 'Заполните характеристики, чтобы получить рекомендацию'
              "
            >
              <div v-if="prediction && prediction.ready" class="helper__focus">
                <span class="helper__focus-label">Похожесть</span>
                <span class="helper__focus-value">{{ confidencePercent }}%</span>
              </div>

              <div v-if="prediction && prediction.ready" class="helper__focus">
                <span class="helper__focus-label">Акцент билда</span>
                <span class="helper__focus-value">{{ build.focus }}</span>
              </div>

              <RouterLink
                v-if="wikiItem"
                :to="{
                  name: 'article',
                  params: { category: wikiItem.category, id: wikiItem.id },
                }"
                class="link-arrow helper__link"
              >
                Открыть статью в вики
                <AppIcon name="arrow-right" :size="16" />
              </RouterLink>

              <p v-else-if="prediction && prediction.ready" class="helper__weapon">
                Модель назвала оружие вне каталога — статьи о нём в вики пока нет.
              </p>
            </ItemPreviewCard>
          </div>
        </div>

        <section class="saved">
          <div class="saved__head">
            <h2 class="section-title">Сохранённые билды</h2>
            <span class="saved__count">{{ build.savedBuilds.length }}</span>
          </div>

          <div v-if="build.savedBuilds.length" class="saved__list">
            <article v-for="saved in build.savedBuilds" :key="saved.id" class="saved-card">
              <div class="saved-card__body">
                <h3 class="saved-card__title">{{ saved.name }}</h3>
                <p class="saved-card__meta">
                  {{ saved.itemName }} · {{ saved.author }} ·
                  {{ new Date(saved.createdAt).toLocaleDateString('ru-RU') }}
                </p>
                <p class="saved-card__stats">
                  <span v-for="field in STAT_FIELDS" :key="field.key">
                    {{ field.label }}: {{ saved.stats[field.key] }}
                  </span>
                  <span v-if="saved.confidence !== null && saved.confidence !== undefined">
                    похожесть: {{ saved.confidence }}%
                  </span>
                </p>
                <p v-if="saved.note" class="saved-card__note">{{ saved.note }}</p>
              </div>
              <div class="saved-card__actions">
                <button type="button" class="btn btn--ghost btn--sm" @click="applyBuild(saved)">
                  Загрузить
                </button>
                <button type="button" class="btn btn--ghost btn--sm" @click="downloadSaved(saved)">
                  <AppIcon name="download" :size="15" />
                  Скачать
                </button>
                <button type="button" class="btn btn--danger btn--sm" @click="removeSaved(saved)">
                  <AppIcon name="trash" :size="15" />
                </button>
              </div>
            </article>
          </div>

          <div v-else class="saved__empty">
            Пока нет сохранённых билдов. Настройте характеристики и нажмите «Сохранить билд».
          </div>
        </section>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.helper {
  padding-top: 34px;
}

.helper__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
}

/* --- Блок с описанием модели ------------------------------------------- */
.model {
  margin-top: 26px;
  padding: 16px 18px;
  border: 1px solid $paper-line;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.55);
}

.model__head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;
}

.model__chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 12px;
}

.model__chip {
  padding: 5px 11px;
  border-radius: 999px;
  background: rgba(88, 112, 172, 0.12);
  color: $header-deep;
  font-size: 12.5px;
}

.model__chip--base {
  background: $gold-soft;
  color: $amber-ink;
}

.model__note {
  margin-top: 12px;
  color: $ink-soft;
  font-size: 12.5px;
  line-height: 1.55;
}

.model__note--error {
  color: $red-ink;
}

.helper__layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 372px;
  gap: 66px;
  margin-top: 32px;
  align-items: start;
}

.helper__form-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 16px;
}

.helper__h2 {
  font-size: 20px;
}

.helper__total {
  color: $muted;
  font-size: 12.5px;
}

.helper__fields {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-top: 18px;
  max-width: 348px;
}

.stat-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.stat-field__label {
  font-size: 13px;
  font-weight: 600;
  color: $ink-strong;
}

.helper__extra {
  display: grid;
  gap: 16px;
  margin-top: 26px;
  max-width: 520px;
}

.helper__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 26px;
}

.helper__summary {
  margin-top: 20px;
  padding: 14px 16px;
  border-radius: 10px;
  background: rgba(88, 112, 172, 0.1);
  color: $header-deep;
  font-size: 13.5px;
  line-height: 1.55;
}

/* --- Варианты, которые дала модель -------------------------------------- */
.candidates {
  margin-top: 18px;
}

.candidates__list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 12px;
  list-style: none;
}

.candidate {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 120px 42px 54px;
  align-items: center;
  gap: 12px;
  font-size: 13px;
}

.candidate__name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: $ink-strong;
}

.candidate__bar {
  display: block;
  height: 6px;
  border-radius: 999px;
  background: rgba(56, 57, 59, 0.12);
  overflow: hidden;
}

.candidate__fill {
  display: block;
  height: 100%;
  border-radius: 999px;
  background: $header;
}

.candidate__value {
  text-align: right;
  font-weight: 600;
  color: $header-deep;
}

.candidate__distance {
  text-align: right;
  color: $muted;
  font-size: 12px;
}

.helper__weapon {
  margin-top: 16px;
  padding: 12px 14px;
  border-radius: 10px;
  background: $gold-soft;
  color: $amber-ink;
  font-size: 13px;
}

.helper__focus {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  margin-top: 16px;
  padding-top: 14px;
  border-top: 1px solid $paper-line;
}

.helper__focus-label {
  color: $muted;
  font-size: 13px;
}

.helper__focus-value {
  font-size: 13px;
  font-weight: 600;
}

.helper__link {
  display: inline-flex;
  margin-top: 16px;
}

.saved {
  margin-top: 46px;
  padding-top: 26px;
  border-top: 1px solid rgba(56, 57, 59, 0.14);
}

.saved__head {
  display: flex;
  align-items: center;
  gap: 12px;
}

.saved__count {
  display: grid;
  place-items: center;
  min-width: 26px;
  height: 22px;
  padding: 0 7px;
  border-radius: 999px;
  background: rgba(56, 57, 59, 0.1);
  color: $ink-soft;
  font-size: 12px;
  font-weight: 600;
}

.saved__list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-top: 18px;
}

.saved-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 22px;
  padding: 18px 20px;
  border-radius: 12px;
  background: $paper;
  box-shadow: $shadow-card;
}

.saved-card__title {
  font-size: 16px;
}

.saved-card__meta {
  margin-top: 4px;
  color: $muted;
  font-size: 12.5px;
}

.saved-card__stats {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 8px;
  color: $ink-soft;
  font-size: 12.5px;
}

.saved-card__note {
  margin-top: 6px;
  color: $ink-soft;
  font-size: 12.5px;
  font-style: italic;
}

.saved-card__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.saved__empty {
  margin-top: 16px;
  padding: 28px 22px;
  border: 1px dashed rgba(56, 57, 59, 0.22);
  border-radius: 12px;
  color: $muted;
  font-size: 13.5px;
  text-align: center;
}

@include media-max(1000px) {
  .helper__layout {
    grid-template-columns: 1fr;
    gap: 30px;
  }

  .candidate {
    grid-template-columns: minmax(0, 1fr) 80px 40px;
  }

  .candidate__distance {
    display: none;
  }

  .saved-card {
    flex-direction: column;
    align-items: flex-start;
  }
}

@include media-max(600px) {
  .helper__head {
    flex-direction: column;
  }
}
</style>
