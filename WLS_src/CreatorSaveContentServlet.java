import java.io.BufferedReader;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

public class CreatorSaveContentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final int MAX_TOPIC_LEVEL = 5;
    private static final int CONTENT_CREATOR_ROLE_ID = 2;
    private static final int UNASSIGNED_OWNER = Integer.MIN_VALUE;
    private static final Map<Integer, String[]> AUXILIARY_DELETE_TABLES = new HashMap<Integer, String[]>();

    static {
        AUXILIARY_DELETE_TABLES.put(0, new String[] {
                "class_subject_chapter",
                "content_developer_privileges_chapter",
                "content_viewer_privileges_chapter"
        });
        AUXILIARY_DELETE_TABLES.put(1, new String[] {
                "class_subject_chapter_topic_level1",
                "content_developer_privileges_topic_level1",
                "content_viewer_privileges_topic_level1",
                "subject_index"
        });
        AUXILIARY_DELETE_TABLES.put(2, new String[] {
                "class_subject_chapter_topic_level1_topic_level2",
                "content_developer_privileges_topic_level2",
                "content_viewer_privileges_topic_level2"
        });
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject payload;
        try {
            payload = readPayload(request);
        } catch (Exception parseError) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"Invalid request payload\"}");
            return;
        }

        int subjectId = payload.optInt("subjectId", 0);
        String title = payload.optString("title", "").trim();
        String content = payload.optString("content", "");
        String operation = payload.optString("operation", "").trim();
        Integer requestedDisplayOrder = resolveRequestedDisplayOrder(payload);
        int[] resolvedPath = resolvePath(payload);
        String nodeType = payload.optString("nodeType", payload.optString("type", "")).trim();
        if (nodeType.isEmpty() && resolvedPath.length > 0) {
            nodeType = inferNodeTypeFromPath(resolvedPath);
        }

        boolean isCreate = "create".equalsIgnoreCase(operation);
        boolean isDelete = "delete".equalsIgnoreCase(operation)
                || (!isCreate && title.isEmpty() && resolvedPath.length > 0);

        System.out.println(
                "CreatorSaveContentServlet request: operation=" + operation
                        + ", inferredDelete=" + isDelete
                        + ", subjectId=" + subjectId
                        + ", nodeType=" + nodeType
                        + ", pathLength=" + resolvedPath.length
                        + ", titleEmpty=" + title.isEmpty());

        if (subjectId <= 0 || nodeType.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"Missing required fields\"}");
            return;
        }

        if (!isDelete && title.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"Missing required fields\"}");
            return;
        }

        Integer actorUserId = getAuthenticatedUserId(request);
        Integer actorRoleId = getAuthenticatedRoleId(request);
        if (actorUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"error\": \"Login required\"}");
            return;
        }
        if (actorRoleId == null || actorRoleId.intValue() != CONTENT_CREATOR_ROLE_ID) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"error\": \"Creator access required\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            boolean originalAutoCommit = conn.getAutoCommit();
            conn.setAutoCommit(false);

            try {
                if (!hasCreatorSubjectAccess(conn, actorUserId.intValue(), subjectId)) {
                    throw new SecurityException("You do not have creator access to this subject");
                }

                if (isCreate) {
                    assertCreateOwnership(conn, subjectId, nodeType, payload.optJSONArray("parentPath"), actorUserId.intValue());
                    createNode(conn, subjectId, nodeType, title, content, payload.optJSONArray("parentPath"),
                            actorUserId, requestedDisplayOrder);
                } else if (isDelete) {
                    assertNodeOwnedByCreator(conn, subjectId, resolvedPath, actorUserId.intValue());
                    deleteNode(conn, subjectId, nodeType, resolvedPath);
                } else {
                    assertNodeOwnedByCreator(conn, subjectId, resolvedPath, actorUserId.intValue());
                    updateNode(conn, subjectId, nodeType, title, content, resolvedPath);
                }
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(originalAutoCommit);
            }

            response.getWriter().print("{\"status\": \"success\"}");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        } catch (SecurityException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().print("{\"error\": \"" + escapeJson(e.getMessage()) + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Database error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private void updateNode(Connection conn, int subjectId, String nodeType, String title, String content, int[] path)
            throws SQLException {
        int level = "chapter".equals(nodeType) ? 0 : parseTopicLevel(nodeType);
        
        try (CallableStatement stmt = conn.prepareCall("{CALL update_node_content_creator(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setInt(1, subjectId);
            stmt.setInt(2, path[0]);
            stmt.setInt(3, level);
            stmt.setInt(4, path.length > 1 ? path[1] : 0);
            stmt.setInt(5, path.length > 2 ? path[2] : 0);
            stmt.setInt(6, path.length > 3 ? path[3] : 0);
            stmt.setInt(7, path.length > 4 ? path[4] : 0);
            stmt.setInt(8, path.length > 5 ? path[5] : 0);
            stmt.setString(9, title);
            stmt.setString(10, content);
            stmt.executeUpdate();
        }
    }

    private void createNode(Connection conn, int subjectId, String nodeType, String title, String content,
            JSONArray parentPathJson, Integer actorUserId, Integer requestedDisplayOrder)
            throws SQLException {
        if ("chapter".equals(nodeType)) {
            int targetDisplayOrder = reserveDisplayOrderForInsert(conn, 0, subjectId, new int[] {}, requestedDisplayOrder);
            int nextChapterId = getNextId(conn, "chapter", "chapter_id", subjectId, new int[] {});
            int[] path = new int[] { nextChapterId };
            try (CallableStatement stmt = conn.prepareCall("{CALL insert_chapter_creator(?, ?, ?, ?, ?, ?, ?)}")) {
                stmt.setInt(1, subjectId);
                stmt.setInt(2, nextChapterId);
                stmt.setString(3, buildCode(subjectId, path));
                stmt.setString(4, title);
                stmt.setNull(5, java.sql.Types.LONGVARCHAR);
                stmt.setString(6, content);
                setNullableInt(stmt, 7, actorUserId);
                stmt.executeUpdate();
            }
            setDisplayOrderForNode(conn, 0, subjectId, path, targetDisplayOrder);
            return;
        }

        int topicLevel = parseTopicLevel(nodeType);
        if (topicLevel < 1 || topicLevel > MAX_TOPIC_LEVEL) {
            throw new IllegalArgumentException("Unsupported node type");
        }
        if (parentPathJson == null) {
            throw new IllegalArgumentException("Missing parent path");
        }

        int[] parentPath = jsonArrayToIntArray(parentPathJson);
        validatePathLength(parentPath, topicLevel);
        int targetDisplayOrder = reserveDisplayOrderForInsert(conn, topicLevel, subjectId, parentPath,
                requestedDisplayOrder);

        String tableName = "topic_level" + topicLevel;
        String idColumn = tableName + "_id";

        int nextTopicId = getNextId(conn, tableName, idColumn, subjectId, parentPath);
        int[] fullPath = appendPath(parentPath, nextTopicId);

        String call = String.format("{CALL insert_topic_creator_level%d(?, ?, ?, %s, ?, ?, ?, ?)}",
                                    topicLevel, repeat("?", topicLevel));
        try (CallableStatement stmt = conn.prepareCall(call)) {
            stmt.setString(1, buildCode(subjectId, fullPath));
            stmt.setInt(2, subjectId);
            stmt.setInt(3, fullPath[0]);
            for (int level = 1; level <= topicLevel; level++) {
                stmt.setInt(level + 3, fullPath[level]);
            }
            stmt.setString(topicLevel + 4, title);
            stmt.setNull(topicLevel + 5, java.sql.Types.LONGVARCHAR);
            stmt.setString(topicLevel + 6, content);
            setNullableInt(stmt, topicLevel + 7, actorUserId);
            stmt.executeUpdate();
        }
        setDisplayOrderForNode(conn, topicLevel, subjectId, fullPath, targetDisplayOrder);

        updateParentHasNextLevel(conn, subjectId, parentPath);
    }

    private String repeat(String s, int n) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < n; i++) {
            if (i > 0) sb.append(", ");
            sb.append(s);
        }
        return sb.toString();
    }

    private Integer getAuthenticatedUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object userIdObj = session.getAttribute("userId");
        if (userIdObj instanceof Integer) {
            return (Integer) userIdObj;
        }
        if (userIdObj instanceof Number) {
            return Integer.valueOf(((Number) userIdObj).intValue());
        }
        if (userIdObj instanceof String) {
            try {
                return Integer.valueOf(((String) userIdObj).trim());
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private Integer getAuthenticatedRoleId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }

        Object roleObj = session.getAttribute("roleId");
        if (roleObj instanceof Integer) {
            return (Integer) roleObj;
        }
        if (roleObj instanceof Number) {
            return Integer.valueOf(((Number) roleObj).intValue());
        }
        if (roleObj instanceof String) {
            try {
                return Integer.valueOf(((String) roleObj).trim());
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private boolean hasCreatorSubjectAccess(Connection conn, int userId, int subjectId) throws SQLException {
        String sql = "SELECT 1 FROM content_developer_privileges_subject WHERE user_id=? AND subject_id=? LIMIT 1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, subjectId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void assertCreateOwnership(Connection conn, int subjectId, String nodeType, JSONArray parentPathJson, int actorUserId)
            throws SQLException {
        if ("chapter".equals(nodeType)) {
            return;
        }

        if (parentPathJson == null) {
            throw new IllegalArgumentException("Missing parent path");
        }

        int[] parentPath = jsonArrayToIntArray(parentPathJson);
        if (parentPath.length == 0) {
            throw new IllegalArgumentException("Invalid parent path");
        }
        assertNodeOwnedByCreator(conn, subjectId, parentPath, actorUserId);
    }

    private void assertNodeOwnedByCreator(Connection conn, int subjectId, int[] path, int actorUserId) throws SQLException {
        if (path == null || path.length == 0) {
            throw new IllegalArgumentException("Invalid node path");
        }

        Integer ownerId = resolveNodeOwner(conn, subjectId, path);
        if (ownerId == null) {
            throw new IllegalArgumentException("Node not found");
        }
        if (ownerId.intValue() == UNASSIGNED_OWNER) {
            // Backward compatibility for legacy rows created before created_by was populated.
            return;
        }
        if (ownerId.intValue() != actorUserId) {
            throw new SecurityException("You can only modify content created by your account");
        }
    }

    private Integer resolveNodeOwner(Connection conn, int subjectId, int[] path) throws SQLException {
        if (path.length == 1) {
            try (PreparedStatement stmt = conn
                    .prepareStatement("SELECT created_by FROM chapter WHERE subject_id=? AND chapter_id=? LIMIT 1")) {
                stmt.setInt(1, subjectId);
                stmt.setInt(2, path[0]);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    Object owner = rs.getObject("created_by");
                    return owner == null ? Integer.valueOf(UNASSIGNED_OWNER) : Integer.valueOf(((Number) owner).intValue());
                }
            }
        }

        int level = path.length - 1;
        if (level < 1 || level > MAX_TOPIC_LEVEL) {
            throw new IllegalArgumentException("Invalid node path");
        }

        StringBuilder sql = new StringBuilder("SELECT created_by FROM topic_level")
                .append(level)
                .append(" WHERE subject_id=? AND chapter_id=?");
        for (int i = 1; i <= level; i++) {
            sql.append(" AND topic_level").append(i).append("_id=?");
        }
        sql.append(" LIMIT 1");

        try (PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            int bindIndex = 1;
            stmt.setInt(bindIndex++, subjectId);
            stmt.setInt(bindIndex++, path[0]);
            for (int i = 1; i <= level; i++) {
                stmt.setInt(bindIndex++, path[i]);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Object owner = rs.getObject("created_by");
                return owner == null ? Integer.valueOf(UNASSIGNED_OWNER) : Integer.valueOf(((Number) owner).intValue());
            }
        }
    }

    private void setNullableInt(CallableStatement stmt, int parameterIndex, Integer value) throws SQLException {
        if (value == null) {
            stmt.setNull(parameterIndex, java.sql.Types.INTEGER);
            return;
        }
        stmt.setInt(parameterIndex, value.intValue());
    }

    private void deleteNode(Connection conn, int subjectId, String nodeType, int[] path) throws SQLException {
        if ("chapter".equals(nodeType)) {
            validatePathLength(path, 1);
            deleteChapterSubtree(conn, subjectId, path);
            closeDisplayOrderGapsAfterDelete(conn, 0, subjectId, new int[] {});
            return;
        }

        int topicLevel = parseTopicLevel(nodeType);
        validatePathLength(path, topicLevel + 1);
        deleteTopicSubtree(conn, subjectId, topicLevel, path);
        updateParentHasNextLevelAfterDelete(conn, subjectId, path);
        closeDisplayOrderGapsAfterDelete(conn, topicLevel, subjectId, parentPath(path));
    }

    private void deleteChapterSubtree(Connection conn, int subjectId, int[] chapterPath) throws SQLException {
        deleteScopedMedia(conn, subjectId, chapterPath);
        deleteAuxiliaryTables(conn, subjectId, chapterPath, 2);

        for (int level = MAX_TOPIC_LEVEL; level >= 1; level--) {
            deleteScopedRows(conn, "topic_level" + level, level, subjectId, chapterPath);
        }

        deleteAuxiliaryTables(conn, subjectId, chapterPath, 0);
        deleteScopedRows(conn, "chapter", 0, subjectId, chapterPath);
    }

    private void deleteTopicSubtree(Connection conn, int subjectId, int topicLevel, int[] path) throws SQLException {
        deleteScopedMedia(conn, subjectId, path);
        deleteAuxiliaryTables(conn, subjectId, path, topicLevel);

        for (int level = MAX_TOPIC_LEVEL; level >= topicLevel; level--) {
            deleteScopedRows(conn, "topic_level" + level, level, subjectId, path);
        }
    }

    private void deleteScopedMedia(Connection conn, int subjectId, int[] path) throws SQLException {
        deleteScopedRows(conn, "audio", 5, subjectId, path);
        deleteScopedRows(conn, "image", 5, subjectId, path);
        deleteScopedRows(conn, "program", 5, subjectId, path);
        deleteScopedRows(conn, "simulation", 5, subjectId, path);
        deleteScopedRows(conn, "video", 5, subjectId, path);
        deleteScopedRows(conn, "subject_glossary", 5, subjectId, path);
    }

    private void deleteAuxiliaryTables(Connection conn, int subjectId, int[] path, int minimumLevel) throws SQLException {
        for (int level = getMaxAuxiliaryLevel(); level >= minimumLevel; level--) {
            String[] tableNames = AUXILIARY_DELETE_TABLES.get(level);
            if (tableNames == null) {
                continue;
            }
            for (String tableName : tableNames) {
                deleteScopedRowsIfTableExists(conn, tableName, level, subjectId, path);
            }
        }
    }

    private int getMaxAuxiliaryLevel() {
        int maxLevel = 0;
        for (Integer level : AUXILIARY_DELETE_TABLES.keySet()) {
            if (level != null && level.intValue() > maxLevel) {
                maxLevel = level.intValue();
            }
        }
        return maxLevel;
    }

    private void deleteScopedRowsIfTableExists(Connection conn, String tableName, int topicColumns, int subjectId, int[] path)
            throws SQLException {
        if (!tableExists(conn, tableName)) {
            return;
        }
        deleteScopedRows(conn, tableName, topicColumns, subjectId, path);
    }

    private void deleteScopedRows(Connection conn, String tableName, int topicColumns, int subjectId, int[] path)
            throws SQLException {
        try (CallableStatement stmt = conn.prepareCall("{CALL delete_scoped_rows_creator(?, ?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setString(1, tableName);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, path[0]);
            stmt.setInt(4, path.length > 1 ? path[1] : 0);
            stmt.setInt(5, path.length > 2 ? path[2] : 0);
            stmt.setInt(6, path.length > 3 ? path[3] : 0);
            stmt.setInt(7, path.length > 4 ? path[4] : 0);
            stmt.setInt(8, path.length > 5 ? path[5] : 0);
            stmt.executeUpdate();
        }
    }

    private boolean tableExists(Connection conn, String tableName) throws SQLException {
        DatabaseMetaData metaData = conn.getMetaData();
        try (ResultSet rs = metaData.getTables(conn.getCatalog(), null, tableName, new String[] { "TABLE" })) {
            return rs.next();
        }
    }

    private void updateParentHasNextLevelAfterDelete(Connection conn, int subjectId, int[] deletedPath) throws SQLException {
        int[] parentPath = new int[deletedPath.length - 1];
        System.arraycopy(deletedPath, 0, parentPath, 0, parentPath.length);

        if (parentPath.length == 0) return;

        int childCount = countDirectChildren(conn, subjectId, parentPath);
        if (childCount == 0) {
            String parentTable = parentPath.length == 1 ? "chapter" : "topic_level" + (parentPath.length - 1);
            try (CallableStatement stmt = conn.prepareCall("{CALL update_has_next_level_creator(?, ?, ?, ?, ?, ?, ?, ?)}")) {
                stmt.setString(1, parentTable);
                stmt.setString(2, "0");
                stmt.setInt(3, subjectId);
                stmt.setInt(4, parentPath[0]);
                stmt.setInt(5, parentPath.length > 1 ? parentPath[1] : 0);
                stmt.setInt(6, parentPath.length > 2 ? parentPath[2] : 0);
                stmt.setInt(7, parentPath.length > 3 ? parentPath[3] : 0);
                stmt.setInt(8, parentPath.length > 4 ? parentPath[4] : 0);
                stmt.executeUpdate();
            }
        }
    }

    private int countDirectChildren(Connection conn, int subjectId, int[] parentPath) throws SQLException {
        int childLevel = parentPath.length; // If parent is chapter (len 1), children are level 1
        try (CallableStatement stmt = conn.prepareCall("{CALL count_direct_children_creator(?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setInt(1, childLevel);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, parentPath[0]);
            stmt.setInt(4, parentPath.length > 1 ? parentPath[1] : 0);
            stmt.setInt(5, parentPath.length > 2 ? parentPath[2] : 0);
            stmt.setInt(6, parentPath.length > 3 ? parentPath[3] : 0);
            stmt.setInt(7, parentPath.length > 4 ? parentPath[4] : 0);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("child_count");
                }
            }
        }
        return 0;
    }

    private int getNextId(Connection conn, String tableName, String idColumn, int subjectId, int[] parentPath) throws SQLException {
        try (CallableStatement stmt = conn.prepareCall("{CALL get_next_node_id(?, ?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setString(1, tableName);
            stmt.setString(2, idColumn);
            stmt.setInt(3, subjectId);
            stmt.setInt(4, parentPath.length > 0 ? parentPath[0] : 0);
            stmt.setInt(5, parentPath.length > 1 ? parentPath[1] : 0);
            stmt.setInt(6, parentPath.length > 2 ? parentPath[2] : 0);
            stmt.setInt(7, parentPath.length > 3 ? parentPath[3] : 0);
            stmt.setInt(8, parentPath.length > 4 ? parentPath[4] : 0);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("next_id");
                }
            }
        }
        return 1;
    }

    private void updateParentHasNextLevel(Connection conn, int subjectId, int[] parentPath) throws SQLException {
        String parentTable = parentPath.length == 0 ? null : (parentPath.length == 1 ? "chapter" : "topic_level" + (parentPath.length - 1));
        if (parentTable == null) return;

        try (CallableStatement stmt = conn.prepareCall("{CALL update_has_next_level_creator(?, ?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setString(1, parentTable);
            stmt.setString(2, "1");
            stmt.setInt(3, subjectId);
            stmt.setInt(4, parentPath[0]);
            stmt.setInt(5, parentPath.length > 1 ? parentPath[1] : 0);
            stmt.setInt(6, parentPath.length > 2 ? parentPath[2] : 0);
            stmt.setInt(7, parentPath.length > 3 ? parentPath[3] : 0);
            stmt.setInt(8, parentPath.length > 4 ? parentPath[4] : 0);
            stmt.executeUpdate();
        }
    }

    private Integer resolveRequestedDisplayOrder(JSONObject payload) {
        if (payload == null) {
            return null;
        }
        if (payload.has("targetDisplayOrder")) {
            return parsePositiveInt(payload.opt("targetDisplayOrder"));
        }
        if (payload.has("target_display_order")) {
            return parsePositiveInt(payload.opt("target_display_order"));
        }
        if (payload.has("displayOrder")) {
            return parsePositiveInt(payload.opt("displayOrder"));
        }
        if (payload.has("display_order")) {
            return parsePositiveInt(payload.opt("display_order"));
        }
        return null;
    }

    private Integer parsePositiveInt(Object value) {
        if (value == null || JSONObject.NULL.equals(value)) {
            return null;
        }
        if (value instanceof Number) {
            int parsed = ((Number) value).intValue();
            return parsed > 0 ? Integer.valueOf(parsed) : null;
        }
        if (value instanceof String) {
            try {
                int parsed = Integer.parseInt(((String) value).trim());
                return parsed > 0 ? Integer.valueOf(parsed) : null;
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private int reserveDisplayOrderForInsert(Connection conn, int level, int subjectId, int[] parentPath,
            Integer requestedDisplayOrder) throws SQLException {
        validateOrderingLevel(level);
        validateParentPath(parentPath, level);
        int chapterId = level > 0 ? parentPath[0] : 0;
        int p1 = level > 1 ? parentPath[1] : 0;
        int p2 = level > 2 ? parentPath[2] : 0;
        int p3 = level > 3 ? parentPath[3] : 0;
        int p4 = level > 4 ? parentPath[4] : 0;
        int requested = requestedDisplayOrder == null ? 0 : requestedDisplayOrder.intValue();

        try (CallableStatement stmt = conn.prepareCall("{CALL prepare_display_order_slot_creator(?, ?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setInt(1, level);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, chapterId);
            stmt.setInt(4, p1);
            stmt.setInt(5, p2);
            stmt.setInt(6, p3);
            stmt.setInt(7, p4);
            stmt.setInt(8, requested);
            Integer value = readIntColumnFromAnyResultSet(stmt, "target_display_order");
            if (value != null) {
                return value.intValue();
            }
        }
        throw new SQLException("Unable to reserve display order");
    }

    private Integer readIntColumnFromAnyResultSet(CallableStatement stmt, String columnName) throws SQLException {
        boolean hasResultSet = stmt.execute();
        while (true) {
            if (hasResultSet) {
                try (ResultSet rs = stmt.getResultSet()) {
                    if (rs != null) {
                        int columnIndex = findColumnIndex(rs.getMetaData(), columnName);
                        if (columnIndex > 0 && rs.next()) {
                            return Integer.valueOf(rs.getInt(columnIndex));
                        }
                    }
                }
            } else {
                int updateCount = stmt.getUpdateCount();
                if (updateCount == -1) {
                    break;
                }
            }
            hasResultSet = stmt.getMoreResults();
        }
        return null;
    }

    private int findColumnIndex(ResultSetMetaData metaData, String columnName) throws SQLException {
        int columnCount = metaData.getColumnCount();
        for (int i = 1; i <= columnCount; i++) {
            String label = metaData.getColumnLabel(i);
            if (label != null && label.equalsIgnoreCase(columnName)) {
                return i;
            }
            String name = metaData.getColumnName(i);
            if (name != null && name.equalsIgnoreCase(columnName)) {
                return i;
            }
        }
        return -1;
    }

    private void closeDisplayOrderGapsAfterDelete(Connection conn, int level, int subjectId, int[] parentPath)
            throws SQLException {
        validateOrderingLevel(level);
        validateParentPath(parentPath, level);
        int chapterId = level > 0 ? parentPath[0] : 0;
        int p1 = level > 1 ? parentPath[1] : 0;
        int p2 = level > 2 ? parentPath[2] : 0;
        int p3 = level > 3 ? parentPath[3] : 0;
        int p4 = level > 4 ? parentPath[4] : 0;

        try (CallableStatement stmt = conn.prepareCall("{CALL normalize_display_order_scope_creator(?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setInt(1, level);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, chapterId);
            stmt.setInt(4, p1);
            stmt.setInt(5, p2);
            stmt.setInt(6, p3);
            stmt.setInt(7, p4);
            stmt.executeUpdate();
        }
    }

    private void setDisplayOrderForNode(Connection conn, int level, int subjectId, int[] nodePath, int displayOrder)
            throws SQLException {
        validatePathLength(nodePath, level + 1);
        int[] parentPath = parentPath(nodePath);
        int chapterId = level > 0 ? parentPath[0] : 0;
        int p1 = level > 1 ? parentPath[1] : 0;
        int p2 = level > 2 ? parentPath[2] : 0;
        int p3 = level > 3 ? parentPath[3] : 0;
        int p4 = level > 4 ? parentPath[4] : 0;
        int nodeId = nodePath[nodePath.length - 1];

        try (CallableStatement stmt = conn.prepareCall("{CALL set_node_display_order_creator(?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            stmt.setInt(1, level);
            stmt.setInt(2, subjectId);
            stmt.setInt(3, chapterId);
            stmt.setInt(4, p1);
            stmt.setInt(5, p2);
            stmt.setInt(6, p3);
            stmt.setInt(7, p4);
            stmt.setInt(8, nodeId);
            stmt.setInt(9, displayOrder);
            stmt.executeUpdate();
        }
    }

    private int[] parentPath(int[] path) {
        int[] parent = new int[Math.max(path.length - 1, 0)];
        if (parent.length > 0) {
            System.arraycopy(path, 0, parent, 0, parent.length);
        }
        return parent;
    }

    private void validateOrderingLevel(int level) {
        if (level < 0 || level > MAX_TOPIC_LEVEL) {
            throw new IllegalArgumentException("Unsupported ordering level");
        }
    }

    private void validateParentPath(int[] parentPath, int expectedLength) {
        if (parentPath.length != expectedLength) {
            throw new IllegalArgumentException("Invalid parent path for ordering");
        }
        for (int value : parentPath) {
            if (value <= 0) {
                throw new IllegalArgumentException("Invalid parent path values");
            }
        }
    }

    private int[] resolvePath(JSONObject payload) {
        JSONArray pathJson = payload.optJSONArray("path");
        if (pathJson != null) {
            return jsonArrayToIntArray(pathJson);
        }

        String nodeType = payload.optString("nodeType", payload.optString("type", ""));
        if ("chapter".equals(nodeType)) {
            int chapterId = payload.optInt("chapterId", 0);
            return chapterId > 0 ? new int[] { chapterId } : new int[] {};
        }

        int chapterId = payload.optInt("chapterId", 0);
        int topicId = payload.optInt("topicId", 0);
        if (chapterId > 0 && topicId > 0) {
            return new int[] { chapterId, topicId };
        }
        return new int[] {};
    }

    private int[] jsonArrayToIntArray(JSONArray values) {
        int[] path = new int[values.length()];
        for (int i = 0; i < values.length(); i++) {
            path[i] = values.optInt(i, 0);
        }
        return path;
    }

    private int[] appendPath(int[] parentPath, int currentId) {
        int[] path = new int[parentPath.length + 1];
        System.arraycopy(parentPath, 0, path, 0, parentPath.length);
        path[parentPath.length] = currentId;
        return path;
    }

    private String inferNodeTypeFromPath(int[] path) {
        if (path.length == 1) {
            return "chapter";
        }

        return "topic" + (path.length - 1);
    }

    private int parseTopicLevel(String nodeType) {
        if (nodeType == null || !nodeType.startsWith("topic")) {
            throw new IllegalArgumentException("Unsupported node type");
        }

        try {
            return Integer.parseInt(nodeType.substring(5));
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Unsupported node type");
        }
    }

    private void validatePathLength(int[] path, int expectedLength) {
        if (path.length != expectedLength) {
            throw new IllegalArgumentException("Invalid path for node type");
        }
        for (int pathId : path) {
            if (pathId <= 0) {
                throw new IllegalArgumentException("Invalid path values");
            }
        }
    }

    private String buildCode(int subjectId, int[] path) {
        StringBuilder code = new StringBuilder(String.format("%05d", subjectId));
        for (int value : path) {
            code.append(String.format("%02d", value));
        }
        return code.toString();
    }

    private JSONObject readPayload(HttpServletRequest request) throws IOException {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }
        return new JSONObject(body.toString());
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
