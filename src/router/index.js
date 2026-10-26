import { createRouter, createWebHistory } from 'vue-router'
import { CATEGORY_BY_KEY } from '@/data/categories'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/HomeView.vue'),
    meta: { title: 'Вики по Elden Ring' },
  },
  {
    path: '/wiki/:category',
    name: 'category',
    component: () => import('@/views/CategoryView.vue'),
    props: true,
    meta: { title: 'Каталог' },
    beforeEnter: (to) => (CATEGORY_BY_KEY[to.params.category] ? true : { name: 'not-found' }),
  },
  {
    path: '/wiki/:category/:id',
    name: 'article',
    component: () => import('@/views/ArticleView.vue'),
    props: true,
    meta: { title: 'Карточка предмета' },
    beforeEnter: (to) => (CATEGORY_BY_KEY[to.params.category] ? true : { name: 'not-found' }),
  },
  {
    path: '/lore',
    name: 'lore',
    component: () => import('@/views/LoreView.vue'),
    meta: { title: 'Лор и сюжет' },
  },
  {
    path: '/mechanics',
    name: 'mechanics',
    component: () => import('@/views/MechanicsView.vue'),
    meta: { title: 'Механики и билды' },
  },
  {
    path: '/build-helper',
    name: 'build-helper',
    component: () => import('@/views/BuildHelperView.vue'),
    meta: { title: 'Помощник билдов' },
  },
  {
    path: '/community',
    name: 'community',
    component: () => import('@/views/CommunityView.vue'),
    meta: { title: 'Сообщество' },
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/LoginView.vue'),
    meta: { title: 'Вход в аккаунт', guestOnly: true },
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('@/views/RegisterView.vue'),
    meta: { title: 'Регистрация', guestOnly: true },
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('@/views/ProfileView.vue'),
    meta: { title: 'Профиль', requiresAuth: true },
  },
  {
    path: '/profile/edit',
    name: 'profile-edit',
    component: () => import('@/views/ProfileEditView.vue'),
    meta: { title: 'Редактирование профиля', requiresAuth: true },
  },
  {
    path: '/admin',
    name: 'admin-dashboard',
    component: () => import('@/views/admin/AdminDashboardView.vue'),
    meta: { title: 'Панель управления', requiresAuth: true, minRole: 2 },
  },
  {
    path: '/admin/employees',
    name: 'admin-employees',
    component: () => import('@/views/admin/AdminEmployeesView.vue'),
    meta: { title: 'Сотрудники', requiresAuth: true, minRole: 3 },
  },
  {
    path: '/admin/moderation',
    name: 'admin-moderation',
    component: () => import('@/views/admin/AdminModerationView.vue'),
    meta: { title: 'Проверка статей', requiresAuth: true, minRole: 2 },
  },
  {
    path: '/admin/items/new',
    name: 'admin-item-create',
    component: () => import('@/views/admin/AdminItemCreateView.vue'),
    meta: { title: 'Создание записи', requiresAuth: true, minRole: 2 },
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: () => import('@/views/NotFoundView.vue'),
    meta: { title: 'Страница не найдена' },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) return savedPosition
    if (to.hash) return { el: to.hash, top: 110, behavior: 'smooth' }
    return { top: 0 }
  },
})

router.beforeEach((to) => {
  const auth = useAuthStore()

  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guestOnly && auth.isAuthenticated) {
    return { name: 'profile' }
  }

  if (to.meta.minRole && auth.roleId < to.meta.minRole) {
    return { name: 'home' }
  }

  return true
})

router.afterEach((to) => {
  const base = 'EldenWiki'
  document.title = to.meta.title ? `${to.meta.title} — ${base}` : base
})

export default router
