import { useCallback, useEffect, useMemo, useState } from "react";
import {
  bulkImportUsers,
  createAdminUser,
  downloadBlob,
  downloadUsersTemplate,
  exportUsers,
  fetchAdminUsers,
  resetAdminUserPassword,
  type UserListItem,
  updateAdminUser,
  updateAdminUserStatus,
} from "../../api/admin";
import AcademicHierarchySelector, { type HierarchySelection } from "../../components/Admin/AcademicHierarchySelector";

interface UserFormState extends HierarchySelection {
  username: string;
  password: string;
  role_id: 2 | 3;
  first_name: string;
  last_name: string;
  email: string;
  mobile_no: string;
  nationality_id: number;
}

const emptyUserForm: UserFormState = {
  username: "",
  password: "",
  role_id: 2,
  first_name: "",
  last_name: "",
  email: "",
  mobile_no: "",
  nationality_id: 1,
};

export default function AdminUsersPage() {
  const [users, setUsers] = useState<UserListItem[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [pageSize] = useState(20);
  const [search, setSearch] = useState("");
  const [roleId, setRoleId] = useState<number | undefined>(undefined);
  const [status, setStatus] = useState<string>("");
  const [filterHierarchy, setFilterHierarchy] = useState<HierarchySelection>({});
  const [selectedIds, setSelectedIds] = useState<number[]>([]);
  const [bulkAction, setBulkAction] = useState<"ACTIVATE" | "DEACTIVATE" | "UNLOCK">("ACTIVATE");

  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: "error" | "success"; message: string } | null>(null);

  const [showCreate, setShowCreate] = useState(false);
  const [createForm, setCreateForm] = useState<UserFormState>(emptyUserForm);

  const [editUser, setEditUser] = useState<UserListItem | null>(null);
  const [editForm, setEditForm] = useState<UserFormState>(emptyUserForm);

  const [resetUser, setResetUser] = useState<UserListItem | null>(null);
  const [resetPassword, setResetPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

  const [importRole, setImportRole] = useState<"teacher" | "student">("teacher");
  const [importFile, setImportFile] = useState<File | null>(null);
  const [importResult, setImportResult] = useState<{
    total: number;
    success: number;
    failed: number;
    errors: Array<{ row: number; username?: string; reason: string }>;
  } | null>(null);

  const totalPages = useMemo(() => Math.max(1, Math.ceil(total / pageSize)), [total, pageSize]);

  const loadUsers = useCallback(async () => {
    setLoading(true);
    try {
      const result = await fetchAdminUsers({
        page,
        page_size: pageSize,
        search,
        role_id: roleId,
        account_status: status || undefined,
        university_id: filterHierarchy.university_id,
        department_id: filterHierarchy.department_id,
        class_id: filterHierarchy.class_id,
      });
      setUsers(result.items);
      setTotal(result.total);
      setSelectedIds([]);
      setToast(null);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to load users" });
    } finally {
      setLoading(false);
    }
  }, [page, pageSize, search, roleId, status, filterHierarchy]);

  useEffect(() => {
    void loadUsers();
  }, [loadUsers]);

  const onCreateSubmit = async () => {
    try {
      await createAdminUser({
        ...createForm,
        role_id: Number(createForm.role_id),
      });
      setShowCreate(false);
      setCreateForm(emptyUserForm);
      setToast({ type: "success", message: "User created successfully" });
      await loadUsers();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Create failed" });
    }
  };

  const openEdit = (user: UserListItem) => {
    setEditUser(user);
    setEditForm({
      username: user.username,
      password: "",
      role_id: user.role_id === 3 ? 3 : 2,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      mobile_no: user.mobile_no ?? "",
      nationality_id: 1,
      university_id: user.university_id,
      faculty_id: user.faculty_id,
      department_id: user.department_id,
      course_id: user.course_id,
      specialization_id: user.specialization_id,
      class_id: user.class_id,
    });
  };

  const onEditSubmit = async () => {
    if (!editUser) {
      return;
    }
    try {
      await updateAdminUser(editUser.user_id, {
        first_name: editForm.first_name,
        last_name: editForm.last_name,
        email: editForm.email,
        mobile_no: editForm.mobile_no,
        nationality_id: editForm.nationality_id,
        university_id: editForm.university_id,
        faculty_id: editForm.faculty_id,
        department_id: editForm.department_id,
        course_id: editForm.course_id,
        specialization_id: editForm.role_id === 3 ? editForm.specialization_id : undefined,
        class_id: editForm.role_id === 3 ? editForm.class_id : undefined,
      });
      setEditUser(null);
      setToast({ type: "success", message: "User updated" });
      await loadUsers();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Update failed" });
    }
  };

  const onResetPassword = async () => {
    if (!resetUser) {
      return;
    }
    if (!resetPassword || resetPassword !== confirmPassword) {
      setToast({ type: "error", message: "Passwords do not match" });
      return;
    }

    try {
      await resetAdminUserPassword(resetUser.user_id, resetPassword);
      setToast({ type: "success", message: "Password reset successful" });
      setResetUser(null);
      setResetPassword("");
      setConfirmPassword("");
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Reset failed" });
    }
  };

  const runBulkAction = async () => {
    if (selectedIds.length === 0) {
      setToast({ type: "error", message: "No users selected" });
      return;
    }
    try {
      await updateAdminUserStatus(selectedIds, bulkAction);
      setToast({ type: "success", message: `Bulk action ${bulkAction} applied` });
      await loadUsers();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Bulk action failed" });
    }
  };

  const quickStatus = async (userId: number, action: "ACTIVATE" | "DEACTIVATE" | "UNLOCK") => {
    try {
      await updateAdminUserStatus([userId], action);
      setToast({ type: "success", message: `User ${action.toLowerCase()} successful` });
      await loadUsers();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Action failed" });
    }
  };

  const onImport = async () => {
    if (!importFile) {
      setToast({ type: "error", message: "Please select an Excel file" });
      return;
    }
    try {
      const result = await bulkImportUsers(importRole, importFile);
      setImportResult(result ?? null);
      setToast({ type: "success", message: "Bulk import completed" });
      await loadUsers();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Import failed" });
    }
  };

  const onDownloadTemplate = async () => {
    try {
      const blob = await downloadUsersTemplate(importRole);
      downloadBlob(blob, `${importRole}_import_template.csv`);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Download failed" });
    }
  };

  const onExport = async () => {
    try {
      const blob = await exportUsers({
        role_id: roleId,
        account_status: status || undefined,
        university_id: filterHierarchy.university_id,
        department_id: filterHierarchy.department_id,
        class_id: filterHierarchy.class_id,
      });
      downloadBlob(blob, "admin_users_export.xlsx");
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Export failed" });
    }
  };

  return (
    <div>
      <div className="admin-topbar">
        <h2>User Management</h2>
        <div className="admin-row">
          <button type="button" className="admin-btn secondary" onClick={() => setShowCreate(true)}>
            Create User
          </button>
          <button type="button" className="admin-btn" onClick={onExport}>
            Export Excel
          </button>
        </div>
      </div>

      {toast && <div className={`admin-toast ${toast.type}`}>{toast.message}</div>}

      <section className="admin-panel">
        <div className="admin-grid">
          <label>
            Search
            <input value={search} onChange={(e) => setSearch(e.target.value)} placeholder="username / name / email" />
          </label>

          <label>
            Role
            <select
              value={roleId ?? ""}
              onChange={(e) => setRoleId(e.target.value ? Number(e.target.value) : undefined)}
            >
              <option value="">All</option>
              <option value="2">Teacher</option>
              <option value="3">Student</option>
            </select>
          </label>

          <label>
            Status
            <select value={status} onChange={(e) => setStatus(e.target.value)}>
              <option value="">All</option>
              <option value="ACTIVE">ACTIVE</option>
              <option value="INACTIVE">INACTIVE</option>
              <option value="LOCKED">LOCKED</option>
            </select>
          </label>

          <div className="admin-row" style={{ alignItems: "flex-end" }}>
            <button type="button" className="admin-btn" onClick={loadUsers}>
              Apply Filters
            </button>
          </div>
        </div>

        <div style={{ marginTop: "0.8rem" }}>
          <AcademicHierarchySelector value={filterHierarchy} onChange={setFilterHierarchy} includeSpecialization includeClass />
        </div>
      </section>

      <section className="admin-panel">
        <div className="admin-actions">
          <select
            value={bulkAction}
            onChange={(e) => setBulkAction(e.target.value as "ACTIVATE" | "DEACTIVATE" | "UNLOCK")}
          >
            <option value="ACTIVATE">Activate Selected</option>
            <option value="DEACTIVATE">Deactivate Selected</option>
            <option value="UNLOCK">Unlock Selected</option>
          </select>
          <button type="button" className="admin-btn secondary" onClick={runBulkAction}>
            Apply Bulk Action
          </button>
          <span>Selected: {selectedIds.length}</span>
        </div>

        <div className="admin-table-wrap">
          <table className="admin-table">
            <thead>
              <tr>
                <th>
                  <input
                    type="checkbox"
                    checked={users.length > 0 && selectedIds.length === users.length}
                    onChange={(e) =>
                      setSelectedIds(e.target.checked ? users.map((u) => u.user_id) : [])
                    }
                  />
                </th>
                <th>Username</th>
                <th>Name</th>
                <th>Role</th>
                <th>Status</th>
                <th>Last Login</th>
                <th>Failed</th>
                <th>Academic</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={9}>Loading...</td>
                </tr>
              )}
              {!loading && users.length === 0 && (
                <tr>
                  <td colSpan={9}>No users found.</td>
                </tr>
              )}
              {!loading &&
                users.map((user) => (
                  <tr key={user.user_id}>
                    <td>
                      <input
                        type="checkbox"
                        checked={selectedIds.includes(user.user_id)}
                        onChange={(e) =>
                          setSelectedIds((prev) =>
                            e.target.checked ? [...prev, user.user_id] : prev.filter((id) => id !== user.user_id),
                          )
                        }
                      />
                    </td>
                    <td>{user.username}</td>
                    <td>{`${user.first_name ?? ""} ${user.last_name ?? ""}`.trim()}</td>
                    <td>{user.role_name}</td>
                    <td>
                      <span className={`admin-status ${String(user.account_status).toLowerCase()}`}>{user.account_status}</span>
                    </td>
                    <td>{user.last_login_at ?? "-"}</td>
                    <td>{user.failed_login_attempts}</td>
                    <td>
                      {user.university_name ?? "-"} / {user.department_name ?? "-"}
                      <br />
                      {user.class_name ?? "-"}
                    </td>
                    <td>
                      <div className="admin-row">
                        <button type="button" className="admin-btn secondary" onClick={() => openEdit(user)}>
                          Edit
                        </button>
                        <button
                          type="button"
                          className="admin-btn secondary"
                          onClick={() => setResetUser(user)}
                        >
                          Reset PW
                        </button>
                        <button
                          type="button"
                          className="admin-btn secondary"
                          onClick={() =>
                            quickStatus(user.user_id, user.account_status === "ACTIVE" ? "DEACTIVATE" : "ACTIVATE")
                          }
                        >
                          {user.account_status === "ACTIVE" ? "Deactivate" : "Activate"}
                        </button>
                        <button
                          type="button"
                          className="admin-btn secondary"
                          onClick={() => quickStatus(user.user_id, "UNLOCK")}
                        >
                          Unlock
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>

        <div className="admin-row" style={{ justifyContent: "space-between", marginTop: "0.8rem" }}>
          <span>
            Page {page} / {totalPages} (Total: {total})
          </span>
          <div className="admin-row">
            <button type="button" className="admin-btn secondary" disabled={page <= 1} onClick={() => setPage(page - 1)}>
              Prev
            </button>
            <button
              type="button"
              className="admin-btn secondary"
              disabled={page >= totalPages}
              onClick={() => setPage(page + 1)}
            >
              Next
            </button>
          </div>
        </div>
      </section>

      <section className="admin-panel">
        <h3>Bulk Import</h3>
        <div className="admin-row">
          <select value={importRole} onChange={(e) => setImportRole(e.target.value as "teacher" | "student") }>
            <option value="teacher">Teacher Template</option>
            <option value="student">Student Template</option>
          </select>
          <button type="button" className="admin-btn secondary" onClick={onDownloadTemplate}>
            Download Template
          </button>
          <input type="file" accept=".xlsx" onChange={(e) => setImportFile(e.target.files?.[0] ?? null)} />
          <button type="button" className="admin-btn" onClick={onImport}>
            Upload
          </button>
        </div>

        {importResult && (
          <div style={{ marginTop: "0.8rem" }}>
            <p>
              Total: {importResult.total}, Success: {importResult.success}, Failed: {importResult.failed}
            </p>
            {importResult.errors.length > 0 && (
              <div className="admin-table-wrap">
                <table className="admin-table">
                  <thead>
                    <tr>
                      <th>Row</th>
                      <th>Username</th>
                      <th>Error</th>
                    </tr>
                  </thead>
                  <tbody>
                    {importResult.errors.map((error) => (
                      <tr key={`${error.row}-${error.reason}`}>
                        <td>{error.row}</td>
                        <td>{error.username ?? "-"}</td>
                        <td>{error.reason}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}
      </section>

      {showCreate && (
        <div className="admin-modal-backdrop" role="dialog" aria-modal="true">
          <div className="admin-modal">
            <h3>Create User</h3>
            <div className="admin-grid">
              <label>
                Role
                <select
                  value={createForm.role_id}
                  onChange={(e) =>
                    setCreateForm((prev) => ({
                      ...prev,
                      role_id: Number(e.target.value) as 2 | 3,
                      specialization_id: undefined,
                      class_id: undefined,
                    }))
                  }
                >
                  <option value={2}>Teacher</option>
                  <option value={3}>Student</option>
                </select>
              </label>
              <label>
                Username
                <input
                  value={createForm.username}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, username: e.target.value }))}
                />
              </label>
              <label>
                Password
                <input
                  type="password"
                  value={createForm.password}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, password: e.target.value }))}
                />
              </label>
              <label>
                First Name
                <input
                  value={createForm.first_name}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, first_name: e.target.value }))}
                />
              </label>
              <label>
                Last Name
                <input
                  value={createForm.last_name}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, last_name: e.target.value }))}
                />
              </label>
              <label>
                Email
                <input
                  value={createForm.email}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, email: e.target.value }))}
                />
              </label>
              <label>
                Mobile
                <input
                  value={createForm.mobile_no}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, mobile_no: e.target.value }))}
                />
              </label>
              <label>
                Nationality ID
                <input
                  type="number"
                  value={createForm.nationality_id}
                  onChange={(e) => setCreateForm((prev) => ({ ...prev, nationality_id: Number(e.target.value) || 1 }))}
                />
              </label>
            </div>

            <div style={{ marginTop: "0.8rem" }}>
              <AcademicHierarchySelector
                value={createForm}
                onChange={(value) => setCreateForm((prev) => ({ ...prev, ...value }))}
                includeSpecialization={createForm.role_id === 3}
                includeClass={createForm.role_id === 3}
              />
            </div>

            <div className="admin-row" style={{ marginTop: "0.9rem" }}>
              <button type="button" className="admin-btn" onClick={onCreateSubmit}>
                Save
              </button>
              <button type="button" className="admin-btn secondary" onClick={() => setShowCreate(false)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {editUser && (
        <div className="admin-modal-backdrop" role="dialog" aria-modal="true">
          <div className="admin-modal">
            <h3>Edit User: {editUser.username}</h3>
            <div className="admin-grid">
              <label>
                First Name
                <input
                  value={editForm.first_name}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, first_name: e.target.value }))}
                />
              </label>
              <label>
                Last Name
                <input
                  value={editForm.last_name}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, last_name: e.target.value }))}
                />
              </label>
              <label>
                Email
                <input
                  value={editForm.email}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, email: e.target.value }))}
                />
              </label>
              <label>
                Mobile
                <input
                  value={editForm.mobile_no}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, mobile_no: e.target.value }))}
                />
              </label>
            </div>

            <div style={{ marginTop: "0.8rem" }}>
              <AcademicHierarchySelector
                value={editForm}
                onChange={(value) => setEditForm((prev) => ({ ...prev, ...value }))}
                includeSpecialization={editForm.role_id === 3}
                includeClass={editForm.role_id === 3}
              />
            </div>

            <div className="admin-row" style={{ marginTop: "0.9rem" }}>
              <button type="button" className="admin-btn" onClick={onEditSubmit}>
                Update
              </button>
              <button type="button" className="admin-btn secondary" onClick={() => setEditUser(null)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {resetUser && (
        <div className="admin-modal-backdrop" role="dialog" aria-modal="true">
          <div className="admin-modal" style={{ maxWidth: 520 }}>
            <h3>Reset Password: {resetUser.username}</h3>
            <div className="admin-grid">
              <label>
                New Password
                <input type="password" value={resetPassword} onChange={(e) => setResetPassword(e.target.value)} />
              </label>
              <label>
                Confirm Password
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                />
              </label>
            </div>
            <div className="admin-row" style={{ marginTop: "0.9rem" }}>
              <button type="button" className="admin-btn" onClick={onResetPassword}>
                Reset Password
              </button>
              <button type="button" className="admin-btn secondary" onClick={() => setResetUser(null)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
