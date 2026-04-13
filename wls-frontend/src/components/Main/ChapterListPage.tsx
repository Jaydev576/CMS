import { useParams } from "react-router-dom";
import { useAuth } from "../../context/useAuth";
import "../../App.css";

export default function ChapterListPage() {
  const { subjectId } = useParams();
  const { user } = useAuth();

  const subjectName = user?.subjects?.find(s => String(s.subject_id) === subjectId)?.subject_name || "Course";

  return (
    <div className="main-content">
      <div className="subject-container animate-fade-in">
        <div className="content-detail-header">
          <span className="content-detail-badge">Learner Workspace</span>
          <h2 className="page-title">{subjectName} Dashboard</h2>
          <p className="content-detail-body">
            Choose a chapter from the left menu to open the lesson flow for this subject.
          </p>
        </div>

        <div className="subject-card" style={{ cursor: "default", maxWidth: "600px" }}>
          <h4>Explore Course Content</h4>
          <p style={{ color: "var(--text-secondary)", marginTop: "0.5rem" }}>
            You are currently viewing Subject: <strong>{subjectName}</strong>.
            <br /><br />
            Select a chapter from the sidebar menu on the left to begin learning.
          </p>
        </div>
      </div>
    </div>
  );
}
