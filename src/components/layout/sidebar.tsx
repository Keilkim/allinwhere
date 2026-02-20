"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

const navItems = [
  { href: "/dashboard", label: "대시보드" },
  { href: "/calendar", label: "캘린더" },
  { href: "/tasks", label: "Task" },
  { href: "/files", label: "파일" },
  { href: "/notifications", label: "알림" },
  { href: "/teams", label: "팀" },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden md:flex w-56 flex-col border-r border-neutral-200 bg-white">
      <div className="px-6 py-6">
        <Link href="/dashboard">
          <span className="text-base font-semibold tracking-tight text-neutral-900">
            Allinwhere
          </span>
        </Link>
      </div>

      <nav className="flex-1 px-3 space-y-1">
        {navItems.map((item) => {
          const isActive =
            pathname === item.href || pathname.startsWith(item.href + "/");
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "block px-3 py-2 rounded-lg text-sm transition-colors duration-200",
                isActive
                  ? "font-medium text-neutral-900 bg-neutral-100"
                  : "text-neutral-500 hover:text-neutral-900 hover:bg-neutral-50"
              )}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="px-3 py-4 border-t border-neutral-200">
        <Link
          href="/settings"
          className="block px-3 py-2 rounded-lg text-sm text-neutral-500 hover:text-neutral-900 hover:bg-neutral-50 transition-colors duration-200"
        >
          설정
        </Link>
      </div>
    </aside>
  );
}
