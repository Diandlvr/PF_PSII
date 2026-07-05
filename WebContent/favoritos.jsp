<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, java.util.*, java.net.URLEncoder" %>
<%@ page import="modelo.ConexionDB, modelo.FavoritoDAO" %>
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

    // ── AJAX: quitar favorito ────────────────────────────────────────
    if ("quitar".equals(request.getParameter("action"))
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
            FavoritoDAO.remove(pAjax, Integer.parseInt(idStr));
            out.print("{\"ok\":true}");
        } catch (Exception e) {
            System.err.println("favoritos.jsp quitar: " + e.getMessage());
            out.print("{\"error\":\"No se pudo quitar el favorito\"}");
        }
        return;
    }

    // ── Validar perfil ────────────────────────────────────────────────
    // Si no llega por URL, usamos el perfil activo de la sesion.
    String perfil = request.getParameter("perfil");
    if (perfil == null || perfil.isEmpty()) {
        perfil = (String) session.getAttribute("perfilKey");
    }
    if (perfil == null || perfil.isEmpty()) {
        response.sendRedirect("usuarios.jsp");
        return;
    }
    String perfilNombre = null;
    String avatarUrl    = null;
    try (Connection con = ConexionDB.getConexion();
         PreparedStatement ps = con.prepareStatement(
             "SELECT nombre, avatar FROM usuarios WHERE perfil_key=? AND cliente_id=?")) {
        ps.setString(1, perfil);
        ps.setInt(2, clienteId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            perfilNombre = rs.getString("nombre");
            avatarUrl    = rs.getString("avatar");
            // Sincronizar perfil con la sesion
            session.setAttribute("perfilKey",    perfil);
            session.setAttribute("perfilNombre", perfilNombre);
        } else {
            response.sendRedirect("usuarios.jsp");
            return;
        }
    }

    // ── Cargar favoritos ──────────────────────────────────────────────
    List<Map<String, String>> favoritos = new ArrayList<>();
    try { favoritos = FavoritoDAO.getContenido(perfil); } catch (Exception e) { /* ignorar */ }

    String perfilEnc = URLEncoder.encode(perfil, "UTF-8");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Mis Favoritos &ndash; CinemaxPlus</title>
  <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body class="favorites-body">

  <!-- ══ Navbar ══════════════════════════════════════════════════════ -->
  <nav class="navbar">
    <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="cinemax-logo"></a>
    <div class="nav-links">
      <a href="repertorio.jsp?perfil=<%= perfilEnc %>">Inicio</a>
      <a href="favoritos.jsp?perfil=<%= perfilEnc %>" class="active">Mis Favoritos</a>
      <a href="reporte_avance.jsp">Mi Avance</a>
      <a href="reporte_cuenta.jsp">Mi Cuenta</a>
    </div>
    <a href="usuarios.jsp" class="user-icon" title="Cambiar perfil">
      <%= (perfilNombre == null || perfilNombre.isEmpty()) ? "?" : esc(perfilNombre.substring(0,1).toUpperCase()) %>
    </a>
  </nav>

  <!-- ══ Encabezado de perfil ════════════════════════════════════════ -->
  <div class="profile-header" style="padding: 20px 50px 0;">
    <div style="display:flex; align-items:center; gap:18px;">
      <% if (avatarUrl != null && !avatarUrl.isEmpty()) { %>
        <div style="width:62px; height:62px; border-radius:14px;
                    background:url('<%= esc(avatarUrl) %>') center/contain no-repeat;
                    background-color:#0e1c16; border:2px solid var(--brand);"></div>
      <% } %>
      <div>
        <h1 class="profile-title"
            style="font-size:1.8rem; text-align:left; margin:0;">
          Lista de <%= esc(perfilNombre) %>
        </h1>
        <p style="color:var(--cinemax-gray-medium); font-size:14px; margin-top:4px;">
          <%= favoritos.size() %> t&iacute;tulo<%= favoritos.size() != 1 ? "s" : "" %> guardado<%= favoritos.size() != 1 ? "s" : "" %>
        </p>
      </div>
    </div>
  </div>

  <!-- ══ Grid de favoritos ════════════════════════════════════════════ -->
  <% if (favoritos.isEmpty()) { %>
  <div style="text-align:center; padding:80px 20px; color:var(--cinemax-gray-medium);">
    <p style="font-size:3rem;">&#9825;</p>
    <p style="font-size:1.2rem; margin-top:12px;">A&uacute;n no tienes favoritos.</p>
    <p style="margin-top:8px;">Explora el cat&aacute;logo y pulsa &#9825; en lo que m&aacute;s te guste.</p>
    <a href="repertorio.jsp?perfil=<%= perfilEnc %>" class="btn btn-primary" style="margin-top:28px;">
      Explorar cat&aacute;logo
    </a>
  </div>
  <% } else { %>
  <div class="favorites-grid">
    <% int delay = 0;
       for (Map<String, String> fav : favoritos) {
    %>
    <div class="favorite-item" id="fav-<%= fav.get("id") %>"
         style="animation-delay:<%= delay * 0.06 %>s">
      <img src="<%= esc(fav.get("imagen_url")) %>"
           alt="<%= esc(fav.get("titulo")) %>"
           loading="lazy">
      <div class="favorite-overlay">
        <span style="font-family:'Poppins',sans-serif; font-size:1rem; font-weight:700;
                     text-align:center; text-shadow:0 2px 8px rgba(0,0,0,0.8);">
          <%= esc(fav.get("titulo")) %>
        </span>
        <span style="font-size:12px; color:var(--brand-tint);">
          <%= esc(fav.get("genero")) %>
        </span>
        <div style="display:flex; gap:10px; margin-top:10px; flex-wrap:wrap; justify-content:center;">
          <a href="https://www.youtube.com/results?search_query=<%= URLEncoder.encode(fav.get("titulo"), "UTF-8") %>"
             target="_blank" rel="noopener"
             class="btn btn-primary" style="padding:8px 18px; font-size:12px;">
            &#9654; Ver en YouTube
          </a>
          <button class="btn btn-outline"
                  style="padding:8px 18px; font-size:12px;"
                  onclick="quitarFav(this, <%= fav.get("id") %>)">
            &#9829; Quitar
          </button>
        </div>
      </div>
    </div>
    <% delay++; } %>
  </div>
  <% } %>

  <!-- ══ Footer ══════════════════════════════════════════════════════ -->
  <footer>
    <p>&copy; 2025 CinemaxPlus &mdash; Todos los derechos reservados</p>
    <p style="margin-top:8px;">
      <a href="logout.jsp" style="color:var(--brand); text-decoration:none;">Cerrar sesi&oacute;n</a>
    </p>
  </footer>

  <script>
    const PERFIL_KEY = '<%= perfil.replace("'", "\\'") %>';

    async function quitarFav(btn, id) {
        btn.disabled = true;
        try {
            const res  = await fetch('favoritos.jsp', {
                method : 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body   : 'action=quitar&perfil=' + encodeURIComponent(PERFIL_KEY) + '&id=' + id
            });
            const data = await res.json();
            if (data.error) { console.error(data.error); btn.disabled = false; return; }
            const card = document.getElementById('fav-' + id);
            if (card) {
                card.style.transition = 'opacity 0.35s, transform 0.35s';
                card.style.opacity    = '0';
                card.style.transform  = 'scale(0.9)';
                setTimeout(() => {
                    card.remove();
                    actualizarContador();
                }, 380);
            }
        } catch (e) {
            console.error('quitarFav error:', e);
            btn.disabled = false;
        }
    }

    function actualizarContador() {
        const cards = document.querySelectorAll('.favorite-item');
        const count = cards.length;
        const el = document.querySelector('.profile-header p');
        if (el) {
            el.textContent = count + ' título' + (count !== 1 ? 's' : '')
                           + ' guardado' + (count !== 1 ? 's' : '');
        }
        if (count === 0) location.reload();
    }
  </script>

</body>
</html>
