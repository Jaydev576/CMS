import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class FrontControllerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    public static final String ROUTE_PARAMS_ATTR = "wls.routeParams";
    public static final String ROUTE_MATCHED_PATH_ATTR = "wls.routeMatchedPath";

    // Route -> Servlet mapping loaded from DB
    private Map<String, String> routeMap;
    private List<ParameterizedRoute> parameterizedRoutes;

    private static final class ParameterizedRoute {
        private final String routePath;
        private final String servletName;
        private final Pattern regex;
        private final List<String> paramNames;

        private ParameterizedRoute(String routePath, String servletName, Pattern regex, List<String> paramNames) {
            this.routePath = routePath;
            this.servletName = servletName;
            this.regex = regex;
            this.paramNames = paramNames;
        }
    }

    @Override
    public void init() throws ServletException {
        super.init();

        routeMap = new HashMap<>();
        parameterizedRoutes = new ArrayList<>();

        System.out.println("FrontController: Loading API routes from database...");

        loadRoutesFromDB();

        System.out.println("FrontController: Loaded " + routeMap.size() + " routes.");
    }

    private void loadRoutesFromDB() {
        routeMap.clear();
        parameterizedRoutes.clear();
        try (Connection conn = DBConnection.getConnection();
             CallableStatement cs = conn.prepareCall("{CALL get_active_api_routes()}");
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {

                String routePath = rs.getString("route_path");
                String servletName = rs.getString("servlet_name");

                if (isParameterizedRoute(routePath)) {
                    parameterizedRoutes.add(buildParameterizedRoute(routePath, servletName));
                } else {
                    routeMap.put(routePath, servletName);
                }

                System.out.println("Route loaded: " + routePath + " -> " + servletName);
            }

        } catch (Exception e) {
            System.err.println("FrontController: Failed to load routes from DB");
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pathInfo = request.getPathInfo();

        System.out.println("FrontController PathInfo: " + pathInfo);

        if (pathInfo == null || pathInfo.equals("/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid API Endpoint");
            return;
        }

        request.removeAttribute(ROUTE_PARAMS_ATTR);
        request.removeAttribute(ROUTE_MATCHED_PATH_ATTR);

        // Lookup servlet name from route map
        String targetServletName = routeMap.get(pathInfo);

        if (targetServletName == null) {
            for (ParameterizedRoute route : parameterizedRoutes) {
                Matcher matcher = route.regex.matcher(pathInfo);
                if (!matcher.matches()) {
                    continue;
                }

                Map<String, String> params = new LinkedHashMap<>();
                for (int i = 0; i < route.paramNames.size(); i++) {
                    params.put(route.paramNames.get(i), matcher.group(i + 1));
                }

                request.setAttribute(ROUTE_PARAMS_ATTR, params);
                request.setAttribute(ROUTE_MATCHED_PATH_ATTR, route.routePath);
                targetServletName = route.servletName;
                break;
            }
        }

        if (targetServletName != null) {

            RequestDispatcher dispatcher = getServletContext().getNamedDispatcher(targetServletName);

            if (dispatcher != null) {

                System.out.println("Dispatching to: " + targetServletName);

                dispatcher.forward(request, response);

            } else {

                System.err.println("Target servlet not found: " + targetServletName);

                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Servlet not found");
            }

        } else {

            System.err.println("Route not found: " + pathInfo);

            response.sendError(HttpServletResponse.SC_NOT_FOUND, "API Endpoint not found");
        }
    }

    private boolean isParameterizedRoute(String routePath) {
        if (routePath == null) {
            return false;
        }
        return routePath.contains(":") || routePath.contains("{");
    }

    private ParameterizedRoute buildParameterizedRoute(String routePath, String servletName) {
        String[] parts = routePath.split("/");
        StringBuilder patternBuilder = new StringBuilder("^");
        List<String> paramNames = new ArrayList<>();

        for (String part : parts) {
            if (part == null || part.isEmpty()) {
                continue;
            }
            patternBuilder.append("/");

            String paramName = extractParamName(part);
            if (paramName != null && !paramName.isEmpty()) {
                paramNames.add(paramName);
                patternBuilder.append("([^/]+)");
            } else {
                patternBuilder.append(Pattern.quote(part));
            }
        }

        patternBuilder.append("$");
        Pattern regex = Pattern.compile(patternBuilder.toString());
        return new ParameterizedRoute(routePath, servletName, regex, Collections.unmodifiableList(paramNames));
    }

    private String extractParamName(String part) {
        if (part.startsWith(":")) {
            return part.substring(1).trim();
        }
        if (part.startsWith("{") && part.endsWith("}") && part.length() > 2) {
            return part.substring(1, part.length() - 1).trim();
        }
        return null;
    }
}
