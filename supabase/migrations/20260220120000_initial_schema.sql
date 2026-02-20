-- ============================================================
-- Allinwhere 초기 스키마
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================
-- 공용 함수: updated_at 트리거
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- PROFILES (auth.users 확장)
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email       TEXT NOT NULL,
    full_name   TEXT,
    avatar_url  TEXT,
    timezone    TEXT DEFAULT 'Asia/Seoul',
    locale      TEXT DEFAULT 'ko',
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE profiles IS '사용자 프로필 (auth.users 확장)';

CREATE TRIGGER set_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 신규 가입 시 프로필 자동 생성
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- TEAMS
-- ============================================================
CREATE TABLE IF NOT EXISTS teams (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        TEXT NOT NULL,
    slug        TEXT UNIQUE NOT NULL,
    description TEXT,
    created_by  UUID NOT NULL REFERENCES profiles(id),
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE teams IS '팀/조직';

CREATE TRIGGER set_teams_updated_at
    BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- MEMBERSHIPS
-- ============================================================
DO $$ BEGIN
    CREATE TYPE membership_role AS ENUM ('owner', 'admin', 'member', 'guest');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS memberships (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team_id     UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    role        membership_role NOT NULL DEFAULT 'member',
    joined_at   TIMESTAMPTZ DEFAULT now(),
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, team_id)
);
COMMENT ON TABLE memberships IS '팀 멤버십 (역할 포함)';

CREATE INDEX IF NOT EXISTS idx_memberships_user ON memberships(user_id);
CREATE INDEX IF NOT EXISTS idx_memberships_team ON memberships(team_id);
CREATE INDEX IF NOT EXISTS idx_memberships_team_role ON memberships(team_id, role);

CREATE TRIGGER set_memberships_updated_at
    BEFORE UPDATE ON memberships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- TEAM INVITATIONS
-- ============================================================
DO $$ BEGIN
    CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'expired', 'revoked');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS team_invitations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id     UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    email       TEXT NOT NULL,
    role        membership_role NOT NULL DEFAULT 'member',
    token       TEXT UNIQUE NOT NULL DEFAULT gen_random_uuid()::text,
    invited_by  UUID NOT NULL REFERENCES profiles(id),
    status      invitation_status DEFAULT 'pending',
    expires_at  TIMESTAMPTZ DEFAULT now() + INTERVAL '7 days',
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE team_invitations IS '팀 초대';

CREATE INDEX IF NOT EXISTS idx_invitations_token ON team_invitations(token);
CREATE INDEX IF NOT EXISTS idx_invitations_email ON team_invitations(email);

CREATE TRIGGER set_invitations_updated_at
    BEFORE UPDATE ON team_invitations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- CALENDARS
-- ============================================================
DO $$ BEGIN
    CREATE TYPE calendar_visibility AS ENUM ('private', 'team', 'public');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS calendars (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id     UUID REFERENCES teams(id) ON DELETE CASCADE,
    owner_id    UUID NOT NULL REFERENCES profiles(id),
    name        TEXT NOT NULL,
    description TEXT,
    color       TEXT DEFAULT '#000000',
    visibility  calendar_visibility DEFAULT 'private',
    is_default  BOOLEAN DEFAULT false,
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE calendars IS '캘린더 (개인/팀)';

CREATE INDEX IF NOT EXISTS idx_calendars_team ON calendars(team_id);
CREATE INDEX IF NOT EXISTS idx_calendars_owner ON calendars(owner_id);

CREATE TRIGGER set_calendars_updated_at
    BEFORE UPDATE ON calendars
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- CALENDAR SHARES
-- ============================================================
DO $$ BEGIN
    CREATE TYPE calendar_permission AS ENUM ('read', 'write', 'manage');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS calendar_shares (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    calendar_id   UUID NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    user_id       UUID REFERENCES profiles(id) ON DELETE CASCADE,
    team_id       UUID REFERENCES teams(id) ON DELETE CASCADE,
    permission    calendar_permission NOT NULL DEFAULT 'read',
    created_at    TIMESTAMPTZ DEFAULT now(),
    CHECK (user_id IS NOT NULL OR team_id IS NOT NULL)
);
COMMENT ON TABLE calendar_shares IS '캘린더 공유 권한';

CREATE INDEX IF NOT EXISTS idx_calendar_shares_calendar ON calendar_shares(calendar_id);
CREATE INDEX IF NOT EXISTS idx_calendar_shares_user ON calendar_shares(user_id);

-- ============================================================
-- EVENTS
-- ============================================================
DO $$ BEGIN
    CREATE TYPE event_status AS ENUM ('confirmed', 'tentative', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS events (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    calendar_id     UUID NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    created_by      UUID NOT NULL REFERENCES profiles(id),
    title           TEXT NOT NULL,
    description     TEXT,
    location        TEXT,
    location_lat    DOUBLE PRECISION,
    location_lng    DOUBLE PRECISION,
    start_at        TIMESTAMPTZ NOT NULL,
    end_at          TIMESTAMPTZ NOT NULL,
    all_day         BOOLEAN DEFAULT false,
    status          event_status DEFAULT 'confirmed',
    recurrence_rule TEXT,
    recurrence_end  TIMESTAMPTZ,
    parent_event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    reminder_minutes INTEGER[],
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE events IS '일정/이벤트';

CREATE INDEX IF NOT EXISTS idx_events_calendar ON events(calendar_id);
CREATE INDEX IF NOT EXISTS idx_events_date_range ON events(start_at, end_at);
CREATE INDEX IF NOT EXISTS idx_events_created_by ON events(created_by);
CREATE INDEX IF NOT EXISTS idx_events_parent ON events(parent_event_id);

CREATE TRIGGER set_events_updated_at
    BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- EVENT ATTENDEES
-- ============================================================
DO $$ BEGIN
    CREATE TYPE attendee_response AS ENUM ('pending', 'accepted', 'declined', 'tentative');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS event_attendees (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id    UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    response    attendee_response DEFAULT 'pending',
    is_organizer BOOLEAN DEFAULT false,
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now(),
    UNIQUE(event_id, user_id)
);
COMMENT ON TABLE event_attendees IS '일정 참석자';

CREATE INDEX IF NOT EXISTS idx_attendees_event ON event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_attendees_user ON event_attendees(user_id);

CREATE TRIGGER set_attendees_updated_at
    BEFORE UPDATE ON event_attendees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- PROJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS projects (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id     UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    description TEXT,
    created_by  UUID NOT NULL REFERENCES profiles(id),
    archived    BOOLEAN DEFAULT false,
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE projects IS '프로젝트 (파일 컨테이너)';

CREATE INDEX IF NOT EXISTS idx_projects_team ON projects(team_id);

CREATE TRIGGER set_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- TASKS
-- ============================================================
DO $$ BEGIN
    CREATE TYPE task_status AS ENUM ('todo', 'in_progress', 'done', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS tasks (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id     UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    project_id  UUID REFERENCES projects(id) ON DELETE SET NULL,
    title       TEXT NOT NULL,
    description TEXT,
    status      task_status DEFAULT 'todo',
    priority    task_priority DEFAULT 'medium',
    assignee_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_by  UUID NOT NULL REFERENCES profiles(id),
    due_date    TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    position    INTEGER DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE tasks IS '공유 태스크';

CREATE INDEX IF NOT EXISTS idx_tasks_team ON tasks(team_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assignee ON tasks(assignee_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(team_id, status);
CREATE INDEX IF NOT EXISTS idx_tasks_due ON tasks(due_date);

CREATE TRIGGER set_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- TASK <-> EVENT LINKS
-- ============================================================
CREATE TABLE IF NOT EXISTS task_event_links (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    event_id    UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ DEFAULT now(),
    UNIQUE(task_id, event_id)
);
COMMENT ON TABLE task_event_links IS 'Task-Event 양방향 링크';

CREATE INDEX IF NOT EXISTS idx_task_event_task ON task_event_links(task_id);
CREATE INDEX IF NOT EXISTS idx_task_event_event ON task_event_links(event_id);

-- ============================================================
-- FILES
-- ============================================================
CREATE TABLE IF NOT EXISTS files (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id      UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    uploaded_by     UUID NOT NULL REFERENCES profiles(id),
    name            TEXT NOT NULL,
    storage_path    TEXT NOT NULL,
    mime_type       TEXT,
    size_bytes      BIGINT,
    thumbnail_path  TEXT,
    tags            TEXT[],
    deadline        TIMESTAMPTZ,
    auto_event_id   UUID REFERENCES events(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE files IS '프로젝트 파일';

CREATE INDEX IF NOT EXISTS idx_files_project ON files(project_id);
CREATE INDEX IF NOT EXISTS idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_files_tags ON files USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_files_name_trgm ON files USING GIN(name gin_trgm_ops);

CREATE TRIGGER set_files_updated_at
    BEFORE UPDATE ON files
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
DO $$ BEGIN
    CREATE TYPE notification_type AS ENUM (
        'event_invite', 'event_updated', 'event_reminder',
        'task_assigned', 'task_updated', 'task_due_soon',
        'file_uploaded', 'file_deadline',
        'team_invite', 'member_joined', 'permission_changed'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE notification_channel AS ENUM ('in_app', 'web_push', 'email');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS notifications (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type            notification_type NOT NULL,
    title           TEXT NOT NULL,
    body            TEXT,
    resource_type   TEXT,
    resource_id     UUID,
    channels        notification_channel[] DEFAULT '{in_app}',
    read_at         TIMESTAMPTZ,
    sent_at         TIMESTAMPTZ DEFAULT now(),
    created_at      TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE notifications IS '알림';

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON notifications(user_id) WHERE read_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_notifications_resource ON notifications(resource_type, resource_id);

-- ============================================================
-- NOTIFICATION PREFERENCES
-- ============================================================
CREATE TABLE IF NOT EXISTS notification_preferences (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    team_id           UUID REFERENCES teams(id) ON DELETE CASCADE,
    notification_type notification_type NOT NULL,
    in_app            BOOLEAN DEFAULT true,
    web_push          BOOLEAN DEFAULT true,
    email             BOOLEAN DEFAULT false,
    created_at        TIMESTAMPTZ DEFAULT now(),
    updated_at        TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, team_id, notification_type)
);
COMMENT ON TABLE notification_preferences IS '알림 수신 설정';

CREATE TRIGGER set_notification_prefs_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- AUDIT LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id         UUID REFERENCES teams(id) ON DELETE SET NULL,
    user_id         UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action          TEXT NOT NULL,
    resource_type   TEXT NOT NULL,
    resource_id     UUID,
    metadata        JSONB,
    ip_address      INET,
    created_at      TIMESTAMPTZ DEFAULT now()
);
COMMENT ON TABLE audit_logs IS '감사 로그';

CREATE INDEX IF NOT EXISTS idx_audit_team ON audit_logs(team_id);
CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at DESC);

-- ============================================================
-- PUSH SUBSCRIPTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS push_subscriptions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    endpoint        TEXT NOT NULL,
    p256dh          TEXT NOT NULL,
    auth_key        TEXT NOT NULL,
    created_at      TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, endpoint)
);
COMMENT ON TABLE push_subscriptions IS '웹푸시 구독 정보';

-- ============================================================
-- RLS 헬퍼 함수
-- ============================================================

CREATE OR REPLACE FUNCTION is_team_member(check_team_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM memberships
        WHERE team_id = check_team_id AND user_id = auth.uid()
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION has_team_role(check_team_id UUID, required_role membership_role)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM memberships
        WHERE team_id = check_team_id
        AND user_id = auth.uid()
        AND role <= required_role
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION can_access_calendar(check_calendar_id UUID, required_permission calendar_permission)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM calendars c
        LEFT JOIN calendar_shares cs ON cs.calendar_id = c.id
        WHERE c.id = check_calendar_id
        AND (
            c.owner_id = auth.uid()
            OR (cs.user_id = auth.uid() AND cs.permission >= required_permission)
            OR (c.team_id IS NOT NULL AND is_team_member(c.team_id))
        )
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
