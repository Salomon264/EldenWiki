import { defineStore } from 'pinia'
import { ref } from 'vue'

let counter = 0

export const useUiStore = defineStore('ui', () => {
  const toasts = ref([])
  const mobileNavOpen = ref(false)

  function notify(message, tone = 'info', timeout = 4200) {
    const id = ++counter
    toasts.value = [...toasts.value, { id, message, tone }]
    window.setTimeout(() => dismiss(id), timeout)
  }

  function dismiss(id) {
    toasts.value = toasts.value.filter((toast) => toast.id !== id)
  }

  function toggleMobileNav(value) {
    mobileNavOpen.value = value ?? !mobileNavOpen.value
  }

  return { toasts, mobileNavOpen, notify, dismiss, toggleMobileNav }
})
