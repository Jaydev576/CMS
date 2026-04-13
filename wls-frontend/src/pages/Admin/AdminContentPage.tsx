import { Fragment, useEffect, useState } from "react";
import { approveReview, fetchReviewQueue, moveReviewToDraft, rejectReview } from "../../api/admin";
import CodeEditor from "../../components/CodeEditor";

type QueueStatus = "DRAFT" | "APPROVED" | "REJECTED";
type RemarkModalAction = "REJECT" | "EDIT_REMARKS";

interface RemarkModalState {
  compositeId: string;
  contentType: string;
  action: RemarkModalAction;
}

export default function AdminContentPage() {
  const [status, setStatus] = useState<QueueStatus>("DRAFT");
  const [rows, setRows] = useState<Array<Record<string, unknown>>>([]);
  const [loading, setLoading] = useState(false);
  const [expandedContentKey, setExpandedContentKey] = useState<string | null>(null);
  const [expandedRemarksKey, setExpandedRemarksKey] = useState<string | null>(null);
  const [remarkModalState, setRemarkModalState] = useState<RemarkModalState | null>(null);
  const [remarks, setRemarks] = useState("");
  const [toast, setToast] = useState<{ type: "error" | "success"; message: string } | null>(null);

  const load = async () => {
    setLoading(true);
    try {
      const result = await fetchReviewQueue(status);
      setRows(result.items);
      setToast(null);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to load queue" });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [status]);

  useEffect(() => {
    setExpandedContentKey(null);
    setExpandedRemarksKey(null);
    setRemarkModalState(null);
    setRemarks("");
  }, [status]);

  const doApprove = async (row: Record<string, unknown>) => {
    try {
      await approveReview(String(row.content_type), String(row.composite_id));
      setToast({ type: "success", message: "Content approved" });
      await load();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Approve failed" });
    }
  };

  const doMoveToDraft = async (row: Record<string, unknown>) => {
    try {
      await moveReviewToDraft(String(row.content_type), String(row.composite_id));
      setToast({ type: "success", message: "Content moved to draft" });
      await load();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Move to draft failed" });
    }
  };

  const doSubmitRemarks = async () => {
    if (!remarkModalState) {
      return;
    }

    try {
      await rejectReview(remarkModalState.contentType, remarkModalState.compositeId, remarks);
      setToast({
        type: "success",
        message: remarkModalState.action === "EDIT_REMARKS" ? "Remarks updated" : "Content rejected",
      });
      setRemarkModalState(null);
      setRemarks("");
      await load();
    } catch (err: unknown) {
      setToast({
        type: "error",
        message: err instanceof Error ? err.message : remarkModalState.action === "EDIT_REMARKS" ? "Update failed" : "Reject failed",
      });
    }
  };

  const tabs: QueueStatus[] = ["DRAFT", "APPROVED", "REJECTED"];

  return (
    <div>
      <div className="admin-topbar">
        <h2>Content Review Queue</h2>
      </div>

      {toast && <div className={`admin-toast ${toast.type}`}>{toast.message}</div>}

      <section className="admin-panel">
        <div className="admin-row">
          {tabs.map((tab) => (
            <button
              key={tab}
              type="button"
              className={`admin-btn ${status === tab ? "" : "secondary"}`}
              onClick={() => setStatus(tab)}
            >
              {tab}
            </button>
          ))}
        </div>
      </section>

      <section className="admin-panel">
        <div className="admin-table-wrap">
          <table className="admin-table">
            <thead>
              <tr>
                <th>Type</th>
                <th>Name</th>
                <th>Subject</th>
                <th>Author</th>
                <th>Created</th>
                <th>Version</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={8}>Loading...</td>
                </tr>
              )}
              {!loading && rows.length === 0 && (
                <tr>
                  <td colSpan={8}>No items</td>
                </tr>
              )}
              {!loading &&
                rows.map((row) => {
                  const compositeId = String(row.composite_id ?? "");
                  const contentType = String(row.content_type ?? "");
                  const itemStatus = String(row.review_status ?? status);
                  const contentHtml = String(row.content ?? "");
                  const rowRemarks = String(row.remarks ?? "").trim();
                  const resolvedRemarks = rowRemarks || "No remarks provided.";
                  const resolvedContentHtml = contentHtml.trim() ? contentHtml : "<p>No content</p>";
                  const rowKey = `${contentType}-${compositeId}`;
                  const isContentExpanded = expandedContentKey === rowKey;
                  const isRemarksExpanded = expandedRemarksKey === rowKey;

                  return (
                    <Fragment key={rowKey}>
                      <tr>
                        <td>{contentType}</td>
                        <td>{String(row.content_name ?? "-")}</td>
                        <td>{String(row.subject_id ?? "-")}</td>
                        <td>{String(row.created_by ?? "-")}</td>
                        <td>{String(row.created_at ?? "-")}</td>
                        <td>{String(row.version_no ?? "-")}</td>
                        <td>
                          <span className={`admin-status ${itemStatus.toLowerCase()}`}>{itemStatus}</span>
                        </td>
                        <td>
                          <div className="admin-row">
                            <button
                              type="button"
                              className="admin-btn secondary"
                              onClick={() => setExpandedContentKey(isContentExpanded ? null : rowKey)}
                            >
                              {isContentExpanded ? "Hide Content" : "View Content"}
                            </button>
                            {status === "DRAFT" && (
                              <>
                                <button type="button" className="admin-btn secondary" onClick={() => doApprove(row)}>
                                  Approve
                                </button>
                                <button
                                  type="button"
                                  className="admin-btn warn"
                                  onClick={() => {
                                    setRemarkModalState({ compositeId, contentType, action: "REJECT" });
                                    setRemarks("");
                                  }}
                                >
                                  Reject
                                </button>
                              </>
                            )}
                            {status === "APPROVED" && (
                              <button type="button" className="admin-btn secondary" onClick={() => doMoveToDraft(row)}>
                                Move to Draft
                              </button>
                            )}
                            {status === "REJECTED" && (
                              <>
                                <button
                                  type="button"
                                  className="admin-btn secondary"
                                  onClick={() => setExpandedRemarksKey(isRemarksExpanded ? null : rowKey)}
                                >
                                  {isRemarksExpanded ? "Hide Remarks" : "View Remarks"}
                                </button>
                                <button
                                  type="button"
                                  className="admin-btn secondary"
                                  onClick={() => {
                                    setRemarkModalState({ compositeId, contentType, action: "EDIT_REMARKS" });
                                    setRemarks(rowRemarks);
                                  }}
                                >
                                  Edit Remarks
                                </button>
                              </>
                            )}
                          </div>
                        </td>
                      </tr>
                      {isContentExpanded && (
                        <tr>
                          <td colSpan={8}>
                            <div
                              style={{
                                border: "1px solid #dbe3f1",
                                borderRadius: 8,
                                padding: "0.75rem",
                                background: "#fcfdff",
                              }}
                              dangerouslySetInnerHTML={{ __html: resolvedContentHtml }}
                            />
                          </td>
                        </tr>
                      )}
                      {isRemarksExpanded && (
                        <tr>
                          <td colSpan={8}>
                            <div
                              style={{
                                border: "1px solid #f1d9d9",
                                borderRadius: 8,
                                padding: "0.75rem",
                                background: "#fffafa",
                                whiteSpace: "pre-wrap",
                              }}
                            >
                              <strong>Rejection Remarks</strong>
                              <p style={{ margin: "0.55rem 0 0", lineHeight: 1.45 }}>{resolvedRemarks}</p>
                            </div>
                          </td>
                        </tr>
                      )}
                    </Fragment>
                  );
                })}
            </tbody>
          </table>
        </div>
      </section>

      {remarkModalState && (
        <div className="admin-modal-backdrop" role="dialog" aria-modal="true">
          <div className="admin-modal" style={{ maxWidth: 560 }}>
            <h3>{remarkModalState.action === "EDIT_REMARKS" ? "Edit Rejection Remarks" : "Reject Content"}</h3>
            <p>
              {remarkModalState.contentType} ({remarkModalState.compositeId})
            </p>
            <label style={{ display: "block", marginTop: "0.7rem" }}>
              Remarks
              <CodeEditor
                value={remarks}
                onChange={setRemarks}
                placeholder="Enter rejection reason..."
                plainText
              />
            </label>

            <div className="admin-row" style={{ marginTop: "0.9rem" }}>
              <button
                type="button"
                className={remarkModalState.action === "EDIT_REMARKS" ? "admin-btn secondary" : "admin-btn warn"}
                onClick={doSubmitRemarks}
              >
                {remarkModalState.action === "EDIT_REMARKS" ? "Save Remarks" : "Confirm Reject"}
              </button>
              <button type="button" className="admin-btn secondary" onClick={() => setRemarkModalState(null)}>
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
