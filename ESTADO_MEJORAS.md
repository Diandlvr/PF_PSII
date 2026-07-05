# Estado de mejoras — Auditoría QA + UI/UX (CinemaxPlus)

> Auditoría hecha revisando TODO el código (11 JSP, 7 clases Java, CSS, SQL).
> Actualizar este archivo al completar cada punto para retomar en cualquier sesión.
> Última actualización: 2026-07-04 — **sesión de correcciones aplicada** (ver resumen al final).

## Qué ya funciona

- Login con hash SHA-256 + salt, migración automática de cuentas legacy en texto plano.
- Registro con verificación por correo (token UUID, reenvío incluido).
- Perfiles por cliente con avatares; repertorio con favoritos AJAX; reportes de cuenta y avance.
- `repertorio.jsp`/`favoritos.jsp` guardan `perfilKey` en sesión → el pendiente de "Persona 2" está resuelto.
- Flujo de membresía conectado: primer login sin plan → membresía → (pago si Premium) → perfiles.

---

## 🔴 CRÍTICOS

- [x] **1. `membresia.jsp` no compilaba** (`modoPrueba` sin declarar + bloque muerto). Corregido.
- [x] **2. Bypass de login por "modo prueba".** Eliminado de `reporte_cuenta.jsp` y `pago.jsp`; ahora redirigen a `login.jsp` sin sesión.
- [x] **3. Enlace de verificación hardcodeado.** `EmailUtil.enviarConfirmacion()` ahora recibe la URL base real desde el request (login y registro actualizados).
- [x] **4. Credenciales en el repo.** `.gitignore` creado, ambos `mail.properties` fuera del tracking, `mail.properties.example` agregado, contraseña real reemplazada por dummy en `database_mariadb.sql`. Commit hecho.
  - [ ] ⚠️ **PENDIENTE DEL USUARIO: rotar el App Password de Gmail** — el viejo quedó en el historial de GitHub (commit "cambios"). Crear uno nuevo en https://myaccount.google.com/apppasswords y actualizar el `mail.properties` local (que ya no se sube).

## 🟠 FUNCIONALES / QA

- [x] **5. XSS almacenado en `usuarios.jsp`.** Nombre de perfil y perfil_key ahora escapados (esc + escJs + URLEncoder).
- [x] **6. `e.getMessage()` al usuario.** Reemplazado por mensajes genéricos + `System.err` en login, registro, usuarios y AJAX de repertorio/favoritos.
- [x] **7. `setCharacterEncoding("UTF-8")`** agregado en login, registro, usuarios, membresía y pago.
- [x] **8. Eliminar perfil ahora es POST** (formulario oculto + confirmación) y borra también sus `favs` y `progreso`; limpia el perfil de la sesión si era el activo.
- [x] **9. Membresía vencida** ya no aparece como activa: `reporte_cuenta.jsp` muestra "(vencida)" y "Venció:" cuando corresponde.
- [x] **10. Filtro de autenticación central.** `modelo.AuthFilter` + mapeo en `web.xml` para las 7 páginas privadas.
- [x] **11. Crash de `substring`** protegido en repertorio y favoritos.
- [x] **12. `pago.jsp` valida expiración** (formato MM/AA y tarjeta no vencida).

## 🟡 UI/UX

- [x] **13. Navegación.** Repertorio y favoritos aceptan el perfil desde la sesión (ya no se pierde al navegar); enlace "Mi Avance" agregado a los navbars.
- [x] **14. Navbar unificado.** `reporte_cuenta.jsp` y `reporte_avance.jsp` usan el mismo `.navbar` que repertorio/favoritos.
- [x] **15. Paleta unificada.** Membresía, pago y reporte de cuenta migrados del rojo Netflix a las variables verdes de la marca (`--brand`, `--surface`...).
- [x] **16. `index.jsp` es una landing real** (logo, claim, botones Registrarse/Iniciar sesión; redirige a perfiles si ya hay sesión).
- [x] **17. Membresía integrada al flujo.** Primer login sin plan → `membresia.jsp`; elegir Regular registra la membresía gratuita (`MembresiaDAO.registrarRegular`); enlace en navbar de Mi Cuenta.
- [x] **18. Modo prueba de `reporte_avance.jsp` eliminado.** Guard real: sin login → login.jsp, sin perfil → usuarios.jsp.
- [x] **19. Accesibilidad (parcial).** aria-labels en botones de favorito y eliminar perfil, foco inicial en el modal, `inputmode/pattern/autocomplete` en pago, contrastes #444/#555 subidos a #7e948b.
  - [ ] Pendiente menor: reemplazar `confirm()` nativo por modal propio; focus-trap completo en el modal.
- [x] **20. Formulario de pago.** Auto-formato de tarjeta (grupos de 4), barra automática en MM/AA, CVV solo dígitos, resumen del plan Premium $9.99 antes del formulario.

## 🧹 Deuda técnica

- [ ] **21.** `esc()`/`leerId()` duplicados en varios JSP → mover a una clase `modelo.WebUtil` (opcional).
- [x] **22.** El `esc()` de `reporte_avance.jsp` ahora escapa comillas simples como los demás.
- [x] **23.** Repos: el trabajo pendiente + seguridad quedó commiteado en el repo real `PF_PSII` (remoto github.com/Diandlvr/PF_PSII). Ojo: hay un repo git "envoltorio" sin commits en la carpeta padre `PFPSII/` que solo confunde; se puede borrar su `.git` cuando quieran.
- [ ] **24.** Tablas MyISAM sin FKs — limitación documentada, migrar a InnoDB es opcional para el curso.

---

## Resumen de la sesión 2026-07-04

Se aplicaron los puntos 1–20 y 22 (todo salvo lo marcado pendiente). Los `.java` compilan
contra servlet-api de Tomcat (`javac` OK). **Falta probar en Tomcat**: flujo completo
registro → correo → verificar → login → membresía → perfiles → repertorio → favoritos →
avance → cuenta → pago Premium. Recordar en Eclipse: refrescar el proyecto (F5) y
Clean + Start del servidor para que compile `AuthFilter` y los JSP nuevos.

**Acción manual pendiente del usuario:** rotar el App Password de Gmail (punto 4).
