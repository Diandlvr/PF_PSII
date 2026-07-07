<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ page import="java.sql.*, modelo.ConexionDB" %>
<%
    String token = request.getParameter("token");
    boolean exito = false;
    String mensajeError = null;

    if (token != null && !token.trim().isEmpty()) {
        try (Connection con = ConexionDB.getConexion()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT id FROM cliente WHERE token_verificacion = ? AND verificado = 0");
            ps.setString(1, token.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                PreparedStatement upd = con.prepareStatement(
                    "UPDATE cliente SET verificado = 1, token_verificacion = NULL WHERE id = ?");
                upd.setInt(1, rs.getInt("id"));
                upd.executeUpdate();
                exito = true;
            } else {
                mensajeError = "El enlace no es válido o ya fue utilizado.";
            }
        } catch (Exception e) {
            mensajeError = "Error al verificar: " + e.getMessage();
        }
    } else {
        mensajeError = "Enlace incompleto o expirado.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Verificaci&oacute;n &ndash; CinemaxPlus</title>
  <link rel="icon" type="image/x-icon" href="favicon.ico">
  <link rel="stylesheet" href="css/estilos_cinemax.css">
  <style>
    .verify-card {
      width: 100%; max-width: 440px; text-align: center;
      background: rgba(12,24,19,.94); border: 1px solid rgba(255,255,255,.08);
      border-radius: 20px; padding: 52px 40px;
      box-shadow: 0 30px 70px rgba(0,0,0,.5);
    }
    .verify-card svg.hero { display: block; margin: 0 auto 24px; }
    .verify-card h1 { font-size: 22px; color: #fff; margin: 0 0 12px; }
    .verify-card p  { color: #aaa; font-size: 15px; line-height: 1.6; margin-bottom: 28px; }
  </style>
</head>
<body class="login-body">
  <div class="verify-card">
    <% if (exito) { %>
      <svg class="hero" width="60" height="60" viewBox="0 0 24 24" fill="none"
           stroke="#2ecc71" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
        <polyline points="22 4 12 14.01 9 11.01"/>
      </svg>
      <h1>Cuenta verificada</h1>
      <p>Tu correo ha sido confirmado. Ya puedes iniciar sesi&oacute;n en CinemaxPlus.</p>
      <a href="login.jsp" class="btn btn-primary">Iniciar sesi&oacute;n</a>
    <% } else { %>
      <svg class="hero" width="60" height="60" viewBox="0 0 24 24" fill="none"
           stroke="#e74c3c" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"/>
        <line x1="15" y1="9" x2="9" y2="15"/>
        <line x1="9" y1="9" x2="15" y2="15"/>
      </svg>
      <h1>Enlace inv&aacute;lido</h1>
      <p><%= mensajeError %></p>
      <a href="registro.jsp" class="btn btn-secondary">Volver al registro</a>
    <% } %>
  </div>
</body>
</html>
