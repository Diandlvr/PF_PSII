# Persona 4 — Membresía, pago y reporte de cuenta

Archivos de esta entrega:

- `WebContent/membresia.jsp`
- `WebContent/pago.jsp`
- `WebContent/reporte_cuenta.jsp`
- `src/modelo/MembresiaDAO.java`
- `src/modelo/ReporteDAO.java`

## Dónde pegarlos

En el Dynamic Web Project de Eclipse:

```text
CinemaxPlus/
├── src/
│   └── modelo/
│       ├── MembresiaDAO.java
│       └── ReporteDAO.java
└── WebContent/
    ├── membresia.jsp
    ├── pago.jsp
    └── reporte_cuenta.jsp
```

Si tu Eclipse usa estructura nueva, cambia `src/modelo/` por `src/main/java/modelo/` y `WebContent/` por `src/main/webapp/`.

## Importante sobre ReporteDAO.java

`ReporteDAO.java` incluye el método `cuenta()` de Persona 4 y también deja el método `avance()` de Persona 5 para no borrar ese trabajo.

Si otra persona ya modificó `ReporteDAO.java`, no pegues el archivo completo a ciegas. Copia solo estas partes:

- `CuentaReporte`
- `MembresiaItem`
- `PerfilItem`
- `cuenta(int clienteId)`
- `cargarCliente(...)`
- `cargarMembresias(...)`
- `cargarPerfiles(...)`

## Prueba rápida sin login listo

Mientras la parte de login no esté terminada, puedes probar así:

```text
http://localhost:8080/CinemaxPlus/membresia.jsp?clienteId=1
http://localhost:8080/CinemaxPlus/pago.jsp?clienteId=1
http://localhost:8080/CinemaxPlus/reporte_cuenta.jsp?clienteId=1
```

## Datos de prueba para pago

El pago es simulado. Cualquier número con 16 dígitos funciona:

```text
Tarjeta: 1234 5678 9012 3456
CVV: 123
Expiración: 12/30
Nombre: cualquier nombre
```

## Qué hace el flujo

1. `membresia.jsp` permite elegir Regular o Premium.
2. Si el usuario elige Premium, se redirige a `pago.jsp`.
3. `pago.jsp` valida solo formato de tarjeta y CVV.
4. Si el formato es correcto, `MembresiaDAO.procesarPagoPremium()` inserta una fila en `membresias` con vencimiento a 1 mes.
5. `reporte_cuenta.jsp` muestra datos del cliente, membresía más reciente, historial de membresías y perfiles de la cuenta.

## Requisitos

- La base de datos debe llamarse `cinemax_plus`.
- Debe existir `ConexionDB.java` en el paquete `modelo`.
- MySQL Connector/J debe estar en Build Path y Deployment Assembly.
- El CSS debe estar en `WebContent/css/estilos_cinemax.css`.
