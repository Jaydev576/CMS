import { useEffect, useMemo, useState } from "react";
import { fetchHierarchyLevel, type HierarchyNode } from "../../api/admin";

export interface HierarchySelection {
  university_id?: number;
  faculty_id?: number;
  department_id?: number;
  course_id?: number;
  specialization_id?: number;
  class_id?: number;
}

interface Option {
  id: number;
  name: string;
}

interface AcademicHierarchySelectorProps {
  value: HierarchySelection;
  onChange: (value: HierarchySelection) => void;
  includeSpecialization?: boolean;
  includeClass?: boolean;
  disabled?: boolean;
  className?: string;
  refreshToggle?: number;
}

function toOptions(items: HierarchyNode[], idKey: string, nameKey: string): Option[] {
  return items
    .map((item) => ({
      id: Number(item[idKey]),
      name: String(item[nameKey] ?? `${nameKey} ${String(item[idKey])}`),
    }))
    .filter((item) => Number.isFinite(item.id) && item.id > 0);
}

export default function AcademicHierarchySelector({
  value,
  onChange,
  includeSpecialization = true,
  includeClass = true,
  disabled,
  className,
  refreshToggle,
}: AcademicHierarchySelectorProps) {
  const [universities, setUniversities] = useState<Option[]>([]);
  const [faculties, setFaculties] = useState<Option[]>([]);
  const [departments, setDepartments] = useState<Option[]>([]);
  const [courses, setCourses] = useState<Option[]>([]);
  const [specializations, setSpecializations] = useState<Option[]>([]);
  const [classes, setClasses] = useState<Option[]>([]);

  useEffect(() => {
    fetchHierarchyLevel("universities")
      .then((data) => setUniversities(toOptions(data.items, "university_id", "university_name")))
      .catch(() => setUniversities([]));
  }, [refreshToggle]);

  useEffect(() => {
    if (!value.university_id) {
      setFaculties([]);
      return;
    }

    fetchHierarchyLevel("faculties", { university_id: value.university_id })
      .then((data) => setFaculties(toOptions(data.items, "faculty_id", "faculty_name")))
      .catch(() => setFaculties([]));
  }, [value.university_id, refreshToggle]);

  useEffect(() => {
    if (!value.university_id || !value.faculty_id) {
      setDepartments([]);
      return;
    }

    fetchHierarchyLevel("departments", {
      university_id: value.university_id,
      faculty_id: value.faculty_id,
    })
      .then((data) => setDepartments(toOptions(data.items, "department_id", "department_name")))
      .catch(() => setDepartments([]));
  }, [value.university_id, value.faculty_id, refreshToggle]);

  useEffect(() => {
    if (!value.university_id || !value.faculty_id || !value.department_id) {
      setCourses([]);
      return;
    }

    fetchHierarchyLevel("courses", {
      university_id: value.university_id,
      faculty_id: value.faculty_id,
      department_id: value.department_id,
    })
      .then((data) => setCourses(toOptions(data.items, "course_id", "course_name")))
      .catch(() => setCourses([]));
  }, [value.university_id, value.faculty_id, value.department_id, refreshToggle]);

  useEffect(() => {
    if (!includeSpecialization || !value.university_id || !value.faculty_id || !value.department_id || !value.course_id) {
      setSpecializations([]);
      return;
    }

    fetchHierarchyLevel("specializations", {
      university_id: value.university_id,
      faculty_id: value.faculty_id,
      department_id: value.department_id,
      course_id: value.course_id,
    })
      .then((data) => setSpecializations(toOptions(data.items, "specialization_id", "specialization_name")))
      .catch(() => setSpecializations([]));
  }, [includeSpecialization, value.university_id, value.faculty_id, value.department_id, value.course_id, refreshToggle]);

  useEffect(() => {
    if (
      !includeClass
      || !value.university_id
      || !value.faculty_id
      || !value.department_id
      || !value.course_id
      || !value.specialization_id
    ) {
      setClasses([]);
      return;
    }

    fetchHierarchyLevel("classes", {
      university_id: value.university_id,
      faculty_id: value.faculty_id,
      department_id: value.department_id,
      course_id: value.course_id,
      specialization_id: value.specialization_id,
    })
      .then((data) => setClasses(toOptions(data.items, "class_id", "class_name")))
      .catch(() => setClasses([]));
  }, [
    includeClass,
    value.university_id,
    value.faculty_id,
    value.department_id,
    value.course_id,
    value.specialization_id,
    refreshToggle,
  ]);

  const containerClass = useMemo(() => `admin-grid ${className ?? ""}`.trim(), [className]);

  return (
    <div className={containerClass}>
      <label>
        University
        <select
          disabled={disabled}
          value={value.university_id ?? ""}
          onChange={(e) =>
            onChange({
              university_id: e.target.value ? Number(e.target.value) : undefined,
              faculty_id: undefined,
              department_id: undefined,
              course_id: undefined,
              specialization_id: undefined,
              class_id: undefined,
            })
          }
        >
          <option value="">Select</option>
          {universities.map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
      </label>

      <label>
        Faculty
        <select
          disabled={disabled || !value.university_id}
          value={value.faculty_id ?? ""}
          onChange={(e) =>
            onChange({
              ...value,
              faculty_id: e.target.value ? Number(e.target.value) : undefined,
              department_id: undefined,
              course_id: undefined,
              specialization_id: undefined,
              class_id: undefined,
            })
          }
        >
          <option value="">Select</option>
          {faculties.map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
      </label>

      <label>
        Department
        <select
          disabled={disabled || !value.faculty_id}
          value={value.department_id ?? ""}
          onChange={(e) =>
            onChange({
              ...value,
              department_id: e.target.value ? Number(e.target.value) : undefined,
              course_id: undefined,
              specialization_id: undefined,
              class_id: undefined,
            })
          }
        >
          <option value="">Select</option>
          {departments.map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
      </label>

      <label>
        Course
        <select
          disabled={disabled || !value.department_id}
          value={value.course_id ?? ""}
          onChange={(e) =>
            onChange({
              ...value,
              course_id: e.target.value ? Number(e.target.value) : undefined,
              specialization_id: undefined,
              class_id: undefined,
            })
          }
        >
          <option value="">Select</option>
          {courses.map((item) => (
            <option key={item.id} value={item.id}>
              {item.name}
            </option>
          ))}
        </select>
      </label>

      {includeSpecialization && (
        <label>
          Specialization
          <select
            disabled={disabled || !value.course_id}
            value={value.specialization_id ?? ""}
            onChange={(e) =>
              onChange({
                ...value,
                specialization_id: e.target.value ? Number(e.target.value) : undefined,
                class_id: undefined,
              })
            }
          >
            <option value="">Select</option>
            {specializations.map((item) => (
              <option key={item.id} value={item.id}>
                {item.name}
              </option>
            ))}
          </select>
        </label>
      )}

      {includeClass && includeSpecialization && (
        <label>
          Class
          <select
            disabled={disabled || !value.specialization_id}
            value={value.class_id ?? ""}
            onChange={(e) =>
              onChange({
                ...value,
                class_id: e.target.value ? Number(e.target.value) : undefined,
              })
            }
          >
            <option value="">Select</option>
            {classes.map((item) => (
              <option key={item.id} value={item.id}>
                {item.name}
              </option>
            ))}
          </select>
        </label>
      )}
    </div>
  );
}
