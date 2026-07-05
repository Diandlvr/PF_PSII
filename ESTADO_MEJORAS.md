# Estado de mejoras — Auditoría QA + UI/UX (CinemaxPlus)

> Auditoría hecha revisando TODO el código (11 JSP, 7 clases Java, CSS, SQL).
> Actualizar este archivo al completar cada punto para retomar en cualquier sesión.
> Última actualización: 2026-07-04

## Qué ya funciona (no tocar sin razón)

- Login con hash SHA-256 + salt, migración automática de cuentas legacy en texto plano (`PasswordUtil`, `login.jsp`).
- Registro con verificación por correo (token UUID, `EmailUtil`, `verificar.jsp`, reenvío de correo).
- Perfiles por cliente (`usuarios.jsp`) con avatares y modal.
- Repertorio con hero, filtro por género, carruseles y favoritos AJAX (valida que el perfil pertenezca al cliente — bien hecho).
- Favoritos por perfil (`favoritos.jsp` + `FavoritoDAO`).
- Membresía/pago simulado (Persona 4) y reportes de cuenta y avance (Personas 4 y 5).
- `repertorio.jsp` y `favoritos.jsp` ya guardan `perfilKey` en sesión → el pendiente de "Persona 2" del GUIA_PERSONA5 **ya está resuelto**.

---

## 🔴 CRÍTICOS (rompen funcionalidad o seguridad — arreglar primero)

- [ ] **1. `membresia.jsp` NO COMPILA.** Línea 159 usa `modoPrueba` que nunca se declara → error 500 al abrir la página. Eliminar ese bloque `<% if (modoPrueba) ... %>` (y de paso el bloque muerto `if (clienteId == null)` de la línea 152, inalcanzable porque arriba ya se redirige a login).
- [ ] **2. Bypass de login por "modo prueba".** `reporte_cuenta.jsp?clienteId=1` y `pago.jsp?clienteId=1` ESCRIBEN `clienteId` en la sesión sin contraseña → cualquiera se convierte en cualquier cliente. El login ya funciona: quitar ambos modos prueba y redirigir a `login.jsp` si no hay sesión.
- [ ] **3. Enlace de verificación hardcodeado.** `EmailUtil.java:59` arma `http://localhost:8080/PF_PSII_JSP/verificar.jsp`. Hoy coincide con el nombre Eclipse (`PF_PSII_JSP`), pero las guías/equipo usan `CinemaxPlus` — si alguien despliega con otro nombre, ningún correo de verificación funciona. Pasar la URL base desde el JSP: `EmailUtil.enviarConfirmacion(email, nombre, token, baseUrl)` con `baseUrl = request.getRequestURL()` recortado + `request.getContextPath()`.
- [ ] **4. Credenciales reales dentro del repo (¡antes del primer commit!).**
  - `src/mail.properties` y `WebContent/WEB-INF/classes/mail.properties` contienen un App Password real de Gmail.
  - `database_mariadb.sql` línea 32 tiene contraseñas reales en texto plano (cliente 4).
  - Acción: crear `.gitignore` (mail.properties, `build/`), agregar `mail.properties.example` (el que `EmailUtil` ya menciona pero no existe), **rotar el App Password** en Gmail, y cambiar las contraseñas de prueba del SQL por dummies.

## 🟠 FUNCIONALES / QA (bugs que un usuario normal puede disparar)

- [ ] **5. XSS almacenado en `usuarios.jsp`.** El nombre del perfil se imprime sin escapar (`<%= pNombre %>`) y se inyecta en `onclick="...'<%= pKey %>'..."`. Un perfil llamado `<script>...` ejecuta JS. Usar el mismo `esc()` que ya existe en otras páginas + escapar en atributos JS.
- [ ] **6. `e.getMessage()` mostrado al usuario** en login, registro, usuarios y en los JSON de AJAX (repertorio/favoritos). Filtra detalles internos (SQL, rutas). Mostrar mensaje genérico y loguear el detalle en servidor.
- [ ] **7. Falta `request.setCharacterEncoding("UTF-8")`** antes de leer POST en `login.jsp`, `registro.jsp`, `usuarios.jsp`, `membresia.jsp`, `pago.jsp` (repertorio y favoritos sí lo hacen). Síntoma: nombres con ñ/acentos se guardan corruptos.
- [ ] **8. Eliminar perfil por GET sin protección.** `usuarios.jsp?eliminar=KEY` borra con un solo clic de un enlace (sin CSRF, cacheable/prefetch). Cambiar a POST con formulario. Además deja huérfanos en `favs` y `progreso`: borrar también esas filas.
- [ ] **9. Membresía vencida aparece como activa.** `ReporteDAO.getMembresiaActual()` toma la más reciente sin comparar `fecha_vencimiento` con hoy. El badge "premium" se muestra aunque venció. Validar vigencia (y decidir qué pasa al vencer).
- [ ] **10. Sin autenticación central.** Cada JSP repite el guard a mano y `reporte_avance.jsp` no exige sesión (solo muestra aviso). Ideal: un `Filter` en `web.xml` que proteja todo menos login/registro/verificar/css/img.
- [ ] **11. Crash potencial en navbar.** `repertorio.jsp:123` y `favoritos.jsp:96` hacen `.substring(0,1)` sobre el nombre del perfil → excepción si quedara vacío en BD. Proteger con un default ("?").
- [ ] **12. `pago.jsp` no valida la expiración.** Acepta `99/99` o vacío de formato; solo tarjeta y CVV se validan. Validar patrón MM/AA y que no esté vencida (es simulado, pero es lo que evaluaría un QA).

## 🟡 UI/UX (revisión como diseñador)

- [ ] **13. Navegación rota entre secciones.** `reporte_avance.jsp` enlaza a `repertorio.jsp`/`favoritos.jsp` SIN `?perfil=` → repertorio rebota a la pantalla de perfiles y se pierde el contexto. A la inversa, repertorio/favoritos NO tienen enlace a "Mi avance". Arreglo: como `perfilKey` ya vive en la sesión, hacer que repertorio/favoritos la usen como fallback cuando no llegue el parámetro, y unificar los enlaces del navbar en las 4 páginas internas.
- [ ] **14. Tres navbars distintos.** `navbar` (repertorio/favoritos/avance) vs `report-header` (reporte_cuenta) con estilos propios embebidos. Unificar en un solo navbar (idealmente un include `navbar.jspf`).
- [ ] **15. Dos identidades visuales.** Login/registro/perfiles/repertorio usan la marca verde (#2ecc71, fondos verdosos); membresía/pago/reporte_cuenta usan rojo Netflix (#e50914) y fondo gris — se sienten de otra app. Migrar las páginas de Persona 4 a las variables del CSS global (`--brand`, `--surface`...).
- [ ] **16. `index.jsp` es una página de diagnóstico** ("Fase 0 - Migración... conexión BD OK") y es el welcome-file. Para la entrega: landing real con botones "Iniciar sesión / Registrarse" (el CSS `landing-*` ya existe) o redirect a login.
- [ ] **17. La membresía está huérfana en el flujo.** Tras registro/login nunca se ofrece elegir plan; `membresia.jsp` solo es alcanzable desde el header de reporte_cuenta. Propuesta: tras el primer login (cliente sin membresía) pasar por membresía antes de perfiles, o al menos enlazarla en el navbar.
- [ ] **18. Modo prueba visible en `reporte_avance.jsp`.** Los botones "1_carlos / 1_jamir / 4_juan" y el parámetro `?perfil=` deben quitarse para la entrega (la sesión ya funciona). Sin perfil → redirigir a `usuarios.jsp`.
- [ ] **19. Accesibilidad.** Botones de favorito solo-ícono sin `aria-label`; modal de perfil sin foco inicial ni focus-trap; `confirm()` nativo para eliminar perfil (inconsistente con el diseño); contrastes bajos (#555/#444 sobre negro); inputs de pago sin `inputmode="numeric"`, `pattern` ni `autocomplete="cc-number"`.
- [ ] **20. Detalles de formulario de pago.** Sin auto-formato "1234 5678..." al escribir, CVV acepta letras hasta el submit, sin resumen del plan que se está pagando ($9.99 Premium aparece solo en el botón).

## 🧹 Deuda técnica (si queda tiempo)

- [ ] **21.** `esc()` y `leerId()` copiados en 6 JSPs → mover a una clase `modelo.WebUtil` estática.
- [ ] **22.** El `esc()` de `reporte_avance.jsp` no escapa comillas simples (los demás sí) — unificar (se resuelve con el punto 21).
- [ ] **23.** Repo sin commits: hacer commit inicial **después** del punto 4 (.gitignore + secretos fuera).
- [ ] **24.** Tablas MyISAM sin FKs (huérfanos posibles en favs/progreso/usuarios/membresias). Migrar a InnoDB + FK es opcional para el curso; documentarlo como limitación.

## Orden recomendado de trabajo

1. Punto 4 (secretos) → commit inicial inmediato.
2. Puntos 1 y 2 (membresía compila, quitar bypass) — son los que un profesor encuentra en 2 minutos.
3. Punto 3 (link de verificación) + probar registro→correo→verificar→login completo.
4. Puntos 13, 18, 16 (navegación + limpiar modos prueba + landing) — mayor impacto visible.
5. Puntos 5–8 (XSS, encoding, mensajes de error, eliminar por POST).
6. Resto de UI/UX (14, 15, 17, 19, 20) y deuda técnica.
