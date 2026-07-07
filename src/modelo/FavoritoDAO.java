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

public class FavoritoDAO {

    /** IDs de contenido que el perfil tiene marcados como favoritos. */
    public static Set<Integer> getIds(String perfilKey) throws SQLException {
        Set<Integer> ids = new HashSet<>();
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(
                 "SELECT id_contenido FROM favs WHERE usuario = ?")) {
            ps.setString(1, perfilKey);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt(1));
            }
        }
        return ids;
    }

    /** Detalle completo de los favoritos de un perfil, ordenados por fecha desc. */
    public static List<Map<String, String>> getContenido(String perfilKey)
            throws SQLException {
        List<Map<String, String>> lista = new ArrayList<>();
        String sql = "SELECT c.id_contenido, c.titulo, c.genero, c.imagen_url,"
                   + " f.fecha_agregado"
                   + " FROM favs f"
                   + " JOIN contenido c ON f.id_contenido = c.id_contenido"
                   + " WHERE f.usuario = ?"
                   + " ORDER BY f.fecha_agregado DESC";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, perfilKey);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> fila = new LinkedHashMap<>();
                    fila.put("id",             rs.getString("id_contenido"));
                    fila.put("titulo",         rs.getString("titulo"));
                    fila.put("genero",         rs.getString("genero"));
                    fila.put("imagen_url",     rs.getString("imagen_url"));
                    fila.put("fecha_agregado", rs.getString("fecha_agregado"));
                    lista.add(fila);
                }
            }
        }
        return lista;
    }

    /**
     * Agrega el contenido a favoritos si no existe; lo elimina si ya existe.
     *
     * @return true  → quedó como favorito (fue agregado)
     *         false → ya no es favorito  (fue eliminado)
     */
    public static boolean toggle(String perfilKey, int idContenido) throws SQLException {
        try (Connection con = ConexionDB.getConexion()) {
            boolean existe;
            try (PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM favs WHERE usuario = ? AND id_contenido = ?")) {
                ps.setString(1, perfilKey);
                ps.setInt(2, idContenido);
                ResultSet rs = ps.executeQuery();
                rs.next();
                existe = rs.getInt(1) > 0;
            }
            String dml = existe
                ? "DELETE FROM favs WHERE usuario = ? AND id_contenido = ?"
                : "INSERT INTO favs (usuario, id_contenido) VALUES (?, ?)";
            try (PreparedStatement ps = con.prepareStatement(dml)) {
                ps.setString(1, perfilKey);
                ps.setInt(2, idContenido);
                ps.executeUpdate();
            }
            return !existe;
        }
    }

    /** Elimina un favorito directamente (sin toggle). */
    public static void remove(String perfilKey, int idContenido) throws SQLException {
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(
                 "DELETE FROM favs WHERE usuario = ? AND id_contenido = ?")) {
            ps.setString(1, perfilKey);
            ps.setInt(2, idContenido);
            ps.executeUpdate();
        }
    }
}
