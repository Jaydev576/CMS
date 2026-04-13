import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.json.JSONObject;

public class CheckLoginServlet extends HttpServlet {
    private static final int MAX_FAILED_ATTEMPTS = 5;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        JSONObject responseJson = new JSONObject();
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null) {
            username = username.trim();
        }

        if (username == null || username.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            responseJson.put("status", "error");
            responseJson.put("message", "Username and password are required");
            response.getWriter().print(responseJson.toString());
            return;
        }

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "SELECT user_id, role_id, password_hash, account_status FROM users WHERE username=?")) {
            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "Invalid username or password");
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().print(responseJson.toString());
                    return;
                }

                int userId = rs.getInt("user_id");
                int roleId = rs.getInt("role_id");
                String storedHash = rs.getString("password_hash");
                String accountStatus = rs.getString("account_status");
                String normalizedStatus = (accountStatus == null || accountStatus.trim().isEmpty())
                        ? "ACTIVE"
                        : accountStatus.trim().toUpperCase();

                if (!"ACTIVE".equals(normalizedStatus)) {
                    responseJson.put("status", "error");
                    responseJson.put("message", "LOCKED".equals(normalizedStatus)
                            ? "Account is locked. Please contact admin."
                            : "Account is inactive. Please contact admin.");
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().print(responseJson.toString());
                    return;
                }

                if (storedHash == null || !PasswordHash.verifyPassword(password, storedHash)) {
                    markFailedLogin(con, userId);
                    responseJson.put("status", "error");
                    responseJson.put("message", "Invalid username or password");
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().print(responseJson.toString());
                    return;
                }

                markSuccessfulLogin(con, userId);

                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session = request.getSession(true);
                session.setAttribute("userId", userId);
                session.setAttribute("roleId", roleId);
                session.setAttribute("userName", username);
                session.setMaxInactiveInterval(60 * 90);

                String dashboard = "";
                if (roleId == 1) {
                    dashboard = "admin";
                } else if (roleId == 2) {
                    dashboard = "content_creator";
                } else if (roleId == 3) {
                    dashboard = "content_viewer";
                }

                responseJson.put("status", "success");
                responseJson.put("roleId", roleId);
                responseJson.put("dashboard", dashboard);
                response.setStatus(HttpServletResponse.SC_OK);
            }
        } catch (Exception e) {
            e.printStackTrace();
            responseJson.put("status", "error");
            responseJson.put("message", "Server error");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        response.getWriter().print(responseJson.toString());
    }

    private void markFailedLogin(Connection con, int userId) throws SQLException {
        String sql = "UPDATE users"
                + " SET failed_login_attempts = COALESCE(failed_login_attempts, 0) + 1,"
                + " account_status = CASE"
                + " WHEN COALESCE(failed_login_attempts, 0) + 1 >= ? THEN 'LOCKED'"
                + " ELSE account_status END"
                + " WHERE user_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, MAX_FAILED_ATTEMPTS);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    private void markSuccessfulLogin(Connection con, int userId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "UPDATE users SET failed_login_attempts=0, last_login_at=NOW(),"
                        + " password_updated_at=COALESCE(password_updated_at, NOW())"
                        + " WHERE user_id=?")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}
