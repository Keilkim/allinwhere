# /test-feature — Unit + E2E 테스트 생성

요청된 기능에 대한 테스트를 생성하라.

## 테스트 종류

### Unit 테스트 (Vitest)
- 위치: `tests/unit/{feature}/`
- 파일명: `{기능}.test.ts`
- 대상: Server Actions, Zod 검증, 유틸리티 함수

### E2E 테스트 (Playwright)
- 위치: `tests/e2e/`
- 파일명: `{기능}.spec.ts`
- 대상: 사용자 흐름 전체 (네비게이션 → 입력 → 제출 → 결과 확인)

## Unit 테스트 패턴

### Server Action 테스트
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { createEvent } from '@/actions/events'

// Supabase 클라이언트 모킹
vi.mock('@/lib/supabase/server', () => ({
  createClient: vi.fn(() => ({
    auth: {
      getUser: vi.fn(() => ({
        data: { user: { id: 'user-1', email: 'test@test.com' } },
        error: null,
      })),
    },
    from: vi.fn(() => ({
      insert: vi.fn(() => ({
        select: vi.fn(() => ({
          single: vi.fn(() => ({
            data: { id: 'event-1' },
            error: null,
          })),
        })),
      })),
    })),
  })),
}))

describe('createEvent', () => {
  it('유효한 입력으로 이벤트를 생성한다', async () => {
    const formData = new FormData()
    formData.set('title', '회의')
    formData.set('start_at', '2026-03-01T09:00:00Z')
    formData.set('end_at', '2026-03-01T10:00:00Z')
    formData.set('calendar_id', 'cal-uuid-here')

    const result = await createEvent(formData)
    expect(result.success).toBe(true)
  })

  it('인증 없으면 에러를 반환한다', async () => {
    // getUser가 null 반환하도록 모킹 변경
    // ...
    const result = await createEvent(new FormData())
    expect(result.success).toBe(false)
  })
})
```

### Zod 검증 테스트
```typescript
import { describe, it, expect } from 'vitest'
import { createEventSchema } from '@/lib/validators/event'

describe('createEventSchema', () => {
  it('유효한 데이터를 통과시킨다', () => {
    const result = createEventSchema.safeParse({
      title: '회의',
      start_at: '2026-03-01T09:00:00Z',
      end_at: '2026-03-01T10:00:00Z',
      calendar_id: '550e8400-e29b-41d4-a716-446655440000',
    })
    expect(result.success).toBe(true)
  })

  it('빈 제목을 거부한다', () => {
    const result = createEventSchema.safeParse({
      title: '',
      start_at: '2026-03-01T09:00:00Z',
      end_at: '2026-03-01T10:00:00Z',
      calendar_id: '550e8400-e29b-41d4-a716-446655440000',
    })
    expect(result.success).toBe(false)
  })
})
```

## E2E 테스트 패턴

```typescript
import { test, expect } from '@playwright/test'

test.describe('캘린더 일정', () => {
  test.beforeEach(async ({ page }) => {
    // 테스트 유저로 로그인
    await page.goto('/login')
    await page.getByLabel('이메일').fill('test@test.com')
    await page.getByLabel('비밀번호').fill('password123')
    await page.getByRole('button', { name: '로그인' }).click()
    await page.waitForURL('/dashboard')
  })

  test('새 일정을 생성할 수 있다', async ({ page }) => {
    await page.goto('/calendar')
    await page.getByRole('button', { name: '새 일정' }).click()
    await page.getByLabel('제목').fill('팀 미팅')
    await page.getByRole('button', { name: '저장' }).click()

    // 캘린더에 일정이 표시되는지 확인
    await expect(page.getByText('팀 미팅')).toBeVisible()
  })
})
```

## 규칙
- 셀렉터: `page.getByRole()`, `page.getByText()`, `page.getByLabel()` 사용 (CSS 셀렉터 금지)
- `describe` 블록: 기능/컴포넌트명으로 구성
- 테스트명: 한국어로 "~한다" 형태
- Happy path + Error state 모두 테스트
- Supabase 모킹: `tests/helpers/supabase-mock.ts` 공용 헬퍼 사용
