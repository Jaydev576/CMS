import { useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { fetchContentHierarchy } from "../../api/content";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import { useAuth } from "../../context/useAuth";
import type { TreeNode } from "../../models/contentTree";

const EMPTY_TREE_NODES: TreeNode[] = [];

function areSetsEqual(a: Set<string>, b: Set<string>) {
  if (a.size !== b.size) {
    return false;
  }
  for (const value of a) {
    if (!b.has(value)) {
      return false;
    }
  }
  return true;
}

function parseDisplayOrder(node: TreeNode): number | null {
  const rawNode = node as unknown as { displayOrder?: unknown; display_order?: unknown };
  const value = rawNode.displayOrder ?? rawNode.display_order;
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

function getNodeTailId(node: TreeNode): number {
  if (!Array.isArray(node.path) || node.path.length === 0) {
    return Number.MAX_SAFE_INTEGER;
  }
  const tail = node.path[node.path.length - 1];
  return typeof tail === "number" && Number.isFinite(tail) ? tail : Number.MAX_SAFE_INTEGER;
}

function sortSiblings(siblingNodes: TreeNode[]): TreeNode[] {
  const sorted = [...siblingNodes];
  sorted.sort((left, right) => {
    const leftDisplayOrder = parseDisplayOrder(left);
    const rightDisplayOrder = parseDisplayOrder(right);

    if (leftDisplayOrder !== null && rightDisplayOrder !== null) {
      if (leftDisplayOrder !== rightDisplayOrder) {
        return leftDisplayOrder - rightDisplayOrder;
      }
      return getNodeTailId(left) - getNodeTailId(right);
    }

    if (leftDisplayOrder !== null) return -1;
    if (rightDisplayOrder !== null) return 1;
    return getNodeTailId(left) - getNodeTailId(right);
  });
  return sorted;
}

export default function ChapterContentTree({
  onNavigate,
}: {
  onNavigate?: () => void;
}) {
  const { subjectId, chapterId } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const { user } = useAuth();
  const [expandedNodeIds, setExpandedNodeIds] = useState<Set<string>>(new Set());

  const handleNavigate = (path: string) => {
    navigate(path);
    onNavigate?.();
  };

  const { data, isLoading, isError } = useQuery<TreeNode[]>({
    queryKey: ["contentHierarchy", subjectId],
    queryFn: () => fetchContentHierarchy(subjectId!),
    enabled: !!subjectId,
  });
  const nodes = data ?? EMPTY_TREE_NODES;
  const orderedNodes = useMemo(() => sortSiblings(nodes), [nodes]);

  useEffect(() => {
    const nextExpandedNodeIds = new Set<string>();

    const collectExpandableNodes = (treeNodes: TreeNode[]) => {
      treeNodes.forEach((treeNode) => {
        if (treeNode.children.length > 0) {
          nextExpandedNodeIds.add(treeNode.id);
          collectExpandableNodes(treeNode.children);
        }
      });
    };

    collectExpandableNodes(orderedNodes);
    setExpandedNodeIds((currentExpandedNodeIds) =>
      areSetsEqual(currentExpandedNodeIds, nextExpandedNodeIds)
        ? currentExpandedNodeIds
        : nextExpandedNodeIds,
    );
  }, [orderedNodes]);

  const activeNodeId = useMemo(() => {
    const searchParams = new URLSearchParams(location.search);
    return searchParams.get("node") ?? chapterId ?? null;
  }, [chapterId, location.search]);

  if (!subjectId) return null;

  if (isLoading) {
    return <div className="sidebar-tree-status">Loading content...</div>;
  }

  if (isError) {
    return <div className="sidebar-tree-status">Failed to load content.</div>;
  }

  const subjectName =
    user?.subjects?.find((s) => String(s.subject_id) === subjectId)?.subject_name || "Dashboard";

  const simulationsPath = `/subjects/${subjectId}/simulations`;
  const testMediaPath = `/subjects/${subjectId}/test_media`;
  const codePlaygroundPath = `/subjects/${subjectId}/code_playground`;
  const isSimulationsActive =
    location.pathname === simulationsPath ||
    location.pathname.startsWith(`${simulationsPath}/`);
  const isTestMediaActive = location.pathname === testMediaPath;
  const isCodePlaygroundActive = location.pathname === codePlaygroundPath;

  const toggleNode = (nodeId: string) => {
    setExpandedNodeIds((currentExpandedNodeIds) => {
      const nextExpandedNodeIds = new Set(currentExpandedNodeIds);

      if (nextExpandedNodeIds.has(nodeId)) {
        nextExpandedNodeIds.delete(nodeId);
      } else {
        nextExpandedNodeIds.add(nodeId);
      }

      return nextExpandedNodeIds;
    });
  };

  const openNode = (node: TreeNode) => {
    const chapterPath = `/subjects/${subjectId}/chapter/${node.path[0]}`;
    const nodePath = node.type === "chapter" ? chapterPath : `${chapterPath}?node=${node.id}`;
    handleNavigate(nodePath);
  };

  const renderNode = (
    node: TreeNode,
    depth: number,
    siblingIndex: number,
    parentNumberPath: number[],
  ) => {
    const hasChildren = node.children.length > 0;
    const isExpanded = hasChildren && expandedNodeIds.has(node.id);
    const isActive = activeNodeId === node.id;
    const isChapter = node.type === "chapter";
    const nodeDisplayOrder = parseDisplayOrder(node) ?? (siblingIndex + 1);
    const numberPath = [...parentNumberPath, nodeDisplayOrder];
    const hierarchyNumber = numberPath.join(".");

    return (
      <div
        key={node.id}
        className={`sidebar-tree-item ${isChapter ? "sidebar-tree-item-chapter" : "sidebar-tree-item-topic"} sidebar-tree-item-depth-${Math.min(depth, 4)}`}
      >
        <div
          className={`sidebar-tree-node ${isChapter ? "sidebar-tree-node-chapter" : "sidebar-tree-node-topic"} ${isActive ? "sidebar-tree-node-active" : ""}`}
          onClick={() => openNode(node)}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => e.key === "Enter" && openNode(node)}
        >
          {hasChildren ? (
            <button
              type="button"
              className={`sidebar-tree-toggle ${isExpanded ? "sidebar-tree-toggle-open" : ""}`}
              aria-label={isExpanded ? `Collapse ${node.name}` : `Expand ${node.name}`}
              aria-expanded={isExpanded}
              onClick={(e) => {
                e.stopPropagation();
                toggleNode(node.id);
              }}
            >
              &gt;
            </button>
          ) : (
            <span className="sidebar-tree-toggle-spacer" aria-hidden="true" />
          )}
          <span className="sidebar-tree-text">
            <span className="sidebar-tree-label">
              <span className="sidebar-tree-number">{hierarchyNumber}</span>
              <span className="sidebar-tree-title-wrap">
                <span className="sidebar-tree-title">{node.name}</span>
                <span className="sidebar-tree-tooltip" role="tooltip">
                  {node.name}
                </span>
              </span>
            </span>
          </span>
        </div>
        {isExpanded ? (
          <div
            className={`sidebar-tree-children ${isChapter ? "sidebar-tree-children-chapter" : ""}`}
          >
            {sortSiblings(node.children).map((child, index) =>
              renderNode(child, depth + 1, index, numberPath),
            )}
          </div>
        ) : null}
      </div>
    );
  };

  return (
    <>
      <div
        className={`nav-item ${location.pathname === `/subjects/${subjectId}` ? "active" : ""}`}
        onClick={() => handleNavigate(`/subjects/${subjectId}`)}
      >
        {subjectName} Home
      </div>

      <div
        className={`nav-item ${isSimulationsActive ? "active" : ""}`}
        onClick={() => handleNavigate(simulationsPath)}
      >
        Interactive Simulations
      </div>

      <div
        className={`nav-item ${isTestMediaActive ? "active" : ""}`}
        onClick={() => handleNavigate(testMediaPath)}
      >
        Test Media
      </div>

      <div
        className={`nav-item ${isCodePlaygroundActive ? "active" : ""}`}
        onClick={() => handleNavigate(codePlaygroundPath)}
      >
        Code Playground
      </div>

      <div className="sidebar-tree-list">
        {orderedNodes.map((node, index) => renderNode(node, 0, index, []))}
      </div>
    </>
  );
}
