import type { ReactElement } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider } from "./context/AuthContext";
import { useAuth } from "./context/useAuth";
import AppLayout from "./layout/AppLayout";
import LoginPage from "./components/Main/LoginPage";
import SubjectListPage from "./components/Main/SubjectListPage";
import ChapterListPage from "./components/Main/ChapterListPage";
import ChapterDetailPage from "./components/Main/ChapterDetailPage";
import SimulationsModule from "./simulations/src/App";
import TestMediaPage from "./components/Main/TestMediaPage";
import CodePlaygroundPage from "./components/Main/CodePlaygroundPage";
import CreatorDashboard from "./pages/Creator/CreatorDashboard";
import CreatorSubjectEditor from "./pages/Creator/CreatorSubjectEditor";
import AdminLayout from "./pages/Admin/AdminLayout";
import AdminDashboardPage from "./pages/Admin/AdminDashboardPage";
import AdminUsersPage from "./pages/Admin/AdminUsersPage";
import AdminEnrollmentsPage from "./pages/Admin/AdminEnrollmentsPage";
import AdminPrivilegesPage from "./pages/Admin/AdminPrivilegesPage";
import AdminHierarchyPage from "./pages/Admin/AdminHierarchyPage";
import AdminContentPage from "./pages/Admin/AdminContentPage";
import AdminSystemPage from "./pages/Admin/AdminSystemPage";

const queryClient = new QueryClient();

function ProtectedRoute({ children }: { children: ReactElement }) {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <div style={{ padding: "2rem" }}>Checking session...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  return children;
}

function RoleProtectedRoute({ children, roleId }: { children: ReactElement; roleId: number }) {
  const { user, isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <div style={{ padding: "2rem" }}>Checking session...</div>;
  }

  if (!isAuthenticated) {
    return <Navigate to="/" replace />;
  }

  if (user?.roleId !== roleId) {
    if (user?.roleId === 2) {
      return <Navigate to="/creator/dashboard" replace />;
    }
    if (user?.roleId === 1) {
      return <Navigate to="/admin" replace />;
    }
    return <Navigate to="/subjects" replace />;
  }

  return children;
}

function LoginRoute() {
  const { isAuthenticated, isLoading, user } = useAuth();

  if (isLoading) {
    return <div style={{ padding: "2rem" }}>Checking session...</div>;
  }

  if (isAuthenticated) {
    if (user?.roleId === 1) {
      return <Navigate to="/admin" replace />;
    }
    return <Navigate to={user?.roleId === 2 ? "/creator/dashboard" : "/subjects"} replace />;
  }

  return <LoginPage />;
}

export default function App() {
  return (
    <BrowserRouter>
      <QueryClientProvider client={queryClient}>
        <AuthProvider>
          <Routes>
            <Route path="/" element={<LoginRoute />} />

            <Route
              path="/subjects"
              element={
                <ProtectedRoute>
                  <AppLayout />
                </ProtectedRoute>
              }
            >
              <Route index element={<SubjectListPage />} />
              <Route path=":subjectId" element={<ChapterListPage />} />
              <Route
                path=":subjectId/simulations/*"
                element={<SimulationsModule />}
              />
              <Route path=":subjectId/test_media" element={<TestMediaPage />} />
              <Route path=":subjectId/code_playground" element={<CodePlaygroundPage />} />
              <Route
                path=":subjectId/chapter/:chapterId"
                element={<ChapterDetailPage />}
              />
            </Route>

            {/* Content Creator / Teacher Routes */}
            <Route
              path="/creator/dashboard"
              element={
                <RoleProtectedRoute roleId={2}>
                  <CreatorDashboard />
                </RoleProtectedRoute>
              }
            />
            <Route
              path="/creator/subject/:subjectId"
              element={
                <RoleProtectedRoute roleId={2}>
                  <CreatorSubjectEditor />
                </RoleProtectedRoute>
              }
            />

            {/* Admin Routes */}
            <Route
              path="/admin"
              element={
                <RoleProtectedRoute roleId={1}>
                  <AdminLayout />
                </RoleProtectedRoute>
              }
            >
              <Route index element={<AdminDashboardPage />} />
              <Route path="users" element={<AdminUsersPage />} />
              <Route path="enrollments" element={<AdminEnrollmentsPage />} />
              <Route path="privileges" element={<AdminPrivilegesPage />} />
              <Route path="hierarchy" element={<AdminHierarchyPage />} />
              <Route path="content" element={<AdminContentPage />} />
              <Route path="system" element={<AdminSystemPage />} />
            </Route>

            <Route path="*" element={<Navigate to="/" />} />
          </Routes>
        </AuthProvider>
      </QueryClientProvider>
    </BrowserRouter>
  );
}
