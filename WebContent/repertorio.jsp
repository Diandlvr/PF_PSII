<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, java.util.*, java.net.URLEncoder" %>
<%@ page import="modelo.ConexionDB, modelo.ContenidoDAO, modelo.FavoritoDAO, modelo.ProgresoDAO, modelo.VerDespuesDAO" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }

    // Reloj estilo YouTube "Ver más tarde": contorno cuando no está en la lista...
    private static final String ICON_RELOJ =
        "<svg width=\"16\" height=\"16\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" "
      + "stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">"
      + "<circle cx=\"12\" cy=\"12\" r=\"9\"/><polyline points=\"12 7 12 12 15.5 14\"/></svg>";

    // ...relleno (solido) cuando ya esta agregada.
    private static final String ICON_RELOJ_LLENO =
        "<svg width=\"16\" height=\"16\" viewBox=\"0 0 24 24\" fill=\"currentColor\">"
      + "<path d=\"M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z"
      + "m.5 5H11v6l5.25 3.15.75-1.23-4.5-2.67V7z\"/></svg>";
%>
<%
    request.setCharacterEncoding("UTF-8");

    // Guardia de sesion
    if (session.getAttribute("clienteId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int clienteId = (Integer) session.getAttribute("clienteId");

    // ── AJAX: toggle favorito ─────────────────────────────────────────────
    if ("toggle".equals(request.getParameter("action"))
            && "POST".equals(request.getMethod())) {
        response.setContentType("application/json; charset=UTF-8");
        String pAjax = request.getParameter("perfil");
        String idStr  = request.getParameter("id");
        try {
            if (pAjax == null || idStr == null) throw new IllegalArgumentException("params");
            // Validar que el perfil pertenezca a este cliente
            try (Connection con = ConexionDB.getConexion();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT 1 FROM usuarios WHERE perfil_key=? AND cliente_id=?")) {
                ps.setString(1, pAjax);
                ps.setInt(2, clienteId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) throw new SecurityException("perfil no autorizado");
            }
            boolean esFav = FavoritoDAO.toggle(pAjax, Integer.parseInt(idStr));
            out.print("{\"favorito\":" + esFav + "}");
        } catch (Exception e) {
            System.err.println("repertorio.jsp toggle: " + e.getMessage());
            out.print("{\"error\":\"No se pudo actualizar el favorito\"}");
        }
        return;
    }

    // ── AJAX: toggle "Ver más tarde" ────────────────────────────────────────
    if ("verdespues".equals(request.getParameter("action"))
            && "POST".equals(request.getMethod())) {
        response.setContentType("application/json; charset=UTF-8");
        String pAjax = request.getParameter("perfil");
        String idStr  = request.getParameter("id");
        try {
            if (pAjax == null || idStr == null) throw new IllegalArgumentException("params");
            try (Connection con = ConexionDB.getConexion();
                 PreparedStatement ps = con.prepareStatement(
                     "SELECT 1 FROM usuarios WHERE perfil_key=? AND cliente_id=?")) {
                ps.setString(1, pAjax);
                ps.setInt(2, clienteId);
                ResultSet rs = ps.executeQuery();
                if (!rs.next()) throw new SecurityException("perfil no autorizado");
            }
            boolean enLista = VerDespuesDAO.toggle(pAjax, Integer.parseInt(idStr));
            out.print("{\"enLista\":" + enLista + "}");
        } catch (Exception e) {
            System.err.println("repertorio.jsp verdespues: " + e.getMessage());
            out.print("{\"error\":\"No se pudo actualizar la lista\"}");
        }
        return;
    }

    // ── Validar perfil ────────────────────────────────────────────────────
    // Si no llega por URL, usamos el perfil activo de la sesion (permite
    // navegar entre paginas sin arrastrar ?perfil= en cada enlace).
    String perfil = request.getParameter("perfil");
    if (perfil == null || perfil.isEmpty()) {
        perfil = (String) session.getAttribute("perfilKey");
    }
    if (perfil == null || perfil.isEmpty()) {
        response.sendRedirect("usuarios.jsp");
        return;
    }
    String perfilNombre = null;
    String catFav = "Acción";
    try (Connection con = ConexionDB.getConexion();
         PreparedStatement ps = con.prepareStatement(
             "SELECT nombre, cat_fav FROM usuarios WHERE perfil_key=? AND cliente_id=?")) {
        ps.setString(1, perfil);
        ps.setInt(2, clienteId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            perfilNombre = rs.getString("nombre");
            catFav = rs.getString("cat_fav") != null ? rs.getString("cat_fav") : "Acción";
            // Sincronizar perfil con la sesion para reporte_avance.jsp / reporte_cuenta.jsp
            session.setAttribute("perfilKey",    perfil);
            session.setAttribute("perfilNombre", perfilNombre);
        } else {
            response.sendRedirect("usuarios.jsp");
            return;
        }
    }

    // ── Cargar contenido ──────────────────────────────────────────────────
    String generoFiltro = request.getParameter("genero");
    List<String> generos = new ArrayList<>();
    List<Map<String, String>> contenidos = new ArrayList<>();
    try {
        generos   = ContenidoDAO.getGeneros();
        contenidos = (generoFiltro != null && !generoFiltro.isEmpty())
                   ? ContenidoDAO.getByGenero(generoFiltro)
                   : ContenidoDAO.getAll();
    } catch (Exception e) { /* continuar con listas vacías */ }

    // Agrupar por género
    Map<String, List<Map<String, String>>> porGenero = new LinkedHashMap<>();
    for (Map<String, String> c : contenidos) {
        String g = c.get("genero");
        if (!porGenero.containsKey(g)) porGenero.put(g, new ArrayList<Map<String, String>>());
        porGenero.get(g).add(c);
    }

    // Favoritos del perfil
    Set<Integer> favIds = new HashSet<>();
    try { favIds = FavoritoDAO.getIds(perfil); } catch (Exception e) { /* ignorar */ }

    // "Ver más tarde" del perfil
    Set<Integer> verDespuesIds = new HashSet<>();
    try { verDespuesIds = VerDespuesDAO.getIds(perfil); } catch (Exception e) { /* ignorar */ }
    List<Map<String, String>> listaVerDespues = new ArrayList<>();
    try { listaVerDespues = VerDespuesDAO.listar(perfil); } catch (Exception e) { /* ignorar */ }

    // "Continuar viendo" del perfil (peliculas empezadas, no terminadas)
    List<Map<String, String>> continuarViendo = ProgresoDAO.continuarViendo(perfil, 10);

    // % visto por pelicula (todas las que tengan avance guardado), para pintar
    // la barra de progreso también dentro de los carruseles por género.
    Map<Integer, Integer> pctPorPelicula = ProgresoDAO.obtenerTodos(perfil);

    // Hero: primer item del género favorito, si no el primero disponible
    Map<String, String> hero = null;
    for (Map<String, String> c : contenidos) {
        if (catFav.equals(c.get("genero"))) { hero = c; break; }
    }
    if (hero == null && !contenidos.isEmpty()) hero = contenidos.get(0);

    String perfilEnc = URLEncoder.encode(perfil, "UTF-8");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CinemaxPlus &ndash; Repertorio</title>
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body>

  <!-- ══ Navbar ══════════════════════════════════════════════════════ -->
  <nav class="navbar">
    <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="cinemax-logo"></a>
    <div class="nav-links">
      <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="active">Inicio</a>
      <a href="favoritos.jsp?perfil=<%= perfilEnc %>">Mis Favoritos</a>
      <a href="reporte_avance.jsp">Mi Avance</a>
      <a href="reporte_cuenta.jsp">Mi Cuenta</a>
      <a href="contactanos.jsp">Nuestro Equipo</a>
    </div>
    <a href="usuarios.jsp" class="user-icon" title="Cambiar perfil">
      <%= (perfilNombre == null || perfilNombre.isEmpty()) ? "?" : esc(perfilNombre.substring(0,1).toUpperCase()) %>
    </a>
  </nav>

  <div class="main-content">

    <!-- ══ Hero ════════════════════════════════════════════════════════ -->
    <% if (hero != null) {
       boolean heroFav = favIds.contains(Integer.parseInt(hero.get("id"))); %>
    <section class="hero">
      <div class="hero-backdrop"
           style="background-image:url('<%= esc(hero.get("imagen_url")) %>')"></div>
      <div class="hero-inner">
        <div class="hero-content">
          <span class="hero-badge"><%= esc(hero.get("genero")) %></span>
          <h1 class="hero-title"><%= esc(hero.get("titulo")) %></h1>
          <p class="hero-sub">Disfruta de lo mejor del cine y series en CinemaxPlus.</p>
          <div class="hero-buttons">
            <a href="reproductor.jsp?id=<%= hero.get("id") %>&perfil=<%= perfilEnc %>"
               class="btn btn-primary">&#9654; Reproducir</a>
            <button class="btn btn-secondary hero-fav-btn <%= heroFav ? "favorito" : "" %>"
                    data-id="<%= hero.get("id") %>"
                    onclick="toggleFav(this, <%= hero.get("id") %>)">
              <%= heroFav ? "&#9829;" : "&#9825;" %> <%= heroFav ? "En favoritos" : "Agregar" %>
            </button>
          </div>
        </div>
        <div class="hero-poster"
             style="background-image:url('<%= esc(hero.get("imagen_url")) %>'); cursor:pointer;"
             onclick="location.href='reproductor.jsp?id=<%= hero.get("id") %>&perfil=<%= perfilEnc %>'"></div>
      </div>
    </section>
    <% } %>

    <!-- ══ Continuar viendo ════════════════════════════════════════════ -->
    <% if (!continuarViendo.isEmpty()) { %>
    <section class="content-section">
      <h2 class="section-title">Continuar viendo</h2>
      <div class="carousel">
        <% for (Map<String,String> it : continuarViendo) { %>
        <div class="carousel-item"
             style="background-image:url('<%= esc(it.get("imagen_url")) %>')"
             onclick="location.href='reproductor.jsp?id=<%= it.get("id") %>&perfil=<%= perfilEnc %>'">
          <div class="card-progress">
            <div class="progress-track"><div class="progress-fill" style="width:<%= it.get("pct") %>%;"></div></div>
          </div>
          <div class="card-overlay">
            <span class="card-title"><%= esc(it.get("titulo")) %></span>
            <span class="card-play"><%= it.get("pct") %>% visto &mdash; Continuar</span>
          </div>
        </div>
        <% } %>
      </div>
    </section>
    <% } %>

    <!-- ══ Ver más tarde ═══════════════════════════════════════════════ -->
    <section class="content-section" id="verDespuesSection"
              style="<%= listaVerDespues.isEmpty() ? "display:none;" : "" %>">
      <h2 class="section-title">Ver m&aacute;s tarde</h2>
      <div class="carousel" id="verDespuesCarousel">
        <% for (Map<String,String> it : listaVerDespues) { %>
        <div class="carousel-item" id="verdespues-item-<%= it.get("id") %>"
             style="background-image:url('<%= esc(it.get("imagen_url")) %>')"
             onclick="location.href='reproductor.jsp?id=<%= it.get("id") %>&perfil=<%= perfilEnc %>'">
          <div class="card-overlay">
            <span class="card-title"><%= esc(it.get("titulo")) %></span>
            <span class="card-play">&#9654; Reproducir</span>
          </div>
        </div>
        <% } %>
      </div>
    </section>

    <!-- ══ Filtro de géneros ════════════════════════════════════════════ -->
    <div class="genre-filter">
      <a href="repertorio.jsp?perfil=<%= perfilEnc %>"
         class="chip <%= (generoFiltro == null || generoFiltro.isEmpty()) ? "active" : "" %>">Todos</a>
      <% for (String g : generos) { %>
        <a href="repertorio.jsp?perfil=<%= perfilEnc %>&genero=<%= URLEncoder.encode(g,"UTF-8") %>"
           class="chip <%= g.equals(generoFiltro) ? "active" : "" %>"><%= esc(g) %></a>
      <% } %>
    </div>

    <!-- ══ Carruseles por género ════════════════════════════════════════ -->
    <% for (Map.Entry<String, List<Map<String,String>>> entry : porGenero.entrySet()) {
         String secGenero = entry.getKey();
         List<Map<String,String>> items = entry.getValue();
    %>
    <section class="content-section">
      <h2 class="section-title"><%= esc(secGenero) %></h2>
      <div class="carousel">
        <% for (Map<String,String> item : items) {
             int itemId = Integer.parseInt(item.get("id"));
             boolean esFav = favIds.contains(itemId);
             boolean enLista = verDespuesIds.contains(itemId);
             Integer pctItem = pctPorPelicula.get(itemId);
        %>
        <div class="carousel-item"
             style="background-image:url('<%= esc(item.get("imagen_url")) %>')"
             onclick="location.href='reproductor.jsp?id=<%= itemId %>&perfil=<%= perfilEnc %>'">
          <button class="favorite-btn <%= esFav ? "favorito" : "" %>"
                  title="<%= esFav ? "Quitar de favoritos" : "Agregar a favoritos" %>"
                  aria-label="<%= esFav ? "Quitar" : "Agregar" %> <%= esc(item.get("titulo")) %> <%= esFav ? "de" : "a" %> favoritos"
                  data-id="<%= itemId %>"
                  onclick="event.stopPropagation(); toggleFav(this, <%= itemId %>)">
            <%= esFav ? "&#9829;" : "&#9825;" %>
          </button>
          <button class="watchlist-btn <%= enLista ? "en-lista" : "" %>"
                  title="<%= enLista ? "Quitar de Ver más tarde" : "Agregar a Ver más tarde" %>"
                  aria-label="<%= enLista ? "Quitar" : "Agregar" %> <%= esc(item.get("titulo")) %> <%= enLista ? "de" : "a" %> Ver más tarde"
                  data-id="<%= itemId %>"
                  data-titulo="<%= esc(item.get("titulo")) %>"
                  data-imagen="<%= esc(item.get("imagen_url")) %>"
                  onclick="event.stopPropagation(); toggleVerDespues(this, <%= itemId %>)">
            <%= enLista ? ICON_RELOJ_LLENO : ICON_RELOJ %>
          </button>
          <% if (pctItem != null) { %>
          <div class="card-progress">
            <div class="progress-track"><div class="progress-fill" style="width:<%= pctItem %>%;"></div></div>
          </div>
          <% } %>
          <div class="card-overlay">
            <span class="card-title"><%= esc(item.get("titulo")) %></span>
            <span class="card-play">&#9654; <%= pctItem != null ? pctItem + "% visto" : "Reproducir" %></span>
          </div>
        </div>
        <% } %>
      </div>
    </section>
    <% } %>

    <% if (porGenero.isEmpty()) { %>
    <div style="text-align:center; padding:80px 20px; color:var(--cinemax-gray-medium);">
      <p style="font-size:1.2rem;">No hay contenido en esta categor&iacute;a.</p>
      <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="btn btn-outline"
         style="margin-top:20px;">Ver todo</a>
    </div>
    <% } %>

  </div>

  <!-- ══ Footer ══════════════════════════════════════════════════════ -->
  <footer>
    <p>&copy; 2025 CinemaxPlus &mdash; Todos los derechos reservados</p>
    <p style="margin-top:8px;">
      <a href="logout.jsp" style="color:var(--brand); text-decoration:none;">Cerrar sesi&oacute;n</a>
    </p>
  </footer>

  <script>
    const PERFIL_KEY = '<%= perfil.replace("'", "\\'") %>';
    const ICON_RELOJ_JS = '<%= ICON_RELOJ.replace("'", "\\'") %>';
    const ICON_RELOJ_LLENO_JS = '<%= ICON_RELOJ_LLENO.replace("'", "\\'") %>';

    async function toggleFav(btn, id) {
        const body = 'action=toggle&perfil=' + encodeURIComponent(PERFIL_KEY) + '&id=' + id;
        try {
            const res  = await fetch('repertorio.jsp', {
                method : 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body
            });
            const data = await res.json();
            if (data.error) { console.error(data.error); return; }
            btn.classList.toggle('favorito', data.favorito);
            btn.title = data.favorito ? 'Quitar de favoritos' : 'Agregar a favoritos';
            const isHeroBtn = btn.closest('.hero') != null;
            if (isHeroBtn) {
                btn.innerHTML = data.favorito ? '&#9829; En favoritos' : '&#9825; Agregar';
            } else {
                btn.innerHTML = data.favorito ? '&#9829;' : '&#9825;';
            }
        } catch (e) {
            console.error('toggleFav error:', e);
        }
    }

    async function toggleVerDespues(btn, id) {
        const body = 'action=verdespues&perfil=' + encodeURIComponent(PERFIL_KEY) + '&id=' + id;
        try {
            const res  = await fetch('repertorio.jsp', {
                method : 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body
            });
            const data = await res.json();
            if (data.error) { console.error(data.error); return; }

            btn.classList.toggle('en-lista', data.enLista);
            btn.title = data.enLista ? 'Quitar de Ver más tarde' : 'Agregar a Ver más tarde';
            btn.innerHTML = data.enLista ? ICON_RELOJ_LLENO_JS : ICON_RELOJ_JS;

            // Mantener sincronizada la fila "Ver más tarde" sin recargar la página.
            const carousel = document.getElementById('verDespuesCarousel');
            const section  = document.getElementById('verDespuesSection');
            const existente = document.getElementById('verdespues-item-' + id);

            if (data.enLista && !existente) {
                const card = document.createElement('div');
                card.className = 'carousel-item';
                card.id = 'verdespues-item-' + id;
                card.style.backgroundImage = "url('" + btn.dataset.imagen + "')";
                card.onclick = function () {
                    location.href = 'reproductor.jsp?id=' + id + '&perfil=' + encodeURIComponent(PERFIL_KEY);
                };
                const overlay = document.createElement('div');
                overlay.className = 'card-overlay';
                const titulo = document.createElement('span');
                titulo.className = 'card-title';
                titulo.textContent = btn.dataset.titulo;
                const play = document.createElement('span');
                play.className = 'card-play';
                play.innerHTML = '&#9654; Reproducir';
                overlay.appendChild(titulo);
                overlay.appendChild(play);
                card.appendChild(overlay);
                carousel.prepend(card);
                section.style.display = '';
            } else if (!data.enLista && existente) {
                existente.remove();
                if (!carousel.children.length) section.style.display = 'none';
            }
        } catch (e) {
            console.error('toggleVerDespues error:', e);
        }
    }
  </script>

</body>
</html>
