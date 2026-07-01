<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="modelo.ConexionDB" %>
<%
    // Prueba de conexion a la base de datos (Fase 0).
    String estadoBD;
    boolean conectado = false;
    try (Connection con = ConexionDB.getConexion()) {
        conectado = (con != null && !con.isClosed());
        estadoBD = conectado
            ? "Conexion a la base de datos cinemax_plus establecida correctamente."
            : "No se pudo abrir la conexion a la base de datos.";
    } catch (Exception e) {
        estadoBD = "Error al conectar con la base de datos: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaxPlus - Prueba Tomcat/JSP</title>
    <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body class="landing-body">

    <div class="landing-overlay">

        <div class="landing-text">
            <h1>CinemaxPlus</h1>
            <p>Fase 0 - Migracion de PHP a Java JSP + Tomcat 9</p>
        </div>

        <div style="margin: 30px auto; max-width: 640px; text-align: center;">
            <p style="color:#2ecc71; font-size:1.1rem;">
                &#10004; Tomcat esta sirviendo JSP correctamente.
            </p>
            <p style="color:<%= conectado ? "#2ecc71" : "#e74c3c" %>; font-size:1.05rem;">
                <%= conectado ? "&#10004; " : "&#10006; " %><%= estadoBD %>
            </p>
            <p style="color:#bbb; font-size:0.9rem;">
                Hora del servidor: <%= new java.util.Date() %>
            </p>
        </div>

    </div>

    <footer style="position: absolute; bottom: 0; width: 100%; background: transparent; border: none;">
        <p style="color: #bbb;">&copy; 2025 CinemaxPlus Inc.</p>
    </footer>

</body>
</html>
