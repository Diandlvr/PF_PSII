-- ============================================================
--  CinemaxPlus - Modulo 3A (Persona 5)
--  Tabla `progreso`: avance de reproduccion por PERFIL.
--
--  El avance NO es por cuenta (cliente), sino por PERFIL:
--  la columna `usuario` guarda el perfil_key (ej. "1_carlos"),
--  igual que la tabla `favs`.
--
--  Compatible con MariaDB 10.4 (XAMPP): MyISAM + utf8mb4_general_ci.
--  Ejecutar en phpMyAdmin sobre la BD `cinemax_plus` DESPUES de
--  haber importado database_mariadb.sql.
-- ============================================================

USE `cinemax_plus`;

DROP TABLE IF EXISTS `progreso`;

CREATE TABLE `progreso` (
  `id_progreso`    int(11)      NOT NULL AUTO_INCREMENT,
  `usuario`        varchar(150) NOT NULL,          -- perfil_key (ej. "1_carlos")
  `id_contenido`   int(11)      NOT NULL,
  `minuto_actual`  int(11)      NOT NULL DEFAULT 0,
  `duracion_total` int(11)      NOT NULL DEFAULT 0,
  `fecha_visto`    timestamp    NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_progreso`),
  KEY `usuario` (`usuario`),
  KEY `id_contenido` (`id_contenido`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
--  Datos de prueba: apuntan a perfil_key y id_contenido que YA
--  existen en database_mariadb.sql, para que el reporte de
--  avance (3C) muestre porcentajes reales en la sustentacion.
--
--  Perfiles reales: 1_carlos, 1_jamir, 3_admin, 4_juan
--  % visto = minuto_actual / duracion_total
-- ------------------------------------------------------------
LOCK TABLES `progreso` WRITE;
INSERT INTO `progreso` (`usuario`, `id_contenido`, `minuto_actual`, `duracion_total`) VALUES
  ('1_carlos',  1,  90, 120),   -- Mad Max: Fury Road      -> 75%
  ('1_carlos',  3, 152, 152),   -- The Dark Knight         -> 100% (terminada)
  ('1_carlos', 22,  40, 142),   -- Forrest Gump            -> ~28%
  ('1_carlos',  4,   0, 131),   -- Top Gun: Maverick       -> 0% (sin empezar)
  ('1_jamir',  13,  60, 135),   -- It (Eso)                -> ~44%
  ('1_jamir',  16,  45,  90),   -- A Quiet Place           -> 50%
  ('4_juan',   57,  75, 127),   -- Jurassic Park           -> ~59%
  ('4_juan',    7,  38, 114),   -- Barbie                  -> ~33%
  ('3_admin',  19, 100, 180);   -- Oppenheimer             -> ~56%
UNLOCK TABLES;
