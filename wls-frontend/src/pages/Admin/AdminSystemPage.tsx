import { useEffect, useState } from "react";
import { fetchActivity } from "../../api/admin";

function toCsv(rows: Array<Record<string, unknown>>) {
  if (rows.length === 0) {
    return "";
  }

  const headers = ["username", "role_name", "last_login_at", "account_status"];
  const lines = [headers.join(",")];

  rows.forEach((row) => {
    const values = headers.map((header) => {
      const value = String(row[header] ?? "");
      return `"${value.replaceAll('"', '""')}"`;
    });
    lines.push(values.join(","));
  });

  return lines.join("\n");
}

function downloadText(filename: string, content: string) {
  const blob = new Blob([content], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

export default function AdminSystemPage() {
  const [activity, setActivity] = useState<Array<Record<string, unknown>>>([]);
  const [dateFrom, setDateFrom] = useState("");
  const [dateTo, setDateTo] = useState("");
  const [userId, setUserId] = useState("");
  const [toast, setToast] = useState<{ type: "error" | "success"; message: string } | null>(null);

  const loadActivity = async () => {
    try {
      const result = await fetchActivity({
        page: 1,
        page_size: 100,
        date_from: dateFrom || undefined,
        date_to: dateTo || undefined,
        user_id: userId ? Number(userId) : undefined,
      });
      setActivity(result.items);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to load activity" });
    }
  };

  useEffect(() => {
    void loadActivity();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div>
      <div className="admin-topbar">
        <h2>System & Audit</h2>
      </div>

      {toast && <div className={`admin-toast ${toast.type}`}>{toast.message}</div>}

      <section className="admin-panel">
        <h3>Login & Activity Log</h3>
        <div className="admin-row">
          <label>
            Date From
            <input type="date" value={dateFrom} onChange={(e) => setDateFrom(e.target.value)} />
          </label>
          <label>
            Date To
            <input type="date" value={dateTo} onChange={(e) => setDateTo(e.target.value)} />
          </label>
          <label>
            User ID
            <input value={userId} onChange={(e) => setUserId(e.target.value)} />
          </label>
          <button type="button" className="admin-btn" onClick={loadActivity}>
            Apply
          </button>
          <button
            type="button"
            className="admin-btn secondary"
            onClick={() => downloadText("activity_log.csv", toCsv(activity))}
          >
            Export CSV
          </button>
        </div>

        <div className="admin-table-wrap" style={{ marginTop: "0.8rem" }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>Username</th>
                <th>Role</th>
                <th>Last Login</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {activity.length === 0 && (
                <tr>
                  <td colSpan={4}>No activity rows</td>
                </tr>
              )}
              {activity.map((row, idx) => (
                <tr key={`${String(row.user_id ?? idx)}`}>
                  <td>{String(row.username ?? "-")}</td>
                  <td>{String(row.role_name ?? "-")}</td>
                  <td>{String(row.last_login_at ?? "-")}</td>
                  <td>
                    <span className={`admin-status ${String(row.account_status ?? "").toLowerCase()}`}>
                      {String(row.account_status ?? "-")}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
