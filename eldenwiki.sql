-- =====================================================================
--  EldenWiki — база данных (MySQL 8.0.16+ / MariaDB 10.4+)
--  Импорт: mysql -u root -p < eldenwiki.sql   (или через phpMyAdmin → Импорт)
-- =====================================================================

DROP DATABASE IF EXISTS eldenwiki;
CREATE DATABASE eldenwiki CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eldenwiki;

-- =====================================================================
-- 1. ПОЛЬЗОВАТЕЛИ И РОЛИ
--    Игрок, модератор и администратор имеют одинаковые поля
--    (id, логин, пароль), поэтому хранятся в одной таблице с ролью.
--    Гость — незарегистрированный посетитель, в БД не хранится.
-- =====================================================================
CREATE TABLE roles (
    id   TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL UNIQUE          -- player / moderator / admin
) ENGINE=InnoDB;

CREATE TABLE users (
    id            INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    login         VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,       -- хранить хэш (bcrypt/argon2), не пароль
    role_id       TINYINT UNSIGNED NOT NULL DEFAULT 1,
    is_blocked    TINYINT(1)   NOT NULL DEFAULT 0,  -- блокировка учётной записи администратором
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. СПРАВОЧНИКИ (ведёт администратор)
-- =====================================================================
CREATE TABLE weapon_types   (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- вид оружия
CREATE TABLE damage_types   (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- тип повреждений
CREATE TABLE skills         (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- навыки
CREATE TABLE acquisitions   (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(255) NOT NULL) ENGINE=InnoDB;         -- способ получения
CREATE TABLE shield_types   (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- вид щита
CREATE TABLE talisman_types (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- вид талисмана
CREATE TABLE magic_types    (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- вид магии (чары / молитвы)
CREATE TABLE material_types (id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- вид материала
CREATE TABLE character_types(id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100) NOT NULL UNIQUE) ENGINE=InnoDB; -- вид персонажа

-- =====================================================================
-- 3. ОРУЖИЕ
-- =====================================================================
CREATE TABLE weapons (
    id             INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(150) NOT NULL UNIQUE,
    weapon_type_id INT UNSIGNED NOT NULL,
    damage_type_id INT UNSIGNED NOT NULL,
    skill_id       INT UNSIGNED NULL,
    weight         DECIMAL(5,1) NOT NULL DEFAULT 0,
    acquisition_id INT UNSIGNED NULL,
    CONSTRAINT chk_weapons_weight CHECK (weight >= 0),
    CONSTRAINT fk_weapons_type  FOREIGN KEY (weapon_type_id) REFERENCES weapon_types(id),
    CONSTRAINT fk_weapons_dmg   FOREIGN KEY (damage_type_id) REFERENCES damage_types(id),
    CONSTRAINT fk_weapons_skill FOREIGN KEY (skill_id)       REFERENCES skills(id),
    CONSTRAINT fk_weapons_acq   FOREIGN KEY (acquisition_id) REFERENCES acquisitions(id)
) ENGINE=InnoDB;

-- Характеристики: сила, ловкость, мудрость (интеллект), вера, колдовство (тайна)
CREATE TABLE weapon_requirements (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    weapon_id    INT UNSIGNED NOT NULL UNIQUE,
    strength     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    dexterity    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    intelligence SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    faith        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    arcane       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_wreq_weapon FOREIGN KEY (weapon_id) REFERENCES weapons(id)
) ENGINE=InnoDB;

CREATE TABLE weapon_bonuses (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    weapon_id    INT UNSIGNED NOT NULL UNIQUE,
    strength     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    dexterity    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    intelligence SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    faith        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    arcane       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_wbon_weapon FOREIGN KEY (weapon_id) REFERENCES weapons(id)
) ENGINE=InnoDB;

CREATE TABLE weapon_attack (
    id        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    weapon_id INT UNSIGNED NOT NULL UNIQUE,
    physical  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    magic     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    fire      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    lightning SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    holy      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    critical  SMALLINT UNSIGNED NOT NULL DEFAULT 100,
    CONSTRAINT fk_watk_weapon FOREIGN KEY (weapon_id) REFERENCES weapons(id)
) ENGINE=InnoDB;

CREATE TABLE weapon_defense (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    weapon_id   INT UNSIGNED NOT NULL UNIQUE,
    physical    DECIMAL(5,1) NOT NULL DEFAULT 0,
    magic       DECIMAL(5,1) NOT NULL DEFAULT 0,
    fire        DECIMAL(5,1) NOT NULL DEFAULT 0,
    lightning   DECIMAL(5,1) NOT NULL DEFAULT 0,
    holy        DECIMAL(5,1) NOT NULL DEFAULT 0,
    guard_boost SMALLINT UNSIGNED NOT NULL DEFAULT 0,       -- усиление блока
    CONSTRAINT chk_wdef CHECK (physical>=0 AND magic>=0 AND fire>=0 AND lightning>=0 AND holy>=0),
    CONSTRAINT fk_wdef_weapon FOREIGN KEY (weapon_id) REFERENCES weapons(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. БРОНЯ
-- =====================================================================
CREATE TABLE armor_sets (
    id             INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(150) NOT NULL UNIQUE,            -- название комплекта
    weight         DECIMAL(5,1) NOT NULL DEFAULT 0,
    acquisition_id INT UNSIGNED NULL,
    CONSTRAINT chk_armor_weight CHECK (weight >= 0),
    CONSTRAINT fk_armor_acq FOREIGN KEY (acquisition_id) REFERENCES acquisitions(id)
) ENGINE=InnoDB;

CREATE TABLE armor_defense (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    armor_set_id INT UNSIGNED NOT NULL UNIQUE,
    physical     DECIMAL(5,1) NOT NULL DEFAULT 0,   -- физическая защита
    strike       DECIMAL(5,1) NOT NULL DEFAULT 0,   -- от дробящего
    slash        DECIMAL(5,1) NOT NULL DEFAULT 0,   -- от рубящего
    pierce       DECIMAL(5,1) NOT NULL DEFAULT 0,   -- от колющего
    magic        DECIMAL(5,1) NOT NULL DEFAULT 0,
    fire         DECIMAL(5,1) NOT NULL DEFAULT 0,
    lightning    DECIMAL(5,1) NOT NULL DEFAULT 0,
    holy         DECIMAL(5,1) NOT NULL DEFAULT 0,
    CONSTRAINT chk_adef CHECK (physical>=0 AND strike>=0 AND slash>=0 AND pierce>=0
                               AND magic>=0 AND fire>=0 AND lightning>=0 AND holy>=0),
    CONSTRAINT fk_adef_set FOREIGN KEY (armor_set_id) REFERENCES armor_sets(id)
) ENGINE=InnoDB;

CREATE TABLE armor_resistance (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    armor_set_id INT UNSIGNED NOT NULL UNIQUE,
    immunity     SMALLINT UNSIGNED NOT NULL DEFAULT 0,  -- иммунитет
    robustness   SMALLINT UNSIGNED NOT NULL DEFAULT 0,  -- живучесть
    focus        SMALLINT UNSIGNED NOT NULL DEFAULT 0,  -- концентрация
    vitality     SMALLINT UNSIGNED NOT NULL DEFAULT 0,  -- физическая мощь
    poise        SMALLINT UNSIGNED NOT NULL DEFAULT 0,  -- баланс
    CONSTRAINT fk_ares_set FOREIGN KEY (armor_set_id) REFERENCES armor_sets(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 5. ЩИТЫ
-- =====================================================================
CREATE TABLE shields (
    id              INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name            VARCHAR(150) NOT NULL UNIQUE,
    shield_type_id  INT UNSIGNED NOT NULL,
    skill_id        INT UNSIGNED NULL,
    damage_type_id  INT UNSIGNED NOT NULL,
    weight          DECIMAL(5,1) NOT NULL DEFAULT 0,
    acquisition_id  INT UNSIGNED NULL,
    CONSTRAINT chk_shields_weight CHECK (weight >= 0),
    CONSTRAINT fk_shields_type  FOREIGN KEY (shield_type_id) REFERENCES shield_types(id),
    CONSTRAINT fk_shields_skill FOREIGN KEY (skill_id)       REFERENCES skills(id),
    CONSTRAINT fk_shields_dmg   FOREIGN KEY (damage_type_id) REFERENCES damage_types(id),
    CONSTRAINT fk_shields_acq   FOREIGN KEY (acquisition_id) REFERENCES acquisitions(id)
) ENGINE=InnoDB;

CREATE TABLE shield_requirements (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    shield_id    INT UNSIGNED NOT NULL UNIQUE,
    strength     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    dexterity    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    intelligence SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    faith        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    arcane       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_sreq_shield FOREIGN KEY (shield_id) REFERENCES shields(id)
) ENGINE=InnoDB;

CREATE TABLE shield_bonuses (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    shield_id    INT UNSIGNED NOT NULL UNIQUE,
    strength     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    dexterity    SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    intelligence SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    faith        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    arcane       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_sbon_shield FOREIGN KEY (shield_id) REFERENCES shields(id)
) ENGINE=InnoDB;

CREATE TABLE shield_attack (
    id        INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    shield_id INT UNSIGNED NOT NULL UNIQUE,
    physical  SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    magic     SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    fire      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    lightning SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    holy      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    critical  SMALLINT UNSIGNED NOT NULL DEFAULT 100,
    CONSTRAINT fk_satk_shield FOREIGN KEY (shield_id) REFERENCES shields(id)
) ENGINE=InnoDB;

CREATE TABLE shield_defense (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    shield_id   INT UNSIGNED NOT NULL UNIQUE,
    physical    DECIMAL(5,1) NOT NULL DEFAULT 0,
    magic       DECIMAL(5,1) NOT NULL DEFAULT 0,
    fire        DECIMAL(5,1) NOT NULL DEFAULT 0,
    lightning   DECIMAL(5,1) NOT NULL DEFAULT 0,
    holy        DECIMAL(5,1) NOT NULL DEFAULT 0,
    guard_boost SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT chk_sdef CHECK (physical>=0 AND magic>=0 AND fire>=0 AND lightning>=0 AND holy>=0),
    CONSTRAINT fk_sdef_shield FOREIGN KEY (shield_id) REFERENCES shields(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 6. ТАЛИСМАНЫ
-- =====================================================================
CREATE TABLE talismans (
    id               INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name             VARCHAR(150) NOT NULL UNIQUE,
    effect           TEXT NOT NULL,
    weight           DECIMAL(5,1) NOT NULL DEFAULT 0,
    talisman_type_id INT UNSIGNED NOT NULL,
    acquisition_id   INT UNSIGNED NULL,
    CONSTRAINT chk_tal_weight CHECK (weight >= 0),
    CONSTRAINT fk_tal_type FOREIGN KEY (talisman_type_id) REFERENCES talisman_types(id),
    CONSTRAINT fk_tal_acq  FOREIGN KEY (acquisition_id)   REFERENCES acquisitions(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 7. МАГИЯ (чары и молитвы — в одной таблице, различаются видом магии)
-- =====================================================================
CREATE TABLE spells (
    id             INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(150) NOT NULL UNIQUE,
    effect         TEXT NOT NULL,
    magic_type_id  INT UNSIGNED NOT NULL,
    acquisition_id INT UNSIGNED NULL,
    CONSTRAINT fk_spells_type FOREIGN KEY (magic_type_id)  REFERENCES magic_types(id),
    CONSTRAINT fk_spells_acq  FOREIGN KEY (acquisition_id) REFERENCES acquisitions(id)
) ENGINE=InnoDB;

CREATE TABLE spell_parameters (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    spell_id     INT UNSIGNED NOT NULL UNIQUE,
    fp_cost      SMALLINT UNSIGNED NOT NULL DEFAULT 0,   -- расход маны (FP)
    stamina_cost SMALLINT UNSIGNED NOT NULL DEFAULT 0,   -- расход выносливости
    slots        TINYINT UNSIGNED  NOT NULL DEFAULT 1,   -- занимаемые слоты памяти
    CONSTRAINT fk_sparam_spell FOREIGN KEY (spell_id) REFERENCES spells(id)
) ENGINE=InnoDB;

CREATE TABLE spell_requirements (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    spell_id     INT UNSIGNED NOT NULL UNIQUE,
    intelligence SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    faith        SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    arcane       SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    CONSTRAINT fk_sreqs_spell FOREIGN KEY (spell_id) REFERENCES spells(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 8. МИР ИГРЫ: регионы, локации, персонажи, враги
-- =====================================================================
CREATE TABLE regions (
    id   INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE locations (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    description TEXT NULL,
    region_id   INT UNSIGNED NOT NULL,
    UNIQUE KEY uq_location (region_id, name),
    CONSTRAINT fk_loc_region FOREIGN KEY (region_id) REFERENCES regions(id)
) ENGINE=InnoDB;

CREATE TABLE characters (
    id                INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name              VARCHAR(150) NOT NULL UNIQUE,
    character_type_id INT UNSIGNED NOT NULL,
    location_id       INT UNSIGNED NULL,                 -- где обитает
    description       TEXT NULL,
    CONSTRAINT fk_char_type FOREIGN KEY (character_type_id) REFERENCES character_types(id),
    CONSTRAINT fk_char_loc  FOREIGN KEY (location_id)       REFERENCES locations(id)
) ENGINE=InnoDB;

CREATE TABLE bosses (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL UNIQUE,
    location_id INT UNSIGNED NOT NULL,
    tactics     TEXT NULL,                               -- тактика прохождения
    CONSTRAINT fk_boss_loc FOREIGN KEY (location_id) REFERENCES locations(id)
) ENGINE=InnoDB;

CREATE TABLE unique_enemies (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL UNIQUE,
    location_id INT UNSIGNED NOT NULL,
    CONSTRAINT fk_uenemy_loc FOREIGN KEY (location_id) REFERENCES locations(id)
) ENGINE=InnoDB;

CREATE TABLE regular_enemies (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    region_id   INT UNSIGNED NOT NULL,
    description TEXT NULL,
    UNIQUE KEY uq_renemy (region_id, name),
    CONSTRAINT fk_renemy_region FOREIGN KEY (region_id) REFERENCES regions(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 9. МАТЕРИАЛЫ, ХАРАКТЕРИСТИКИ, ОБУЧЕНИЕ
-- =====================================================================
CREATE TABLE materials (
    id               INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name             VARCHAR(150) NOT NULL UNIQUE,
    material_type_id INT UNSIGNED NOT NULL,
    effect           TEXT NULL,
    CONSTRAINT fk_mat_type FOREIGN KEY (material_type_id) REFERENCES material_types(id)
) ENGINE=InnoDB;

CREATE TABLE attributes (                                -- характеристики предметов
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE tutorials (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL UNIQUE,
    description TEXT NULL
) ENGINE=InnoDB;

CREATE TABLE mechanics (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    tutorial_id INT UNSIGNED NOT NULL,
    name        VARCHAR(150) NOT NULL,
    description TEXT NULL,
    CONSTRAINT fk_mech_tutorial FOREIGN KEY (tutorial_id) REFERENCES tutorials(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 10. ДРОП ПРОТИВНИКОВ
--     Одна строка = «источник (босс / уникальный враг / рядовой враг)
--     роняет предмет (оружие / щит / броню / талисман / заклинание / материал)».
--     Ровно один источник и ровно один предмет (CHECK).
-- =====================================================================
CREATE TABLE drops (
    id               INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    boss_id          INT UNSIGNED NULL,
    unique_enemy_id  INT UNSIGNED NULL,
    regular_enemy_id INT UNSIGNED NULL,
    weapon_id        INT UNSIGNED NULL,
    shield_id        INT UNSIGNED NULL,
    armor_set_id     INT UNSIGNED NULL,
    talisman_id      INT UNSIGNED NULL,
    spell_id         INT UNSIGNED NULL,
    material_id      INT UNSIGNED NULL,
    CONSTRAINT chk_drop_source CHECK (
        (boss_id IS NOT NULL) + (unique_enemy_id IS NOT NULL) + (regular_enemy_id IS NOT NULL) = 1),
    CONSTRAINT chk_drop_item CHECK (
        (weapon_id IS NOT NULL) + (shield_id IS NOT NULL) + (armor_set_id IS NOT NULL)
        + (talisman_id IS NOT NULL) + (spell_id IS NOT NULL) + (material_id IS NOT NULL) = 1),
    CONSTRAINT fk_drop_boss    FOREIGN KEY (boss_id)          REFERENCES bosses(id),
    CONSTRAINT fk_drop_uenemy  FOREIGN KEY (unique_enemy_id)  REFERENCES unique_enemies(id),
    CONSTRAINT fk_drop_renemy  FOREIGN KEY (regular_enemy_id) REFERENCES regular_enemies(id),
    CONSTRAINT fk_drop_weapon  FOREIGN KEY (weapon_id)        REFERENCES weapons(id),
    CONSTRAINT fk_drop_shield  FOREIGN KEY (shield_id)        REFERENCES shields(id),
    CONSTRAINT fk_drop_armor   FOREIGN KEY (armor_set_id)     REFERENCES armor_sets(id),
    CONSTRAINT fk_drop_talis   FOREIGN KEY (talisman_id)      REFERENCES talismans(id),
    CONSTRAINT fk_drop_spell   FOREIGN KEY (spell_id)         REFERENCES spells(id),
    CONSTRAINT fk_drop_mat     FOREIGN KEY (material_id)      REFERENCES materials(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 11. КОНСТРУКТОР БИЛДОВ (сохранённые конфигурации игроков)
-- =====================================================================
CREATE TABLE builds (
    id           INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    user_id      INT UNSIGNED NOT NULL,
    name         VARCHAR(150) NOT NULL,
    strength     SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    dexterity    SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    intelligence SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    faith        SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    arcane       SMALLINT UNSIGNED NOT NULL DEFAULT 10,
    weapon_id    INT UNSIGNED NULL,
    shield_id    INT UNSIGNED NULL,
    armor_set_id INT UNSIGNED NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_build_user   FOREIGN KEY (user_id)      REFERENCES users(id),
    CONSTRAINT fk_build_weapon FOREIGN KEY (weapon_id)    REFERENCES weapons(id),
    CONSTRAINT fk_build_shield FOREIGN KEY (shield_id)    REFERENCES shields(id),
    CONSTRAINT fk_build_armor  FOREIGN KEY (armor_set_id) REFERENCES armor_sets(id)
) ENGINE=InnoDB;

CREATE TABLE build_talismans (
    build_id    INT UNSIGNED NOT NULL,
    talisman_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (build_id, talisman_id),
    CONSTRAINT fk_bt_build FOREIGN KEY (build_id)    REFERENCES builds(id) ON DELETE CASCADE,
    CONSTRAINT fk_bt_tal   FOREIGN KEY (talisman_id) REFERENCES talismans(id)
) ENGINE=InnoDB;

CREATE TABLE build_spells (
    build_id INT UNSIGNED NOT NULL,
    spell_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (build_id, spell_id),
    CONSTRAINT fk_bs_build FOREIGN KEY (build_id) REFERENCES builds(id) ON DELETE CASCADE,
    CONSTRAINT fk_bs_spell FOREIGN KEY (spell_id) REFERENCES spells(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 12. КАТЕГОРИИ И СТАТЬИ ВИКИ (контент сайта, используется REST API)
--     Гость и игрок читают каталог; модератор правит статьи;
--     администратор добавляет/удаляет статьи и ведёт категории.
-- =====================================================================
CREATE TABLE categories (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL UNIQUE,
    slug        VARCHAR(150) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE articles (
    id          INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    category_id INT UNSIGNED NOT NULL,
    author_id   INT UNSIGNED NULL,
    title       VARCHAR(255) NOT NULL,
    summary     VARCHAR(500) NULL,
    content     TEXT NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_article_title (category_id, title),
    CONSTRAINT fk_articles_category FOREIGN KEY (category_id) REFERENCES categories(id),
    CONSTRAINT fk_articles_author   FOREIGN KEY (author_id)   REFERENCES users(id)
) ENGINE=InnoDB;

-- =====================================================================
-- 13. ПРЕДСТАВЛЕНИЯ ДЛЯ ОТЧЁТОВ (п. 1.2 постановки задачи)
-- =====================================================================

-- Каталог оружия с типом повреждений, требованиями и атакой
-- Пример: SELECT * FROM v_weapon_catalog WHERE damage_type = 'Огненный';
CREATE VIEW v_weapon_catalog AS
SELECT w.id, w.name, wt.name AS weapon_type, dt.name AS damage_type, s.name AS skill, w.weight,
       r.strength AS req_str, r.dexterity AS req_dex, r.intelligence AS req_int,
       r.faith AS req_fai, r.arcane AS req_arc,
       a.physical AS atk_physical, a.magic AS atk_magic, a.fire AS atk_fire,
       a.lightning AS atk_lightning, a.holy AS atk_holy, a.critical AS atk_critical
FROM weapons w
JOIN weapon_types wt ON wt.id = w.weapon_type_id
JOIN damage_types dt ON dt.id = w.damage_type_id
LEFT JOIN skills s ON s.id = w.skill_id
LEFT JOIN weapon_requirements r ON r.weapon_id = w.id
LEFT JOIN weapon_attack a ON a.weapon_id = w.id;

-- Подбор оружия под характеристики персонажа
-- Пример: SELECT * FROM v_weapon_catalog
--         WHERE req_str <= 14 AND req_dex <= 16 AND req_int <= 10 AND req_fai <= 10 AND req_arc <= 10;

-- Дроп противников (босс / уникальный / рядовой) → предмет
-- Пример: SELECT * FROM v_drops WHERE enemy = 'Маргит, Грозный Лик';
CREATE VIEW v_drops AS
SELECT COALESCE(b.name, ue.name, re.name) AS enemy,
       CASE WHEN d.boss_id IS NOT NULL THEN 'Босс'
            WHEN d.unique_enemy_id IS NOT NULL THEN 'Уникальный враг'
            ELSE 'Рядовой враг' END AS enemy_kind,
       COALESCE(w.name, sh.name, ar.name, ta.name, sp.name, ma.name) AS item,
       CASE WHEN d.weapon_id IS NOT NULL THEN 'Оружие'
            WHEN d.shield_id IS NOT NULL THEN 'Щит'
            WHEN d.armor_set_id IS NOT NULL THEN 'Броня'
            WHEN d.talisman_id IS NOT NULL THEN 'Талисман'
            WHEN d.spell_id IS NOT NULL THEN 'Заклинание'
            ELSE 'Материал' END AS item_kind
FROM drops d
LEFT JOIN bosses b           ON b.id  = d.boss_id
LEFT JOIN unique_enemies ue  ON ue.id = d.unique_enemy_id
LEFT JOIN regular_enemies re ON re.id = d.regular_enemy_id
LEFT JOIN weapons w          ON w.id  = d.weapon_id
LEFT JOIN shields sh         ON sh.id = d.shield_id
LEFT JOIN armor_sets ar      ON ar.id = d.armor_set_id
LEFT JOIN talismans ta       ON ta.id = d.talisman_id
LEFT JOIN spells sp          ON sp.id = d.spell_id
LEFT JOIN materials ma       ON ma.id = d.material_id;

-- Где встречается босс / уникальный враг (локация + регион)
-- Пример: SELECT * FROM v_enemy_locations WHERE enemy = 'Маргит, Грозный Лик';
CREATE VIEW v_enemy_locations AS
SELECT b.name AS enemy, 'Босс' AS enemy_kind, l.name AS location, r.name AS region
FROM bosses b JOIN locations l ON l.id = b.location_id JOIN regions r ON r.id = l.region_id
UNION ALL
SELECT ue.name, 'Уникальный враг', l.name, r.name
FROM unique_enemies ue JOIN locations l ON l.id = ue.location_id JOIN regions r ON r.id = l.region_id;

-- Статистика билдов: сколько сохранённых конфигураций используют талисман
CREATE VIEW v_talisman_usage AS
SELECT t.id, t.name, COUNT(bt.build_id) AS builds_count
FROM talismans t LEFT JOIN build_talismans bt ON bt.talisman_id = t.id
GROUP BY t.id, t.name;

-- Статистика билдов: сколько сохранённых конфигураций используют заклинание
CREATE VIEW v_spell_usage AS
SELECT s.id, s.name, COUNT(bs.build_id) AS builds_count
FROM spells s LEFT JOIN build_spells bs ON bs.spell_id = s.id
GROUP BY s.id, s.name;

-- =====================================================================
-- 14. ТЕСТОВЫЕ ДАННЫЕ (примерные значения, для проверки работы схемы)
-- =====================================================================
INSERT INTO roles (name) VALUES ('player'), ('moderator'), ('admin');

-- ВНИМАНИЕ: ниже — заглушка вместо хэша. При первом запуске EldenApi
-- инициализатор схемы заменит 'CHANGE_ME_HASH' на реальные хэши демо-аккаунтов
-- (admin/admin123, moder/moder123, player/player123).
INSERT INTO users (login, password_hash, role_id) VALUES
 ('admin',  'CHANGE_ME_HASH', 3),
 ('moder',  'CHANGE_ME_HASH', 2),
 ('player', 'CHANGE_ME_HASH', 1);

INSERT INTO weapon_types (name)   VALUES ('Катана'), ('Большой меч'), ('Посох');
INSERT INTO damage_types (name)   VALUES ('Рубящий'), ('Колющий'), ('Дробящий'), ('Огненный'), ('Магический'), ('Святой'), ('Молния');
INSERT INTO skills (name)         VALUES ('Обнажение клинка'), ('Коготь льва'), ('Каменный щит');
INSERT INTO acquisitions (name)   VALUES ('Продаётся у торговца'), ('Выпадает с босса'), ('Найден в мире'), ('Награда за квест');
INSERT INTO shield_types (name)   VALUES ('Малый щит'), ('Средний щит'), ('Большой щит');
INSERT INTO talisman_types (name) VALUES ('Усиление атаки'), ('Защитный'), ('Восстановление');
INSERT INTO magic_types (name)    VALUES ('Чары'), ('Молитвы');
INSERT INTO material_types (name) VALUES ('Камень ковки'), ('Цветок'), ('Крафтовый материал');
INSERT INTO character_types (name) VALUES ('Торговец'), ('Союзник'), ('Квестовый персонаж');

INSERT INTO weapons (name, weapon_type_id, damage_type_id, skill_id, weight, acquisition_id) VALUES
 ('Утигатана', 1, 1, 1, 5.5, 3),
 ('Клеймор',   2, 1, 2, 9.0, 3);
INSERT INTO weapon_requirements (weapon_id, strength, dexterity) VALUES (1, 11, 15), (2, 18, 12);
INSERT INTO weapon_bonuses      (weapon_id, strength, dexterity) VALUES (1, 0, 1), (2, 1, 0);
INSERT INTO weapon_attack  (weapon_id, physical, critical) VALUES (1, 115, 100), (2, 118, 100);
INSERT INTO weapon_defense (weapon_id, physical, magic, fire, lightning, holy, guard_boost) VALUES
 (1, 49.0, 30.0, 30.0, 30.0, 30.0, 31), (2, 56.0, 33.0, 33.0, 33.0, 33.0, 39);

INSERT INTO shields (name, shield_type_id, skill_id, damage_type_id, weight, acquisition_id) VALUES
 ('Круглый щит', 1, 3, 3, 3.0, 1);
INSERT INTO shield_requirements (shield_id, strength) VALUES (1, 8);
INSERT INTO shield_bonuses      (shield_id) VALUES (1);
INSERT INTO shield_attack       (shield_id, physical) VALUES (1, 80);
INSERT INTO shield_defense (shield_id, physical, magic, fire, lightning, holy, guard_boost) VALUES
 (1, 100.0, 50.0, 50.0, 50.0, 50.0, 40);

INSERT INTO armor_sets (name, weight, acquisition_id) VALUES ('Комплект странника', 10.5, 3);
INSERT INTO armor_defense (armor_set_id, physical, strike, slash, pierce, magic, fire, lightning, holy)
 VALUES (1, 15.0, 15.0, 16.0, 14.0, 10.0, 11.0, 10.0, 10.0);
INSERT INTO armor_resistance (armor_set_id, immunity, robustness, focus, vitality, poise)
 VALUES (1, 20, 25, 20, 20, 12);

INSERT INTO talismans (name, effect, weight, talisman_type_id, acquisition_id) VALUES
 ('Медальон красной капли', 'Увеличивает максимальное здоровье', 0.3, 2, 1),
 ('Талисман крылатого меча', 'Увеличивает силу атаки при полном здоровье', 0.3, 1, 3);

INSERT INTO spells (name, effect, magic_type_id, acquisition_id) VALUES
 ('Звёздный снаряд', 'Выпускает магический снаряд', 1, 1),
 ('Исцеление',       'Восстанавливает здоровье',    2, 1);
INSERT INTO spell_parameters  (spell_id, fp_cost, stamina_cost, slots) VALUES (1, 8, 0, 1), (2, 20, 0, 1);
INSERT INTO spell_requirements (spell_id, intelligence, faith) VALUES (1, 10, 0), (2, 0, 10);

INSERT INTO regions   (name) VALUES ('Лимгрейв'), ('Лиурния');
INSERT INTO locations (name, description, region_id) VALUES
 ('Замок Грозовой Завесы', 'Древний замок, охраняемый Маргитом', 1),
 ('Церковь Элеоноры', 'Небольшая церковь в Лимгрейве', 1);
INSERT INTO characters (name, character_type_id, location_id, description) VALUES
 ('Кузнец Хьюг', 1, 2, 'Торговец и кузнец');

INSERT INTO bosses (name, location_id, tactics) VALUES
 ('Маргит, Грозный Лик', 1, 'Держите дистанцию, уворачивайтесь перекатом от серии ударов.');
INSERT INTO unique_enemies  (name, location_id) VALUES ('Рыцарь-призрак', 1);
INSERT INTO regular_enemies (name, region_id, description) VALUES ('Солдат Лимгрейва', 1, 'Рядовой пеший противник');

INSERT INTO materials (name, material_type_id, effect) VALUES
 ('Камень ковки [1]', 1, 'Улучшает оружие до +1');

INSERT INTO drops (boss_id, talisman_id)         VALUES (1, 2);
INSERT INTO drops (unique_enemy_id, weapon_id)   VALUES (1, 1);
INSERT INTO drops (regular_enemy_id, material_id) VALUES (1, 1);

INSERT INTO attributes (name, description) VALUES
 ('Сила', 'Влияет на урон тяжёлого оружия'),
 ('Ловкость', 'Влияет на урон лёгкого оружия и скорость каста'),
 ('Мудрость', 'Влияет на силу чар'),
 ('Вера', 'Влияет на силу молитв'),
 ('Колдовство', 'Влияет на кровотечение, яд и особые заклинания');

INSERT INTO tutorials (name, description) VALUES ('Основы боя', 'Базовые приёмы боя');
INSERT INTO mechanics (tutorial_id, name, description) VALUES
 (1, 'Перекат', 'Позволяет уклоняться от атак'),
 (1, 'Блок', 'Снижает получаемый урон щитом');

INSERT INTO builds (user_id, name, strength, dexterity, weapon_id, shield_id, armor_set_id)
 VALUES (3, 'Стартовый самурай', 12, 16, 1, 1, 1);
INSERT INTO build_talismans (build_id, talisman_id) VALUES (1, 1), (1, 2);
INSERT INTO build_spells    (build_id, spell_id)    VALUES (1, 2);

-- ---------------------------------------------------------------------
-- Категории и статьи вики (разделы каталога, используются REST API)
-- ---------------------------------------------------------------------
INSERT INTO categories (name, slug, description) VALUES
 ('Оружие',    'weapons',    'Каталог оружия: характеристики, требования, бонусы и способы получения.'),
 ('Броня',     'armor',      'Комплекты брони и их защитные характеристики.'),
 ('Щиты',      'shields',    'Каталог щитов и их виды.'),
 ('Талисманы', 'talismans',  'Талисманы и их эффекты.'),
 ('Магия',     'magic',      'Чары и молитвы.'),
 ('Материалы', 'materials',  'Материалы для усиления.'),
 ('Персонажи', 'characters', 'НПС игрового мира.'),
 ('Боссы',     'bosses',     'Боссы, тактики и дроп.'),
 ('Враги',     'enemies',    'Уникальные и рядовые противники.'),
 ('Локации',   'locations',  'Регионы и локации.'),
 ('Обучение',  'tutorials',  'Механики и основы игры.'),
 ('Билды',     'builds',     'Гайды по сборке персонажа.');

INSERT INTO articles (category_id, author_id, title, summary, content) VALUES
 (1, 1, 'Утигатана', 'Лёгкая катана с высоким критическим уроном.',
  'Утигатана — катана с навыком «Обнажение клинка». Требует 11 силы и 15 ловкости. Подходит для ловких сборок и хорошо сочетается с кровотечением.'),
 (8, 1, 'Маргит, Грозный Лик', 'Первый серьёзный босс Лимгрейва.',
  'Держите дистанцию, уворачивайтесь перекатом от серии ударов и используйте призыв духов, чтобы разделить внимание босса.');
