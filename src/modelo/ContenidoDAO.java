package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ContenidoDAO {

    public static List<Map<String, String>> getAll() throws SQLException {
        return ejecutar(
            "SELECT id_contenido, titulo, genero, imagen_url, video_url"
          + " FROM contenido ORDER BY genero, titulo",
            null);
    }

    public static List<Map<String, String>> getByGenero(String genero) throws SQLException {
        return ejecutar(
            "SELECT id_contenido, titulo, genero, imagen_url, video_url"
          + " FROM contenido WHERE genero = ? ORDER BY titulo",
            genero);
    }

    public static Map<String, String> getById(int id) throws SQLException {
        String sql = "SELECT id_contenido, titulo, genero, imagen_url, video_url, duracion_min"
                   + " FROM contenido WHERE id_contenido = ?";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, String> fila = new LinkedHashMap<>();
                    fila.put("id", rs.getString("id_contenido"));
                    fila.put("titulo", rs.getString("titulo"));
                    fila.put("genero", rs.getString("genero"));
                    fila.put("imagen_url", rs.getString("imagen_url"));
                    fila.put("video_url", rs.getString("video_url"));
                    fila.put("duracion_min", rs.getString("duracion_min"));
                    return fila;
                }
            }
        }
        return null;
    }

    public static List<String> getGeneros() throws SQLException {
        List<String> lista = new ArrayList<>();
        try (Connection con = ConexionDB.getConexion();
             Statement st  = con.createStatement();
             ResultSet rs  = st.executeQuery(
                 "SELECT DISTINCT genero FROM contenido ORDER BY genero")) {
            while (rs.next()) lista.add(rs.getString(1));
        }
        return lista;
    }

    private static List<Map<String, String>> ejecutar(String sql, String param)
            throws SQLException {
        List<Map<String, String>> lista = new ArrayList<>();
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (param != null) ps.setString(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> fila = new LinkedHashMap<>();
                    fila.put("id",         rs.getString("id_contenido"));
                    fila.put("titulo",     rs.getString("titulo"));
                    fila.put("genero",     rs.getString("genero"));
                    fila.put("imagen_url", rs.getString("imagen_url"));
                    String video = rs.getString("video_url");
                    fila.put("video_url", video != null ? video : "");
                    lista.add(fila);
                }
            }
        }
        return lista;
    }
}
