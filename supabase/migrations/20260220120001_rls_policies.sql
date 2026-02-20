-- ============================================================
-- RLS 정책 (모든 테이블)
-- ============================================================

-- ============================================================
-- PROFILES
-- ============================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_all"
ON profiles FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "profiles_update_own"
ON profiles FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- ============================================================
-- TEAMS
-- ============================================================
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

CREATE POLICY "teams_select_member"
ON teams FOR SELECT
TO authenticated
USING (is_team_member(id));

CREATE POLICY "teams_insert_authenticated"
ON teams FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());

CREATE POLICY "teams_update_admin"
ON teams FOR UPDATE
TO authenticated
USING (has_team_role(id, 'admin'))
WITH CHECK (has_team_role(id, 'admin'));

CREATE POLICY "teams_delete_owner"
ON teams FOR DELETE
TO authenticated
USING (has_team_role(id, 'owner'));

-- ============================================================
-- MEMBERSHIPS
-- ============================================================
ALTER TABLE memberships ENABLE ROW LEVEL SECURITY;

CREATE POLICY "memberships_select_team_member"
ON memberships FOR SELECT
TO authenticated
USING (is_team_member(team_id));

CREATE POLICY "memberships_insert_admin"
ON memberships FOR INSERT
TO authenticated
WITH CHECK (has_team_role(team_id, 'admin') OR user_id = auth.uid());

CREATE POLICY "memberships_update_admin"
ON memberships FOR UPDATE
TO authenticated
USING (has_team_role(team_id, 'admin'))
WITH CHECK (has_team_role(team_id, 'admin'));

CREATE POLICY "memberships_delete_self_or_admin"
ON memberships FOR DELETE
TO authenticated
USING (user_id = auth.uid() OR has_team_role(team_id, 'admin'));

-- ============================================================
-- TEAM INVITATIONS
-- ============================================================
ALTER TABLE team_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "invitations_select_team_member_or_invitee"
ON team_invitations FOR SELECT
TO authenticated
USING (
    is_team_member(team_id)
    OR email = (SELECT email FROM profiles WHERE id = auth.uid())
);

CREATE POLICY "invitations_insert_admin"
ON team_invitations FOR INSERT
TO authenticated
WITH CHECK (has_team_role(team_id, 'admin'));

CREATE POLICY "invitations_update_admin_or_invitee"
ON team_invitations FOR UPDATE
TO authenticated
USING (
    has_team_role(team_id, 'admin')
    OR email = (SELECT email FROM profiles WHERE id = auth.uid())
);

CREATE POLICY "invitations_delete_admin"
ON team_invitations FOR DELETE
TO authenticated
USING (has_team_role(team_id, 'admin'));

-- ============================================================
-- CALENDARS
-- ============================================================
ALTER TABLE calendars ENABLE ROW LEVEL SECURITY;

CREATE POLICY "calendars_select_accessible"
ON calendars FOR SELECT
TO authenticated
USING (
    owner_id = auth.uid()
    OR (team_id IS NOT NULL AND is_team_member(team_id))
    OR EXISTS (
        SELECT 1 FROM calendar_shares
        WHERE calendar_id = id AND user_id = auth.uid()
    )
);

CREATE POLICY "calendars_insert_authenticated"
ON calendars FOR INSERT
TO authenticated
WITH CHECK (owner_id = auth.uid());

CREATE POLICY "calendars_update_owner_or_manager"
ON calendars FOR UPDATE
TO authenticated
USING (
    owner_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM calendar_shares
        WHERE calendar_id = id AND user_id = auth.uid() AND permission = 'manage'
    )
);

CREATE POLICY "calendars_delete_owner"
ON calendars FOR DELETE
TO authenticated
USING (owner_id = auth.uid());

-- ============================================================
-- CALENDAR SHARES
-- ============================================================
ALTER TABLE calendar_shares ENABLE ROW LEVEL SECURITY;

CREATE POLICY "calendar_shares_select_involved"
ON calendar_shares FOR SELECT
TO authenticated
USING (
    user_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM calendars WHERE id = calendar_id AND owner_id = auth.uid()
    )
);

CREATE POLICY "calendar_shares_insert_calendar_owner"
ON calendar_shares FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM calendars WHERE id = calendar_id AND owner_id = auth.uid()
    )
);

CREATE POLICY "calendar_shares_delete_calendar_owner"
ON calendar_shares FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM calendars WHERE id = calendar_id AND owner_id = auth.uid()
    )
);

-- ============================================================
-- EVENTS
-- ============================================================
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "events_select_calendar_access"
ON events FOR SELECT
TO authenticated
USING (can_access_calendar(calendar_id, 'read'));

CREATE POLICY "events_insert_calendar_write"
ON events FOR INSERT
TO authenticated
WITH CHECK (can_access_calendar(calendar_id, 'write') AND created_by = auth.uid());

CREATE POLICY "events_update_creator_or_manager"
ON events FOR UPDATE
TO authenticated
USING (
    created_by = auth.uid()
    OR can_access_calendar(calendar_id, 'manage')
);

CREATE POLICY "events_delete_creator_or_manager"
ON events FOR DELETE
TO authenticated
USING (
    created_by = auth.uid()
    OR can_access_calendar(calendar_id, 'manage')
);

-- ============================================================
-- EVENT ATTENDEES
-- ============================================================
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

CREATE POLICY "attendees_select_event_access"
ON event_attendees FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM events e
        WHERE e.id = event_id AND can_access_calendar(e.calendar_id, 'read')
    )
);

CREATE POLICY "attendees_insert_event_creator"
ON event_attendees FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM events e
        WHERE e.id = event_id AND (e.created_by = auth.uid() OR can_access_calendar(e.calendar_id, 'write'))
    )
);

CREATE POLICY "attendees_update_own_response"
ON event_attendees FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "attendees_delete_event_creator"
ON event_attendees FOR DELETE
TO authenticated
USING (
    user_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM events e
        WHERE e.id = event_id AND e.created_by = auth.uid()
    )
);

-- ============================================================
-- PROJECTS
-- ============================================================
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "projects_select_team_member"
ON projects FOR SELECT
TO authenticated
USING (is_team_member(team_id));

CREATE POLICY "projects_insert_team_member"
ON projects FOR INSERT
TO authenticated
WITH CHECK (is_team_member(team_id) AND created_by = auth.uid());

CREATE POLICY "projects_update_team_admin"
ON projects FOR UPDATE
TO authenticated
USING (has_team_role(team_id, 'admin') OR created_by = auth.uid());

CREATE POLICY "projects_delete_team_admin"
ON projects FOR DELETE
TO authenticated
USING (has_team_role(team_id, 'admin'));

-- ============================================================
-- TASKS
-- ============================================================
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tasks_select_team_member"
ON tasks FOR SELECT
TO authenticated
USING (is_team_member(team_id));

CREATE POLICY "tasks_insert_team_member"
ON tasks FOR INSERT
TO authenticated
WITH CHECK (is_team_member(team_id) AND created_by = auth.uid());

CREATE POLICY "tasks_update_team_member"
ON tasks FOR UPDATE
TO authenticated
USING (is_team_member(team_id));

CREATE POLICY "tasks_delete_creator_or_admin"
ON tasks FOR DELETE
TO authenticated
USING (created_by = auth.uid() OR has_team_role(team_id, 'admin'));

-- ============================================================
-- TASK EVENT LINKS
-- ============================================================
ALTER TABLE task_event_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY "task_event_links_select_task_access"
ON task_event_links FOR SELECT
TO authenticated
USING (
    EXISTS (SELECT 1 FROM tasks t WHERE t.id = task_id AND is_team_member(t.team_id))
);

CREATE POLICY "task_event_links_insert_task_access"
ON task_event_links FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (SELECT 1 FROM tasks t WHERE t.id = task_id AND is_team_member(t.team_id))
);

CREATE POLICY "task_event_links_delete_task_access"
ON task_event_links FOR DELETE
TO authenticated
USING (
    EXISTS (SELECT 1 FROM tasks t WHERE t.id = task_id AND is_team_member(t.team_id))
);

-- ============================================================
-- FILES
-- ============================================================
ALTER TABLE files ENABLE ROW LEVEL SECURITY;

CREATE POLICY "files_select_project_team"
ON files FOR SELECT
TO authenticated
USING (
    EXISTS (SELECT 1 FROM projects p WHERE p.id = project_id AND is_team_member(p.team_id))
);

CREATE POLICY "files_insert_project_team"
ON files FOR INSERT
TO authenticated
WITH CHECK (
    uploaded_by = auth.uid()
    AND EXISTS (SELECT 1 FROM projects p WHERE p.id = project_id AND is_team_member(p.team_id))
);

CREATE POLICY "files_update_uploader"
ON files FOR UPDATE
TO authenticated
USING (uploaded_by = auth.uid());

CREATE POLICY "files_delete_uploader_or_admin"
ON files FOR DELETE
TO authenticated
USING (
    uploaded_by = auth.uid()
    OR EXISTS (SELECT 1 FROM projects p WHERE p.id = project_id AND has_team_role(p.team_id, 'admin'))
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_select_own"
ON notifications FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "notifications_update_own"
ON notifications FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ============================================================
-- NOTIFICATION PREFERENCES
-- ============================================================
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notification_prefs_select_own"
ON notification_preferences FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "notification_prefs_insert_own"
ON notification_preferences FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "notification_prefs_update_own"
ON notification_preferences FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "notification_prefs_delete_own"
ON notification_preferences FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- ============================================================
-- AUDIT LOGS (read by admin only, insert by service role)
-- ============================================================
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "audit_logs_select_team_admin"
ON audit_logs FOR SELECT
TO authenticated
USING (team_id IS NOT NULL AND has_team_role(team_id, 'admin'));

-- ============================================================
-- PUSH SUBSCRIPTIONS
-- ============================================================
ALTER TABLE push_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "push_subs_select_own"
ON push_subscriptions FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "push_subs_insert_own"
ON push_subscriptions FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "push_subs_delete_own"
ON push_subscriptions FOR DELETE
TO authenticated
USING (user_id = auth.uid());
