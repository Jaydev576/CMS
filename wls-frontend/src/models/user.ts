import { type AcademicContext } from "./academic";

export interface UserProfile {
  userId: number;
  username: string;
  firstName: string;
  lastName: string;

  roleId: number;
  roleName: string;

  academicContext: AcademicContext;
}
