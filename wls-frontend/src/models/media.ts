export type MediaContentType =
  | "AUDIO"
  | "VIDEO"
  | "SIMULATION"
  | "PROGRAM"
  | "IMAGE";

export interface MediaItem {
  id: number;
  title: string;
  contentType: string;
  resourceUrl: string;
  createdBy: number | null;
  createdAt: string | null;
}
