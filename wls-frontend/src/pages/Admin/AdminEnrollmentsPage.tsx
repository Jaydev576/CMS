import { useState } from "react";
import CodeEditor from "../../components/CodeEditor";
import {
  bulkReassignEnrollment,
  fetchEnrollments,
  updateEnrollmentStatus,
  upsertEnrollment,
} from "../../api/admin";
import AcademicHierarchySelector, { type HierarchySelection } from "../../components/Admin/AcademicHierarchySelector";

export default function AdminEnrollmentsPage() {
  const [userId, setUserId] = useState("");
  const [rows, setRows] = useState<Array<Record<string, unknown>>>([]);
  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: "error" | "success"; message: string } | null>(null);

  const [showAdd, setShowAdd] = useState(false);
  const [formHierarchy, setFormHierarchy] = useState<HierarchySelection>({});
  const [enrollmentType, setEnrollmentType] = useState<"HOME" | "EXPLICIT">("EXPLICIT");
  const [validFrom, setValidFrom] = useState("");
  const [validTo, setValidTo] = useState("");

  const [reassignUserIds, setReassignUserIds] = useState("");
  const [reassignHierarchy, setReassignHierarchy] = useState<HierarchySelection>({});

  const load = async () => {
    const numericUserId = Number(userId);
    if (!Number.isFinite(numericUserId) || numericUserId <= 0) {
      setToast({ type: "error", message: "Enter a valid user_id" });
      return;
    }

    setLoading(true);
    try {
      const result = await fetchEnrollments(numericUserId);
      setRows(result.items);
      setToast(null);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to load" });
    } finally {
      setLoading(false);
    }
  };

  const addEnrollment = async () => {
    const numericUserId = Number(userId);
    if (!Number.isFinite(numericUserId) || numericUserId <= 0) {
      setToast({ type: "error", message: "Load a valid user first" });
      return;
    }

    try {
      await upsertEnrollment({
        user_id: numericUserId,
        university_id: formHierarchy.university_id,
        faculty_id: formHierarchy.faculty_id,
        department_id: formHierarchy.department_id,
        course_id: formHierarchy.course_id,
        specialization_id: formHierarchy.specialization_id,
        class_id: formHierarchy.class_id,
        enrollment_type: enrollmentType,
        valid_from: validFrom || null,
        valid_to: validTo || null,
      });

      setToast({ type: "success", message: "Enrollment saved" });
      setShowAdd(false);
      await load();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Enrollment save failed" });
    }
  };

  const updateStatus = async (enrollmentId: number, status: "ACTIVE" | "REVOKED" | "EXPIRED") => {
    try {
      await updateEnrollmentStatus(enrollmentId, status);
      setToast({ type: "success", message: `Enrollment marked ${status}` });
      await load();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Status update failed" });
    }
  };

  const reassign = async () => {
    const ids = reassignUserIds
      .split(",")
      .map((v) => Number(v.trim()))
      .filter((v) => Number.isFinite(v) && v > 0);

    if (ids.length === 0) {
      setToast({ type: "error", message: "Provide comma separated user IDs" });
      return;
    }

    try {
      await bulkReassignEnrollment({
        user_ids: ids,
        new_university_id: reassignHierarchy.university_id,
        new_faculty_id: reassignHierarchy.faculty_id,
        new_department_id: reassignHierarchy.department_id,
        new_course_id: reassignHierarchy.course_id,
        new_specialization_id: reassignHierarchy.specialization_id,
        new_class_id: reassignHierarchy.class_id,
      });
      setToast({ type: "success", message: "Bulk reassignment completed" });
      await load();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Bulk reassignment failed" });
    }
  };

  return (
    <div>
      <div className="admin-topbar">
        <h2>Enrollment Management</h2>
      </div>

      {toast && <div className={`admin-toast ${toast.type}`}>{toast.message}</div>}

      <section className="admin-panel">
        <div className="admin-row" style={{ alignItems: "flex-start", gap: "1.5rem" }}>
          <div style={{ display: "flex", flexDirection: "column", gap: "0.35rem" }}>
            <span style={{ fontSize: "0.82rem", color: "var(--text-secondary)", fontWeight: 600 }}>
              Student User ID
            </span>
            <div className="admin-row" style={{ alignItems: "center", marginTop: 0 }}>
              <input 
                value={userId} 
                onChange={(e) => setUserId(e.target.value)} 
                placeholder="e.g. 3" 
                style={{ width: "160px" }}
              />
              <button type="button" className="admin-btn" onClick={load}>
                Load Enrollments
              </button>
              <button type="button" className="admin-btn secondary" onClick={() => setShowAdd(true)}>
                Add Enrollment
              </button>
            </div>
          </div>
        </div>

        <div className="admin-table-wrap" style={{ marginTop: "0.8rem" }}>
          <table className="admin-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Type</th>
                <th>Status</th>
                <th>Class</th>
                <th>Valid From</th>
                <th>Valid To</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={7}>Loading...</td>
                </tr>
              )}
              {!loading && rows.length === 0 && (
                <tr>
                  <td colSpan={7}>No enrollments</td>
                </tr>
              )}
              {!loading &&
                rows.map((row) => {
                  const enrollmentId = Number(row.enrollment_id);
                  const status = String(row.status ?? "");
                  const isHomeFallback = Number(row.is_home_fallback ?? 0) === 1 || enrollmentId <= 0;
                  return (
                    <tr key={enrollmentId}>
                      <td>{enrollmentId}</td>
                      <td>{String(row.enrollment_type ?? "")}</td>
                      <td>
                        <span className={`admin-status ${status.toLowerCase()}`}>{status}</span>
                      </td>
                      <td>
                        {String(row.university_name ?? "-")} / {String(row.department_name ?? "-")} / {String(row.class_name ?? "-")}
                      </td>
                      <td>{String(row.valid_from ?? "-")}</td>
                      <td>{String(row.valid_to ?? "-")}</td>
                      <td>
                        <div className="admin-row">
                          <button
                            type="button"
                            className="admin-btn secondary"
                            disabled={isHomeFallback}
                            onClick={() => updateStatus(enrollmentId, "ACTIVE")}
                          >
                            Activate
                          </button>
                          <button
                            type="button"
                            className="admin-btn secondary"
                            disabled={isHomeFallback}
                            onClick={() => updateStatus(enrollmentId, "REVOKED")}
                          >
                            Revoke
                          </button>
                          <button
                            type="button"
                            className="admin-btn secondary"
                            disabled={isHomeFallback}
                            onClick={() => updateStatus(enrollmentId, "EXPIRED")}
                          >
                            Expire
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
            </tbody>
          </table>
        </div>
      </section>

      <section className="admin-panel">
        <h3>Bulk Class Reassignment</h3>
        <div className="admin-grid">
          <label>
            User IDs (comma separated)
            <CodeEditor
              value={reassignUserIds}
              onChange={setReassignUserIds}
              placeholder="12, 13, 14"
              plainText
            />
          </label>
        </div>

        <div style={{ marginTop: "0.8rem" }}>
          <AcademicHierarchySelector value={reassignHierarchy} onChange={setReassignHierarchy} includeSpecialization includeClass />
        </div>

        <div className="admin-row" style={{ marginTop: "0.8rem" }}>
          <button type="button" className="admin-btn" onClick={reassign}>
            Reassign
          </button>
        </div>
      </section>

      {showAdd && (
        <div className="admin-modal-backdrop" role="dialog" aria-modal="true">
          <div className="admin-modal">
            <h3>Add / Update Enrollment</h3>

            <div className="admin-grid">
              <label>
                Enrollment Type
                <select value={enrollmentType} onChange={(e) => setEnrollmentType(e.target.value as "HOME" | "EXPLICIT") }>
                  <option value="HOME">HOME</option>
                  <option value="EXPLICIT">EXPLICIT</option>
                </select>
              </label>
              <label>
                Valid From
                <input type="datetime-local" value={validFrom} onChange={(e) => setValidFrom(e.target.value)} />
              </label>
              <label>
                Valid To
                <input type="datetime-local" value={validTo} onChange={(e) => setValidTo(e.target.value)} />
              </label>
            </div>

            <div style={{ marginTop: "0.8rem" }}>
              <AcademicHierarchySelector value={formHierarchy} onChange={setFormHierarchy} includeSpecialization includeClass />
            </div>

            <div className="admin-row" style={{ marginTop: "0.9rem" }}>
              <button type="button" className="admin-btn" onClick={addEnrollment}>
                Save Enrollment
              </button>
              <button type="button" className="admin-btn secondary" onClick={() => setShowAdd(false)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
