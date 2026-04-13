export interface SubjectSummary {
  subject_id: number;
  subject_name: string;
}

export interface UserProfile {
  userId: number;
  username: string;
  roleId: number;
  classId: string;
  sessionTimeoutSeconds: number;
  subjects: SubjectSummary[];
}

export interface LoginResponse {
  status: "success" | "error";
  roleId?: number;
  dashboard?: string;
  message?: string;
}

export interface AuthContextType {
  user: UserProfile | null;
  login: (username: string, password: string) => Promise<LoginResponse>;
  logout: () => Promise<void>;
  isAuthenticated: boolean;
  isLoading: boolean;
  isError: boolean;
  isAuthenticating: boolean;
}
