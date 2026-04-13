import { useEffect, useMemo, useState } from "react";
import { fetchAdminDashboard } from "../../api/admin";

interface RoleCount {
  role_id: number;
  total: number;
}

export default function AdminDashboardPage() {
  const [data, setData] = useState<Record<string, unknown> | null>(null);
  const [error, setError] = useState<string>("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetchAdminDashboard()
      .then((result) => {
        setData(result);
        setError("");
      })
      .catch((err: unknown) => {
        setError(err instanceof Error ? err.message : "Failed to load dashboard");
      })
      .finally(() => setLoading(false));
  }, []);

  const roleCounts = useMemo(() => {
    const list = (data?.total_users_by_role as RoleCount[] | undefined) ?? [];
    const total = list.reduce((sum, item) => sum + Number(item.total ?? 0), 0);
    return { list, total };
  }, [data]);

  if (loading) {
    return <div className="admin-panel">Loading dashboard...</div>;
  }

  return (
    <div>
      <div className="admin-topbar">
        <h2>Admin Dashboard</h2>
      </div>

      {error && <div className="admin-toast error">{error}</div>}

      <section className="admin-card-grid">
        <div className="admin-card">
          <h4>Active Users Today</h4>
          <div className="metric">{Number(data?.active_users_today ?? 0)}</div>
        </div>
        <div className="admin-card">
          <h4>Locked Accounts</h4>
          <div className="metric">{Number(data?.locked_accounts ?? 0)}</div>
        </div>
        <div className="admin-card">
          <h4>Draft Content</h4>
          <div className="metric">{Number(data?.content_draft_count ?? 0)}</div>
        </div>
        <div className="admin-card">
          <h4>Published Content</h4>
          <div className="metric">{Number(data?.content_published_count ?? 0)}</div>
        </div>
        <div className="admin-card">
          <h4>Total Subjects</h4>
          <div className="metric">{Number(data?.total_subjects ?? 0)}</div>
        </div>
        <div className="admin-card">
          <h4>Total Chapters</h4>
          <div className="metric">{Number(data?.total_chapters ?? 0)}</div>
        </div>
        <div className="admin-card">
          <h4>Enrollments Expiring (30 days)</h4>
          <div className="metric">{Number(data?.enrollments_expiring_soon ?? 0)}</div>
        </div>
      </section>

      <section className="admin-panel">
        <h3>User Distribution</h3>
        {roleCounts.list.length === 0 && <p>No role data available.</p>}
        {roleCounts.list.map((role) => {
          const pct = roleCounts.total > 0 ? Math.round((Number(role.total) / roleCounts.total) * 100) : 0;
          return (
            <div key={role.role_id} style={{ marginBottom: "0.7rem" }}>
              <div className="admin-row" style={{ justifyContent: "space-between" }}>
                <strong>Role {role.role_id}</strong>
                <span>
                  {role.total} ({pct}%)
                </span>
              </div>
              <div style={{ background: "#e5ebf5", borderRadius: 999, height: 10, overflow: "hidden" }}>
                <div
                  style={{
                    width: `${pct}%`,
                    height: "100%",
                    background: "linear-gradient(90deg, #1f4c8f, #3f78c6)",
                  }}
                />
              </div>
            </div>
          );
        })}
      </section>
    </div>
  );
}
