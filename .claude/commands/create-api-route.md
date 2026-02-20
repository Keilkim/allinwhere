# /create-api-route — Route Handler 생성

웹훅, Cron, 외부 연동용 Route Handler를 생성하라.

## 파일 위치
- `src/app/api/{경로}/route.ts`

## 사용 시기
- Supabase 웹훅 수신
- Vercel Cron 작업
- 외부 서비스 콜백 (OAuth 등)
- 일반 CRUD는 Server Action 사용 (Route Handler 아님)

## 템플릿

### 웹훅 핸들러
```typescript
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/admin'

export async function POST(request: NextRequest) {
  // 1. 시크릿 검증
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.WEBHOOK_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // 2. 요청 파싱
  const body = await request.json()

  // 3. 비즈니스 로직 (admin 클라이언트 사용)
  const supabase = createClient()
  // ...

  return NextResponse.json({ success: true })
}
```

### Vercel Cron 핸들러
```typescript
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  // Vercel Cron 인증
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // Cron 로직 실행
  // ...

  return NextResponse.json({ success: true, processed: count })
}
```

## 규칙

### 인증
- 웹훅: `Authorization: Bearer {WEBHOOK_SECRET}` 헤더 검증
- Cron: `Authorization: Bearer {CRON_SECRET}` 헤더 검증
- 외부 콜백: 해당 서비스의 서명 검증 방식 사용

### Supabase 클라이언트
- 사용자 컨텍스트 밖이므로 **admin 클라이언트** (service role) 사용
- `src/lib/supabase/admin.ts`에서 임포트

### 응답
- 항상 `NextResponse.json()` 사용
- 적절한 HTTP 상태 코드 반환
- 요청/응답 타입을 명시적으로 정의

### vercel.json Cron 등록
Cron 엔드포인트 생성 시 `vercel.json`에도 등록:
```json
{
  "crons": [
    { "path": "/api/cron/notifications", "schedule": "*/5 * * * *" }
  ]
}
```
