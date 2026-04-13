import { ApiError } from "./auth";
import type { MediaContentType, MediaItem } from "../models/media";

type MediaApiResponse = {
  status?: string;
  message?: string;
  items?: unknown;
};

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null;

const readString = (value: unknown): string =>
  typeof value === "string" ? value : "";

const readNumberOrNull = (value: unknown): number | null => {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  return null;
};

const normalizeContentType = (value: unknown): MediaContentType | string => {
  const type = readString(value).toUpperCase();
  if (type === "AUDIO" || type === "VIDEO" || type === "SIMULATION" || type === "PROGRAM" || type === "IMAGE") {
    return type;
  }
  return type || "PROGRAM";
};

const parseMediaItem = (value: unknown): MediaItem | null => {
  if (!isRecord(value)) {
    return null;
  }

  const idRaw = value.id;
  const parsedId = typeof idRaw === "number" ? idRaw : Number(idRaw);
  if (!Number.isFinite(parsedId)) {
    return null;
  }

  return {
    id: parsedId,
    title: readString(value.title),
    contentType: normalizeContentType(value.contentType),
    resourceUrl: readString(value.resourceUrl),
    createdBy: readNumberOrNull(value.createdBy),
    createdAt: typeof value.createdAt === "string" ? value.createdAt : null,
  };
};

export const fetchMediaItems = async (): Promise<MediaItem[]> => {
  const res = await fetch("/wls/api/LearningContentServlet", {
    method: "GET",
    credentials: "include",
  });

  if (!res.ok) {
    throw new ApiError("Failed to fetch media content", res.status);
  }

  const data = (await res.json()) as MediaApiResponse;

  if (data.status !== "success") {
    throw new ApiError(data.message ?? "Failed to fetch media content", 400);
  }

  if (!Array.isArray(data.items)) {
    return [];
  }

  return data.items
    .map((item) => parseMediaItem(item))
    .filter((item): item is MediaItem => item !== null && item.resourceUrl.trim().length > 0);
};
