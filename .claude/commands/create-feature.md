# /create-feature — 전체 피처 E2E 스캐폴딩

요청된 기능을 데이터베이스부터 UI까지 전체 스택으로 설계하고 구현하라.

## 입력
- 기능 이름 (예: "팀 초대", "일정 반복", "파일 업로드")

## 실행 순서

### 1단계: DB 스키마
- 필요한 테이블/컬럼 추가 (`/db-migration` 패턴 따름)
- RLS 정책 추가 (`/add-rls-policy` 패턴 따름)
- 인덱스 추가

### 2단계: 타입 & 유효성 검증
- `src/types/` 에 타입 정의 (database.ts 자동생성 후 alias)
- `src/lib/validators/{feature}.ts`에 Zod 스키마

### 3단계: Server Actions
- `src/actions/{feature}.ts` (`/create-server-action` 패턴 따름)
- CRUD + 비즈니스 로직
- 인증 + 유효성 검증 + 에러 핸들링

### 4단계: 페이지 & 컴포넌트
- 페이지: `src/app/(app)/{feature}/page.tsx` (`/create-page` 패턴)
- 컴포넌트: `src/app/(app)/{feature}/_components/` (feature-specific)
- 공용 컴포넌트: `src/components/` (`/create-component` 패턴)

### 5단계: 실시간 구독 (해당 시)
- Supabase Realtime 구독 필요 여부 판단
- 필요 시 `useRealtime` 훅으로 구독 설정

### 6단계: 알림 연동
- 이 기능에서 알림을 트리거해야 하는 이벤트 식별
- notifications 테이블에 레코드 삽입

### 7단계: 네비게이션 업데이트
- 새 최상위 라우트 추가 시 사이드바 네비게이션 업데이트
- `src/components/layout/sidebar.tsx` 수정

## 체크리스트 출력
기능 설계 시 다음 체크리스트를 먼저 사용자에게 제시:

```
□ DB 마이그레이션 파일
□ RLS 정책
□ Zod 유효성 검증 스키마
□ Server Action(s)
□ 페이지(s)
□ 컴포넌트(s)
□ 실시간 구독 (필요 시)
□ 알림 트리거 (필요 시)
□ 사이드바 네비게이션 (필요 시)
□ 로딩/에러 상태
```

## 디자인 규칙 (전체 적용)
- **아이콘/픽토그램 절대 금지**
- 색상: neutral 팔레트 중심
- 폰트: 최대 font-semibold(600)
- 로딩: 스켈레톤(animate-pulse)
- 인터랙션: transition-colors duration-200
- 빈 상태: 텍스트 중심, 삽화 없음
