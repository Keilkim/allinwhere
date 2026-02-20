import type { Database } from './database'

// 테이블 Row 타입 별칭
export type Profile = Database['public']['Tables']['profiles']['Row']
export type Team = Database['public']['Tables']['teams']['Row']
export type Membership = Database['public']['Tables']['memberships']['Row']
export type Calendar = Database['public']['Tables']['calendars']['Row']
export type Event = Database['public']['Tables']['events']['Row']
export type Task = Database['public']['Tables']['tasks']['Row']
export type Project = Database['public']['Tables']['projects']['Row']
export type FileRecord = Database['public']['Tables']['files']['Row']
export type Notification = Database['public']['Tables']['notifications']['Row']
export type AuditLog = Database['public']['Tables']['audit_logs']['Row']

// Enum 타입 별칭
export type MembershipRole = Database['public']['Enums']['membership_role']
export type TaskStatus = Database['public']['Enums']['task_status']
export type TaskPriority = Database['public']['Enums']['task_priority']
export type EventStatus = Database['public']['Enums']['event_status']
export type CalendarVisibility = Database['public']['Enums']['calendar_visibility']
export type CalendarPermission = Database['public']['Enums']['calendar_permission']
export type NotificationType = Database['public']['Enums']['notification_type']

// Server Action 공용 반환 타입
export type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string }
