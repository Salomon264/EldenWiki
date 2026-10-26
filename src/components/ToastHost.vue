<script setup>
import { useUiStore } from '@/stores/ui'
import AppIcon from './AppIcon.vue'

const ui = useUiStore()
</script>

<template>
  <div class="toast-host" aria-live="polite">
    <TransitionGroup name="toast">
      <div v-for="toast in ui.toasts" :key="toast.id" class="toast" :class="`toast--${toast.tone}`">
        <AppIcon :name="toast.tone === 'error' ? 'warning' : 'check'" :size="18" />
        <span class="toast__text">{{ toast.message }}</span>
        <button type="button" class="toast__close" @click="ui.dismiss(toast.id)">
          <AppIcon name="close" :size="16" />
        </button>
      </div>
    </TransitionGroup>
  </div>
</template>

<style scoped lang="scss">
.toast-host {
  position: fixed;
  right: 24px;
  bottom: 24px;
  z-index: 200;
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: min(380px, calc(100vw - 32px));
  pointer-events: none;
}

.toast {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 13px 14px;
  border-radius: 12px;
  background: #f5f6f8;
  box-shadow: $shadow-pop;
  color: $ink;
  font-size: 14px;
  pointer-events: auto;
}

.toast--success {
  border-left: 3px solid $green;
  color: $green-ink;
}

.toast--error {
  border-left: 3px solid $red;
  color: $red-ink;
}

.toast--info {
  border-left: 3px solid $header;
}

.toast__text {
  flex: 1;
  line-height: 1.45;
}

.toast__close {
  display: grid;
  place-items: center;
  padding: 0;
  border: 0;
  background: none;
  color: $muted;
}

.toast-enter-active,
.toast-leave-active {
  transition:
    opacity 0.24s $ease,
    transform 0.24s $ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(10px);
}
</style>
