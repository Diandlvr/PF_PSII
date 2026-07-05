<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, java.util.*, java.net.URLEncoder, modelo.ConexionDB" %>
<%!
    // Devuelve la URL del avatar: el guardado en BD o uno estable por hash de la clave.
    String avatarDe(String avatar, String perfilKey, String[] avatares) {
        if (avatar != null && !avatar.isEmpty()) return avatar;
        int idx = Math.abs(perfilKey.hashCode()) % avatares.length;
        return avatares[idx];
    }

    // Escape HTML para prevenir XSS con datos escritos por el usuario.
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // Escape para incrustar un valor dentro de un string de JavaScript.
    private String escJs(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"");
    }
%>
<%
    request.setCharacterEncoding("UTF-8");

    // Guardia de sesion: redirige a login si no hay cliente autenticado
    if (session.getAttribute("clienteId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int clienteId = (Integer) session.getAttribute("clienteId");
    String mensaje = null;

    String[] avatares = {
        "img/avatars/spiderman.png",
        "img/avatars/gumball.png",
        "img/avatars/kanyebear.jpg",
        "img/avatars/shrek.png",
        "img/avatars/spongebob.png"
    };

    // Eliminar perfil (POST accion=eliminar; nunca por GET, es destructivo)
    if ("POST".equals(request.getMethod())
            && "eliminar".equals(request.getParameter("accion"))) {
        String eliminar = request.getParameter("perfilKey");
        if (eliminar != null && !eliminar.isEmpty()) {
            try (Connection con = ConexionDB.getConexion()) {
                PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM usuarios WHERE perfil_key = ? AND cliente_id = ?");
                ps.setString(1, eliminar);
                ps.setInt(2, clienteId);
                int filas = ps.executeUpdate();

                // Limpiar datos asociados solo si el perfil era de este cliente
                if (filas > 0) {
                    try (PreparedStatement pf = con.prepareStatement(
                            "DELETE FROM favs WHERE usuario = ?")) {
                        pf.setString(1, eliminar);
                        pf.executeUpdate();
                    }
                    try (PreparedStatement pp = con.prepareStatement(
                            "DELETE FROM progreso WHERE usuario = ?")) {
                        pp.setString(1, eliminar);
                        pp.executeUpdate();
                    } catch (SQLException exProgreso) {
                        // La tabla progreso puede no estar importada aun; no es fatal
                        System.err.println("usuarios.jsp progreso: " + exProgreso.getMessage());
                    }
                    // Si se elimino el perfil activo, limpiarlo de la sesion
                    if (eliminar.equals(session.getAttribute("perfilKey"))) {
                        session.removeAttribute("perfilKey");
                        session.removeAttribute("perfilNombre");
                    }
                }
            } catch (Exception e) {
                System.err.println("usuarios.jsp eliminar: " + e.getMessage());
            }
        }
        response.sendRedirect("usuarios.jsp");
        return;
    }

    // Crear perfil (POST)
    if ("POST".equals(request.getMethod())) {
        String nombre = request.getParameter("nombre") != null ? request.getParameter("nombre").trim() : "";
        String genero = request.getParameter("generoFavorito");
        String avatar = request.getParameter("avatar");

        // Validar avatar contra lista permitida
        boolean avatarValido = false;
        for (String a : avatares) { if (a.equals(avatar)) { avatarValido = true; break; } }
        if (!avatarValido) avatar = avatares[0];

        if (!nombre.isEmpty()) {
            String nombreNorm = nombre.toLowerCase().replaceAll("\\s+", "");
            String perfilKey  = clienteId + "_" + nombreNorm;

            try (Connection con = ConexionDB.getConexion()) {
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT COUNT(*) FROM usuarios WHERE perfil_key = ?");
                psCheck.setString(1, perfilKey);
                ResultSet rs = psCheck.executeQuery();
                rs.next();

                if (rs.getInt(1) > 0) {
                    mensaje = "Ya existe un perfil con ese nombre.";
                } else {
                    PreparedStatement psIns = con.prepareStatement(
                        "INSERT INTO usuarios (perfil_key, cliente_id, nombre, cat_fav, avatar) VALUES (?, ?, ?, ?, ?)");
                    psIns.setString(1, perfilKey);
                    psIns.setInt(2, clienteId);
                    psIns.setString(3, nombre);
                    psIns.setString(4, genero);
                    psIns.setString(5, avatar);
                    psIns.executeUpdate();
                    response.sendRedirect("usuarios.jsp");
                    return;
                }
            } catch (Exception e) {
                System.err.println("usuarios.jsp crear: " + e.getMessage());
                mensaje = "No se pudo crear el perfil. Intenta de nuevo.";
            }
        } else {
            mensaje = "El nombre no puede estar vacío.";
        }
    }

    // Obtener perfiles del cliente
    List<Map<String, String>> perfiles = new ArrayList<>();
    try (Connection con = ConexionDB.getConexion()) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT perfil_key, nombre, avatar FROM usuarios WHERE cliente_id = ?");
        ps.setInt(1, clienteId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> p = new HashMap<>();
            p.put("perfil_key", rs.getString("perfil_key"));
            p.put("nombre",     rs.getString("nombre"));
            p.put("avatar",     rs.getString("avatar") != null ? rs.getString("avatar") : "");
            perfiles.add(p);
        }
    } catch (Exception e) {
        System.err.println("usuarios.jsp cargar: " + e.getMessage());
        mensaje = "No se pudieron cargar los perfiles. Recarga la página.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Gestionar perfiles &ndash; CinemaxPlus</title>
  <link rel="stylesheet" href="css/estilos_cinemax.css">
  <style>
    .modal { display:none; position:fixed; inset:0; background:rgba(3,8,6,0.78);
             backdrop-filter:blur(8px); justify-content:center; align-items:center;
             z-index:200; animation:fadeIn 0.3s ease; }
    .modal-content {
      background:rgba(12,24,19,0.94); backdrop-filter:blur(22px);
      padding:40px; border-radius:22px; width:440px; max-width:92%;
      border:1px solid rgba(255,255,255,0.09); box-shadow:0 30px 70px rgba(0,0,0,0.6);
      animation:scaleIn 0.35s cubic-bezier(0.34,1.56,0.64,1);
    }
    .modal-content h2 { font-family:'Poppins',sans-serif; margin-bottom:6px; }
    .modal-content .hint { color:var(--cinemax-gray-medium); font-size:13px; margin-bottom:18px; }
    .modal-actions { display:flex; gap:10px; margin-top:8px; }
    .modal-actions .btn { flex:1; }
  </style>
</head>
<body class="perfil-body">
  <div class="profile-management">
    <h1 class="profile-title">&iquest;Qui&eacute;n est&aacute; viendo ahora?</h1>
    <p style="text-align:center; color:var(--cinemax-gray-medium); margin-top:4px;">
      Elige tu perfil para continuar
    </p>

    <div class="profiles-container">
      <%
        int i = 0;
        for (Map<String, String> p : perfiles) {
            String pKey   = p.get("perfil_key");
            String pNombre = p.get("nombre");
            String pAvatar = avatarDe(p.get("avatar"), pKey, avatares);
            double delay   = i * 0.07;
      %>
        <div class="profile" style="animation-delay: <%= delay %>s"
             onclick="location.href='repertorio.jsp?perfil=<%= URLEncoder.encode(pKey, "UTF-8") %>'">
          <button class="delete-btn btn btn-outline" type="button"
                  title="Eliminar perfil" aria-label="Eliminar perfil <%= esc(pNombre) %>"
                  onclick="event.stopPropagation(); eliminarPerfil('<%= esc(escJs(pKey)) %>', '<%= esc(escJs(pNombre)) %>')">&#10060;</button>
          <div class="profile-avatar" style="background-image:url('<%= esc(pAvatar) %>');"></div>
          <div class="profile-name"><%= esc(pNombre) %></div>
        </div>
      <% i++; } %>

      <div class="profile" id="addProfileBtn"
           style="animation-delay: <%= perfiles.size() * 0.07 %>s">
        <div class="add-profile">+</div>
        <div class="profile-name">A&ntilde;adir perfil</div>
      </div>
    </div>

    <% if (mensaje != null) { %>
      <div class="error-message"
           style="display:block; text-align:center; max-width:420px; margin:24px auto 0;">
        <strong><%= esc(mensaje) %></strong>
      </div>
    <% } %>

    <div style="text-align:center; margin-top:40px;">
      <a href="logout.jsp" class="btn btn-outline">Cerrar sesi&oacute;n</a>
    </div>
  </div>

  <!-- Modal A&ntilde;adir perfil -->
  <div class="modal" id="profileModal">
    <div class="modal-content">
      <h2>A&ntilde;adir perfil</h2>
      <p class="hint">Personaliza tu nombre, avatar y g&eacute;nero favorito.</p>
      <form action="usuarios.jsp" method="post">
        <div class="form-group">
          <label>Elige tu avatar</label>
          <div class="avatar-picker">
            <% for (int idx = 0; idx < avatares.length; idx++) { %>
              <label class="avatar-option">
                <input type="radio" name="avatar" value="<%= avatares[idx] %>"
                       <%= idx == 0 ? "checked" : "" %>>
                <img src="<%= avatares[idx] %>" alt="Avatar <%= idx + 1 %>">
              </label>
            <% } %>
          </div>
        </div>
        <div class="form-group">
          <label>Nombre</label>
          <input type="text" name="nombre" placeholder="Ej. Juan" required>
        </div>
        <div class="form-group">
          <label>G&eacute;nero favorito</label>
          <select name="generoFavorito">
            <option value="Acci&oacute;n">Acci&oacute;n</option>
            <option value="Drama">Drama</option>
            <option value="Comedia">Comedia</option>
            <option value="Terror">Terror</option>
            <option value="Ciencia Ficci&oacute;n">Ciencia Ficci&oacute;n</option>
            <option value="Animaci&oacute;n">Animaci&oacute;n</option>
            <option value="Aventura">Aventura</option>
          </select>
        </div>
        <div class="modal-actions">
          <button type="button" class="btn btn-secondary" id="cancelBtn">Cancelar</button>
          <button type="submit" class="btn btn-primary">Crear perfil</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Formulario oculto: eliminar perfil por POST (nunca por GET) -->
  <form id="deleteForm" method="post" action="usuarios.jsp" style="display:none;">
    <input type="hidden" name="accion" value="eliminar">
    <input type="hidden" name="perfilKey" id="deleteKey">
  </form>

  <script>
    const modal = document.getElementById('profileModal');
    document.getElementById('addProfileBtn').onclick = () => {
      modal.style.display = 'flex';
      const inp = modal.querySelector('input[name="nombre"]');
      if (inp) inp.focus();
    };
    document.getElementById('cancelBtn').onclick     = () => modal.style.display = 'none';
    modal.addEventListener('click', (e) => { if (e.target === modal) modal.style.display = 'none'; });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') modal.style.display = 'none'; });

    function eliminarPerfil(perfilKey, nombre) {
      if (confirm('¿Eliminar el perfil "' + nombre + '"? También se borrarán sus favoritos y su avance.')) {
        document.getElementById('deleteKey').value = perfilKey;
        document.getElementById('deleteForm').submit();
      }
    }
  </script>
</body>
</html>
