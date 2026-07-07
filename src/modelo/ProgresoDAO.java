package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Progreso de reproduccion por perfil (usuario = perfil_key).
 */
public class ProgresoDAO {

    /** [minutoActual, duracionTotal] del avance guardado, o null si no ha empezado. */
    public static int[] obtener(String perfilKey, int idContenido) {
        String sql = "SELECT minuto_actual, duracion_total FROM progreso "
                   + "WHERE usuario = ? AND id_contenido = ?";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, perfilKey);
            ps.setInt(2, idContenido);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new int[]{ rs.getInt("minuto_actual"), rs.getInt("duracion_total") };
                }
            }
        } catch (SQLException e) {
            System.err.println("ProgresoDAO.obtener() error: " + e.getMessage());
        }
        return null;
    }

    public static void guardar(String perfilKey, int idContenido,
                                int minutoActual, int duracionTotal) {
        String sql = "INSERT INTO progreso (usuario, id_contenido, minuto_actual, duracion_total) "
                   + "VALUES (?, ?, ?, ?) "
                   + "ON DUPLICATE KEY UPDATE minuto_actual = VALUES(minuto_actual), "
                   + "fecha_visto = CURRENT_TIMESTAMP";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, perfilKey);
            ps.setInt(2, idContenido);
            ps.setInt(3, minutoActual);
            ps.setInt(4, duracionTotal);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("ProgresoDAO.guardar() error: " + e.getMessage());
        }
    }

    /** Mapa id_contenido -> % visto, para TODAS las peliculas con avance guardado (incluye terminadas). */
    public static Map<Integer, Integer> obtenerTodos(String perfilKey) {
        Map<Integer, Integer> mapa = new LinkedHashMap<>();
        String sql = "SELECT id_contenido, minuto_actual, duracion_total FROM progreso WHERE usuario = ?";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, perfilKey);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int min = rs.getInt("minuto_actual");
                    int tot = rs.getInt("duracion_total");
                    int pct = tot > 0 ? (int) Math.round(min * 100.0 / tot) : 0;
                    if (pct > 100) pct = 100;
                    mapa.put(rs.getInt("id_contenido"), pct);
                }
            }
        } catch (SQLException e) {
            System.err.println("ProgresoDAO.obtenerTodos() error: " + e.getMessage());
        }
        return mapa;
    }

    /** Peliculas empezadas pero no terminadas, mas recientes primero. Para "Continuar viendo". */
    public static List<Map<String, String>> continuarViendo(String perfilKey, int limite) {
        List<Map<String, String>> lista = new ArrayList<>();
        String sql = "SELECT c.id_contenido, c.titulo, c.genero, c.imagen_url, "
                   + "p.minuto_actual, p.duracion_total "
                   + "FROM progreso p JOIN contenido c ON c.id_contenido = p.id_contenido "
                   + "WHERE p.usuario = ? AND p.minuto_actual < p.duracion_total "
                   + "ORDER BY p.fecha_visto DESC LIMIT ?";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, perfilKey);
            ps.setInt(2, limite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int min = rs.getInt("minuto_actual");
                    int tot = rs.getInt("duracion_total");
                    Map<String, String> fila = new LinkedHashMap<String, String>();
                    fila.put("id", rs.getString("id_contenido"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("genero", rs.getString("genero"));
                    fila.put("imagen_url", rs.getString("imagen_url"));
                    fila.put("pct", String.valueOf(tot > 0 ? Math.round(min * 100.0 / tot) : 0));
                    lista.add(fila);
                }
            }
        } catch (SQLException e) {
            System.err.println("ProgresoDAO.continuarViendo() error: " + e.getMessage());
        }
        return lista;
    }
}
