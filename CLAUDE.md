# Allinwhere — 프로젝트 컨벤션

## 프로젝트 개요
Google Calendar 기반 그룹웨어 웹앱. 공유 캘린더/Task/파일/알림/지도 통합.
Vercel + Supabase 배포. Apple 스타일 슈퍼 미니멀 디자인.

## 기술 스택
- **프론트**: Next.js 15 (App Router) + TypeScript + Tailwind CSS
- **백엔드**: Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions)
- **캘린더**: FullCalendar
- **배포**: Vercel
- **유효성 검증**: Zod
- **날짜**: date-fns

## 디자인 시스템

### 절대 금지
- 아이콘, 이모지, 픽토그램 사용 금지 → 텍스트 레이블만
- `font-bold` (700) 사용 금지 → 최대 `font-semibold` (600)
- 스피너/로더 금지 → 스켈레톤 (`animate-pulse`)만
- 과한 그림자 금지 → 최대 `shadow-sm`
- bounce/spring 애니메이션 금지

### 색상
- 텍스트 기본: `text-neutral-900`
- 텍스트 보조: `text-neutral-500`
- 텍스트 비활성: `text-neutral-400`
- 보더: `border-neutral-200`
- 표면: `bg-neutral-50`
- 배경: `bg-white`
- 인터랙티브: `bg-neutral-900 text-white`, 호버 `bg-neutral-700`
- 위험: `bg-red-600`, 호버 `bg-red-700`
- 성공: `text-emerald-600`
- 경고: `text-amber-600`

### 타이포그래피
- Display: `text-3xl font-semibold tracking-tight`
- Heading: `text-xl font-semibold tracking-tight`
- Subheading: `text-base font-medium`
- Body: `text-sm`
- Caption: `text-xs text-neutral-500`
- Label: `text-xs font-medium uppercase tracking-wide`

### 컴포넌트 패턴
- 버튼: `rounded-lg px-4 py-2 text-sm font-medium transition-colors duration-200`
- 카드: `border border-neutral-200 rounded-xl p-6` (그림자 없음)
- 인풋: `border border-neutral-200 rounded-lg px-3 py-2 text-sm`
- 모달: `rounded-2xl p-8 shadow-lg`, 배경 `bg-black/50 backdrop-blur-sm`
- 포커스: `focus:ring-2 focus:ring-neutral-900 focus:ring-offset-2`

### 스페이싱
- 페이지: `px-8 py-6 md:px-12 md:py-8`
- 카드: `p-6`
- 폼 필드: `space-y-4`
- 섹션: `space-y-6`

### 로딩
- 스켈레톤만 사용: `bg-neutral-200 rounded animate-pulse`
- 모든 페이지에 `loading.tsx` 생성

## Supabase 규칙

### 클라이언트
- 브라우저: `src/lib/supabase/client.ts` (`createBrowserClient`)
- 서버: `src/lib/supabase/server.ts` (`createServerClient` + cookies)
- 미들웨어: `src/lib/supabase/middleware.ts`
- Admin: `src/lib/supabase/admin.ts` (service role, 서버 전용)

### 인증
- 서버에서 항상 `supabase.auth.getUser()` 사용
- `getSession()` 서버 사이드 사용 금지 (신뢰 불가)
- `SUPABASE_SERVICE_ROLE_KEY`는 절대 클라이언트에 노출 금지

### RLS
- 모든 테이블에 RLS 활성화
- 헬퍼 함수: `is_team_member()`, `has_team_role()`, `can_access_calendar()`
- SELECT/INSERT/UPDATE/DELETE 각각 별도 정책

## 파일/폴더 규칙

### 네이밍
- 폴더: kebab-case (`calendar`, `team-settings`)
- 컴포넌트 파일: kebab-case (`event-form.tsx`)
- 컴포넌트 이름: PascalCase (`EventForm`)
- 서버 액션: camelCase (`createEvent`)
- DB 테이블: 복수형 snake_case (`events`, `team_invitations`)
- DB 컬럼: snake_case (`created_by`, `start_at`)

### 구조
- 인증 필요 페이지: `src/app/(app)/`
- 비인증 페이지: `src/app/(auth)/`
- feature-specific 컴포넌트: `src/app/(app)/{feature}/_components/`
- 공용 컴포넌트: `src/components/{ui|layout|shared}/`
- Server Action: `src/actions/{feature}.ts`
- Zod 스키마: `src/lib/validators/{feature}.ts`

### barrel export 금지
- `index.ts`에서 re-export 하지 않음
- 각 파일에서 직접 import

## Server Action 패턴
```typescript
'use server'
// 1. Supabase 서버 클라이언트 생성
// 2. getUser()로 인증 확인
// 3. Zod로 입력 검증
// 4. DB 작업 (RLS가 1차 권한 검증)
// 5. revalidatePath() 캐시 무효화
// 6. ActionResult<T> 반환
```

## 커밋 메시지
- 한국어 사용
- prefix: `feat:`, `fix:`, `refactor:`, `style:`, `chore:`, `docs:`, `test:`
