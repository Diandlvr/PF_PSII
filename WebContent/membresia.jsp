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
    // Persona 4 - Membresía
    // En producción, clienteId viene del login.
    // Para probar mientras login no esté listo: membresia.jsp?clienteId=1
    // ------------------------------------------------------------
    Integer clienteId = leerId(session.getAttribute("clienteId"));
    boolean modoPrueba = false;

    if (clienteId == null) {
        clienteId = leerId(request.getParameter("clienteId"));
        if (clienteId != null) {
            session.setAttribute("clienteId", clienteId);
            if (session.getAttribute("userName") == null) {
                session.setAttribute("userName", "Usuario demo");
            }
            modoPrueba = true;
        }
    }

    String mensaje = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String tipo = request.getParameter("tipoMembresia");

        if (clienteId == null) {
            mensaje = "Debes iniciar sesión antes de elegir una membresía.";
        } else if (!MembresiaDAO.seleccionar(tipo)) {
            mensaje = "Tipo de membresía inválido.";
        } else {
            session.setAttribute("tipoMembresia", tipo);

            if ("regular".equalsIgnoreCase(tipo)) {
                response.sendRedirect("usuarios.jsp");
                return;
            }

            if ("premium".equalsIgnoreCase(tipo)) {
                response.sendRedirect("pago.jsp");
                return;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Seleccionar Membresía - CinemaxPlus</title>
    <link rel="stylesheet" href="css/estilos_cinemax.css">
    <style>
        body.membership-body {
            min-height: 100vh;
            background: radial-gradient(circle at top, #2b2b2b 0%, #141414 50%, #000 100%);
            color: #fff;
        }
        .membership-container {
            max-width: 1050px;
            margin: 0 auto;
            padding: 50px 25px;
            text-align: center;
        }
        .membership-title {
            font-size: 2.5rem;
            margin: 20px 0 10px;
        }
        .membership-subtitle {
            color: #b3b3b3;
            margin-bottom: 30px;
        }
        .membership-options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }
        .membership-card {
            background: rgba(30, 30, 30, 0.95);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 14px;
            padding: 30px;
            box-shadow: 0 12px 35px rgba(0,0,0,0.45);
            text-align: left;
        }
        .membership-card.featured {
            border: 2px solid #e50914;
            transform: scale(1.02);
        }
        .membership-name {
            font-size: 1.7rem;
            margin-bottom: 10px;
        }
        .membership-price {
            font-size: 2rem;
            font-weight: bold;
            margin: 15px 0;
        }
        .membership-price span {
            font-size: 1rem;
            color: #b3b3b3;
        }
        .membership-features {
            margin: 20px 0 25px 20px;
            line-height: 1.9;
            color: #e5e5e5;
        }
        .membership-card .btn {
            width: 100%;
            text-align: center;
            border: 0;
            font-size: 1rem;
        }
        .alert {
            background: rgba(229, 9, 20, 0.15);
            border: 1px solid rgba(229, 9, 20, 0.7);
            color: #fff;
            padding: 12px;
            border-radius: 8px;
            margin: 20px auto;
            max-width: 620px;
        }
        .test-links {
            margin-top: 20px;
            color: #b3b3b3;
        }
        .test-links a { color: white; }
    </style>
</head>
<body class="membership-body">
    <div class="membership-container">
        <div class="cinemax-logo" style="margin:0 auto;"></div>
        <h1 class="membership-title">Elige tu membresía</h1>
        <p class="membership-subtitle">Selecciona el plan que deseas usar en CinemaxPlus.</p>

        <% if (mensaje != null) { %>
            <div class="alert"><%= esc(mensaje) %></div>
        <% } %>

        <% if (clienteId == null) { %>
            <div class="alert">
                No hay cliente activo en sesión. Primero debe funcionar el login.<br>
                Para probar esta pantalla temporalmente puedes abrir:
                <strong>membresia.jsp?clienteId=1</strong>
            </div>
        <% } else { %>
            <% if (modoPrueba) { %>
                <p class="test-links">Modo prueba activo con clienteId: <strong><%= clienteId %></strong></p>
            <% } %>

            <div class="membership-options">
                <div class="membership-card">
                    <h3 class="membership-name">Regular</h3>
                    <div class="membership-price">$0 <span>/mes</span></div>
                    <ul class="membership-features">
                        <li>Acceso a todo el catálogo</li>
                        <li>Calidad estándar 720p</li>
                        <li>Anuncios incluidos</li>
                        <li>1 dispositivo a la vez</li>
                    </ul>
                    <form action="membresia.jsp" method="post">
                        <input type="hidden" name="tipoMembresia" value="regular">
                        <button type="submit" class="btn btn-secondary">Seleccionar Regular</button>
                    </form>
                </div>

                <div class="membership-card featured">
                    <h3 class="membership-name">Premium</h3>
                    <div class="membership-price">$9.99 <span>/mes</span></div>
                    <ul class="membership-features">
                        <li>Calidad Ultra HD 4K</li>
                        <li>Sin anuncios</li>
                        <li>4 dispositivos simultáneos</li>
                        <li>Descargas offline</li>
                    </ul>
                    <form action="membresia.jsp" method="post">
                        <input type="hidden" name="tipoMembresia" value="premium">
                        <button type="submit" class="btn btn-primary">Seleccionar Premium</button>
                    </form>
                </div>
            </div>
        <% } %>
    </div>
</body>
</html>
