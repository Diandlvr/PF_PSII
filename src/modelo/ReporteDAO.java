package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de reportes de CinemaxPlus.
 *
 * Persona 4 - Reporte de cuenta.
 * Persona 5 - Reporte de avance.
 */
public class ReporteDAO {

    // =========================================================
    // Persona 4 - Reporte de cuenta
    // =========================================================

    public static class CuentaReporte {
        private int clienteId;
        private String nombre;
        private String correo;
        private Timestamp fechaRegistro;
        private List<MembresiaItem> membresias = new ArrayList<MembresiaItem>();
        private List<PerfilItem> perfiles = new ArrayList<PerfilItem>();

        public int getClienteId() {
            return clienteId;
        }

        public String getNombre() {
            return nombre;
        }

        public String getCorreo() {
            return correo;
        }

        public Timestamp getFechaRegistro() {
            return fechaRegistro;
        }

        public List<MembresiaItem> getMembresias() {
            return membresias;
        }

        public List<PerfilItem> getPerfiles() {
            return perfiles;
        }

        public MembresiaItem getMembresiaActual() {
            if (membresias == null || membresias.isEmpty()) {
                return null;
            }
            return membresias.get(0);
        }

        public String getTipoActual() {
            MembresiaItem actual = getMembresiaActual();

            if (actual == null) {
                return "Sin membresía registrada";
            }

            return actual.getTipo();
        }
    }

    public static class MembresiaItem {
        private int id;
        private String tipo;
        private Timestamp fechaInicio;
        private Timestamp fechaVencimiento;

        public int getId() {
            return id;
        }

        public String getTipo() {
            return tipo;
        }

        public Timestamp getFechaInicio() {
            return fechaInicio;
        }

        public Timestamp getFechaVencimiento() {
            return fechaVencimiento;
        }
    }

    public static class PerfilItem {
        private String perfilKey;
        private String nombre;
        private String catFav;

        public String getPerfilKey() {
            return perfilKey;
        }

        public String getNombre() {
            return nombre;
        }

        public String getCatFav() {
            return catFav;
        }
    }

    /**
     * Reporte de cuenta por usuario.
     * Une información de cliente + membresías + perfiles.
     */
    public static CuentaReporte cuenta(int clienteId) {
        if (clienteId <= 0) {
            return null;
        }

        CuentaReporte reporte = cargarCliente(clienteId);

        if (reporte == null) {
            return null;
        }

        cargarMembresias(reporte, clienteId);
        cargarPerfiles(reporte, clienteId);

        return reporte;
    }

    private static CuentaReporte cargarCliente(int clienteId) {
        String sql = "SELECT id, nombre, correo, fecha_registro "
                   + "FROM cliente "
                   + "WHERE id = ?";

        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, clienteId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CuentaReporte reporte = new CuentaReporte();

                    reporte.clienteId = rs.getInt("id");
                    reporte.nombre = rs.getString("nombre");
                    reporte.correo = rs.getString("correo");
                    reporte.fechaRegistro = rs.getTimestamp("fecha_registro");

                    return reporte;
                }
            }

        } catch (SQLException e) {
            System.err.println("ReporteDAO.cargarCliente() error: " + e.getMessage());
        }

        return null;
    }

    private static void cargarMembresias(CuentaReporte reporte, int clienteId) {
        String sql = "SELECT id, tipo, fecha_inicio, fecha_vencimiento "
                   + "FROM membresias "
                   + "WHERE cliente_id = ? "
                   + "ORDER BY fecha_inicio DESC, id DESC";

        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, clienteId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MembresiaItem item = new MembresiaItem();

                    item.id = rs.getInt("id");
                    item.tipo = rs.getString("tipo");
                    item.fechaInicio = rs.getTimestamp("fecha_inicio");
                    item.fechaVencimiento = rs.getTimestamp("fecha_vencimiento");

                    reporte.membresias.add(item);
                }
            }

        } catch (SQLException e) {
            System.err.println("ReporteDAO.cargarMembresias() error: " + e.getMessage());
        }
    }

    private static void cargarPerfiles(CuentaReporte reporte, int clienteId) {
        String sql = "SELECT perfil_key, nombre, cat_fav "
                   + "FROM usuarios "
                   + "WHERE cliente_id = ? "
                   + "ORDER BY nombre ASC";

        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, clienteId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PerfilItem item = new PerfilItem();

                    item.perfilKey = rs.getString("perfil_key");
                    item.nombre = rs.getString("nombre");
                    item.catFav = rs.getString("cat_fav");

                    reporte.perfiles.add(item);
                }
            }

        } catch (SQLException e) {
            System.err.println("ReporteDAO.cargarPerfiles() error: " + e.getMessage());
        }
    }

    // =========================================================
    // Persona 5 - Reporte de avance
    // Se conserva para no borrar el trabajo de la otra persona.
    // =========================================================

    public static class AvanceItem {
        private int idContenido;
        private String titulo;
        private String genero;
        private String imagenUrl;
        private int minutoActual;
        private int duracionTotal;
        private Timestamp fechaVisto;

        public int getIdContenido() {
            return idContenido;
        }

        public String getTitulo() {
            return titulo;
        }

        public String getGenero() {
            return genero;
        }

        public String getImagenUrl() {
            return imagenUrl;
        }

        public int getMinutoActual() {
            return minutoActual;
        }

        public int getDuracionTotal() {
            return duracionTotal;
        }

        public Timestamp getFechaVisto() {
            return fechaVisto;
        }

        public int getPorcentaje() {
            if (duracionTotal <= 0) {
                return 0;
            }

            long porcentaje = Math.round((minutoActual * 100.0) / duracionTotal);

            if (porcentaje < 0) {
                porcentaje = 0;
            }

            if (porcentaje > 100) {
                porcentaje = 100;
            }

            return (int) porcentaje;
        }

        public boolean isTerminada() {
            return getPorcentaje() >= 100;
        }
    }

    /**
     * Devuelve el avance de reproducción de un perfil.
     * El avance se maneja por perfilKey, no por clienteId.
     */
    public static List<AvanceItem> avance(String perfilKey) {
        List<AvanceItem> lista = new ArrayList<AvanceItem>();

        if (perfilKey == null || perfilKey.trim().isEmpty()) {
            return lista;
        }

        String sql = "SELECT c.id_contenido, c.titulo, c.genero, c.imagen_url, "
                   + "p.minuto_actual, p.duracion_total, p.fecha_visto "
                   + "FROM progreso p "
                   + "JOIN contenido c ON c.id_contenido = p.id_contenido "
                   + "WHERE p.usuario = ? "
                   + "ORDER BY p.fecha_visto DESC";

        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, perfilKey);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AvanceItem item = new AvanceItem();

                    item.idContenido = rs.getInt("id_contenido");
                    item.titulo = rs.getString("titulo");
                    item.genero = rs.getString("genero");
                    item.imagenUrl = rs.getString("imagen_url");
                    item.minutoActual = rs.getInt("minuto_actual");
                    item.duracionTotal = rs.getInt("duracion_total");
                    item.fechaVisto = rs.getTimestamp("fecha_visto");

                    lista.add(item);
                }
            }

        } catch (SQLException e) {
            System.err.println("ReporteDAO.avance() error: " + e.getMessage());
        }

        return lista;
    }
}
