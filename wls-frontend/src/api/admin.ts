export interface AdminApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
}

export interface UserListItem {
  user_id: number;
  username: string;
  first_name: string;
  last_name: string;
  email: string;
  mobile_no?: string;
  role_id: number;
  role_name: string;
  account_status: string;
  last_login_at: string | null;
  failed_login_attempts: number;
  university_id?: number;
  faculty_id?: number;
  department_id?: number;
  course_id?: number;
  specialization_id?: number;
  class_id?: number;
  university_name?: string;
  faculty_name?: string;
  department_name?: string;
  course_name?: string;
  specialization_name?: string;
  class_name?: string;
}

export interface PagedResult<T> {
  items: T[];
  total: number;
  page: number;
  page_size: number;
}

export interface HierarchyNode {
  [key: string]: string | number | null;
}

async function requestJson<T>(url: string, init?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    credentials: "include",
    ...init,
  });

  const text = await response.text();
  const json = text ? (JSON.parse(text) as AdminApiResponse<T>) : null;

  if (!response.ok) {
    throw new Error(json?.message ?? "Request failed");
  }

  if (!json?.success) {
    throw new Error(json?.message ?? "Request failed");
  }

  return json.data as T;
}

async function requestBlob(url: string): Promise<Blob> {
  const response = await fetch(url, { credentials: "include" });
  if (!response.ok) {
    const raw = await response.text();
    let message = "File export failed";
    if (raw) {
      try {
        const json = JSON.parse(raw) as AdminApiResponse<unknown>;
        if (json?.message) {
          message = json.message;
        }
      } catch {
        // ignore non-JSON responses
      }
    }
    throw new Error(message);
  }
  return response.blob();
}

function toQueryString(params: Record<string, string | number | undefined | null>): string {
  const search = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value === undefined || value === null || value === "") {
      return;
    }
    search.append(key, String(value));
  });
  const qs = search.toString();
  return qs ? `?${qs}` : "";
}

export function fetchAdminDashboard() {
  return requestJson<Record<string, unknown>>("/wls/api/admin/dashboard");
}

export function fetchAdminUsers(params: {
  page?: number;
  page_size?: number;
  role_id?: number;
  account_status?: string;
  university_id?: number;
  department_id?: number;
  class_id?: number;
  search?: string;
}) {
  return requestJson<PagedResult<UserListItem>>(`/wls/api/admin/users${toQueryString(params)}`);
}

export function createAdminUser(payload: Record<string, unknown>) {
  return requestJson<{ user_id: number }>("/wls/api/admin/users/create", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function updateAdminUser(userId: number, payload: Record<string, unknown>) {
  return requestJson<UserListItem>(`/wls/api/admin/users/${userId}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function resetAdminUserPassword(userId: number, newPassword: string) {
  return requestJson<{ updated: boolean }>(`/wls/api/admin/users/${userId}/reset-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ new_password: newPassword }),
  });
}

export function updateAdminUserStatus(
  userIds: number[],
  action: "ACTIVATE" | "DEACTIVATE" | "UNLOCK" | "INVOKE",
) {
  return requestJson<{ updated: number }>("/wls/api/admin/users/status", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ user_ids: userIds, action }),
  });
}

export async function bulkImportUsers(role: "teacher" | "student", file: File) {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("role", role);

  const response = await fetch(`/wls/api/admin/users/bulk-import?role=${encodeURIComponent(role)}`, {
    method: "POST",
    credentials: "include",
    body: formData,
  });

  const raw = await response.text();
  const data = (raw ? JSON.parse(raw) : null) as AdminApiResponse<{
    total: number;
    success: number;
    failed: number;
    errors: Array<{ row: number; username?: string; reason: string }>;
  }> | null;

  if (!response.ok || !data?.success) {
    throw new Error(data?.message ?? "Bulk import failed");
  }

  return data.data;
}

export function downloadUsersTemplate(role: "teacher" | "student") {
  return requestBlob(`/wls/api/admin/users/template?role=${encodeURIComponent(role)}`);
}

export function exportUsers(params: Record<string, string | number | undefined>) {
  return requestBlob(`/wls/api/admin/users/export${toQueryString(params)}`);
}

export function fetchHierarchyLevel(level: string, params: Record<string, string | number | undefined> = {}) {
  return requestJson<{ items: HierarchyNode[] }>(`/wls/api/admin/hierarchy/${level}${toQueryString(params)}`);
}

export function createHierarchyLevel(level: string, payload: Record<string, unknown>) {
  return requestJson<Record<string, unknown>>(`/wls/api/admin/hierarchy/${level}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function updateHierarchyLevel(level: string, id: number, payload: Record<string, unknown>) {
  return requestJson<Record<string, unknown>>(`/wls/api/admin/hierarchy/${level}/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function deleteHierarchyLevel(level: string, id: number, payload: Record<string, unknown>) {
  return requestJson<{ deleted: number }>(`/wls/api/admin/hierarchy/${level}/${id}`, {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function fetchEnrollments(userId: number) {
  return requestJson<{ items: Array<Record<string, unknown>> }>(`/wls/api/admin/enrollments?user_id=${userId}`);
}

export function upsertEnrollment(payload: Record<string, unknown>) {
  return requestJson<{ updated: number }>("/wls/api/admin/enrollments", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function updateEnrollmentStatus(enrollmentId: number, status: "ACTIVE" | "REVOKED" | "EXPIRED") {
  return requestJson<{ updated: number }>(`/wls/api/admin/enrollments/${enrollmentId}/status`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status }),
  });
}

export function bulkReassignEnrollment(payload: Record<string, unknown>) {
  return requestJson<{ updated_users: number; updated_home_enrollments: number }>(
    "/wls/api/admin/enrollments/bulk-reassign",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    },
  );
}

export function fetchPrivilegeOverview(subjectId: number, roleId: 2 | 3) {
  return requestJson<{ items: Array<Record<string, unknown>> }>(
    `/wls/api/admin/privileges/overview?subject_id=${subjectId}&role_id=${roleId}`,
  );
}

export function updatePrivilege(route: string, payload: Record<string, unknown>) {
  return requestJson<{ updated: boolean | number }>(`/wls/api/admin/${route}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function revokePrivilege(route: string, payload: Record<string, unknown>) {
  return requestJson<{ updated: number }>(`/wls/api/admin/${route}`, {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function fetchPrivilegeAudit(params: {
  page?: number;
  page_size?: number;
  target_user_id?: number;
  subject_id?: number;
}) {
  return requestJson<PagedResult<Record<string, unknown>>>(
    `/wls/api/admin/privileges/audit${toQueryString(params)}`,
  );
}

export function exportPrivileges(subjectId: number, roleId: 2 | 3) {
  return requestBlob(`/wls/api/admin/privileges/export?subject_id=${subjectId}&role_id=${roleId}`);
}

export function exportPrivilegeAuditAll(subjectId?: number) {
  const qs = subjectId ? `?subject_id=${subjectId}` : "";
  return requestBlob(`/wls/api/admin/privileges/audit/export${qs}`);
}

export function fetchClassSubjects(params: Record<string, string | number | undefined>) {
  return requestJson<{ items: Array<Record<string, unknown>> }>(`/wls/api/admin/class-subjects${toQueryString(params)}`);
}

export function fetchClassSubjectChapters(params: Record<string, string | number | undefined>) {
  return requestJson<{ items: Array<Record<string, unknown>> }>(
    `/wls/api/admin/class-subject-chapters${toQueryString(params)}`,
  );
}

export function assignClassSubject(payload: Record<string, unknown>) {
  return requestJson<{ updated: number }>("/wls/api/admin/class-subjects", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function removeClassSubject(payload: Record<string, unknown>) {
  return requestJson<{ deleted: number }>("/wls/api/admin/class-subjects", {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function assignClassSubjectChapter(payload: Record<string, unknown>) {
  return requestJson<{ updated: number }>("/wls/api/admin/class-subject-chapters", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function removeClassSubjectChapter(payload: Record<string, unknown>) {
  return requestJson<{ deleted: number }>("/wls/api/admin/class-subject-chapters", {
    method: "DELETE",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
}

export function fetchActivity(params: Record<string, string | number | undefined>) {
  return requestJson<PagedResult<Record<string, unknown>>>(`/wls/api/admin/activity${toQueryString(params)}`);
}

export function fetchReviewQueue(status: "DRAFT" | "APPROVED" | "REJECTED" | "PENDING") {
  return requestJson<{ items: Array<Record<string, unknown>> }>(`/wls/api/admin/content/review-queue?status=${status}`);
}

export function invokeUserSession(userId: number) {
  return updateAdminUserStatus([userId], "INVOKE");
}

export function approveReview(contentType: string, compositeId: string) {
  return requestJson<{ updated: number }>(
    `/wls/api/admin/content/review-queue/${encodeURIComponent(contentType)}/${encodeURIComponent(compositeId)}/approve`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    },
  );
}

export function moveReviewToDraft(contentType: string, compositeId: string) {
  return requestJson<{ updated: number }>(
    `/wls/api/admin/content/review-queue/${encodeURIComponent(contentType)}/${encodeURIComponent(compositeId)}/move-to-draft`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({}),
    },
  );
}

export function rejectReview(contentType: string, compositeId: string, remarks: string) {
  return requestJson<{ updated: number }>(
    `/wls/api/admin/content/review-queue/${encodeURIComponent(contentType)}/${encodeURIComponent(compositeId)}/reject`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ remarks }),
    },
  );
}

export function downloadBlob(blob: Blob, filename: string) {
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  a.remove();
  window.URL.revokeObjectURL(url);
}
