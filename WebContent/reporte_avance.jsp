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
                .replace("\"", "&quot;");
    }
%>
<%
    // -------------------------------------------------------------------
    //  Modulo 3C - Reporte de avance (Persona 5)
    //
    //  El avance es por PERFIL: leemos el perfilKey de la sesion.
    //  Guard de sesion (Modulo 4C): sin perfil no hay reporte.
    //
    //  Mientras la opcion 2 (perfiles) no guarde perfilKey en sesion,
    //  se permite ?perfil=1_carlos como MODO DE PRUEBA. Cuando el login
    //  este listo, este JSP funciona solo con la sesion sin cambios.
    // -------------------------------------------------------------------
    String perfilKey = (String) session.getAttribute("perfilKey");
    boolean modoPrueba = false;
    if (perfilKey == null || perfilKey.trim().isEmpty()) {
        String pParam = request.getParameter("perfil");
        if (pParam != null && !pParam.trim().isEmpty()) {
            perfilKey = pParam.trim();
            modoPrueba = true;
        }
    }

    List<AvanceItem> avances = null;
    if (perfilKey != null && !perfilKey.trim().isEmpty()) {
        avances = ReporteDAO.avance(perfilKey);
    }

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CinemaxPlus - Reporte de avance</title>
    <link rel="stylesheet" href="css/estilos_cinemax.css">
</head>
<body class="favorites-body">

    <nav class="navbar">
        <a href="repertorio.jsp" class="cinemax-logo" aria-label="CinemaxPlus"></a>
        <div class="nav-links">
            <a href="repertorio.jsp">Catalogo</a>
            <a href="favoritos.jsp">Favoritos</a>
            <a href="reporte_cuenta.jsp">Mi cuenta</a>
            <a href="reporte_avance.jsp" class="active">Mi avance</a>
            <a href="logout.jsp" class="user-icon" title="Cerrar sesion">&#9099;</a>
        </div>
    </nav>

    <main class="main-content" style="padding-top: 90px;">
        <section class="content-section">
            <h1 class="section-title">Mi avance de reproduccion</h1>
            <p style="color: var(--cinemax-gray-light); margin: 8px 0 4px 16px;">
                <% if (perfilKey != null && !perfilKey.trim().isEmpty()) { %>
                    Perfil: <strong style="color:#fff;"><%= esc(perfilKey) %></strong>
                    <% if (modoPrueba) { %>
                        <span style="color:#e0b04a; font-size:0.85rem;">(modo prueba)</span>
                    <% } %>
                <% } %>
            </p>

            <% if (perfilKey == null || perfilKey.trim().isEmpty()) { %>
                <%-- Sin perfil en sesion: cuando exista el login esto redirige a login.jsp.
                     Por ahora mostramos un aviso testeable. --%>
                <div class="avance-empty">
                    <p>No hay un perfil activo en la sesion.</p>
                    <p style="margin-top:10px;">Para probar el reporte mientras el login no esta listo,
                       abre la pagina con un perfil de ejemplo:</p>
                    <div style="margin-top:16px; display:flex; gap:10px; flex-wrap:wrap; justify-content:center;">
                        <a class="btn btn-secondary" href="reporte_avance.jsp?perfil=1_carlos">1_carlos</a>
                        <a class="btn btn-secondary" href="reporte_avance.jsp?perfil=1_jamir">1_jamir</a>
                        <a class="btn btn-secondary" href="reporte_avance.jsp?perfil=4_juan">4_juan</a>
                    </div>
                </div>

            <% } else if (avances == null || avances.isEmpty()) { %>
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
