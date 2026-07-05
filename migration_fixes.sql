-- ============================================================
--  CinemaxPlus - Correcciones criticas de esquema
--
--  Ejecutar en phpMyAdmin sobre la BD `cinemax_plus` UNA sola
--  vez despues de importar database_mariadb.sql y progreso.sql.
--
--  Cambios:
--   1) Agrega columnas `verificado` y `token_verificacion` a
--      la tabla `cliente` (requeridas por login.jsp y registro.jsp).
--   2) Agrega columna `password_salt` para el hashing SHA-256.
--   3) Marca como verificados a los clientes de prueba.
-- ============================================================

USE `cinemax_plus`;

-- (1) Columnas de verificacion por correo
ALTER TABLE `cliente`
  ADD COLUMN IF NOT EXISTS `verificado`         TINYINT(1)   NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `token_verificacion` VARCHAR(255) DEFAULT NULL;

-- (2) Salt para hashing de contrasena
ALTER TABLE `cliente`
  ADD COLUMN IF NOT EXISTS `password_salt` VARCHAR(64) DEFAULT NULL;

-- (3) Marcar los clientes existentes como verificados para no romper login
UPDATE `cliente` SET `verificado` = 1 WHERE `verificado` = 0;
