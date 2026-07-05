<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, java.util.UUID, modelo.ConexionDB, modelo.EmailUtil, modelo.PasswordUtil, modelo.MembresiaDAO" %>
<%
    String mensaje      = null;
    boolean noVerificado = false;
    boolean reenvioOk   = false;
    String  accion      = request.getParameter("accion") != null ? request.getParameter("accion") : "";

    request.setCharacterEncoding("UTF-8");

    // URL base real de la app para el enlace del correo de verificacion
    String urlCompleta = request.getRequestURL().toString();
    String baseUrl = urlCompleta.substring(0, urlCompleta.lastIndexOf('/'));

    if ("POST".equals(request.getMethod())) {

        // ── Reenviar correo de verificacion ──────────────────────────────────
        if ("reenviar".equals(accion)) {
            String email = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
            if (email.contains("@")) {
                try (Connection con = ConexionDB.getConexion()) {
                    PreparedStatement ps = con.prepareStatement(
                        "SELECT id, nombre FROM cliente WHERE correo = ? AND verificado = 0");
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String nuevoToken = UUID.randomUUID().toString();
                        PreparedStatement upd = con.prepareStatement(
                            "UPDATE cliente SET token_verificacion = ? WHERE id = ?");
                        upd.setString(1, nuevoToken);
                        upd.setInt(2, rs.getInt("id"));
                        upd.executeUpdate();
                        EmailUtil.enviarConfirmacion(email, rs.getString("nombre"), nuevoToken, baseUrl);
                        reenvioOk = true;
                    } else {
                        // No revelamos si el correo existe o ya estaba verificado
                        reenvioOk = true;
                    }
                } catch (Exception e) {
                    System.err.println("login.jsp reenviar: " + e.getMessage());
                    mensaje = "No se pudo reenviar el correo. Intenta de nuevo en unos minutos.";
                }
            } else {
                mensaje = "Ingresa un correo válido para reenviar la verificación.";
            }

        // ── Login normal ──────────────────────────────────────────────────────
        } else {
            String email    = request.getParameter("email")    != null ? request.getParameter("email").trim()    : "";
            String password = request.getParameter("password") != null ? request.getParameter("password").trim() : "";

            if (email.contains("@") && password.length() >= 6) {
                try (Connection con = ConexionDB.getConexion()) {
                    PreparedStatement ps = con.prepareStatement(
                        "SELECT id, nombre, verificado, contrasena, password_salt"
                      + " FROM cliente WHERE correo = ?");
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String storedPass = rs.getString("contrasena");
                        String storedSalt = rs.getString("password_salt");

                        if (!PasswordUtil.verificar(password, storedPass, storedSalt)) {
                            mensaje = "Correo o contraseña incorrectos.";
                        } else if (rs.getInt("verificado") == 0) {
                            noVerificado = true;
                            mensaje = "Debes confirmar tu correo antes de iniciar sesión.";
                        } else {
                            int cliId = rs.getInt("id");

                            // Auto-migracion: si la cuenta esta en texto plano, la re-hasheamos
                            if (PasswordUtil.esLegacy(storedSalt)) {
                                String nuevoSalt = PasswordUtil.generarSalt();
                                String nuevoHash = PasswordUtil.hash(password, nuevoSalt);
                                try (PreparedStatement upd = con.prepareStatement(
                                        "UPDATE cliente SET contrasena = ?, password_salt = ? WHERE id = ?")) {
                                    upd.setString(1, nuevoHash);
                                    upd.setString(2, nuevoSalt);
                                    upd.setInt(3, cliId);
                                    upd.executeUpdate();
                                }
                            }

                            session.setAttribute("clienteId", cliId);
                            session.setAttribute("userEmail", email);
                            session.setAttribute("userName",  rs.getString("nombre"));

                            // Primer login sin plan: elegir membresia antes de los perfiles
                            if (MembresiaDAO.tieneMembresia(cliId)) {
                                response.sendRedirect("usuarios.jsp");
                            } else {
                                response.sendRedirect("membresia.jsp");
                            }
                            return;
                        }
                    } else {
                        mensaje = "Correo o contraseña incorrectos.";
                    }
                } catch (Exception e) {
                    System.err.println("login.jsp: " + e.getMessage());
                    mensaje = "Ocurrió un error al iniciar sesión. Intenta de nuevo.";
                }
            } else {
                mensaje = "Datos inválidos. Verifica e inténtalo de nuevo.";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesi&oacute;n &ndash; CinemaxPlus</title>
  <link rel="stylesheet" href="css/estilos_cinemax.css">
  <style>
    .field-wrap { position: relative; }
    .field-wrap input { padding-right: 44px; width: 100%; box-sizing: border-box; }
    .btn-eye {
      position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
      background: none; border: none; cursor: pointer; color: #666;
      padding: 0; line-height: 0; transition: color .2s;
    }
    .btn-eye:hover { color: #2ecc71; }
    .alert-info {
      background: rgba(46,204,113,.08); border: 1px solid rgba(46,204,113,.35);
      border-radius: 8px; color: #2ecc71; padding: 14px 16px;
      font-size: 13px; text-align: center; margin-bottom: 18px; line-height: 1.6;
    }
    /* Panel de reenvio (oculto por defecto) */
    .resend-panel {
      display: none; margin-top: 12px; padding: 16px;
      background: rgba(255,255,255,.03); border: 1px solid #1e1e1e;
      border-radius: 10px;
    }
    .resend-panel p { color: #888; font-size: 13px; margin: 0 0 10px; }
    .resend-panel .resend-row { display: flex; gap: 8px; }
    .resend-panel .resend-row input {
      flex: 1; padding: 10px 12px; background: #111; border: 1px solid #2a2a2a;
      border-radius: 8px; color: #fff; font-size: 13px; outline: none;
    }
    .resend-panel .resend-row input:focus { border-color: #2ecc71; }
    .btn-resend {
      padding: 10px 16px; background: transparent; border: 1px solid #2ecc71;
      color: #2ecc71; border-radius: 8px; font-size: 13px; cursor: pointer;
      white-space: nowrap; transition: background .2s, color .2s;
    }
    .btn-resend:hover { background: #2ecc71; color: #000; }
    .link-resend {
      display: inline-block; margin-top: 8px; font-size: 12px;
      color: #2ecc71; cursor: pointer; text-decoration: underline;
      background: none; border: none; padding: 0;
    }
  </style>
</head>
<body class="login-body">
  <div class="login-container">
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>
    <h1 class="login-title">Iniciar sesi&oacute;n</h1>

    <%-- Reenvio exitoso --%>
    <% if (reenvioOk) { %>
      <div class="alert-info">
        <svg style="vertical-align:middle;margin-right:6px" width="16" height="16"
             viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
             stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
          <polyline points="22,6 12,13 2,6"/>
        </svg>
        Correo de verificaci&oacute;n enviado. Revisa tu bandeja de entrada.
      </div>

    <%-- Cuenta no verificada: muestra alerta + panel de reenvio --%>
    <% } else if (noVerificado) { %>
      <div class="alert-info">
        <svg style="vertical-align:middle;margin-right:6px" width="16" height="16"
             viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
             stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        <%= mensaje %> Revisa tu bandeja de entrada.
        <br>
        <button type="button" class="link-resend" onclick="mostrarReenvio()">
          &iquest;No recibiste el correo? Reenv&iacute;alo aqu&iacute;
        </button>
      </div>
      <div class="resend-panel" id="resendPanel">
        <p>Ingresa tu correo y te enviaremos un nuevo enlace de activaci&oacute;n.</p>
        <form method="post" action="login.jsp">
          <input type="hidden" name="accion" value="reenviar">
          <div class="resend-row">
            <input type="email" name="email" placeholder="correo@ejemplo.com" required>
            <button type="submit" class="btn-resend">Reenviar</button>
          </div>
        </form>
      </div>

    <%-- Error generico --%>
    <% } else if (mensaje != null) { %>
      <div class="error-message" style="display:block;text-align:center;margin-bottom:18px;">
        <strong><%= mensaje %></strong>
      </div>
    <% } %>

    <%-- Formulario de login --%>
    <form id="loginForm" action="login.jsp" method="post" novalidate>
      <div class="form-group">
        <label for="email">Correo electr&oacute;nico</label>
        <input type="email" id="email" name="email"
               placeholder="correo@ejemplo.com" required>
        <div class="error-message" id="email-error">Ingresa un correo v&aacute;lido</div>
      </div>
      <div class="form-group">
        <label for="password">Contrase&ntilde;a</label>
        <div class="field-wrap">
          <input type="password" id="password" name="password"
                 placeholder="Tu contrase&ntilde;a" required minlength="6">
          <button type="button" class="btn-eye" id="togglePass"
                  aria-label="Mostrar contrase&ntilde;a">
            <svg id="iconEye" width="20" height="20" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>
            </svg>
            <svg id="iconEyeOff" width="20" height="20" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round"
                 stroke-linejoin="round" style="display:none">
              <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/>
              <line x1="1" y1="1" x2="23" y2="23"/>
            </svg>
          </button>
        </div>
        <div class="error-message" id="password-error">M&iacute;nimo 6 caracteres</div>
      </div>
      <button type="submit" class="btn btn-primary">Iniciar sesi&oacute;n</button>
    </form>

    <div class="signup-link">
      &iquest;Primera vez en CinemaxPlus?
      <a href="registro.jsp">Reg&iacute;strate ahora</a>.
    </div>
  </div>

  <script>
    function mostrarReenvio() {
      const panel = document.getElementById('resendPanel');
      panel.style.display = panel.style.display === 'block' ? 'none' : 'block';
    }

    document.getElementById('togglePass').addEventListener('click', function() {
      const inp  = document.getElementById('password');
      const show = inp.type === 'password';
      inp.type = show ? 'text' : 'password';
      document.getElementById('iconEye').style.display    = show ? 'none' : '';
      document.getElementById('iconEyeOff').style.display = show ? ''     : 'none';
    });

    document.getElementById('loginForm').addEventListener('submit', function(e) {
      const email = document.getElementById('email').value;
      const pass  = document.getElementById('password').value;
      document.getElementById('email-error').style.display =
        (!email.includes('@') || !email.includes('.')) ? 'block' : 'none';
      document.getElementById('password-error').style.display =
        pass.length < 6 ? 'block' : 'none';
      if (!email.includes('@') || !email.includes('.') || pass.length < 6)
        e.preventDefault();
    });
  </script>
</body>
</html>
