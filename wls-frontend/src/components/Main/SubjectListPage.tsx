import { useAuth } from "../../context/useAuth";
import { useNavigate } from "react-router-dom";
import type { SubjectSummary } from "../../context/auth-types";
import "../../App.css";

export default function SubjectListPage() {
  const { user, isLoading, isError } = useAuth();
  const navigate = useNavigate();

  const subjects = user?.subjects ?? [];

  if (isLoading) return <div className="main-content">Loading subjects...</div>;
  if (isError) return <div className="main-content" style={{ color: "#ef4444" }}>Error loading subjects.</div>;

  return (
    <div className="main-content">
      <div className="subject-container animate-fade-in">
        <div className="content-detail-header">
          <span className="content-detail-badge">Learner Workspace</span>
          <h2 className="page-title">Select a Subject</h2>
          <p className="content-detail-body">
            Open a subject to browse chapters, review learning materials, and continue your progress.
          </p>
        </div>

        <div className="grid-cards">
          {subjects.map((subject: SubjectSummary) => (
            <div
              key={subject.subject_id}
              className="subject-card"
              onClick={() => navigate(`/subjects/${subject.subject_id}`)}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => e.key === 'Enter' && navigate(`/subjects/${subject.subject_id}`)}
            >
              <h4>{subject.subject_name}</h4>
              <p style={{ color: "var(--text-secondary)", fontSize: "0.9rem" }}>
                Click to explore chapters
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
