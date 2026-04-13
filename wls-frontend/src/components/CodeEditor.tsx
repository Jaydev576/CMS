import { useEffect, useRef, useState } from "react";
import { EditorView, basicSetup } from "codemirror";
import { EditorState, type Extension } from "@codemirror/state";
import { java } from "@codemirror/lang-java";
import { python } from "@codemirror/lang-python";
import { cpp } from "@codemirror/lang-cpp";
import { javascript } from "@codemirror/lang-javascript";
import "./CodeEditor.css";

// ── Types ────────────────────────────────────────────────────────────────

interface Language {
    id: number;
    label: string;
    extension: Extension;
}

interface ExecutionResult {
    stdout?: string;
    stderr?: string;
    compile_output?: string;
    message?: string;
    /** Judge0 CE returns status as a nested object: { id, description } */
    status?: { id: number; description: string };
    time?: string;
    memory?: number;
    error?: string;
}

interface CodeEditorProps {
    /** Uncontrolled starting value (used when no `value` prop is provided) */
    initialCode?: string;
    initialLanguageId?: number;
    /** Controlled value – when provided the editor syncs with this string */
    value?: string;
    /** Called with the full document string on every change */
    onChange?: (value: string) => void;
    /** Placeholder shown when the editor is empty */
    placeholder?: string;
    /** Hide the language selector + run toolbar (useful for code areas with no execution) */
    hideToolbar?: boolean;
    /** Override the display language without showing the selector */
    language?: "java" | "python" | "cpp" | "c" | "javascript";
    /**
     * Render as a plain-text textarea — no syntax highlighting, no dark theme.
     * Use this for any field that holds free-text (remarks, IDs, notes, etc.).
     * `hideToolbar` and `language` are ignored when this is true.
     */
    plainText?: boolean;
}

// ── Constants ────────────────────────────────────────────────────────────

const LANGUAGES: Language[] = [
    { id: 62, label: "Java", extension: java() },
    { id: 71, label: "Python", extension: python() },
    { id: 54, label: "C++", extension: cpp() },
    { id: 50, label: "C", extension: cpp() },
    { id: 63, label: "JavaScript", extension: javascript() },
];

/** UTF-8 safe Base64 encoding for Judge0 */
const encodeBase64 = (str: string) => {
    if (!str) return "";
    const bytes = new TextEncoder().encode(str);
    let binString = "";
    for (let i = 0; i < bytes.byteLength; i++) {
        binString += String.fromCharCode(bytes[i]);
    }
    return btoa(binString);
};

/** UTF-8 safe Base64 decoding for Judge0 results */
const decodeBase64 = (str?: string | null): string | undefined => {
    if (!str) return undefined;
    try {
        const binString = atob(str.trim());
        const bytes = Uint8Array.from(binString, (c) => c.charCodeAt(0));
        return new TextDecoder().decode(bytes);
    } catch (e) {
        console.error("Base64 decode error:", e);
        return str; // Fallback to original if not base64
    }
};

const STATUS_STYLES: Record<number, { label: string; color: string }> = {
    3: { label: "Accepted", color: "#4ade80" },
    4: { label: "Wrong Answer", color: "#f87171" },
    5: { label: "Time Limit", color: "#fb923c" },
    6: { label: "Compile Error", color: "#fb923c" },
    11: { label: "Runtime Error", color: "#f87171" },
    13: { label: "Internal Error", color: "#f87171" },
};

// ── Component ────────────────────────────────────────────────────────────

export default function CodeEditor({
    initialCode = "",
    initialLanguageId = 62,
    value,
    onChange,
    placeholder,
    hideToolbar = false,
    language,
    plainText = false,
}: CodeEditorProps) {

    // ── Plain-text fast path — skip all CodeMirror setup ──
    if (plainText) {
        return (
            <textarea
                className="ce-plain-textarea"
                value={value ?? initialCode}
                onChange={(e) => onChange?.(e.target.value)}
                placeholder={placeholder}
                spellCheck={false}
            />
        );
    }

    const editorContainerRef = useRef<HTMLDivElement>(null);
    const viewRef = useRef<EditorView | null>(null);
    // Track whether we're in controlled mode
    const isControlled = value !== undefined;
    const onChangeRef = useRef(onChange);
    onChangeRef.current = onChange;

    const [selectedLang, setSelectedLang] = useState<Language>(() => {
        if (language) {
            const langMap: Record<string, number> = {
                java: 62, python: 71, cpp: 54, c: 50, javascript: 63,
            };
            return LANGUAGES.find(l => l.id === langMap[language]) ?? LANGUAGES[0];
        }
        return LANGUAGES.find(l => l.id === initialLanguageId) ?? LANGUAGES[0];
    });
    const [stdin, setStdin] = useState<string>("");
    const [output, setOutput] = useState<ExecutionResult | null>(null);
    const [running, setRunning] = useState<boolean>(false);
    const [showStdin, setShowStdin] = useState<boolean>(false);

    // ── Build/rebuild editor when language changes ──
    useEffect(() => {
        if (!editorContainerRef.current) return;

        // Prefer controlled value, then preserved code, then initialCode
        const currentCode = isControlled
            ? (value ?? "")
            : (viewRef.current ? viewRef.current.state.doc.toString() : initialCode);

        viewRef.current?.destroy();

        // Listener extension for controlled / onChange mode
        const updateListener = EditorView.updateListener.of((update) => {
            if (update.docChanged && onChangeRef.current) {
                onChangeRef.current(update.state.doc.toString());
            }
        });

        viewRef.current = new EditorView({
            state: EditorState.create({
                doc: currentCode,
                extensions: [
                    basicSetup,
                    selectedLang.extension,
                    EditorView.lineWrapping,
                    EditorView.theme({
                        // Mobile-first font sizing
                        "&": { fontSize: "14px", height: "100%", backgroundColor: "#ffffff", color: "#0f172a" },
                        ".cm-scroller": {
                            fontFamily: "'JetBrains Mono', 'Fira Code', monospace",
                            minHeight: "200px",
                        },
                        ".cm-content": { minHeight: "200px" },
                        ".cm-gutters": {
                            backgroundColor: "#ffffff",
                            color: "#64748b",
                            borderRight: "1px solid #e2e8f0",
                        },
                        ".cm-activeLine, .cm-activeLineGutter": {
                            backgroundColor: "#eff6ff",
                        },
                        "&.cm-focused .cm-cursor": {
                            borderLeftColor: "#1d4ed8",
                        },
                        "&.cm-focused .cm-selectionBackground, .cm-selectionBackground, .cm-content ::selection": {
                            backgroundColor: "#bfdbfe",
                        },
                    }),
                    ...(placeholder ? [EditorView.theme({ ".cm-placeholder": { color: "#6b7a99" } })] : []),
                    updateListener,
                ],
            }),
            parent: editorContainerRef.current,
        });

        return () => {
            viewRef.current?.destroy();
            viewRef.current = null;
        };
    }, [selectedLang]);

    // ── Sync controlled value into editor (when changed externally) ──
    useEffect(() => {
        if (!isControlled || !viewRef.current) return;
        const current = viewRef.current.state.doc.toString();
        if (current !== value) {
            viewRef.current.dispatch({
                changes: { from: 0, to: current.length, insert: value ?? "" },
            });
        }
    }, [value, isControlled]);

    // ── Run code handler ──
    const handleRun = async (): Promise<void> => {
        if (!viewRef.current || running) return;

        const code = viewRef.current.state.doc.toString().trim();
        if (!code) return;

        setRunning(true);
        setOutput(null);

        try {
            // POST to Judge0 CE via Vite proxy: /api → http://localhost:2358
            // base64_encoded=true is the "gold standard" for reliability with 
            // special characters and newlines in stdin/stdout.
            const res = await fetch("/api/submissions?base64_encoded=true&wait=true", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    source_code: encodeBase64(code),
                    language_id: selectedLang.id,
                    stdin: encodeBase64(stdin),
                }),
            });

            if (!res.ok) throw new Error(`Judge0 error: ${res.status} ${res.statusText}`);
            const data: ExecutionResult = await res.json();

            // Decode all base64 fields in the response only if they exist
            const decodedResult: ExecutionResult = {
                ...data,
                stdout: data.stdout ? decodeBase64(data.stdout) : undefined,
                stderr: data.stderr ? decodeBase64(data.stderr) : undefined,
                compile_output: data.compile_output ? decodeBase64(data.compile_output) : undefined,
                message: data.message ? decodeBase64(data.message) : undefined,
            };

            setOutput(decodedResult);

        } catch (err) {
            setOutput({
                error: err instanceof Error
                    ? err.message
                    : "Could not reach execution server.",
            });
        } finally {
            setRunning(false);
        }
    };

    // ── Derive output text ──
    const outputText = output
        ? (output.error
            || output.compile_output
            || output.stderr
            || output.stdout
            || output.message
            || "(no output)")
        : null;

    const statusStyle = output?.status?.id != null
        ? (STATUS_STYLES[output.status.id] ?? { label: output.status.description ?? "Unknown", color: "#94a3b8" })
        : null;

    // ── Language change handler ──
    const handleLangChange = (e: React.ChangeEvent<HTMLSelectElement>): void => {
        const lang = LANGUAGES.find(l => l.id === parseInt(e.target.value));
        if (lang) setSelectedLang(lang);
    };

    // ── Render ──
    return (
        <div className="ce-wrapper">

            {/* Toolbar – hidden when hideToolbar is true */}
            {!hideToolbar && (
                <div className="ce-toolbar">
                    <select
                        value={selectedLang.id}
                        onChange={handleLangChange}
                        className="ce-select"
                        aria-label="Select programming language"
                    >
                        {LANGUAGES.map(l => (
                            <option key={l.id} value={l.id}>{l.label}</option>
                        ))}
                    </select>

                    <button
                        onClick={() => setShowStdin(s => !s)}
                        className="ce-btn ce-btn--secondary"
                        aria-label="Toggle stdin input"
                    >
                        {showStdin ? "Hide Input" : "Add Input"}
                    </button>

                    <button
                        onClick={handleRun}
                        disabled={running}
                        className="ce-btn ce-btn--run"
                        aria-label="Run code"
                    >
                        {running ? "⏳ Running…" : "▶ Run"}
                    </button>
                </div>
            )}

            {/* CM6 editor mount */}
            <div ref={editorContainerRef} className="ce-editor" />

            {/* Stdin panel */}
            {showStdin && (
                <div className="ce-stdin">
                    <label className="ce-panel-label">Standard Input</label>
                    <textarea
                        value={stdin}
                        onChange={e => setStdin(e.target.value)}
                        placeholder="Enter program input here..."
                        className="ce-textarea"
                        rows={3}
                        aria-label="Standard input"
                    />
                </div>
            )}

            {/* Output panel */}
            {output && (
                <div className="ce-output">
                    <div className="ce-output-header">
                        <span className="ce-panel-label">Output</span>
                        {statusStyle && (
                            <span
                                className="ce-status-badge"
                                style={{ color: statusStyle.color, borderColor: statusStyle.color }}
                            >
                                {statusStyle.label}
                            </span>
                        )}
                        {output.time && (
                            <span className="ce-meta">⏱ {output.time}s</span>
                        )}
                        {output.memory != null && output.memory > 0 && (
                            <span className="ce-meta">
                                💾 {(output.memory / 1024).toFixed(1)} MB
                            </span>
                        )}
                    </div>
                    <pre className="ce-output-pre">{outputText}</pre>
                </div>
            )}

        </div>
    );
}
