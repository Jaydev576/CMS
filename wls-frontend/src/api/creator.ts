import type { SubjectSummary } from "../context/auth-types";
import type { TreeNode } from "../models/contentTree";

export interface CreatorContentStats {
  approved: number;
  rejected: number;
  draft: number;
  total: number;
}

interface CreatorSubjectsPayload {
  subjects: SubjectSummary[];
  stats: CreatorContentStats;
}

function mapSubjects(raw: unknown): SubjectSummary[] {
  if (!Array.isArray(raw)) {
    return [];
  }

  return raw.map((subject) => {
    const value = subject as { subject_id?: unknown; subject_name?: unknown };
    return {
      subject_id: Number(value.subject_id ?? 0),
      subject_name: String(value.subject_name ?? ""),
    };
  });
}

function mapStats(raw: unknown): CreatorContentStats {
  const value = (raw ?? {}) as Record<string, unknown>;
  const approved = Number(value.approved ?? 0);
  const rejected = Number(value.rejected ?? 0);
  const draft = Number(value.draft ?? 0);
  const total = Number(value.total ?? approved + rejected + draft);
  return {
    approved: Number.isFinite(approved) ? approved : 0,
    rejected: Number.isFinite(rejected) ? rejected : 0,
    draft: Number.isFinite(draft) ? draft : 0,
    total: Number.isFinite(total) ? total : 0,
  };
}

export async function fetchCreatorOverview(userId: number): Promise<CreatorSubjectsPayload> {
  const response = await fetch(`/wls/api/creator/subjects?userId=${userId}`, {
    credentials: "include",
  });

  if (!response.ok) {
    throw new Error("Failed to fetch subjects");
  }

  const payload = (await response.json()) as unknown;

  if (Array.isArray(payload)) {
    return {
      subjects: mapSubjects(payload),
      stats: { approved: 0, rejected: 0, draft: 0, total: 0 },
    };
  }

  const objectPayload = (payload ?? {}) as Record<string, unknown>;
  return {
    subjects: mapSubjects(objectPayload.subjects),
    stats: mapStats(objectPayload.stats),
  };
}

export async function fetchCreatorSubjects(userId: number): Promise<SubjectSummary[]> {
  const overview = await fetchCreatorOverview(userId);
  return overview.subjects;
}

export async function fetchCreatorStats(userId: number): Promise<CreatorContentStats> {
  const overview = await fetchCreatorOverview(userId);
  return overview.stats;
}

export async function fetchCreatorHierarchy(subjectId: number): Promise<TreeNode[]> {
  const response = await fetch(`/wls/api/creator/hierarchy?subjectId=${subjectId}`, {
    credentials: "include",
  });

  if (!response.ok) {
    let details = "";
    try {
      const payload = await response.json();
      if (payload && typeof payload.error === "string") {
        details = payload.error;
      } else if (payload && typeof payload.message === "string") {
        details = payload.message;
      }
    } catch (_e) {
      try {
        const text = await response.text();
        details = text ? text.slice(0, 240) : "";
      } catch (_ignored) {
        details = "";
      }
    }
    const suffix = details ? `: ${details}` : "";
    throw new Error(`Failed to load content hierarchy (${response.status})${suffix}`);
  }

  return response.json();
}
