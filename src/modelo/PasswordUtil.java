package modelo;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 * Utilidad para hashear contrasenas con SHA-256 + salt aleatorio de 16 bytes.
 *
 * Compatibilidad con datos legacy:
 *  - Si la BD guarda `password_salt = NULL`, la contrasena esta en texto plano.
 *    Se compara directamente y, si coincide, el login.jsp la re-hashea.
 *  - Si `password_salt` tiene valor, se re-hashea el input con el mismo salt
 *    y se compara el hash resultante contra `contrasena` en BD.
 */
public class PasswordUtil {

    private static final SecureRandom RNG = new SecureRandom();

    /** Genera un salt aleatorio de 16 bytes en hex (32 chars). */
    public static String generarSalt() {
        byte[] bytes = new byte[16];
        RNG.nextBytes(bytes);
        return bytesToHex(bytes);
    }

    /** Hashea password + salt con SHA-256 y devuelve el resultado en hex (64 chars). */
    public static String hash(String password, String salt) {
        if (password == null) password = "";
        if (salt == null)     salt     = "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            md.update(salt.getBytes(StandardCharsets.UTF_8));
            byte[] digest = md.digest(password.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(digest);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 no disponible en la JVM", e);
        }
    }

    /**
     * Verifica un password contra lo almacenado en BD.
     *
     * @param input           Contrasena escrita por el usuario.
     * @param storedPassword  Valor de la columna `contrasena` (hex o plano).
     * @param storedSalt      Valor de la columna `password_salt` (NULL en accounts legacy).
     * @return true si coincide.
     */
    public static boolean verificar(String input, String storedPassword, String storedSalt) {
        if (input == null || storedPassword == null) return false;
        if (storedSalt == null || storedSalt.isEmpty()) {
            // Cuenta legacy en texto plano
            return input.equals(storedPassword);
        }
        return hash(input, storedSalt).equalsIgnoreCase(storedPassword);
    }

    /** true si la cuenta todavia usa texto plano (necesita migracion). */
    public static boolean esLegacy(String storedSalt) {
        return storedSalt == null || storedSalt.isEmpty();
    }

    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }
}
