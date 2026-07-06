# Guía Persona 5 — Avance de reproducción (Módulos 3A + 3C)

Guía para dejar funcionando la tabla `progreso` y el reporte de avance
(`reporte_avance.jsp`). Sirve como pasos a seguir **y** como evidencia de entrega.

> **Entorno real de esta máquina:** NO se usa XAMPP. Está instalado **MySQL Server 8.0**
> como servicio de Windows (`MySQL80`) en el puerto 3306, y el root quedó **sin
> contraseña** (`ALTER USER 'root'@'localhost' IDENTIFIED BY ''`), que es justo lo que
> asume `ConexionDB.java`. Por eso no hubo que tocar `ConexionDB`. Connector/J ya está
> en `WEB-INF/lib`.

> ✅ **En esta máquina la BD ya está importada y verificada** (6 tablas, `progreso`
> con 9 filas, columnas de login en `cliente`, 4 clientes verificados). Los Pasos 1–2
> solo hacen falta si se reinstala o se prueba en otro equipo.

---

## Paso 1 — Verificar que MySQL 8.0 está corriendo

1. El servicio **`MySQL80`** arranca solo con Windows. Para comprobarlo:
   `services.msc` → busca *MySQL80* → estado **En ejecución**.
2. Recuerda: root usa **contraseña vacía**. Si algún día le pones contraseña,
   habrá que reflejarla en `ConexionDB.java` (o en un `db.properties`).

---

## Paso 2 — Importar la base de datos (3 scripts, EN ORDEN)

> ⚠️ El proyecto creció: ya no basta con `progreso.sql`. Hay que importar **tres**
> scripts **en este orden**. Si te saltas el 3, el login falla por columnas
> faltantes (`verificado`, `password_salt`).

| Orden | Archivo | Qué hace |
|-------|---------|----------|
| 1º | `database_mariadb.sql` | Crea la BD y las 5 tablas base con datos. |
| 2º | `progreso.sql` | Crea la tabla `progreso` (avance) con datos de prueba. |
| 3º | `migration_fixes.sql` | Agrega columnas de verificación por correo y hashing. |

**Importar desde la línea de comandos** (PowerShell o CMD), en orden. La ruta del
cliente en esta máquina es `C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe`:

```powershell
cd "C:\Users\quint\OneDrive\Desktop\Nueva carpeta\PF_PSII"
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot < database_mariadb.sql
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot < progreso.sql
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot < migration_fixes.sql
```

(Como root no tiene contraseña, no se pasa `-p`.) También sirve **MySQL Workbench**:
abre cada `.sql` y ejecútalo con el rayo ⚡, en el mismo orden.

### Verificación rápida
```powershell
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -uroot cinemax_plus -e "SELECT COUNT(*) FROM progreso; SHOW COLUMNS FROM cliente LIKE 'password_salt';"
```
Debe devolver **9** (filas de `progreso`) y la fila de la columna `password_salt`.

> ⚠️ Ojo con `migration_fixes.sql`: MySQL 8.0 **no** soporta `ADD COLUMN IF NOT EXISTS`
> (eso es de MariaDB). El script ya fue reescrito para MySQL 8.0 (comprueba
> `information_schema`) y es seguro re-ejecutarlo. No hace falta el arreglo de
> collation `utf8mb4_0900` porque MySQL 8.0 sí soporta `utf8mb4_general_ci`.

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

## Paso 4 — Prueba final del flujo (5A)

El login ya es obligatorio (el modo `?perfil=` se eliminó). Se prueba con el flujo real.

1. Abre **http://localhost:8080/CinemaxPlus/**
2. **Iniciar sesión** con un cliente de prueba:
   - correo `carlos@gmail.com` · contraseña `123456`
3. Elige el perfil **Carlos** (`1_carlos`) en la pantalla de perfiles.
4. En el navbar entra a **Mi Avance**.

Deberías ver, para `1_carlos`:

| Película           | Avance esperado |
|--------------------|-----------------|
| The Dark Knight    | 100% (Terminada) |
| Mad Max: Fury Road | 75% |
| Forrest Gump       | ~28% |
| Top Gun: Maverick  | 0% |

Arriba, las 3 tarjetas resumen: **4 en curso · 1 terminada · ~51% promedio**.

### Estado vacío
Crea un perfil nuevo (que no tenga avances) y entra a **Mi Avance**: debe mostrar
"Este perfil todavía no ha comenzado a ver ninguna película" con botón al catálogo.

### Guard de sesión
Sin iniciar sesión, abre directo
`http://localhost:8080/CinemaxPlus/reporte_avance.jsp`: debe redirigir a `login.jsp`.
Logueado pero sin perfil elegido: debe redirigir a `usuarios.jsp`.

---

## Paso 5 — Checklist de la prueba integrada (5A)

Flujo completo a verificar de punta a punta (todos los módulos del equipo):

- [ ] Registro → correo de verificación → `verificar.jsp` → cuenta verificada
- [ ] Login con cuenta verificada
- [ ] Membresía (primer login) → Regular o Premium (pago simulado)
- [ ] Elegir/crear perfil → se guarda `perfilKey` en sesión
- [ ] Catálogo con filtro por género → agregar favorito
- [ ] Favoritos → listar y eliminar
- [ ] **Mi Avance** (mi módulo) → barras de progreso correctas
- [ ] **Mi Cuenta** → cliente + membresía + perfiles
- [ ] Logout → vuelve a la landing

---

## Resumen de lo que entrega la Persona 5

| Módulo | Archivo | Estado |
|--------|---------|--------|
| 3A Tabla progreso | `progreso.sql` | ✅ Hecho — importar con esta guía |
| 3C Reporte avance | `src/modelo/ReporteDAO.java` (`avance()`) | ✅ Hecho e integrado |
| 3C Reporte avance | `WebContent/reporte_avance.jsp` | ✅ Hecho (guard real + navbar unificado por el equipo) |
| 4D CSS | `css/estilos_cinemax.css` (barras + paleta unificada) | ✅ Hecho (equipo unificó paleta) |
| 5A Prueba final | prueba integrada en Tomcat | 🔜 Pendiente — seguir Pasos 1–5 de esta guía |

---

## Problemas comunes

| Síntoma | Causa / solución |
|---------|------------------|
| `No suitable driver found` | Connector/J falta en **Deployment Assembly**. |
| La página carga pero sale vacía ("no ha comenzado a ver...") | La tabla `progreso` no se importó, o se importó en otra BD. Revisa el Paso 2. |
| `Unknown collation` al importar | La BD base se creó con otra collation; avisa al equipo. |
| Error 404 en `reporte_avance.jsp` | El proyecto no se republicó. Server → Clean → Start. |
| Los estilos se ven planos (sin barras) | El navegador cacheó el CSS viejo: **Ctrl + F5** para recargar. |
