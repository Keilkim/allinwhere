# /create-component — UI/공유 컴포넌트 생성

요청된 컴포넌트를 Allinwhere 디자인 시스템에 맞게 생성하라.

## 입력
- 컴포넌트 이름 (PascalCase)
- 카테고리: `ui` | `layout` | `shared`

## 파일 위치
- `src/components/{카테고리}/{kebab-case}.tsx`
- 예: `Button` → `src/components/ui/button.tsx`

## 필수 규칙

### 구조
- `className` prop 필수 수용, `cn()` 유틸로 병합
- 네이티브 HTML 요소 래핑 시 `forwardRef` 사용
- barrel export (index.ts) 금지 — 파일에서 직접 export

### cn 유틸 임포트
```typescript
import { cn } from '@/lib/utils'
```

### 디자인 토큰 (Apple 미니멀)

**절대 금지:**
- 아이콘, 이모지, 픽토그램 사용
- `font-bold` (700) 사용 → 최대 `font-semibold` (600)
- 스피너/로더 → 스켈레톤(`animate-pulse`) 사용
- 과한 그림자 → 최대 `shadow-sm`

**필수 적용:**
- 인터랙티브 요소: `transition-colors duration-200`
- 포커스: `focus:outline-none focus:ring-2 focus:ring-neutral-900 focus:ring-offset-2`
- 라운딩: 컨테이너 `rounded-xl`, 버튼/인풋 `rounded-lg`
- 호버: 색상 변화만 (스케일/그림자 변경 금지)

**색상 팔레트:**
- 텍스트 기본: `text-neutral-900`
- 텍스트 보조: `text-neutral-500`
- 텍스트 비활성: `text-neutral-400`
- 보더: `border-neutral-200`
- 표면: `bg-neutral-50`
- 배경: `bg-white`
- 인터랙티브: `bg-neutral-900 text-white`
- 위험: `bg-red-600 text-white`

**타이포그래피:**
- 제목: `font-semibold tracking-tight`
- 부제목: `text-base font-medium`
- 본문: `text-sm`
- 캡션: `text-xs text-neutral-500`
- 레이블: `text-xs font-medium uppercase tracking-wide`

### 버튼 variants 예시
```typescript
const variants = {
  primary: 'bg-neutral-900 text-white hover:bg-neutral-700',
  secondary: 'bg-white text-neutral-900 border border-neutral-200 hover:bg-neutral-50',
  ghost: 'text-neutral-500 hover:text-neutral-900 hover:bg-neutral-50',
  destructive: 'bg-red-600 text-white hover:bg-red-700',
}
```

### 컴포넌트 템플릿
```typescript
import { forwardRef } from 'react'
import { cn } from '@/lib/utils'

type ComponentProps = {
  className?: string
  children?: React.ReactNode
}

const Component = forwardRef<HTMLDivElement, ComponentProps>(
  ({ className, children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn('base-styles', className)}
        {...props}
      >
        {children}
      </div>
    )
  }
)
Component.displayName = 'Component'

export { Component }
```
