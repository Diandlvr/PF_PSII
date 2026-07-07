package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Lista "Ver mas tarde" por perfil (usuario = perfil_key).
 * Independiente de favoritos: se agrega/quita a mano, y se quita sola
 * cuando el perfil empieza a reproducir la pelicula.
 */
public class VerDespuesDAO {

    /** Agrega o quita; devuelve true si quedo en la lista, false si se quito. */
    public static boolean toggle(String perfilKey, int idContenido) throws SQLException {
        try (Connection con = ConexionDB.getConexion()) {
            try (PreparedStatement del = con.prepareStatement(
                    "DELETE FROM ver_despues WHERE usuario=? AND id_contenido=?")) {
                del.setString(1, perfilKey);
                del.setInt(2, idContenido);
                if (del.executeUpdate() > 0) return false;
            }
            try (PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO ver_despues (usuario, id_contenido) VALUES (?, ?)")) {
                ins.setString(1, perfilKey);
                ins.setInt(2, idContenido);
                ins.executeUpdate();
            }
            return true;
        }
    }

    /** Se llama al abrir el reproductor: sale de la lista automaticamente. */
    public static void quitar(String perfilKey, int idContenido) {
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM ver_despues WHERE usuario=? AND id_contenido=?")) {
            ps.setString(1, perfilKey);
            ps.setInt(2, idContenido);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("VerDespuesDAO.quitar() error: " + e.getMessage());
        }
    }

    public static Set<Integer> getIds(String perfilKey) throws SQLException {
        Set<Integer> ids = new HashSet<Integer>();
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT id_contenido FROM ver_despues WHERE usuario=?")) {
            ps.setString(1, perfilKey);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        }
        return ids;
    }

    /** Contenidos completos de la lista, para pintar la fila "Ver mas tarde". */
    public static List<Map<String, String>> listar(String perfilKey) throws SQLException {
        List<Map<String, String>> lista = new ArrayList<Map<String, String>>();
        String sql = "SELECT c.id_contenido, c.titulo, c.genero, c.imagen_url "
                   + "FROM ver_despues v JOIN contenido c ON c.id_contenido = v.id_contenido "
                   + "WHERE v.usuario = ? ORDER BY v.fecha_agregado DESC";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, perfilKey);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> fila = new LinkedHashMap<String, String>();
                    fila.put("id", rs.getString("id_contenido"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("genero", rs.getString("genero"));
                    fila.put("imagen_url", rs.getString("imagen_url"));
                    lista.add(fila);
                }
            }
        }
        return lista;
    }
}
