import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

public class GetUserProfileAndSubjectsServlet extends HttpServlet {

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

        try (Connection con = DBConnection.getConnection()) {
            // =============================
            // 1️⃣ Fetch Academic Context
            // =============================

            JSONObject academicContext = new JSONObject();

            int universityId = 0, facultyId = 0, departmentId = 0, courseId = 0, specializationId = 0, classId = 0;

            try (CallableStatement academicStmt = con.prepareCall("{CALL get_academic_context (?)}")) {
                academicStmt.setInt(1, userId);
                try (ResultSet rsAcademic = academicStmt.executeQuery()) {
                    if (rsAcademic.next()) {
                        universityId = rsAcademic.getInt("university_id");
                        facultyId = rsAcademic.getInt("faculty_id");
                        departmentId = rsAcademic.getInt("department_id");
                        courseId = rsAcademic.getInt("course_id");
                        specializationId = rsAcademic.getInt("specialization_id");
                        classId = rsAcademic.getInt("class_id");

                        academicContext.put("universityId", universityId);
                        academicContext.put("facultyId", facultyId);
                        academicContext.put("departmentId", departmentId);
                        academicContext.put("courseId", courseId);
                        academicContext.put("specializationId", specializationId);
                        academicContext.put("classId", classId);
                    }
                }
            }

            // =============================
            // 2️⃣ Fetch Subjects
            // =============================
            JSONArray subjectsArray = new JSONArray();
            try (CallableStatement subjectStmt = con.prepareCall("{CALL get_subjects(?, ?, ?, ?, ?, ?)}")) {
                subjectStmt.setInt(1, universityId);
                subjectStmt.setInt(2, facultyId);
                subjectStmt.setInt(3, departmentId);
                subjectStmt.setInt(4, courseId);
                subjectStmt.setInt(5, specializationId);
                subjectStmt.setInt(6, classId);

                try (ResultSet rsSubjects = subjectStmt.executeQuery()) {
                    while (rsSubjects.next()) {
                        JSONObject subject = new JSONObject();
                        subject.put("subject_name", rsSubjects.getString("subject_name"));
                        subject.put("subject_id", rsSubjects.getInt("subject_id"));
                        subjectsArray.put(subject);
                    }
                }
            }

            // =============================
            // 3️⃣ Build Final Response
            // =============================

            responseJson.put("status", "success");
            responseJson.put("username", userName);
            responseJson.put("roleId", roleId);
            responseJson.put("userId", userId);
            responseJson.put("sessionTimeoutSeconds", session.getMaxInactiveInterval());
            responseJson.put("academicContext", academicContext);
            responseJson.put("subjects", subjectsArray);

            response.setStatus(HttpServletResponse.SC_OK);
            out.print(responseJson.toString());

        } catch (Exception ex) {
            responseJson = new JSONObject();
            responseJson.put("status", "error");
            responseJson.put("message", "Database connection error");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(responseJson.toString());
        }
    }
}
