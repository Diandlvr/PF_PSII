package modelo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Clase utilitaria para obtener conexiones a la base de datos MySQL/MariaDB.
 * Usa el driver de MySQL Connector/J 8.x/9.x (com.mysql.cj.jdbc.Driver).
 */
public class ConexionDB {

    // Datos de conexion. Por defecto XAMPP local (root sin password);
    // se pueden sobreescribir con variables de entorno (p. ej. en Docker).
    private static final String HOST     = env("DB_HOST", "localhost");
    private static final String PUERTO   = env("DB_PORT", "3306");
    private static final String USUARIO  = env("DB_USER", "root");
    private static final String PASSWORD = env("DB_PASS", "");

    private static final String URL =
            "jdbc:mysql://" + HOST + ":" + PUERTO + "/cinemax_plus"
            + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
            + "&useUnicode=true&characterEncoding=UTF-8";

    private static String env(String nombre, String porDefecto) {
        String v = System.getenv(nombre);
        return (v != null && !v.isEmpty()) ? v : porDefecto;
    }
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    // Cargamos el driver una sola vez al iniciar la clase.
    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(
                    "No se encontro el driver JDBC de MySQL (Connector/J). "
                    + "Agrega mysql-connector-j-9.7.0.jar al Build Path / WEB-INF/lib. "
                    + e.getMessage());
        }
    }

    /**
     * Devuelve una nueva conexion a la base de datos cinemax_plus.
     *
     * @return Connection abierta hacia MySQL/MariaDB.
     * @throws SQLException si no se puede establecer la conexion.
     */
    public static Connection getConexion() throws SQLException {
        return DriverManager.getConnection(URL, USUARIO, PASSWORD);
    }

    /**
     * Metodo main de prueba rapida (opcional).
     * Ejecutar desde Eclipse: Run As > Java Application.
     */
    public static void main(String[] args) {
        try (Connection con = getConexion()) {
            if (con != null && !con.isClosed()) {
                System.out.println("Conexion exitosa a cinemax_plus.");
            }
        } catch (SQLException e) {
            System.out.println("Error de conexion: " + e.getMessage());
        }
    }
}
