# Documentación técnica — Catálogo y Favoritos (Persona 3)

Módulos cubiertos: **2A Catálogo + filtro (N1)**, **2B Agregar favorito**,
**2C Lista de favoritos**.

Archivos: `WebContent/repertorio.jsp`, `WebContent/favoritos.jsp`,
`src/modelo/ContenidoDAO.java`, `src/modelo/FavoritoDAO.java`.

---

## 1. Modelo de datos que usa este módulo

```
contenido (id_contenido, titulo, genero, imagen_url, youtube_id)
favs      (id_fav, usuario, id_contenido, fecha_agregado)
usuarios  (perfil_key, cliente_id, nombre, cat_fav, avatar)
```

- `contenido` es el catálogo completo (películas/series de ejemplo).
- `favs.usuario` guarda el **`perfil_key`** (ej. `"1_carlos"`), no el
  `cliente_id`: los favoritos son por perfil, igual que la tabla `progreso`
  de Persona 5. Esto permite que dos perfiles de la misma cuenta (ej. papá e
  hijo) tengan listas de favoritos distintas.
- `usuarios.cat_fav` es el género favorito declarado del perfil; se usa solo
  para decidir qué título mostrar en el *hero* de `repertorio.jsp`.

---

## 2. `ContenidoDAO.java` — acceso al catálogo

| Método | SQL | Uso |
|---|---|---|
| `getAll()` | `SELECT ... FROM contenido ORDER BY genero, titulo` | Catálogo completo sin filtro |
| `getByGenero(genero)` | `SELECT ... WHERE genero = ? ORDER BY titulo` | Catálogo filtrado (chip activo) |
| `getGeneros()` | `SELECT DISTINCT genero FROM contenido ORDER BY genero` | Construye los chips del filtro |

Todos los métodos devuelven `List<Map<String,String>>` (cada fila como
`id`, `titulo`, `genero`, `imagen_url`, `youtube_id`) para que el JSP no
tenga que manipular `ResultSet` directamente. Usan `PreparedStatement` con
parámetros (`?`) para evitar inyección SQL, y `try-with-resources` para
cerrar conexión/consulta siempre, incluso si hay excepción.

## 3. `FavoritoDAO.java` — acceso a favoritos

| Método | Qué hace |
|---|---|
| `getIds(perfilKey)` | Devuelve un `Set<Integer>` con los IDs de contenido favoritos de ese perfil. Se usa para pintar el ícono ♥/♡ en cada tarjeta del catálogo sin hacer una consulta por tarjeta. |
| `getContenido(perfilKey)` | JOIN `favs` + `contenido`, ordenado por `fecha_agregado DESC`. Es lo que pinta la grilla de `favoritos.jsp`. |
| `toggle(perfilKey, idContenido)` | Lógica central de **2B**: primero hace `SELECT COUNT(*) FROM favs WHERE usuario=? AND id_contenido=?`. Si ya existe → `DELETE`; si no existe → `INSERT`. Devuelve `true` si quedó como favorito, `false` si se quitó. Esto es lo que garantiza **cero duplicados**: nunca se inserta sin comprobar antes. |
| `remove(perfilKey, idContenido)` | `DELETE` directo, sin toggle. Lo usa `favoritos.jsp` para el botón "Quitar" (ahí siempre se quiere quitar, nunca alternar). |

## 4. `repertorio.jsp` — Catálogo + filtro + agregar favorito (2A + 2B)

**Guardias al inicio de la página:**
1. Sin `session.getAttribute("clienteId")` → redirige a `login.jsp`.
2. Sin perfil (`?perfil=` o `session.getAttribute("perfilKey")`) → redirige a
   `usuarios.jsp`.
3. El perfil se valida contra `usuarios` con `perfil_key + cliente_id`, así
   un cliente no puede leer/tocar los favoritos de un perfil ajeno solo
   cambiando el parámetro de la URL.

**Flujo de renderizado (GET):**
1. Lee `genero` de la URL. Si viene, usa `ContenidoDAO.getByGenero(genero)`;
   si no, `ContenidoDAO.getAll()`.
2. Agrupa el resultado en un `LinkedHashMap<String, List<...>>` por género
   (mantiene el orden porque el `ORDER BY genero` ya viene de la BD) →
   de ahí salen los carruseles (`.content-section` + `.carousel` por cada
   género).
3. Calcula `favIds` con `FavoritoDAO.getIds(perfil)` para saber qué tarjetas
   pintar como favoritas.
4. Elige el *hero*: primer título cuyo género coincida con `cat_fav` del
   perfil; si no hay coincidencia, el primero de la lista.
5. Pinta los chips de género con `ContenidoDAO.getGeneros()`, marcando
   `active` el que esté seleccionado (o "Todos" si no hay filtro).

**Flujo AJAX (POST, `action=toggle`, módulo 2B):**
1. El botón ♥/♡ de cada tarjeta llama a `toggleFav(btn, id)` en JS, que hace
   `fetch()` con `perfil` + `id` por `x-www-form-urlencoded`.
2. El servidor revalida que el perfil pertenezca al cliente en sesión
   (misma consulta de seguridad que en el GET).
3. Llama a `FavoritoDAO.toggle(...)` y responde JSON:
   `{"favorito": true|false}` o `{"error": "..."}`.
4. El JS actualiza la clase `favorito` del botón y su ícono/texto **sin
   recargar la página** (importante: no usa `<form action=... method=post>`
   como la versión PHP original, sino AJAX real).

## 5. `favoritos.jsp` — Lista de favoritos (2C)

**Guardias:** iguales a `repertorio.jsp` (sesión + perfil válido).

**Flujo de renderizado (GET):**
1. Trae `perfilNombre` y `avatar` del perfil para el encabezado.
2. `FavoritoDAO.getContenido(perfil)` trae el detalle completo (título,
   género, imagen, fecha) para pintar la grilla `.favorites-grid`.
3. Si la lista está vacía, muestra un estado vacío con botón "Explorar
   catálogo" en vez de una grilla en blanco.

**Flujo AJAX (POST, `action=quitar`):**
1. El botón "Quitar" llama a `quitarFav(btn, id)`, que hace `fetch()` a la
   misma página con `action=quitar`.
2. El servidor valida el perfil y llama a `FavoritoDAO.remove(...)`.
3. En el cliente, la tarjeta se desvanece (`opacity`/`transform` con
   `setTimeout`) y se elimina del DOM; luego `actualizarContador()`
   recalcula el texto "N títulos guardados". Si queda en 0, recarga la
   página para mostrar el estado vacío.

## 6. Seguridad y buenas prácticas aplicadas

- **SQL Injection:** todo el acceso a datos usa `PreparedStatement` con `?`,
  nunca concatenación de strings.
- **XSS:** `esc()` (helper declarado en cada JSP) escapa `& < > " '` antes de
  imprimir cualquier dato que venga de la BD (`titulo`, `genero`, etc.).
- **IDOR (acceso a datos de otro perfil):** antes de leer/tocar favoritos,
  ambos JSP comprueban `SELECT 1 FROM usuarios WHERE perfil_key=? AND
  cliente_id=?` con el `clienteId` de la sesión, no el que mande el cliente.
- **No hay duplicados en `favs`:** `FavoritoDAO.toggle()` siempre comprueba
  existencia antes de insertar (ver sección 3).
- **Manejo de errores:** las excepciones no se muestran al usuario
  (`e.getMessage()` solo va a `System.err`); el usuario ve un JSON de error
  genérico o la página sigue con listas vacías en vez de un stack trace.

## 7. Qué clases de `estilos_cinemax.css` usa este módulo

El CSS está en `WebContent/css/estilos_cinemax.css` y usa variables CSS
(`:root`) para la paleta "Aurora" verde esmeralda (`--brand`, `--brand-grad`,
`--brand-glow`, `--surface`, `--cinemax-dark`, etc.). Ninguna de las clases
de abajo está definida *dentro* del JSP: viven todas en ese único archivo,
compartido con el resto del sitio.

**Navbar (ambas páginas):**
- `.navbar`, `.cinemax-logo`, `.nav-links`, `.nav-links a`, `.nav-links
  a.active`, `.user-icon` — barra superior con logo, enlaces (Inicio / Mis
  Favoritos / Mi Avance / Mi Cuenta) y la burbuja con la inicial del perfil.

**Botones genéricos (ambas páginas):**
- `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-outline` — usados en "Ver
  en YouTube", "Agregar"/"En favoritos" del hero, "Explorar catálogo", etc.

**Solo `repertorio.jsp`:**
- `.hero`, `.hero-backdrop`, `.hero-inner`, `.hero-content`, `.hero-badge`,
  `.hero-title`, `.hero-sub`, `.hero-buttons`, `.hero-poster` — sección
  destacada superior con el título del género favorito del perfil.
- `.genre-filter`, `.chip`, `.chip.active` — barra de chips para filtrar por
  género (2A).
- `.content-section`, `.section-title` — cada bloque "Género → carrusel".
- `.carousel`, `.carousel-item` — fila horizontal con scroll y las tarjetas
  de contenido.
- `.favorite-btn`, `.favorite-btn.favorito` — botón ♥/♡ sobre cada tarjeta
  (2B); el estado `.favorito` cambia el fondo al degradado de marca y le
  agrega el brillo (`--brand-glow`).
- `.card-overlay`, `.card-title`, `.card-play` — overlay con el título que
  aparece al pasar el mouse sobre una tarjeta.

**Solo `favoritos.jsp`:**
- `.favorites-body` — ajusta el padding superior para no quedar debajo del
  navbar fijo.
- `.profile-header` — encabezado con avatar, nombre del perfil y contador
  de favoritos.
- `.favorites-grid` — grilla responsive (`repeat(auto-fill, minmax(280px,
  1fr))`) para las tarjetas de favoritos (2C).
- `.favorite-item`, `.favorite-item img` — cada tarjeta con su miniatura.
- `.favorite-overlay` — overlay oscuro con título, género y los botones
  "Ver en YouTube" / "Quitar", visible al pasar el mouse.

**Animaciones reutilizadas de `estilos_cinemax.css`** (declaradas como
`@keyframes` globales, no específicas de este módulo, pero usadas aquí):
`fadeIn`, `fadeInUp` (entrada del hero y de la grilla de favoritos),
`ringPulse` (pulso al marcar un favorito), `float` (flotación sutil del
poster del hero).

## 8. Diferencias clave frente al Cinemax original (PHP)

El Cinemax original (`Cinemax.zip`) tenía `repertorio.php` / `favoritos.php`
con una lógica más simple. Este módulo JSP la mejora en varios puntos:

| Aspecto | PHP original | JSP (este módulo) |
|---|---|---|
| Agregar/quitar favorito | `<form method="post">` que recarga toda la página | `fetch()` AJAX, sin recargar |
| Filtro de catálogo | No existe (solo "Populares" + género favorito fijo) | Filtro por cualquier género vía chips (2A) |
| Duplicados en `favs` | Verificaba con `COUNT(*)` antes de insertar (igual de correcto) | Igual, pero centralizado en `FavoritoDAO.toggle()` reutilizable |
| Autorización de perfil | Confiaba en `$_SESSION['perfilKey']` sin validar contra el cliente | Valida `perfil_key` + `cliente_id` en cada acción |
| SQL | PDO con parámetros (ya seguro) | `PreparedStatement` con parámetros (equivalente en Java) |

---

Este documento es explicativo/técnico. Para instrucciones de dónde pegar los
archivos en Eclipse y cómo probar el flujo paso a paso, ver
`README_PERSONA3.md`.
