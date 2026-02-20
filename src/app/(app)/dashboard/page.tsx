import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function DashboardPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  return (
    <div className="px-8 py-6 md:px-12 md:py-8">
      <h1 className="text-2xl font-semibold tracking-tight text-neutral-900">
        대시보드
      </h1>
      <p className="mt-2 text-sm text-neutral-500">
        안녕하세요, {user?.user_metadata?.full_name || user?.email}
      </p>

      <div className="mt-8 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <div className="border border-neutral-200 rounded-xl p-6">
          <h2 className="text-base font-medium text-neutral-900">오늘의 일정</h2>
          <p className="mt-2 text-sm text-neutral-500">등록된 일정이 없습니다</p>
        </div>

        <div className="border border-neutral-200 rounded-xl p-6">
          <h2 className="text-base font-medium text-neutral-900">진행 중인 Task</h2>
          <p className="mt-2 text-sm text-neutral-500">등록된 Task가 없습니다</p>
        </div>

        <div className="border border-neutral-200 rounded-xl p-6">
          <h2 className="text-base font-medium text-neutral-900">최근 알림</h2>
          <p className="mt-2 text-sm text-neutral-500">새로운 알림이 없습니다</p>
        </div>
      </div>
    </div>
  );
}
