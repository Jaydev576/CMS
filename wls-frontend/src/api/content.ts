// api/content.ts
import type { Chapter } from "../models/chapters";
import type { TreeNode } from "../models/contentTree";
import { ApiError } from "./auth";

export const fetchChapters = async (subjectId: string): Promise<Chapter[]> => {
  const res = await fetch(`/wls/api/GetChaptersServlet?subjectId=${subjectId}`, {
    credentials: "include",
  });
  if (!res.ok) {
    throw new ApiError("Failed to fetch chapters", res.status);
  }

  const data = await res.json();
  if (data.status !== "success") {
    throw new ApiError(
      "Failed to fetch chapters: " + (data.message ?? "Unknown error"),
      400,
    );
  }
  return data.chapters;
};

export const fetchContentHierarchy = async (subjectId: string): Promise<TreeNode[]> => {
  const res = await fetch(`/wls/api/creator/hierarchy?subjectId=${subjectId}`, {
    credentials: "include",
  });

  if (!res.ok) {
    throw new ApiError("Failed to fetch content hierarchy", res.status);
  }

  return res.json();
};
