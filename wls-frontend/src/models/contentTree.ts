export type TreeNodeType = "chapter" | "topic1" | "topic2" | "topic3" | "topic4" | "topic5";

export interface TreeNode {
  id: string;
  name: string;
  type: TreeNodeType;
  level: number;
  path: number[];
  content: string;
  displayOrder?: number | null;
  reviewStatus?: string | null;
  rejectionRemarks?: string | null;
  children: TreeNode[];
}

export interface CreateDraft {
  nodeType: TreeNodeType;
  level: number;
  parentPath: number[] | null;
  parentName: string | null;
  targetDisplayOrder?: number | null;
  insertionHint?: string | null;
}

export const findTreeNodeById = (
  nodes: TreeNode[],
  nodeId: string,
): TreeNode | null => {
  for (const node of nodes) {
    if (node.id === nodeId) {
      return node;
    }

    const childMatch = findTreeNodeById(node.children, nodeId);
    if (childMatch) {
      return childMatch;
    }
  }

  return null;
};
