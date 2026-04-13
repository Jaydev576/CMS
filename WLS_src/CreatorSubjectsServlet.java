import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

public class CreatorSubjectsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int CONTENT_CREATOR_ROLE_ID = 2;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\": \"Login required\"}");
            return;
        }

        Integer roleId = readSessionInt(session.getAttribute("roleId"));
        Integer sessionUserId = readSessionInt(session.getAttribute("userId"));
        if (roleId == null || sessionUserId == null || roleId.intValue() != CONTENT_CREATOR_ROLE_ID) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.print("{\"error\": \"Creator access required\"}");
            return;
        }

        String requestedUserId = request.getParameter("userId");
        if (requestedUserId != null && !requestedUserId.trim().isEmpty()) {
            try {
                if (Integer.parseInt(requestedUserId.trim()) != sessionUserId.intValue()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    out.print("{\"error\": \"Forbidden user context\"}");
                    return;
                }
            } catch (NumberFormatException ignored) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\": \"Invalid userId format\"}");
                return;
            }
        }

        int userId = sessionUserId.intValue();

        try (Connection conn = DBConnection.getConnection()) {
            JSONArray subjects = new JSONArray();
            try (CallableStatement stmt = conn.prepareCall("{CALL get_creator_subjects(?)}")) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        JSONObject subject = new JSONObject();
                        subject.put("subject_id", rs.getInt("subject_id"));
                        subject.put("subject_name", safeString(rs.getString("subject_name")));
                        subjects.put(subject);
                    }
                }
            }

            JSONObject stats = fetchCreatorContentStats(conn, userId);
            JSONObject payload = new JSONObject();
            payload.put("subjects", subjects);
            payload.put("stats", stats);
            out.print(payload.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Database error\"}");
        }
    }

    private JSONObject fetchCreatorContentStats(Connection conn, int userId) throws Exception {
        String statusExpr = "LOWER(COALESCE(NULLIF(TRIM(review_status), ''), 'draft'))";
        String scopedWhere = " (created_by = ? OR created_by IS NULL) AND subject_id IN "
                + " (SELECT subject_id FROM content_developer_privileges_subject WHERE user_id = ?) ";

        String sql = "SELECT "
                + " SUM(CASE WHEN (" + statusExpr + "='published' OR COALESCE(is_published,0)=1) THEN 1 ELSE 0 END) AS approved_count,"
                + " SUM(CASE WHEN " + statusExpr + "='rejected' THEN 1 ELSE 0 END) AS rejected_count,"
                + " SUM(CASE WHEN " + statusExpr + "='draft' AND COALESCE(is_published,0)=0 THEN 1 ELSE 0 END) AS draft_count"
                + " FROM ("
                + " SELECT review_status, is_published FROM chapter WHERE " + scopedWhere
                + " UNION ALL SELECT review_status, is_published FROM topic_level1 WHERE " + scopedWhere
                + " UNION ALL SELECT review_status, is_published FROM topic_level2 WHERE " + scopedWhere
                + " UNION ALL SELECT review_status, is_published FROM topic_level3 WHERE " + scopedWhere
                + " UNION ALL SELECT review_status, is_published FROM topic_level4 WHERE " + scopedWhere
                + " UNION ALL SELECT review_status, is_published FROM topic_level5 WHERE " + scopedWhere
                + " ) creator_nodes";

        JSONObject stats = new JSONObject();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            int bindIndex = 1;
            for (int i = 0; i < 6; i++) {
                ps.setInt(bindIndex++, userId);
                ps.setInt(bindIndex++, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int approved = rs.getInt("approved_count");
                    int rejected = rs.getInt("rejected_count");
                    int draft = rs.getInt("draft_count");
                    stats.put("approved", approved);
                    stats.put("rejected", rejected);
                    stats.put("draft", draft);
                    stats.put("total", approved + rejected + draft);
                    return stats;
                }
            }
        }

        stats.put("approved", 0);
        stats.put("rejected", 0);
        stats.put("draft", 0);
        stats.put("total", 0);
        return stats;
    }

    private Integer readSessionInt(Object rawValue) {
        if (rawValue instanceof Number) {
            return Integer.valueOf(((Number) rawValue).intValue());
        }
        if (rawValue instanceof String) {
            try {
                return Integer.valueOf(Integer.parseInt(((String) rawValue).trim()));
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private String safeString(String value) {
        return value == null ? "" : value;
    }
}
