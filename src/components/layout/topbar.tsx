"use client";

import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";
import type { User } from "@supabase/supabase-js";

export function Topbar({ user }: { user: User }) {
  const router = useRouter();
  const supabase = createClient();

  async function handleLogout() {
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  }

  return (
    <header className="flex items-center justify-between border-b border-neutral-200 px-8 py-3 bg-white">
      <div className="md:hidden">
        <span className="text-base font-semibold tracking-tight text-neutral-900">
          Allinwhere
        </span>
      </div>

      <div className="flex-1" />

      <div className="flex items-center gap-4">
        <span className="text-sm text-neutral-500">
          {user.user_metadata?.full_name || user.email}
        </span>
        <button
          onClick={handleLogout}
          className="text-sm text-neutral-500 hover:text-neutral-900 transition-colors duration-200"
        >
          로그아웃
        </button>
      </div>
    </header>
  );
}
