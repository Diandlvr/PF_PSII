-- ============================================================
--  CinemaxPlus - Correcciones criticas de esquema
--
--  Ejecutar en phpMyAdmin / MySQL sobre la BD `cinemax_plus`
--  DESPUES de importar database_mariadb.sql y progreso.sql.
--
--  Cambios:
--   1) Agrega columnas `verificado` y `token_verificacion` a
--      la tabla `cliente` (requeridas por login.jsp y registro.jsp).
--   2) Agrega columna `password_salt` para el hashing SHA-256.
--   3) Marca como verificados a los clientes de prueba.
--
--  NOTA: el equipo usa MySQL Server 8.0, que NO soporta
--  `ADD COLUMN IF NOT EXISTS` (eso es sintaxis de MariaDB). Por eso
--  este script comprueba information_schema antes de cada ALTER, asi
--  es seguro re-ejecutarlo (idempotente) en MySQL 8.0.
-- ============================================================

USE `cinemax_plus`;

-- (1) verificado ---------------------------------------------------------
SET @existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = 'cinemax_plus'
                  AND TABLE_NAME   = 'cliente'
                  AND COLUMN_NAME  = 'verificado');
SET @sql := IF(@existe = 0,
  'ALTER TABLE `cliente` ADD COLUMN `verificado` TINYINT(1) NOT NULL DEFAULT 0',
  'DO 0');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- (2) token_verificacion -------------------------------------------------
SET @existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = 'cinemax_plus'
                  AND TABLE_NAME   = 'cliente'
                  AND COLUMN_NAME  = 'token_verificacion');
SET @sql := IF(@existe = 0,
  'ALTER TABLE `cliente` ADD COLUMN `token_verificacion` VARCHAR(255) DEFAULT NULL',
  'DO 0');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- (3) password_salt ------------------------------------------------------
SET @existe := (SELECT COUNT(*) FROM information_schema.COLUMNS
                WHERE TABLE_SCHEMA = 'cinemax_plus'
                  AND TABLE_NAME   = 'cliente'
                  AND COLUMN_NAME  = 'password_salt');
SET @sql := IF(@existe = 0,
  'ALTER TABLE `cliente` ADD COLUMN `password_salt` VARCHAR(64) DEFAULT NULL',
  'DO 0');
PREPARE st FROM @sql; EXECUTE st; DEALLOCATE PREPARE st;

-- (4) Marcar los clientes existentes como verificados para no romper login
UPDATE `cliente` SET `verificado` = 1 WHERE `verificado` = 0;
