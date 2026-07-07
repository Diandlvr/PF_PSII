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
    <link rel="icon" type="image/x-icon" href="favicon.ico">
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
        
        <section class="news-section">

    <h2>Noticias e Información</h2>

    <div class="news-layout">

        <!-- VIDEO -->

        <div class="video-box">

            <h3>Video destacado</h3>

            <iframe
                src="https://www.youtube.com/embed/d9MyW72ELq0"
                allowfullscreen>
            </iframe>

            <a href="#" target="_blank">
                Ver en YouTube
            </a>

        </div>

        <!-- NOTICIAS -->

        <div class="articles">

            <div class="news-card">

                <h3>Avatar 3 presenta su primer avance oficial</h3>

                <p>
                    James Cameron mostró nuevas imágenes de Avatar 3,
                    revelando escenarios nunca antes vistos y nuevos
                    personajes que llegarán a la gran pantalla.
                </p>

                <a href="#">
                    Leer más
                </a>

            </div>

            <div class="news-card">

                <h3>Los estrenos más esperados del próximo año</h3>

                <p>
                    Marvel, DC y otros grandes estudios anunciaron las
                    películas que llegarán próximamente a los cines y
                    plataformas de streaming.
                </p>

                <a href="#">
                    Leer más
                </a>

            </div>

        </div>

    </div>

</section>

    </div>

    <footer style="position: absolute; bottom: 0; width: 100%; background: transparent; border: none;">
        <p style="color: var(--cinemax-gray-medium);">&copy; 2025 CinemaxPlus Inc. &mdash;
          <a href="contactanos.jsp" style="color:var(--brand); text-decoration:none;">Nuestro Equipo</a>
        </p>
    </footer>

</body>
</html>
