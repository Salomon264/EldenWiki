CREATE DATABASE  IF NOT EXISTS `eldenwiki` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `eldenwiki`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: eldenwiki
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `build_items`
--

DROP TABLE IF EXISTS `build_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `build_items` (
  `build_id` int unsigned NOT NULL,
  `item_id` int unsigned NOT NULL,
  PRIMARY KEY (`build_id`,`item_id`),
  KEY `idx_bi_item` (`item_id`),
  CONSTRAINT `build_items_ibfk_1` FOREIGN KEY (`build_id`) REFERENCES `builds` (`id`) ON DELETE CASCADE,
  CONSTRAINT `build_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `build_items`
--

LOCK TABLES `build_items` WRITE;
/*!40000 ALTER TABLE `build_items` DISABLE KEYS */;
INSERT INTO `build_items` VALUES (1,1),(1,3),(1,4),(1,5),(1,6),(1,8);
/*!40000 ALTER TABLE `build_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `build_stats`
--

DROP TABLE IF EXISTS `build_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `build_stats` (
  `build_id` int unsigned NOT NULL,
  `stat_id` smallint unsigned NOT NULL,
  `value` smallint unsigned NOT NULL,
  PRIMARY KEY (`build_id`,`stat_id`),
  KEY `stat_id` (`stat_id`),
  CONSTRAINT `build_stats_ibfk_1` FOREIGN KEY (`build_id`) REFERENCES `builds` (`id`) ON DELETE CASCADE,
  CONSTRAINT `build_stats_ibfk_2` FOREIGN KEY (`stat_id`) REFERENCES `stats` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `build_stats`
--

LOCK TABLES `build_stats` WRITE;
/*!40000 ALTER TABLE `build_stats` DISABLE KEYS */;
INSERT INTO `build_stats` VALUES (1,1,12),(1,2,16),(1,3,10),(1,4,10),(1,5,10);
/*!40000 ALTER TABLE `build_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `builds`
--

DROP TABLE IF EXISTS `builds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `builds` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_builds_user` (`user_id`),
  CONSTRAINT `builds_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `builds`
--

LOCK TABLES `builds` WRITE;
/*!40000 ALTER TABLE `builds` DISABLE KEYS */;
INSERT INTO `builds` VALUES (1,3,'Стартовый самурай','2026-10-05 06:28:01');
/*!40000 ALTER TABLE `builds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creature_locations`
--

DROP TABLE IF EXISTS `creature_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `creature_locations` (
  `creature_id` int unsigned NOT NULL,
  `location_id` int unsigned NOT NULL,
  PRIMARY KEY (`creature_id`,`location_id`),
  KEY `idx_cl_location` (`location_id`),
  CONSTRAINT `creature_locations_ibfk_1` FOREIGN KEY (`creature_id`) REFERENCES `creatures` (`id`),
  CONSTRAINT `creature_locations_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creature_locations`
--

LOCK TABLES `creature_locations` WRITE;
/*!40000 ALTER TABLE `creature_locations` DISABLE KEYS */;
INSERT INTO `creature_locations` VALUES (1,1),(2,1),(3,1),(3,2),(4,2);
/*!40000 ALTER TABLE `creature_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creature_types`
--

DROP TABLE IF EXISTS `creature_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `creature_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('npc','enemy') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creature_types`
--

LOCK TABLES `creature_types` WRITE;
/*!40000 ALTER TABLE `creature_types` DISABLE KEYS */;
INSERT INTO `creature_types` VALUES (1,'Босс','enemy'),(2,'Уникальный враг','enemy'),(3,'Рядовой враг','enemy'),(4,'Торговец','npc'),(5,'Союзник','npc');
/*!40000 ALTER TABLE `creature_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `creatures`
--

DROP TABLE IF EXISTS `creatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `creatures` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_id` int unsigned NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `tactics` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_creatures_type` (`type_id`),
  CONSTRAINT `creatures_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `creature_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `creatures`
--

LOCK TABLES `creatures` WRITE;
/*!40000 ALTER TABLE `creatures` DISABLE KEYS */;
INSERT INTO `creatures` VALUES (1,'Маргит, Грозный Лик',1,NULL,'Держите дистанцию, уворачивайтесь перекатом от серии ударов.'),(2,'Рыцарь-призрак',2,NULL,NULL),(3,'Солдат Лимгрейва',3,'Рядовой пеший противник',NULL),(4,'Кузнец Хьюг',4,'Торговец и кузнец',NULL);
/*!40000 ALTER TABLE `creatures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drops`
--

DROP TABLE IF EXISTS `drops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drops` (
  `creature_id` int unsigned NOT NULL,
  `item_id` int unsigned NOT NULL,
  PRIMARY KEY (`creature_id`,`item_id`),
  KEY `idx_drops_item` (`item_id`),
  CONSTRAINT `drops_ibfk_1` FOREIGN KEY (`creature_id`) REFERENCES `creatures` (`id`),
  CONSTRAINT `drops_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drops`
--

LOCK TABLES `drops` WRITE;
/*!40000 ALTER TABLE `drops` DISABLE KEYS */;
INSERT INTO `drops` VALUES (2,1),(1,6),(3,9);
/*!40000 ALTER TABLE `drops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_stats`
--

DROP TABLE IF EXISTS `item_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_stats` (
  `item_id` int unsigned NOT NULL,
  `stat_id` smallint unsigned NOT NULL,
  `purpose` enum('req','bonus','atk','def','res','cost') COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` decimal(6,1) NOT NULL,
  PRIMARY KEY (`item_id`,`purpose`,`stat_id`),
  KEY `idx_istats_search` (`stat_id`,`purpose`,`value`),
  CONSTRAINT `item_stats_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`),
  CONSTRAINT `item_stats_ibfk_2` FOREIGN KEY (`stat_id`) REFERENCES `stats` (`id`),
  CONSTRAINT `chk_stat_value` CHECK ((`value` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_stats`
--

LOCK TABLES `item_stats` WRITE;
/*!40000 ALTER TABLE `item_stats` DISABLE KEYS */;
INSERT INTO `item_stats` VALUES (3,1,'req',8.0),(1,1,'req',11.0),(2,1,'req',18.0),(2,1,'bonus',1.0),(2,2,'req',12.0),(1,2,'req',15.0),(1,2,'bonus',1.0),(7,3,'req',10.0),(8,4,'req',10.0),(3,6,'atk',80.0),(1,6,'atk',115.0),(2,6,'atk',118.0),(4,6,'def',15.0),(1,6,'def',49.0),(2,6,'def',56.0),(3,6,'def',100.0),(4,7,'def',10.0),(4,8,'def',11.0),(4,9,'def',10.0),(4,10,'def',10.0),(4,11,'def',15.0),(4,12,'def',16.0),(4,13,'def',14.0),(4,14,'res',20.0),(4,15,'res',25.0),(4,16,'res',20.0),(4,17,'res',20.0),(4,18,'res',12.0),(1,19,'atk',100.0),(2,19,'atk',100.0),(1,20,'def',31.0),(2,20,'def',39.0),(3,20,'def',40.0),(7,21,'cost',8.0),(8,21,'cost',20.0),(7,23,'cost',1.0),(8,23,'cost',1.0);
/*!40000 ALTER TABLE `item_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_types`
--

DROP TABLE IF EXISTS `item_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_types` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('weapon','shield','armor','talisman','spell','material') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_type` (`category`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_types`
--

LOCK TABLES `item_types` WRITE;
/*!40000 ALTER TABLE `item_types` DISABLE KEYS */;
INSERT INTO `item_types` VALUES (2,'Большой меч','weapon'),(1,'Катана','weapon'),(3,'Малый щит','shield'),(4,'Комплект брони','armor'),(6,'Защитный','talisman'),(5,'Усиление атаки','talisman'),(8,'Молитвы','spell'),(7,'Чары','spell'),(9,'Камень ковки','material');
/*!40000 ALTER TABLE `item_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_id` int unsigned NOT NULL,
  `weight` decimal(5,1) NOT NULL DEFAULT '0.0',
  `damage_type_id` smallint unsigned DEFAULT NULL,
  `skill_id` int unsigned DEFAULT NULL,
  `effect` text COLLATE utf8mb4_unicode_ci,
  `obtain` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `skill_id` (`skill_id`),
  KEY `idx_items_type` (`type_id`),
  KEY `idx_items_damage` (`damage_type_id`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`type_id`) REFERENCES `item_types` (`id`),
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`damage_type_id`) REFERENCES `stats` (`id`),
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`),
  CONSTRAINT `chk_item_weight` CHECK ((`weight` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES (1,'Утигатана',1,5.5,12,1,NULL,'Найден в мире'),(2,'Клеймор',2,9.0,12,2,NULL,'Найден в мире'),(3,'Круглый щит',3,3.0,11,3,NULL,'Продаётся у торговца'),(4,'Комплект странника',4,10.5,NULL,NULL,NULL,'Найден в мире'),(5,'Медальон красной капли',6,0.3,NULL,NULL,'Увеличивает максимальное здоровье','Продаётся у торговца'),(6,'Талисман крылатого меча',5,0.3,NULL,NULL,'Усиливает атаку при полном здоровье','Найден в мире'),(7,'Звёздный снаряд',7,0.0,NULL,NULL,'Выпускает магический снаряд','Продаётся у торговца'),(8,'Исцеление',8,0.0,NULL,NULL,'Восстанавливает здоровье','Продаётся у торговца'),(9,'Камень ковки [1]',9,0.0,NULL,NULL,'Улучшает оружие до +1','Находится в подземельях');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `region_id` int unsigned NOT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_location` (`region_id`,`name`),
  CONSTRAINT `locations_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES (1,1,'Замок Грозовой Завесы','Древний замок, охраняемый Маргитом'),(2,1,'Церковь Элеоноры','Небольшая церковь в Лимгрейве');
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mechanics`
--

DROP TABLE IF EXISTS `mechanics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mechanics` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `tutorial_id` int unsigned NOT NULL,
  `stat_id` smallint unsigned DEFAULT NULL,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_mech` (`tutorial_id`,`name`),
  KEY `stat_id` (`stat_id`),
  CONSTRAINT `mechanics_ibfk_1` FOREIGN KEY (`tutorial_id`) REFERENCES `tutorials` (`id`),
  CONSTRAINT `mechanics_ibfk_2` FOREIGN KEY (`stat_id`) REFERENCES `stats` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mechanics`
--

LOCK TABLES `mechanics` WRITE;
/*!40000 ALTER TABLE `mechanics` DISABLE KEYS */;
INSERT INTO `mechanics` VALUES (1,1,NULL,'Перекат','Позволяет уклоняться от атак'),(2,1,20,'Блок','Снижает получаемый урон щитом'),(3,1,18,'Сбивание с ног','Зависит от баланса брони');
/*!40000 ALTER TABLE `mechanics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `regions`
--

DROP TABLE IF EXISTS `regions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `regions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `regions`
--

LOCK TABLES `regions` WRITE;
/*!40000 ALTER TABLE `regions` DISABLE KEYS */;
INSERT INTO `regions` VALUES (1,'Лимгрейв'),(2,'Лиурния');
/*!40000 ALTER TABLE `regions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (3,'admin'),(2,'moderator'),(1,'player');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES (1,'Обнажение клинка',NULL),(2,'Коготь льва',NULL),(3,'Каменный щит',NULL);
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stats`
--

DROP TABLE IF EXISTS `stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stats` (
  `id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kind` enum('attribute','damage','resistance','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stats`
--

LOCK TABLES `stats` WRITE;
/*!40000 ALTER TABLE `stats` DISABLE KEYS */;
INSERT INTO `stats` VALUES (1,'Сила','attribute','Влияет на урон тяжёлого оружия'),(2,'Ловкость','attribute','Влияет на урон лёгкого оружия и скорость каста'),(3,'Мудрость','attribute','Влияет на силу чар'),(4,'Вера','attribute','Влияет на силу молитв'),(5,'Колдовство','attribute','Влияет на кровотечение, яд и особые заклинания'),(6,'Физический','damage',NULL),(7,'Магия','damage',NULL),(8,'Огонь','damage',NULL),(9,'Молния','damage',NULL),(10,'Святое','damage',NULL),(11,'Дробящий','damage',NULL),(12,'Рубящий','damage',NULL),(13,'Колющий','damage',NULL),(14,'Иммунитет','resistance','Сопротивление яду и гнили'),(15,'Живучесть','resistance','Сопротивление кровотечению и обморожению'),(16,'Концентрация','resistance','Сопротивление сну и безумию'),(17,'Физическая мощь','resistance','Сопротивление смерти от проклятия'),(18,'Баланс','resistance','Устойчивость к сбиванию с ног'),(19,'Критический удар','other',NULL),(20,'Усиление блока','other',NULL),(21,'Расход FP','other',NULL),(22,'Расход выносливости','other',NULL),(23,'Слоты памяти','other',NULL);
/*!40000 ALTER TABLE `stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tutorials`
--

DROP TABLE IF EXISTS `tutorials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tutorials` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tutorials`
--

LOCK TABLES `tutorials` WRITE;
/*!40000 ALTER TABLE `tutorials` DISABLE KEYS */;
INSERT INTO `tutorials` VALUES (1,'Основы боя','Базовые приёмы боя');
/*!40000 ALTER TABLE `tutorials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `login` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` tinyint unsigned NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login` (`login`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','CHANGE_ME_HASH',3,'2026-10-05 06:28:01'),(2,'moder','CHANGE_ME_HASH',2,'2026-10-05 06:28:01'),(3,'player','CHANGE_ME_HASH',1,'2026-10-05 06:28:01');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_creature_locations`
--

DROP TABLE IF EXISTS `v_creature_locations`;
/*!50001 DROP VIEW IF EXISTS `v_creature_locations`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_creature_locations` AS SELECT 
 1 AS `creature`,
 1 AS `creature_type`,
 1 AS `location`,
 1 AS `region`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_drops`
--

DROP TABLE IF EXISTS `v_drops`;
/*!50001 DROP VIEW IF EXISTS `v_drops`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_drops` AS SELECT 
 1 AS `creature`,
 1 AS `item`,
 1 AS `item_category`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_item_usage`
--

DROP TABLE IF EXISTS `v_item_usage`;
/*!50001 DROP VIEW IF EXISTS `v_item_usage`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_item_usage` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `category`,
 1 AS `builds_count`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_items`
--

DROP TABLE IF EXISTS `v_items`;
/*!50001 DROP VIEW IF EXISTS `v_items`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_items` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `category`,
 1 AS `item_type`,
 1 AS `damage_type`,
 1 AS `skill`,
 1 AS `weight`,
 1 AS `effect`,
 1 AS `obtain`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_requirements`
--

DROP TABLE IF EXISTS `v_requirements`;
/*!50001 DROP VIEW IF EXISTS `v_requirements`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_requirements` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `category`,
 1 AS `str`,
 1 AS `dex`,
 1 AS `intel`,
 1 AS `fai`,
 1 AS `arc`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `v_creature_locations`
--

/*!50001 DROP VIEW IF EXISTS `v_creature_locations`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_creature_locations` AS select `c`.`name` AS `creature`,`ct`.`name` AS `creature_type`,`l`.`name` AS `location`,`r`.`name` AS `region` from ((((`creatures` `c` join `creature_types` `ct` on((`ct`.`id` = `c`.`type_id`))) join `creature_locations` `cl` on((`cl`.`creature_id` = `c`.`id`))) join `locations` `l` on((`l`.`id` = `cl`.`location_id`))) join `regions` `r` on((`r`.`id` = `l`.`region_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_drops`
--

/*!50001 DROP VIEW IF EXISTS `v_drops`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_drops` AS select `c`.`name` AS `creature`,`i`.`name` AS `item`,`t`.`category` AS `item_category` from (((`drops` `d` join `creatures` `c` on((`c`.`id` = `d`.`creature_id`))) join `items` `i` on((`i`.`id` = `d`.`item_id`))) join `item_types` `t` on((`t`.`id` = `i`.`type_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_item_usage`
--

/*!50001 DROP VIEW IF EXISTS `v_item_usage`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_item_usage` AS select `i`.`id` AS `id`,`i`.`name` AS `name`,`t`.`category` AS `category`,count(`bi`.`build_id`) AS `builds_count` from ((`items` `i` join `item_types` `t` on((`t`.`id` = `i`.`type_id`))) left join `build_items` `bi` on((`bi`.`item_id` = `i`.`id`))) group by `i`.`id`,`i`.`name`,`t`.`category` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_items`
--

/*!50001 DROP VIEW IF EXISTS `v_items`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_items` AS select `i`.`id` AS `id`,`i`.`name` AS `name`,`t`.`category` AS `category`,`t`.`name` AS `item_type`,`d`.`name` AS `damage_type`,`sk`.`name` AS `skill`,`i`.`weight` AS `weight`,`i`.`effect` AS `effect`,`i`.`obtain` AS `obtain` from (((`items` `i` join `item_types` `t` on((`t`.`id` = `i`.`type_id`))) left join `stats` `d` on((`d`.`id` = `i`.`damage_type_id`))) left join `skills` `sk` on((`sk`.`id` = `i`.`skill_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_requirements`
--

/*!50001 DROP VIEW IF EXISTS `v_requirements`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_requirements` AS select `i`.`id` AS `id`,`i`.`name` AS `name`,`t`.`category` AS `category`,coalesce(max((case when (`s`.`name` = 'Сила') then `x`.`value` end)),0) AS `str`,coalesce(max((case when (`s`.`name` = 'Ловкость') then `x`.`value` end)),0) AS `dex`,coalesce(max((case when (`s`.`name` = 'Мудрость') then `x`.`value` end)),0) AS `intel`,coalesce(max((case when (`s`.`name` = 'Вера') then `x`.`value` end)),0) AS `fai`,coalesce(max((case when (`s`.`name` = 'Колдовство') then `x`.`value` end)),0) AS `arc` from (((`items` `i` join `item_types` `t` on((`t`.`id` = `i`.`type_id`))) left join `item_stats` `x` on(((`x`.`item_id` = `i`.`id`) and (`x`.`purpose` = 'req')))) left join `stats` `s` on((`s`.`id` = `x`.`stat_id`))) group by `i`.`id`,`i`.`name`,`t`.`category` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-05 11:28:48
