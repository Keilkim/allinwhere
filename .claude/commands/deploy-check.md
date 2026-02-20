# /deploy-check — 배포 전 체크리스트

Vercel + Supabase 배포 전에 모든 항목을 검증하라.

## 체크리스트

### 1. TypeScript
```bash
npx tsc --noEmit
```
- 타입 에러 0건 확인

### 2. 린팅
```bash
npx next lint
```
- 린트 에러 0건 확인

### 3. 빌드
```bash
npx next build
```
- 빌드 성공 확인
- 번들 크기 확인 (큰 청크 → 코드 스플리팅 제안)

### 4. 환경 변수
- `.env.example`에 모든 변수 문서화 확인
- 필수 변수 목록:
  - `NEXT_PUBLIC_SUPABASE_URL`
  - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - `SUPABASE_SERVICE_ROLE_KEY`
  - `CRON_SECRET`
- `SUPABASE_SERVICE_ROLE_KEY`가 클라이언트에 노출되지 않는지 확인
  - `NEXT_PUBLIC_` 접두사 없는지 확인

### 5. Supabase
- 마이그레이션 최신 상태: `supabase db push`
- 타입 재생성: `supabase gen types typescript`
- 모든 테이블에 RLS 활성화 확인
- Storage 버킷 정책 확인

### 6. 보안
- `console.log` 프로덕션 코드에 없는지 확인
- 하드코딩된 시크릿/키 없는지 확인
- `middleware.ts`가 `(app)` 라우트 보호 확인
- `getSession()` 서버 사이드 사용 없는지 (`getUser()` 사용)

### 7. Vercel 설정
- `vercel.json` Cron 엔트리가 Route Handler와 매칭
- 보안 헤더 설정 확인
- 리다이렉트/리라이트 규칙 확인

### 8. 성능
- 이미지: `next/image` 사용
- 폰트: `next/font` 사용
- 큰 라이브러리: dynamic import 사용
- 서버 컴포넌트 기본 (불필요한 `"use client"` 없는지)

### 9. SEO / 접근성
- 모든 페이지에 `<title>` 및 `metadata` export
- 인터랙티브 요소에 적절한 ARIA 속성
- 키보드 네비게이션 가능

## 실행 방법
위 항목을 순서대로 검증하고, 각 항목에 대해:
- ✅ 통과
- ❌ 실패 + 구체적 수정 방법

최종 결과를 요약하여 배포 가능 여부를 판단하라.
