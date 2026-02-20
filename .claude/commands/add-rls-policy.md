# /add-rls-policy — Row Level Security 정책 추가

요청된 테이블에 RLS 정책을 추가하는 마이그레이션을 생성하라.

## 파일 위치
- 기존 마이그레이션에 추가하거나 새 파일: `supabase/migrations/{timestamp}_rls_{테이블}.sql`

## 기본 구조

```sql
-- RLS 활성화
ALTER TABLE {테이블} ENABLE ROW LEVEL SECURITY;

-- 정책 추가
CREATE POLICY "{테이블}_{동작}_{스코프}"
ON {테이블}
FOR {SELECT|INSERT|UPDATE|DELETE}
TO authenticated
USING ({조건});
```

## 정책 네이밍
- `{테이블}_{동작}_{스코프}`
- 예: `events_select_team_member`, `profiles_update_own`

## 공통 패턴

### 1. 본인만 접근
```sql
CREATE POLICY "profiles_select_own"
ON profiles FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "profiles_update_own"
ON profiles FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());
```

### 2. 팀 멤버 접근
```sql
CREATE POLICY "tasks_select_team_member"
ON tasks FOR SELECT
TO authenticated
USING (is_team_member(team_id));
```

### 3. 팀 관리자 전용
```sql
CREATE POLICY "memberships_delete_admin"
ON memberships FOR DELETE
TO authenticated
USING (has_team_role(team_id, 'admin'));
```

### 4. 캘린더 스코프 접근
```sql
CREATE POLICY "events_select_calendar_access"
ON events FOR SELECT
TO authenticated
USING (can_access_calendar(calendar_id, 'read'));
```

### 5. 생성자 또는 관리자
```sql
CREATE POLICY "events_delete_creator_or_admin"
ON events FOR DELETE
TO authenticated
USING (
    created_by = auth.uid()
    OR can_access_calendar(calendar_id, 'manage')
);
```

## 헬퍼 함수 (이미 존재해야 함)

```sql
-- 팀 멤버 확인
CREATE OR REPLACE FUNCTION is_team_member(check_team_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM memberships
        WHERE team_id = check_team_id AND user_id = auth.uid()
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 팀 역할 확인 (owner < admin < member < guest 순서)
CREATE OR REPLACE FUNCTION has_team_role(check_team_id UUID, required_role membership_role)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM memberships
        WHERE team_id = check_team_id
        AND user_id = auth.uid()
        AND role <= required_role
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- 캘린더 접근 확인
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
```

## 규칙
- SELECT, INSERT, UPDATE, DELETE 각각 **별도 정책** 생성
- RLS WHERE 절에서 참조하는 컬럼에 반드시 **인덱스** 추가
- `IN` 대신 `EXISTS` 사용 (성능)
- `SECURITY DEFINER` 함수 사용 시 주의 (RLS 우회)
- 모든 정책에 `TO authenticated` 지정 (anonymous 차단)
