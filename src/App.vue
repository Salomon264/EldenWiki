<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from '@/components/AppHeader.vue'
import ToastHost from '@/components/ToastHost.vue'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const route = useRoute()

const showDemoNotice = computed(
  () => auth.demoMode && route.name !== 'login' && route.name !== 'register',
)
</script>

<template>
  <div class="app-shell">
    <AppHeader />

    <p v-if="showDemoNotice" class="demo-notice">
      Демо-режим: EldenApi недоступен, данные берутся из локального набора.
    </p>

    <main class="app-main">
      <RouterView v-slot="{ Component }">
        <Transition name="fade" mode="out-in">
          <component :is="Component" />
        </Transition>
      </RouterView>
    </main>

    <ToastHost />
  </div>
</template>

<style scoped lang="scss">
.app-shell {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}

.app-main {
  flex: 1;
}

.demo-notice {
  padding: 8px 56px;
  background: rgba(209, 149, 57, 0.16);
  color: $gold-soft;
  font-size: 12.5px;
  letter-spacing: 0.01em;

  @include media-max(900px) {
    padding: 8px 18px;
  }
}
</style>
