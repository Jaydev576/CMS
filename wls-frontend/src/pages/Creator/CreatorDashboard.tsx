import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/useAuth";
import type { SubjectSummary } from "../../context/auth-types";
import { fetchCreatorOverview, type CreatorContentStats } from "../../api/creator";
import "../../App.css";
import "./CreatorStyles.css";

const CreatorDashboard: React.FC = () => {
  const [subjects, setSubjects] = useState<SubjectSummary[]>([]);
  const [stats, setStats] = useState<CreatorContentStats>({
    approved: 0,
    rejected: 0,
    draft: 0,
    total: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();
  const { user } = useAuth();

  useEffect(() => {
    if (!user?.userId) {
      return;
    }

    setLoading(true);
    setError(null);

    fetchCreatorOverview(user.userId)
      .then((overview) => {
        setSubjects(overview.subjects);
        setStats(overview.stats);
        setLoading(false);
      })
      .catch((err: unknown) => {
        setError(err instanceof Error ? err.message : "Failed to fetch subjects");
        setLoading(false);
      });
  }, [user]);

  if (loading) {
    return (
      <div className="creator-dashboard-shell">
        <header className="mobile-header creator-mobile-header">
          <div className="header-spacer" />
          <button className="subjects-home-btn active" type="button" disabled>
            Subjects
          </button>
        </header>
        <div className="main-content">
          <div className="creator-loading">
            <div className="loader"></div>
            <p>Loading your subjects...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="creator-dashboard-shell">
        <header className="mobile-header creator-mobile-header">
          <div className="header-spacer" />
          <button className="subjects-home-btn active" type="button" disabled>
            Subjects
          </button>
        </header>
        <div className="main-content">
          <div className="creator-error">
            <p>Error: {error}</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="creator-dashboard-shell">
      <header className="mobile-header creator-mobile-header">
        <div className="header-spacer" />
        <button className="subjects-home-btn active" type="button" disabled>
          Subjects
        </button>
      </header>

      <div className="main-content">
        <div className="subject-container animate-fade-in">
          <div className="creator-dashboard-header">
            <span className="content-detail-badge">Creator Workspace</span>
            <h2 className="page-title">Select a Subject</h2>
            <p className="creator-dashboard-copy">
              Open a subject to manage chapters, topics, and learning content from a responsive editor.
            </p>
          </div>

          <div className="creator-stats-grid">
            <div className="creator-stat-card">
              <span className="creator-stat-label">Approved</span>
              <strong className="creator-stat-value">{stats.approved}</strong>
            </div>
            <div className="creator-stat-card">
              <span className="creator-stat-label">Rejected</span>
              <strong className="creator-stat-value">{stats.rejected}</strong>
            </div>
            <div className="creator-stat-card">
              <span className="creator-stat-label">Draft</span>
              <strong className="creator-stat-value">{stats.draft}</strong>
            </div>
            <div className="creator-stat-card">
              <span className="creator-stat-label">Total</span>
              <strong className="creator-stat-value">{stats.total}</strong>
            </div>
          </div>

          <div className="grid-cards">
            {subjects.map((subject) => (
              <div
                key={subject.subject_id}
                className="subject-card creator-subject-card"
                onClick={() => navigate(`/creator/subject/${subject.subject_id}`)}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => e.key === "Enter" && navigate(`/creator/subject/${subject.subject_id}`)}
              >
                <div className="creator-subject-card-top">
                  <div className="creator-subject-icon">
                    {subject.subject_name.substring(0, 2).toUpperCase()}
                  </div>
                  <span className="creator-subject-id">Subject #{subject.subject_id}</span>
                </div>
                <div className="creator-subject-info">
                  <h4>{subject.subject_name}</h4>
                  <p>Tap to open the creator menu, browse the structure, and edit content.</p>
                </div>
              </div>
            ))}

            {subjects.length === 0 && (
              <div className="creator-empty-state">
                <p>You have not been assigned any subjects yet.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CreatorDashboard;
