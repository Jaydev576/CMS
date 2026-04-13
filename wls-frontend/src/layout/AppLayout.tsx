import { useState } from "react";
import { Outlet, useParams, useNavigate, useLocation } from "react-router-dom";
import ChapterContentTree from "../components/Sidebar/ChapterContentTree";
import { useAuth } from "../context/useAuth";
import "../App.css";

export default function AppLayout() {
  const { subjectId } = useParams();
  const showSidebar = Boolean(subjectId);
  const { logout, user } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);
  const isSubjectListPage = location.pathname === "/subjects";
  const isSimulationPage = location.pathname.includes("/simulations");
  const isTestMediaPage = location.pathname.includes("/test_media");
  const isCodePlaygroundPage = location.pathname.includes("/code_playground");
  const hideSubjectsButton = isSimulationPage || isTestMediaPage || isCodePlaygroundPage;

  const subjectName = user?.subjects?.find(s => String(s.subject_id) === subjectId)?.subject_name || "Course Content";

  const handleLogout = async () => {
    setIsSidebarOpen(false);
    await logout();
    navigate("/");
  };

  const handleGoToSubjects = () => {
    setIsSidebarOpen(false);
    navigate("/subjects");
  };

  return (
    <div className="dashboard-layout">
      {showSidebar && (
        <div
          className={`sidebar-backdrop ${isSidebarOpen ? "open" : ""}`}
          onClick={() => setIsSidebarOpen(false)}
          aria-hidden="true"
        />
      )}

      {showSidebar && (
        <div
          className={`sidebar ${isSidebarOpen ? "open" : ""}`}
          style={{ justifyContent: "space-between" }}
        >
          <div>
            <div className="sidebar-header">
              <h3>{subjectName}</h3>
              <button
                className="sidebar-close"
                type="button"
                onClick={() => setIsSidebarOpen(false)}
                aria-label="Close chapter sidebar"
              >
                Close
              </button>
            </div>
            <div className="sidebar-nav">
              <ChapterContentTree onNavigate={() => setIsSidebarOpen(false)} />
            </div>
          </div>

          <div className="sidebar-footer">
            <button className="btn-danger" onClick={handleLogout}>
              Sign Out
            </button>
          </div>
        </div>
      )}

      <div className="layout-outlet" onClick={() => setIsSidebarOpen(false)}>
        <header className="mobile-header" onClick={(e) => e.stopPropagation()}>
          {showSidebar ? (
            <button
              className="sidebar-toggle"
              type="button"
              onClick={() => setIsSidebarOpen(true)}
              aria-label="Open chapter sidebar"
            >
              Menu
            </button>
          ) : (
            <div className="header-spacer" />
          )}

          {!hideSubjectsButton && (
            <button
              className={`subjects-home-btn ${isSubjectListPage ? "active" : ""}`}
              type="button"
              onClick={handleGoToSubjects}
              disabled={isSubjectListPage}
              aria-label="Go to subject list"
            >
              Subjects
            </button>
          )}
        </header>

        <Outlet />
      </div>
    </div>
  );
}
