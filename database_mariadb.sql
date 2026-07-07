-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: cinemax_plus
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `cinemax_plus`
--

/*!40000 DROP DATABASE IF EXISTS `cinemax_plus`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cinemax_plus` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `cinemax_plus`;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `correo` varchar(100) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `fecha_registro` timestamp NULL DEFAULT current_timestamp(),
  `verificado` tinyint(1) NOT NULL DEFAULT 0,
  `token_verificacion` varchar(255) DEFAULT NULL,
  `password_salt` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'carlos@gmail.com','5174fc9ccb6679bb7892bacad1710fa47629f8c4424075323527cd6f8a772e46','Carlos Contreras','2025-12-15 04:04:59',1,NULL,'988ddecbdf7bb7ec4dbd9026e8623026'),(2,'diego@gmail.com','123456','Diego','2025-12-15 19:00:17',1,NULL,NULL),(3,'admin@test.com','123456','admin','2025-12-15 19:29:23',1,NULL,NULL),(4,'juanxp8879@gmail.com','ef4ea378b4590eee0e1a6089da794e893f7c87ea4e64a6ded2dba1b428a97731','Juan Pitti','2026-06-22 15:16:32',1,NULL,'2bf35d4420e0a5cd8d9eb96b6aa974a6');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contenido`
--

DROP TABLE IF EXISTS `contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contenido` (
  `id_contenido` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) NOT NULL,
  `genero` varchar(50) NOT NULL,
  `imagen_url` varchar(255) NOT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `duracion_min` int(11) NOT NULL DEFAULT 120,
  PRIMARY KEY (`id_contenido`)
) ENGINE=MyISAM AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenido`
--

LOCK TABLES `contenido` WRITE;
/*!40000 ALTER TABLE `contenido` DISABLE KEYS */;
INSERT INTO `contenido` VALUES (1,'Mad Max: Fury Road','Acción','https://img.youtube.com/vi/hEJnMQG9ev8/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',120),(2,'John Wick 4','Acción','https://img.youtube.com/vi/qEVUtrk8_B4/hqdefault.jpg','https://www.w3schools.com/html/mov_bbb.mp4',120),(3,'The Dark Knight','Acción','https://img.youtube.com/vi/EXeTwQWrcwY/hqdefault.jpg','https://vjs.zencdn.net/v/oceans.mp4',120),(4,'Top Gun: Maverick','Acción','https://img.youtube.com/vi/qSqVVswa420/hqdefault.jpg','https://media.w3.org/2010/05/sintel/trailer.mp4',120),(5,'Avengers: Endgame','Acción','https://img.youtube.com/vi/TcMBFSGVi1c/hqdefault.jpg','https://download.samplelib.com/mp4/sample-5s.mp4',120),(7,'Barbie','Comedia','https://img.youtube.com/vi/zh4KhVSMwtQ/hqdefault.jpg','https://download.samplelib.com/mp4/sample-15s.mp4',120),(8,'The Hangover','Comedia','https://img.youtube.com/vi/tlize92ffnY/hqdefault.jpg','https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',120),(9,'Superbad','Comedia','https://img.youtube.com/vi/4eaZ_48ZYog/hqdefault.jpg','https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',120),(10,'The Office','Comedia','https://img.youtube.com/vi/-ZSV0jcYJw8/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',120),(11,'Mean Girls','Comedia','https://img.youtube.com/vi/oDU84nmSDZY/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',120),(13,'It (Eso)','Terror','https://img.youtube.com/vi/fP4BBZ76DGg/hqdefault.jpg','https://vjs.zencdn.net/v/oceans.mp4',120),(14,'The Exorcist','Terror','https://img.youtube.com/vi/BU2eYAO31Cc/hqdefault.jpg','https://media.w3.org/2010/05/sintel/trailer.mp4',120),(15,'Hereditary','Terror','https://img.youtube.com/vi/V6wWKNij_1M/hqdefault.jpg','https://download.samplelib.com/mp4/sample-5s.mp4',120),(16,'A Quiet Place','Terror','https://img.youtube.com/vi/WR7cc5t7tv8/hqdefault.jpg','https://download.samplelib.com/mp4/sample-10s.mp4',120),(17,'Halloween','Terror','https://img.youtube.com/vi/ek1ePFp-nBI/hqdefault.jpg','https://download.samplelib.com/mp4/sample-15s.mp4',120),(19,'Oppenheimer','Drama','https://img.youtube.com/vi/uYPbbksJxIg/hqdefault.jpg','https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',120),(20,'The Godfather','Drama','https://img.youtube.com/vi/UaVTIH8mujA/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',120),(21,'Breaking Bad','Drama','https://img.youtube.com/vi/mXd1zTwcQ18/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',120),(22,'Forrest Gump','Drama','https://img.youtube.com/vi/bLvqoHBptjg/hqdefault.jpg','https://www.w3schools.com/html/mov_bbb.mp4',120),(23,'Titanic','Drama','https://img.youtube.com/vi/kVrqfYjkTdQ/hqdefault.jpg','https://vjs.zencdn.net/v/oceans.mp4',120),(25,'Inception','Ciencia Ficción','https://img.youtube.com/vi/YoHD9XEInc0/hqdefault.jpg','https://download.samplelib.com/mp4/sample-5s.mp4',120),(26,'Interstellar','Ciencia Ficción','https://img.youtube.com/vi/LYS2O1nl9iM/hqdefault.jpg','https://download.samplelib.com/mp4/sample-10s.mp4',120),(27,'The Matrix','Ciencia Ficción','https://img.youtube.com/vi/vKQi3bBA1y8/hqdefault.jpg','https://download.samplelib.com/mp4/sample-15s.mp4',120),(28,'Blade Runner 2049','Ciencia Ficción','https://img.youtube.com/vi/gCcx85zbxz4/hqdefault.jpg','https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',120),(29,'Dune','Ciencia Ficción','https://img.youtube.com/vi/n9xhJrPXop4/hqdefault.jpg','https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',120),(51,'Toy Story','Animación','https://img.youtube.com/vi/c51ND9Hdbw0/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/friday.mp4',120),(52,'Spirited Away','Animación','https://img.youtube.com/vi/ByXuk9QqQkk/hqdefault.jpg','https://www.w3schools.com/html/mov_bbb.mp4',120),(53,'Coco','Animación','https://img.youtube.com/vi/R7wo-0Q0u4g/hqdefault.jpg','https://vjs.zencdn.net/v/oceans.mp4',120),(54,'Inside Out','Animación','https://img.youtube.com/vi/yRUAzGQ3nSY/hqdefault.jpg','https://media.w3.org/2010/05/sintel/trailer.mp4',120),(55,'Spider-Verse','Animación','https://img.youtube.com/vi/g4Hbz2jLxvQ/hqdefault.jpg','https://download.samplelib.com/mp4/sample-5s.mp4',120),(56,'Indiana Jones','Aventura','https://img.youtube.com/vi/0xQSIdSRlAk/hqdefault.jpg','https://download.samplelib.com/mp4/sample-10s.mp4',120),(57,'Jurassic Park','Aventura','https://img.youtube.com/vi/QWBKEmWWL38/hqdefault.jpg','https://download.samplelib.com/mp4/sample-15s.mp4',120),(58,'The Lord of the Rings','Aventura','https://img.youtube.com/vi/V75dMMIW2B4/hqdefault.jpg','https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',120),(59,'Pirates of the Caribbean','Aventura','https://img.youtube.com/vi/naQr0uTrH_s/hqdefault.jpg','https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',120),(60,'Back to the Future','Aventura','https://img.youtube.com/vi/qvsgGtivCgs/hqdefault.jpg','https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',120);
/*!40000 ALTER TABLE `contenido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favs`
--

DROP TABLE IF EXISTS `favs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `favs` (
  `id_fav` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(150) NOT NULL,
  `id_contenido` int(11) NOT NULL,
  `fecha_agregado` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_fav`),
  KEY `usuario` (`usuario`),
  KEY `id_contenido` (`id_contenido`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favs`
--

LOCK TABLES `favs` WRITE;
/*!40000 ALTER TABLE `favs` DISABLE KEYS */;
INSERT INTO `favs` VALUES (5,'1_carlos',1,'2025-12-15 04:20:12'),(4,'1_carlos',3,'2025-12-15 04:19:44'),(7,'1_carlos',22,'2025-12-15 04:20:20'),(8,'1_carlos',4,'2025-12-15 04:35:02'),(9,'1_carlos',16,'2025-12-15 04:55:12'),(10,'4_juan',57,'2026-06-23 19:36:55'),(12,'4_juan',22,'2026-07-07 05:31:44'),(14,'4_juan',2,'2026-07-07 06:28:23'),(15,'4_juan',3,'2026-07-07 06:45:42');
/*!40000 ALTER TABLE `favs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `membresias`
--

DROP TABLE IF EXISTS `membresias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `membresias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cliente_id` int(11) NOT NULL,
  `tipo` enum('regular','premium') NOT NULL,
  `fecha_inicio` datetime DEFAULT current_timestamp(),
  `fecha_vencimiento` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cliente_id` (`cliente_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `membresias`
--

LOCK TABLES `membresias` WRITE;
/*!40000 ALTER TABLE `membresias` DISABLE KEYS */;
INSERT INTO `membresias` VALUES (1,2,'premium','2025-12-15 14:01:57','2026-01-15 14:01:57'),(2,1,'regular','2026-07-07 00:06:50',NULL),(3,4,'premium','2026-07-07 00:17:02','2026-08-07 00:17:02'),(4,4,'premium','2026-07-07 00:31:07','2026-08-07 00:31:07');
/*!40000 ALTER TABLE `membresias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `progreso`
--

DROP TABLE IF EXISTS `progreso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `progreso` (
  `id_progreso` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(150) NOT NULL,
  `id_contenido` int(11) NOT NULL,
  `minuto_actual` int(11) NOT NULL DEFAULT 0,
  `duracion_total` int(11) NOT NULL DEFAULT 0,
  `fecha_visto` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_progreso`),
  UNIQUE KEY `uq_usuario_contenido` (`usuario`,`id_contenido`),
  KEY `usuario` (`usuario`),
  KEY `id_contenido` (`id_contenido`)
) ENGINE=MyISAM AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `progreso`
--

LOCK TABLES `progreso` WRITE;
/*!40000 ALTER TABLE `progreso` DISABLE KEYS */;
INSERT INTO `progreso` VALUES (1,'1_carlos',1,90,120,'2026-07-07 04:58:33'),(2,'1_carlos',3,152,152,'2026-07-07 04:58:33'),(3,'1_carlos',22,40,142,'2026-07-07 04:58:33'),(4,'1_carlos',4,0,131,'2026-07-07 04:58:33'),(5,'1_jamir',13,60,135,'2026-07-07 04:58:33'),(6,'1_jamir',16,45,90,'2026-07-07 04:58:33'),(7,'4_juan',57,104,127,'2026-07-07 06:37:41'),(8,'4_juan',7,62,114,'2026-07-07 06:49:40'),(9,'3_admin',19,100,180,'2026-07-07 04:58:33'),(11,'4_juan',56,51,120,'2026-07-07 06:37:18'),(12,'4_juan',2,36,120,'2026-07-07 06:44:59'),(13,'4_juan',55,120,120,'2026-07-07 06:47:59'),(14,'4_juan',52,63,120,'2026-07-07 06:46:27'),(15,'4_juan',29,57,120,'2026-07-07 06:47:20'),(16,'4_juan',54,57,120,'2026-07-07 06:48:17'),(17,'4_juan',4,9,120,'2026-07-07 06:48:48'),(18,'4_juan',53,83,120,'2026-07-07 06:49:20'),(19,'4_juan',8,48,120,'2026-07-07 06:49:58');
/*!40000 ALTER TABLE `progreso` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `perfil_key` varchar(150) NOT NULL,
  `cliente_id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `cat_fav` varchar(50) DEFAULT 'Acción',
  `avatar` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`perfil_key`),
  KEY `cliente_id` (`cliente_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES ('1_carlos',1,'Carlos','Drama',NULL),('1_jamir',1,'jamir','Terror',NULL),('3_admin',3,'admin','Drama',NULL),('4_juan',4,'Juan','Comedia',NULL);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ver_despues`
--

DROP TABLE IF EXISTS `ver_despues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ver_despues` (
  `id_ver_despues` int(11) NOT NULL AUTO_INCREMENT,
  `usuario` varchar(150) NOT NULL,
  `id_contenido` int(11) NOT NULL,
  `fecha_agregado` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_ver_despues`),
  UNIQUE KEY `uq_usuario_contenido` (`usuario`,`id_contenido`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ver_despues`
--

LOCK TABLES `ver_despues` WRITE;
/*!40000 ALTER TABLE `ver_despues` DISABLE KEYS */;
INSERT INTO `ver_despues` VALUES (6,'4_juan',1,'2026-07-07 06:32:38'),(8,'4_juan',3,'2026-07-07 06:45:43');
/*!40000 ALTER TABLE `ver_despues` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-07  1:58:06
