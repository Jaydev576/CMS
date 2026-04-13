import { useEffect, useState } from "react";
import {
  downloadBlob,
  exportPrivilegeAuditAll,
  exportPrivileges,
  fetchHierarchyLevel,
  fetchPrivilegeAudit,
  fetchPrivilegeOverview,
  updatePrivilege,
} from "../../api/admin";

const viewerPermissions = [
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
  "remarks_permission",
] as const;

const developerPermissions = [
  "has_next_level",
  "read_permission",
  "write_permission",
  "edit_permission",
  "review_permission",
] as const;

const viewerPermissionAliases: Record<string, string> = {
  read_permission: "read",
  audio_permission: "audio",
  video_permission: "video",
  animation_permission: "animation",
  program_permission: "program",
  chat_permission: "chat",
  forum_permission: "forum",
  simulation_permission: "simulation",
  assignment_permission: "assignment",
  test_permission: "test",
  marks_review_permission: "marks_review",
  remarks_permission: "remarks",
};

function flagToBool(value: unknown): boolean {
  if (value === true || value === 1 || value === "1") {
    return true;
  }
  return false;
}

function formatPermissionLabel(permission: string): string {
  return permission
    .replace(/_permission$/, "")
    .replaceAll("_", " ")
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

export default function AdminPrivilegesPage() {
  const [subjectId, setSubjectId] = useState("");
  const [subjects, setSubjects] = useState<Array<{ id: number; name: string }>>([]);
  const [roleId, setRoleId] = useState<2 | 3>(3);
  const [rows, setRows] = useState<Array<Record<string, unknown>>>([]);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: "error" | "success"; message: string } | null>(null);

  const [auditRows, setAuditRows] = useState<Array<Record<string, unknown>>>([]);
  const [showAudit, setShowAudit] = useState(false);
  const [exportingMatrix, setExportingMatrix] = useState(false);
  const [exportingAudit, setExportingAudit] = useState(false);

  const permissions = roleId === 3 ? viewerPermissions : developerPermissions;

  useEffect(() => {
    void fetchHierarchyLevel("subjects")
      .then((result) => {
        const mapped = result.items.map((item) => ({
          id: Number(item.subject_id),
          name: String(item.subject_name ?? item.subject_id),
        }));
        setSubjects(mapped);
      })
      .catch(() => setSubjects([]));
  }, []);

  const load = async () => {
    const numericSubject = Number(subjectId);
    if (!Number.isFinite(numericSubject) || numericSubject <= 0) {
      setToast({ type: "error", message: "Enter valid subject_id" });
      return;
    }

    setLoading(true);
    try {
      const result = await fetchPrivilegeOverview(numericSubject, roleId);
      setRows(result.items);
      setToast(null);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to fetch privileges" });
    } finally {
      setLoading(false);
    }
  };

  const updateCell = (row: Record<string, unknown>, key: string, checked: boolean) => {
    setRows((prev) =>
      prev.map((item) =>
        Number(item.user_id) === Number(row.user_id)
          ? {
              ...item,
              [key]: checked ? "1" : "0",
            }
          : item,
      ),
    );
  };

  const buildPrivilegePayload = (row: Record<string, unknown>) => {
    const numericSubject = Number(subjectId);
    if (!Number.isFinite(numericSubject) || numericSubject <= 0) {
      return null;
    }

    const payload: Record<string, unknown> = {
      user_id: Number(row.user_id),
      subject_id: numericSubject,
    };

    permissions.forEach((perm) => {
      const enabled = flagToBool(row[perm]);
      payload[perm] = enabled;

      if (roleId === 3) {
        const alias = viewerPermissionAliases[perm];
        if (alias) {
          payload[alias] = enabled;
        }
      }
    });

    return payload;
  };

  const grantRow = async (row: Record<string, unknown>) => {
    const payload = buildPrivilegePayload(row);
    if (!payload) {
      setToast({ type: "error", message: "Enter valid subject_id" });
      return;
    }

    try {
      if (roleId === 3) {
        await updatePrivilege("privileges/viewer/subject", payload);
      } else {
        await updatePrivilege("privileges/developer/subject", payload);
      }

      setToast({ type: "success", message: `Privilege granted for user #${Number(row.user_id)}` });
      await load();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Grant failed" });
    }
  };



  const loadAudit = async () => {
    try {
      const result = await fetchPrivilegeAudit({
        page: 1,
        page_size: 50,
        subject_id: Number(subjectId) || undefined,
      });
      setAuditRows(result.items);
      setShowAudit(true);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Audit fetch failed" });
    }
  };

  const onExportMatrix = async () => {
    const numericSubject = Number(subjectId);
    if (!Number.isFinite(numericSubject) || numericSubject <= 0) {
      setToast({ type: "error", message: "Select a subject first to export the matrix" });
      return;
    }

    setExportingMatrix(true);
    try {
      const subjectLabel = subjects.find(s => String(s.id) === String(subjectId))?.name.replace(/[^a-z0-9]/gi, "_") || subjectId;
      const roleLabel = roleId === 2 ? "Teacher" : "Student";
      
      const blob = await exportPrivileges(numericSubject, roleId);
      downloadBlob(blob, `privileges_matrix_${subjectLabel}_${roleLabel}.xlsx`);
      setToast({ type: "success", message: "Matrix exported successfully" });
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Matrix export failed" });
    } finally {
      setExportingMatrix(false);
    }
  };

  const onExportAllAuditLogs = async () => {
    setExportingAudit(true);
    try {
      const blob = await exportPrivilegeAuditAll();
      downloadBlob(blob, "privilege_audit_all.xlsx");
      setToast({ type: "success", message: "All audit logs exported successfully" });
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Audit export failed" });
    } finally {
      setExportingAudit(false);
    }
  };

  const onExportSubjectAuditLogs = async () => {
    const numericSubject = Number(subjectId);
    if (!Number.isFinite(numericSubject) || numericSubject <= 0) {
      setToast({ type: "error", message: "Select a subject first" });
      return;
    }

    setExportingAudit(true);
    try {
      const subjectLabel = subjects.find(s => String(s.id) === String(subjectId))?.name.replace(/[^a-z0-9]/gi, "_") || subjectId;
      const blob = await exportPrivilegeAuditAll(numericSubject);
      downloadBlob(blob, `privilege_audit_subject_${subjectLabel}.xlsx`);
      setToast({ type: "success", message: "Subject audit logs exported successfully" });
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Audit export failed" });
    } finally {
      setExportingAudit(false);
    }
  };

  return (
    <div>
      <div className="admin-topbar">
        <h2>Privilege Matrix</h2>
        <div className="admin-row">
          <button type="button" className="admin-btn secondary" onClick={loadAudit}>
            Audit Log
          </button>
          <button
            type="button"
            className="admin-btn secondary"
            onClick={onExportAllAuditLogs}
            disabled={exportingAudit}
            title="Export complete privilege audit history (all subjects)"
          >
            {exportingAudit ? "Exporting…" : "⬇ Export All Logs"}
          </button>
          <button
            type="button"
            className="admin-btn secondary"
            onClick={onExportSubjectAuditLogs}
            disabled={exportingAudit || !subjectId}
            title={!subjectId ? "Select a subject first" : "Export audit history for the selected subject"}
          >
            {exportingAudit ? "Exporting…" : "⬇ Export Subject Logs"}
          </button>
          <button
            type="button"
            className="admin-btn"
            onClick={onExportMatrix}
            disabled={exportingMatrix || !subjectId}
            title={!subjectId ? "Select a subject first" : "Export current privilege matrix (checkmarks) to Excel"}
          >
            {exportingMatrix ? "Exporting…" : "⬇ Export Matrix"}
          </button>
        </div>
      </div>

      {toast && <div className={`admin-toast ${toast.type}`}>{toast.message}</div>}

      <section className="admin-panel">
        <div className="admin-row" style={{ alignItems: "flex-end" }}>
          <label style={{ flex: "0 1 260px" }}>
            Subject
            <select value={subjectId} onChange={(e) => setSubjectId(e.target.value)}>
              <option value="">Select Subject</option>
              {subjects.map((subject) => (
                <option key={subject.id} value={subject.id}>
                  {subject.name} (#{subject.id})
                </option>
              ))}
            </select>
          </label>

          <label style={{ flex: "0 1 240px" }}>
            Role
            <select value={roleId} onChange={(e) => setRoleId(Number(e.target.value) as 2 | 3)}>
              <option value={3}>Student</option>
              <option value={2}>Teacher</option>
            </select>
          </label>

          <button type="button" className="admin-btn" onClick={load}>
            Load Matrix
          </button>
        </div>
      </section>



      <section className="admin-panel">
        <div className="admin-table-wrap">
          <table className="admin-table admin-table-privileges">
            <thead>
              <tr>
                <th>User</th>
                {permissions.map((perm) => (
                  <th key={perm}>
                    <span className="admin-perm-header" title={perm}>
                      {formatPermissionLabel(perm)}
                    </span>
                  </th>
                ))}
                <th>Active</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={permissions.length + 3}>Loading...</td>
                </tr>
              )}
              {!loading && rows.length === 0 && (
                <tr>
                  <td colSpan={permissions.length + 3}>No users in matrix</td>
                </tr>
              )}
              {!loading &&
                rows.map((row) => (
                  <tr key={Number(row.user_id)}>
                    <td>
                      {String(row.username ?? "")} ({String(row.user_id ?? "")})
                    </td>
                    {permissions.map((perm) => (
                      <td key={`${Number(row.user_id)}-${perm}`}>
                        <input
                          type="checkbox"
                          checked={flagToBool(row[perm])}
                          onChange={(e) => updateCell(row, perm, e.target.checked)}
                        />
                      </td>
                    ))}
                    <td>{flagToBool(row.is_active) ? "Yes" : "No"}</td>
                    <td>
                      <div className="admin-row">
                        <button type="button" className="admin-btn secondary" onClick={() => grantRow(row)}>
                          Grant
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </section>

      {showAudit && (
        <section className="admin-panel">
          <div className="admin-row" style={{ justifyContent: "space-between" }}>
            <h3>Privilege Audit Log</h3>
            <button type="button" className="admin-btn secondary" onClick={() => setShowAudit(false)}>
              Hide
            </button>
          </div>
          <div className="admin-table-wrap">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Admin</th>
                  <th>Target User</th>
                  <th>Action</th>
                  <th>Type</th>
                  <th>Subject</th>
                  <th>When</th>
                </tr>
              </thead>
              <tbody>
                {auditRows.length === 0 && (
                  <tr>
                    <td colSpan={6}>No audit records</td>
                  </tr>
                )}
                {auditRows.map((row, idx) => (
                  <tr key={`${String(row.audit_id ?? idx)}`}>
                    <td>{String(row.admin_username ?? row.admin_user_id ?? "-")}</td>
                    <td>{String(row.target_username ?? row.target_user_id ?? "-")}</td>
                    <td>{String(row.action ?? "-")}</td>
                    <td>{String(row.privilege_type ?? "-")}</td>
                    <td>{String(row.subject_id ?? "-")}</td>
                    <td>{String(row.actioned_at ?? "-")}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}
    </div>
  );
}
