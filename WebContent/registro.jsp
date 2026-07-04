<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, java.util.UUID, modelo.ConexionDB, modelo.EmailUtil" %>
<%
    String mensaje   = null;
    boolean enviado  = false;
    String emailEnv  = "";

    if ("POST".equals(request.getMethod())) {
        String email  = request.getParameter("email")     != null ? request.getParameter("email").trim()     : "";
        String pass1  = request.getParameter("password")  != null ? request.getParameter("password").trim()  : "";
        String pass2  = request.getParameter("password2") != null ? request.getParameter("password2").trim() : "";
        String nombre = request.getParameter("name")      != null ? request.getParameter("name").trim()      : "";

        if (!email.contains("@") || pass1.length() < 6 || nombre.isEmpty()) {
            mensaje = "Datos inválidos. Verifica todos los campos.";
        } else if (!pass1.equals(pass2)) {
            mensaje = "Las contraseñas no coinciden.";
        } else {
            try (Connection con = ConexionDB.getConexion()) {
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT COUNT(*) FROM cliente WHERE correo = ?");
                psCheck.setString(1, email);
                ResultSet rs = psCheck.executeQuery(); rs.next();

                if (rs.getInt(1) > 0) {
                    mensaje = "El correo ya está registrado.";
                } else {
                    String token = UUID.randomUUID().toString();
                    PreparedStatement psIns = con.prepareStatement(
                        "INSERT INTO cliente (correo, contrasena, nombre, verificado, token_verificacion) " +
                        "VALUES (?, ?, ?, 0, ?)",
                        PreparedStatement.RETURN_GENERATED_KEYS);
                    psIns.setString(1, email);
                    psIns.setString(2, pass1);
                    psIns.setString(3, nombre);
                    psIns.setString(4, token);

                    if (psIns.executeUpdate() > 0) {
                        try {
                            EmailUtil.enviarConfirmacion(email, nombre, token);
                            enviado = true;
                            emailEnv = email;
                        } catch (Exception mailEx) {
                            mensaje = "Cuenta creada, pero no se pudo enviar el correo: " + mailEx.getMessage();
                        }
                    } else {
                        mensaje = "No se pudo registrar. Intenta de nuevo.";
                    }
                }
            } catch (Exception e) {
                mensaje = "Error en registro: " + e.getMessage();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Registro &ndash; CinemaxPlus</title>
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
    .confirm-status {
      position: absolute; right: 44px; top: 50%; transform: translateY(-50%);
      line-height: 0;
    }
    /* Barra de fuerza */
    .strength-bar  { height: 4px; border-radius: 4px; background: #1a1a1a; margin-top: 7px; overflow: hidden; }
    .strength-fill { height: 100%; width: 0; border-radius: 4px; transition: width .35s, background .35s; }
    .strength-lbl  { font-size: 11px; color: #555; margin-top: 4px; min-height: 16px; transition: color .35s; }
    /* Pantalla "correo enviado" */
    .sent-card {
      width: 100%; max-width: 460px; text-align: center;
      background: rgba(12,24,19,.94); border: 1px solid rgba(255,255,255,.08);
      border-radius: 20px; padding: 52px 40px;
      box-shadow: 0 30px 70px rgba(0,0,0,.5);
    }
    .sent-card svg.hero { display: block; margin: 0 auto 24px; }
    .sent-card h1 { font-size: 22px; color: #fff; margin: 0 0 10px; }
    .sent-card p  { color: #aaa; font-size: 15px; line-height: 1.7; margin: 0 0 6px; }
    .email-chip {
      display: inline-block; background: #0d1f15; color: #2ecc71;
      border: 1px solid rgba(46,204,113,.4); border-radius: 20px;
      padding: 5px 18px; font-size: 14px; margin: 10px 0 28px;
    }
    .hint { font-size: 12px; color: #444; margin-top: 16px; }
  </style>
</head>
<body class="register-body">

<% if (enviado) { %>
  <!-- Pantalla de correo enviado -->
  <div class="sent-card">
    <svg class="hero" width="60" height="60" viewBox="0 0 24 24" fill="none" stroke="#2ecc71"
         stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
      <polyline points="22,6 12,13 2,6"/>
    </svg>
    <h1>Revisa tu correo</h1>
    <p>Enviamos un enlace de confirmaci&oacute;n a</p>
    <div class="email-chip"><%= emailEnv %></div>
    <p>Haz clic en el enlace para activar tu cuenta.</p>
    <p class="hint">Si no lo ves, revisa la carpeta de Spam.</p>
    <a href="login.jsp" class="btn btn-secondary" style="margin-top:24px;">
      Volver al inicio de sesi&oacute;n
    </a>
  </div>

<% } else { %>
  <!-- Formulario de registro -->
  <div class="register-container">
    <div class="cinemax-logo"></div>
    <h1 class="register-title">Crear una cuenta</h1>

    <% if (mensaje != null) { %>
      <div class="error-message" style="display:block;text-align:center;margin-bottom:20px;">
        <strong><%= mensaje %></strong>
      </div>
    <% } %>

    <form id="registerForm" action="registro.jsp" method="post" novalidate>

      <!-- Nombre -->
      <div class="form-group">
        <label for="name">Nombre completo</label>
        <input type="text" id="name" name="name" placeholder="Tu nombre" required>
        <div class="error-message" id="name-error">Por favor ingresa tu nombre</div>
      </div>

      <!-- Correo -->
      <div class="form-group">
        <label for="email">Correo electr&oacute;nico</label>
        <input type="email" id="email" name="email" placeholder="correo@ejemplo.com" required>
        <div class="error-message" id="email-error">Ingresa un correo v&aacute;lido</div>
      </div>

      <!-- Contrasena -->
      <div class="form-group">
        <label for="password">Contrase&ntilde;a</label>
        <div class="field-wrap">
          <input type="password" id="password" name="password"
                 placeholder="M&iacute;nimo 6 caracteres" required minlength="6"
                 oninput="evaluarFuerza(this.value); verificarCoincidencia()">
          <button type="button" class="btn-eye" id="toggleP1" aria-label="Ver contrase&ntilde;a">
            <svg id="eyeP1" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            <svg id="eyeOffP1" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
          </button>
        </div>
        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
        <div class="strength-lbl" id="strengthLbl"></div>
        <div class="error-message" id="password-error">M&iacute;nimo 6 caracteres</div>
      </div>

      <!-- Confirmar contrasena -->
      <div class="form-group">
        <label for="password2">Confirmar contrase&ntilde;a</label>
        <div class="field-wrap">
          <input type="password" id="password2" name="password2"
                 placeholder="Repite la contrase&ntilde;a" required
                 oninput="verificarCoincidencia()">
          <span class="confirm-status" id="confirmIcon"></span>
          <button type="button" class="btn-eye" id="toggleP2" aria-label="Ver contrase&ntilde;a">
            <svg id="eyeP2" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            <svg id="eyeOffP2" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="display:none"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"/><line x1="1" y1="1" x2="23" y2="23"/></svg>
          </button>
        </div>
        <div class="error-message" id="password2-error">Las contrase&ntilde;as no coinciden</div>
      </div>

      <button type="submit" class="btn btn-primary" style="margin-top:8px;">
        Crear cuenta
      </button>
    </form>

    <div class="login-link">
      &iquest;Ya tienes una cuenta? <a href="login.jsp">Inicia sesi&oacute;n</a>
    </div>
  </div>
<% } %>

<script>
  // SVG icons para el indicador de coincidencia
  const svgOk = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2ecc71" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';
  const svgX  = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#e74c3c" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>';

  // Toggle ver/ocultar contrasena
  function toggleEye(inputId, eyeId, eyeOffId) {
    const inp  = document.getElementById(inputId);
    const show = inp.type === 'password';
    inp.type = show ? 'text' : 'password';
    document.getElementById(eyeId).style.display    = show ? 'none' : '';
    document.getElementById(eyeOffId).style.display = show ? ''     : 'none';
  }
  document.getElementById('toggleP1').addEventListener('click', () => toggleEye('password',  'eyeP1', 'eyeOffP1'));
  document.getElementById('toggleP2').addEventListener('click', () => toggleEye('password2', 'eyeP2', 'eyeOffP2'));

  // Barra de fuerza de contrasena
  function evaluarFuerza(val) {
    let score = 0;
    if (val.length >= 6)           score++;
    if (val.length >= 10)          score++;
    if (/[A-Z]/.test(val))         score++;
    if (/[0-9]/.test(val))         score++;
    if (/[^A-Za-z0-9]/.test(val))  score++;
    const niveles = [
      { pct:'0%',   color:'#1a1a1a', txt:'' },
      { pct:'25%',  color:'#e74c3c', txt:'Muy débil' },
      { pct:'50%',  color:'#e67e22', txt:'Débil' },
      { pct:'70%',  color:'#f1c40f', txt:'Aceptable' },
      { pct:'85%',  color:'#2ecc71', txt:'Fuerte' },
      { pct:'100%', color:'#27ae60', txt:'Muy fuerte' },
    ];
    const n = niveles[score] || niveles[0];
    const fill = document.getElementById('strengthFill');
    fill.style.width      = n.pct;
    fill.style.background = n.color;
    const lbl = document.getElementById('strengthLbl');
    lbl.textContent = n.txt;
    lbl.style.color = n.color;
  }

  // Verificar que las dos contrasenas coincidan
  function verificarCoincidencia() {
    const p1  = document.getElementById('password').value;
    const p2  = document.getElementById('password2').value;
    const ico = document.getElementById('confirmIcon');
    ico.innerHTML = p2.length === 0 ? '' : (p1 === p2 ? svgOk : svgX);
  }

  // Validacion al enviar
  document.getElementById('registerForm').addEventListener('submit', function(e) {
    const nombre = document.getElementById('name').value.trim();
    const email  = document.getElementById('email').value;
    const pass1  = document.getElementById('password').value;
    const pass2  = document.getElementById('password2').value;
    let ok = true;
    if (nombre === '') { document.getElementById('name-error').style.display = 'block'; ok = false; }
    else { document.getElementById('name-error').style.display = 'none'; }
    if (!email.includes('@')) { document.getElementById('email-error').style.display = 'block'; ok = false; }
    else { document.getElementById('email-error').style.display = 'none'; }
    if (pass1.length < 6) { document.getElementById('password-error').style.display = 'block'; ok = false; }
    else { document.getElementById('password-error').style.display = 'none'; }
    if (pass1 !== pass2) { document.getElementById('password2-error').style.display = 'block'; ok = false; }
    else { document.getElementById('password2-error').style.display = 'none'; }
    if (!ok) e.preventDefault();
  });
</script>
</body>
</html>
