import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public final class DBConnection {
    private DBConnection() {
    }

    private static final Properties PROPERTIES = loadPropertiesSafely();

    private static final class DataSourceHolder {
        private static final HikariDataSource INSTANCE = createDataSource();
    }

    public static Connection getConnection() throws SQLException {
        return DataSourceHolder.INSTANCE.getConnection();
    }

    public static void shutdown() {
        HikariDataSource dataSource = DataSourceHolder.INSTANCE;
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
        }
    }

    private static HikariDataSource createDataSource() {
        String driverClass = getConfig("ClassName", "WLS_DB_DRIVER", "com.mysql.cj.jdbc.Driver");
        String username = getConfig("Username", "WLS_DB_USERNAME", "root");
        String password = getConfig("Password", "WLS_DB_PASSWORD", "password");

        String dbUrl = System.getenv("WLS_DB_URL"); 
        if (dbUrl == null || dbUrl.trim().isEmpty()) {
            String connectionPrefix = getConfig("Connection", "WLS_DB_CONNECTION", "jdbc:mysql");
            String host = getConfig("Host", "WLS_DB_HOST", "localhost");
            String port = getConfig("Port", "WLS_DB_PORT", "3306");
            String database = getConfig("Database", "WLS_DB_NAME", "wls");
            String encoding = getConfig(
                    "encoding",
                    "WLS_DB_ENCODING",
                    "?useUnicode=true&characterEncoding=UTF-8&useSSL=false");
            dbUrl = connectionPrefix + "://" + host + ":" + port + "/" + database + encoding;
        }

        HikariConfig config = new HikariConfig();
        config.setDriverClassName(driverClass);
        config.setJdbcUrl(dbUrl);
        config.setUsername(username);
        config.setPassword(password);

        config.setPoolName(getConfig("PoolName", "WLS_DB_POOL_NAME", "WLSHikariPool"));
        int maxPoolSize = Math.max(10, getIntConfig("PoolMaxSize", "WLS_DB_POOL_MAX_SIZE", 120));
        int minIdle = Math.max(0, getIntConfig("PoolMinIdle", "WLS_DB_POOL_MIN_IDLE", 30));
        if (minIdle > maxPoolSize) {
            minIdle = maxPoolSize;
        }
        config.setMaximumPoolSize(maxPoolSize);
        config.setMinimumIdle(minIdle);

        long connectionTimeoutMs = Math.max(1000L,
                getLongConfig("PoolConnectionTimeoutMs", "WLS_DB_POOL_CONNECTION_TIMEOUT_MS", 3000L));
        long validationTimeoutMs = Math.max(1000L,
                getLongConfig("PoolValidationTimeoutMs", "WLS_DB_POOL_VALIDATION_TIMEOUT_MS", 1500L));
        long maxLifetimeMs = Math.max(30000L,
                getLongConfig("PoolMaxLifetimeMs", "WLS_DB_POOL_MAX_LIFETIME_MS", 1740000L));
        long idleTimeoutMs = Math.max(10000L,
                getLongConfig("PoolIdleTimeoutMs", "WLS_DB_POOL_IDLE_TIMEOUT_MS", 600000L));
        if (idleTimeoutMs >= maxLifetimeMs) {
            idleTimeoutMs = Math.max(10000L, maxLifetimeMs - 10000L);
        }
        long keepaliveMs = Math.max(0L, getLongConfig("PoolKeepaliveMs", "WLS_DB_POOL_KEEPALIVE_MS", 120000L));
        if (keepaliveMs > 0L && keepaliveMs >= maxLifetimeMs) {
            keepaliveMs = Math.max(30000L, maxLifetimeMs / 2L);
        }

        config.setConnectionTimeout(connectionTimeoutMs);
        config.setValidationTimeout(validationTimeoutMs);
        config.setIdleTimeout(idleTimeoutMs);
        config.setMaxLifetime(maxLifetimeMs);
        config.setTransactionIsolation(getConfig(
                "PoolTransactionIsolation",
                "WLS_DB_POOL_TRANSACTION_ISOLATION",
                "TRANSACTION_READ_COMMITTED"));
        if (keepaliveMs > 0L) {
            config.setKeepaliveTime(keepaliveMs);
        }
        config.setInitializationFailTimeout(getLongConfig("PoolInitFailTimeoutMs", "WLS_DB_POOL_INIT_FAIL_TIMEOUT_MS", 1L));

        long leakDetectionMs = getLongConfig("PoolLeakDetectionMs", "WLS_DB_POOL_LEAK_DETECTION_MS", 0L);
        if (leakDetectionMs > 0L) {
            config.setLeakDetectionThreshold(leakDetectionMs);
        }

        config.setAutoCommit(true);
        config.setConnectionTestQuery(getConfig("PoolConnectionTestQuery", "WLS_DB_POOL_TEST_QUERY", "SELECT 1"));

        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", getConfig("PrepStmtCacheSize", "WLS_DB_PREPSTMT_CACHE_SIZE", "500"));
        config.addDataSourceProperty("prepStmtCacheSqlLimit", getConfig("PrepStmtCacheSqlLimit", "WLS_DB_PREPSTMT_CACHE_SQL_LIMIT", "2048"));
        config.addDataSourceProperty("useServerPrepStmts", "true");
        config.addDataSourceProperty("rewriteBatchedStatements", "true");
        config.addDataSourceProperty("cacheResultSetMetadata", "true");
        config.addDataSourceProperty("cacheServerConfiguration", "true");
        config.addDataSourceProperty("elideSetAutoCommits", "true");
        config.addDataSourceProperty("maintainTimeStats", "false");
        config.addDataSourceProperty("tcpKeepAlive", "true");
        config.addDataSourceProperty("connectTimeout", getConfig("DbConnectTimeoutMs", "WLS_DB_CONNECT_TIMEOUT_MS", "5000"));
        config.addDataSourceProperty("socketTimeout", getConfig("DbSocketTimeoutMs", "WLS_DB_SOCKET_TIMEOUT_MS", "30000"));

        return new HikariDataSource(config);
    }

    private static Properties loadPropertiesSafely() {
        Properties prop = new Properties();
        try (InputStream in = Thread.currentThread()
                .getContextClassLoader()
                .getResourceAsStream("wls_db_config.properties")) {
            if (in != null) {
                prop.load(in);
            }
        } catch (Exception ignored) {
            // Environment variables still allow full configuration when properties are unavailable.
        }
        return prop;
    }

    private static String getConfig(String key, String envName, String defaultValue) {
        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.trim().isEmpty()) {
            return envValue;
        }

        String propertyValue = PROPERTIES.getProperty(key);
        if (propertyValue != null && !propertyValue.trim().isEmpty()) {
            return propertyValue;
        }

        return defaultValue;
    }

    private static int getIntConfig(String key, String envName, int defaultValue) {
        String raw = getConfig(key, envName, Integer.toString(defaultValue));
        try {
            return Integer.parseInt(raw.trim());
        } catch (Exception ignored) {
            return defaultValue;
        }
    }

    private static long getLongConfig(String key, String envName, long defaultValue) {
        String raw = getConfig(key, envName, Long.toString(defaultValue));
        try {
            return Long.parseLong(raw.trim());
        } catch (Exception ignored) {
            return defaultValue;
        }
    }
}
