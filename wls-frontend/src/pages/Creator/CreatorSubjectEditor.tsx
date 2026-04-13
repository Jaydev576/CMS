import React, { useEffect, useState, useCallback, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/useAuth";
import ContentTree from "../../components/Creator/ContentTree";
import ContentEditor from "../../components/Creator/ContentEditor";
import { fetchCreatorHierarchy, fetchCreatorSubjects } from "../../api/creator";
import type { SubjectSummary } from "../../context/auth-types";
import type { CreateDraft, TreeNode } from "../../models/contentTree";
import "../../App.css";
import "./CreatorStyles.css";

function findNodeById(nodes: TreeNode[], nodeId: string | null): TreeNode | null {
  if (!nodeId) {
    return null;
  }

  for (const node of nodes) {
    if (node.id === nodeId) {
      return node;
    }

    const childMatch = findNodeById(node.children, nodeId);
    if (childMatch) {
      return childMatch;
    }
  }

  return null;
}

function parseDisplayOrder(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    const normalized = Math.trunc(value);
    return normalized > 0 ? normalized : null;
  }
  if (typeof value === "string") {
    const parsed = Number.parseInt(value.trim(), 10);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : null;
  }
  return null;
}

function getPathTailId(node: TreeNode): number {
  if (!Array.isArray(node.path) || node.path.length === 0) {
    return Number.MAX_SAFE_INTEGER;
  }
  const tail = node.path[node.path.length - 1];
  return typeof tail === "number" && Number.isFinite(tail) ? tail : Number.MAX_SAFE_INTEGER;
}

function sortTreeByDisplayOrder(nodes: TreeNode[]): TreeNode[] {
  const sortedNodes = nodes.map((node) => ({
    ...node,
    children: sortTreeByDisplayOrder(node.children ?? []),
  }));

  sortedNodes.sort((left, right) => {
    const leftDisplayOrder = parseDisplayOrder(left.displayOrder);
    const rightDisplayOrder = parseDisplayOrder(right.displayOrder);
    const leftKey = leftDisplayOrder ?? getPathTailId(left);
    const rightKey = rightDisplayOrder ?? getPathTailId(right);
    if (leftKey !== rightKey) {
      return leftKey - rightKey;
    }
    return getPathTailId(left) - getPathTailId(right);
  });

  return sortedNodes;
}

function pathsMatch(left: number[] | null, right: number[]): boolean {
  if (!left || left.length !== right.length) {
    return false;
  }

  return left.every((value, index) => value === right[index]);
}

function findNodeByPath(nodes: TreeNode[], path: number[]): TreeNode | null {
  for (const node of nodes) {
    if (pathsMatch(path, node.path)) {
      return node;
    }

    const childMatch = findNodeByPath(node.children, path);
    if (childMatch) {
      return childMatch;
    }
  }

  return null;
}

function findNewestCreatedNode(nodes: TreeNode[], draft: CreateDraft): TreeNode | null {
  if (draft.nodeType === "chapter") {
    return [...nodes].sort((left, right) => right.path[0] - left.path[0])[0] ?? null;
  }

  if (!draft.parentPath) {
    return null;
  }

  const parentNode = findNodeByPath(nodes, draft.parentPath);
  if (!parentNode) {
    return null;
  }

  const matchingChildren = parentNode.children
    .filter((child) => child.type === draft.nodeType)
    .sort((left, right) => right.path[right.path.length - 1] - left.path[left.path.length - 1]);

  return matchingChildren[0] ?? null;
}

function buildNodeNumberMap(nodes: TreeNode[]): Map<string, string> {
  const numberMap = new Map<string, string>();

  const walk = (siblings: TreeNode[], parentNumbers: number[]) => {
    siblings.forEach((node, index) => {
      const nodeDisplayOrder = parseDisplayOrder(node.displayOrder) ?? (index + 1);
      const numberParts = [...parentNumbers, nodeDisplayOrder];
      numberMap.set(node.id, numberParts.join("."));
      walk(node.children ?? [], numberParts);
    });
  };

  walk(nodes, []);
  return numberMap;
}

interface SaveTarget {
  mode: "create" | "update";
  nodeId?: string;
  draft?: CreateDraft;
}

const CreatorSubjectEditor: React.FC = () => {
  const { subjectId } = useParams<{ subjectId: string }>();
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [nodes, setNodes] = useState<TreeNode[]>([]);
  const [selectedNode, setSelectedNode] = useState<TreeNode | null>(null);
  const [createDraft, setCreateDraft] = useState<CreateDraft | null>(null);
  const [subjects, setSubjects] = useState<SubjectSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false);

  const subjectIdNum = parseInt(subjectId || "0", 10);
  const nodeNumberMap = useMemo(() => buildNodeNumberMap(nodes), [nodes]);
  const selectedNodeNumber = selectedNode ? (nodeNumberMap.get(selectedNode.id) ?? null) : null;
  const draftNodeNumber = useMemo(() => {
    if (!createDraft || !createDraft.targetDisplayOrder) {
      return null;
    }

    const normalizedTargetDisplayOrder = Math.max(1, Math.trunc(createDraft.targetDisplayOrder));

    if (createDraft.nodeType === "chapter") {
      return String(normalizedTargetDisplayOrder);
    }

    if (!createDraft.parentPath) {
      return String(normalizedTargetDisplayOrder);
    }

    const parentNode = findNodeByPath(nodes, createDraft.parentPath);
    if (!parentNode) {
      return String(normalizedTargetDisplayOrder);
    }

    const parentNodeNumber = nodeNumberMap.get(parentNode.id);
    if (!parentNodeNumber) {
      return String(normalizedTargetDisplayOrder);
    }

    return `${parentNodeNumber}.${normalizedTargetDisplayOrder}`;
  }, [createDraft, nodes, nodeNumberMap]);

  const fetchHierarchy = useCallback(async (saveTarget?: SaveTarget) => {
    setLoading(true);
    setError(null);

    try {
      const data = await fetchCreatorHierarchy(subjectIdNum);
      const sortedData = sortTreeByDisplayOrder(data);
      setNodes(sortedData);

      if (saveTarget?.mode === "create" && saveTarget.draft) {
        setSelectedNode(findNewestCreatedNode(sortedData, saveTarget.draft));
        setCreateDraft(null);
      } else if (saveTarget?.mode === "update" && saveTarget.nodeId) {
        setSelectedNode(findNodeById(sortedData, saveTarget.nodeId));
      } else {
        setSelectedNode((currentSelectedNode) => findNodeById(sortedData, currentSelectedNode?.id ?? null));
      }
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "Unknown error");
    } finally {
      setLoading(false);
    }
  }, [subjectIdNum]);

  useEffect(() => {
    fetchHierarchy();
  }, [fetchHierarchy]);

  useEffect(() => {
    if (!user?.userId) {
      return;
    }

    fetchCreatorSubjects(user.userId)
      .then(setSubjects)
      .catch(() => {
        setSubjects([]);
      });
  }, [user]);

  const handleAddSibling = (
    referenceNode: TreeNode,
    position: "above" | "below",
    fallbackDisplayOrder: number,
  ) => {
    const parentNodePath = referenceNode.level === 0 ? null : referenceNode.path.slice(0, -1);
    const parentNode = parentNodePath ? findNodeByPath(nodes, parentNodePath) : null;
    const parsedDisplayOrder =
      typeof referenceNode.displayOrder === "number" && Number.isFinite(referenceNode.displayOrder)
        ? Math.trunc(referenceNode.displayOrder)
        : null;
    const baseDisplayOrder =
      parsedDisplayOrder !== null && parsedDisplayOrder > 0 ? parsedDisplayOrder : fallbackDisplayOrder;
    const targetDisplayOrder = Math.max(1, position === "above" ? baseDisplayOrder : baseDisplayOrder + 1);

    setSelectedNode(null);
    setCreateDraft({
      nodeType: referenceNode.type,
      level: referenceNode.level,
      parentPath: parentNodePath,
      parentName: parentNode?.name ?? null,
      targetDisplayOrder,
      insertionHint: `Insert ${position} "${referenceNode.name}"`,
    });
    setIsSidebarOpen(false);
  };

  const handleDeleteNode = async (node: TreeNode) => {
    const nodeLabel =
      node.type === "chapter" ? "chapter" : node.level === 1 ? "topic" : "subtopic";
    const confirmed = window.confirm(
      `Delete this ${nodeLabel} and all nested content under "${node.name}"? This cannot be undone.`,
    );

    if (!confirmed) {
      return;
    }

    try {
      const res = await fetch("/wls/api/creator/save", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({
          operation: "delete",
          subjectId: subjectIdNum,
          nodeType: node.type,
          path: node.path,
        }),
      });
      const data = await res.json();
      if (data.status === "success") {
        fetchHierarchy();
      } else {
        alert("Error deleting item: " + (data.error || "Unknown error"));
      }
    } catch {
      alert("Network error deleting item");
    }
  };

  const subjectName =
    subjects.find((subject) => subject.subject_id === subjectIdNum)?.subject_name ||
    user?.subjects?.find((subject) => subject.subject_id === subjectIdNum)?.subject_name ||
    `Subject #${subjectIdNum}`;

  const handleLogout = async () => {
    setIsSidebarOpen(false);
    await logout();
    navigate("/");
  };

  const handleEditorSaved = async (saveTarget: SaveTarget) => {
    await fetchHierarchy(saveTarget);
  };

  if (loading) {
    return (
      <div className="creator-dashboard-shell">
        <header className="mobile-header creator-mobile-header">
          <button className="sidebar-toggle" type="button" disabled>
            Menu
          </button>
          <button className="subjects-home-btn" type="button" onClick={() => navigate("/creator/dashboard")}>
            Subjects
          </button>
        </header>
        <div className="main-content">
          <div className="creator-loading">
            <div className="loader"></div>
            <p>Loading content...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="creator-dashboard-shell">
        <header className="mobile-header creator-mobile-header">
          <button className="sidebar-toggle" type="button" disabled>
            Menu
          </button>
          <button className="subjects-home-btn" type="button" onClick={() => navigate("/creator/dashboard")}>
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
    <div className="dashboard-layout creator-layout">
      <div
        className={`sidebar-backdrop ${isSidebarOpen ? "open" : ""}`}
        onClick={() => setIsSidebarOpen(false)}
        aria-hidden="true"
      />

      <aside className={`sidebar creator-sidebar ${isSidebarOpen ? "open" : ""}`}>
        <div>
          <div className="sidebar-header">
            <h3>{subjectName}</h3>
            <button
              className="sidebar-close"
              type="button"
              onClick={() => setIsSidebarOpen(false)}
              aria-label="Close creator menu"
            >
              Close
            </button>
          </div>
          <ContentTree
            nodes={nodes}
            selectedId={selectedNode?.id ?? null}
            onSelect={(node) => {
              setSelectedNode(node);
              setCreateDraft(null);
              setIsSidebarOpen(false);
            }}
            onAddSibling={handleAddSibling}
            onDeleteNode={handleDeleteNode}
          />
        </div>

        <div className="sidebar-footer creator-sidebar-footer">
          <div className="creator-sidebar-user">
            <span className="creator-user-badge">{user?.username || "Creator"}</span>
            <p>Manage chapters and topics for this subject.</p>
          </div>
          <button className="btn-danger" onClick={handleLogout}>
            Sign Out
          </button>
        </div>
      </aside>

      <div className="layout-outlet" onClick={() => setIsSidebarOpen(false)}>
        <header className="mobile-header creator-mobile-header" onClick={(event) => event.stopPropagation()}>
          <button
            className="sidebar-toggle"
            type="button"
            onClick={() => setIsSidebarOpen(true)}
            aria-label="Open creator menu"
          >
            Menu
          </button>
          <button className="subjects-home-btn" type="button" onClick={() => navigate("/creator/dashboard")}>
            Subjects
          </button>
        </header>

        <div className="main-content creator-main-content" onClick={(event) => event.stopPropagation()}>
          <div className="subject-container creator-editor-container">
            <div className="content-detail-header creator-dashboard-header">
              <span className="content-detail-badge">Creator Workspace</span>
              <h2 className="page-title creator-editor-title">{subjectName}</h2>
              <p className="creator-dashboard-copy">
                Use the menu to browse the structure, create new chapters or subtopics, and update the selected
                section content.
              </p>
            </div>

            <ContentEditor
              node={selectedNode}
              draft={createDraft}
              hierarchyNumber={selectedNodeNumber}
              draftHierarchyNumber={draftNodeNumber}
              subjectId={subjectIdNum}
              onSaved={handleEditorSaved}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default CreatorSubjectEditor;
