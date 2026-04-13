import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

public class AuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No-op
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        String uri = req.getRequestURI();

        boolean loggedIn = (session != null && session.getAttribute("userId") != null);
        boolean loginRequest = uri.contains("/api/checkLogin");
        boolean apiRequest = uri.contains("/api/");

        if (loggedIn || loginRequest) {
            chain.doFilter(request, response);
        } else {
            if (apiRequest) {
                res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                res.setContentType("application/json");
                res.setCharacterEncoding("UTF-8");
                res.getWriter().print("{\"status\":\"unauthorized\",\"message\":\"Login required\"}");
                return;
            }

            res.sendRedirect(req.getContextPath() + "/");
        }
    }

    @Override
    public void destroy() {
        // No-op
    }
}
