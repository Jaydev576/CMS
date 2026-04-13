import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

public class GetChaptersServlet extends HttpServlet {
    private static final int CONTENT_VIEWER_ROLE_ID = 3;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        JSONObject responseJson = new JSONObject();

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            responseJson.put("status", "unauthorized");
            out.print(responseJson.toString());
            return;
        }

        int roleId = (int) session.getAttribute("roleId");
        int userId = (int) session.getAttribute("userId");
        String userName = (String) session.getAttribute("userName");

        int subjectId;
        try {
            subjectId = Integer.parseInt(request.getParameter("subjectId"));
        } catch (Exception parseError) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            responseJson.put("status", "error");
            responseJson.put("message", "Invalid subjectId");
            out.print(responseJson.toString());
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            if (!canAccessSubject(con, roleId, userId, subjectId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                responseJson.put("status", "forbidden");
                responseJson.put("message", "You do not have access to this subject");
                out.print(responseJson.toString());
                return;
            }

            JSONArray chaptersArray = roleId == CONTENT_VIEWER_ROLE_ID
                    ? fetchViewerEnabledChapters(con, userId, subjectId)
                    : fetchAllChapters(con, subjectId);

            responseJson.put("status", "success");
            responseJson.put("username", userName);
            responseJson.put("roleId", roleId);
            responseJson.put("userId", userId);
            responseJson.put("sessionTimeoutSeconds", session.getMaxInactiveInterval());
            responseJson.put("chapters", chaptersArray);

            response.setStatus(HttpServletResponse.SC_OK);
            out.print(responseJson.toString());

        } catch (Exception ex) {
            ex.printStackTrace();
            responseJson = new JSONObject();
            responseJson.put("status", "error");
            responseJson.put("message", "Database connection error");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(responseJson.toString());
        }
    }

    private boolean canAccessSubject(Connection con, int roleId, int userId, int subjectId) throws SQLException {
        if (roleId != CONTENT_VIEWER_ROLE_ID) {
            return true;
        }

        try (CallableStatement stmt = con.prepareCall("{CALL check_subject_access_for_viewer(?, ?)}")) {
            stmt.setInt(1, userId);
            stmt.setInt(2, subjectId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private JSONArray fetchAllChapters(Connection con, int subjectId) throws SQLException {
        JSONArray chapters = new JSONArray();
        try (CallableStatement chaptersStmt = con.prepareCall("{CALL get_chapter_content(?)}")) {
            chaptersStmt.setInt(1, subjectId);
            try (ResultSet rsChapters = chaptersStmt.executeQuery()) {
                while (rsChapters.next()) {
                    chapters.put(mapChapter(rsChapters));
                }
            }
        }
        return chapters;
    }

    private JSONArray fetchViewerEnabledChapters(Connection con, int userId, int subjectId) throws SQLException {
        JSONArray chapters = new JSONArray();
        String sql = "SELECT DISTINCT ch.chapter_id, ch.chapter_name, ch.introduction, ch.content, ch.summary, ch.display_order"
                + " FROM content_viewer_users cvu"
                + " JOIN class_subject_chapter csc"
                + "   ON csc.university_id = cvu.university_id"
                + "  AND csc.faculty_id = cvu.faculty_id"
                + "  AND csc.department_id = cvu.department_id"
                + "  AND csc.course_id = cvu.course_id"
                + "  AND csc.specialization_id = cvu.specialization_id"
                + "  AND csc.class_id = cvu.class_id"
                + " JOIN chapter ch"
                + "   ON ch.subject_id = csc.subject_id"
                + "  AND ch.chapter_id = csc.chapter_id"
                + " WHERE cvu.user_id = ?"
                + "   AND csc.subject_id = ?"
                + "   AND (LOWER(COALESCE(NULLIF(TRIM(ch.review_status), ''), 'draft'))='published' OR COALESCE(ch.is_published,0)=1)"
                + " ORDER BY COALESCE(ch.display_order, ch.chapter_id) ASC, ch.chapter_id ASC";

        try (PreparedStatement stmt = con.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, subjectId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    chapters.put(mapChapter(rs));
                }
            }
        }
        return chapters;
    }

    private JSONObject mapChapter(ResultSet rs) throws SQLException {
        JSONObject chapter = new JSONObject();
        chapter.put("chapter_id", rs.getInt("chapter_id"));
        chapter.put("chapter_name", rs.getString("chapter_name"));
        chapter.put("introduction", rs.getString("introduction"));
        chapter.put("content", rs.getString("content"));
        chapter.put("summary", rs.getString("summary"));
        Object displayOrder = rs.getObject("display_order");
        chapter.put("display_order", displayOrder == null ? JSONObject.NULL : displayOrder);
        return chapter;
    }
}
