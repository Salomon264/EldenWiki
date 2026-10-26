<script setup>
import { computed } from 'vue'

const props = defineProps({
  name: { type: String, required: true },
  size: { type: [Number, String], default: 20 },
  strokeWidth: { type: [Number, String], default: 1.6 },
})

const paths = {
  sword: 'M14.5 3.5 20 3l-.5 5.5-9 9-2.5.5L5 21l-2-2 3-3 .5-2.5 9-9Z M6 16l2 2',
  armor: 'M12 3l7 3v6c0 4.2-2.9 7.5-7 9-4.1-1.5-7-4.8-7-9V6l7-3Z M9 9l3 2 3-2 M9 15h6',
  shield: 'M12 3l7 3v5.5c0 4.3-2.9 7.6-7 9.5-4.1-1.9-7-5.2-7-9.5V6l7-3Z M12 8v6',
  talisman: 'M12 3a3 3 0 0 1 3 3v1.5l3 3.5-3 3.5V16a3 3 0 0 1-6 0v-1.5L6 11l3-3.5V6a3 3 0 0 1 3-3Z M12 21v-2',
  spell: 'M12 3l1.9 5.1L19 10l-5.1 1.9L12 17l-1.9-5.1L5 10l5.1-1.9L12 3Z M18 15l.9 2.1L21 18l-2.1.9L18 21l-.9-2.1L15 18l2.1-.9L18 15Z',
  material: 'M12 3l6 4.5v9L12 21l-6-4.5v-9L12 3Z M12 8v8 M8 10.5l8 4 M16 10.5l-8 4',
  search: 'M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14Z M16.2 16.2 21 21',
  'chevron-down': 'M6 9l6 6 6-6',
  'chevron-right': 'M9 6l6 6-6 6',
  'arrow-right': 'M4 12h15 M13 6l6 6-6 6',
  'arrow-left': 'M20 12H5 M11 18l-6-6 6-6',
  user: 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z M4 21c0-3.5 3.6-6 8-6s8 2.5 8 6',
  users: 'M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z M2 20c0-3 3.1-5.5 7-5.5S16 17 16 20 M17 5.2a3.5 3.5 0 0 1 0 6.6 M18 14.6c2.4.7 4 2.5 4 4.9',
  edit: 'M4 20h4l10-10-4-4L4 16v4Z M14 6l4 4',
  block: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z M6 6l12 12',
  check: 'M5 12.5 10 17l9-10',
  close: 'M6 6l12 12 M18 6 6 18',
  download: 'M12 3v12 M7 11l5 5 5-5 M4 20h16',
  plus: 'M12 5v14 M5 12h14',
  upload: 'M12 16V4 M7 9l5-5 5 5 M4 20h16',
  home: 'M4 11l8-7 8 7v9a1 1 0 0 1-1 1h-5v-6H10v6H5a1 1 0 0 1-1-1v-9Z',
  dashboard: 'M4 4h7v7H4V4Z M13 4h7v4h-7V4Z M13 10h7v10h-7V10Z M4 13h7v7H4v-7Z',
  queue: 'M4 6h16 M4 12h16 M4 18h10 M19 16l2 2-2 2',
  chart: 'M4 20V10 M10 20V4 M16 20v-7 M22 20H2',
  warning: 'M12 3 2.5 20h19L12 3Z M12 9v5 M12 17h.01',
  logout: 'M15 4h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-3 M10 8l-4 4 4 4 M6 12h9',
  menu: 'M4 7h16 M4 12h16 M4 17h16',
  book: 'M4 5a2 2 0 0 1 2-2h12v18H6a2 2 0 0 1-2-2V5Z M8 3v18',
  spark: 'M12 3v4 M12 17v4 M3 12h4 M17 12h4 M6.3 6.3l2.8 2.8 M14.9 14.9l2.8 2.8 M17.7 6.3l-2.8 2.8 M9.1 14.9l-2.8 2.8',
  save: 'M5 4h11l3 3v13H5V4Z M8 4v6h8V4 M8 15h8',
  trash: 'M4 7h16 M9 7V4h6v3 M6 7l1 13h10l1-13 M10 11v6 M14 11v6',
  image: 'M4 5h16v14H4V5Z M4 16l5-5 4 4 3-3 4 4 M15 9h.01',
  mail: 'M3 6h18v12H3V6Z M3 7l9 6 9-6',
  lock: 'M6 11h12v9H6v-9Z M9 11V8a3 3 0 0 1 6 0v3',
  filter: 'M4 6h16 M7 12h10 M10 18h4',
  clock: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z M12 7v5l3 2',
  flame: 'M12 21c4 0 6-2.6 6-6 0-4-3-5.5-3-9-2 1.5-3 3-3 5 0-2-1-3.5-2-4.5C8 9 6 11.5 6 15c0 3.4 2 6 6 6Z',
  globe: 'M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18Z M3 12h18 M12 3c2.5 2.4 3.8 5.4 3.8 9S14.5 18.6 12 21c-2.5-2.4-3.8-5.4-3.8-9S9.5 5.4 12 3Z',
}

const path = computed(() => paths[props.name] ?? paths.spark)
</script>

<template>
  <svg
    class="app-icon"
    :width="size"
    :height="size"
    viewBox="0 0 24 24"
    fill="none"
    :stroke-width="strokeWidth"
    stroke="currentColor"
    stroke-linecap="round"
    stroke-linejoin="round"
    aria-hidden="true"
  >
    <path :d="path" />
  </svg>
</template>

<style scoped lang="scss">
.app-icon {
  flex: none;
}
</style>
