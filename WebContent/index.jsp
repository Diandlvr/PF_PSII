<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    // Landing publica. Si ya hay sesion iniciada, vamos directo a los perfiles.
    if (session.getAttribute("clienteId") != null) {
        response.sendRedirect("usuarios.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaxPlus &ndash; Pel&iacute;culas y series sin l&iacute;mites</title>
    <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body class="landing-body">

    <div class="landing-overlay">

        <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"
             style="margin: 0 auto 24px;"></div>

        <div class="landing-text">
            <h1>Pel&iacute;culas y series sin l&iacute;mites</h1>
            <p>Todo el cine que te gusta, en un solo lugar. Crea tu cuenta y empieza a ver hoy.</p>
        </div>

        <div class="landing-buttons">
            <a href="registro.jsp" class="btn btn-primary btn-large">Reg&iacute;strate gratis</a>
            <a href="login.jsp" class="btn btn-outline btn-large">Iniciar sesi&oacute;n</a>
        </div>

    </div>

    <footer style="position: absolute; bottom: 0; width: 100%; background: transparent; border: none;">
        <p style="color: var(--cinemax-gray-medium);">&copy; 2025 CinemaxPlus Inc.</p>
    </footer>

</body>
</html>
