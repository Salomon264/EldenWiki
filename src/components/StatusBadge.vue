<script setup>
defineProps({
  label: { type: String, required: true },
  tone: { type: String, default: 'neutral' },
})
</script>

<template>
  <span class="badge" :class="`badge--${tone}`">{{ label }}</span>
</template>

<style scoped lang="scss">
.badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
  line-height: 1.4;
  white-space: nowrap;
}

.badge--success {
  background: $green-soft;
  color: $green-ink;
}

.badge--warning {
  background: $amber-soft;
  color: $amber-ink;
}

.badge--danger {
  background: $red-soft;
  color: $red-ink;
}

.badge--info {
  background: rgba(17, 108, 216, 0.12);
  color: $link;
}

.badge--neutral {
  background: rgba(56, 57, 59, 0.08);
  color: $ink-soft;
}
</style>
