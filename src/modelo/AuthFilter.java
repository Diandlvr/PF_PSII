package modelo;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Filtro de autenticacion central (Modulo 4C).
 *
 * Protege las paginas privadas: si no hay un cliente logueado en la sesion,
 * redirige a login.jsp. Las paginas protegidas se declaran en web.xml, asi
 * ningun JSP nuevo se queda sin guard por olvido.
 */
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig config) {
        // sin configuracion
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        boolean autenticado = session != null && session.getAttribute("clienteId") != null;

        if (!autenticado) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // sin recursos que liberar
    }
}
