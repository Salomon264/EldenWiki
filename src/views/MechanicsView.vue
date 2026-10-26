<script setup>
import AppIcon from '@/components/AppIcon.vue'

const softCaps = [
  { stat: 'Vigor (здоровье)', caps: '40 / 60' },
  { stat: 'Mind (FP)', caps: '50 / 60' },
  { stat: 'Endurance (выносливость)', caps: '30 / 50' },
  { stat: 'Strength / Dexterity', caps: '60 / 80' },
  { stat: 'Intelligence / Faith', caps: '50 / 80' },
]

const combat = [
  {
    title: 'Guard Counter (Защитная контратака)',
    text: 'Блок → сразу сильная атака. Ломает стойку врага.',
  },
  {
    title: 'Jump Attack (Атака в прыжке)',
    text: 'Высокий урон по стойке, часто используется в силовых билдах.',
  },
  {
    title: 'Power Stance (Двуручный хват)',
    text: 'Одинаковое оружие в обеих руках даёт уникальный мувсет и высокий урон.',
  },
]

const builds = [
  {
    title: 'Силовой билд (Strength)',
    logic: 'Максимальный урон и ломка стойки тяжёлым оружием. Никакой магии, только физика.',
    stats: 'Vigor до 60, Endurance до 30–40, Strength до 60–80 (софткап).',
    gear: 'Тяжёлые мечи, молоты. Инфузия «Heavy» (Тяжёлая). Популярные атаки: прыжковые и заряженные.',
    talismans: 'Осколок Александра (усиливает атаки умений), Клешня (усиливает прыжковые атаки).',
  },
  {
    title: 'Кровоток (Bleed / Arcane)',
    logic: 'Быстрый набор кровотечения через серии ударов. Взрывной урон по HP.',
    stats: 'Arcane (Тайна) — 45–60 для накопления кровотечения, Dexterity — для скорости.',
    gear: 'Катаны, парные клинки, например Река Крови или Лунная вуаль.',
    talismans: 'Милость Лорда Крови (усиление после кровотечения).',
  },
  {
    title: '«Игрок с щитом» (Shield Poke)',
    logic: 'Безопасность. Держим блок и колем из-за щита.',
    stats: 'Много Endurance (50+), Strength для тяжёлых щитов (например, Каменный щит-отпечаток требует 48 силы).',
    gear: 'Копья (например, Крест-нагината) + тяжёлый щит.',
    talismans: 'Секрет: можно колоть, не убирая щит.',
  },
]
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--wiki mechanics">
        <header class="mechanics__head">
          <h1 class="page-title">Механики и билды</h1>
          <p class="page-subtitle">
            Междуземье некогда процветало под сенью великого Древа Эрд. Золотой Порядок,
            установленный королевой Марикой Вечной, даровал бессмертие и благодать всем, кто был
            верен Кольцу Элден. Но когда само Кольцо — источник порядка вещей — было разбито, мир
            погрузился в хаос бесконечной войны полубогов.
          </p>
        </header>

        <section class="mechanics__section">
          <h2 class="mechanics__h2">1. Система Soft Caps (мягких пределов)</h2>
          <p class="mechanics__text">
            Это фундамент любого билда. После определённых значений (например, 40 и 60 для
            выносливости и HP) каждая вложенная руна даёт всё меньше пользы. Без этого игроки
            сливают уровни в пустоту.
          </p>

          <table class="caps">
            <thead>
              <tr>
                <th>Характеристика</th>
                <th>Мягкие пределы</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in softCaps" :key="row.stat">
                <td>{{ row.stat }}</td>
                <td>{{ row.caps }}</td>
              </tr>
            </tbody>
          </table>
        </section>

        <section class="mechanics__section">
          <h2 class="mechanics__h2">2. Скейлинг и инфузии</h2>
          <p class="mechanics__text">
            Оружие имеет буквенные ранги (S–E), показывающие, насколько хорошо оно масштабируется
            от статов. Игрок должен знать, что «Тяжёлая» инфузия меняет скейлинг на силу, а
            «Острая» — на ловкость.
          </p>
        </section>

        <section class="mechanics__section">
          <h2 class="mechanics__h2">3. Боевые механики</h2>
          <ul class="mechanics__list">
            <li v-for="entry in combat" :key="entry.title">
              <strong>{{ entry.title }}:</strong> {{ entry.text }}
            </li>
          </ul>
        </section>

        <section id="builds" class="mechanics__section">
          <h2 class="mechanics__section-title">Билды: структура и примеры</h2>

          <article v-for="build in builds" :key="build.title" class="build-example">
            <h3 class="build-example__title">Пример: {{ build.title }}</h3>
            <ul class="mechanics__list mechanics__list--tight">
              <li><strong>Логика:</strong> {{ build.logic }}</li>
              <li><strong>Статы:</strong> {{ build.stats }}</li>
              <li><strong>Оружие:</strong> {{ build.gear }}</li>
              <li><strong>Ключевые талисманы:</strong> {{ build.talismans }}</li>
            </ul>
          </article>
        </section>

        <aside class="mechanics__cta">
          <div>
            <h2 class="mechanics__cta-title">Соберите билд под свои характеристики</h2>
            <p class="mechanics__cta-text">
              Помощник билдов подберёт оружие по вашим статам и сохранит конфигурацию в файл.
            </p>
          </div>
          <RouterLink to="/build-helper" class="btn btn--gold">
            Открыть помощник
            <AppIcon name="spark" :size="17" />
          </RouterLink>
        </aside>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.mechanics {
  padding-top: 34px;
}

.mechanics__head {
  max-width: 900px;
}

.mechanics__section {
  margin-top: 34px;
}

.mechanics__h2 {
  font-size: 19px;
  line-height: 1.35;
}

.mechanics__section-title {
  font-size: 24px;
  line-height: 1.3;
}

.mechanics__text {
  margin-top: 10px;
  max-width: 900px;
  color: $ink-soft;
  font-size: 15px;
  line-height: 1.68;
}

.mechanics__list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 12px;
  padding-left: 18px;
  color: $ink-soft;
  font-size: 14.5px;
  line-height: 1.62;

  li::marker {
    color: rgba(56, 57, 59, 0.45);
  }

  strong {
    color: $ink-strong;
    font-weight: 600;
  }
}

.mechanics__list--tight {
  margin-top: 10px;
}

.caps {
  width: 100%;
  max-width: 620px;
  margin-top: 16px;
  border-collapse: collapse;
  font-size: 14px;

  th,
  td {
    padding: 10px 14px;
    text-align: left;
  }

  thead th {
    background: rgba(56, 57, 59, 0.07);
    color: $ink-soft;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.04em;
    text-transform: uppercase;
  }

  thead th:first-child {
    border-radius: 8px 0 0 8px;
  }

  thead th:last-child {
    border-radius: 0 8px 8px 0;
  }

  tbody tr:nth-child(odd) td {
    background: rgba(255, 255, 255, 0.6);
  }

  td:last-child {
    font-weight: 600;
  }
}

.build-example {
  margin-top: 22px;
  padding: 20px 22px;
  border-radius: 12px;
  background: rgba(246, 247, 249, 0.9);
  box-shadow: $shadow-card;
}

.build-example__title {
  font-size: 17px;
}

.mechanics__cta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 26px;
  margin-top: 40px;
  padding: 26px 30px;
  border-radius: 16px;
  background: rgba(24, 30, 52, 0.06);
  border: 1px solid rgba(56, 57, 59, 0.1);
}

.mechanics__cta-title {
  font-size: 20px;
}

.mechanics__cta-text {
  margin-top: 6px;
  color: $ink-soft;
  font-size: 14px;
}

@include media-max(760px) {
  .mechanics__cta {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
