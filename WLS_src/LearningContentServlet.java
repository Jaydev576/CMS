import java.io.BufferedReader;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet(name = "LearningContentServlet", urlPatterns = { "/api/LearningContentServlet" })
public class LearningContentServlet extends HttpServlet {

    private static final Set<String> ALLOWED_TYPES = new HashSet<>(
            Arrays.asList("AUDIO", "VIDEO", "SIMULATION", "PROGRAM", "IMAGE"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject responseJson = new JSONObject();
        HttpSession session = request.getSession(false);

        if (!isSessionValid(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            responseJson.put("status", "unauthorized");
            responseJson.put("message", "Login required");
            response.getWriter().print(responseJson.toString());
            return;
        }

        try (Connection con = DBConnection.getConnection();
                CallableStatement cs = con.prepareCall("{CALL get_learning_content()}");
                ResultSet rs = cs.executeQuery()) {

            JSONArray items = new JSONArray();
            while (rs.next()) {
                JSONObject item = new JSONObject();
                item.put("id", rs.getInt("id"));
                item.put("title", rs.getString("title"));
                item.put("contentType", rs.getString("content_type"));
                item.put("resourceUrl", rs.getString("resource_url"));
                item.put("createdBy", rs.getObject("created_by"));
                item.put("createdAt", rs.getTimestamp("created_at") != null
                        ? rs.getTimestamp("created_at").toString()
                        : JSONObject.NULL);
                items.put(item);
            }

            responseJson.put("status", "success");
            responseJson.put("items", items);
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception ex) {
            ex.printStackTrace();
            responseJson.put("status", "error");
            responseJson.put("message", "Failed to fetch learning content");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        response.getWriter().print(responseJson.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JSONObject responseJson = new JSONObject();
        HttpSession session = request.getSession(false);

        if (!isSessionValid(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            responseJson.put("status", "unauthorized");
            responseJson.put("message", "Login required");
            response.getWriter().print(responseJson.toString());
            return;
        }

        JSONObject payload;
        try {
            payload = readPayload(request);
        } catch (Exception parseError) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            responseJson.put("status", "error");
            responseJson.put("message", "Invalid request payload");
            response.getWriter().print(responseJson.toString());
            return;
        }

        String title = payload.optString("title", "").trim();
        String contentType = payload.optString("contentType", "").trim().toUpperCase();
        String resourceUrl = payload.optString("resourceUrl", "").trim();

        if (title.isEmpty() || resourceUrl.isEmpty() || !ALLOWED_TYPES.contains(contentType)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            responseJson.put("status", "error");
            responseJson.put("message", "title, contentType, and resourceUrl are required");
            response.getWriter().print(responseJson.toString());
            return;
        }

        Integer userId = getUserId(session);

        try (Connection con = DBConnection.getConnection();
                CallableStatement cs = con.prepareCall("{CALL add_learning_content(?, ?, ?, ?)}")) {

            cs.setString(1, title);
            cs.setString(2, contentType);
            cs.setString(3, resourceUrl);

            if (userId != null) {
                cs.setInt(4, userId.intValue());
            } else {
                cs.setNull(4, java.sql.Types.INTEGER);
            }

            int insertedId = 0;
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    insertedId = rs.getInt("inserted_id");
                }
            }

            responseJson.put("status", "success");
            responseJson.put("id", insertedId);
            responseJson.put("message", "Content saved");
            response.setStatus(HttpServletResponse.SC_CREATED);

        } catch (Exception ex) {
            ex.printStackTrace();
            responseJson.put("status", "error");
            responseJson.put("message", "Failed to save learning content");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }

        response.getWriter().print(responseJson.toString());
    }

    private boolean isSessionValid(HttpSession session) {
        return session != null && session.getAttribute("userId") != null;
    }

    private Integer getUserId(HttpSession session) {
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
        return null;
    }

    private JSONObject readPayload(HttpServletRequest request) throws IOException {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }

        if (body.length() > 0) {
            return new JSONObject(body.toString());
        }

        JSONObject fromParams = new JSONObject();
        if (request.getParameter("title") != null) {
            fromParams.put("title", request.getParameter("title"));
        }
        if (request.getParameter("contentType") != null) {
            fromParams.put("contentType", request.getParameter("contentType"));
        }
        if (request.getParameter("resourceUrl") != null) {
            fromParams.put("resourceUrl", request.getParameter("resourceUrl"));
        }
        return fromParams;
    }
}
