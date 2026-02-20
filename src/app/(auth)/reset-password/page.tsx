"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";
import Link from "next/link";

export default function ResetPasswordPage() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const supabase = createClient();

  async function handleReset(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/auth/callback?next=/settings`,
    });

    if (error) {
      setError("재설정 메일 발송에 실패했습니다");
      setLoading(false);
      return;
    }

    setSent(true);
    setLoading(false);
  }

  if (sent) {
    return (
      <div className="space-y-4">
        <h1 className="text-2xl font-semibold tracking-tight text-neutral-900">
          메일을 확인해주세요
        </h1>
        <p className="text-sm text-neutral-500">
          {email}으로 비밀번호 재설정 링크를 보냈습니다.
        </p>
        <Link
          href="/login"
          className="inline-block text-sm font-medium text-neutral-900 hover:text-neutral-700 transition-colors duration-200"
        >
          로그인으로 돌아가기
        </Link>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-neutral-900">
          비밀번호 재설정
        </h1>
        <p className="mt-2 text-sm text-neutral-500">
          가입 시 사용한 이메일을 입력해주세요
        </p>
      </div>

      <form onSubmit={handleReset} className="space-y-4">
        <div className="space-y-2">
          <label
            htmlFor="email"
            className="text-xs font-medium uppercase tracking-wide text-neutral-500"
          >
            이메일
          </label>
          <input
            id="email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            required
            className="w-full border border-neutral-200 rounded-lg px-3 py-2 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900 focus:ring-offset-2 transition-colors duration-200"
          />
        </div>

        {error && <p className="text-sm text-red-600">{error}</p>}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-neutral-900 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-neutral-700 transition-colors duration-200 disabled:opacity-50"
        >
          {loading ? "발송 중..." : "재설정 메일 보내기"}
        </button>
      </form>

      <p className="text-center text-sm text-neutral-500">
        <Link
          href="/login"
          className="font-medium text-neutral-900 hover:text-neutral-700 transition-colors duration-200"
        >
          로그인으로 돌아가기
        </Link>
      </p>
    </div>
  );
}
