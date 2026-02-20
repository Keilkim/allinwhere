# /db-migration — Supabase SQL 마이그레이션 생성

요청된 스키마 변경을 SQL 마이그레이션 파일로 생성하라.

## 파일 위치
- `supabase/migrations/{YYYYMMDDHHMMSS}_{설명}.sql`
- 예: `supabase/migrations/20260220120000_add_tasks_table.sql`

## 필수 규칙

### 네이밍
- 테이블: 복수형 snake_case (`events`, `team_invitations`)
- 컬럼: snake_case (`created_by`, `start_at`)
- 인덱스: `idx_{테이블}_{컬럼}` (`idx_events_calendar`)
- ENUM: snake_case (`task_status`, `membership_role`)

### 기본 구조
```sql
-- ============================================================
-- {테이블/변경 설명}
-- ============================================================

-- 테이블 생성 시
CREATE TABLE IF NOT EXISTS {테이블} (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- 컬럼 정의...
    created_at  TIMESTAMPTZ DEFAULT now(),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

-- 테이블 설명
COMMENT ON TABLE {테이블} IS '{한국어 설명}';

-- 인덱스 (FK, WHERE/ORDER BY 사용 컬럼, RLS 참조 컬럼)
CREATE INDEX IF NOT EXISTS idx_{테이블}_{컬럼} ON {테이블}({컬럼});

-- updated_at 트리거
CREATE TRIGGER set_{테이블}_updated_at
    BEFORE UPDATE ON {테이블}
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

### 필수 컬럼
- PK: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
- 타임스탬프: `created_at TIMESTAMPTZ DEFAULT now()`
- 타임스탬프: `updated_at TIMESTAMPTZ DEFAULT now()`

### 인덱스 규칙
- 모든 FK 컬럼에 인덱스
- RLS 정책에서 참조하는 컬럼에 인덱스
- WHERE/ORDER BY 자주 사용 컬럼에 인덱스
- 배열 컬럼: GIN 인덱스 (`USING GIN`)
- 텍스트 검색: pg_trgm GIN 인덱스

### ENUM 타입
```sql
CREATE TYPE task_status AS ENUM ('todo', 'in_progress', 'done', 'cancelled');
```
- ENUM은 테이블 생성 전에 정의
- `IF NOT EXISTS`는 ENUM에서 지원 안 됨 → `DO $$ ... $$` 블록으로 방어:
```sql
DO $$ BEGIN
    CREATE TYPE task_status AS ENUM ('todo', 'in_progress', 'done', 'cancelled');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
```

### 변경 후 안내
마이그레이션 작성 후 사용자에게 안내:
1. `supabase db push` (리모트) 또는 `supabase migration up` (로컬)
2. `supabase gen types typescript --project-id <ref> > src/types/database.ts`
3. 관련 RLS 정책이 필요하면 `/add-rls-policy` 사용 안내

### updated_at 트리거 함수 (최초 1회)
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```
