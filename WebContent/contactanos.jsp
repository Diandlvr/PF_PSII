<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Nuestro Equipo &ndash; CinemaxPlus</title>
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body class="team-body">

  <nav class="navbar">
    <a href="index.jsp" class="cinemax-logo"></a>
    <div class="nav-links">
      <a href="index.jsp">Inicio</a>
      <% if (session.getAttribute("clienteId") != null) {
           String pk = (String) session.getAttribute("perfilKey");
           String enc = pk != null ? java.net.URLEncoder.encode(pk, "UTF-8") : ""; %>
      <a href="repertorio.jsp<%= enc.isEmpty() ? "" : "?perfil=" + enc %>">Repertorio</a>
      <% } else { %>
      <a href="login.jsp">Iniciar sesi&oacute;n</a>
      <a href="registro.jsp">Registrarse</a>
      <% } %>
      <a href="contactanos.jsp" class="active">Nuestro Equipo</a>
    </div>
  </nav>

  <div class="team-header">
    <h1 class="team-title">Nuestro Equipo</h1>
    <p class="team-subtitle">Las personas detr&aacute;s de CinemaxPlus</p>
  </div>

  <div class="team-grid">

    <div class="team-card">
      <div class="team-photo">
        <img src="img/equipo/juan_pitti.jpg" alt="Juan Pitti">
      </div>
      <div class="team-name">Juan Pitti</div>
      <div class="team-cedula">2-755-783</div>
      <div class="team-role">Solutions Architect</div>
    </div>

    <div class="team-card">
      <div class="team-photo">
        <img src="img/equipo/virgilio_peff.jpg" alt="Virgilio Peff">
      </div>
      <div class="team-name">Virgilio Peff</div>
      <div class="team-cedula">8-1015-2026</div>
      <div class="team-role">Full Stack Developer</div>
    </div>

    <div class="team-card">
      <div class="team-photo">
        <img src="img/equipo/diego_perez.jpg" alt="Diego Perez">
      </div>
      <div class="team-name">Diego P&eacute;rez</div>
      <div class="team-cedula">8-1030-939</div>
      <div class="team-role">UX/UI Designer</div>
    </div>

    <div class="team-card">
      <div class="team-photo">
        <img src="img/equipo/eric_solis.jpg" alt="Eric Solis">
      </div>
      <div class="team-name">Eric Solis</div>
      <div class="team-cedula">8-1009-1180</div>
      <div class="team-role">QA Engineer</div>
    </div>

    <div class="team-card">
      <div class="team-photo">
        <img src="img/equipo/jonathan_quintero.jpg" alt="Jonathan Quintero">
      </div>
      <div class="team-name">Jonathan Quintero</div>
      <div class="team-cedula">8-1015-1974</div>
      <div class="team-role">Data Analyst</div>
    </div>

  </div>

  <footer>
    <p>&copy; 2025 CinemaxPlus &mdash; Todos los derechos reservados</p>
  </footer>

</body>
</html>
