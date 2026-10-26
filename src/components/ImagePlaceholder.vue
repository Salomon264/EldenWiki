<script setup>
import AppIcon from './AppIcon.vue'

defineProps({
  label: { type: String, default: 'Изображение отсутствует' },
  icon: { type: String, default: 'image' },
  ratio: { type: String, default: 'square' },
  tone: { type: String, default: 'light' },
  compact: { type: Boolean, default: false },
})
</script>

<template>
  <div class="placeholder" :class="[`placeholder--${ratio}`, `placeholder--${tone}`, { 'placeholder--compact': compact }]">
    <svg class="placeholder__rune" viewBox="0 0 200 200" aria-hidden="true">
      <circle cx="100" cy="100" r="74" />
      <circle cx="100" cy="100" r="54" />
      <path d="M100 26v148M26 100h148M48 48l104 104M152 48 48 152" />
      <path d="M100 60l14 26 26 14-26 14-14 26-14-26-26-14 26-14 14-26Z" />
    </svg>
    <div class="placeholder__body">
      <AppIcon :name="icon" :size="compact ? 20 : 28" :stroke-width="1.3" />
      <span v-if="!compact" class="placeholder__label">{{ label }}</span>
    </div>
  </div>
</template>

<style scoped lang="scss">
.placeholder {
  position: relative;
  display: grid;
  place-items: center;
  width: 100%;
  overflow: hidden;
  border-radius: 12px;
  border: 1px dashed rgba(56, 57, 59, 0.22);
  background:
    radial-gradient(70% 60% at 30% 20%, rgba(255, 255, 255, 0.85), transparent 70%),
    linear-gradient(150deg, #c3d1d6 0%, #aebfc6 52%, #9fb1ba 100%);
  color: rgba(56, 57, 59, 0.55);
  isolation: isolate;
}

.placeholder--dark {
  border-color: rgba(245, 246, 248, 0.28);
  background:
    radial-gradient(70% 60% at 30% 20%, rgba(255, 255, 255, 0.16), transparent 70%),
    linear-gradient(150deg, #2b3557 0%, #222b48 55%, #1a2238 100%);
  color: rgba(245, 246, 248, 0.7);
}

.placeholder__rune {
  position: absolute;
  inset: 12%;
  width: 76%;
  height: 76%;
  fill: none;
  stroke: currentColor;
  stroke-width: 0.7;
  opacity: 0.22;
  pointer-events: none;
}

.placeholder__body {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 12px;
  text-align: center;
}

.placeholder__label {
  max-width: 200px;
  font-size: 12px;
  line-height: 1.35;
  letter-spacing: 0.01em;
}

.placeholder--square {
  aspect-ratio: 1 / 1;
}

.placeholder--wide {
  aspect-ratio: 16 / 9;
}

.placeholder--portrait {
  aspect-ratio: 3 / 4;
}

.placeholder--tall {
  aspect-ratio: 4 / 5;
}

.placeholder--fill {
  height: 100%;
  min-height: 160px;
}

.placeholder--compact {
  border-radius: 10px;
}
</style>
