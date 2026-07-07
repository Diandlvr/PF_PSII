<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="modelo.ContenidoDAO, modelo.ProgresoDAO, modelo.VerDespuesDAO" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // Guardia de sesion y perfil
    if (session.getAttribute("clienteId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String perfil = (String) session.getAttribute("perfilKey");
    if (perfil == null || perfil.isEmpty()) {
        response.sendRedirect("usuarios.jsp");
        return;
    }

    // ── AJAX: guardar avance ────────────────────────────────────────────
    if ("guardar".equals(request.getParameter("action"))
            && "POST".equals(request.getMethod())) {
        response.setContentType("application/json; charset=UTF-8");
        try {
            int idAjax = Integer.parseInt(request.getParameter("id"));
            double segundosVideo  = Double.parseDouble(request.getParameter("segundosVideo"));
            double duracionVideo  = Double.parseDouble(request.getParameter("duracionVideo"));
            int duracionTotal = Integer.parseInt(request.getParameter("duracionTotal"));

            double pct = (duracionVideo > 0) ? (segundosVideo / duracionVideo) : 0;
            if (pct < 0) pct = 0;
            if (pct > 1) pct = 1;
            int minutoActual = (int) Math.round(pct * duracionTotal);

            ProgresoDAO.guardar(perfil, idAjax, minutoActual, duracionTotal);
            out.print("{\"ok\":true}");
        } catch (Exception e) {
            System.err.println("reproductor.jsp guardar: " + e.getMessage());
            out.print("{\"ok\":false}");
        }
        return;
    }

    // ── Cargar pelicula ──────────────────────────────────────────────────
    int id;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        response.sendRedirect("repertorio.jsp");
        return;
    }

    Map<String, String> contenido = null;
    try {
        contenido = ContenidoDAO.getById(id);
    } catch (Exception e) { /* contenido queda null */ }

    if (contenido == null) {
        response.sendRedirect("repertorio.jsp");
        return;
    }

    // Al entrar a reproducir, sale de "Ver mas tarde" si estaba ahi
    VerDespuesDAO.quitar(perfil, id);

    int duracionTotal = Integer.parseInt(contenido.get("duracion_min"));
    int minutoActualPrevio = 0;
    int[] avance = ProgresoDAO.obtener(perfil, id);
    if (avance != null) {
        minutoActualPrevio = avance[0];
        duracionTotal = avance[1]; // conserva la duracion ya guardada para este perfil+pelicula
    }

    String videoUrl = contenido.get("video_url");
    String perfilEnc = URLEncoder.encode(perfil, "UTF-8");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CinemaxPlus &ndash; <%= esc(contenido.get("titulo")) %></title>
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="stylesheet" href="css/estilos_cinemax.css">
  <style>
    .player-wrap { max-width: 1100px; margin: 90px auto 40px; padding: 0 20px; }
    .player-video { width: 100%; border-radius: var(--radius); background: #000; box-shadow: 0 20px 44px rgba(0,0,0,0.6); }
    .player-title { margin: 20px 0 6px; font-size: 1.8rem; }
    .player-genre { color: var(--brand); font-weight: 600; font-size: 13px; }
    .player-back { display: inline-block; margin-top: 18px; }
  </style>
</head>
<body>

  <nav class="navbar">
    <a href="repertorio.jsp" class="cinemax-logo" aria-label="CinemaxPlus"></a>
    <div class="nav-links">
      <a href="repertorio.jsp">Inicio</a>
      <a href="favoritos.jsp">Mis Favoritos</a>
      <a href="reporte_avance.jsp">Mi Avance</a>
      <a href="reporte_cuenta.jsp">Mi Cuenta</a>
    </div>
    <a href="usuarios.jsp" class="user-icon" title="Cambiar perfil">?</a>
  </nav>

  <div class="player-wrap">
    <video id="player" class="player-video" controls autoplay src="<%= esc(videoUrl) %>"></video>
    <h1 class="player-title"><%= esc(contenido.get("titulo")) %></h1>
    <span class="player-genre"><%= esc(contenido.get("genero")) %></span>
    <br>
    <a class="btn btn-outline player-back" href="repertorio.jsp?perfil=<%= perfilEnc %>">&larr; Volver al cat&aacute;logo</a>
  </div>

  <script>
    const video = document.getElementById('player');
    const ID = <%= id %>;
    const DURACION_TOTAL = <%= duracionTotal %>;
    const MINUTO_PREVIO = <%= minutoActualPrevio %>;

    video.addEventListener('loadedmetadata', () => {
        if (MINUTO_PREVIO > 0 && DURACION_TOTAL > 0 && video.duration) {
            const pct = Math.min(MINUTO_PREVIO / DURACION_TOTAL, 0.98);
            video.currentTime = pct * video.duration;
        }
    });

    function guardarAvance() {
        if (!video.duration) return;
        const body = new URLSearchParams({
            action: 'guardar',
            id: ID,
            segundosVideo: video.currentTime,
            duracionVideo: video.duration,
            duracionTotal: DURACION_TOTAL
        });
        navigator.sendBeacon('reproductor.jsp', body);
    }

    let ultimoGuardado = 0;
    video.addEventListener('timeupdate', () => {
        if (video.currentTime - ultimoGuardado > 10) {
            ultimoGuardado = video.currentTime;
            guardarAvance();
        }
    });
    video.addEventListener('pause', guardarAvance);
    video.addEventListener('ended', guardarAvance);
    window.addEventListener('beforeunload', guardarAvance);
  </script>

</body>
</html>
