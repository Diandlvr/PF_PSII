# CinemaxPlus

Plataforma de streaming (estilo Netflix) hecha con **Java JSP + Tomcat + MySQL/MariaDB**,
como Dynamic Web Project de Eclipse (sin Maven, sin Spring).

## Funcionalidades
- Registro con verificación por correo y login con hash SHA-256 + salt.
- Membresías (Regular gratis / Premium con pago simulado).
- Perfiles por cuenta (estilo Netflix); favoritos, "Ver más tarde" y progreso son **por perfil**.
- Catálogo de 35 películas (5 por género) con filtro por género.
- Reproductor de video HTML5 que guarda el avance y retoma donde quedaste.
- Filas "Continuar viendo" (con barra de %) y "Ver más tarde" en el catálogo.
- Reportes: avance de reproducción y cuenta (membresía + perfiles).

## Requisitos
- JDK 11+ · Tomcat 8.5/9 · MySQL 8 o MariaDB 10.4 (XAMPP)
- MySQL Connector/J en `WebContent/WEB-INF/lib` (incluido)

## Puesta en marcha rápida
1. Importar `database_mariadb.sql` (crea la BD `cinemax_plus` completa con datos de prueba).
2. Abrir el proyecto en Eclipse como Dynamic Web Project y desplegar en Tomcat
   (o compilar `src/modelo/*.java` a `WebContent/WEB-INF/classes` y apuntar un Context al `WebContent`).
3. (Opcional, para correos de verificación) copiar `src/mail.properties.example`
   a `src/mail.properties` y a `WebContent/WEB-INF/classes/` con credenciales SMTP reales.
4. Entrar a `http://localhost:8080/CinemaxPlus/` — usuario de prueba: `carlos@gmail.com` / `123456`.

La conexión a BD se puede configurar con variables de entorno
(`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`); por defecto usa `localhost:3306`, `root` sin password.

## Estructura
```
src/modelo/          Clases Java (DAOs, filtros, utilidades)
WebContent/          Páginas JSP, CSS, imágenes, favicon
WebContent/WEB-INF/  web.xml, librerías (.jar) y clases compiladas
database_mariadb.sql Dump completo de la BD (esquema + datos de prueba)
```
