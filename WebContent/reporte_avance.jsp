<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="modelo.ReporteDAO" %>
<%@ page import="modelo.ReporteDAO.AvanceItem" %>
<%!
    /* Escape basico de HTML para evitar inyeccion en la salida (Modulo 4B). */
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    // -------------------------------------------------------------------
    //  Modulo 3C - Reporte de avance (Persona 5)
    //
    //  El avance es por PERFIL: el perfilKey lo guarda repertorio.jsp
    //  en la sesion al elegir perfil. Guard de sesion (Modulo 4C):
    //  sin login -> login.jsp; sin perfil elegido -> usuarios.jsp.
    // -------------------------------------------------------------------
    if (session.getAttribute("clienteId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String perfilKey = (String) session.getAttribute("perfilKey");
    if (perfilKey == null || perfilKey.trim().isEmpty()) {
        response.sendRedirect("usuarios.jsp");
        return;
    }
    String perfilNombre = (String) session.getAttribute("perfilNombre");
    if (perfilNombre == null || perfilNombre.trim().isEmpty()) {
        perfilNombre = perfilKey;
    }

    List<AvanceItem> avances = ReporteDAO.avance(perfilKey);

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaxPlus - Reporte de avance</title>
    <link rel="icon" type="image/x-icon" href="favicon.ico">
    <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body class="favorites-body">

    <nav class="navbar">
        <a href="repertorio.jsp" class="cinemax-logo" aria-label="CinemaxPlus"></a>
        <div class="nav-links">
            <a href="repertorio.jsp">Inicio</a>
            <a href="favoritos.jsp">Mis Favoritos</a>
            <a href="reporte_avance.jsp" class="active">Mi Avance</a>
            <a href="reporte_cuenta.jsp">Mi Cuenta</a>
        </div>
        <a href="usuarios.jsp" class="user-icon" title="Cambiar perfil">
            <%= esc(perfilNombre.substring(0, 1).toUpperCase()) %>
        </a>
    </nav>

    <main class="main-content" style="padding-top: 90px;">
        <section class="content-section">
            <h1 class="section-title">Mi avance de reproduccion</h1>
            <p style="color: var(--cinemax-gray-light); margin: 8px 0 4px 16px;">
                Perfil: <strong style="color:#fff;"><%= esc(perfilNombre) %></strong>
            </p>

            <% if (avances == null || avances.isEmpty()) { %>
                <div class="avance-empty">
                    <p>Este perfil todavia no ha comenzado a ver ninguna pelicula.</p>
                    <a class="btn btn-primary" href="repertorio.jsp" style="margin-top:18px;">Ir al catalogo</a>
                </div>

            <% } else { %>
                <%
                    int total = avances.size();
                    int terminadas = 0;
                    long sumaPct = 0;
                    for (AvanceItem it : avances) {
                        if (it.isTerminada()) terminadas++;
                        sumaPct += it.getPorcentaje();
                    }
                    int promedio = total > 0 ? (int) Math.round((double) sumaPct / total) : 0;
                %>
                <div class="avance-stats">
                    <div class="stat-card">
                        <span class="stat-num"><%= total %></span>
                        <span class="stat-label">Peliculas en curso</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-num"><%= terminadas %></span>
                        <span class="stat-label">Terminadas</span>
                    </div>
                    <div class="stat-card">
                        <span class="stat-num"><%= promedio %>%</span>
                        <span class="stat-label">Avance promedio</span>
                    </div>
                </div>

                <div class="avance-list">
                    <% for (AvanceItem it : avances) {
                           int pct = it.getPorcentaje();
                           String fecha = it.getFechaVisto() != null ? fmt.format(it.getFechaVisto()) : "";
                    %>
                        <div class="avance-item">
                            <div class="avance-thumb"
                                 style="background-image:url('<%= esc(it.getImagenUrl()) %>');">
                                <% if (it.isTerminada()) { %>
                                    <span class="avance-done">&#10004; Terminada</span>
                                <% } %>
                            </div>
                            <div class="avance-info">
                                <div class="avance-head">
                                    <h3 class="avance-title"><%= esc(it.getTitulo()) %></h3>
                                    <span class="avance-genre"><%= esc(it.getGenero()) %></span>
                                </div>
                                <div class="progress-track" title="<%= pct %>% visto">
                                    <div class="progress-fill" style="width:<%= pct %>%;"></div>
                                </div>
                                <div class="avance-meta">
                                    <span class="avance-pct"><%= pct %>%</span>
                                    <span><%= it.getMinutoActual() %> / <%= it.getDuracionTotal() %> min</span>
                                    <span class="avance-date">Visto: <%= esc(fecha) %></span>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </section>
    </main>

    <footer>
        <p>&copy; 2025 CinemaxPlus Inc.</p>
    </footer>

</body>
</html>
