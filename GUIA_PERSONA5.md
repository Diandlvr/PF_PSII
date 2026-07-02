# Guía Persona 5 — Avance de reproducción (Módulos 3A + 3C)

Guía para dejar funcionando la tabla `progreso` y el reporte de avance
(`reporte_avance.jsp`). Sirve como pasos a seguir **y** como evidencia de entrega.

> **Requisito previo:** la Fase 0 ya debe estar hecha (XAMPP + Tomcat 9 corriendo,
> base `cinemax_plus` importada desde `database_mariadb.sql`, Connector/J en su sitio).

---

## Paso 1 — Arrancar XAMPP

1. Abre el **Panel de Control de XAMPP**.
2. Pulsa **Start** en **Apache** y en **MySQL**.
3. Ambos deben quedar en verde. Si MySQL no arranca, cierra otros MySQL/servicios
   que usen el puerto 3306.

---

## Paso 2 — Importar `progreso.sql` en phpMyAdmin

Esto crea la tabla `progreso` con datos de prueba reales.

1. En el navegador abre: **http://localhost/phpmyadmin**
2. En la columna izquierda, haz clic en la base de datos **`cinemax_plus`**
   (importante: primero selecciónala, si no la tabla se crea en la BD equivocada).
3. Arriba, pestaña **SQL**.
4. Abre el archivo `progreso.sql` del proyecto, copia **todo** su contenido y pégalo
   en el cuadro de texto.
5. Botón **Continuar** (abajo a la derecha).
6. Debe salir el mensaje verde de que se ejecutaron las consultas.

**Alternativa (pestaña Importar):** con `cinemax_plus` seleccionada → pestaña
**Importar** → **Seleccionar archivo** → elige `progreso.sql` → **Continuar**.

### Verificación rápida
En la izquierda debe aparecer la tabla **`progreso`**. Haz clic en ella → pestaña
**Examinar**: deben verse **9 filas** (perfiles `1_carlos`, `1_jamir`, `4_juan`,
`3_admin`).

> Si sale `ERROR 1273 Unknown collation`: no debería, `progreso.sql` ya usa
> `utf8mb4_general_ci` (compatible con MariaDB/XAMPP). Si aparece, avisa al equipo
> porque significa que la BD base se importó con otra collation.

---

## Paso 3 — Publicar el proyecto en Tomcat (desde Eclipse)

1. En Eclipse, clic derecho sobre el proyecto **CinemaxPlus** → **Run As** →
   **Run on Server** → Tomcat 9 → **Finish**.
2. Si ya estaba corriendo, basta con **Ctrl + S** en los archivos nuevos y Eclipse
   los republica solo. Si tienes dudas: clic derecho al servidor (pestaña *Servers*)
   → **Clean...** y luego **Start**.

> 🔴 Recordatorio del error #1 del curso: el **Connector/J** debe estar en
> **Build Path** *y* en **Deployment Assembly**. Si al abrir una página sale
> `No suitable driver found`, ese es el motivo.

---

## Paso 4 — Probar el reporte de avance

Como el login/perfiles todavía no guardan el perfil en sesión, la página tiene un
**modo prueba** por URL. Abre en el navegador:

```
http://localhost:8080/CinemaxPlus/reporte_avance.jsp?perfil=1_carlos
```

Deberías ver, para el perfil `1_carlos`:

| Película          | Avance esperado |
|-------------------|-----------------|
| The Dark Knight   | 100% (Terminada) |
| Mad Max: Fury Road| 75% |
| Forrest Gump      | ~28% |
| Top Gun: Maverick | 0% |

Prueba también otros perfiles cambiando el parámetro:

```
http://localhost:8080/CinemaxPlus/reporte_avance.jsp?perfil=1_jamir
http://localhost:8080/CinemaxPlus/reporte_avance.jsp?perfil=4_juan
```

Y un perfil sin datos para ver el estado vacío:

```
http://localhost:8080/CinemaxPlus/reporte_avance.jsp?perfil=noexiste
```

---

## Paso 5 — Qué pasa cuando el login esté listo

Cuando la **Persona 2** guarde el perfil en la sesión con
`session.setAttribute("perfilKey", ...)` al elegir perfil, el reporte funcionará
**solo**, sin el `?perfil=` de la URL:

```
http://localhost:8080/CinemaxPlus/reporte_avance.jsp
```

No hay que cambiar código: la página primero busca `perfilKey` en la sesión y solo
usa el parámetro de la URL si la sesión está vacía (modo prueba). En la entrega
final se quita ese modo prueba.

---

## Resumen de lo que entrega la Persona 5

| Módulo | Archivo | Estado |
|--------|---------|--------|
| 3A Tabla progreso | `progreso.sql` | Hecho — importar con esta guía |
| 3C Reporte avance | `src/modelo/ReporteDAO.java` (`avance()`) | Hecho |
| 3C Reporte avance | `WebContent/reporte_avance.jsp` | Hecho |
| 4D CSS | sección nueva en `css/estilos_cinemax.css` | Adelantado (barras de progreso) |
| 5A Prueba final | prueba integrada en Tomcat | Pendiente (al final, con todo el equipo) |

---

## Problemas comunes

| Síntoma | Causa / solución |
|---------|------------------|
| `No suitable driver found` | Connector/J falta en **Deployment Assembly**. |
| La página carga pero sale vacía ("no ha comenzado a ver...") | La tabla `progreso` no se importó, o se importó en otra BD. Revisa el Paso 2. |
| `Unknown collation` al importar | La BD base se creó con otra collation; avisa al equipo. |
| Error 404 en `reporte_avance.jsp` | El proyecto no se republicó. Server → Clean → Start. |
| Los estilos se ven planos (sin barras) | El navegador cacheó el CSS viejo: **Ctrl + F5** para recargar. |
