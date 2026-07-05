<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="modelo.ReporteDAO" %>
<%@ page import="modelo.ReporteDAO.CuentaReporte" %>
<%@ page import="modelo.ReporteDAO.MembresiaItem" %>
<%@ page import="modelo.ReporteDAO.PerfilItem" %>
<%!
    private Integer leerId(Object valor) {
        if (valor == null) return null;
        try {
            return Integer.valueOf(String.valueOf(valor));
        } catch (NumberFormatException e) {
            return null;
        }
    }

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
    // ------------------------------------------------------------
    // Persona 4 - Reporte de cuenta
    // Junta datos de cliente + membresías + perfiles.
    // clienteId SIEMPRE viene de la sesión (post-login).
    // ------------------------------------------------------------
    Integer clienteId = leerId(session.getAttribute("clienteId"));

    if (clienteId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    CuentaReporte reporte = ReporteDAO.cuenta(clienteId);

    SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Cuenta - CinemaxPlus</title>
    <link rel="stylesheet" href="css/estilos_cinemax.css">
    <style>
        .report-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 40px 25px 70px;
        }
        .report-title {
            font-size: 2.4rem;
            margin-bottom: 8px;
        }
        .report-subtitle {
            color: #b3b3b3;
            margin-bottom: 28px;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(230px, 1fr));
            gap: 18px;
            margin-bottom: 30px;
        }
        .summary-card, .report-card {
            background: var(--surface);
            border: 1px solid var(--surface-border);
            border-radius: 14px;
            padding: 22px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.28);
        }
        .summary-label {
            color: #b3b3b3;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: .08em;
            margin-bottom: 8px;
        }
        .summary-value {
            font-size: 1.35rem;
            font-weight: bold;
        }
        .badge {
            display: inline-block;
            padding: 6px 11px;
            border-radius: 30px;
            font-weight: bold;
            font-size: 13px;
        }
        .badge.premium { background: var(--brand-grad); color: #04130d; }
        .badge.regular { background: var(--cinemax-gray-dark); color: var(--cinemax-gray-lighter); border: 1px solid var(--surface-border); }
        .badge.none { background: #333; color: #ddd; }
        .report-card { margin-bottom: 24px; }
        .report-card h2 { margin-bottom: 16px; }
        table {
            width: 100%;
            border-collapse: collapse;
            overflow: hidden;
            border-radius: 10px;
        }
        th, td {
            padding: 13px 12px;
            text-align: left;
            border-bottom: 1px solid #333;
        }
        th { color: #b3b3b3; font-size: 13px; text-transform: uppercase; }
        tr:hover td { background: rgba(255,255,255,0.03); }
        .empty {
            color: #b3b3b3;
            padding: 18px;
            background: rgba(255,255,255,0.04);
            border-radius: 10px;
        }
        .alert {
            background: rgba(229, 9, 20, 0.15);
            border: 1px solid rgba(229, 9, 20, 0.7);
            color: #fff;
            padding: 14px;
            border-radius: 8px;
            margin: 20px 0;
        }
        @media (max-width: 700px) {
            table { font-size: 13px; }
        }
    </style>
</head>
<body class="favorites-body">
    <nav class="navbar">
        <a href="repertorio.jsp" class="cinemax-logo" aria-label="CinemaxPlus"></a>
        <div class="nav-links">
            <a href="repertorio.jsp">Inicio</a>
            <a href="favoritos.jsp">Mis Favoritos</a>
            <a href="reporte_avance.jsp">Mi Avance</a>
            <a href="reporte_cuenta.jsp" class="active">Mi Cuenta</a>
            <a href="membresia.jsp">Membres&iacute;a</a>
        </div>
        <a href="logout.jsp" class="user-icon" title="Cerrar sesi&oacute;n">&#9099;</a>
    </nav>

    <main class="report-container">
        <h1 class="report-title">Reporte de cuenta</h1>
        <p class="report-subtitle">Resumen del cliente, membresía activa e información de perfiles.</p>

        <% if (reporte == null) { %>
            <div class="alert">No se encontró información de tu cuenta. Intenta iniciar sesión de nuevo.</div>
        <% } else { %>
            <%
                MembresiaItem actual = reporte.getMembresiaActual();
                String tipoActual = reporte.getTipoActual();

                // Una membresía con fecha de vencimiento pasada no es "actual"
                boolean vencida = actual != null && actual.getFechaVencimiento() != null
                        && actual.getFechaVencimiento().before(new java.util.Date());

                String claseBadge = "none";
                if (vencida) {
                    tipoActual = actual.getTipo() + " (vencida)";
                } else if (actual != null && "premium".equalsIgnoreCase(actual.getTipo())) {
                    claseBadge = "premium";
                } else if (actual != null && "regular".equalsIgnoreCase(actual.getTipo())) {
                    claseBadge = "regular";
                }
            %>

            <section class="summary-grid">
                <div class="summary-card">
                    <div class="summary-label">Cliente</div>
                    <div class="summary-value"><%= esc(reporte.getNombre()) %></div>
                    <p style="color:#b3b3b3; margin-top:8px;"><%= esc(reporte.getCorreo()) %></p>
                </div>

                <div class="summary-card">
                    <div class="summary-label">Membresía actual</div>
                    <div class="summary-value">
                        <span class="badge <%= claseBadge %>"><%= esc(tipoActual) %></span>
                    </div>
                    <% if (actual != null && actual.getFechaVencimiento() != null) { %>
                        <p style="color:#b3b3b3; margin-top:8px;"><%= vencida ? "Venció" : "Vence" %>: <%= fmt.format(actual.getFechaVencimiento()) %></p>
                    <% } %>
                </div>

                <div class="summary-card">
                    <div class="summary-label">Perfiles creados</div>
                    <div class="summary-value"><%= reporte.getPerfiles().size() %></div>
                </div>

                <div class="summary-card">
                    <div class="summary-label">Fecha de registro</div>
                    <div class="summary-value">
                        <%= reporte.getFechaRegistro() != null ? fmt.format(reporte.getFechaRegistro()) : "Sin fecha" %>
                    </div>
                </div>
            </section>

            <section class="report-card">
                <h2>Historial de membresías</h2>
                <% if (reporte.getMembresias().isEmpty()) { %>
                    <div class="empty">Este cliente todavía no tiene membresías registradas.</div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tipo</th>
                                <th>Inicio</th>
                                <th>Vencimiento</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (MembresiaItem m : reporte.getMembresias()) { %>
                                <tr>
                                    <td><%= m.getId() %></td>
                                    <td><span class="badge <%= "premium".equalsIgnoreCase(m.getTipo()) ? "premium" : "regular" %>"><%= esc(m.getTipo()) %></span></td>
                                    <td><%= m.getFechaInicio() != null ? fmt.format(m.getFechaInicio()) : "-" %></td>
                                    <td><%= m.getFechaVencimiento() != null ? fmt.format(m.getFechaVencimiento()) : "-" %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </section>

            <section class="report-card">
                <h2>Perfiles de la cuenta</h2>
                <% if (reporte.getPerfiles().isEmpty()) { %>
                    <div class="empty">Este cliente no tiene perfiles creados.</div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Perfil key</th>
                                <th>Nombre</th>
                                <th>Categoría favorita</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (PerfilItem p : reporte.getPerfiles()) { %>
                                <tr>
                                    <td><%= esc(p.getPerfilKey()) %></td>
                                    <td><%= esc(p.getNombre()) %></td>
                                    <td><%= esc(p.getCatFav()) %></td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </section>
        <% } %>
    </main>
</body>
</html>
