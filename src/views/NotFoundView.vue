<script setup>
import AppIcon from '@/components/AppIcon.vue'
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--wiki not-found">
        <p class="not-found__code">404</p>
        <h1 class="page-title">Благодать привела не туда</h1>
        <p class="page-subtitle">
          Такой страницы нет в Междуземье. Возможно, ссылка устарела или запись была удалена.
        </p>
        <div class="not-found__actions">
          <RouterLink to="/" class="btn btn--primary">
            <AppIcon name="home" :size="17" />
            На главную
          </RouterLink>
          <RouterLink to="/wiki/weapon" class="btn btn--ghost">К каталогу оружия</RouterLink>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.not-found {
  max-width: 720px;
  margin: 0 auto;
  padding: 56px 44px;
  text-align: center;
}

.not-found__code {
  font-size: 72px;
  font-weight: 800;
  line-height: 1;
  letter-spacing: -0.04em;
  color: rgba(56, 57, 59, 0.18);
}

.not-found .page-title {
  margin-top: 14px;
}

.not-found .page-subtitle {
  margin-inline: auto;
}

.not-found__actions {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 28px;
}
</style>
