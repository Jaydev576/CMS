import { Link, useLocation, useParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { fetchContentHierarchy } from "../../api/content";
import { findTreeNodeById, type TreeNode } from "../../models/contentTree";
import "../../App.css";
import "../../pages/Creator/CreatorStyles.css";

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

function sortSiblings(nodes: TreeNode[]): TreeNode[] {
  const sorted = [...nodes];
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

function buildNodeNumberMap(nodes: TreeNode[]): Map<string, string> {
  const numberMap = new Map<string, string>();

  const walk = (siblings: TreeNode[], parentNumbers: number[]) => {
    sortSiblings(siblings).forEach((node, index) => {
      const nodeOrder = parseDisplayOrder(node) ?? (index + 1);
      const numberPath = [...parentNumbers, nodeOrder];
      numberMap.set(node.id, numberPath.join("."));
      walk(node.children ?? [], numberPath);
    });
  };

  walk(nodes, []);
  return numberMap;
}

export default function ChapterDetailPage() {
  const { subjectId, chapterId } = useParams();
  const location = useLocation();

  const { data: nodes = [], isLoading, error } = useQuery<TreeNode[]>({
    queryKey: ["contentHierarchy", subjectId],
    queryFn: () => fetchContentHierarchy(subjectId!),
    enabled: !!subjectId,
  });

  if (isLoading) {
    return <div className="main-content">Loading content...</div>;
  }

  if (error) {
    return <div className="main-content">Failed to load content.</div>;
  }

  const searchParams = new URLSearchParams(location.search);
  const selectedNodeId = searchParams.get("node");

  const selectedNode = selectedNodeId
    ? findTreeNodeById(nodes, selectedNodeId)
    : nodes.find((node) => node.path[0] === Number(chapterId)) ?? null;
  const nodeNumberMap = buildNodeNumberMap(nodes);
  const selectedNodeNumber = selectedNode ? (nodeNumberMap.get(selectedNode.id) ?? null) : null;

  if (!selectedNode) {
    return <div className="main-content">Content not found.</div>;
  }

  return (
    <div className="main-content creator-layout">
      <div className="subject-container animate-fade-in creator-editor-container" style={{ flex: 1, minHeight: 0 }}>
        <div className="content-editor">
          <div className="editor-panel">
            <div className="editor-header">
              {selectedNodeNumber ? (
                <span className="editor-hierarchy-number">{selectedNodeNumber}</span>
              ) : null}
              <div className="editor-title-block">
                <h2 className="editor-title-display">{selectedNode.name}</h2>
              </div>
            </div>

            <div className="editor-form" style={{ overflowY: "auto", cursor: "default" }}>
              <div style={{ whiteSpace: "pre-line", fontSize: "1.05rem", color: "var(--text-primary)", lineHeight: "1.7" }}>
                {selectedNode.content?.trim() || "No content available yet for this section."}
              </div>

              {selectedNode.type === "chapter" && (
                <div style={{ marginTop: "1.5rem" }}>
                  <Link to={`/subjects/${subjectId}/simulations`}>
                    Open interactive simulations
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
