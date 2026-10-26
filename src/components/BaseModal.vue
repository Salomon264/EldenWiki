<script setup>
import { onBeforeUnmount, onMounted } from 'vue'
import AppIcon from './AppIcon.vue'

const props = defineProps({
  open: { type: Boolean, default: false },
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  width: { type: String, default: '560px' },
})

const emit = defineEmits(['close'])

function onKeydown(event) {
  if (event.key === 'Escape' && props.open) emit('close')
}

onMounted(() => document.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => document.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="open" class="modal" role="dialog" aria-modal="true" @click.self="emit('close')">
        <div class="modal__card" :style="{ maxWidth: width }">
          <header class="modal__head">
            <div>
              <h2 v-if="title" class="modal__title">{{ title }}</h2>
              <p v-if="subtitle" class="modal__subtitle">{{ subtitle }}</p>
            </div>
            <button type="button" class="modal__close" aria-label="Закрыть" @click="emit('close')">
              <AppIcon name="close" :size="18" />
            </button>
          </header>
          <div class="modal__body">
            <slot />
          </div>
          <footer v-if="$slots.footer" class="modal__foot">
            <slot name="footer" />
          </footer>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped lang="scss">
.modal {
  position: fixed;
  inset: 0;
  z-index: 150;
  display: grid;
  place-items: center;
  padding: 24px;
  background: rgba(10, 14, 26, 0.62);
  backdrop-filter: blur(3px);
}

.modal__card {
  width: 100%;
  max-height: 90vh;
  overflow: auto;
  border-radius: 18px;
  background: $paper;
  box-shadow: $shadow-pop;
}

.modal__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
  padding: 26px 28px 0;
}

.modal__title {
  font-size: 22px;
  line-height: 1.25;
}

.modal__subtitle {
  margin-top: 6px;
  color: $ink-soft;
  font-size: 14px;
}

.modal__close {
  display: grid;
  place-items: center;
  width: 34px;
  height: 34px;
  border: 1px solid $paper-line;
  border-radius: 9px;
  background: #fff;
  color: $ink-soft;

  &:hover {
    color: $ink;
    border-color: $paper-line-strong;
  }
}

.modal__body {
  padding: 22px 28px 26px;
}

.modal__foot {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 0 28px 26px;
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s $ease;
}

.modal-enter-active .modal__card,
.modal-leave-active .modal__card {
  transition: transform 0.24s $ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal__card,
.modal-leave-to .modal__card {
  transform: translateY(14px) scale(0.98);
}
</style>
