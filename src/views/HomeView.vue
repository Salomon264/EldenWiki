<script setup>
import { onMounted } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import ImagePlaceholder from '@/components/ImagePlaceholder.vue'
import { useWikiStore } from '@/stores/wiki'

const wiki = useWikiStore()

const cards = [
  {
    eyebrow: 'Мир',
    title: 'Места и локации',
    text: 'Изучайте регионы, руины, подземелья и ключевые точки на карте.',
    to: '/lore#epochs',
    icon: 'globe',
  },
  {
    eyebrow: 'Персонажи',
    title: 'Персонажи и НПС',
    text: 'Узнайте о лор-историях, диалогах и ролях ключевых персонажей.',
    to: '/lore#factions',
    icon: 'users',
  },
  {
    eyebrow: 'Геймплей',
    title: 'Механики и билды',
    text: 'Советы по билдам, прокачке и стратегиям прохождения.',
    to: '/mechanics',
    icon: 'flame',
  },
  {
    eyebrow: 'Лор',
    title: 'Лор и сюжет',
    text: 'Разберитесь в событиях, фракциях и ключевых поворотах истории.',
    to: '/lore',
    icon: 'book',
  },
  {
    eyebrow: 'Предметы',
    title: 'Снаряжение',
    text: 'Оружие, доспехи и полезные предметы для разных стилей игры.',
    to: '/wiki/weapon',
    icon: 'sword',
  },
  {
    eyebrow: 'Гайды',
    title: 'Гайды и советы',
    text: 'Пошаговые руководства для новичков и опытных игроков.',
    to: '/mechanics#builds',
    icon: 'spark',
  },
]

onMounted(() => wiki.loadArticles())
</script>

<template>
  <div class="page">
    <div class="container">
      <section class="page-panel page-panel--home home">
        <div class="home__hero">
          <div class="home__art">
            <ImagePlaceholder
              label="Арт Междуземья"
              icon="globe"
              ratio="tall"
              tone="dark"
            />
          </div>

          <div class="home__intro">
            <p class="eyebrow">Русскоязычная вики</p>
            <h1 class="home__title">
              Добро пожаловать на русскоязычную вики, посвященную игре Elden Ring от From
              Software
            </h1>

            <div class="home__quick">
              <RouterLink to="/community#admins">Администрация</RouterLink>
              <RouterLink to="/community">Свежие правки</RouterLink>
              <RouterLink to="/community#rules">Правила вики</RouterLink>
            </div>

            <RouterLink to="/build-helper" class="btn btn--gold home__cta">
              Помощник билдов
              <AppIcon name="spark" :size="18" />
            </RouterLink>
          </div>
        </div>

        <div class="home__section-head">
          <h2 class="section-title">Мир Elden Ring</h2>
          <p class="home__section-sub">
            Краткие материалы по миру, персонажам и геймплею Elden Ring
          </p>
        </div>

        <div class="home__grid">
          <RouterLink
            v-for="card in cards"
            :key="card.title"
            :to="card.to"
            class="home-card"
          >
            <p class="home-card__eyebrow">{{ card.eyebrow }}</p>
            <h3 class="home-card__title">{{ card.title }}</h3>
            <p class="home-card__text">{{ card.text }}</p>
            <span class="link-arrow home-card__link">
              Подробнее
              <AppIcon name="arrow-right" :size="15" />
            </span>
          </RouterLink>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped lang="scss">
.home {
  padding-top: 46px;
}

.home__hero {
  display: grid;
  grid-template-columns: 280px minmax(0, 1fr);
  gap: 46px;
  align-items: start;
}

.home__art {
  max-width: 280px;
}

.home__intro {
  padding-top: 93px;
}

.home__title {
  margin-top: 12px;
  max-width: 620px;
  font-size: clamp(24px, 2vw, 27px);
  line-height: 1.34;
  font-weight: 700;
  color: $ink-strong;
  letter-spacing: -0.02em;
}

.home__quick {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-top: 28px;

  a {
    color: $ink-soft;
    font-size: 14px;
    font-weight: 500;

    &:hover {
      color: $link;
    }
  }
}

.home__cta {
  margin-top: 26px;
}

.home__section-head {
  margin-top: 43px;
}

.home__section-sub {
  margin-top: 8px;
  color: $ink-soft;
  font-size: 14px;
}

.home__grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 24px;
  margin-top: 32px;
}

.home-card {
  display: flex;
  flex-direction: column;
  min-height: 222px;
  padding: 24px 24px 22px;
  border-radius: $card-radius;
  background: #fff;
  border: 1px solid rgba(255, 255, 255, 0.7);
  box-shadow: $shadow-card;
  color: $ink;
  transition:
    transform 0.22s $ease,
    box-shadow 0.22s $ease;

  &:hover {
    color: $ink;
    transform: translateY(-3px);
    box-shadow: 0 18px 36px rgba(24, 30, 52, 0.16);
  }
}

.home-card__eyebrow {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: $muted;
}

.home-card__title {
  margin-top: 12px;
  font-size: 20px;
  line-height: 1.25;
}

.home-card__text {
  margin-top: 10px;
  flex: 1;
  color: $ink-soft;
  font-size: 14px;
  line-height: 1.5;
}

.home-card__link {
  margin-top: 16px;
}

@include media-max(1000px) {
  .home__hero {
    grid-template-columns: 220px minmax(0, 1fr);
    gap: 30px;
  }

  .home__grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@include media-max(720px) {
  .home__hero {
    grid-template-columns: 1fr;
  }

  .home__art {
    max-width: 220px;
  }

  .home__grid {
    grid-template-columns: 1fr;
  }

  .home__quick {
    gap: 16px;
  }
}
</style>
