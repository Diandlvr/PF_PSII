<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, java.util.*, java.net.URLEncoder" %>
<%@ page import="modelo.ConexionDB, modelo.ContenidoDAO, modelo.FavoritoDAO" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
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
            out.print("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
        }
        return;
    }

    // ── Validar perfil ────────────────────────────────────────────────────
    String perfil = request.getParameter("perfil");
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
        if (!porGenero.containsKey(g)) porGenero.put(g, new ArrayList<>());
        porGenero.get(g).add(c);
    }

    // Favoritos del perfil
    Set<Integer> favIds = new HashSet<>();
    try { favIds = FavoritoDAO.getIds(perfil); } catch (Exception e) { /* ignorar */ }

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
  <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body>

  <!-- ══ Navbar ══════════════════════════════════════════════════════ -->
  <nav class="navbar">
    <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="cinemax-logo"></a>
    <div class="nav-links">
      <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="active">Inicio</a>
      <a href="favoritos.jsp?perfil=<%= perfilEnc %>">Mis Favoritos</a>
      <a href="reporte_cuenta.jsp">Mi Cuenta</a>
    </div>
    <a href="usuarios.jsp" class="user-icon" title="Cambiar perfil">
      <%= esc(perfilNombre).substring(0,1).toUpperCase() %>
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
            <a href="https://www.youtube.com/results?search_query=<%= URLEncoder.encode(hero.get("titulo"), "UTF-8") %>"
               target="_blank" rel="noopener" class="btn btn-primary">&#9654; Ver en YouTube</a>
            <button class="btn btn-secondary favorite-btn <%= heroFav ? "favorito" : "" %>"
                    data-id="<%= hero.get("id") %>"
                    onclick="toggleFav(this, <%= hero.get("id") %>)">
              <%= heroFav ? "&#9829;" : "&#9825;" %> <%= heroFav ? "En favoritos" : "Agregar" %>
            </button>
          </div>
        </div>
        <div class="hero-poster"
             style="background-image:url('<%= esc(hero.get("imagen_url")) %>'); cursor:pointer;"
             onclick="window.open('https://www.youtube.com/results?search_query=<%= URLEncoder.encode(hero.get("titulo"), "UTF-8") %>','_blank')"></div>
      </div>
    </section>
    <% } %>

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
        %>
        <div class="carousel-item"
             style="background-image:url('<%= esc(item.get("imagen_url")) %>')"
             onclick="window.open('https://www.youtube.com/results?search_query=<%= URLEncoder.encode(item.get("titulo"), "UTF-8") %>','_blank')">
          <button class="favorite-btn <%= esFav ? "favorito" : "" %>"
                  title="<%= esFav ? "Quitar de favoritos" : "Agregar a favoritos" %>"
                  data-id="<%= itemId %>"
                  onclick="event.stopPropagation(); toggleFav(this, <%= itemId %>)">
            <%= esFav ? "&#9829;" : "&#9825;" %>
          </button>
          <div class="card-overlay">
            <span class="card-title"><%= esc(item.get("titulo")) %></span>
            <span class="card-play">&#9654; Ver en YouTube</span>
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
  </script>

</body>
</html>
