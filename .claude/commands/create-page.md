# /create-page — App Router 페이지 스캐폴딩

사용자가 요청한 페이지를 Next.js App Router 규칙에 맞게 생성하라.

## 입력
- 경로 (예: `calendar/[eventId]`, `teams/[teamId]/settings`)
- 인증 여부: 인증 필요 → `(app)`, 비인증 → `(auth)`

## 규칙

### 파일 위치
- 인증 필요: `src/app/(app)/{경로}/page.tsx`
- 비인증: `src/app/(auth)/{경로}/page.tsx`

### 서버 vs 클라이언트
- **기본은 서버 컴포넌트** (DOM 조작 없으면 `"use client"` 금지)
- FullCalendar, 드래그앤드롭 등 DOM 필요 시에만 `"use client"` 사용
- 서버 컴포넌트에서 데이터 fetch → props로 클라이언트 컴포넌트에 전달

### TypeScript
```typescript
type Props = {
  params: Promise<{ id: string }>
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>
}
```

### Supabase 데이터 접근
```typescript
import { createClient } from '@/lib/supabase/server'

export default async function Page({ params }: Props) {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  // ... 데이터 fetch
}
```

### 디자인 규칙 (Apple 미니멀)
- 페이지 컨테이너: `px-8 py-6 md:px-12 md:py-8`
- 페이지 제목: `text-2xl font-semibold tracking-tight text-neutral-900`
- 보조 텍스트: `text-sm text-neutral-500`
- **아이콘/픽토그램 절대 금지** — 텍스트 레이블만 사용
- 빈 상태: 텍스트 중심, 삽화 없음

### 함께 생성할 파일
1. `page.tsx` — 메인 페이지
2. `loading.tsx` — 스켈레톤 로딩 (`animate-pulse`, 스피너 금지)
3. `error.tsx` — 에러 바운더리 (`"use client"`, reset 버튼 포함)

### loading.tsx 템플릿
```typescript
export default function Loading() {
  return (
    <div className="px-8 py-6 md:px-12 md:py-8 space-y-6">
      <div className="h-8 w-48 bg-neutral-200 rounded animate-pulse" />
      <div className="space-y-4">
        <div className="h-4 w-full bg-neutral-200 rounded animate-pulse" />
        <div className="h-4 w-3/4 bg-neutral-200 rounded animate-pulse" />
      </div>
    </div>
  )
}
```

### error.tsx 템플릿
```typescript
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="px-8 py-6 md:px-12 md:py-8">
      <h2 className="text-xl font-semibold tracking-tight text-neutral-900">
        문제가 발생했습니다
      </h2>
      <p className="mt-2 text-sm text-neutral-500">{error.message}</p>
      <button
        onClick={reset}
        className="mt-4 bg-neutral-900 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-neutral-700 transition-colors duration-200"
      >
        다시 시도
      </button>
    </div>
  )
}
```
