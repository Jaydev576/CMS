import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "AdminModuleServlet", urlPatterns = { "/api/AdminModuleServlet" })
@MultipartConfig
public class AdminModuleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final Set<String> VIEWER_PERMISSION_KEYS = new HashSet<>(Arrays.asList(
            "has_next_level",
            "read_permission",
            "audio_permission",
            "video_permission",
            "animation_permission",
            "program_permission",
            "chat_permission",
            "forum_permission",
            "simulation_permission",
            "assignment_permission",
            "test_permission",
            "marks_review_permission",
            "remarks_permission"));

    private static final Set<String> DEVELOPER_PERMISSION_KEYS = new HashSet<>(Arrays.asList(
            "has_next_level",
            "read_permission",
            "write_permission",
            "edit_permission",
            "review_permission"));

    private static final Map<String, String> VIEWER_PERMISSION_ALIASES = new HashMap<>();
    static {
        VIEWER_PERMISSION_ALIASES.put("read_permission", "read");
        VIEWER_PERMISSION_ALIASES.put("audio_permission", "audio");
        VIEWER_PERMISSION_ALIASES.put("video_permission", "video");
        VIEWER_PERMISSION_ALIASES.put("animation_permission", "animation");
        VIEWER_PERMISSION_ALIASES.put("program_permission", "program");
        VIEWER_PERMISSION_ALIASES.put("chat_permission", "chat");
        VIEWER_PERMISSION_ALIASES.put("forum_permission", "forum");
        VIEWER_PERMISSION_ALIASES.put("simulation_permission", "simulation");
        VIEWER_PERMISSION_ALIASES.put("assignment_permission", "assignment");
        VIEWER_PERMISSION_ALIASES.put("test_permission", "test");
        VIEWER_PERMISSION_ALIASES.put("marks_review_permission", "marks_review");
        VIEWER_PERMISSION_ALIASES.put("remarks_permission", "remarks");
    }

    private static final DataFormatter EXCEL_FORMATTER = new DataFormatter(Locale.ENGLISH);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleRequest(request, response, "GET");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleRequest(request, response, "POST");
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleRequest(request, response, "PUT");
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        handleRequest(request, response, "DELETE");
    }

    private void handleRequest(HttpServletRequest request, HttpServletResponse response, String method) throws IOException {
        Integer adminUserId = AdminApiUtil.requireAdminUserId(request, response);
        if (adminUserId == null) {
            return;
        }

        String route = AdminApiUtil.getMatchedRoute(request);
        if (route == null || route.trim().isEmpty()) {
            route = request.getPathInfo();
        }

        try {
            if ("GET".equals(method)) {
                handleGet(route, request, response, adminUserId.intValue());
                return;
            }
            if ("POST".equals(method)) {
                handlePost(route, request, response, adminUserId.intValue());
                return;
            }
            if ("PUT".equals(method)) {
                handlePut(route, request, response, adminUserId.intValue());
                return;
            }
            if ("DELETE".equals(method)) {
                handleDelete(route, request, response, adminUserId.intValue());
                return;
            }

            AdminApiUtil.writeError(response, HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Method not allowed");
        } catch (SQLException sqlEx) {
            sqlEx.printStackTrace();
            AdminApiUtil.writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database operation failed");
        } catch (IllegalArgumentException badRequest) {
            AdminApiUtil.writeError(response, HttpServletResponse.SC_BAD_REQUEST, badRequest.getMessage());
        } catch (Exception ex) {
            ex.printStackTrace();
            AdminApiUtil.writeError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Request failed");
        }
    }

    private void handleGet(String route, HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        switch (route) {
            case "/admin/users":
                handleUsersList(request, response);
                return;
            case "/admin/users/export":
                handleUsersExport(request, response);
                return;
            case "/admin/users/template":
                handleUsersTemplate(request, response);
                return;
            case "/admin/enrollments":
                handleEnrollmentsList(request, response);
                return;
            case "/admin/privileges/overview":
                handlePrivilegeOverview(request, response);
                return;
            case "/admin/privileges/export":
                handlePrivilegeExport(request, response);
                return;
            case "/admin/privileges/audit":
                handlePrivilegeAuditList(request, response);
                return;
            case "/admin/privileges/audit/export":
                handlePrivilegeAuditExport(request, response);
                return;
            case "/admin/hierarchy/:level":
                handleHierarchyList(request, response);
                return;
            case "/admin/class-subjects":
                handleClassSubjectList(request, response);
                return;
            case "/admin/class-subject-chapters":
                handleClassSubjectChapterList(request, response);
                return;
            case "/admin/dashboard":
                handleDashboard(request, response);
                return;
            case "/admin/activity":
                handleActivity(request, response);
                return;
            case "/admin/content/review-queue":
                handleReviewQueueList(request, response);
                return;
            default:
                AdminApiUtil.writeError(response, HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
                return;
        }
    }

    private void handlePost(String route, HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        switch (route) {
            case "/admin/users/create":
                handleUserCreate(request, response);
                return;
            case "/admin/users/bulk-import":
                handleUsersBulkImport(request, response);
                return;
            case "/admin/users/status":
                handleUsersStatus(request, response);
                return;
            case "/admin/users/:user_id/reset-password":
                handleResetPassword(request, response);
                return;
            case "/admin/enrollments":
                handleEnrollmentUpsert(request, response, adminUserId);
                return;
            case "/admin/enrollments/bulk-reassign":
                handleEnrollmentBulkReassign(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/subject":
                handleViewerSubjectPrivilegeUpsert(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/chapter":
                handleViewerChapterPrivilegeUpsert(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/topic-level1":
                handleViewerTopicLevel1PrivilegeUpsert(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/topic-level2":
                handleViewerTopicLevel2PrivilegeUpsert(request, response, adminUserId);
                return;
            case "/admin/privileges/developer/subject":
                handleDeveloperSubjectPrivilegeUpsert(request, response, adminUserId);
                return;
            case "/admin/privileges/developer/chapter":
                handleDeveloperChapterPrivilegeUpsert(request, response, adminUserId);
                return;
            case "/admin/hierarchy/:level":
                handleHierarchyCreate(request, response);
                return;
            case "/admin/class-subjects":
                handleClassSubjectAssign(request, response);
                return;
            case "/admin/class-subject-chapters":
                handleClassSubjectChapterAssign(request, response);
                return;
            case "/admin/content/review-queue/:content_type/:composite_id/approve":
                handleReviewApprove(request, response, adminUserId);
                return;
            case "/admin/content/review-queue/:content_type/:composite_id/move-to-draft":
                handleReviewMoveToDraft(request, response, adminUserId);
                return;
            case "/admin/content/review-queue/:content_type/:composite_id/reject":
                handleReviewReject(request, response, adminUserId);
                return;
            default:
                AdminApiUtil.writeError(response, HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
                return;
        }
    }

    private void handlePut(String route, HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        switch (route) {
            case "/admin/users/:user_id":
                handleUserEdit(request, response);
                return;
            case "/admin/enrollments/:enrollment_id/status":
                handleEnrollmentStatusUpdate(request, response);
                return;
            case "/admin/hierarchy/:level/:id":
                handleHierarchyUpdate(request, response);
                return;
            default:
                AdminApiUtil.writeError(response, HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
                return;
        }
    }

    private void handleDelete(String route, HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        switch (route) {
            case "/admin/privileges/viewer/subject":
                handleViewerSubjectPrivilegeRevoke(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/chapter":
                handleViewerChapterPrivilegeRevoke(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/topic-level1":
                handleViewerTopicLevel1PrivilegeRevoke(request, response, adminUserId);
                return;
            case "/admin/privileges/viewer/topic-level2":
                handleViewerTopicLevel2PrivilegeRevoke(request, response, adminUserId);
                return;
            case "/admin/class-subjects":
                handleClassSubjectRemove(request, response);
                return;
            case "/admin/class-subject-chapters":
                handleClassSubjectChapterRemove(request, response);
                return;
            case "/admin/hierarchy/:level/:id":
                handleHierarchyDelete(request, response);
                return;
            default:
                AdminApiUtil.writeError(response, HttpServletResponse.SC_NOT_FOUND, "Endpoint not found");
                return;
        }
    }

    private JSONObject readBodyWhenJson(HttpServletRequest request) throws IOException {
        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase(Locale.ENGLISH).contains("application/json")) {
            return AdminApiUtil.readJsonBody(request);
        }
        return new JSONObject();
    }

    // =====================================================================
    // Section 1: User Management
    // =====================================================================

    private void handleUserCreate(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);

        String username = valueOrFallback(AdminApiUtil.getString(body, request, "username")).trim();
        String password = valueOrFallback(AdminApiUtil.getString(body, request, "password")).trim();
        Integer roleId = AdminApiUtil.getInt(body, request, "role_id");

        if (username.isEmpty() || password.isEmpty() || roleId == null || (roleId.intValue() != 2 && roleId.intValue() != 3)) {
            throw new IllegalArgumentException("username, password and role_id (2/3) are required");
        }

        Integer nationalityId = AdminApiUtil.getInt(body, request, "nationality_id");
        if (nationalityId == null) {
            nationalityId = Integer.valueOf(1);
        }

        String firstName = valueOrNull(AdminApiUtil.getString(body, request, "first_name"));
        String lastName = valueOrNull(AdminApiUtil.getString(body, request, "last_name"));
        String email = valueOrNull(AdminApiUtil.getString(body, request, "email"));
        String mobileNo = valueOrNull(AdminApiUtil.getString(body, request, "mobile_no"));

        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");

        if (firstName == null || lastName == null || email == null || mobileNo == null
                || universityId == null || facultyId == null || departmentId == null || courseId == null) {
            throw new IllegalArgumentException("Missing required fields for profile or academic placement");
        }

        if (roleId.intValue() == 3 && (specializationId == null || classId == null)) {
            throw new IllegalArgumentException("specialization_id and class_id are required for student users");
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                if (isUsernameTaken(conn, username)) {
                    throw new IllegalArgumentException("Username already exists");
                }

                int userId = insertBaseUser(conn, username, password, roleId.intValue(), firstName, lastName, email,
                        mobileNo);

                if (roleId.intValue() == 2) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO content_developer_users (user_id, university_id, faculty_id, department_id, course_id, nationality_id) VALUES (?, ?, ?, ?, ?, ?)")) {
                        ps.setInt(1, userId);
                        ps.setInt(2, universityId.intValue());
                        ps.setInt(3, facultyId.intValue());
                        ps.setInt(4, departmentId.intValue());
                        ps.setInt(5, courseId.intValue());
                        ps.setInt(6, nationalityId.intValue());
                        ps.executeUpdate();
                    }
                } else {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO content_viewer_users (user_id, university_id, faculty_id, department_id, course_id, specialization_id, class_id, nationality_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")) {
                        ps.setInt(1, userId);
                        ps.setInt(2, universityId.intValue());
                        ps.setInt(3, facultyId.intValue());
                        ps.setInt(4, departmentId.intValue());
                        ps.setInt(5, courseId.intValue());
                        ps.setInt(6, specializationId.intValue());
                        ps.setInt(7, classId.intValue());
                        ps.setInt(8, nationalityId.intValue());
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                JSONObject data = new JSONObject();
                data.put("user_id", userId);
                AdminApiUtil.writeSuccess(response, data);
            } catch (Exception e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    private void handleUsersBulkImport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String contentType = valueOrFallback(request.getContentType()).toLowerCase(Locale.ENGLISH);
        if (!contentType.contains("multipart/form-data")) {
            throw new IllegalArgumentException("Content-Type must be multipart/form-data");
        }

        String roleRaw = valueOrFallback(request.getParameter("role")).trim().toLowerCase(Locale.ENGLISH);
        if (roleRaw.isEmpty()) {
            roleRaw = "teacher";
        }

        int roleId;
        if ("teacher".equals(roleRaw) || "2".equals(roleRaw)) {
            roleId = 2;
        } else if ("student".equals(roleRaw) || "3".equals(roleRaw)) {
            roleId = 3;
        } else {
            throw new IllegalArgumentException("role must be teacher or student");
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            throw new IllegalArgumentException("Excel file is required");
        }

        JSONArray errors = new JSONArray();
        int total = 0;
        int success = 0;

        try (Connection conn = DBConnection.getConnection();
                InputStream in = filePart.getInputStream();
                Workbook workbook = WorkbookFactory.create(in)) {
            conn.setAutoCommit(false);
            try {
                Sheet sheet = workbook.getNumberOfSheets() > 0 ? workbook.getSheetAt(0) : null;
                if (sheet == null) {
                    throw new IllegalArgumentException("Uploaded workbook has no sheets");
                }

                Row header = sheet.getRow(0);
                if (header == null) {
                    throw new IllegalArgumentException("Header row missing");
                }

                Map<String, Integer> headerIndex = new HashMap<>();
                for (int i = 0; i < header.getLastCellNum(); i++) {
                    String key = normalizeHeader(readExcelCell(header.getCell(i)));
                    if (!key.isEmpty()) {
                        headerIndex.put(key, Integer.valueOf(i));
                    }
                }

                List<String> required = roleId == 2
                        ? Arrays.asList("username", "password", "first_name", "last_name", "email", "mobile_no",
                                "nationality_id", "university_id", "faculty_id", "department_id", "course_id")
                        : Arrays.asList("username", "password", "first_name", "last_name", "email", "mobile_no",
                                "nationality_id", "university_id", "faculty_id", "department_id", "course_id",
                                "specialization_id", "class_id");

                for (String req : required) {
                    if (!headerIndex.containsKey(req)) {
                        throw new IllegalArgumentException("Missing required column: " + req);
                    }
                }

                Set<String> seenUsernames = new HashSet<>();

                for (int rowNum = 1; rowNum <= sheet.getLastRowNum(); rowNum++) {
                    Row row = sheet.getRow(rowNum);
                    if (row == null) {
                        continue;
                    }

                    total++;
                    String username = readMappedCell(row, headerIndex, "username");
                    String password = readMappedCell(row, headerIndex, "password");

                    if (username.isEmpty() && password.isEmpty()) {
                        // ignore blank rows
                        total--;
                        continue;
                    }

                    java.sql.Savepoint sp = conn.setSavepoint("row_" + rowNum);
                    try {
                        if (username.isEmpty() || password.isEmpty()) {
                            throw new IllegalArgumentException("username/password required");
                        }
                        if (seenUsernames.contains(username.toLowerCase(Locale.ENGLISH))) {
                            throw new IllegalArgumentException("duplicate username in file");
                        }
                        seenUsernames.add(username.toLowerCase(Locale.ENGLISH));

                        if (isUsernameTaken(conn, username)) {
                            throw new IllegalArgumentException("username already exists");
                        }

                        String firstName = readMappedCell(row, headerIndex, "first_name");
                        String lastName = readMappedCell(row, headerIndex, "last_name");
                        String email = readMappedCell(row, headerIndex, "email");
                        String mobileNo = readMappedCell(row, headerIndex, "mobile_no");
                        Integer nationalityId = parseRequiredIntCell(row, headerIndex, "nationality_id");
                        Integer universityId = parseRequiredIntCell(row, headerIndex, "university_id");
                        Integer facultyId = parseRequiredIntCell(row, headerIndex, "faculty_id");
                        Integer departmentId = parseRequiredIntCell(row, headerIndex, "department_id");
                        Integer courseId = parseRequiredIntCell(row, headerIndex, "course_id");

                        int userId = insertBaseUser(conn, username, password, roleId, firstName, lastName, email, mobileNo);

                        if (roleId == 2) {
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "INSERT INTO content_developer_users (user_id, university_id, faculty_id, department_id, course_id, nationality_id) VALUES (?, ?, ?, ?, ?, ?)")) {
                                ps.setInt(1, userId);
                                ps.setInt(2, universityId.intValue());
                                ps.setInt(3, facultyId.intValue());
                                ps.setInt(4, departmentId.intValue());
                                ps.setInt(5, courseId.intValue());
                                ps.setInt(6, nationalityId.intValue());
                                ps.executeUpdate();
                            }
                        } else {
                            Integer specializationId = parseRequiredIntCell(row, headerIndex, "specialization_id");
                            Integer classId = parseRequiredIntCell(row, headerIndex, "class_id");
                            try (PreparedStatement ps = conn.prepareStatement(
                                    "INSERT INTO content_viewer_users (user_id, university_id, faculty_id, department_id, course_id, specialization_id, class_id, nationality_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")) {
                                ps.setInt(1, userId);
                                ps.setInt(2, universityId.intValue());
                                ps.setInt(3, facultyId.intValue());
                                ps.setInt(4, departmentId.intValue());
                                ps.setInt(5, courseId.intValue());
                                ps.setInt(6, specializationId.intValue());
                                ps.setInt(7, classId.intValue());
                                ps.setInt(8, nationalityId.intValue());
                                ps.executeUpdate();
                            }
                        }

                        success++;
                    } catch (Exception rowError) {
                        conn.rollback(sp);
                        JSONObject err = new JSONObject();
                        err.put("row", rowNum + 1);
                        err.put("username", username);
                        err.put("reason", getThrowableMessage(rowError));
                        err.put("causes", buildThrowableChain(rowError));
                        errors.put(err);
                    }
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }

        JSONObject data = new JSONObject();
        data.put("total", total);
        data.put("success", success);
        data.put("failed", Math.max(total - success, 0));
        data.put("errors", errors);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleUsersStatus(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);

        String action = valueOrFallback(AdminApiUtil.getString(body, request, "action")).trim().toUpperCase(Locale.ENGLISH);
        if (!("ACTIVATE".equals(action) || "DEACTIVATE".equals(action) || "UNLOCK".equals(action)
                || "INVOKE".equals(action))) {
            throw new IllegalArgumentException("action must be ACTIVATE, DEACTIVATE, UNLOCK, or INVOKE");
        }

        List<Integer> userIds = parseIntList(body, request, "user_ids");
        if (userIds.isEmpty()) {
            throw new IllegalArgumentException("user_ids is required");
        }

        StringBuilder sql = new StringBuilder("UPDATE users SET ");
        if ("ACTIVATE".equals(action)) {
            sql.append("account_status='ACTIVE' ");
        } else if ("DEACTIVATE".equals(action)) {
            sql.append("account_status='INACTIVE' ");
        } else if ("INVOKE".equals(action)) {
            sql.append("account_status='INACTIVE', password_updated_at=NOW() ");
        } else {
            sql.append("failed_login_attempts=0, account_status='ACTIVE' ");
        }
        sql.append("WHERE user_id IN (");
        appendPlaceholders(sql, userIds.size());
        sql.append(")");

        int updated;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindIntList(ps, userIds, 1);
            updated = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleUserEdit(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        Integer userId = AdminApiUtil.toInteger(AdminApiUtil.getRouteParam(request, "user_id"));
        if (userId == null) {
            throw new IllegalArgumentException("Invalid user_id");
        }

        String firstName = valueOrNull(AdminApiUtil.getString(body, request, "first_name"));
        String lastName = valueOrNull(AdminApiUtil.getString(body, request, "last_name"));
        String email = valueOrNull(AdminApiUtil.getString(body, request, "email"));
        String mobileNo = valueOrNull(AdminApiUtil.getString(body, request, "mobile_no"));
        Integer nationalityId = AdminApiUtil.getInt(body, request, "nationality_id");

        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                Integer roleId = null;
                try (PreparedStatement rsRole = conn.prepareStatement("SELECT role_id FROM users WHERE user_id=?")) {
                    rsRole.setInt(1, userId.intValue());
                    try (ResultSet rs = rsRole.executeQuery()) {
                        if (rs.next()) {
                            roleId = Integer.valueOf(rs.getInt("role_id"));
                        }
                    }
                }

                if (roleId == null) {
                    throw new IllegalArgumentException("User not found");
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET first_name=?, last_name=?, email=?, mobile_no=? WHERE user_id=?")) {
                    ps.setString(1, firstName);
                    ps.setString(2, lastName);
                    ps.setString(3, email);
                    ps.setString(4, mobileNo);
                    ps.setInt(5, userId.intValue());
                    ps.executeUpdate();
                }

                if (roleId.intValue() == 2) {
                    if (universityId == null || facultyId == null || departmentId == null || courseId == null) {
                        throw new IllegalArgumentException(
                                "university_id, faculty_id, department_id, course_id are required for teachers");
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE content_developer_users SET university_id=?, faculty_id=?, department_id=?, course_id=?, nationality_id=? WHERE user_id=?")) {
                        ps.setInt(1, universityId.intValue());
                        ps.setInt(2, facultyId.intValue());
                        ps.setInt(3, departmentId.intValue());
                        ps.setInt(4, courseId.intValue());
                        if (nationalityId == null) {
                            ps.setNull(5, Types.INTEGER);
                        } else {
                            ps.setInt(5, nationalityId.intValue());
                        }
                        ps.setInt(6, userId.intValue());
                        ps.executeUpdate();
                    }
                } else if (roleId.intValue() == 3) {
                    if (universityId == null || facultyId == null || departmentId == null || courseId == null
                            || specializationId == null || classId == null) {
                        throw new IllegalArgumentException(
                                "Academic hierarchy fields are required for student users");
                    }
                    try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE content_viewer_users SET university_id=?, faculty_id=?, department_id=?, course_id=?, specialization_id=?, class_id=?, nationality_id=? WHERE user_id=?")) {
                        ps.setInt(1, universityId.intValue());
                        ps.setInt(2, facultyId.intValue());
                        ps.setInt(3, departmentId.intValue());
                        ps.setInt(4, courseId.intValue());
                        ps.setInt(5, specializationId.intValue());
                        ps.setInt(6, classId.intValue());
                        if (nationalityId == null) {
                            ps.setNull(7, Types.INTEGER);
                        } else {
                            ps.setInt(7, nationalityId.intValue());
                        }
                        ps.setInt(8, userId.intValue());
                        ps.executeUpdate();
                    }
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }

            JSONObject user = fetchUserById(conn, userId.intValue());
            AdminApiUtil.writeSuccess(response, user);
        }
    }

    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        Integer userId = AdminApiUtil.toInteger(AdminApiUtil.getRouteParam(request, "user_id"));
        String newPassword = valueOrFallback(AdminApiUtil.getString(body, request, "new_password")).trim();

        if (userId == null || newPassword.isEmpty()) {
            throw new IllegalArgumentException("user_id and new_password are required");
        }

        int updated;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET password_hash=?, password_updated_at=NOW() WHERE user_id=?")) {
            ps.setString(1, PasswordHash.hashPassword(newPassword));
            ps.setInt(2, userId.intValue());
            updated = ps.executeUpdate();
        }

        if (updated == 0) {
            throw new IllegalArgumentException("User not found");
        }

        JSONObject data = new JSONObject();
        data.put("updated", true);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleUsersList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        UserListQuery query = UserListQuery.fromRequest(request);
        UserListResult result = fetchUsers(query);

        JSONObject data = new JSONObject();
        data.put("items", result.items);
        data.put("total", result.total);
        data.put("page", query.page);
        data.put("page_size", query.pageSize);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleUsersExport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        UserListQuery query = UserListQuery.fromRequest(request);
        query.page = 1;
        query.pageSize = 100000;
        UserListResult result = fetchUsers(query);

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Users");
            String[] headers = new String[] {
                    "User ID", "Username", "First Name", "Last Name", "Email", "Role", "Status", "Last Login",
                    "Failed Attempts", "University", "Faculty", "Department", "Course", "Specialization", "Class"
            };

            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) {
                headerRow.createCell(i).setCellValue(headers[i]);
            }

            for (int i = 0; i < result.items.length(); i++) {
                JSONObject item = result.items.getJSONObject(i);
                Row row = sheet.createRow(i + 1);
                row.createCell(0).setCellValue(item.optInt("user_id"));
                row.createCell(1).setCellValue(item.optString("username"));
                row.createCell(2).setCellValue(item.optString("first_name"));
                row.createCell(3).setCellValue(item.optString("last_name"));
                row.createCell(4).setCellValue(item.optString("email"));
                row.createCell(5).setCellValue(item.optString("role_name"));
                row.createCell(6).setCellValue(item.optString("account_status"));
                row.createCell(7).setCellValue(item.optString("last_login_at"));
                row.createCell(8).setCellValue(item.optInt("failed_login_attempts"));
                row.createCell(9).setCellValue(item.optString("university_name"));
                row.createCell(10).setCellValue(item.optString("faculty_name"));
                row.createCell(11).setCellValue(item.optString("department_name"));
                row.createCell(12).setCellValue(item.optString("course_name"));
                row.createCell(13).setCellValue(item.optString("specialization_name"));
                row.createCell(14).setCellValue(item.optString("class_name"));
            }

            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=admin_users_export.xlsx");
            workbook.write(response.getOutputStream());
        }
    }

    private void handleUsersTemplate(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String role = valueOrFallback(request.getParameter("role")).trim().toLowerCase(Locale.ENGLISH);
        if (!("teacher".equals(role) || "student".equals(role))) {
            throw new IllegalArgumentException("role must be teacher or student");
        }

        String[] headers = "teacher".equals(role)
                ? new String[] { "username", "password", "first_name", "last_name", "email", "mobile_no",
                        "nationality_id", "university_id", "faculty_id", "department_id", "course_id" }
                : new String[] { "username", "password", "first_name", "last_name", "email", "mobile_no",
                        "nationality_id", "university_id", "faculty_id", "department_id", "course_id",
                        "specialization_id", "class_id" };

        // Generate CSV directly to avoid runtime POI/commons-io conflicts on older containers.
        response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=" + role + "_import_template.csv");
        response.setHeader("Cache-Control", "no-store");

        StringBuilder csv = new StringBuilder();
        csv.append('\uFEFF'); // UTF-8 BOM for Excel compatibility
        csv.append(String.join(",", headers));
        csv.append('\n');
        response.getOutputStream().write(csv.toString().getBytes(StandardCharsets.UTF_8));
        response.getOutputStream().flush();
    }

    // =====================================================================
    // Section 2: Enrollment Management
    // =====================================================================

    private void handleEnrollmentsList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer userId = AdminApiUtil.toInteger(request.getParameter("user_id"));
        if (userId == null) {
            throw new IllegalArgumentException("user_id is required");
        }

        JSONArray items = new JSONArray();
        String sql = "SELECT e.enrollment_id, e.user_id, e.university_id, e.faculty_id, e.department_id, e.course_id, e.specialization_id, e.class_id,"
                + " e.enrollment_type, e.status, e.valid_from, e.valid_to, e.granted_by, e.created_at,"
                + " c.class_name, s.specialization_name, co.course_name, d.department_name, f.faculty_name, u2.university_name"
                + " FROM content_viewer_class_enrollment e"
                + " LEFT JOIN class c ON c.university_id=e.university_id AND c.faculty_id=e.faculty_id AND c.department_id=e.department_id"
                + " AND c.course_id=e.course_id AND c.specialization_id=e.specialization_id AND c.class_id=e.class_id"
                + " LEFT JOIN specialization s ON s.university_id=e.university_id AND s.faculty_id=e.faculty_id AND s.department_id=e.department_id"
                + " AND s.course_id=e.course_id AND s.specialization_id=e.specialization_id"
                + " LEFT JOIN course co ON co.university_id=e.university_id AND co.faculty_id=e.faculty_id AND co.department_id=e.department_id AND co.course_id=e.course_id"
                + " LEFT JOIN department d ON d.university_id=e.university_id AND d.faculty_id=e.faculty_id AND d.department_id=e.department_id"
                + " LEFT JOIN faculty f ON f.university_id=e.university_id AND f.faculty_id=e.faculty_id"
                + " LEFT JOIN university u2 ON u2.university_id=e.university_id"
                + " WHERE e.user_id=? ORDER BY e.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId.intValue());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JSONObject item = mapRow(rs);
                    items.put(item);
                }
            }
        }

        if (items.length() == 0) {
            String fallbackSql = "SELECT 0 AS enrollment_id, cvu.user_id, cvu.university_id, cvu.faculty_id, cvu.department_id,"
                    + " cvu.course_id, cvu.specialization_id, cvu.class_id,"
                    + " 'HOME' AS enrollment_type, 'ACTIVE' AS status,"
                    + " NULL AS valid_from, NULL AS valid_to, NULL AS granted_by, NULL AS created_at,"
                    + " c.class_name, s.specialization_name, co.course_name, d.department_name, f.faculty_name, u2.university_name,"
                    + " 1 AS is_home_fallback"
                    + " FROM content_viewer_users cvu"
                    + " LEFT JOIN class c ON c.university_id=cvu.university_id AND c.faculty_id=cvu.faculty_id AND c.department_id=cvu.department_id"
                    + " AND c.course_id=cvu.course_id AND c.specialization_id=cvu.specialization_id AND c.class_id=cvu.class_id"
                    + " LEFT JOIN specialization s ON s.university_id=cvu.university_id AND s.faculty_id=cvu.faculty_id AND s.department_id=cvu.department_id"
                    + " AND s.course_id=cvu.course_id AND s.specialization_id=cvu.specialization_id"
                    + " LEFT JOIN course co ON co.university_id=cvu.university_id AND co.faculty_id=cvu.faculty_id AND co.department_id=cvu.department_id AND co.course_id=cvu.course_id"
                    + " LEFT JOIN department d ON d.university_id=cvu.university_id AND d.faculty_id=cvu.faculty_id AND d.department_id=cvu.department_id"
                    + " LEFT JOIN faculty f ON f.university_id=cvu.university_id AND f.faculty_id=cvu.faculty_id"
                    + " LEFT JOIN university u2 ON u2.university_id=cvu.university_id"
                    + " WHERE cvu.user_id=?";

            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setInt(1, userId.intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        items.put(mapRow(rs));
                    }
                }
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleEnrollmentUpsert(HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        JSONObject body = readBodyWhenJson(request);

        Integer userId = AdminApiUtil.getInt(body, request, "user_id");
        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");
        String enrollmentType = valueOrFallback(AdminApiUtil.getString(body, request, "enrollment_type")).trim()
                .toUpperCase(Locale.ENGLISH);

        if (userId == null || universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null) {
            throw new IllegalArgumentException("Missing required enrollment fields");
        }
        if (!("HOME".equals(enrollmentType) || "EXPLICIT".equals(enrollmentType))) {
            throw new IllegalArgumentException("enrollment_type must be HOME or EXPLICIT");
        }

        Timestamp validFrom = parseTimestamp(AdminApiUtil.getString(body, request, "valid_from"));
        Timestamp validTo = parseTimestamp(AdminApiUtil.getString(body, request, "valid_to"));

        String sql = "INSERT INTO content_viewer_class_enrollment"
                + " (user_id, university_id, faculty_id, department_id, course_id, specialization_id, class_id, enrollment_type, status, valid_from, valid_to, granted_by)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?, ?, ?)"
                + " ON DUPLICATE KEY UPDATE enrollment_type=VALUES(enrollment_type), status='ACTIVE', valid_from=VALUES(valid_from),"
                + " valid_to=VALUES(valid_to), granted_by=VALUES(granted_by)";

        int updated;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId.intValue());
            ps.setInt(2, universityId.intValue());
            ps.setInt(3, facultyId.intValue());
            ps.setInt(4, departmentId.intValue());
            ps.setInt(5, courseId.intValue());
            ps.setInt(6, specializationId.intValue());
            ps.setInt(7, classId.intValue());
            ps.setString(8, enrollmentType);
            if (validFrom == null) {
                ps.setNull(9, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(9, validFrom);
            }
            if (validTo == null) {
                ps.setNull(10, Types.TIMESTAMP);
            } else {
                ps.setTimestamp(10, validTo);
            }
            ps.setInt(11, adminUserId);
            updated = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleEnrollmentStatusUpdate(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        Long enrollmentId = AdminApiUtil.toLong(AdminApiUtil.getRouteParam(request, "enrollment_id"));
        String status = valueOrFallback(AdminApiUtil.getString(body, request, "status")).trim().toUpperCase(Locale.ENGLISH);

        if (enrollmentId == null) {
            throw new IllegalArgumentException("Invalid enrollment_id");
        }
        if (!("ACTIVE".equals(status) || "REVOKED".equals(status) || "EXPIRED".equals(status))) {
            throw new IllegalArgumentException("status must be ACTIVE, REVOKED, or EXPIRED");
        }

        int updated;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "UPDATE content_viewer_class_enrollment SET status=? WHERE enrollment_id=?")) {
            ps.setString(1, status);
            ps.setLong(2, enrollmentId.longValue());
            updated = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleEnrollmentBulkReassign(HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        JSONObject body = readBodyWhenJson(request);
        List<Integer> userIds = parseIntList(body, request, "user_ids");

        Integer universityId = AdminApiUtil.getInt(body, request, "new_university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "new_faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "new_department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "new_course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "new_specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "new_class_id");

        if (userIds.isEmpty() || universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null) {
            throw new IllegalArgumentException("Missing required bulk reassignment fields");
        }

        int updatedUsers = 0;
        int updatedEnrollments = 0;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                StringBuilder userSql = new StringBuilder(
                        "UPDATE content_viewer_users SET university_id=?, faculty_id=?, department_id=?, course_id=?, specialization_id=?, class_id=? WHERE user_id IN (");
                appendPlaceholders(userSql, userIds.size());
                userSql.append(")");

                try (PreparedStatement ps = conn.prepareStatement(userSql.toString())) {
                    ps.setInt(1, universityId.intValue());
                    ps.setInt(2, facultyId.intValue());
                    ps.setInt(3, departmentId.intValue());
                    ps.setInt(4, courseId.intValue());
                    ps.setInt(5, specializationId.intValue());
                    ps.setInt(6, classId.intValue());
                    bindIntList(ps, userIds, 7);
                    updatedUsers = ps.executeUpdate();
                }

                StringBuilder enrollmentSql = new StringBuilder(
                        "UPDATE content_viewer_class_enrollment SET university_id=?, faculty_id=?, department_id=?, course_id=?, specialization_id=?, class_id=?, status='ACTIVE', granted_by=? WHERE enrollment_type='HOME' AND user_id IN (");
                appendPlaceholders(enrollmentSql, userIds.size());
                enrollmentSql.append(")");

                try (PreparedStatement ps = conn.prepareStatement(enrollmentSql.toString())) {
                    ps.setInt(1, universityId.intValue());
                    ps.setInt(2, facultyId.intValue());
                    ps.setInt(3, departmentId.intValue());
                    ps.setInt(4, courseId.intValue());
                    ps.setInt(5, specializationId.intValue());
                    ps.setInt(6, classId.intValue());
                    ps.setInt(7, adminUserId);
                    bindIntList(ps, userIds, 8);
                    updatedEnrollments = ps.executeUpdate();
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }

        JSONObject data = new JSONObject();
        data.put("updated_users", updatedUsers);
        data.put("updated_home_enrollments", updatedEnrollments);
        AdminApiUtil.writeSuccess(response, data);
    }

    // =====================================================================
    // Section 3: Privileges + Audit
    // =====================================================================

    private void handleViewerSubjectPrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeUpsert(request, response, adminUserId, body,
                "content_viewer_privileges_subject", "viewer_subject",
                Arrays.asList("user_id", "subject_id"), VIEWER_PERMISSION_KEYS, true);
    }

    private void handleViewerChapterPrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeUpsert(request, response, adminUserId, body,
                "content_viewer_privileges_chapter", "viewer_chapter",
                Arrays.asList("user_id", "subject_id", "chapter_id"), VIEWER_PERMISSION_KEYS, true);
    }

    private void handleViewerTopicLevel1PrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeUpsert(request, response, adminUserId, body,
                "content_viewer_privileges_topic_level1", "viewer_topic_level1",
                Arrays.asList("user_id", "subject_id", "chapter_id", "topic_level1_id"), VIEWER_PERMISSION_KEYS, true);
    }

    private void handleViewerTopicLevel2PrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        Set<String> keys = new HashSet<>(VIEWER_PERMISSION_KEYS);
        keys.remove("has_next_level");
        handleViewerPrivilegeUpsert(request, response, adminUserId, body,
                "content_viewer_privileges_topic_level2", "viewer_topic_level2",
                Arrays.asList("user_id", "subject_id", "chapter_id", "topic_level1_id", "topic_level2_id"), keys,
                false);
    }

    private void handleViewerSubjectPrivilegeRevoke(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeRevoke(request, response, adminUserId, body,
                "content_viewer_privileges_subject", "viewer_subject",
                Arrays.asList("user_id", "subject_id"));
    }

    private void handleViewerChapterPrivilegeRevoke(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeRevoke(request, response, adminUserId, body,
                "content_viewer_privileges_chapter", "viewer_chapter",
                Arrays.asList("user_id", "subject_id", "chapter_id"));
    }

    private void handleViewerTopicLevel1PrivilegeRevoke(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeRevoke(request, response, adminUserId, body,
                "content_viewer_privileges_topic_level1", "viewer_topic_level1",
                Arrays.asList("user_id", "subject_id", "chapter_id", "topic_level1_id"));
    }

    private void handleViewerTopicLevel2PrivilegeRevoke(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleViewerPrivilegeRevoke(request, response, adminUserId, body,
                "content_viewer_privileges_topic_level2", "viewer_topic_level2",
                Arrays.asList("user_id", "subject_id", "chapter_id", "topic_level1_id", "topic_level2_id"));
    }

    private void handleDeveloperSubjectPrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleDeveloperPrivilegeUpsert(request, response, adminUserId, body,
                "content_developer_privileges_subject", "developer_subject",
                Arrays.asList("user_id", "subject_id"));
    }

    private void handleDeveloperChapterPrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId) throws Exception {
        JSONObject body = readBodyWhenJson(request);
        handleDeveloperPrivilegeUpsert(request, response, adminUserId, body,
                "content_developer_privileges_chapter", "developer_chapter",
                Arrays.asList("user_id", "subject_id", "chapter_id"));
    }

    private void handleViewerPrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId, JSONObject body,
            String tableName,
            String privilegeType,
            List<String> primaryKeys,
            Set<String> permissionKeys,
            boolean includeHasNextLevel)
            throws Exception {
        Map<String, Integer> idValues = new LinkedHashMap<>();
        for (String key : primaryKeys) {
            Integer value = AdminApiUtil.getInt(body, request, key);
            if (value == null) {
                throw new IllegalArgumentException(key + " is required");
            }
            idValues.put(key, value);
        }

        Timestamp expiresAt = parseTimestamp(AdminApiUtil.getString(body, request, "expires_at"));

        try (Connection conn = DBConnection.getConnection()) {
            boolean exists = checkPrivilegeExists(conn, tableName, idValues);

            List<String> insertColumns = new ArrayList<>(primaryKeys);
            List<Object> insertValues = new ArrayList<>();
            for (String key : primaryKeys) {
                insertValues.add(idValues.get(key));
            }

            for (String key : permissionKeys) {
                if (!includeHasNextLevel && "has_next_level".equals(key)) {
                    continue;
                }
                insertColumns.add(key);
                insertValues.add(resolveViewerPermissionFlag(body, key));
            }

            insertColumns.add("expires_at");
            insertValues.add(expiresAt);
            insertColumns.add("granted_by");
            insertValues.add(Integer.valueOf(adminUserId));
            insertColumns.add("granted_at");
            insertValues.add(new Timestamp(System.currentTimeMillis()));
            insertColumns.add("is_active");
            insertValues.add(Integer.valueOf(1));

            StringBuilder sql = new StringBuilder("INSERT INTO ").append(tableName).append(" (");
            sql.append(String.join(", ", insertColumns));
            sql.append(") VALUES (");
            appendPlaceholders(sql, insertColumns.size());
            sql.append(") ON DUPLICATE KEY UPDATE ");

            List<String> updates = new ArrayList<>();
            for (String key : permissionKeys) {
                if (!includeHasNextLevel && "has_next_level".equals(key)) {
                    continue;
                }
                updates.add(key + "=VALUES(" + key + ")");
            }
            updates.add("expires_at=VALUES(expires_at)");
            updates.add("granted_by=VALUES(granted_by)");
            updates.add("granted_at=VALUES(granted_at)");
            updates.add("is_active=1");
            sql.append(String.join(", ", updates));

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                bindValues(ps, insertValues);
                ps.executeUpdate();
            }

            insertPrivilegeAudit(conn, adminUserId,
                    idValues.get("user_id").intValue(),
                    privilegeType,
                    idValues.containsKey("subject_id") ? idValues.get("subject_id") : null,
                    idValues.containsKey("chapter_id") ? idValues.get("chapter_id") : null,
                    exists ? "UPDATE" : "GRANT",
                    body.toString());
        }

        JSONObject data = new JSONObject();
        data.put("updated", true);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleViewerPrivilegeRevoke(HttpServletRequest request, HttpServletResponse response,
            int adminUserId, JSONObject body,
            String tableName,
            String privilegeType,
            List<String> primaryKeys)
            throws Exception {
        Map<String, Integer> idValues = new LinkedHashMap<>();
        for (String key : primaryKeys) {
            Integer value = AdminApiUtil.getInt(body, request, key);
            if (value == null) {
                throw new IllegalArgumentException(key + " is required");
            }
            idValues.put(key, value);
        }

        int updated;
        try (Connection conn = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE ").append(tableName).append(" SET is_active=0 WHERE ");
            appendWhereForKeys(sql, primaryKeys);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int index = 1;
                for (String key : primaryKeys) {
                    ps.setInt(index++, idValues.get(key).intValue());
                }
                updated = ps.executeUpdate();
            }

            JSONObject change = new JSONObject();
            change.put("is_active", 0);
            insertPrivilegeAudit(conn, adminUserId,
                    idValues.get("user_id").intValue(),
                    privilegeType,
                    idValues.containsKey("subject_id") ? idValues.get("subject_id") : null,
                    idValues.containsKey("chapter_id") ? idValues.get("chapter_id") : null,
                    "REVOKE",
                    change.toString());
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleDeveloperPrivilegeUpsert(HttpServletRequest request, HttpServletResponse response,
            int adminUserId, JSONObject body,
            String tableName,
            String privilegeType,
            List<String> primaryKeys)
            throws Exception {
        Map<String, Integer> idValues = new LinkedHashMap<>();
        for (String key : primaryKeys) {
            Integer value = AdminApiUtil.getInt(body, request, key);
            if (value == null) {
                throw new IllegalArgumentException(key + " is required");
            }
            idValues.put(key, value);
        }

        Timestamp expiresAt = parseTimestamp(AdminApiUtil.getString(body, request, "expires_at"));

        try (Connection conn = DBConnection.getConnection()) {
            boolean exists = checkPrivilegeExists(conn, tableName, idValues);

            List<String> columns = new ArrayList<>(primaryKeys);
            List<Object> values = new ArrayList<>();
            for (String key : primaryKeys) {
                values.add(idValues.get(key));
            }

            for (String key : DEVELOPER_PERMISSION_KEYS) {
                columns.add(key);
                values.add(AdminApiUtil.toFlag(body.opt(key), "0"));
            }

            columns.add("expires_at");
            values.add(expiresAt);
            columns.add("granted_by");
            values.add(Integer.valueOf(adminUserId));
            columns.add("granted_at");
            values.add(new Timestamp(System.currentTimeMillis()));
            columns.add("is_active");
            values.add(Integer.valueOf(1));

            StringBuilder sql = new StringBuilder("INSERT INTO ").append(tableName).append(" (")
                    .append(String.join(", ", columns)).append(") VALUES (");
            appendPlaceholders(sql, columns.size());
            sql.append(") ON DUPLICATE KEY UPDATE ");

            List<String> updates = new ArrayList<>();
            for (String key : DEVELOPER_PERMISSION_KEYS) {
                updates.add(key + "=VALUES(" + key + ")");
            }
            updates.add("expires_at=VALUES(expires_at)");
            updates.add("granted_by=VALUES(granted_by)");
            updates.add("granted_at=VALUES(granted_at)");
            updates.add("is_active=1");
            sql.append(String.join(", ", updates));

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                bindValues(ps, values);
                ps.executeUpdate();
            }

            insertPrivilegeAudit(conn, adminUserId,
                    idValues.get("user_id").intValue(),
                    privilegeType,
                    idValues.containsKey("subject_id") ? idValues.get("subject_id") : null,
                    idValues.containsKey("chapter_id") ? idValues.get("chapter_id") : null,
                    exists ? "UPDATE" : "GRANT",
                    body.toString());
        }

        JSONObject data = new JSONObject();
        data.put("updated", true);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handlePrivilegeOverview(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer subjectId = AdminApiUtil.toInteger(request.getParameter("subject_id"));
        Integer roleId = AdminApiUtil.toInteger(request.getParameter("role_id"));

        if (subjectId == null) {
            throw new IllegalArgumentException("subject_id is required");
        }
        if (roleId == null || (roleId.intValue() != 2 && roleId.intValue() != 3)) {
            throw new IllegalArgumentException("role_id must be 2 or 3");
        }

        JSONArray items = fetchPrivilegeOverviewItems(subjectId.intValue(), roleId.intValue());

        JSONObject data = new JSONObject();
        data.put("items", items);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handlePrivilegeExport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer subjectId = AdminApiUtil.toInteger(request.getParameter("subject_id"));
        Integer roleId = AdminApiUtil.toInteger(request.getParameter("role_id"));

        if (subjectId == null || roleId == null) {
            throw new IllegalArgumentException("subject_id and role_id are required");
        }

        JSONArray items = fetchPrivilegeOverviewItems(subjectId.intValue(), roleId.intValue());

        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Privileges");

            List<String> headers = new ArrayList<>();
            headers.add("User ID");
            headers.add("Username");
            headers.add("Name");
            headers.add("Email");

            if (roleId.intValue() == 2) {
                headers.addAll(Arrays.asList("has_next_level", "read_permission", "write_permission", "edit_permission",
                        "review_permission", "is_active", "expires_at"));
            } else {
                headers.addAll(Arrays.asList("has_next_level", "read_permission", "audio_permission", "video_permission",
                        "animation_permission", "program_permission", "chat_permission", "forum_permission",
                        "simulation_permission", "assignment_permission", "test_permission", "marks_review_permission",
                        "remarks_permission", "is_active", "expires_at"));
            }

            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.size(); i++) {
                headerRow.createCell(i).setCellValue(headers.get(i));
            }

            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                Row row = sheet.createRow(i + 1);
                row.createCell(0).setCellValue(item.optInt("user_id"));
                row.createCell(1).setCellValue(item.optString("username"));
                row.createCell(2).setCellValue((item.optString("first_name") + " " + item.optString("last_name")).trim());
                row.createCell(3).setCellValue(item.optString("email"));

                int col = 4;
                for (int h = 4; h < headers.size(); h++) {
                    String key = headers.get(h);
                    row.createCell(col++).setCellValue(item.optString(key));
                }
            }

            for (int i = 0; i < headers.size(); i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(baos);
        }

        byte[] xlsxBytes = baos.toByteArray();
        
        String subjectName = fetchSubjectName(subjectId.intValue());
        String roleLabel = roleId.intValue() == 2 ? "Teacher" : "Student";
        String filename = "privileges_matrix_" + (subjectName != null ? subjectName : subjectId) + "_" + roleLabel + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=" + filename);
        response.setContentLength(xlsxBytes.length);
        response.getOutputStream().write(xlsxBytes);
        response.getOutputStream().flush();
    }

    private JSONArray fetchPrivilegeOverviewItems(int subjectId, int roleId) throws SQLException {
        JSONArray items = new JSONArray();
        String sql;
        if (roleId == 2) {
            sql = "SELECT u.user_id, u.username, u.first_name, u.last_name, u.email,"
                    + " p.has_next_level, p.read_permission, p.write_permission, p.edit_permission, p.review_permission,"
                    + " p.expires_at, p.is_active"
                    + " FROM users u"
                    + " JOIN content_developer_users du ON du.user_id=u.user_id"
                    + " LEFT JOIN content_developer_privileges_subject p ON p.user_id=u.user_id AND p.subject_id=?"
                    + " WHERE u.role_id=2 ORDER BY u.username";
        } else {
            sql = "SELECT u.user_id, u.username, u.first_name, u.last_name, u.email,"
                    + " p.has_next_level, p.read_permission, p.audio_permission, p.video_permission, p.animation_permission,"
                    + " p.program_permission, p.chat_permission, p.forum_permission, p.simulation_permission,"
                    + " p.assignment_permission, p.test_permission, p.marks_review_permission, p.remarks_permission,"
                    + " p.expires_at, p.is_active"
                    + " FROM users u"
                    + " JOIN content_viewer_users vu ON vu.user_id=u.user_id"
                    + " LEFT JOIN content_viewer_privileges_subject p ON p.user_id=u.user_id AND p.subject_id=?"
                    + " WHERE u.role_id=3 ORDER BY u.username";
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, subjectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.put(mapRow(rs));
                }
            }
        }
        return items;
    }

    private void handlePrivilegeAuditList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int page = Math.max(1, parseIntOrDefault(request.getParameter("page"), 1));
        int pageSize = Math.max(1, Math.min(200, parseIntOrDefault(request.getParameter("page_size"), 20)));
        int offset = (page - 1) * pageSize;

        Integer targetUserId = AdminApiUtil.toInteger(request.getParameter("target_user_id"));
        Integer subjectId = AdminApiUtil.toInteger(request.getParameter("subject_id"));

        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (targetUserId != null) {
            where.append(" AND a.target_user_id=? ");
            params.add(targetUserId);
        }
        if (subjectId != null) {
            where.append(" AND a.subject_id=? ");
            params.add(subjectId);
        }

        JSONArray items = new JSONArray();
        int total = 0;

        String countSql = "SELECT COUNT(*) AS total FROM admin_privilege_audit a" + where;
        String dataSql = "SELECT a.audit_id, a.admin_user_id, a.target_user_id, a.privilege_type, a.subject_id, a.chapter_id,"
                + " a.action, a.changes_json, a.actioned_at,"
                + " au.username AS admin_username, tu.username AS target_username"
                + " FROM admin_privilege_audit a"
                + " LEFT JOIN users au ON au.user_id=a.admin_user_id"
                + " LEFT JOIN users tu ON tu.user_id=a.target_user_id"
                + where
                + " ORDER BY a.actioned_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement cps = conn.prepareStatement(countSql)) {
                bindValues(cps, params);
                try (ResultSet rs = cps.executeQuery()) {
                    if (rs.next()) {
                        total = rs.getInt("total");
                    }
                }
            }

            List<Object> dataParams = new ArrayList<>(params);
            dataParams.add(Integer.valueOf(pageSize));
            dataParams.add(Integer.valueOf(offset));

            try (PreparedStatement dps = conn.prepareStatement(dataSql)) {
                bindValues(dps, dataParams);
                try (ResultSet rs = dps.executeQuery()) {
                    while (rs.next()) {
                        items.put(mapRow(rs));
                    }
                }
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        data.put("total", total);
        data.put("page", page);
        data.put("page_size", pageSize);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handlePrivilegeAuditExport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer targetUserId = AdminApiUtil.toInteger(request.getParameter("target_user_id"));
        Integer subjectId = AdminApiUtil.toInteger(request.getParameter("subject_id"));

        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (targetUserId != null) {
            where.append(" AND a.target_user_id=? ");
            params.add(targetUserId);
        }
        if (subjectId != null) {
            where.append(" AND a.subject_id=? ");
            params.add(subjectId);
        }

        String dataSql = "SELECT a.audit_id, a.admin_user_id, a.target_user_id, a.privilege_type, a.subject_id, a.chapter_id,"
                + " a.action, a.changes_json, a.actioned_at,"
                + " au.username AS admin_username, tu.username AS target_username"
                + " FROM admin_privilege_audit a"
                + " LEFT JOIN users au ON au.user_id=a.admin_user_id"
                + " LEFT JOIN users tu ON tu.user_id=a.target_user_id"
                + where
                + " ORDER BY a.actioned_at DESC";

        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Audit_Logs");
            List<String> headers = Arrays.asList("Audit ID", "Admin User", "Target User", "Action", "Type", "Subject ID", "Chapter ID", "Date", "Details");
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.size(); i++) {
                headerRow.createCell(i).setCellValue(headers.get(i));
            }

            int rIndex = 1;
            try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(dataSql)) {
                bindValues(ps, params);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Row row = sheet.createRow(rIndex++);
                        row.createCell(0).setCellValue(rs.getInt("audit_id"));
                        row.createCell(1).setCellValue(rs.getString("admin_username") != null ? rs.getString("admin_username") : String.valueOf(rs.getInt("admin_user_id")));
                        row.createCell(2).setCellValue(rs.getString("target_username") != null ? rs.getString("target_username") : String.valueOf(rs.getInt("target_user_id")));
                        row.createCell(3).setCellValue(rs.getString("action") != null ? rs.getString("action") : "");
                        row.createCell(4).setCellValue(rs.getString("privilege_type") != null ? rs.getString("privilege_type") : "");
                        row.createCell(5).setCellValue(rs.getObject("subject_id") != null ? rs.getString("subject_id") : "");
                        row.createCell(6).setCellValue(rs.getObject("chapter_id") != null ? rs.getString("chapter_id") : "");
                        Timestamp ts = rs.getTimestamp("actioned_at");
                        row.createCell(7).setCellValue(ts != null ? ts.toString() : "");
                        row.createCell(8).setCellValue(rs.getString("changes_json") != null ? rs.getString("changes_json") : "");
                    }
                }
            }

            for (int i = 0; i < headers.size(); i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(baos);
        }

        byte[] xlsxBytes = baos.toByteArray();
        
        String subjectName = subjectId != null ? fetchSubjectName(subjectId.intValue()) : null;
        String filename = "privilege_audit_" + (subjectName != null ? subjectName : (subjectId != null ? subjectId : "all")) + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=" + filename);
        response.setContentLength(xlsxBytes.length);
        response.getOutputStream().write(xlsxBytes);
        response.getOutputStream().flush();
    }

    // =====================================================================
    // Section 4: Academic Hierarchy + Class Subject assignment
    // =====================================================================

    private void handleHierarchyList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String level = valueOrFallback(AdminApiUtil.getRouteParam(request, "level")).trim().toLowerCase(Locale.ENGLISH);

        if ("subjects".equals(level)) {
            JSONArray items = new JSONArray();
            try (Connection conn = DBConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement("SELECT subject_id, subject_name FROM subject ORDER BY subject_name");
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.put(mapRow(rs));
                }
            }
            JSONObject data = new JSONObject();
            data.put("items", items);
            AdminApiUtil.writeSuccess(response, data);
            return;
        }

        if ("countries".equals(level)) {
            JSONArray items = new JSONArray();
            try (Connection conn = DBConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement("SELECT country_id, country_name FROM country_list ORDER BY country_name");
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.put(mapRow(rs));
                }
            }
            JSONObject data = new JSONObject();
            data.put("items", items);
            AdminApiUtil.writeSuccess(response, data);
            return;
        }

        if ("chapters".equals(level)) {
            Integer subjectId = AdminApiUtil.toInteger(request.getParameter("subject_id"));
            if (subjectId == null) {
                throw new IllegalArgumentException("subject_id is required for chapters");
            }
            JSONArray items = new JSONArray();
            try (Connection conn = DBConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement(
                            "SELECT chapter_id, chapter_name FROM chapter WHERE subject_id=? ORDER BY chapter_id")) {
                ps.setInt(1, subjectId.intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        items.put(mapRow(rs));
                    }
                }
            }
            JSONObject data = new JSONObject();
            data.put("items", items);
            AdminApiUtil.writeSuccess(response, data);
            return;
        }

        HierarchyMeta meta = HierarchyMeta.byRouteLevel(level);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported hierarchy level");
        }

        StringBuilder sql = new StringBuilder("SELECT * FROM ").append(meta.tableName).append(" WHERE 1=1");
        List<Object> params = new ArrayList<>();
        for (String parentCol : meta.parentColumns) {
            Integer value = AdminApiUtil.toInteger(request.getParameter(parentCol));
            if (value != null) {
                sql.append(" AND ").append(parentCol).append("=?");
                params.add(value);
            }
        }
        sql.append(" ORDER BY ").append(meta.idColumn).append(" ASC");

        JSONArray items = new JSONArray();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindValues(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.put(mapRow(rs));
                }
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleHierarchyCreate(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String level = valueOrFallback(AdminApiUtil.getRouteParam(request, "level")).trim().toLowerCase(Locale.ENGLISH);
        HierarchyMeta meta = HierarchyMeta.byRouteLevel(level);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported hierarchy level");
        }

        JSONObject body = readBodyWhenJson(request);

        Map<String, Integer> parentValues = new LinkedHashMap<>();
        for (String parentCol : meta.parentColumns) {
            Integer parent = AdminApiUtil.getInt(body, request, parentCol);
            if (parent == null) {
                throw new IllegalArgumentException(parentCol + " is required");
            }
            parentValues.put(parentCol, parent);
        }

        String name = valueOrFallback(AdminApiUtil.getString(body, request, meta.nameColumn)).trim();
        if (name.isEmpty()) {
            throw new IllegalArgumentException(meta.nameColumn + " is required");
        }

        try (Connection conn = DBConnection.getConnection()) {
            int newId = getNextHierarchyId(conn, meta, parentValues);

            List<String> cols = new ArrayList<>();
            List<Object> vals = new ArrayList<>();

            for (Map.Entry<String, Integer> e : parentValues.entrySet()) {
                cols.add(e.getKey());
                vals.add(e.getValue());
            }

            cols.add(meta.idColumn);
            vals.add(Integer.valueOf(newId));

            cols.add(meta.nameColumn);
            vals.add(name);

            if (meta.supportsHasNextLevel) {
                cols.add("has_next_level");
                vals.add("0");
            }

            cols.add("responsible_person_name");
            vals.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_name")));
            cols.add("responsible_person_role");
            vals.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_role")));
            cols.add("responsible_person_address");
            vals.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_address")));
            cols.add("responsible_person_contact_no");
            vals.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_contact_no")));
            cols.add("responsible_person_email");
            vals.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_email")));

            if ("university".equals(meta.tableName)) {
                cols.add("aicte_id");
                vals.add(valueOrNull(AdminApiUtil.getString(body, request, "aicte_id")));
            }

            StringBuilder sql = new StringBuilder("INSERT INTO ").append(meta.tableName).append(" (")
                    .append(String.join(", ", cols)).append(") VALUES (");
            appendPlaceholders(sql, cols.size());
            sql.append(")");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                bindValues(ps, vals);
                ps.executeUpdate();
            }

            JSONObject data = new JSONObject();
            data.put("id", newId);
            for (Map.Entry<String, Integer> e : parentValues.entrySet()) {
                data.put(e.getKey(), e.getValue().intValue());
            }
            data.put(meta.nameColumn, name);
            AdminApiUtil.writeSuccess(response, data);
        }
    }

    private void handleHierarchyUpdate(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String level = valueOrFallback(AdminApiUtil.getRouteParam(request, "level")).trim().toLowerCase(Locale.ENGLISH);
        HierarchyMeta meta = HierarchyMeta.byRouteLevel(level);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported hierarchy level");
        }

        JSONObject body = readBodyWhenJson(request);
        Integer id = AdminApiUtil.toInteger(AdminApiUtil.getRouteParam(request, "id"));
        if (id == null) {
            throw new IllegalArgumentException("Invalid hierarchy id");
        }

        String name = valueOrFallback(AdminApiUtil.getString(body, request, meta.nameColumn)).trim();
        if (name.isEmpty()) {
            throw new IllegalArgumentException(meta.nameColumn + " is required");
        }

        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("UPDATE ").append(meta.tableName)
                .append(" SET ")
                .append(meta.nameColumn).append("=?, ")
                .append("responsible_person_name=?, responsible_person_role=?, responsible_person_address=?, responsible_person_contact_no=?, responsible_person_email=?")
                .append(" WHERE ");

        params.add(name);
        params.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_name")));
        params.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_role")));
        params.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_address")));
        params.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_contact_no")));
        params.add(valueOrNull(AdminApiUtil.getString(body, request, "responsible_person_email")));

        for (String parentCol : meta.parentColumns) {
            Integer parent = AdminApiUtil.getInt(body, request, parentCol);
            if (parent == null) {
                throw new IllegalArgumentException(parentCol + " is required");
            }
            sql.append(parentCol).append("=? AND ");
            params.add(parent);
        }
        sql.append(meta.idColumn).append("=?");
        params.add(id);

        int updated;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindValues(ps, params);
            updated = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleHierarchyDelete(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String level = valueOrFallback(AdminApiUtil.getRouteParam(request, "level")).trim().toLowerCase(Locale.ENGLISH);
        HierarchyMeta meta = HierarchyMeta.byRouteLevel(level);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported hierarchy level");
        }

        JSONObject body = readBodyWhenJson(request);
        Integer id = AdminApiUtil.toInteger(AdminApiUtil.getRouteParam(request, "id"));
        if (id == null) {
            throw new IllegalArgumentException("Invalid hierarchy id");
        }

        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("DELETE FROM ").append(meta.tableName).append(" WHERE ");

        for (String parentCol : meta.parentColumns) {
            Integer parent = AdminApiUtil.getInt(body, request, parentCol);
            if (parent == null) {
                throw new IllegalArgumentException(parentCol + " is required");
            }
            sql.append(parentCol).append("=? AND ");
            params.add(parent);
        }
        sql.append(meta.idColumn).append("=?");
        params.add(id);

        int deleted;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindValues(ps, params);
            deleted = ps.executeUpdate();
        } catch (SQLException ex) {
            if (isIntegrityConstraintViolation(ex)) {
                throw new IllegalArgumentException("Cannot delete this record because dependent records exist");
            }
            throw ex;
        }

        JSONObject data = new JSONObject();
        data.put("deleted", deleted);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleClassSubjectAssign(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);

        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");
        Integer subjectId = AdminApiUtil.getInt(body, request, "subject_id");

        if (universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null || subjectId == null) {
            throw new IllegalArgumentException("Missing required class-subject fields");
        }

        String sql = "INSERT INTO class_subject (university_id, faculty_id, department_id, course_id, specialization_id, class_id, subject_id)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?)"
                + " ON DUPLICATE KEY UPDATE subject_id=VALUES(subject_id)";

        int updated;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, universityId.intValue());
            ps.setInt(2, facultyId.intValue());
            ps.setInt(3, departmentId.intValue());
            ps.setInt(4, courseId.intValue());
            ps.setInt(5, specializationId.intValue());
            ps.setInt(6, classId.intValue());
            ps.setInt(7, subjectId.intValue());
            updated = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleClassSubjectRemove(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);

        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");
        Integer subjectId = AdminApiUtil.getInt(body, request, "subject_id");

        if (universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null || subjectId == null) {
            throw new IllegalArgumentException("Missing required class-subject fields");
        }

        int deleted;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM class_subject WHERE university_id=? AND faculty_id=? AND department_id=? AND course_id=? AND specialization_id=? AND class_id=? AND subject_id=?")) {
            ps.setInt(1, universityId.intValue());
            ps.setInt(2, facultyId.intValue());
            ps.setInt(3, departmentId.intValue());
            ps.setInt(4, courseId.intValue());
            ps.setInt(5, specializationId.intValue());
            ps.setInt(6, classId.intValue());
            ps.setInt(7, subjectId.intValue());
            deleted = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("deleted", deleted);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleClassSubjectList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer universityId = AdminApiUtil.toInteger(request.getParameter("university_id"));
        Integer facultyId = AdminApiUtil.toInteger(request.getParameter("faculty_id"));
        Integer departmentId = AdminApiUtil.toInteger(request.getParameter("department_id"));
        Integer courseId = AdminApiUtil.toInteger(request.getParameter("course_id"));
        Integer specializationId = AdminApiUtil.toInteger(request.getParameter("specialization_id"));
        Integer classId = AdminApiUtil.toInteger(request.getParameter("class_id"));

        if (universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null) {
            throw new IllegalArgumentException("All class hierarchy ids are required");
        }

        String sql = "SELECT cs.subject_id, s.subject_name, COUNT(csc.chapter_id) AS enabled_chapters"
                + " FROM class_subject cs"
                + " JOIN subject s ON s.subject_id=cs.subject_id"
                + " LEFT JOIN class_subject_chapter csc ON csc.university_id=cs.university_id AND csc.faculty_id=cs.faculty_id"
                + " AND csc.department_id=cs.department_id AND csc.course_id=cs.course_id AND csc.specialization_id=cs.specialization_id"
                + " AND csc.class_id=cs.class_id AND csc.subject_id=cs.subject_id"
                + " WHERE cs.university_id=? AND cs.faculty_id=? AND cs.department_id=? AND cs.course_id=?"
                + " AND cs.specialization_id=? AND cs.class_id=?"
                + " GROUP BY cs.subject_id, s.subject_name ORDER BY s.subject_name";

        JSONArray items = new JSONArray();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, universityId.intValue());
            ps.setInt(2, facultyId.intValue());
            ps.setInt(3, departmentId.intValue());
            ps.setInt(4, courseId.intValue());
            ps.setInt(5, specializationId.intValue());
            ps.setInt(6, classId.intValue());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.put(mapRow(rs));
                }
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleClassSubjectChapterList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        Integer universityId = AdminApiUtil.toInteger(request.getParameter("university_id"));
        Integer facultyId = AdminApiUtil.toInteger(request.getParameter("faculty_id"));
        Integer departmentId = AdminApiUtil.toInteger(request.getParameter("department_id"));
        Integer courseId = AdminApiUtil.toInteger(request.getParameter("course_id"));
        Integer specializationId = AdminApiUtil.toInteger(request.getParameter("specialization_id"));
        Integer classId = AdminApiUtil.toInteger(request.getParameter("class_id"));
        Integer subjectId = AdminApiUtil.toInteger(request.getParameter("subject_id"));

        if (universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null || subjectId == null) {
            throw new IllegalArgumentException("Class hierarchy IDs and subject_id are required");
        }

        String sql = "SELECT ch.chapter_id, ch.chapter_name,"
                + " CASE WHEN csc.chapter_id IS NULL THEN 0 ELSE 1 END AS is_enabled"
                + " FROM chapter ch"
                + " LEFT JOIN class_subject_chapter csc ON csc.university_id=? AND csc.faculty_id=? AND csc.department_id=?"
                + " AND csc.course_id=? AND csc.specialization_id=? AND csc.class_id=? AND csc.subject_id=? AND csc.chapter_id=ch.chapter_id"
                + " WHERE ch.subject_id=?"
                + " ORDER BY ch.chapter_id";

        JSONArray items = new JSONArray();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, universityId.intValue());
            ps.setInt(2, facultyId.intValue());
            ps.setInt(3, departmentId.intValue());
            ps.setInt(4, courseId.intValue());
            ps.setInt(5, specializationId.intValue());
            ps.setInt(6, classId.intValue());
            ps.setInt(7, subjectId.intValue());
            ps.setInt(8, subjectId.intValue());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.put(mapRow(rs));
                }
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleClassSubjectChapterAssign(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);

        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");
        Integer subjectId = AdminApiUtil.getInt(body, request, "subject_id");
        Integer chapterId = AdminApiUtil.getInt(body, request, "chapter_id");

        if (universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null || subjectId == null || chapterId == null) {
            throw new IllegalArgumentException("Missing required class-subject-chapter fields");
        }

        String sql = "INSERT INTO class_subject_chapter (university_id, faculty_id, department_id, course_id, specialization_id, class_id, subject_id, chapter_id)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                + " ON DUPLICATE KEY UPDATE chapter_id=VALUES(chapter_id)";

        int updated;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, universityId.intValue());
            ps.setInt(2, facultyId.intValue());
            ps.setInt(3, departmentId.intValue());
            ps.setInt(4, courseId.intValue());
            ps.setInt(5, specializationId.intValue());
            ps.setInt(6, classId.intValue());
            ps.setInt(7, subjectId.intValue());
            ps.setInt(8, chapterId.intValue());
            updated = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleClassSubjectChapterRemove(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject body = readBodyWhenJson(request);

        Integer universityId = AdminApiUtil.getInt(body, request, "university_id");
        Integer facultyId = AdminApiUtil.getInt(body, request, "faculty_id");
        Integer departmentId = AdminApiUtil.getInt(body, request, "department_id");
        Integer courseId = AdminApiUtil.getInt(body, request, "course_id");
        Integer specializationId = AdminApiUtil.getInt(body, request, "specialization_id");
        Integer classId = AdminApiUtil.getInt(body, request, "class_id");
        Integer subjectId = AdminApiUtil.getInt(body, request, "subject_id");
        Integer chapterId = AdminApiUtil.getInt(body, request, "chapter_id");

        if (universityId == null || facultyId == null || departmentId == null || courseId == null
                || specializationId == null || classId == null || subjectId == null || chapterId == null) {
            throw new IllegalArgumentException("Missing required class-subject-chapter fields");
        }

        int deleted;
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM class_subject_chapter WHERE university_id=? AND faculty_id=? AND department_id=? AND course_id=? AND specialization_id=? AND class_id=? AND subject_id=? AND chapter_id=?")) {
            ps.setInt(1, universityId.intValue());
            ps.setInt(2, facultyId.intValue());
            ps.setInt(3, departmentId.intValue());
            ps.setInt(4, courseId.intValue());
            ps.setInt(5, specializationId.intValue());
            ps.setInt(6, classId.intValue());
            ps.setInt(7, subjectId.intValue());
            ps.setInt(8, chapterId.intValue());
            deleted = ps.executeUpdate();
        }

        JSONObject data = new JSONObject();
        data.put("deleted", deleted);
        AdminApiUtil.writeSuccess(response, data);
    }

    // =====================================================================
    // Section 5: Dashboard, Activity, Review Queue
    // =====================================================================

    private void handleDashboard(HttpServletRequest request, HttpServletResponse response) throws Exception {
        JSONObject data = new JSONObject();

        try (Connection conn = DBConnection.getConnection()) {
            JSONArray userRoleCounts = new JSONArray();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT role_id, COUNT(*) AS total FROM users GROUP BY role_id ORDER BY role_id");
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JSONObject item = new JSONObject();
                    item.put("role_id", rs.getInt("role_id"));
                    item.put("total", rs.getInt("total"));
                    userRoleCounts.put(item);
                }
            }
            data.put("total_users_by_role", userRoleCounts);

            data.put("active_users_today", queryForInt(conn,
                    "SELECT COUNT(*) AS total FROM users WHERE last_login_at >= CURDATE()"));
            data.put("locked_accounts", queryForInt(conn,
                    "SELECT COUNT(*) AS total FROM users WHERE failed_login_attempts >= 5 OR account_status='LOCKED'"));
            data.put("content_draft_count", queryForInt(conn,
                    "SELECT"
                            + " (SELECT COUNT(*) FROM chapter WHERE review_status='Draft' AND COALESCE(is_published,0)=0)"
                            + " +"
                            + " (SELECT COUNT(*) FROM topic_level1 WHERE review_status='Draft' AND COALESCE(is_published,0)=0) AS total"));
            data.put("content_published_count", queryForInt(conn,
                    "SELECT"
                            + " (SELECT COUNT(*) FROM chapter WHERE review_status='Published' OR COALESCE(is_published,0)=1)"
                            + " +"
                            + " (SELECT COUNT(*) FROM topic_level1 WHERE review_status='Published' OR COALESCE(is_published,0)=1) AS total"));
            data.put("total_subjects", queryForInt(conn, "SELECT COUNT(*) AS total FROM subject"));
            data.put("total_chapters", queryForInt(conn, "SELECT COUNT(*) AS total FROM chapter"));
            data.put("enrollments_expiring_soon", queryForInt(conn,
                    "SELECT COUNT(*) AS total FROM content_viewer_class_enrollment"
                            + " WHERE status='ACTIVE' AND valid_to BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 30 DAY)"));
        }

        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleActivity(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int page = Math.max(1, parseIntOrDefault(request.getParameter("page"), 1));
        int pageSize = Math.max(1, Math.min(200, parseIntOrDefault(request.getParameter("page_size"), 20)));
        int offset = (page - 1) * pageSize;

        String dateFrom = valueOrFallback(request.getParameter("date_from")).trim();
        String dateTo = valueOrFallback(request.getParameter("date_to")).trim();
        Integer userId = AdminApiUtil.toInteger(request.getParameter("user_id"));

        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (!dateFrom.isEmpty()) {
            where.append(" AND DATE(u.last_login_at) >= ? ");
            params.add(dateFrom);
        }
        if (!dateTo.isEmpty()) {
            where.append(" AND DATE(u.last_login_at) <= ? ");
            params.add(dateTo);
        }
        if (userId != null) {
            where.append(" AND u.user_id = ? ");
            params.add(userId);
        }

        int total = 0;
        JSONArray items = new JSONArray();

        String countSql = "SELECT COUNT(*) AS total FROM users u" + where;
        String dataSql = "SELECT u.user_id, u.username, u.last_login_at, u.failed_login_attempts, u.account_status,"
                + " u.role_id, r.role_name"
                + " FROM users u"
                + " LEFT JOIN roles r ON r.role_id=u.role_id"
                + where
                + " ORDER BY u.last_login_at DESC LIMIT ? OFFSET ?";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement cps = conn.prepareStatement(countSql)) {
                bindValues(cps, params);
                try (ResultSet rs = cps.executeQuery()) {
                    if (rs.next()) {
                        total = rs.getInt("total");
                    }
                }
            }

            List<Object> dataParams = new ArrayList<>(params);
            dataParams.add(Integer.valueOf(pageSize));
            dataParams.add(Integer.valueOf(offset));

            try (PreparedStatement dps = conn.prepareStatement(dataSql)) {
                bindValues(dps, dataParams);
                try (ResultSet rs = dps.executeQuery()) {
                    while (rs.next()) {
                        items.put(mapRow(rs));
                    }
                }
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        data.put("total", total);
        data.put("page", page);
        data.put("page_size", pageSize);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleReviewQueueList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String status = valueOrFallback(request.getParameter("status")).trim().toUpperCase(Locale.ENGLISH);
        if (status.isEmpty()) {
            status = "DRAFT";
        }
        if ("PENDING".equals(status)) {
            status = "DRAFT";
        }

        String condition;
        if ("APPROVED".equals(status)) {
            condition = "(LOWER(COALESCE(NULLIF(TRIM(q.review_status), ''), 'draft'))='published' OR COALESCE(q.is_published,0)=1)";
        } else if ("REJECTED".equals(status)) {
            condition = "LOWER(COALESCE(NULLIF(TRIM(q.review_status), ''), 'draft'))='rejected'";
        } else {
            condition = "LOWER(COALESCE(NULLIF(TRIM(q.review_status), ''), 'draft'))='draft' AND COALESCE(q.is_published,0)=0";
        }

        String sql = "SELECT q.*, rr.remarks"
                + " FROM ("
                + " SELECT 'chapter' AS content_type, c.subject_id, c.chapter_id,"
                + " NULL AS topic_level1_id, NULL AS topic_level2_id, NULL AS topic_level3_id, NULL AS topic_level4_id, NULL AS topic_level5_id,"
                + " c.chapter_name AS content_name, COALESCE(NULLIF(TRIM(c.content), ''), NULLIF(TRIM(c.introduction), ''), '') AS content, c.created_by, c.created_at, c.version_no, COALESCE(NULLIF(c.review_status, ''), 'Draft') AS review_status, c.is_published,"
                + " CONCAT_WS('-', c.subject_id, c.chapter_id) AS composite_id"
                + " FROM chapter c"
                + " UNION ALL "
                + " SELECT 'topic_level1' AS content_type, t1.subject_id, t1.chapter_id,"
                + " t1.topic_level1_id, NULL AS topic_level2_id, NULL AS topic_level3_id, NULL AS topic_level4_id, NULL AS topic_level5_id,"
                + " t1.topic_level1_name AS content_name, COALESCE(NULLIF(TRIM(t1.content), ''), NULLIF(TRIM(t1.introduction), ''), '') AS content, t1.created_by, t1.created_at, t1.version_no, COALESCE(NULLIF(t1.review_status, ''), 'Draft') AS review_status, t1.is_published,"
                + " CONCAT_WS('-', t1.subject_id, t1.chapter_id, t1.topic_level1_id) AS composite_id"
                + " FROM topic_level1 t1"
                + " UNION ALL "
                + " SELECT 'topic_level2' AS content_type, t2.subject_id, t2.chapter_id,"
                + " t2.topic_level1_id, t2.topic_level2_id, NULL AS topic_level3_id, NULL AS topic_level4_id, NULL AS topic_level5_id,"
                + " t2.topic_level2_name AS content_name, COALESCE(NULLIF(TRIM(t2.content), ''), NULLIF(TRIM(t2.introduction), ''), '') AS content, t2.created_by, t2.created_at, t2.version_no, COALESCE(NULLIF(t2.review_status, ''), 'Draft') AS review_status, t2.is_published,"
                + " CONCAT_WS('-', t2.subject_id, t2.chapter_id, t2.topic_level1_id, t2.topic_level2_id) AS composite_id"
                + " FROM topic_level2 t2"
                + " UNION ALL "
                + " SELECT 'topic_level3' AS content_type, t3.subject_id, t3.chapter_id,"
                + " t3.topic_level1_id, t3.topic_level2_id, t3.topic_level3_id, NULL AS topic_level4_id, NULL AS topic_level5_id,"
                + " t3.topic_level3_name AS content_name, COALESCE(NULLIF(TRIM(t3.content), ''), NULLIF(TRIM(t3.introduction), ''), '') AS content, t3.created_by, t3.created_at, t3.version_no, COALESCE(NULLIF(t3.review_status, ''), 'Draft') AS review_status, t3.is_published,"
                + " CONCAT_WS('-', t3.subject_id, t3.chapter_id, t3.topic_level1_id, t3.topic_level2_id, t3.topic_level3_id) AS composite_id"
                + " FROM topic_level3 t3"
                + " UNION ALL "
                + " SELECT 'topic_level4' AS content_type, t4.subject_id, t4.chapter_id,"
                + " t4.topic_level1_id, t4.topic_level2_id, t4.topic_level3_id, t4.topic_level4_id, NULL AS topic_level5_id,"
                + " t4.topic_level4_name AS content_name, COALESCE(NULLIF(TRIM(t4.content), ''), NULLIF(TRIM(t4.introduction), ''), '') AS content, t4.created_by, t4.created_at, t4.version_no, COALESCE(NULLIF(t4.review_status, ''), 'Draft') AS review_status, t4.is_published,"
                + " CONCAT_WS('-', t4.subject_id, t4.chapter_id, t4.topic_level1_id, t4.topic_level2_id, t4.topic_level3_id, t4.topic_level4_id) AS composite_id"
                + " FROM topic_level4 t4"
                + " UNION ALL "
                + " SELECT 'topic_level5' AS content_type, t5.subject_id, t5.chapter_id,"
                + " t5.topic_level1_id, t5.topic_level2_id, t5.topic_level3_id, t5.topic_level4_id, t5.topic_level5_id,"
                + " t5.topic_level5_name AS content_name, COALESCE(NULLIF(TRIM(t5.content), ''), NULLIF(TRIM(t5.introduction), ''), '') AS content, t5.created_by, t5.created_at, t5.version_no, COALESCE(NULLIF(t5.review_status, ''), 'Draft') AS review_status, t5.is_published,"
                + " CONCAT_WS('-', t5.subject_id, t5.chapter_id, t5.topic_level1_id, t5.topic_level2_id, t5.topic_level3_id, t5.topic_level4_id, t5.topic_level5_id) AS composite_id"
                + " FROM topic_level5 t5"
                + ") q"
                + " LEFT JOIN admin_content_review_remarks rr"
                + " ON rr.content_type=q.content_type AND rr.composite_id=q.composite_id"
                + " WHERE " + condition
                + " ORDER BY q.created_at DESC";

        JSONArray items = new JSONArray();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                items.put(mapRow(rs));
            }
        }

        JSONObject data = new JSONObject();
        data.put("items", items);
        data.put("status", status);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleReviewApprove(HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        String contentType = normalizeContentType(AdminApiUtil.getRouteParam(request, "content_type"));
        String compositeId = decodePathSegment(AdminApiUtil.getRouteParam(request, "composite_id"));

        ContentMeta meta = ContentMeta.byType(contentType);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported content_type");
        }

        int[] ids = parseCompositeId(compositeId, meta);
        int updated;

        try (Connection conn = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE ").append(meta.tableName)
                    .append(" SET review_status='Published', approved_by=?, approved_at=NOW(), is_published=1, published_at=NOW(), version_no=COALESCE(version_no,0)+1 WHERE ");
            appendWhereForKeys(sql, meta.idColumns);

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                ps.setInt(1, adminUserId);
                for (int i = 0; i < ids.length; i++) {
                    ps.setInt(i + 2, ids[i]);
                }
                updated = ps.executeUpdate();
            }
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleReviewMoveToDraft(HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        String contentType = normalizeContentType(AdminApiUtil.getRouteParam(request, "content_type"));
        String compositeId = decodePathSegment(AdminApiUtil.getRouteParam(request, "composite_id"));

        ContentMeta meta = ContentMeta.byType(contentType);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported content_type");
        }

        int[] ids = parseCompositeId(compositeId, meta);
        int updated;

        try (Connection conn = DBConnection.getConnection()) {
            StringBuilder sql = new StringBuilder("UPDATE ").append(meta.tableName)
                    .append(" SET review_status='Draft', is_published=0, approved_by=NULL, approved_at=NULL, published_at=NULL WHERE ");
            appendWhereForKeys(sql, meta.idColumns);
            sql.append(" AND (LOWER(COALESCE(NULLIF(TRIM(review_status), ''), 'draft'))='published' OR COALESCE(is_published,0)=1)");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < ids.length; i++) {
                    ps.setInt(i + 1, ids[i]);
                }
                updated = ps.executeUpdate();
            }
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    private void handleReviewReject(HttpServletRequest request, HttpServletResponse response, int adminUserId)
            throws Exception {
        JSONObject body = readBodyWhenJson(request);
        String remarks = valueOrFallback(AdminApiUtil.getString(body, request, "remarks")).trim();

        String contentType = normalizeContentType(AdminApiUtil.getRouteParam(request, "content_type"));
        String compositeId = decodePathSegment(AdminApiUtil.getRouteParam(request, "composite_id"));

        ContentMeta meta = ContentMeta.byType(contentType);
        if (meta == null) {
            throw new IllegalArgumentException("Unsupported content_type");
        }

        int[] ids = parseCompositeId(compositeId, meta);
        int updated;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                StringBuilder sql = new StringBuilder("UPDATE ").append(meta.tableName)
                        .append(" SET review_status='Rejected', is_published=0 WHERE ");
                appendWhereForKeys(sql, meta.idColumns);

                try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                    for (int i = 0; i < ids.length; i++) {
                        ps.setInt(i + 1, ids[i]);
                    }
                    updated = ps.executeUpdate();
                }

                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO admin_content_review_remarks (content_type, composite_id, remarks, admin_user_id, created_at) VALUES (?, ?, ?, ?, NOW())"
                                + " ON DUPLICATE KEY UPDATE remarks=VALUES(remarks), admin_user_id=VALUES(admin_user_id), created_at=NOW()")) {
                    ps.setString(1, contentType);
                    ps.setString(2, compositeId);
                    ps.setString(3, remarks);
                    ps.setInt(4, adminUserId);
                    ps.executeUpdate();
                }

                conn.commit();
            } catch (Exception ex) {
                conn.rollback();
                throw ex;
            } finally {
                conn.setAutoCommit(true);
            }
        }

        JSONObject data = new JSONObject();
        data.put("updated", updated);
        AdminApiUtil.writeSuccess(response, data);
    }

    // =====================================================================
    // Internal helpers
    // =====================================================================

    private int insertBaseUser(Connection conn, String username, String plainPassword, int roleId,
            String firstName, String lastName, String email, String mobileNo)
            throws SQLException {
        String sql = "INSERT INTO users (username, password_hash, role_id, first_name, last_name, email, mobile_no,"
                + " password_updated_at, account_status, failed_login_attempts)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), 'ACTIVE', 0)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, username);
            ps.setString(2, PasswordHash.hashPassword(plainPassword));
            ps.setInt(3, roleId);
            ps.setString(4, firstName);
            ps.setString(5, lastName);
            ps.setString(6, email);
            ps.setString(7, mobileNo);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Failed to create user");
    }

    private boolean isUsernameTaken(Connection conn, String username) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE username=?")) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private JSONObject fetchUserById(Connection conn, int userId) throws SQLException {
        String sql = "SELECT u.user_id, u.username, u.first_name, u.last_name, u.email, u.mobile_no, u.role_id, u.account_status,"
                + " u.failed_login_attempts, u.last_login_at,"
                + " COALESCE(cdu.university_id, cvu.university_id) AS university_id,"
                + " COALESCE(cdu.faculty_id, cvu.faculty_id) AS faculty_id,"
                + " COALESCE(cdu.department_id, cvu.department_id) AS department_id,"
                + " COALESCE(cdu.course_id, cvu.course_id) AS course_id,"
                + " cvu.specialization_id, cvu.class_id,"
                + " COALESCE(cdu.nationality_id, cvu.nationality_id) AS nationality_id"
                + " FROM users u"
                + " LEFT JOIN content_developer_users cdu ON cdu.user_id=u.user_id"
                + " LEFT JOIN content_viewer_users cvu ON cvu.user_id=u.user_id"
                + " WHERE u.user_id=?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return new JSONObject();
    }

    private UserListResult fetchUsers(UserListQuery query) throws SQLException {
        StringBuilder where = new StringBuilder(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (query.roleId != null) {
            where.append(" AND u.role_id=? ");
            params.add(query.roleId);
        }

        if (query.accountStatus != null && !query.accountStatus.trim().isEmpty()) {
            where.append(" AND u.account_status=? ");
            params.add(query.accountStatus.trim());
        }

        if (query.universityId != null) {
            where.append(" AND COALESCE(cdu.university_id, cvu.university_id)=? ");
            params.add(query.universityId);
        }
        if (query.departmentId != null) {
            where.append(" AND COALESCE(cdu.department_id, cvu.department_id)=? ");
            params.add(query.departmentId);
        }
        if (query.classId != null) {
            where.append(" AND cvu.class_id=? ");
            params.add(query.classId);
        }

        if (query.search != null && !query.search.trim().isEmpty()) {
            where.append(" AND (LOWER(u.username) LIKE ? OR LOWER(CONCAT(IFNULL(u.first_name,''),' ',IFNULL(u.last_name,''))) LIKE ? OR LOWER(IFNULL(u.email,'')) LIKE ?) ");
            String like = "%" + query.search.trim().toLowerCase(Locale.ENGLISH) + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }

        String fromSql = " FROM users u"
                + " LEFT JOIN roles r ON r.role_id=u.role_id"
                + " LEFT JOIN content_developer_users cdu ON cdu.user_id=u.user_id"
                + " LEFT JOIN content_viewer_users cvu ON cvu.user_id=u.user_id"
                + " LEFT JOIN university un ON un.university_id=COALESCE(cdu.university_id, cvu.university_id)"
                + " LEFT JOIN faculty f ON f.university_id=COALESCE(cdu.university_id, cvu.university_id) AND f.faculty_id=COALESCE(cdu.faculty_id, cvu.faculty_id)"
                + " LEFT JOIN department d ON d.university_id=COALESCE(cdu.university_id, cvu.university_id)"
                + " AND d.faculty_id=COALESCE(cdu.faculty_id, cvu.faculty_id) AND d.department_id=COALESCE(cdu.department_id, cvu.department_id)"
                + " LEFT JOIN course c ON c.university_id=COALESCE(cdu.university_id, cvu.university_id)"
                + " AND c.faculty_id=COALESCE(cdu.faculty_id, cvu.faculty_id) AND c.department_id=COALESCE(cdu.department_id, cvu.department_id)"
                + " AND c.course_id=COALESCE(cdu.course_id, cvu.course_id)"
                + " LEFT JOIN specialization sp ON sp.university_id=cvu.university_id AND sp.faculty_id=cvu.faculty_id"
                + " AND sp.department_id=cvu.department_id AND sp.course_id=cvu.course_id AND sp.specialization_id=cvu.specialization_id"
                + " LEFT JOIN class cl ON cl.university_id=cvu.university_id AND cl.faculty_id=cvu.faculty_id AND cl.department_id=cvu.department_id"
                + " AND cl.course_id=cvu.course_id AND cl.specialization_id=cvu.specialization_id AND cl.class_id=cvu.class_id";

        String countSql = "SELECT COUNT(*) AS total" + fromSql + where;

        String dataSql = "SELECT u.user_id, u.username, u.first_name, u.last_name, u.email, u.role_id, r.role_name, u.account_status,"
                + " u.last_login_at, u.failed_login_attempts,"
                + " COALESCE(cdu.university_id, cvu.university_id) AS university_id,"
                + " COALESCE(cdu.faculty_id, cvu.faculty_id) AS faculty_id,"
                + " COALESCE(cdu.department_id, cvu.department_id) AS department_id,"
                + " COALESCE(cdu.course_id, cvu.course_id) AS course_id,"
                + " cvu.specialization_id, cvu.class_id,"
                + " un.university_name, f.faculty_name, d.department_name, c.course_name, sp.specialization_name, cl.class_name"
                + fromSql + where
                + " ORDER BY u.created_at DESC LIMIT ? OFFSET ?";

        JSONArray items = new JSONArray();
        int total;

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement cps = conn.prepareStatement(countSql)) {
                bindValues(cps, params);
                try (ResultSet rs = cps.executeQuery()) {
                    total = rs.next() ? rs.getInt("total") : 0;
                }
            }

            List<Object> dataParams = new ArrayList<>(params);
            dataParams.add(Integer.valueOf(query.pageSize));
            dataParams.add(Integer.valueOf((query.page - 1) * query.pageSize));

            try (PreparedStatement dps = conn.prepareStatement(dataSql)) {
                bindValues(dps, dataParams);
                try (ResultSet rs = dps.executeQuery()) {
                    while (rs.next()) {
                        items.put(mapRow(rs));
                    }
                }
            }
        }

        return new UserListResult(items, total);
    }

    private boolean checkPrivilegeExists(Connection conn, String tableName, Map<String, Integer> keyValues)
            throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT 1 FROM ").append(tableName).append(" WHERE ");
        appendWhereForKeys(sql, new ArrayList<>(keyValues.keySet()));
        sql.append(" LIMIT 1");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            for (String key : keyValues.keySet()) {
                ps.setInt(index++, keyValues.get(key).intValue());
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void insertPrivilegeAudit(Connection conn, int adminUserId, int targetUserId, String privilegeType,
            Integer subjectId, Integer chapterId, String action, String changesJson)
            throws SQLException {
        String sql = "INSERT INTO admin_privilege_audit"
                + " (admin_user_id, target_user_id, privilege_type, subject_id, chapter_id, action, changes_json, actioned_at)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, adminUserId);
            ps.setInt(2, targetUserId);
            ps.setString(3, privilegeType);
            if (subjectId == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, subjectId.intValue());
            }
            if (chapterId == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(5, chapterId.intValue());
            }
            ps.setString(6, action);
            ps.setString(7, changesJson);
            ps.executeUpdate();
        }
    }

    private int getNextHierarchyId(Connection conn, HierarchyMeta meta, Map<String, Integer> parentValues) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COALESCE(MAX(").append(meta.idColumn).append("), 0) + 1 AS next_id FROM ")
                .append(meta.tableName).append(" WHERE 1=1");
        List<Object> params = new ArrayList<>();

        for (String parentCol : meta.parentColumns) {
            sql.append(" AND ").append(parentCol).append("=?");
            params.add(parentValues.get(parentCol));
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindValues(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("next_id");
                }
            }
        }

        return 1;
    }

    private String normalizeContentType(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase(Locale.ENGLISH).replace('-', '_');
    }

    private String decodePathSegment(String segment) {
        if (segment == null) {
            return "";
        }
        try {
            return URLDecoder.decode(segment, StandardCharsets.UTF_8.name());
        } catch (Exception ex) {
            return segment;
        }
    }

    private int[] parseCompositeId(String compositeId, ContentMeta meta) {
        String[] parts = compositeId.split("-");
        if (parts.length != meta.idColumns.size()) {
            throw new IllegalArgumentException("Invalid composite_id for " + meta.type);
        }

        int[] ids = new int[parts.length];
        for (int i = 0; i < parts.length; i++) {
            try {
                ids[i] = Integer.parseInt(parts[i]);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Invalid composite_id");
            }
        }
        return ids;
    }

    private int queryForInt(Connection conn, String sql) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt("total") : 0;
        }
    }

    private boolean isIntegrityConstraintViolation(SQLException ex) {
        SQLException current = ex;
        while (current != null) {
            String sqlState = current.getSQLState();
            int errorCode = current.getErrorCode();
            if ("23000".equals(sqlState) || errorCode == 1451 || errorCode == 1452) {
                return true;
            }
            current = current.getNextException();
        }
        return false;
    }

    private String normalizeHeader(String header) {
        return valueOrFallback(header)
                .trim()
                .toLowerCase(Locale.ENGLISH)
                .replace(" ", "_");
    }

    private String readMappedCell(Row row, Map<String, Integer> headerIndex, String key) {
        Integer index = headerIndex.get(key);
        if (index == null) {
            return "";
        }
        return readExcelCell(row.getCell(index.intValue())).trim();
    }

    private Integer parseRequiredIntCell(Row row, Map<String, Integer> headerIndex, String key) {
        String value = readMappedCell(row, headerIndex, key);
        Integer number = AdminApiUtil.toInteger(value);
        if (number == null) {
            throw new IllegalArgumentException(key + " must be numeric");
        }
        return number;
    }

    private String readExcelCell(Cell cell) {
        if (cell == null) {
            return "";
        }
        if (cell.getCellType() == CellType.FORMULA) {
            return EXCEL_FORMATTER.formatCellValue(cell, cell.getSheet().getWorkbook().getCreationHelper().createFormulaEvaluator());
        }
        return EXCEL_FORMATTER.formatCellValue(cell);
    }

    private String resolveViewerPermissionFlag(JSONObject body, String key) {
        if (body == null) {
            return "0";
        }
        if (body.has(key)) {
            return AdminApiUtil.toFlag(body.opt(key), "0");
        }

        String alias = VIEWER_PERMISSION_ALIASES.get(key);
        if (alias != null && body.has(alias)) {
            return AdminApiUtil.toFlag(body.opt(alias), "0");
        }

        if ("has_next_level".equals(key) && body.has("next_level")) {
            return AdminApiUtil.toFlag(body.opt("next_level"), "0");
        }

        return "0";
    }

    private String getThrowableMessage(Throwable throwable) {
        String message = "";
        Throwable cursor = throwable;
        Set<Throwable> seen = new HashSet<>();
        while (cursor != null && !seen.contains(cursor)) {
            seen.add(cursor);
            String current = valueOrFallback(cursor.getMessage()).trim();
            if (!current.isEmpty()) {
                message = current;
            }
            cursor = cursor.getCause();
        }
        if (message.isEmpty()) {
            return throwable == null ? "Unknown error" : throwable.getClass().getSimpleName();
        }
        return message;
    }

    private JSONArray buildThrowableChain(Throwable throwable) {
        JSONArray chain = new JSONArray();
        Throwable cursor = throwable;
        Set<Throwable> seen = new HashSet<>();
        while (cursor != null && !seen.contains(cursor)) {
            seen.add(cursor);
            JSONObject item = new JSONObject();
            item.put("type", cursor.getClass().getSimpleName());
            String message = valueOrFallback(cursor.getMessage()).trim();
            item.put("message", message.isEmpty() ? cursor.getClass().getName() : message);
            chain.put(item);
            cursor = cursor.getCause();
        }
        return chain;
    }

    private Timestamp parseTimestamp(String value) {
        String raw = valueOrFallback(value).trim();
        if (raw.isEmpty()) {
            return null;
        }

        List<DateTimeFormatter> dateTimeFormatters = Arrays.asList(
                DateTimeFormatter.ISO_LOCAL_DATE_TIME,
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));

        for (DateTimeFormatter formatter : dateTimeFormatters) {
            try {
                LocalDateTime dt = LocalDateTime.parse(raw, formatter);
                return Timestamp.valueOf(dt);
            } catch (DateTimeParseException ignored) {
            }
        }

        try {
            LocalDate date = LocalDate.parse(raw, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            return Timestamp.valueOf(date.atStartOfDay());
        } catch (DateTimeParseException ignored) {
        }

        try {
            return Timestamp.valueOf(raw);
        } catch (Exception ignored) {
        }

        throw new IllegalArgumentException("Invalid date/time format: " + raw);
    }

    private JSONObject mapRow(ResultSet rs) throws SQLException {
        JSONObject obj = new JSONObject();
        ResultSetMetaData meta = rs.getMetaData();
        int columnCount = meta.getColumnCount();
        for (int i = 1; i <= columnCount; i++) {
            String label = meta.getColumnLabel(i);
            Object value = rs.getObject(i);
            if (value instanceof Timestamp) {
                obj.put(label, value == null ? JSONObject.NULL : value.toString());
            } else {
                obj.put(label, value == null ? JSONObject.NULL : value);
            }
        }
        return obj;
    }

    private List<Integer> parseIntList(JSONObject body, HttpServletRequest request, String key) {
        List<Integer> values = new ArrayList<>();

        JSONArray arr = null;
        if (body != null && body.has(key)) {
            arr = AdminApiUtil.toJsonArray(body.opt(key));
        }

        if (arr == null || arr.length() == 0) {
            String[] fromParams = request.getParameterValues(key);
            if (fromParams == null) {
                fromParams = request.getParameterValues(key + "[]");
            }
            if (fromParams != null) {
                for (String item : fromParams) {
                    Integer v = AdminApiUtil.toInteger(item);
                    if (v != null) {
                        values.add(v);
                    }
                }
            }
            return values;
        }

        for (int i = 0; i < arr.length(); i++) {
            Integer v = AdminApiUtil.toInteger(arr.opt(i));
            if (v != null) {
                values.add(v);
            }
        }
        return values;
    }

    private void appendWhereForKeys(StringBuilder sb, List<String> keys) {
        for (int i = 0; i < keys.size(); i++) {
            if (i > 0) {
                sb.append(" AND ");
            }
            sb.append(keys.get(i)).append("=?");
        }
    }

    private void appendPlaceholders(StringBuilder sb, int count) {
        for (int i = 0; i < count; i++) {
            if (i > 0) {
                sb.append(", ");
            }
            sb.append("?");
        }
    }

    private void bindValues(PreparedStatement ps, List<Object> values) throws SQLException {
        for (int i = 0; i < values.size(); i++) {
            Object v = values.get(i);
            int index = i + 1;
            if (v == null) {
                ps.setNull(index, Types.NULL);
            } else if (v instanceof Integer) {
                ps.setInt(index, ((Integer) v).intValue());
            } else if (v instanceof Long) {
                ps.setLong(index, ((Long) v).longValue());
            } else if (v instanceof Timestamp) {
                ps.setTimestamp(index, (Timestamp) v);
            } else {
                ps.setString(index, String.valueOf(v));
            }
        }
    }

    private void bindIntList(PreparedStatement ps, List<Integer> values, int startIndex) throws SQLException {
        int idx = startIndex;
        for (Integer v : values) {
            ps.setInt(idx++, v.intValue());
        }
    }

    private int parseIntOrDefault(String raw, int defaultValue) {
        try {
            return Integer.parseInt(valueOrFallback(raw).trim());
        } catch (Exception ignored) {
            return defaultValue;
        }
    }

    private String valueOrFallback(String value) {
        return value == null ? "" : value;
    }

    private String valueOrNull(String value) {
        String trimmed = valueOrFallback(value).trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static final class UserListQuery {
        private Integer roleId;
        private String accountStatus;
        private Integer universityId;
        private Integer departmentId;
        private Integer classId;
        private String search;
        private int page;
        private int pageSize;

        private static UserListQuery fromRequest(HttpServletRequest request) {
            UserListQuery q = new UserListQuery();
            q.roleId = AdminApiUtil.toInteger(request.getParameter("role_id"));
            q.accountStatus = request.getParameter("account_status");
            q.universityId = AdminApiUtil.toInteger(request.getParameter("university_id"));
            q.departmentId = AdminApiUtil.toInteger(request.getParameter("department_id"));
            q.classId = AdminApiUtil.toInteger(request.getParameter("class_id"));
            q.search = request.getParameter("search");
            q.page = Math.max(1, parseInt(request.getParameter("page"), 1));
            q.pageSize = Math.max(1, Math.min(500, parseInt(request.getParameter("page_size"), 20)));
            return q;
        }

        private static int parseInt(String raw, int fallback) {
            try {
                return Integer.parseInt(raw);
            } catch (Exception ignored) {
                return fallback;
            }
        }
    }

    private static final class UserListResult {
        private final JSONArray items;
        private final int total;

        private UserListResult(JSONArray items, int total) {
            this.items = items;
            this.total = total;
        }
    }

    private enum HierarchyMeta {
        UNIVERSITIES("universities", "university", "university_id", "university_name", Collections.<String>emptyList(), true),
        FACULTIES("faculties", "faculty", "faculty_id", "faculty_name", Arrays.asList("university_id"), true),
        DEPARTMENTS("departments", "department", "department_id", "department_name",
                Arrays.asList("university_id", "faculty_id"), true),
        COURSES("courses", "course", "course_id", "course_name",
                Arrays.asList("university_id", "faculty_id", "department_id"), true),
        SPECIALIZATIONS("specializations", "specialization", "specialization_id", "specialization_name",
                Arrays.asList("university_id", "faculty_id", "department_id", "course_id"), true),
        CLASSES("classes", "class", "class_id", "class_name",
                Arrays.asList("university_id", "faculty_id", "department_id", "course_id", "specialization_id"), false);

        private final String routeLevel;
        private final String tableName;
        private final String idColumn;
        private final String nameColumn;
        private final List<String> parentColumns;
        private final boolean supportsHasNextLevel;

        private HierarchyMeta(String routeLevel, String tableName, String idColumn, String nameColumn,
                List<String> parentColumns, boolean supportsHasNextLevel) {
            this.routeLevel = routeLevel;
            this.tableName = tableName;
            this.idColumn = idColumn;
            this.nameColumn = nameColumn;
            this.parentColumns = parentColumns;
            this.supportsHasNextLevel = supportsHasNextLevel;
        }

        private static HierarchyMeta byRouteLevel(String routeLevel) {
            for (HierarchyMeta meta : values()) {
                if (meta.routeLevel.equals(routeLevel)) {
                    return meta;
                }
            }
            return null;
        }
    }

    private static final class ContentMeta {
        private static final Map<String, ContentMeta> BY_TYPE = new HashMap<>();

        static {
            register(new ContentMeta("chapter", "chapter", Arrays.asList("subject_id", "chapter_id")));
            register(new ContentMeta("topic_level1", "topic_level1",
                    Arrays.asList("subject_id", "chapter_id", "topic_level1_id")));
            register(new ContentMeta("topic_level2", "topic_level2",
                    Arrays.asList("subject_id", "chapter_id", "topic_level1_id", "topic_level2_id")));
            register(new ContentMeta("topic_level3", "topic_level3",
                    Arrays.asList("subject_id", "chapter_id", "topic_level1_id", "topic_level2_id", "topic_level3_id")));
            register(new ContentMeta("topic_level4", "topic_level4",
                    Arrays.asList("subject_id", "chapter_id", "topic_level1_id", "topic_level2_id", "topic_level3_id", "topic_level4_id")));
            register(new ContentMeta("topic_level5", "topic_level5",
                    Arrays.asList("subject_id", "chapter_id", "topic_level1_id", "topic_level2_id", "topic_level3_id", "topic_level4_id", "topic_level5_id")));
        }

        private final String type;
        private final String tableName;
        private final List<String> idColumns;

        private ContentMeta(String type, String tableName, List<String> idColumns) {
            this.type = type;
            this.tableName = tableName;
            this.idColumns = idColumns;
        }

        private static void register(ContentMeta meta) {
            BY_TYPE.put(meta.type, meta);
            BY_TYPE.put(meta.type.replace("_", "-"), meta);
        }

        private static ContentMeta byType(String type) {
            return BY_TYPE.get(type);
        }
    }

    private String fetchSubjectName(int subjectId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT subject_name FROM subject WHERE subject_id=?")) {
            ps.setInt(1, subjectId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String name = rs.getString("subject_name");
                    return name != null ? name.replaceAll("[^a-zA-Z0-9]", "_") : null;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
