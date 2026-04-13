import java.io.BufferedReader;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.JSONArray;
import org.json.JSONObject;

public final class AdminApiUtil {
    private AdminApiUtil() {
    }

    public static Integer requireAdminUserId(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return null;
        }

        Integer roleId = toInteger(session.getAttribute("roleId"));
        Integer userId = toInteger(session.getAttribute("userId"));
        if (roleId == null || roleId.intValue() != 1 || userId == null) {
            writeError(response, HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return null;
        }
        return userId;
    }

    public static JSONObject readJsonBody(HttpServletRequest request) throws IOException {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }

        if (body.length() == 0) {
            return new JSONObject();
        }

        return new JSONObject(body.toString());
    }

    @SuppressWarnings("unchecked")
    public static Map<String, String> getRouteParams(HttpServletRequest request) {
        Object attr = request.getAttribute(FrontControllerServlet.ROUTE_PARAMS_ATTR);
        if (!(attr instanceof Map)) {
            return Collections.emptyMap();
        }
        return (Map<String, String>) attr;
    }

    public static String getRouteParam(HttpServletRequest request, String key) {
        return getRouteParams(request).get(key);
    }

    public static String getMatchedRoute(HttpServletRequest request) {
        Object attr = request.getAttribute(FrontControllerServlet.ROUTE_MATCHED_PATH_ATTR);
        if (attr instanceof String) {
            return (String) attr;
        }
        return request.getPathInfo();
    }

    public static Integer toInteger(Object value) {
        if (value == null || value == JSONObject.NULL) {
            return null;
        }
        if (value instanceof Number) {
            return Integer.valueOf(((Number) value).intValue());
        }
        try {
            String raw = String.valueOf(value).trim();
            if (raw.isEmpty()) {
                return null;
            }
            return Integer.valueOf(Integer.parseInt(raw));
        } catch (Exception ignored) {
            return null;
        }
    }

    public static Long toLong(Object value) {
        if (value == null || value == JSONObject.NULL) {
            return null;
        }
        if (value instanceof Number) {
            return Long.valueOf(((Number) value).longValue());
        }
        try {
            String raw = String.valueOf(value).trim();
            if (raw.isEmpty()) {
                return null;
            }
            return Long.valueOf(Long.parseLong(raw));
        } catch (Exception ignored) {
            return null;
        }
    }

    public static Boolean toBoolean(Object value) {
        if (value == null || value == JSONObject.NULL) {
            return null;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        String raw = String.valueOf(value).trim();
        if (raw.isEmpty()) {
            return null;
        }
        if ("1".equals(raw) || "true".equalsIgnoreCase(raw) || "yes".equalsIgnoreCase(raw) || "y".equalsIgnoreCase(raw)) {
            return Boolean.TRUE;
        }
        if ("0".equals(raw) || "false".equalsIgnoreCase(raw) || "no".equalsIgnoreCase(raw) || "n".equalsIgnoreCase(raw)) {
            return Boolean.FALSE;
        }
        return null;
    }

    public static String toFlag(Object value, String defaultFlag) {
        Boolean bool = toBoolean(value);
        if (bool == null) {
            return defaultFlag;
        }
        return bool.booleanValue() ? "1" : "0";
    }

    public static JSONArray toJsonArray(Object value) {
        if (value == null || value == JSONObject.NULL) {
            return new JSONArray();
        }
        if (value instanceof JSONArray) {
            return (JSONArray) value;
        }
        if (value instanceof String) {
            String raw = ((String) value).trim();
            if (raw.isEmpty()) {
                return new JSONArray();
            }
            return new JSONArray(raw);
        }
        return new JSONArray();
    }

    public static String getString(JSONObject body, HttpServletRequest request, String key) {
        if (body != null && body.has(key) && body.opt(key) != null && body.opt(key) != JSONObject.NULL) {
            return body.optString(key, null);
        }
        return request.getParameter(key);
    }

    public static Integer getInt(JSONObject body, HttpServletRequest request, String key) {
        if (body != null && body.has(key)) {
            return toInteger(body.opt(key));
        }
        return toInteger(request.getParameter(key));
    }

    public static void writeSuccess(HttpServletResponse response, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);
        JSONObject payload = new JSONObject();
        payload.put("success", true);
        payload.put("data", data == null ? JSONObject.NULL : data);
        response.getWriter().print(payload.toString());
    }

    public static void writeError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        JSONObject payload = new JSONObject();
        payload.put("success", false);
        payload.put("message", message == null ? "Request failed" : message);
        response.getWriter().print(payload.toString());
    }
}
