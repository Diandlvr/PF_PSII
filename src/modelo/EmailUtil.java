package modelo;

import java.io.InputStream;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailUtil {

    // Lee mail.properties desde el classpath (WEB-INF/classes/mail.properties).
    // Si el archivo no existe o falta una clave, lanza una excepcion descriptiva
    // en lugar de fallar silenciosamente.
    private static Properties cargarConfig() {
        Properties cfg = new Properties();
        try (InputStream is = EmailUtil.class.getClassLoader()
                                             .getResourceAsStream("mail.properties")) {
            if (is == null) {
                throw new RuntimeException(
                    "No se encontro mail.properties en el classpath. " +
                    "Copia src/mail.properties.example como src/mail.properties y rellena tus datos.");
            }
            cfg.load(is);
        } catch (RuntimeException re) {
            throw re;
        } catch (Exception e) {
            throw new RuntimeException("Error leyendo mail.properties: " + e.getMessage(), e);
        }
        return cfg;
    }

    /**
     * Envia el correo de confirmacion de cuenta.
     *
     * @param baseUrl URL base de la aplicacion, p. ej. http://localhost:8080/PF_PSII_JSP
     *                (el JSP la obtiene del request para no depender del nombre del contexto).
     */
    public static void enviarConfirmacion(String destinatario, String nombre, String token,
                                          String baseUrl) throws Exception {

        Properties cfg  = cargarConfig();
        String host     = cfg.getProperty("mail.host",  "smtp.gmail.com");
        int    port     = Integer.parseInt(cfg.getProperty("mail.port", "587"));
        final String user = cfg.getProperty("mail.user", "").trim();
        final String pass = cfg.getProperty("mail.pass", "").trim();
        // El remitente debe ser el mismo correo autenticado (Gmail lo exige)
        String from     = cfg.getProperty("mail.from",  user).trim();

        if (user.isEmpty() || pass.isEmpty()) {
            throw new Exception(
                "Credenciales SMTP vacias. Edita mail.properties con tu correo y App Password.");
        }

        Properties smtpProps = new Properties();
        smtpProps.put("mail.smtp.auth",              "true");
        smtpProps.put("mail.smtp.starttls.enable",   "true");
        smtpProps.put("mail.smtp.starttls.required", "true");
        smtpProps.put("mail.smtp.host",              host);
        smtpProps.put("mail.smtp.port",              String.valueOf(port));
        smtpProps.put("mail.smtp.ssl.trust",         host);
        smtpProps.put("mail.smtp.connectiontimeout", "15000");
        smtpProps.put("mail.smtp.timeout",           "15000");

        Session mailSession = Session.getInstance(smtpProps);

        if (baseUrl == null || baseUrl.trim().isEmpty()) {
            baseUrl = "http://localhost:8080";
        }
        if (baseUrl.endsWith("/")) {
            baseUrl = baseUrl.substring(0, baseUrl.length() - 1);
        }
        String link = baseUrl + "/verificar.jsp?token=" + token;

        String cuerpoHtml =
            "<!DOCTYPE html><html lang='es'><head><meta charset='UTF-8'></head>" +
            "<body style='margin:0;padding:0;background:#0a0a0a;font-family:Arial,sans-serif;'>" +
            "<table width='100%' cellpadding='0' cellspacing='0' style='background:#0a0a0a;padding:40px 0;'>" +
            "<tr><td align='center'>" +
            "<table width='520' cellpadding='0' cellspacing='0' " +
            "style='background:#111;border-radius:16px;border:1px solid #1a1a1a;overflow:hidden;'>" +
            "<tr><td style='background:#0d1f15;padding:32px;text-align:center;'>" +
            "<span style='font-size:28px;font-weight:800;color:#2ecc71;letter-spacing:2px;'>CINEMAX" +
            "<span style='color:#fff;'>PLUS</span></span></td></tr>" +
            "<tr><td style='padding:40px 40px 20px;'>" +
            "<h2 style='color:#fff;margin:0 0 12px;font-size:22px;'>Hola, " + nombre + "</h2>" +
            "<p style='color:#aaa;font-size:15px;line-height:1.6;margin:0 0 28px;'>" +
            "Gracias por registrarte en <strong style='color:#2ecc71;'>CinemaxPlus</strong>. " +
            "Confirma tu correo para activar tu cuenta.</p>" +
            "<div style='text-align:center;margin:28px 0;'>" +
            "<a href='" + link + "' style='display:inline-block;background:#2ecc71;color:#000;" +
            "text-decoration:none;padding:14px 36px;border-radius:8px;font-weight:700;font-size:15px;'>" +
            "Confirmar mi correo</a></div>" +
            "<p style='color:#555;font-size:12px;text-align:center;margin:24px 0 0;'>" +
            "Si no creaste esta cuenta, ignora este mensaje.</p>" +
            "</td></tr>" +
            "<tr><td style='padding:20px 40px 32px;border-top:1px solid #1a1a1a;text-align:center;'>" +
            "<p style='color:#333;font-size:11px;margin:0;'>&copy; 2025 CinemaxPlus Inc.</p>" +
            "</td></tr></table></td></tr></table></body></html>";

        MimeMessage msg = new MimeMessage(mailSession);
        msg.setFrom(new InternetAddress(from, "CinemaxPlus"));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        msg.setSubject("Confirma tu cuenta en CinemaxPlus");
        msg.setContent(cuerpoHtml, "text/html; charset=UTF-8");

        Transport transport = mailSession.getTransport("smtp");
        try {
            transport.connect(host, port, user, pass);
            transport.sendMessage(msg, msg.getAllRecipients());
        } finally {
            transport.close();
        }
    }
}
