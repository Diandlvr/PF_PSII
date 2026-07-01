
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

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `cinemax_plus` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `cinemax_plus`;
DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `correo` varchar(100) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `fecha_registro` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'carlos@gmail.com','123456','Carlos Contreras','2025-12-15 04:04:59'),(2,'diego@gmail.com','123456','Diego','2025-12-15 19:00:17'),(3,'admin@test.com','123456','admin','2025-12-15 19:29:23'),(4,'juanxp8879@gmail.com','Dante5516!','Juan Pitti','2026-06-22 15:16:32');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contenido` (
  `id_contenido` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) NOT NULL,
  `genero` varchar(50) NOT NULL,
  `imagen_url` varchar(255) NOT NULL,
  `youtube_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id_contenido`)
) ENGINE=MyISAM AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `contenido` WRITE;
/*!40000 ALTER TABLE `contenido` DISABLE KEYS */;
INSERT INTO `contenido` VALUES (1,'Mad Max: Fury Road','Acción','https://img.youtube.com/vi/hEJnMQG9ev8/hqdefault.jpg','hEJnMQG9ev8'),(2,'John Wick 4','Acción','https://img.youtube.com/vi/qEVUtrk8_B4/hqdefault.jpg','qEVUtrk8_B4'),(3,'The Dark Knight','Acción','https://img.youtube.com/vi/EXeTwQWrcwY/hqdefault.jpg','EXeTwQWrcwY'),(4,'Top Gun: Maverick','Acción','https://img.youtube.com/vi/qSqVVswa420/hqdefault.jpg','qSqVVswa420'),(5,'Avengers: Endgame','Acción','https://img.youtube.com/vi/TcMBFSGVi1c/hqdefault.jpg','TcMBFSGVi1c'),(6,'Gladiator','Acción','https://img.youtube.com/vi/P5ieIbInFpg/hqdefault.jpg','P5ieIbInFpg'),(7,'Barbie','Comedia','https://img.youtube.com/vi/zh4KhVSMwtQ/hqdefault.jpg','zh4KhVSMwtQ'),(8,'The Hangover','Comedia','https://img.youtube.com/vi/tlize92ffnY/hqdefault.jpg','tlize92ffnY'),(9,'Superbad','Comedia','https://img.youtube.com/vi/4eaZ_48ZYog/hqdefault.jpg','4eaZ_48ZYog'),(10,'The Office','Comedia','https://img.youtube.com/vi/-ZSV0jcYJw8/hqdefault.jpg','-ZSV0jcYJw8'),(11,'Mean Girls','Comedia','https://img.youtube.com/vi/oDU84nmSDZY/hqdefault.jpg','oDU84nmSDZY'),(12,'Shrek','Comedia','https://img.youtube.com/vi/CFeRaV32Zuo/hqdefault.jpg','CFeRaV32Zuo'),(13,'It (Eso)','Terror','https://img.youtube.com/vi/fP4BBZ76DGg/hqdefault.jpg','fP4BBZ76DGg'),(14,'The Exorcist','Terror','https://img.youtube.com/vi/BU2eYAO31Cc/hqdefault.jpg','BU2eYAO31Cc'),(15,'Hereditary','Terror','https://img.youtube.com/vi/V6wWKNij_1M/hqdefault.jpg','V6wWKNij_1M'),(16,'A Quiet Place','Terror','https://img.youtube.com/vi/WR7cc5t7tv8/hqdefault.jpg','WR7cc5t7tv8'),(17,'Halloween','Terror','https://img.youtube.com/vi/ek1ePFp-nBI/hqdefault.jpg','ek1ePFp-nBI'),(18,'The Conjuring','Terror','https://img.youtube.com/vi/ejMMn0t58Lc/hqdefault.jpg','ejMMn0t58Lc'),(19,'Oppenheimer','Drama','https://img.youtube.com/vi/uYPbbksJxIg/hqdefault.jpg','uYPbbksJxIg'),(20,'The Godfather','Drama','https://img.youtube.com/vi/UaVTIH8mujA/hqdefault.jpg','UaVTIH8mujA'),(21,'Breaking Bad','Drama','https://img.youtube.com/vi/mXd1zTwcQ18/hqdefault.jpg','mXd1zTwcQ18'),(22,'Forrest Gump','Drama','https://img.youtube.com/vi/bLvqoHBptjg/hqdefault.jpg','bLvqoHBptjg'),(23,'Titanic','Drama','https://img.youtube.com/vi/kVrqfYjkTdQ/hqdefault.jpg','kVrqfYjkTdQ'),(24,'Parasite','Drama','https://img.youtube.com/vi/5xH0HfJHsaY/hqdefault.jpg','5xH0HfJHsaY'),(25,'Inception','Ciencia Ficción','https://img.youtube.com/vi/YoHD9XEInc0/hqdefault.jpg','YoHD9XEInc0'),(26,'Interstellar','Ciencia Ficción','https://img.youtube.com/vi/LYS2O1nl9iM/hqdefault.jpg','LYS2O1nl9iM'),(27,'The Matrix','Ciencia Ficción','https://img.youtube.com/vi/vKQi3bBA1y8/hqdefault.jpg','vKQi3bBA1y8'),(28,'Blade Runner 2049','Ciencia Ficción','https://img.youtube.com/vi/gCcx85zbxz4/hqdefault.jpg','gCcx85zbxz4'),(29,'Dune','Ciencia Ficción','https://img.youtube.com/vi/n9xhJrPXop4/hqdefault.jpg','n9xhJrPXop4'),(30,'Arrival','Ciencia Ficción','https://img.youtube.com/vi/tFMo3UJ4B4g/hqdefault.jpg','tFMo3UJ4B4g'),(31,'Mission Impossible: Fallout','Acción','https://img.youtube.com/vi/wb49-oV0F78/hqdefault.jpg','wb49-oV0F78'),(32,'Die Hard','Acción','https://img.youtube.com/vi/jaJuwKCmJbY/hqdefault.jpg','jaJuwKCmJbY'),(33,'The Batman','Acción','https://img.youtube.com/vi/mqqft2x_Aa4/hqdefault.jpg','mqqft2x_Aa4'),(34,'Spider-Man: No Way Home','Acción','https://img.youtube.com/vi/JfVOs4VSpmA/hqdefault.jpg','JfVOs4VSpmA'),(35,'Casino Royale','Acción','https://img.youtube.com/vi/36mnx8dBbGE/hqdefault.jpg','36mnx8dBbGE'),(36,'Step Brothers','Comedia','https://img.youtube.com/vi/CewglxElBK0/hqdefault.jpg','CewglxElBK0'),(37,'21 Jump Street','Comedia','https://img.youtube.com/vi/Oj55KinxZx4/hqdefault.jpg','Oj55KinxZx4'),(38,'Ted','Comedia','https://img.youtube.com/vi/9fbo_pQvU7M/hqdefault.jpg','9fbo_pQvU7M'),(39,'Anchorman','Comedia','https://img.youtube.com/vi/QvJ1K0_JzFI/hqdefault.jpg','QvJ1K0_JzFI'),(40,'Game Night','Comedia','https://img.youtube.com/vi/qmxMAdV6s4U/hqdefault.jpg','qmxMAdV6s4U'),(41,'Get Out','Terror','https://img.youtube.com/vi/DzfpyUB60YY/hqdefault.jpg','DzfpyUB60YY'),(42,'Midsommar','Terror','https://img.youtube.com/vi/1Vnghdsjmd0/hqdefault.jpg','1Vnghdsjmd0'),(43,'The Babadook','Terror','https://img.youtube.com/vi/k5WQZzDRVtw/hqdefault.jpg','k5WQZzDRVtw'),(44,'Sinister','Terror','https://img.youtube.com/vi/_kbQAJR9YWQ/hqdefault.jpg','_kbQAJR9YWQ'),(45,'Insidious','Terror','https://img.youtube.com/vi/jxU8FU3o75A/hqdefault.jpg','jxU8FU3o75A'),(46,'Whiplash','Drama','https://img.youtube.com/vi/7d_jQycdQGo/hqdefault.jpg','7d_jQycdQGo'),(47,'Joker','Drama','https://img.youtube.com/vi/t433PEQGErc/hqdefault.jpg','t433PEQGErc'),(48,'The Shawshank Redemption','Drama','https://img.youtube.com/vi/PLl99DlL6b4/hqdefault.jpg','PLl99DlL6b4'),(49,'Fight Club','Drama','https://img.youtube.com/vi/qtRKdVHc-cE/hqdefault.jpg','qtRKdVHc-cE'),(50,'La La Land','Drama','https://img.youtube.com/vi/0pdqf4P9MB8/hqdefault.jpg','0pdqf4P9MB8'),(51,'Toy Story','Animación','https://img.youtube.com/vi/c51ND9Hdbw0/hqdefault.jpg','c51ND9Hdbw0'),(52,'Spirited Away','Animación','https://img.youtube.com/vi/ByXuk9QqQkk/hqdefault.jpg','ByXuk9QqQkk'),(53,'Coco','Animación','https://img.youtube.com/vi/R7wo-0Q0u4g/hqdefault.jpg','R7wo-0Q0u4g'),(54,'Inside Out','Animación','https://img.youtube.com/vi/yRUAzGQ3nSY/hqdefault.jpg','yRUAzGQ3nSY'),(55,'Spider-Verse','Animación','https://img.youtube.com/vi/g4Hbz2jLxvQ/hqdefault.jpg','g4Hbz2jLxvQ'),(56,'Indiana Jones','Aventura','https://img.youtube.com/vi/0xQSIdSRlAk/hqdefault.jpg','0xQSIdSRlAk'),(57,'Jurassic Park','Aventura','https://img.youtube.com/vi/QWBKEmWWL38/hqdefault.jpg','QWBKEmWWL38'),(58,'The Lord of the Rings','Aventura','https://img.youtube.com/vi/V75dMMIW2B4/hqdefault.jpg','V75dMMIW2B4'),(59,'Pirates of the Caribbean','Aventura','https://img.youtube.com/vi/naQr0uTrH_s/hqdefault.jpg','naQr0uTrH_s'),(60,'Back to the Future','Aventura','https://img.youtube.com/vi/qvsgGtivCgs/hqdefault.jpg','qvsgGtivCgs');
/*!40000 ALTER TABLE `contenido` ENABLE KEYS */;
UNLOCK TABLES;
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
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `favs` WRITE;
/*!40000 ALTER TABLE `favs` DISABLE KEYS */;
INSERT INTO `favs` VALUES (5,'1_carlos',1,'2025-12-15 04:20:12'),(4,'1_carlos',3,'2025-12-15 04:19:44'),(7,'1_carlos',22,'2025-12-15 04:20:20'),(8,'1_carlos',4,'2025-12-15 04:35:02'),(9,'1_carlos',16,'2025-12-15 04:55:12'),(10,'4_juan',57,'2026-06-23 19:36:55');
/*!40000 ALTER TABLE `favs` ENABLE KEYS */;
UNLOCK TABLES;
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
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `membresias` WRITE;
/*!40000 ALTER TABLE `membresias` DISABLE KEYS */;
INSERT INTO `membresias` VALUES (1,2,'premium','2025-12-15 14:01:57','2026-01-15 14:01:57');
/*!40000 ALTER TABLE `membresias` ENABLE KEYS */;
UNLOCK TABLES;
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

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES ('1_carlos',1,'Carlos','Drama',NULL),('1_jamir',1,'jamir','Terror',NULL),('3_admin',3,'admin','Drama',NULL),('4_juan',4,'Juan','Comedia',NULL);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

