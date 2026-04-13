import { useState } from "react";
import CodeEditor from "../CodeEditor";

// ── Sample programs ──────────────────────────────────────────────────────────

type LangKey = "java" | "python" | "cpp" | "c" | "javascript";

const SAMPLES: Record<LangKey, { label: string; languageId: number; code: string }> = {
  java: {
    label: "Java",
    languageId: 62,
    code: `import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.println("Hello from Java!");

        // Fibonacci sequence
        int n = 10, a = 0, b = 1;
        System.out.print("Fibonacci:");
        System.out.print(" " + a + " " + b);
        for (int i = 2; i < n; i++) {
            int c = a + b;
            System.out.print(" " + c);
            a = b; b = c;
        }
        System.out.println();
    }
}`,
  },

  python: {
    label: "Python",
    languageId: 71,
    code: `# Bubble sort + list comprehension demo
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):
        for j in range(n - i - 1):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
    return arr

numbers = [64, 34, 25, 12, 22, 11, 90]
print("Original:", numbers)
print("Sorted:  ", bubble_sort(numbers))
squares = [x ** 2 for x in range(1, 8)]
print("Squares: ", squares)
`,
  },

  cpp: {
    label: "C++",
    languageId: 54,
    code: `#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main() {
    cout << "Hello from C++!" << endl;

    vector<int> v = {5, 2, 8, 1, 9, 3, 7};
    sort(v.begin(), v.end());

    cout << "Sorted: ";
    for (int x : v) cout << x << " ";
    cout << endl;
    return 0;
}`,
  },

  c: {
    label: "C",
    languageId: 50,
    code: `#include <stdio.h>

int factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

int main() {
    printf("Hello from C!\\n");
    for (int i = 1; i <= 10; i++) {
        printf("%2d! = %d\\n", i, factorial(i));
    }
    return 0;
}`,
  },

  javascript: {
    label: "JavaScript",
    languageId: 63,
    code: `// Higher-order functions demo
const nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const evens   = nums.filter(n => n % 2 === 0);
const squares = evens.map(n => n * n);
const total   = squares.reduce((acc, n) => acc + n, 0);

console.log("Evens:           ", evens.join(", "));
console.log("Squares of evens:", squares.join(", "));
console.log("Sum of squares:  ", total);
`,
  },
};

const LANG_KEYS = Object.keys(SAMPLES) as LangKey[];

// ── Page ─────────────────────────────────────────────────────────────────────

export default function CodePlaygroundPage() {
  const [activeLang, setActiveLang] = useState<LangKey>("java");
  const sample = SAMPLES[activeLang];

  return (
    <div className="main-content">
      <div
        className="animate-fade-in"
        style={{ maxWidth: 920, margin: "0 auto", padding: "1.5rem 1rem 2rem" }}
      >
        {/* ── Header ── */}
        <div style={{ marginBottom: "1.25rem" }}>
          <h2 className="page-title" style={{ marginBottom: "0.3rem" }}>
            ⌨️ Code Playground
          </h2>
          <p style={{ margin: 0, fontSize: "0.92rem", color: "var(--text-secondary)" }}>
            Write and run code in your browser. Pick a sample program below, edit it freely, then
            hit <strong>▶ Run</strong>. Use <strong>Add Input</strong> to supply stdin.
          </p>
        </div>

        {/* ── Sample language pills ── */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: "0.45rem",
            marginBottom: "1.1rem",
            alignItems: "center",
          }}
        >
          <span
            style={{ fontSize: "0.82rem", color: "var(--text-secondary)", marginRight: 2, fontWeight: 600 }}
          >
            Load sample:
          </span>
          {LANG_KEYS.map((key) => (
            <button
              key={key}
              type="button"
              onClick={() => setActiveLang(key)}
              style={{
                padding: "5px 14px",
                borderRadius: 20,
                border: `1.5px solid ${activeLang === key ? "#3b82f6" : "#cbd5e1"}`,
                background: activeLang === key ? "#dbeafe" : "#ffffff",
                color: activeLang === key ? "#1e3a8a" : "#334155",
                fontSize: "0.82rem",
                fontWeight: 600,
                cursor: "pointer",
                transition: "all 0.15s",
              }}
            >
              {SAMPLES[key].label}
            </button>
          ))}
        </div>

        {/* ── CodeEditor — keyed by lang so it remounts with fresh sample code ── */}
        <CodeEditor
          key={activeLang}
          initialCode={sample.code}
          initialLanguageId={sample.languageId}
        />

        <p
          style={{
            marginTop: "0.8rem",
            fontSize: "0.82rem",
            color: "var(--text-secondary)",
            textAlign: "center",
          }}
        >
          💡 Tip: The language in the toolbar is independent — use the pills above to reload a
          fresh sample, or keep editing your own code freely.
          Execution is powered by Judge0 via the backend.
        </p>
      </div>
    </div>
  );
}
