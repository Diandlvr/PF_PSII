package modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DAO para la selección de membresía y el pago premium simulado.
 *
 * Importante: NO se integra ningún gateway real. El pago solo valida formato.
 */
public class MembresiaDAO {

    /**
     * Valida si el tipo de membresía pertenece a los planes permitidos.
     */
    public static boolean seleccionar(String tipo) {
        if (tipo == null) {
            return false;
        }

        String normalizado = tipo.trim().toLowerCase();
        return normalizado.equals("regular") || normalizado.equals("premium");
    }

    /**
     * true si el cliente ya tiene al menos una membresía registrada.
     * En caso de error de BD devuelve true para no bloquear el login.
     */
    public static boolean tieneMembresia(int clienteId) {
        String sql = "SELECT COUNT(*) FROM membresias WHERE cliente_id = ?";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, clienteId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("MembresiaDAO.tieneMembresia() error: " + e.getMessage());
            return true;
        }
    }

    /**
     * Registra la membresía Regular (gratuita, sin vencimiento) si el cliente
     * aún no tiene ninguna. Idempotente: no duplica filas.
     */
    public static boolean registrarRegular(int clienteId) {
        if (clienteId <= 0) {
            return false;
        }
        if (tieneMembresia(clienteId)) {
            return true;
        }
        String sql = "INSERT INTO membresias (cliente_id, tipo, fecha_inicio) "
                   + "VALUES (?, 'regular', NOW())";
        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, clienteId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("MembresiaDAO.registrarRegular() error: " + e.getMessage());
            return false;
        }
    }

    /**
     * Procesa el pago premium de manera simulada.
     *
     * Reglas del plan:
     * - Tarjeta: exactamente 16 dígitos.
     * - CVV: exactamente 3 dígitos.
     * - Si el formato es correcto, se acepta cualquier número.
     * - Se inserta la membresía premium por 1 mes.
     *
     * @return mensaje listo para mostrar en el JSP.
     */
    public static String procesarPagoPremium(int clienteId, String tarjeta, String cvv) {
        if (clienteId <= 0) {
            return "Sesión inválida. Inicia sesión nuevamente.";
        }

        String tarjetaLimpia = limpiarNumero(tarjeta);
        String cvvLimpio = limpiarNumero(cvv);

        if (!tarjetaLimpia.matches("\\d{16}")) {
            return "Datos de tarjeta inválidos. La tarjeta debe tener 16 dígitos.";
        }

        if (!cvvLimpio.matches("\\d{3}")) {
            return "CVV inválido. El CVV debe tener 3 dígitos.";
        }

        String sql = "INSERT INTO membresias "
                + "(cliente_id, tipo, fecha_inicio, fecha_vencimiento) "
                + "VALUES (?, 'premium', NOW(), DATE_ADD(NOW(), INTERVAL 1 MONTH))";

        try (Connection con = ConexionDB.getConexion();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, clienteId);
            int filas = ps.executeUpdate();

            if (filas > 0) {
                return "¡Pago exitoso! Bienvenido a CinemaxPlus Premium.";
            }
            return "No se pudo registrar la membresía.";

        } catch (SQLException e) {
            System.err.println("MembresiaDAO.procesarPagoPremium() error: " + e.getMessage());
            return "Error al registrar el pago en la base de datos.";
        }
    }

    /**
     * Limpia espacios y guiones para permitir formatos tipo:
     * 1234 5678 9012 3456 o 1234-5678-9012-3456.
     */
    private static String limpiarNumero(String valor) {
        if (valor == null) {
            return "";
        }
        return valor.replace(" ", "").replace("-", "").trim();
    }
}
