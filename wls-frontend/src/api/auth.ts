import type { LoginResponse, SubjectSummary, UserProfile } from "../context/auth-types";

export class ApiError extends Error {
  status: number;

  constructor(message: string, status: number) {
    super(message);
    this.status = status;
    this.name = "ApiError";
  }
}

export async function loginUser(credentials: {
  username: string;
  password: string;
}) {
  const formData = new URLSearchParams();
  formData.append("username", credentials.username);
  formData.append("password", credentials.password);

  const res = await fetch("/wls/api/checkLogin", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: formData.toString(),
    credentials: "include",
  });

  const data = (await res.json()) as LoginResponse;

  if (!res.ok || data.status !== "success") {
    throw new ApiError(data.message ?? "Invalid username or password", res.status);
  }

  return data;
}

export async function fetchUserProfile(): Promise<UserProfile> {
  const res = await fetch("/wls/api/subjects", {
    credentials: "include",
  });

  if (!res.ok) {
    throw new ApiError("Failed to fetch user profile", res.status);
  }

  const data = await res.json();

  if (data.status !== "success") {
    throw new ApiError("Unauthorized or server error", 401);
  }

  const subjects: SubjectSummary[] = Array.isArray(data.subjects)
    ? data.subjects.map((subject: { subject_id: number; subject_name: string }) => ({
        subject_id: Number(subject.subject_id),
        subject_name: String(subject.subject_name),
      }))
    : [];

  return {
    userId: Number(data.userId),
    username: String(data.username ?? ""),
    roleId: Number(data.roleId),
    classId: String(data.academicContext?.classId ?? ""),
    sessionTimeoutSeconds: Number(data.sessionTimeoutSeconds ?? 1800),
    subjects,
  };
}
