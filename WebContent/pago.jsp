<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.MembresiaDAO" %>
<%!
    private Integer leerId(Object valor) {
        if (valor == null) return null;
        try {
            return Integer.valueOf(String.valueOf(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    /* true si MM/AA ya pasó respecto al mes actual. */
    private boolean tarjetaVencida(String mmaa) {
        java.util.Calendar hoy = java.util.Calendar.getInstance();
        int anio = 2000 + Integer.parseInt(mmaa.substring(3));
        int mes  = Integer.parseInt(mmaa.substring(0, 2));
        int anioHoy = hoy.get(java.util.Calendar.YEAR);
        int mesHoy  = hoy.get(java.util.Calendar.MONTH) + 1;
        return anio < anioHoy || (anio == anioHoy && mes < mesHoy);
    }
%>
<%
    // ------------------------------------------------------------
    // Persona 4 - Pago premium simulado
    // No hay gateway real: solo validación de formato.
    // ------------------------------------------------------------
    request.setCharacterEncoding("UTF-8");
    Integer clienteId = leerId(session.getAttribute("clienteId"));
    String tipoMembresia = (String) session.getAttribute("tipoMembresia");

    if (clienteId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    // Solo se llega aqui tras elegir Premium en membresia.jsp
    if (tipoMembresia == null || !"premium".equalsIgnoreCase(tipoMembresia)) {
        response.sendRedirect("membresia.jsp");
        return;
    }

    String mensaje = null;
    boolean pagoExitoso = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String numeroTarjeta = request.getParameter("numeroTarjeta");
        String nombreTitular = request.getParameter("nombreTitular");
        String fechaExpiracion = request.getParameter("fechaExpiracion");
        String cvv = request.getParameter("cvv");

        if (numeroTarjeta == null || numeroTarjeta.trim().isEmpty()
                || nombreTitular == null || nombreTitular.trim().isEmpty()
                || fechaExpiracion == null || fechaExpiracion.trim().isEmpty()
                || cvv == null || cvv.trim().isEmpty()) {
            mensaje = "Completa todos los campos.";
        } else if (!fechaExpiracion.trim().matches("(0[1-9]|1[0-2])/\\d{2}")) {
            mensaje = "Fecha de expiración inválida. Usa el formato MM/AA.";
        } else if (tarjetaVencida(fechaExpiracion.trim())) {
            mensaje = "La tarjeta está vencida.";
        } else {
            mensaje = MembresiaDAO.procesarPagoPremium(clienteId, numeroTarjeta, cvv);
            pagoExitoso = mensaje != null && mensaje.toLowerCase().contains("pago exitoso");

            if (pagoExitoso) {
                response.setHeader("Refresh", "3; URL=usuarios.jsp");
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Procesar Pago - CinemaxPlus</title>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <link rel="stylesheet" href="css/estilos_cinemax.css">
    <style>
        /* Usa el fondo global de la marca definido en el CSS */
        body.payment-body {
            min-height: 100vh;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px;
        }
        .payment-container {
            width: 100%;
            max-width: 540px;
            background: rgba(12, 24, 19, 0.94);
            border: 1px solid var(--surface-border);
            border-radius: 14px;
            padding: 35px;
            box-shadow: 0 12px 35px rgba(0,0,0,0.5);
        }
        .payment-title {
            text-align: center;
            margin: 20px 0 10px;
        }
        .payment-note {
            color: #b3b3b3;
            text-align: center;
            margin-bottom: 25px;
            line-height: 1.5;
        }
        .payment-row {
            display: grid;
            grid-template-columns: 1fr 120px;
            gap: 12px;
        }
        .alert {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 18px;
            text-align: center;
        }
        .alert.error {
            background: rgba(229, 9, 20, 0.15);
            border: 1px solid rgba(229, 9, 20, 0.7);
        }
        .alert.success {
            background: rgba(0, 170, 80, 0.15);
            border: 1px solid rgba(0, 220, 120, 0.7);
        }
        .success-message {
            text-align: center;
            padding: 25px 10px;
        }
        .success-message h1 {
            color: #00e676;
            margin-bottom: 12px;
        }
        .form-group input {
            border: 1px solid rgba(255,255,255,0.15);
        }
        @media (max-width: 600px) {
            .payment-row { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body class="payment-body">
    <div class="payment-container">
        <div class="cinemax-logo" style="margin:0 auto;"></div>

        <% if (pagoExitoso) { %>
            <div class="success-message">
                <h1>¡Pago exitoso! ✅</h1>
                <p><%= esc(mensaje) %></p>
                <p style="color:#b3b3b3; margin-top:10px;">Redirigiendo a perfiles en 3 segundos...</p>
                <br>
                <a href="usuarios.jsp" class="btn btn-primary">Continuar ahora</a>
                <a href="reporte_cuenta.jsp" class="btn btn-secondary">Ver reporte de cuenta</a>
            </div>
        <% } else { %>
            <h1 class="payment-title">Información de pago</h1>
            <p class="payment-note">
                Pago premium simulado. No se cobra dinero real ni se conecta con bancos.
                Solo se valida tarjeta de 16 dígitos y CVV de 3 dígitos.
            </p>

            <% if (mensaje != null) { %>
                <div class="alert error"><%= esc(mensaje) %></div>
            <% } %>

            <div style="display:flex; justify-content:space-between; align-items:center;
                        background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.12);
                        border-radius:10px; padding:14px 18px; margin-bottom:22px;">
                <div>
                    <strong>Plan Premium</strong>
                    <div style="color:#b3b3b3; font-size:13px;">Facturación mensual, cancela cuando quieras</div>
                </div>
                <strong style="font-size:1.3rem;">$9.99<span style="font-size:0.85rem; color:#b3b3b3;">/mes</span></strong>
            </div>

            <form action="pago.jsp" method="post">
                <div class="form-group">
                    <label for="numeroTarjeta">Número de tarjeta</label>
                    <input type="text" id="numeroTarjeta" name="numeroTarjeta"
                           placeholder="1234 5678 9012 3456" maxlength="19" required
                           inputmode="numeric" autocomplete="cc-number">
                </div>

                <div class="form-group">
                    <label for="nombreTitular">Nombre del titular</label>
                    <input type="text" id="nombreTitular" name="nombreTitular"
                           placeholder="Nombre como aparece en la tarjeta" required
                           autocomplete="cc-name">
                </div>

                <div class="payment-row">
                    <div class="form-group">
                        <label for="fechaExpiracion">Expiración</label>
                        <input type="text" id="fechaExpiracion" name="fechaExpiracion"
                               placeholder="MM/AA" maxlength="5" required
                               inputmode="numeric" autocomplete="cc-exp"
                               pattern="(0[1-9]|1[0-2])/[0-9]{2}" title="Formato MM/AA">
                    </div>
                    <div class="form-group">
                        <label for="cvv">CVV</label>
                        <input type="text" id="cvv" name="cvv"
                               placeholder="123" maxlength="3" required
                               inputmode="numeric" autocomplete="cc-csc"
                               pattern="[0-9]{3}" title="3 dígitos">
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%; margin-top:15px;">
                    💳 Validar pago $9.99
                </button>
            </form>

            <script>
                // Auto-formato: tarjeta en grupos de 4, barra automática en MM/AA, CVV solo dígitos
                document.getElementById('numeroTarjeta').addEventListener('input', function() {
                    const digitos = this.value.replace(/\D/g, '').slice(0, 16);
                    this.value = digitos.replace(/(.{4})/g, '$1 ').trim();
                });
                document.getElementById('fechaExpiracion').addEventListener('input', function() {
                    const d = this.value.replace(/\D/g, '').slice(0, 4);
                    this.value = d.length > 2 ? d.slice(0, 2) + '/' + d.slice(2) : d;
                });
                document.getElementById('cvv').addEventListener('input', function() {
                    this.value = this.value.replace(/\D/g, '').slice(0, 3);
                });
            </script>

            <p style="color:#777; text-align:center; margin-top:18px; font-size:13px;">
                Prueba rápida: cualquier tarjeta con 16 dígitos funciona. Ejemplo: 1234 5678 9012 3456.
            </p>
        <% } %>
    </div>
</body>
</html>
