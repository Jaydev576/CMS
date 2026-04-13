import React, { useState, useEffect } from 'react';
import type { CreateDraft, TreeNode } from '../../models/contentTree';
import CodeEditor from '../CodeEditor';

interface SaveTarget {
  mode: 'create' | 'update';
  nodeId?: string;
  draft?: CreateDraft;
}

interface ContentEditorProps {
  node: TreeNode | null;
  draft: CreateDraft | null;
  hierarchyNumber: string | null;
  draftHierarchyNumber: string | null;
  subjectId: number;
  onSaved: (saveTarget: SaveTarget) => void | Promise<void>;
}

const ContentEditor: React.FC<ContentEditorProps> = ({
  node,
  draft,
  hierarchyNumber,
  draftHierarchyNumber,
  subjectId,
  onSaved,
}) => {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  useEffect(() => {
    if (node) {
      setTitle(node.name);
      setContent(node.content || '');
      setMessage(null);
      return;
    }

    if (draft) {
      setTitle('');
      setContent('');
      setMessage(null);
    }
  }, [node, draft]);

  const currentMode = draft ? 'create' : 'update';
  const editorNodeType = draft?.nodeType ?? node?.type ?? null;
  const headerNumber = draft ? draftHierarchyNumber : hierarchyNumber;
  const rawReviewStatus = node
    ? (((node as unknown as { reviewStatus?: unknown; review_status?: unknown }).reviewStatus ??
        (node as unknown as { reviewStatus?: unknown; review_status?: unknown }).review_status) as unknown)
    : null;
  const reviewStatus =
    typeof rawReviewStatus === 'string' && rawReviewStatus.trim()
      ? rawReviewStatus.trim()
      : node
        ? 'Draft'
        : null;
  const normalizedStatus = reviewStatus ? reviewStatus.toLowerCase() : null;
  const statusLabel =
    normalizedStatus === 'published' || normalizedStatus === 'approved'
      ? 'Approved'
      : normalizedStatus === 'rejected'
        ? 'Rejected'
        : normalizedStatus
          ? 'Draft'
          : null;
  const rawRemarks = node
    ? (((node as unknown as { rejectionRemarks?: unknown; rejection_remarks?: unknown }).rejectionRemarks ??
        (node as unknown as { rejectionRemarks?: unknown; rejection_remarks?: unknown }).rejection_remarks) as unknown)
    : null;
  const rejectionRemarks = typeof rawRemarks === 'string' && rawRemarks.trim() ? rawRemarks.trim() : null;

  const getDraftHeading = (currentDraft: CreateDraft) => {
    if (currentDraft.nodeType === 'chapter') {
      return 'New Chapter';
    }

    return currentDraft.level === 1 ? 'New Topic' : 'New Subtopic';
  };

  const getDraftDescription = (currentDraft: CreateDraft) => {
    if (currentDraft.insertionHint && currentDraft.targetDisplayOrder) {
      const parentMessage = currentDraft.parentName ? ` within "${currentDraft.parentName}"` : '';
      return `${currentDraft.insertionHint}${parentMessage} at position ${currentDraft.targetDisplayOrder}.`;
    }

    if (!currentDraft.parentName) {
      return 'Fill in the title and content, then save to create this section.';
    }

    return `This will be created under "${currentDraft.parentName}".`;
  };

  const getActionLabel = () => {
    if (!draft) {
      return 'Save Changes';
    }

    if (draft.nodeType === 'chapter') {
      return 'Create Chapter';
    }

    return draft.level === 1 ? 'Create Topic' : 'Create Subtopic';
  };

  if (!node && !draft) {
    return (
      <div className="content-editor">
        <div className="editor-panel">
          <div className="editor-placeholder">
            <span className="editor-placeholder-icon">✏️</span>
            <h3>Select a chapter or topic</h3>
            <p>Click on an item in the content tree to view and edit its content.</p>
          </div>
        </div>
      </div>
    );
  }

  const handleSave = async () => {
    if (!title.trim()) {
      setMessage('Error: Title is required');
      return;
    }

    setSaving(true);
    setMessage(null);
    try {
      const requestedDisplayOrder =
        typeof draft?.targetDisplayOrder === "number" && Number.isFinite(draft.targetDisplayOrder)
          ? Math.max(1, Math.trunc(draft.targetDisplayOrder))
          : null;
      const body = {
        operation: currentMode,
        subjectId,
        nodeType: editorNodeType,
        title,
        content,
        ...(draft?.parentPath ? { parentPath: draft.parentPath } : {}),
        ...(requestedDisplayOrder !== null
          ? {
              displayOrder: requestedDisplayOrder,
              display_order: requestedDisplayOrder,
              targetDisplayOrder: requestedDisplayOrder,
            }
          : {}),
        ...(node ? { path: node.path } : {}),
      };

      const res = await fetch('/wls/api/creator/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify(body),
      });

      const data = await res.json();
      if (data.status === 'success') {
        setMessage(currentMode === 'create' ? 'Created successfully!' : 'Saved successfully!');
        await onSaved(
          currentMode === 'create'
            ? { mode: 'create', draft: draft ?? undefined }
            : { mode: 'update', nodeId: node?.id },
        );
      } else {
        setMessage(`Error: ${data.error || 'Unknown error'}`);
      }
    } catch (err: unknown) {
      setMessage(`Error: ${err instanceof Error ? err.message : 'Network error'}`);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="content-editor">
      <div className="editor-panel">
        <div className="editor-header">
          {headerNumber ? <span className="editor-hierarchy-number">{headerNumber}</span> : null}
          <div className="editor-title-block">
            <h3 className="editor-title-display">
              {draft ? getDraftHeading(draft) : title || 'Untitled'}
            </h3>
            {draft ? <p className="editor-title-helper">{getDraftDescription(draft)}</p> : null}
            {!draft && statusLabel ? (
              <div className="editor-review-meta">
                <span className={`editor-review-status editor-review-status-${normalizedStatus === 'published' || normalizedStatus === 'approved' ? 'approved' : normalizedStatus === 'rejected' ? 'rejected' : 'draft'}`}>
                  {statusLabel}
                </span>
              </div>
            ) : null}
          </div>
        </div>

        <div className="editor-form">
          {!draft && normalizedStatus === 'rejected' && (
            <div className="editor-review-remarks">
              <strong>Reviewer Remark</strong>
              <p>{rejectionRemarks ?? 'No remark was provided for this rejection.'}</p>
            </div>
          )}

          <div className="editor-field">
            <label htmlFor="node-title">Title</label>
            <input
              id="node-title"
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="Enter title..."
            />
          </div>

          <div className="editor-field editor-field-grow">
            <label htmlFor="node-content">Content</label>
            <CodeEditor
              value={content}
              onChange={setContent}
              placeholder="Enter content for this section..."
              plainText
            />
          </div>
        </div>
      </div>

      <div className="editor-actions">
        <button className="btn-primary editor-save-btn" onClick={handleSave} disabled={saving}>
          {saving
            ? currentMode === 'create'
              ? 'Creating...'
              : 'Saving...'
            : getActionLabel()}
        </button>
        {message && (
          <span className={`editor-message ${message.startsWith('Error') ? 'editor-message-error' : 'editor-message-success'}`}>
            {message}
          </span>
        )}
      </div>
    </div>
  );
};

export default ContentEditor;
