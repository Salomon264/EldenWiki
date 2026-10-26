<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import ImagePlaceholder from '@/components/ImagePlaceholder.vue'
import { CATEGORIES } from '@/data/categories'
import { useAdminStore } from '@/stores/admin'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'
import { useWikiStore } from '@/stores/wiki'

const router = useRouter()
const wiki = useWikiStore()
const admin = useAdminStore()
const auth = useAuthStore()
const ui = useUiStore()

const form = ref({
  name: '',
  variant: 'weapon|Катана',
  physicalAttack: 110,
  weight: 2.5,
  reqStrength: 5,
  reqDexterity: 13,
  reqArcane: 0,
  description: '',
  publish: true,
  draft: false,
})

const error = ref('')
const saving = ref(false)
const imageUrl = ref('')
const dragging = ref(false)
const fileInput = ref(null)

const typeGroups = CATEGORIES.map((category) => ({
  key: category.key,
  label: category.label,
  types: category.tabs.slice(1),
}))

const currentCategoryKey = computed(() => form.value.variant.split('|')[0] ?? CATEGORIES[0].key)

const currentCategory = computed(
  () => CATEGORIES.find((item) => item.key === currentCategoryKey.value) ?? CATEGORIES[0],
)

const currentType = computed(() => form.value.variant.split('|')[1] ?? '')

const previewItem = computed(() => ({
  id: 0,
  name: form.value.name || 'Название предмета',
  category: currentCategoryKey.value,
  itemType: currentType.value,
  weight: Number(form.value.weight) || 0,
  description: form.value.description,
  requirements: [
    { label: 'Сила', value: Number(form.value.reqStrength) || 0 },
    { label: 'Ловкость', value: Number(form.value.reqDexterity) || 0 },
    { label: 'Мудрость', value: 0 },
    { label: 'Вера', value: 0 },
    { label: 'Колдовство', value: Number(form.value.reqArcane) || 0 },
  ],
  stats: [
    { label: 'Физ. атака', value: Number(form.value.physicalAttack) || 0 },
    { label: 'Вес', value: Number(form.value.weight) || 0 },
  ],
}))

function pickFile(event) {
  const file = event.target.files?.[0]
  if (!file) return

  if (!file.type.startsWith('image/')) {
    ui.notify('Выберите файл изображения', 'error')
    return
  }

  if (file.size > 2 * 1024 * 1024) {
    ui.notify('Файл больше 2 МБ', 'error')
    return
  }

  if (imageUrl.value) URL.revokeObjectURL(imageUrl.value)
  imageUrl.value = URL.createObjectURL(file)
}

function onDrop(event) {
  dragging.value = false
  const file = event.dataTransfer?.files?.[0]
  if (!file) return
  if (!file.type.startsWith('image/')) {
    ui.notify('Выберите файл изображения', 'error')
    return
  }
  if (imageUrl.value) URL.revokeObjectURL(imageUrl.value)
  imageUrl.value = URL.createObjectURL(file)
}

function clearImage() {
  if (imageUrl.value) URL.revokeObjectURL(imageUrl.value)
  imageUrl.value = ''
}

function save() {
  error.value = ''

  if (form.value.name.trim().length < 2) {
    error.value = 'Укажите название предмета.'
    return
  }

  if (!form.value.description.trim()) {
    error.value = 'Добавьте художественное описание (лор) — оно попадёт в карточку.'
    return
  }

  saving.value = true

  const isDraft = form.value.draft || !form.value.publish

  const created = wiki.addLocalItem({
    name: form.value.name.trim(),
    category: currentCategoryKey.value,
    itemType: currentType.value || currentCategory.value.label,
    weight: Number(form.value.weight) || 0,
    description: form.value.description.trim(),
    obtain: 'Добавлено через панель модератора',
    requirements: previewItem.value.requirements,
    stats: previewItem.value.stats,
    tags: ['новая запись'],
  })

  admin.addModerationEntry({
    title: created.name,
    category: currentCategory.value.label,
    comment: form.value.draft
      ? 'Сохранено как черновик из панели создания записи.'
      : 'Опубликовано из панели создания записи.',
    author: auth.user?.login ?? 'editor',
    status: isDraft ? 'pending' : 'approved',
    reviewer: isDraft ? undefined : auth.displayName,
  })

  saving.value = false

  ui.notify(
    isDraft
      ? 'Черновик сохранён и отправлен в очередь проверки'
      : 'Запись сохранена и опубликована',
    'success',
  )
  router.push(`/wiki/${created.category}/${created.id}`)
}

function cancel() {
  router.back()
}
</script>

<template>
  <div class="page">
    <div class="container container--flush">
      <section class="page-panel page-panel--wide create">
        <header class="create__head">
          <div>
            <h1 class="page-title">Создание записи снаряжения</h1>
            <p class="page-subtitle">
              Заполните характеристики и лорные данные для публикации в EldenWiki
            </p>
          </div>
          <div class="create__head-actions">
            <button type="button" class="btn btn--ghost" @click="cancel">Отмена</button>
            <button type="button" class="btn btn--gold" :disabled="saving" @click="save">
              {{ saving ? 'Сохраняем…' : 'Сохранить в базу' }}
            </button>
          </div>
        </header>

        <div class="create__layout">
          <form class="create__form" @submit.prevent="save">
            <div class="create__row">
              <label class="field create__name">
                <span class="field__label">Название предмета *</span>
                <input
                  v-model="form.name"
                  type="text"
                  class="input"
                  placeholder="Редувия"
                  maxlength="80"
                />
              </label>

              <label class="field create__category">
                <span class="field__label">Категория *</span>
                <select v-model="form.variant" class="select">
                  <optgroup v-for="group in typeGroups" :key="group.key" :label="group.label">
                    <option v-for="type in group.types" :key="type" :value="`${group.key}|${type}`">
                      {{ type }}
                    </option>
                  </optgroup>
                </select>
              </label>
            </div>

            <h2 class="create__section">Характеристики атаки и требования</h2>
            <div class="create__stats">
              <input
                v-model.number="form.physicalAttack"
                type="number"
                min="0"
                class="input"
                placeholder="Физ. Атака (110)"
                aria-label="Физическая атака"
              />
              <input
                v-model.number="form.weight"
                type="number"
                min="0"
                step="0.1"
                class="input"
                placeholder="Вес (1.5)"
                aria-label="Вес"
              />
              <input
                v-model.number="form.reqStrength"
                type="number"
                min="0"
                class="input"
                placeholder="Треб. Сила (5)"
                aria-label="Требование силы"
              />
              <input
                v-model.number="form.reqDexterity"
                type="number"
                min="0"
                class="input"
                placeholder="Треб. Ловк (13)"
                aria-label="Требование ловкости"
              />
              <input
                v-model.number="form.reqArcane"
                type="number"
                min="0"
                class="input"
                placeholder="Треб. Колдовство (13)"
                aria-label="Требование колдовства"
              />
            </div>

            <label class="field create__lore">
              <span class="field__label">Художественное описание (лор)</span>
              <textarea
                v-model="form.description"
                class="textarea"
                placeholder="Кинжал с искривлённым зубчатым лезвием, принадлежавший убийце из Кровавого пальца..."
              />
            </label>

            <div class="create__image">
              <p class="field__label">Изображение предмета</p>
              <div
                class="dropzone"
                :class="{ 'dropzone--dragging': dragging }"
                role="button"
                tabindex="0"
                @click="fileInput?.click()"
                @keydown.enter.prevent="fileInput?.click()"
                @dragover.prevent="dragging = true"
                @dragleave.prevent="dragging = false"
                @drop.prevent="onDrop"
              >
                <template v-if="imageUrl">
                  <img :src="imageUrl" alt="Предпросмотр" class="dropzone__preview" />
                  <button type="button" class="dropzone__clear" @click.stop="clearImage">
                    <AppIcon name="close" :size="15" />
                  </button>
                </template>
                <template v-else>
                  <AppIcon name="upload" :size="24" />
                  <p class="dropzone__title">
                    Перетащите изображение сюда или выберите на компьютере
                  </p>
                  <p class="dropzone__hint">Рекомендуется PNG на прозрачном фоне, до 2 МБ</p>
                </template>
              </div>
              <input
                ref="fileInput"
                type="file"
                accept="image/png,image/jpeg,image/webp"
                class="sr-only"
                @change="pickFile"
              />
            </div>

            <div class="create__options">
              <label class="checkbox">
                <input v-model="form.publish" type="checkbox" />
                Опубликовать сразу
              </label>
              <label class="checkbox">
                <input v-model="form.draft" type="checkbox" />
                Сохранить как черновик
              </label>
            </div>

            <p v-if="error" class="create__error">{{ error }}</p>

            <div class="create__actions">
              <button type="submit" class="btn btn--primary" :disabled="saving">
                Сохранить в базу
              </button>
              <button type="button" class="btn btn--ghost" @click="cancel">Отмена</button>
            </div>
          </form>

          <aside class="create__preview">
            <p class="create__preview-label">ПРЕДПРОСМОТР КАРТОЧКИ</p>

            <div class="create__preview-media">
              <img v-if="imageUrl" :src="imageUrl" alt="Изображение предмета" />
              <ImagePlaceholder
                v-else
                :label="previewItem.name"
                :icon="currentCategory.icon"
                ratio="square"
              />
            </div>

            <h2 class="create__preview-name">{{ previewItem.name }}</h2>

            <dl class="create__preview-meta">
              <div>
                <dt>Тип оружия</dt>
                <dd>{{ previewItem.itemType || '—' }}</dd>
              </div>
              <div>
                <dt>Вес</dt>
                <dd>{{ Number(previewItem.weight).toFixed(1) }}</dd>
              </div>
            </dl>

            <p class="create__preview-section">Требования и характеристики</p>
            <dl class="create__preview-list">
              <div v-for="row in previewItem.requirements.filter((item) => item.value > 0)" :key="row.label">
                <dt>{{ row.label }}</dt>
                <dd>{{ row.value }}</dd>
              </div>
              <div v-for="row in previewItem.stats" :key="row.label">
                <dt>{{ row.label }}</dt>
                <dd>{{ row.value }}</dd>
              </div>
            </dl>

            <p class="create__preview-note">
              Изображение используется только для предпросмотра: загрузка файлов появится после
              добавления хранилища в API.
            </p>
          </aside>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.create {
  padding-top: 26px;
}

.create__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 24px;
}

.create__head-actions {
  display: flex;
  gap: 12px;
}

.create__layout {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 44px;
  margin-top: 24px;
  align-items: start;
}

.create__row {
  display: grid;
  grid-template-columns: minmax(0, 550px) 298px;
  gap: 18px;
}

.create__section {
  margin-top: 24px;
  font-size: 15px;
  font-weight: 700;
}

.create__stats {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 18px;
  margin-top: 14px;
}

.create__lore {
  margin-top: 22px;
}

.create__image {
  margin-top: 22px;
}

.dropzone {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  min-height: 160px;
  margin-top: 10px;
  padding: 20px;
  border: 1px dashed rgba(56, 57, 59, 0.28);
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.6);
  color: $ink-soft;
  cursor: pointer;
  text-align: center;
  transition:
    border-color 0.18s $ease,
    background-color 0.18s $ease;

  &:hover,
  &--dragging {
    border-color: $header;
    background: rgba(88, 112, 172, 0.08);
  }
}

.dropzone__title {
  font-size: 13px;
  font-weight: 600;
  color: $ink-strong;
}

.dropzone__hint {
  color: $muted;
  font-size: 11.5px;
}

.dropzone__preview {
  max-height: 190px;
  border-radius: 8px;
  object-fit: contain;
}

.dropzone__clear {
  position: absolute;
  top: 10px;
  right: 10px;
  display: grid;
  place-items: center;
  width: 28px;
  height: 28px;
  border: 1px solid $paper-line;
  border-radius: 8px;
  background: #fff;
  color: $ink-soft;
}

.create__options {
  display: flex;
  flex-wrap: wrap;
  gap: 26px;
  margin-top: 22px;
}

.create__error {
  margin-top: 16px;
  padding: 10px 12px;
  border-radius: 8px;
  background: $red-soft;
  color: $red-ink;
  font-size: 13px;
}

.create__actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.create__preview {
  position: sticky;
  top: 24px;
  padding: 24px;
  border-radius: 16px;
  background: $paper;
  box-shadow: $shadow-card;
}

.create__preview-label {
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.14em;
  color: $muted;
}

.create__preview-media {
  margin-top: 18px;

  img {
    width: 100%;
    border-radius: 12px;
    object-fit: cover;
  }
}

.create__preview-name {
  margin-top: 16px;
  font-size: 22px;
  text-align: center;
}

.create__preview-meta {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin: 18px 0 0;
  padding-top: 16px;
  border-top: 1px solid $paper-line;

  div {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 14px;
  }

  dt {
    color: $muted;
    font-size: 13px;
  }

  dd {
    margin: 0;
    font-size: 13.5px;
    font-weight: 600;
  }
}

.create__preview-section {
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px solid $paper-line;
  font-size: 13.5px;
  font-weight: 700;
}

.create__preview-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin: 12px 0 0;

  div {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 14px;
  }

  dt {
    color: $ink-soft;
    font-size: 12.5px;
  }

  dd {
    margin: 0;
    font-size: 12.5px;
    font-weight: 600;
  }
}

.create__preview-note {
  margin-top: 18px;
  padding-top: 14px;
  border-top: 1px solid $paper-line;
  color: $muted;
  font-size: 11px;
  line-height: 1.5;
}

@include media-max(1200px) {
  .create__layout {
    grid-template-columns: 1fr;
  }

  .create__preview {
    position: static;
    max-width: 380px;
  }
}

@include media-max(900px) {
  .create__head {
    flex-direction: column;
  }

  .create__row,
  .create__stats {
    grid-template-columns: 1fr 1fr;
  }
}

@include media-max(600px) {
  .create__row,
  .create__stats {
    grid-template-columns: 1fr;
  }
}
</style>
