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
 * Persona 5 - Modulo 3C (Reporte de avance / N3).
 * (El metodo cuenta() del Modulo 3B lo agrega la Persona 4 en esta misma clase.)
 *
 * El avance de reproduccion es por PERFIL: la tabla `progreso` guarda el
 * perfil_key en la columna `usuario` (igual que `favs`), NO el id del cliente.
 */
public class ReporteDAO {

    /**
     * Fila del reporte de avance: una pelicula que el perfil ha visto (o empezado),
     * con su porcentaje de avance ya calculado.
     */
    public static class AvanceItem {
        private int idContenido;
        private String titulo;
        private String genero;
        private String imagenUrl;
        private String youtubeId;
        private int minutoActual;
        private int duracionTotal;
        private Timestamp fechaVisto;

        public int getIdContenido()   { return idContenido; }
        public String getTitulo()     { return titulo; }
        public String getGenero()     { return genero; }
        public String getImagenUrl()  { return imagenUrl; }
        public String getYoutubeId()  { return youtubeId; }
        public int getMinutoActual()  { return minutoActual; }
        public int getDuracionTotal() { return duracionTotal; }
        public Timestamp getFechaVisto() { return fechaVisto; }

        /** Porcentaje visto (0-100), redondeado y acotado. */
        public int getPorcentaje() {
            if (duracionTotal <= 0) {
                return 0;
            }
            long pct = Math.round((minutoActual * 100.0) / duracionTotal);
            if (pct < 0)   pct = 0;
            if (pct > 100) pct = 100;
            return (int) pct;
        }

        /** true si la pelicula ya se termino de ver. */
        public boolean isTerminada() {
            return getPorcentaje() >= 100;
        }
    }

    /**
     * Devuelve el avance de reproduccion de un perfil, ordenado por lo mas
     * reciente primero. Une `progreso` con `contenido` para traer el titulo,
     * genero e imagen de cada pelicula.
     *
     * @param perfilKey clave de perfil (ej. "1_carlos"), guardada en sesion.
     * @return lista de AvanceItem; vacia si el perfil no tiene avances o si
     *         perfilKey es nulo/vacio.
     */
    public static List<AvanceItem> avance(String perfilKey) {
        List<AvanceItem> lista = new ArrayList<>();

        if (perfilKey == null || perfilKey.trim().isEmpty()) {
            return lista;
        }

        String sql =
            "SELECT c.id_contenido, c.titulo, c.genero, c.imagen_url, c.youtube_id, "
          + "       p.minuto_actual, p.duracion_total, p.fecha_visto "
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
                    item.idContenido   = rs.getInt("id_contenido");
                    item.titulo        = rs.getString("titulo");
                    item.genero        = rs.getString("genero");
                    item.imagenUrl     = rs.getString("imagen_url");
                    item.youtubeId     = rs.getString("youtube_id");
                    item.minutoActual  = rs.getInt("minuto_actual");
                    item.duracionTotal = rs.getInt("duracion_total");
                    item.fechaVisto    = rs.getTimestamp("fecha_visto");
                    lista.add(item);
                }
            }
        } catch (SQLException e) {
            // En el patron del curso no propagamos la excepcion a la vista:
            // se registra y se devuelve lo que se haya alcanzado a cargar.
            System.err.println("ReporteDAO.avance() error: " + e.getMessage());
        }

        return lista;
    }
}
