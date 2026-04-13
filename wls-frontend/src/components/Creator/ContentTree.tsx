import React, { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import type { TreeNode } from '../../models/contentTree';

interface ContentTreeProps {
  nodes: TreeNode[];
  selectedId: string | null;
  onSelect: (node: TreeNode) => void;
  onAddSibling: (referenceNode: TreeNode, position: 'above' | 'below', fallbackDisplayOrder: number) => void;
  onDeleteNode: (node: TreeNode) => void;
}

const ContentTree: React.FC<ContentTreeProps> = ({
  nodes,
  selectedId,
  onSelect,
  onAddSibling,
  onDeleteNode,
}) => {
  const parseDisplayOrder = (node: TreeNode): number | null => {
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
  };

  const getNodeTailId = (node: TreeNode): number => {
    if (!Array.isArray(node.path) || node.path.length === 0) {
      return Number.MAX_SAFE_INTEGER;
    }
    const tail = node.path[node.path.length - 1];
    return typeof tail === "number" && Number.isFinite(tail) ? tail : Number.MAX_SAFE_INTEGER;
  };

  const sortSiblings = (siblingNodes: TreeNode[]): TreeNode[] => {
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
  };

  const getDeleteTitle = (node: TreeNode) => (node.type === 'chapter' ? 'Delete Chapter' : 'Delete Item');

  const getNodeStatus = (node: TreeNode): "published" | "rejected" | "draft" => {
    const rawNode = node as unknown as { reviewStatus?: unknown; review_status?: unknown };
    const rawValue = rawNode.reviewStatus ?? rawNode.review_status;
    const normalized =
      typeof rawValue === 'string' && rawValue.trim()
        ? rawValue.trim().toLowerCase()
        : 'draft';

    if (normalized === 'published' || normalized === 'approved') {
      return 'published';
    }
    if (normalized === 'rejected') {
      return 'rejected';
    }
    return 'draft';
  };

  const getStatusLabel = (status: "published" | "rejected" | "draft") => {
    if (status === 'published') return 'Approved';
    if (status === 'rejected') return 'Rejected';
    return 'Draft';
  };

  const [expandedNodeIds, setExpandedNodeIds] = useState<Set<string>>(new Set());
  const [openMenu, setOpenMenu] = useState<{
    node: TreeNode;
    fallbackDisplayOrder: number;
    top: number;
    left: number;
  } | null>(null);

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

    collectExpandableNodes(nodes);
    setExpandedNodeIds(nextExpandedNodeIds);
  }, [nodes]);

  useEffect(() => {
    const closeMenu = () => setOpenMenu(null);
    document.addEventListener('click', closeMenu);
    window.addEventListener('resize', closeMenu);
    window.addEventListener('scroll', closeMenu, true);
    return () => {
      document.removeEventListener('click', closeMenu);
      window.removeEventListener('resize', closeMenu);
      window.removeEventListener('scroll', closeMenu, true);
    };
  }, []);

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

  const renderNode = (
    node: TreeNode,
    depth: number,
    siblingIndex: number,
    parentNumberPath: number[],
  ) => {
    const isSelected = selectedId === node.id;
    const hasChildren = node.children.length > 0;
    const isExpanded = hasChildren && expandedNodeIds.has(node.id);
    const isChapter = node.type === 'chapter';
    const nodeDisplayOrder = parseDisplayOrder(node) ?? (siblingIndex + 1);
    const fallbackDisplayOrder = nodeDisplayOrder;
    const numberPath = [...parentNumberPath, nodeDisplayOrder];
    const hierarchyNumber = numberPath.join('.');
    const nodeStatus = getNodeStatus(node);
    const isMenuOpen = openMenu?.node.id === node.id;

    return (
      <div
        key={node.id}
        className={`tree-item ${isChapter ? 'tree-item-chapter' : 'tree-item-topic'} tree-item-depth-${Math.min(depth, 4)}`}
      >
        <div
          className={`tree-node ${isChapter ? 'tree-node-chapter' : 'tree-node-topic'} ${isSelected ? 'tree-node-selected' : ''}`}
          onClick={() => onSelect(node)}
          role="button"
          tabIndex={0}
          onKeyDown={(e) => e.key === 'Enter' && onSelect(node)}
        >
          {hasChildren ? (
            <button
              type="button"
              className={`tree-node-toggle ${isExpanded ? 'tree-node-toggle-open' : ''}`}
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
            <span className="tree-node-toggle-spacer" aria-hidden="true" />
          )}
          <span className="tree-node-text">
            <span className="tree-node-name">
              <span className="tree-node-number">{hierarchyNumber}</span>
              <span className="tree-node-title-wrap">
                <span className="tree-node-title">{node.name}</span>
                <span className="tree-node-tooltip" role="tooltip">
                  {node.name}
                </span>
              </span>
              <span className={`tree-node-status tree-node-status-${nodeStatus}`}>
                {getStatusLabel(nodeStatus)}
              </span>
            </span>
          </span>
          <span className="tree-node-actions">
            <button
              type="button"
              className={`tree-node-menu-trigger ${isMenuOpen ? 'tree-node-menu-trigger-open' : ''}`}
              title="Open options"
              aria-label="Open options"
              aria-haspopup="menu"
              aria-expanded={isMenuOpen}
              onClick={(e) => {
                e.stopPropagation();
                const triggerRect = (e.currentTarget as HTMLButtonElement).getBoundingClientRect();
                setOpenMenu((currentMenu) => {
                  if (currentMenu?.node.id === node.id) {
                    return null;
                  }
                  return {
                    node,
                    fallbackDisplayOrder,
                    top: triggerRect.bottom + 6,
                    left: triggerRect.right,
                  };
                });
              }}
            >
              ⋯
            </button>
          </span>
        </div>
        {isExpanded && (
          <div className={`tree-children ${isChapter ? 'tree-children-chapter' : 'tree-children-topic'}`}>
            {sortSiblings(node.children).map((child, index) => renderNode(child, depth + 1, index, numberPath))}
          </div>
        )}
      </div>
    );
  };

  return (
    <>
      <div className="content-tree">
        <div className="content-tree-header">
          <h3>Content Structure</h3>
        </div>
        <div className="content-tree-body">
          {nodes.length === 0 && (
            <div className="tree-empty">No content yet.</div>
          )}
          {sortSiblings(nodes).map((node, index) => renderNode(node, 0, index, []))}
        </div>
      </div>
      {openMenu
        ? createPortal(
            <div
              className="tree-node-menu tree-node-menu-floating"
              role="menu"
              style={{ top: openMenu.top, left: openMenu.left }}
              onClick={(e) => e.stopPropagation()}
            >
              <button
                type="button"
                className="tree-node-menu-item"
                role="menuitem"
                onClick={(e) => {
                  e.stopPropagation();
                  onAddSibling(openMenu.node, 'above', openMenu.fallbackDisplayOrder);
                  setOpenMenu(null);
                }}
              >
                Create Above
              </button>
              <button
                type="button"
                className="tree-node-menu-item"
                role="menuitem"
                onClick={(e) => {
                  e.stopPropagation();
                  onAddSibling(openMenu.node, 'below', openMenu.fallbackDisplayOrder);
                  setOpenMenu(null);
                }}
              >
                Create Below
              </button>
              <button
                type="button"
                className="tree-node-menu-item tree-node-menu-item-delete"
                role="menuitem"
                title={getDeleteTitle(openMenu.node)}
                onClick={(e) => {
                  e.stopPropagation();
                  onDeleteNode(openMenu.node);
                  setOpenMenu(null);
                }}
              >
                {openMenu.node.type === 'chapter' ? 'Delete Chapter' : 'Delete Item'}
              </button>
            </div>,
            document.body,
          )
        : null}
    </>
  );
};

export default ContentTree;
