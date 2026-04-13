import { useEffect, useMemo, useState } from "react";
import {
  assignClassSubject,
  assignClassSubjectChapter,
  createHierarchyLevel,
  deleteHierarchyLevel,
  fetchClassSubjectChapters,
  fetchClassSubjects,
  fetchHierarchyLevel,
  removeClassSubject,
  removeClassSubjectChapter,
  updateHierarchyLevel,
  type HierarchyNode,
} from "../../api/admin";
import AcademicHierarchySelector, { type HierarchySelection } from "../../components/Admin/AcademicHierarchySelector";

type LevelKey = "universities" | "faculties" | "departments" | "courses" | "specializations" | "classes";

interface LevelConfig {
  key: LevelKey;
  label: string;
  singularLabel: string;
  idKey: string;
  nameKey: string;
  parentKeys: Array<keyof HierarchySelection>;
}

const configs: LevelConfig[] = [
  { key: "universities", label: "Universities", singularLabel: "University", idKey: "university_id", nameKey: "university_name", parentKeys: [] },
  { key: "faculties", label: "Faculties", singularLabel: "Faculty", idKey: "faculty_id", nameKey: "faculty_name", parentKeys: ["university_id"] },
  {
    key: "departments",
    label: "Departments",
    singularLabel: "Department",
    idKey: "department_id",
    nameKey: "department_name",
    parentKeys: ["university_id", "faculty_id"],
  },
  {
    key: "courses",
    label: "Courses",
    singularLabel: "Course",
    idKey: "course_id",
    nameKey: "course_name",
    parentKeys: ["university_id", "faculty_id", "department_id"],
  },
  {
    key: "specializations",
    label: "Specializations",
    singularLabel: "Specialization",
    idKey: "specialization_id",
    nameKey: "specialization_name",
    parentKeys: ["university_id", "faculty_id", "department_id", "course_id"],
  },
  {
    key: "classes",
    label: "Classes",
    singularLabel: "Class",
    idKey: "class_id",
    nameKey: "class_name",
    parentKeys: ["university_id", "faculty_id", "department_id", "course_id", "specialization_id"],
  },
];

function hasParents(config: LevelConfig, context: HierarchySelection): boolean {
  return config.parentKeys.every((key) => Number.isFinite(Number(context[key])) && Number(context[key]) > 0);
}

function requiredParams(config: LevelConfig, context: HierarchySelection): Record<string, number> {
  const params: Record<string, number> = {};
  config.parentKeys.forEach((key) => {
    const value = context[key];
    if (value) {
      params[key] = value;
    }
  });
  return params;
}

function editableValue(row: HierarchyNode, key: string): string {
  const value = row[key];
  if (value === null || value === undefined) {
    return "";
  }
  return String(value);
}

export default function AdminHierarchyPage() {
  const [context, setContext] = useState<HierarchySelection>({});
  const [itemsByLevel, setItemsByLevel] = useState<Record<LevelKey, HierarchyNode[]>>({
    universities: [],
    faculties: [],
    departments: [],
    courses: [],
    specializations: [],
    classes: [],
  });

  const [newNameByLevel, setNewNameByLevel] = useState<Record<LevelKey, string>>({
    universities: "",
    faculties: "",
    departments: "",
    courses: "",
    specializations: "",
    classes: "",
  });

  const [loading, setLoading] = useState(false);
  const [toast, setToast] = useState<{ type: "error" | "success"; message: string } | null>(null);
  const [subjects, setSubjects] = useState<Array<Record<string, unknown>>>([]);
  const [classSubjects, setClassSubjects] = useState<Array<Record<string, unknown>>>([]);
  const [selectedSubjectId, setSelectedSubjectId] = useState("");
  const [chapterRows, setChapterRows] = useState<Array<Record<string, unknown>>>([]);
  const [refreshToggle, setRefreshToggle] = useState(0);

  const loadLevel = async (config: LevelConfig) => {
    if (config.parentKeys.length > 0 && !hasParents(config, context)) {
      setItemsByLevel((prev) => ({ ...prev, [config.key]: [] }));
      return;
    }

    try {
      const params = requiredParams(config, context);
      const result = await fetchHierarchyLevel(config.key, params);
      setItemsByLevel((prev) => ({ ...prev, [config.key]: result.items }));
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : `Failed to load ${config.label}` });
    }
  };

  const loadAll = async () => {
    setLoading(true);
    for (const config of configs) {
      // eslint-disable-next-line no-await-in-loop
      await loadLevel(config);
    }
    setLoading(false);
  };

  const hasClassContext = useMemo(
    () =>
      Number.isFinite(Number(context.university_id))
      && Number(context.university_id) > 0
      && Number.isFinite(Number(context.faculty_id))
      && Number(context.faculty_id) > 0
      && Number.isFinite(Number(context.department_id))
      && Number(context.department_id) > 0
      && Number.isFinite(Number(context.course_id))
      && Number(context.course_id) > 0
      && Number.isFinite(Number(context.specialization_id))
      && Number(context.specialization_id) > 0
      && Number.isFinite(Number(context.class_id))
      && Number(context.class_id) > 0,
    [context],
  );

  const classParams = useMemo(
    () => ({
      university_id: context.university_id,
      faculty_id: context.faculty_id,
      department_id: context.department_id,
      course_id: context.course_id,
      specialization_id: context.specialization_id,
      class_id: context.class_id,
    }),
    [context],
  );

  const loadClassSubjects = async () => {
    if (!hasClassContext) {
      setClassSubjects([]);
      return;
    }
    try {
      const result = await fetchClassSubjects(classParams);
      setClassSubjects(result.items);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to load class subjects" });
    }
  };

  const loadChapterRows = async () => {
    if (!hasClassContext || !selectedSubjectId) {
      setChapterRows([]);
      return;
    }
    try {
      const result = await fetchClassSubjectChapters({
        ...classParams,
        subject_id: Number(selectedSubjectId),
      });
      setChapterRows(result.items);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Failed to load chapter toggles" });
    }
  };

  useEffect(() => {
    void loadAll();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [context.university_id, context.faculty_id, context.department_id, context.course_id, context.specialization_id]);

  useEffect(() => {
    void fetchHierarchyLevel("subjects")
      .then((result) => setSubjects(result.items))
      .catch(() => setSubjects([]));
  }, []);

  useEffect(() => {
    void loadClassSubjects();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hasClassContext, classParams.university_id, classParams.faculty_id, classParams.department_id, classParams.course_id, classParams.specialization_id, classParams.class_id]);

  useEffect(() => {
    void loadChapterRows();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedSubjectId, hasClassContext, classParams.university_id, classParams.faculty_id, classParams.department_id, classParams.course_id, classParams.specialization_id, classParams.class_id]);

  const addLevel = async (config: LevelConfig) => {
    const name = newNameByLevel[config.key].trim();
    if (!name) {
      setToast({ type: "error", message: `${config.label}: name is required` });
      return;
    }

    const payload: Record<string, unknown> = {
      [config.nameKey]: name,
      responsible_person_name: "",
      responsible_person_role: "",
      responsible_person_address: "",
      responsible_person_contact_no: "",
      responsible_person_email: "",
    };

    config.parentKeys.forEach((key) => {
      payload[key] = context[key];
    });

    try {
      await createHierarchyLevel(config.key, payload);
      setToast({ type: "success", message: `${config.singularLabel} added` });
      setNewNameByLevel((prev) => ({ ...prev, [config.key]: "" }));
      await loadLevel(config);
      setRefreshToggle((prev) => prev + 1);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Create failed" });
    }
  };

  const saveRow = async (config: LevelConfig, row: HierarchyNode) => {
    const id = Number(row[config.idKey]);
    if (!Number.isFinite(id) || id <= 0) {
      return;
    }

    const payload: Record<string, unknown> = {
      [config.nameKey]: editableValue(row, config.nameKey),
      responsible_person_name: editableValue(row, "responsible_person_name"),
      responsible_person_role: editableValue(row, "responsible_person_role"),
      responsible_person_address: editableValue(row, "responsible_person_address"),
      responsible_person_contact_no: editableValue(row, "responsible_person_contact_no"),
      responsible_person_email: editableValue(row, "responsible_person_email"),
    };

    config.parentKeys.forEach((key) => {
      payload[key] = row[key] ?? context[key];
    });

    try {
      await updateHierarchyLevel(config.key, id, payload);
      setToast({ type: "success", message: `${config.label} updated` });
      await loadLevel(config);
      setRefreshToggle((prev) => prev + 1);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Update failed" });
    }
  };

  const deleteRow = async (config: LevelConfig, row: HierarchyNode) => {
    const id = Number(row[config.idKey]);
    if (!Number.isFinite(id) || id <= 0) {
      return;
    }

    const itemName = editableValue(row, config.nameKey) || `${config.singularLabel} #${id}`;
    const confirmed = window.confirm(`Delete "${itemName}"? This cannot be undone.`);
    if (!confirmed) {
      return;
    }

    const payload: Record<string, unknown> = {};
    config.parentKeys.forEach((key) => {
      payload[key] = row[key] ?? context[key];
    });

    try {
      const result = await deleteHierarchyLevel(config.key, id, payload);
      if (result.deleted === 0) {
        setToast({ type: "error", message: `${config.singularLabel} not found or already deleted` });
        return;
      }
      setToast({ type: "success", message: `${config.singularLabel} deleted` });
      await loadLevel(config);
      setRefreshToggle((prev) => prev + 1);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Delete failed" });
    }
  };

  const updateRowField = (config: LevelConfig, index: number, field: string, value: string) => {
    setItemsByLevel((prev) => {
      const nextLevelItems = [...prev[config.key]];
      nextLevelItems[index] = { ...nextLevelItems[index], [field]: value };
      return {
        ...prev,
        [config.key]: nextLevelItems,
      };
    });
  };

  const addSubjectToClass = async () => {
    if (!hasClassContext || !selectedSubjectId) {
      setToast({ type: "error", message: "Select class context and subject" });
      return;
    }

    try {
      await assignClassSubject({
        ...classParams,
        subject_id: Number(selectedSubjectId),
      });
      setToast({ type: "success", message: "Subject assigned to class" });
      await loadClassSubjects();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Assign subject failed" });
    }
  };

  const removeSubjectFromClass = async (subjectId: number) => {
    if (!hasClassContext) {
      return;
    }
    try {
      await removeClassSubject({
        ...classParams,
        subject_id: subjectId,
      });
      setToast({ type: "success", message: "Subject removed from class" });
      if (Number(selectedSubjectId) === subjectId) {
        setSelectedSubjectId("");
      }
      await loadClassSubjects();
      setChapterRows([]);
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Remove subject failed" });
    }
  };

  const toggleChapter = async (chapterId: number, enabled: boolean) => {
    if (!hasClassContext || !selectedSubjectId) {
      return;
    }

    const payload = {
      ...classParams,
      subject_id: Number(selectedSubjectId),
      chapter_id: chapterId,
    };

    try {
      if (enabled) {
        await removeClassSubjectChapter(payload);
      } else {
        await assignClassSubjectChapter(payload);
      }
      await loadChapterRows();
      await loadClassSubjects();
    } catch (err: unknown) {
      setToast({ type: "error", message: err instanceof Error ? err.message : "Chapter toggle failed" });
    }
  };

  const contextLabel = useMemo(() => {
    const parts = [
      context.university_id ? `University: ${context.university_id}` : null,
      context.faculty_id ? `Faculty: ${context.faculty_id}` : null,
      context.department_id ? `Department: ${context.department_id}` : null,
      context.course_id ? `Course: ${context.course_id}` : null,
      context.specialization_id ? `Specialization: ${context.specialization_id}` : null,
    ].filter(Boolean);
    return parts.length > 0 ? parts.join(" | ") : "Global view";
  }, [context]);

  const handleRefresh = async () => {
    setRefreshToggle((prev) => prev + 1);
    void loadAll();
    void fetchHierarchyLevel("subjects")
      .then((result) => setSubjects(result.items))
      .catch(() => setSubjects([]));
    void loadClassSubjects();
    void loadChapterRows();
  };

  return (
    <div>
      <div className="admin-topbar">
        <h2>Academic Hierarchy</h2>
        <button type="button" className="admin-btn" onClick={handleRefresh}>
          Refresh
        </button>
      </div>

      {toast && <div className={`admin-toast ${toast.type}`}>{toast.message}</div>}

      <section className="admin-panel">
        <h3>Hierarchy Context</h3>
        <p style={{ marginBottom: "0.7rem", color: "#445974" }}>{contextLabel}</p>
        <AcademicHierarchySelector value={context} onChange={setContext} includeSpecialization includeClass refreshToggle={refreshToggle} />
      </section>

      <section className="admin-panel">
        <h3>Class Subject Assignment</h3>
        {!hasClassContext && <p>Select full class hierarchy (including class) to manage assignments.</p>}

        {hasClassContext && (
          <>
            <div className="admin-row" style={{ marginBottom: "0.7rem" }}>
              <select value={selectedSubjectId} onChange={(e) => setSelectedSubjectId(e.target.value)}>
                <option value="">Select Subject</option>
                {subjects.map((subject) => (
                  <option key={String(subject.subject_id)} value={String(subject.subject_id)}>
                    {String(subject.subject_name ?? "")} (#{String(subject.subject_id)})
                  </option>
                ))}
              </select>
              <button type="button" className="admin-btn secondary" onClick={addSubjectToClass}>
                Assign Subject
              </button>
              <button type="button" className="admin-btn secondary" onClick={loadClassSubjects}>
                Refresh Subjects
              </button>
            </div>

            <div className="admin-table-wrap">
              <table className="admin-table">
                <thead>
                  <tr>
                    <th>Subject</th>
                    <th>Enabled Chapters</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {classSubjects.length === 0 && (
                    <tr>
                      <td colSpan={3}>No subjects assigned to this class.</td>
                    </tr>
                  )}
                  {classSubjects.map((row) => (
                    <tr key={String(row.subject_id)}>
                      <td>
                        {String(row.subject_name ?? "")} (#{String(row.subject_id)})
                      </td>
                      <td>{String(row.enabled_chapters ?? "0")}</td>
                      <td>
                        <div className="admin-row">
                          <button
                            type="button"
                            className="admin-btn secondary"
                            onClick={() => setSelectedSubjectId(String(row.subject_id ?? ""))}
                          >
                            Chapters
                          </button>
                          <button
                            type="button"
                            className="admin-btn warn"
                            onClick={() => removeSubjectFromClass(Number(row.subject_id))}
                          >
                            Remove
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {selectedSubjectId && (
              <div style={{ marginTop: "0.9rem" }}>
                <h4>Chapter Toggles for Subject #{selectedSubjectId}</h4>
                <div className="admin-table-wrap">
                  <table className="admin-table">
                    <thead>
                      <tr>
                        <th>Chapter</th>
                        <th>Enabled</th>
                      </tr>
                    </thead>
                    <tbody>
                      {chapterRows.length === 0 && (
                        <tr>
                          <td colSpan={2}>No chapters found for this subject.</td>
                        </tr>
                      )}
                      {chapterRows.map((row) => (
                        <tr key={String(row.chapter_id)}>
                          <td>
                            #{String(row.chapter_id)} - {String(row.chapter_name ?? "")}
                          </td>
                          <td>
                            <input
                              type="checkbox"
                              checked={Number(row.is_enabled) === 1}
                              onChange={() => toggleChapter(Number(row.chapter_id), Number(row.is_enabled) === 1)}
                            />
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </>
        )}
      </section>

      {configs.map((config) => {
        const canLoad = config.parentKeys.length === 0 || hasParents(config, context);
        const rows = itemsByLevel[config.key];

        return (
          <section key={config.key} className="admin-panel">
            <h3>{config.label}</h3>
            {!canLoad && <p>Select parent hierarchy first.</p>}

            {canLoad && (
              <>
                <div className="admin-row" style={{ marginBottom: "0.7rem" }}>
                  <input
                    placeholder={`New ${config.singularLabel} Name`}
                    value={newNameByLevel[config.key]}
                    onChange={(e) =>
                      setNewNameByLevel((prev) => ({
                        ...prev,
                        [config.key]: e.target.value,
                      }))
                    }
                  />
                  <button type="button" className="admin-btn secondary" onClick={() => addLevel(config)}>
                    Add {config.singularLabel}
                  </button>
                </div>

                <div className="admin-table-wrap">
                  <table className="admin-table admin-table-hierarchy">
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Name</th>
                        <th>Responsible Name</th>
                        <th>Role</th>
                        <th>Contact</th>
                        <th>Email</th>
                        <th>Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {loading && rows.length === 0 && (
                        <tr>
                          <td colSpan={7}>Loading...</td>
                        </tr>
                      )}
                      {!loading && rows.length === 0 && (
                        <tr>
                          <td colSpan={7}>No records</td>
                        </tr>
                      )}
                      {rows.map((row, idx) => (
                        <tr key={`${config.key}-${String(row[config.idKey])}-${idx}`}>
                          <td>{String(row[config.idKey] ?? "")}</td>
                          <td>
                            <input
                              value={editableValue(row, config.nameKey)}
                              onChange={(e) => updateRowField(config, idx, config.nameKey, e.target.value)}
                            />
                          </td>
                          <td>
                            <input
                              value={editableValue(row, "responsible_person_name")}
                              onChange={(e) => updateRowField(config, idx, "responsible_person_name", e.target.value)}
                            />
                          </td>
                          <td>
                            <input
                              value={editableValue(row, "responsible_person_role")}
                              onChange={(e) => updateRowField(config, idx, "responsible_person_role", e.target.value)}
                            />
                          </td>
                          <td>
                            <input
                              value={editableValue(row, "responsible_person_contact_no")}
                              onChange={(e) => updateRowField(config, idx, "responsible_person_contact_no", e.target.value)}
                            />
                          </td>
                          <td>
                            <input
                              value={editableValue(row, "responsible_person_email")}
                              onChange={(e) => updateRowField(config, idx, "responsible_person_email", e.target.value)}
                            />
                          </td>
                          <td>
                            <div className="admin-action-stack">
                              <button type="button" className="admin-btn secondary" onClick={() => saveRow(config, row)}>
                                Save
                              </button>
                              <button type="button" className="admin-btn warn" onClick={() => deleteRow(config, row)}>
                                Delete
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </>
            )}
          </section>
        );
      })}
    </div>
  );
}
