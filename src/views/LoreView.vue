<script setup>
import AppIcon from '@/components/AppIcon.vue'

const epochs = [
  {
    era: 'Эра Древа Эрд',
    sub: 'До Раскола',
    title: 'Золотой Век и Восхождение Марики',
    text: 'Период величайшего расцвета веры. Марика сокрушает великанов и старых богов, запечатывает Руну Смерти и основывает вечную династию под золотым светом Древа.',
  },
  {
    era: 'Ночь Чёрных Ножей',
    sub: 'Зарождение хаоса',
    title: 'Убийство Годвина Золотого',
    text: 'Таинственные ассасины похищают осколок Руны Смерти и убивают первенца Марики. Годвин становится первым из мертвых, запуская цепь событий, разрушивших веру королевы.',
  },
  {
    era: 'Эпоха Раскола',
    sub: 'Великая Война',
    title: 'Битва Полубогов за Великие Руны',
    text: 'Осколки разбитого Кольца Элден попадают в руки детей Марики. Полубоги, безумные от обретённой мощи, развязывают войну, в которой не будет победителей.',
  },
  {
    era: 'Время Погасших',
    sub: 'Настоящие дни',
    title: 'Возвращение лишенных благодати',
    text: 'Древо Эрд призывает изгнанников прошлого. Лишенные золотого дара воины восстают из могил, чтобы занять опустевший трон в полуразрушенном мире.',
  },
]

const factions = [
  {
    eyebrow: 'Фракции',
    title: 'Золотой Порядок',
    text: 'Церковь Древа Эрд и фундаменталисты, стремящиеся сохранить нерушимые законы королевства.',
  },
  {
    eyebrow: 'Полубоги',
    title: 'Погасшие герои',
    text: 'Те, от кого отвернулось благоволение золота, но кто теперь призван вновь вершить судьбы королевств Междуземья.',
  },
  {
    eyebrow: 'Тайны',
    title: 'Великая Воля',
    text: 'Внешнее Божество, диктующее свою волю через Золотую Звезду, Двух Пальцев и верных им слуг.',
  },
]
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--wiki lore">
        <header class="lore__head">
          <h1 class="page-title">Лор и сюжет Междуземья</h1>
          <p class="page-subtitle">
            История Золотого Порядка, увядания Древа Эрд и великой войны полубогов
          </p>
        </header>

        <div class="lore__intro">
          <p>
            Междуземье некогда процветало под сенью великого Древа Эрд. Золотой Порядок,
            установленный королевой Марикой Вечной, даровал бессмертие и благодать всем, кто был
            верен Кольцу Элден. Но когда само Кольцо — источник порядка вещей — было разбито, мир
            погрузился в хаос бесконечной войны полубогов.
          </p>
          <p>
            Вы — Погасший, ведомый утраченной благодатью. Ваша цель — бросить вызов полубогам,
            собрать осколки Кольца и стать новым Владыкой Элден.
          </p>
        </div>

        <section id="epochs" class="lore__section">
          <h2 class="section-title">Эпохи Междуземья</h2>

          <ol class="timeline">
            <li v-for="epoch in epochs" :key="epoch.title" class="timeline__row">
              <div class="timeline__era">
                <span class="timeline__era-title">{{ epoch.era }}</span>
                <span class="timeline__era-sub">{{ epoch.sub }}</span>
              </div>
              <span class="timeline__dot" aria-hidden="true" />
              <div class="timeline__body">
                <h3 class="timeline__title">{{ epoch.title }}</h3>
                <p class="timeline__text">{{ epoch.text }}</p>
              </div>
            </li>
          </ol>
        </section>

        <section id="factions" class="lore__section">
          <h2 class="section-title">Ключевые силы и фракции</h2>

          <div class="lore__cards">
            <article v-for="faction in factions" :key="faction.title" class="faction-card">
              <p class="faction-card__eyebrow">{{ faction.eyebrow }}</p>
              <h3 class="faction-card__title">{{ faction.title }}</h3>
              <p class="faction-card__text">{{ faction.text }}</p>
              <RouterLink to="/community" class="link-arrow">
                Читать хроники
                <AppIcon name="arrow-right" :size="15" />
              </RouterLink>
            </article>
          </div>
        </section>

        <aside class="lore__cta">
          <div class="lore__cta-body">
            <h2 class="lore__cta-title">Интерактивный помощник по сюжетам</h2>
            <p class="lore__cta-text">
              Хотите подробнее разобрать квесты Рэнни, историю проклятия Малении или тайны Золотой
              Маски? Присоединяйтесь к разборам нашего сообщества.
            </p>
            <RouterLink to="/community" class="btn btn--gold">
              Перейти в раздел теорий
              <AppIcon name="arrow-right" :size="17" />
            </RouterLink>
          </div>
        </aside>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.lore {
  padding-top: 34px;
}

.lore__head {
  max-width: 760px;
}

.lore__intro {
  display: flex;
  flex-direction: column;
  gap: 14px;
  max-width: 700px;
  margin: 28px auto 0;
  color: $ink-soft;
  font-size: 15.5px;
  line-height: 1.72;
}

.lore__section {
  margin-top: 44px;
}

.timeline {
  position: relative;
  margin-top: 22px;
  padding-left: 170px;
  list-style: none;

  &::before {
    content: '';
    position: absolute;
    left: 156px;
    top: 12px;
    bottom: 12px;
    width: 1px;
    background: rgba(56, 57, 59, 0.18);
  }
}

.timeline__row {
  position: relative;
  display: grid;
  grid-template-columns: 1fr;
  gap: 0;
  padding: 14px 0 22px;
}

.timeline__era {
  position: absolute;
  left: -170px;
  top: 14px;
  display: flex;
  flex-direction: column;
  gap: 2px;
  width: 138px;
  text-align: left;
}

.timeline__era-title {
  font-size: 13px;
  font-weight: 600;
  color: $ink-strong;
}

.timeline__era-sub {
  font-size: 11.5px;
  color: $muted;
}

.timeline__dot {
  position: absolute;
  left: -20px;
  top: 20px;
  width: 9px;
  height: 9px;
  border-radius: 50%;
  background: $ink-soft;
  box-shadow: 0 0 0 4px rgba(56, 57, 59, 0.08);
}

.timeline__title {
  font-size: 16px;
  font-weight: 700;
}

.timeline__text {
  margin-top: 7px;
  max-width: 760px;
  color: $ink-soft;
  font-size: 14.5px;
  line-height: 1.65;
}

.lore__cards {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 22px;
  margin-top: 22px;
}

.faction-card {
  display: flex;
  flex-direction: column;
  min-height: 250px;
  padding: 24px;
  border-radius: $card-radius;
  background: $paper;
  box-shadow: $shadow-card;
}

.faction-card__eyebrow {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: $muted;
}

.faction-card__title {
  margin-top: 12px;
  font-size: 19px;
}

.faction-card__text {
  flex: 1;
  margin-top: 10px;
  color: $ink-soft;
  font-size: 13.5px;
  line-height: 1.6;
}

.faction-card .link-arrow {
  margin-top: 16px;
}

.lore__cta {
  margin-top: 44px;
  padding: 34px 38px;
  border-radius: 16px;
  background:
    radial-gradient(120% 140% at 12% 0%, rgba(255, 255, 255, 0.28), transparent 60%),
    linear-gradient(120deg, #d8a24c 0%, #c98f2f 60%, #bb8126 100%);
  color: #fff;
  box-shadow: 0 20px 40px rgba(155, 105, 26, 0.3);
}

.lore__cta-body {
  max-width: 640px;
}

.lore__cta-title {
  color: #fff;
  font-size: 26px;
  line-height: 1.25;
}

.lore__cta-text {
  margin-top: 12px;
  color: rgba(255, 255, 255, 0.92);
  font-size: 14.5px;
  line-height: 1.6;
}

.lore__cta .btn {
  margin-top: 22px;
  background: #fff;
  color: $ink-strong;

  &:hover {
    background: #fff;
    color: $ink-strong;
  }
}

@include media-max(900px) {
  .timeline {
    padding-left: 28px;

    &::before {
      left: 6px;
    }
  }

  .timeline__era {
    position: static;
    width: auto;
    margin-bottom: 6px;
  }

  .timeline__dot {
    left: -26px;
    top: 6px;
  }

  .lore__cards {
    grid-template-columns: 1fr;
  }
}
</style>
