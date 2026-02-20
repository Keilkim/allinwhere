# /style-audit — Apple 미니멀 디자인 감사

지정된 파일/컴포넌트가 Allinwhere 디자인 시스템을 준수하는지 검사하라.

## 검사 항목

### 1. 아이콘/픽토그램 (가장 중요)
- [ ] 아이콘 라이브러리 임포트 없는지 (lucide, heroicons, react-icons 등)
- [ ] SVG 아이콘 인라인 없는지
- [ ] 이모지 사용 없는지
- [ ] 모든 인터랙티브 요소가 **텍스트 레이블만** 사용하는지

### 2. 색상
- [ ] `text-neutral-900` (기본 텍스트)
- [ ] `text-neutral-500` (보조 텍스트)
- [ ] `text-neutral-400` (비활성/플레이스홀더)
- [ ] `border-neutral-200` (보더)
- [ ] `bg-neutral-50` (표면)
- [ ] `bg-white` (배경)
- [ ] 허용 외 색상 사용 없는지 (커스텀 hex, 비표준 Tailwind 색상)
- [ ] 위험 동작만 `red-600`/`red-700`

### 3. 타이포그래피
- [ ] `font-bold` (700) 사용 금지 → `font-semibold` (600) 최대
- [ ] 제목에 `tracking-tight` 적용
- [ ] 본문에 tracking 수정자 없음
- [ ] 타입 스케일 준수:
  - Display: `text-3xl font-semibold tracking-tight`
  - Heading: `text-xl font-semibold tracking-tight`
  - Subheading: `text-base font-medium`
  - Body: `text-sm`
  - Caption: `text-xs text-neutral-500`
  - Label: `text-xs font-medium uppercase tracking-wide`

### 4. 인터랙션
- [ ] 모든 인터랙티브 요소에 `transition-colors duration-200`
- [ ] 포커스 스타일: `focus:ring-2 focus:ring-neutral-900 focus:ring-offset-2`
- [ ] 호버: 색상 변화만 (scale, shadow 변경 금지)
- [ ] 버튼 클릭 시 bounce/spring 애니메이션 없음

### 5. 스페이싱
- [ ] 4px 그리드 준수 (Tailwind 기본 간격)
- [ ] 페이지 컨테이너: `px-8 py-6 md:px-12 md:py-8`
- [ ] 카드 패딩: `p-6`
- [ ] 폼 필드 간격: `space-y-4`
- [ ] 섹션 간격: `space-y-6`

### 6. 컴포넌트 패턴
- [ ] 카드: `border border-neutral-200 rounded-xl p-6` (그림자 없음)
- [ ] 버튼: `rounded-lg px-4 py-2 text-sm font-medium`
- [ ] 인풋: `border border-neutral-200 rounded-lg px-3 py-2 text-sm`
- [ ] 모달: `rounded-2xl p-8 shadow-lg`
- [ ] 빈 상태: 텍스트 중심, 삽화/아이콘 없음

### 7. 로딩
- [ ] 스피너/로더 사용 금지
- [ ] 스켈레톤만 사용: `bg-neutral-200 rounded animate-pulse`
- [ ] loading.tsx 파일 존재

### 8. 반응형
- [ ] 모바일 기본 → md: → lg: 순서
- [ ] 모바일에서 적절한 패딩 축소
- [ ] 터치 타겟 최소 44px

## 결과 출력
각 항목에 대해 ✅ 통과 / ❌ 위반 + 수정 제안을 출력하라.
위반 사항이 있으면 수정 코드를 제시하라.
