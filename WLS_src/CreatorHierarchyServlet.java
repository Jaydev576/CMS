import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;

import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class CreatorHierarchyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int MAX_TOPIC_LEVEL = 5;
    private static final int CONTENT_CREATOR_ROLE_ID = 2;
    private static final int CONTENT_VIEWER_ROLE_ID = 3;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\":\"Login required\"}");
            return;
        }

        String subjectIdStr = request.getParameter("subjectId");
        if (subjectIdStr == null || subjectIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"Missing subjectId\"}");
            return;
        }

        int subjectId;
        try {
            subjectId = Integer.parseInt(subjectIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"Invalid subjectId format\"}");
            return;
        }

        Integer roleIdValue = readSessionInt(session.getAttribute("roleId"));
        Integer userIdValue = readSessionInt(session.getAttribute("userId"));
        if (roleIdValue == null || userIdValue == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\":\"Login required\"}");
            return;
        }

        int roleId = roleIdValue.intValue();
        int userId = userIdValue.intValue();
        boolean viewerMode = roleId == CONTENT_VIEWER_ROLE_ID;
        boolean creatorMode = roleId == CONTENT_CREATOR_ROLE_ID;

        if (!viewerMode && !creatorMode) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"error\":\"Unsupported role for this endpoint\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            if (viewerMode && !canAccessViewerSubject(conn, userId, subjectId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().print("{\"error\":\"You do not have access to this subject\"}");
                return;
            }
            if (creatorMode && !canAccessCreatorSubject(conn, userId, subjectId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().print("{\"error\":\"You do not have creator access to this subject\"}");
                return;
            }

            JSONArray chapters = new JSONArray();
            try (PreparedStatement chapterStmt = prepareChapterStatement(conn, subjectId, viewerMode, creatorMode, userId);
                    ResultSet rsChapter = chapterStmt.executeQuery()) {
                while (rsChapter.next()) {
                    int chapterId = rsChapter.getInt("chapter_id");
                    int[] chapterPath = new int[] { chapterId };
                    JSONObject chapter = createNode(
                            "chapter",
                            0,
                            chapterPath,
                            rsChapter.getString("chapter_name"),
                            resolveEditorContent(rsChapter.getString("introduction"), rsChapter.getString("content")),
                            readNullableInt(rsChapter, "display_order"),
                            rsChapter.getString("review_status"),
                            rsChapter.getString("rejection_remarks"));
                    chapter.put("children", loadTopicChildren(conn, subjectId, chapterPath, 1, viewerMode, creatorMode, userId));
                    chapters.put(chapter);
                }
            }
            response.getWriter().print(chapters.toString());
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Database error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private JSONArray loadTopicChildren(Connection conn, int subjectId, int[] parentPath, int topicLevel, boolean viewerMode,
            boolean creatorMode, int currentUserId)
            throws SQLException {
        JSONArray children = new JSONArray();
        if (topicLevel > MAX_TOPIC_LEVEL) {
            return children;
        }

        String tableName = "topic_level" + topicLevel;
        String idColumn = tableName + "_id";
        String nameColumn = tableName + "_name";
        String compositeIdExpr = buildCompositeIdExpression(topicLevel, "t");

        StringBuilder sql = new StringBuilder("SELECT ")
                .append("t.")
                .append(idColumn)
                .append(", ")
                .append("t.")
                .append(nameColumn)
                .append(", t.introduction, t.content, t.display_order, t.review_status, ")
                .append(" (SELECT rr.remarks FROM admin_content_review_remarks rr")
                .append(" WHERE rr.content_type='topic_level")
                .append(topicLevel)
                .append("' AND rr.composite_id=")
                .append(compositeIdExpr)
                .append(" LIMIT 1) AS rejection_remarks")
                .append(" FROM ")
                .append(tableName)
                .append(" t WHERE t.subject_id = ? AND t.chapter_id = ?");

        if (topicLevel > 1) {
            sql.append(" AND t.topic_level1_id = ?");
        }
        if (topicLevel > 2) {
            sql.append(" AND t.topic_level2_id = ?");
        }
        if (topicLevel > 3) {
            sql.append(" AND t.topic_level3_id = ?");
        }
        if (topicLevel > 4) {
            sql.append(" AND t.topic_level4_id = ?");
        }
        if (viewerMode) {
            sql.append(" AND (LOWER(COALESCE(NULLIF(TRIM(t.review_status), ''), 'draft'))='published' OR COALESCE(t.is_published,0)=1)");
        }
        if (creatorMode) {
            sql.append(" AND (t.created_by = ? OR t.created_by IS NULL)");
        }

        sql.append(" ORDER BY COALESCE(display_order, ")
                .append("t.")
                .append(idColumn)
                .append(") ASC, ")
                .append("t.")
                .append(idColumn)
                .append(" ASC");

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int bindIndex = 1;
            stmt.setInt(bindIndex++, subjectId);
            stmt.setInt(bindIndex++, parentPath[0]);
            if (topicLevel > 1) {
                stmt.setInt(bindIndex++, parentPath[1]);
            }
            if (topicLevel > 2) {
                stmt.setInt(bindIndex++, parentPath[2]);
            }
            if (topicLevel > 3) {
                stmt.setInt(bindIndex++, parentPath[3]);
            }
            if (topicLevel > 4) {
                stmt.setInt(bindIndex++, parentPath[4]);
            }
            if (creatorMode) {
                stmt.setInt(bindIndex++, currentUserId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int currentId = rs.getInt(idColumn);
                    int[] currentPath = appendPath(parentPath, currentId);
                    JSONObject node = createNode(
                            "topic" + topicLevel,
                            topicLevel,
                            currentPath,
                            rs.getString(nameColumn),
                            resolveEditorContent(rs.getString("introduction"), rs.getString("content")),
                            readNullableInt(rs, "display_order"),
                            rs.getString("review_status"),
                            rs.getString("rejection_remarks"));
                    node.put("children",
                            loadTopicChildren(conn, subjectId, currentPath, topicLevel + 1, viewerMode, creatorMode,
                                    currentUserId));
                    children.put(node);
                }
            }
        }

        return children;
    }

    private PreparedStatement prepareChapterStatement(Connection conn, int subjectId, boolean viewerMode, boolean creatorMode,
            int userId)
            throws SQLException {
        if (creatorMode) {
            PreparedStatement stmt = conn.prepareStatement(
                    "SELECT ch.chapter_id, ch.chapter_name, ch.introduction, ch.content, ch.display_order, ch.review_status,"
                            + " (SELECT rr.remarks FROM admin_content_review_remarks rr"
                            + "   WHERE rr.content_type='chapter'"
                            + "     AND rr.composite_id=CONCAT_WS('-', ch.subject_id, ch.chapter_id)"
                            + "   LIMIT 1) AS rejection_remarks"
                            + " FROM chapter ch"
                            + " WHERE ch.subject_id = ? AND (ch.created_by = ? OR ch.created_by IS NULL)"
                            + " ORDER BY COALESCE(ch.display_order, ch.chapter_id) ASC, ch.chapter_id ASC");
            stmt.setInt(1, subjectId);
            stmt.setInt(2, userId);
            return stmt;
        }

        if (viewerMode) {
            PreparedStatement stmt = conn.prepareStatement(
                    "SELECT DISTINCT ch.chapter_id, ch.chapter_name, ch.introduction, ch.content, ch.display_order, ch.review_status,"
                            + " (SELECT rr.remarks FROM admin_content_review_remarks rr"
                            + "   WHERE rr.content_type='chapter'"
                            + "     AND rr.composite_id=CONCAT_WS('-', ch.subject_id, ch.chapter_id)"
                            + "   LIMIT 1) AS rejection_remarks"
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
                            + " ORDER BY COALESCE(ch.display_order, ch.chapter_id) ASC, ch.chapter_id ASC");
            stmt.setInt(1, userId);
            stmt.setInt(2, subjectId);
            return stmt;
        }

        PreparedStatement stmt = conn.prepareStatement(
                "SELECT chapter_id, chapter_name, introduction, content, display_order"
                        + " FROM chapter WHERE subject_id = ?"
                        + " ORDER BY COALESCE(display_order, chapter_id) ASC, chapter_id ASC");
        stmt.setInt(1, subjectId);
        return stmt;
    }

    private boolean canAccessViewerSubject(Connection con, int userId, int subjectId) throws SQLException {
        try (CallableStatement stmt = con.prepareCall("{CALL check_subject_access_for_viewer(?, ?)}")) {
            stmt.setInt(1, userId);
            stmt.setInt(2, subjectId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private boolean canAccessCreatorSubject(Connection con, int userId, int subjectId) throws SQLException {
        String sql = "SELECT 1 FROM content_developer_privileges_subject WHERE user_id=? AND subject_id=? LIMIT 1";
        try (PreparedStatement stmt = con.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, subjectId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private JSONObject createNode(String type, int level, int[] path, String name, String content, Integer displayOrder,
            String reviewStatus, String rejectionRemarks) {
        JSONObject node = new JSONObject();
        node.put("id", joinPath(path));
        node.put("name", name == null ? "" : name);
        node.put("type", type);
        node.put("level", level);
        node.put("path", new JSONArray(Arrays.stream(path).toArray()));
        node.put("content", content == null ? "" : content);
        node.put("reviewStatus", normalizeReviewStatus(reviewStatus));
        if (rejectionRemarks == null || rejectionRemarks.trim().isEmpty()) {
            node.put("rejectionRemarks", JSONObject.NULL);
        } else {
            node.put("rejectionRemarks", rejectionRemarks);
        }
        if (displayOrder == null) {
            node.put("displayOrder", JSONObject.NULL);
        } else {
            node.put("displayOrder", displayOrder.intValue());
        }
        return node;
    }

    private String buildCompositeIdExpression(int topicLevel, String alias) {
        StringBuilder expr = new StringBuilder("CONCAT_WS('-', ")
                .append(alias)
                .append(".subject_id, ")
                .append(alias)
                .append(".chapter_id");
        for (int level = 1; level <= topicLevel; level++) {
            expr.append(", ")
                    .append(alias)
                    .append(".topic_level")
                    .append(level)
                    .append("_id");
        }
        expr.append(")");
        return expr.toString();
    }

    private String normalizeReviewStatus(String reviewStatus) {
        if (reviewStatus == null || reviewStatus.trim().isEmpty()) {
            return "Draft";
        }
        return reviewStatus.trim();
    }

    private Integer readNullableInt(ResultSet rs, String column) throws SQLException {
        Object value = rs.getObject(column);
        if (value == null) {
            return null;
        }
        return Integer.valueOf(((Number) value).intValue());
    }

    private int[] appendPath(int[] parentPath, int currentId) {
        int[] path = Arrays.copyOf(parentPath, parentPath.length + 1);
        path[parentPath.length] = currentId;
        return path;
    }

    private String joinPath(int[] path) {
        StringBuilder joined = new StringBuilder();
        for (int i = 0; i < path.length; i++) {
            if (i > 0) {
                joined.append('.');
            }
            joined.append(path[i]);
        }
        return joined.toString();
    }

    private String resolveEditorContent(String introduction, String content) {
        if (content != null && !content.trim().isEmpty()) {
            return content;
        }
        if (introduction != null && !introduction.trim().isEmpty()) {
            return introduction;
        }
        return "";
    }

    private Integer readSessionInt(Object rawValue) {
        if (rawValue instanceof Number) {
            return Integer.valueOf(((Number) rawValue).intValue());
        }
        if (rawValue instanceof String) {
            try {
                return Integer.valueOf(Integer.parseInt((String) rawValue));
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
