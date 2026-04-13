import { useEffect, useMemo, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { useParams } from "react-router-dom";
import { fetchMediaItems } from "../../api/media";
import type { MediaContentType, MediaItem } from "../../models/media";
import { ApiError } from "../../api/auth";

const normalizeType = (type: string): MediaContentType | "UNKNOWN" => {
  const upper = type.toUpperCase();
  if (upper === "AUDIO" || upper === "VIDEO" || upper === "SIMULATION" || upper === "PROGRAM" || upper === "IMAGE") {
    return upper;
  }
  return "UNKNOWN";
};

const getVideoEmbedUrl = (url: string): string | null => {
  try {
    const parsed = new URL(url, window.location.origin);
    const host = parsed.hostname.toLowerCase();

    if (host.includes("youtube.com")) {
      if (parsed.pathname.startsWith("/embed/")) {
        return parsed.toString();
      }
      const videoId = parsed.searchParams.get("v");
      return videoId ? `https://www.youtube.com/embed/${videoId}` : null;
    }

    if (host === "youtu.be") {
      const videoId = parsed.pathname.replace("/", "");
      return videoId ? `https://www.youtube.com/embed/${videoId}` : null;
    }

    if (host.includes("vimeo.com")) {
      const parts = parsed.pathname.split("/").filter(Boolean);
      const videoId = parts.length > 0 ? parts[parts.length - 1] : "";
      return videoId ? `https://player.vimeo.com/video/${videoId}` : null;
    }
  } catch (_error) {
    return null;
  }

  return null;
};

function ProgramPreview({ url }: { url: string }) {
  const [content, setContent] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const controller = new AbortController();

    const loadProgram = async () => {
      setLoading(true);
      setError("");

      try {
        const response = await fetch(url, { signal: controller.signal });
        if (!response.ok) {
          throw new Error(`Unable to fetch code (${response.status})`);
        }
        const text = await response.text();
        setContent(text);
      } catch (fetchError) {
        if (fetchError instanceof Error && fetchError.name === "AbortError") {
          return;
        }
        setError("Program preview unavailable. Open the link directly.");
      } finally {
        setLoading(false);
      }
    };

    loadProgram();

    return () => {
      controller.abort();
    };
  }, [url]);

  if (loading) {
    return <p className="test-media-status">Loading program preview...</p>;
  }

  if (error) {
    return (
      <p className="test-media-status">
        {error}{" "}
        <a href={url} target="_blank" rel="noreferrer">
          Open program
        </a>
      </p>
    );
  }

  return <pre className="test-media-code">{content}</pre>;
}

function MediaPreview({ item }: { item: MediaItem }) {
  const type = normalizeType(item.contentType);

  if (type === "IMAGE") {
    return <img src={item.resourceUrl} alt={item.title} className="test-media-image" loading="lazy" />;
  }

  if (type === "AUDIO") {
    return <audio className="test-media-audio" controls src={item.resourceUrl} />;
  }

  if (type === "SIMULATION") {
    return (
      <iframe
        title={`${item.title}-simulation`}
        src={item.resourceUrl}
        className="test-media-frame test-media-frame-simulation"
        loading="lazy"
      />
    );
  }

  if (type === "VIDEO") {
    const embedUrl = getVideoEmbedUrl(item.resourceUrl);

    if (embedUrl) {
      return (
        <iframe
          title={`${item.title}-video`}
          src={embedUrl}
          className="test-media-frame test-media-frame-video"
          frameBorder={0}
          allowFullScreen
          loading="lazy"
        />
      );
    }

    return (
      <video className="test-media-video" controls>
        <source src={item.resourceUrl} />
      </video>
    );
  }

  if (type === "PROGRAM") {
    return <ProgramPreview url={item.resourceUrl} />;
  }

  return (
    <a href={item.resourceUrl} target="_blank" rel="noreferrer">
      Open Resource
    </a>
  );
}

export default function TestMediaPage() {
  const { subjectId } = useParams();
  const { data, isLoading, isFetching, isError, error, refetch } = useQuery<MediaItem[]>({
    queryKey: ["test-media", subjectId],
    queryFn: fetchMediaItems,
    enabled: Boolean(subjectId),
  });

  const sortedItems = useMemo(() => {
    const items = data ?? [];
    return [...items].sort((a, b) => b.id - a.id);
  }, [data]);

  if (!subjectId) {
    return <div className="main-content">Subject context is missing.</div>;
  }

  const errorMessage = error instanceof ApiError ? error.message : "Unable to load media content.";

  return (
    <div className="main-content">
      <div className="test-media-container animate-fade-in">
        <div className="test-media-header">
          <div>
            <h2 className="page-title">Test Media</h2>
            <p>All content below is fetched from DB links and rendered by type.</p>
          </div>
          <button
            type="button"
            className="test-media-refresh"
            onClick={() => void refetch()}
            disabled={isFetching}
          >
            {isFetching ? "Refreshing..." : "Refresh"}
          </button>
        </div>

        {isLoading ? <p className="test-media-status">Loading media...</p> : null}
        {isError ? <p className="test-media-error">{errorMessage}</p> : null}

        {!isLoading && !isError && sortedItems.length === 0 ? (
          <p className="test-media-status">No media records found in DB.</p>
        ) : null}

        <div className="test-media-grid">
          {sortedItems.map((item) => (
            <article key={item.id} className="test-media-card">
              <h3>{item.title || "Untitled"}</h3>
              <p>
                <strong>Type:</strong> {normalizeType(item.contentType)}
              </p>
              <p>
                <strong>Link:</strong>{" "}
                <a href={item.resourceUrl} target="_blank" rel="noreferrer">
                  {item.resourceUrl}
                </a>
              </p>
              <div className="test-media-preview">
                <MediaPreview item={item} />
              </div>
            </article>
          ))}
        </div>
      </div>
    </div>
  );
}
