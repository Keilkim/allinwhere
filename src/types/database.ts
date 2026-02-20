// 이 파일은 Supabase CLI로 자동 생성됩니다.
// 실행: supabase gen types typescript --project-id <ref> > src/types/database.ts
// 아래는 초기 개발을 위한 수동 타입 정의입니다.

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          email: string
          full_name: string | null
          avatar_url: string | null
          timezone: string
          locale: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          email: string
          full_name?: string | null
          avatar_url?: string | null
          timezone?: string
          locale?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          full_name?: string | null
          avatar_url?: string | null
          timezone?: string
          locale?: string
          updated_at?: string
        }
      }
      teams: {
        Row: {
          id: string
          name: string
          slug: string
          description: string | null
          created_by: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          slug: string
          description?: string | null
          created_by: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          name?: string
          slug?: string
          description?: string | null
          updated_at?: string
        }
      }
      memberships: {
        Row: {
          id: string
          user_id: string
          team_id: string
          role: 'owner' | 'admin' | 'member' | 'guest'
          joined_at: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          team_id: string
          role?: 'owner' | 'admin' | 'member' | 'guest'
          joined_at?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          role?: 'owner' | 'admin' | 'member' | 'guest'
          updated_at?: string
        }
      }
      calendars: {
        Row: {
          id: string
          team_id: string | null
          owner_id: string
          name: string
          description: string | null
          color: string
          visibility: 'private' | 'team' | 'public'
          is_default: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          team_id?: string | null
          owner_id: string
          name: string
          description?: string | null
          color?: string
          visibility?: 'private' | 'team' | 'public'
          is_default?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          team_id?: string | null
          name?: string
          description?: string | null
          color?: string
          visibility?: 'private' | 'team' | 'public'
          is_default?: boolean
          updated_at?: string
        }
      }
      events: {
        Row: {
          id: string
          calendar_id: string
          created_by: string
          title: string
          description: string | null
          location: string | null
          location_lat: number | null
          location_lng: number | null
          start_at: string
          end_at: string
          all_day: boolean
          status: 'confirmed' | 'tentative' | 'cancelled'
          recurrence_rule: string | null
          recurrence_end: string | null
          parent_event_id: string | null
          reminder_minutes: number[] | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          calendar_id: string
          created_by: string
          title: string
          description?: string | null
          location?: string | null
          location_lat?: number | null
          location_lng?: number | null
          start_at: string
          end_at: string
          all_day?: boolean
          status?: 'confirmed' | 'tentative' | 'cancelled'
          recurrence_rule?: string | null
          recurrence_end?: string | null
          parent_event_id?: string | null
          reminder_minutes?: number[] | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          calendar_id?: string
          title?: string
          description?: string | null
          location?: string | null
          location_lat?: number | null
          location_lng?: number | null
          start_at?: string
          end_at?: string
          all_day?: boolean
          status?: 'confirmed' | 'tentative' | 'cancelled'
          recurrence_rule?: string | null
          recurrence_end?: string | null
          parent_event_id?: string | null
          reminder_minutes?: number[] | null
          updated_at?: string
        }
      }
      tasks: {
        Row: {
          id: string
          team_id: string
          project_id: string | null
          title: string
          description: string | null
          status: 'todo' | 'in_progress' | 'done' | 'cancelled'
          priority: 'low' | 'medium' | 'high' | 'urgent'
          assignee_id: string | null
          created_by: string
          due_date: string | null
          completed_at: string | null
          position: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          team_id: string
          project_id?: string | null
          title: string
          description?: string | null
          status?: 'todo' | 'in_progress' | 'done' | 'cancelled'
          priority?: 'low' | 'medium' | 'high' | 'urgent'
          assignee_id?: string | null
          created_by: string
          due_date?: string | null
          completed_at?: string | null
          position?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          project_id?: string | null
          title?: string
          description?: string | null
          status?: 'todo' | 'in_progress' | 'done' | 'cancelled'
          priority?: 'low' | 'medium' | 'high' | 'urgent'
          assignee_id?: string | null
          due_date?: string | null
          completed_at?: string | null
          position?: number
          updated_at?: string
        }
      }
      projects: {
        Row: {
          id: string
          team_id: string
          name: string
          description: string | null
          created_by: string
          archived: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          team_id: string
          name: string
          description?: string | null
          created_by: string
          archived?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          name?: string
          description?: string | null
          archived?: boolean
          updated_at?: string
        }
      }
      files: {
        Row: {
          id: string
          project_id: string
          uploaded_by: string
          name: string
          storage_path: string
          mime_type: string | null
          size_bytes: number | null
          thumbnail_path: string | null
          tags: string[] | null
          deadline: string | null
          auto_event_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          project_id: string
          uploaded_by: string
          name: string
          storage_path: string
          mime_type?: string | null
          size_bytes?: number | null
          thumbnail_path?: string | null
          tags?: string[] | null
          deadline?: string | null
          auto_event_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          name?: string
          storage_path?: string
          mime_type?: string | null
          size_bytes?: number | null
          thumbnail_path?: string | null
          tags?: string[] | null
          deadline?: string | null
          auto_event_id?: string | null
          updated_at?: string
        }
      }
      notifications: {
        Row: {
          id: string
          user_id: string
          type: string
          title: string
          body: string | null
          resource_type: string | null
          resource_id: string | null
          channels: string[]
          read_at: string | null
          sent_at: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          type: string
          title: string
          body?: string | null
          resource_type?: string | null
          resource_id?: string | null
          channels?: string[]
          read_at?: string | null
          sent_at?: string
          created_at?: string
        }
        Update: {
          read_at?: string | null
        }
      }
      audit_logs: {
        Row: {
          id: string
          team_id: string | null
          user_id: string | null
          action: string
          resource_type: string
          resource_id: string | null
          metadata: Json | null
          ip_address: string | null
          created_at: string
        }
        Insert: {
          id?: string
          team_id?: string | null
          user_id?: string | null
          action: string
          resource_type: string
          resource_id?: string | null
          metadata?: Json | null
          ip_address?: string | null
          created_at?: string
        }
        Update: never
      }
    }
    Enums: {
      membership_role: 'owner' | 'admin' | 'member' | 'guest'
      invitation_status: 'pending' | 'accepted' | 'expired' | 'revoked'
      calendar_visibility: 'private' | 'team' | 'public'
      calendar_permission: 'read' | 'write' | 'manage'
      event_status: 'confirmed' | 'tentative' | 'cancelled'
      attendee_response: 'pending' | 'accepted' | 'declined' | 'tentative'
      task_status: 'todo' | 'in_progress' | 'done' | 'cancelled'
      task_priority: 'low' | 'medium' | 'high' | 'urgent'
      notification_type:
        | 'event_invite'
        | 'event_updated'
        | 'event_reminder'
        | 'task_assigned'
        | 'task_updated'
        | 'task_due_soon'
        | 'file_uploaded'
        | 'file_deadline'
        | 'team_invite'
        | 'member_joined'
        | 'permission_changed'
      notification_channel: 'in_app' | 'web_push' | 'email'
    }
  }
}
