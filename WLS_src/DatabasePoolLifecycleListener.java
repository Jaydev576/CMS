import java.sql.Connection;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class DatabasePoolLifecycleListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try (Connection ignored = DBConnection.getConnection()) {
            sce.getServletContext().log("HikariCP pool initialized.");
        } catch (Exception e) {
            throw new IllegalStateException("Failed to initialize HikariCP pool", e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBConnection.shutdown();
        sce.getServletContext().log("HikariCP pool shut down.");
    }
}
