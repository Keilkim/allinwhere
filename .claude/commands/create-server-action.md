# /create-server-action — 타입 안전 Server Action 생성

요청된 Server Action을 Supabase + Zod 패턴으로 생성하라.

## 파일 위치
- Action: `src/actions/{feature}.ts`
- Validator: `src/lib/validators/{feature}.ts`

## 필수 구조

### Action 파일
```typescript
'use server'

import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { createEventSchema } from '@/lib/validators/event'

type ActionResult<T> =
  | { success: true; data: T }
  | { success: false; error: string }

export async function createEvent(
  formData: FormData
): Promise<ActionResult<{ id: string }>> {
  const supabase = await createClient()

  // 1. 인증 확인 (getUser 필수, getSession 사용 금지)
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) {
    return { success: false, error: '인증이 필요합니다' }
  }

  // 2. 입력값 검증 (Zod)
  const raw = Object.fromEntries(formData)
  const parsed = createEventSchema.safeParse(raw)
  if (!parsed.success) {
    return { success: false, error: parsed.error.issues[0].message }
  }

  // 3. DB 작업 (RLS가 권한 검증)
  const { data, error } = await supabase
    .from('events')
    .insert({ ...parsed.data, created_by: user.id })
    .select('id')
    .single()

  if (error) {
    return { success: false, error: '생성에 실패했습니다' }
  }

  // 4. 캐시 무효화
  revalidatePath('/calendar')

  return { success: true, data: { id: data.id } }
}
```

### Validator 파일 (Zod)
```typescript
import { z } from 'zod'

export const createEventSchema = z.object({
  title: z.string().min(1, '제목을 입력해주세요').max(200),
  description: z.string().optional(),
  start_at: z.string().datetime(),
  end_at: z.string().datetime(),
  calendar_id: z.string().uuid(),
  all_day: z.coerce.boolean().default(false),
})

export type CreateEventInput = z.infer<typeof createEventSchema>
```

## 규칙

### 보안
- **항상** `supabase.auth.getUser()`로 인증 확인 (첫 번째 단계)
- `getSession()` 서버에서 사용 금지 (신뢰 불가)
- 민감 작업(삭제, 권한 변경) 시 팀 멤버십 추가 검증
- Supabase RLS가 1차 권한 검증, 서버 액션에서 2차 확인

### 반환 타입
- 항상 `ActionResult<T>` 판별 유니온 반환
- 에러 메시지는 사용자 친화적 한국어
- 절대 내부 에러 메시지를 클라이언트에 노출하지 않음

### 감사 로그
- 권한 변경, 삭제, 공유 변경 시 audit_logs에 기록:
```typescript
await supabase.from('audit_logs').insert({
  team_id, user_id: user.id,
  action: 'delete', resource_type: 'event', resource_id: id,
  metadata: { title: event.title }
})
```

### 캐시
- 뮤테이션 후 `revalidatePath()` 또는 `revalidateTag()` 호출
- 관련 경로 모두 무효화 (예: 이벤트 생성 → `/calendar` + `/dashboard`)
