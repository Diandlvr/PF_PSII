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
%>
<%
    // ------------------------------------------------------------
    // Persona 4 - Pago premium simulado
    // No hay gateway real: solo validación de formato.
    // ------------------------------------------------------------
    Integer clienteId = leerId(session.getAttribute("clienteId"));
    String tipoMembresia = (String) session.getAttribute("tipoMembresia");

    // Modo de prueba temporal: pago.jsp?clienteId=1
    if (clienteId == null) {
        clienteId = leerId(request.getParameter("clienteId"));
        if (clienteId != null) {
            session.setAttribute("clienteId", clienteId);
            session.setAttribute("tipoMembresia", "premium");
            tipoMembresia = "premium";
        }
    }

    String mensaje = null;
    boolean pagoExitoso = false;

    if (clienteId == null) {
        mensaje = "Debes iniciar sesión antes de pagar la membresía.";
    } else if (tipoMembresia != null && !"premium".equalsIgnoreCase(tipoMembresia)) {
        response.sendRedirect("membresia.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod()) && clienteId != null) {
        String numeroTarjeta = request.getParameter("numeroTarjeta");
        String nombreTitular = request.getParameter("nombreTitular");
        String fechaExpiracion = request.getParameter("fechaExpiracion");
        String cvv = request.getParameter("cvv");

        if (numeroTarjeta == null || numeroTarjeta.trim().isEmpty()
                || nombreTitular == null || nombreTitular.trim().isEmpty()
                || fechaExpiracion == null || fechaExpiracion.trim().isEmpty()
                || cvv == null || cvv.trim().isEmpty()) {
            mensaje = "Completa todos los campos.";
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
    <link rel="stylesheet" href="css/estilos_cinemax.css">
    <style>
        body.payment-body {
            min-height: 100vh;
            background: radial-gradient(circle at top, #2b2b2b 0%, #141414 50%, #000 100%);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px;
        }
        .payment-container {
            width: 100%;
            max-width: 540px;
            background: rgba(20, 20, 20, 0.94);
            border: 1px solid rgba(255,255,255,0.12);
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

            <form action="pago.jsp" method="post">
                <div class="form-group">
                    <label>Número de tarjeta</label>
                    <input type="text" name="numeroTarjeta" placeholder="1234 5678 9012 3456" maxlength="19" required>
                </div>

                <div class="form-group">
                    <label>Nombre del titular</label>
                    <input type="text" name="nombreTitular" placeholder="Nombre como aparece en la tarjeta" required>
                </div>

                <div class="payment-row">
                    <div class="form-group">
                        <label>Expiración</label>
                        <input type="text" name="fechaExpiracion" placeholder="MM/AA" maxlength="5" required>
                    </div>
                    <div class="form-group">
                        <label>CVV</label>
                        <input type="text" name="cvv" placeholder="123" maxlength="3" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%; margin-top:15px;">
                    💳 Validar pago $9.99
                </button>
            </form>

            <p style="color:#777; text-align:center; margin-top:18px; font-size:13px;">
                Prueba rápida: cualquier tarjeta con 16 dígitos funciona. Ejemplo: 1234 5678 9012 3456.
            </p>
        <% } %>
    </div>
</body>
</html>
