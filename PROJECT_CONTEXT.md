# WLS (Web Learning System) Comprehensive Project Context

This document is a technical deep-dive into the WLS project, its architecture, and data structures. It is designed to provide full context for an AI coding assistant (like Claude Code or ChatGPT) to understand and contribute to the codebase.

---

## 1. System Architecture & Routing

### 🏗️ Backend Architecture (Java Servlets)
The backend uses a **Front Controller Pattern**. A central `FrontControllerServlet` handles all `/api/*` requests.

- **Dynamic Routing**: Routes are stored in the `api_routes` database table. The `FrontControllerServlet` loads these at startup via a stored procedure `get_active_api_routes()`.
- **Servlet Dispatching**: When a request comes in, the controller looks up the `servlet_name` from the route and forwards the request using `RequestDispatcher.getNamedDispatcher()`.
- **Authentication Filter**: An `AuthFilter.java` intercepts requests to ensure the user is authenticated and has the necessary permissions.

### ⚛️ Frontend Architecture (React + Vite)
Built with React 18 and Vite, the frontend uses **React Router 7** for navigation and **TanStack React Query** for server state management.

- **Layouts**: Uses `AppLayout` for learners and `AdminLayout` for administrators.
- **Context API**: `AuthContext` managed by `AuthProvider` handles user session state and provides `login`, `logout`, and `user` data globally.

---

## 2. Technical Stack Reference

| Layer | Technologies |
| :--- | :--- |
| **Backend** | Java 8+, Servlets API, JDBC |
| **Frontend** | React, Vite, TailwindCSS, TanStack Query, React Router, CodeMirror 6 |
| **Database** | MySQL 8.0, Stored Procedures, Triggers |
| **Extra** | Judge0 (Code Execution), SHA-256 (Password Hashing) |

---

## 3. Database Schema Deep-Dive

### 👤 User Management & RBAC
Roles are defined in the `roles` table:
1. `ADMIN`: Full system access.
2. `CONTENT_DEVELOPER`: Creation and editing of learning materials.
3. `CONTENT_VIEWER`: Primary students/users.

Main tables:
- `users`: Core profile (`username`, `password_hash`, `role_id`, `account_status`).
- `content_developer_users`: Extended metadata for developers (linked by `user_id`).
- `content_viewer_users`: Extended metadata for students (linked by `user_id`).
- `privileges`: General RBAC mapping for specific organizational levels (university, faculty, etc.).
- `content_developer_privileges_*` & `content_viewer_privileges_*`: Granular permissions for subjects, chapters, and topics.

### 📚 Learning Content Hierarchy
The system uses a 7-level hierarchy for organizing content:
1. **Subject**: Highest level (e.g., "Operating Systems").
2. **Chapter**: Major division within a subject.
3. **Topic Level 1-5**: Progressively deeper nested content.

**Coding Strategy**:
Custom triggers (e.g., `chapter_BEFORE_INSERT`) generate unique `_cd` (code) strings by concatenating IDs.
Example: `subject_id(5) + chapter_id(2) + topic_id(2) ...` -> `000110306`.

### 🎥 Multimedia & Interactive Content
Specific tables for different resource types, all linked into the hierarchy:
- `audio`, `image`, `video`: Standard media blobs or URLs.
- `program`: Code examples for display.
- `simulation`: Java Applet or Web-simulation metadata (linked to `.jar` and `.jsp` files).

---

## 4. API Reference (Mapped from `api_routes`)

The following endpoints are registered in the `api_routes` table:

### Authentication
- `/checkLogin` -> `CheckLoginServlet` (POST: username/password)
- `/Logout` -> `Logout` (POST)
- `/SessionInfo` -> `SessionInfo` (GET)

### Learner API
- `/subjects` -> `GetUserProfileAndSubjectsServlet`: List accessible subjects.
- `/GetChaptersServlet` -> `GetChaptersServlet`: List chapters for a subject.
- `/LearningContentServlet`: Fetch detailed content for a specific hierarchy level.
- `/ContentViewerDashboard`: User dashboard stats.

### Content Creator API
- `/creator/subjects` -> `CreatorSubjectsServlet`: Managed subjects.
- `/creator/hierarchy` -> `CreatorHierarchyServlet`: Browse/Manage hierarchy.
- `/creator/save` -> `CreatorSaveContentServlet`: POST/PUT content.

### Admin API (Handled by `AdminModuleServlet`)
- `/admin/users`: GET (list), POST (create).
- `/admin/users/:user_id`: CRUD operations for a specific user.
- `/admin/enrollments`: Manage student-subject mappings.
- `/admin/privileges/overview`: View all permissions.
- `/admin/content/review-queue`: Content moderation.
- `/admin/hierarchy/:level`: Manage organizational structure (universities, courses).

---

## 5. Interactive Features & Integrations

### 💻 Code Playground & Execution
The system features a custom `CodeEditor.tsx` component built with **CodeMirror 6**.

- **Languages Supported**: C, C++, Java, Python, JavaScript.
- **Backend Execution**: Integrates with a **Judge0 CE** (local or cloud) instance.
- **Workflow**:
    1. User enters code and optional `stdin` in the frontend.
    2. The frontend sends the source, language, and `stdin` to the Judge0 API.
    3. The response (stdout, stderr, compile_output) is displayed in a custom console UI.

### 🎮 Simulations
Interactive simulations are managed via the `simulation` table. They can be Java applets (legacy) or web-based simulations.
- Linked via `.jar` files and `.jsp` entries for server-side dispatching.
- Accessible directly from the learner's subject view.

---

## 6. Security Protocols 🛡️

1. **Password Hashing**: SHA-256 with a random salt (`PasswordHash.java`). Plain text is never stored.
2. **Session Security**: 
   - `CheckLoginServlet` invalidates old sessions before creating new ones to prevent fixation.
   - Sessions expire after 90 minutes of inactivity.
3. **Login Protection**: Max 5 failed attempts locks the account (`account_status = 'LOCKED'`).
4. **Audit Logging**: Admin actions like privilege changes are logged in `admin_privilege_audit`.

---

## 6. Key Frontend Routes

| Path | Component | Description |
| :--- | :--- | :--- |
| `/` | `LoginPage` | Authentication screen. |
| `/subjects` | `SubjectListPage` | Landing for students. |
| `/subjects/:subjectId/chapter/:chapterId` | `ChapterDetailPage` | Main content viewer. |
| `/creator/dashboard` | `CreatorDashboard` | Content management landing. |
| `/admin/*` | `AdminLayout` | Wrapper for all admin modules. |

---

## 7. Development Tips
- **Compiling**: Java classes are compiled from `WLS_src`.
- **Database Mod**: Always check triggers in `full_dump_wls.sql` before changing ID strategies.
- **Frontend**: Run `npm run dev` in `wls-frontend`. Use TanStack Query hooks for any new API calls to ensure consistent state and caching.


Ollama → LLaMA 3 / Mistral
LangChain
ChromaDB / FAISS
FastAPI / Node.js
React Web App
PDF / Notes / Docs