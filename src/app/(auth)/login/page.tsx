"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const supabase = createClient();

  async function handleLogin(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError("이메일 또는 비밀번호가 올바르지 않습니다");
      setLoading(false);
      return;
    }

    router.push("/dashboard");
    router.refresh();
  }

  async function handleSocialLogin(provider: "google" | "apple" | "kakao") {
    await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-neutral-900">
          로그인
        </h1>
        <p className="mt-2 text-sm text-neutral-500">
          Allinwhere에 오신 것을 환영합니다
        </p>
      </div>

      <form onSubmit={handleLogin} className="space-y-4">
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

        <div className="space-y-2">
          <label
            htmlFor="password"
            className="text-xs font-medium uppercase tracking-wide text-neutral-500"
          >
            비밀번호
          </label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
            className="w-full border border-neutral-200 rounded-lg px-3 py-2 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900 focus:ring-offset-2 transition-colors duration-200"
          />
        </div>

        {error && (
          <p className="text-sm text-red-600">{error}</p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-neutral-900 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-neutral-700 transition-colors duration-200 disabled:opacity-50"
        >
          {loading ? "로그인 중..." : "로그인"}
        </button>
      </form>

      <div className="space-y-3">
        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-neutral-200" />
          </div>
          <div className="relative flex justify-center">
            <span className="bg-white px-3 text-xs text-neutral-400">또는</span>
          </div>
        </div>

        <div className="space-y-2">
          <button
            onClick={() => handleSocialLogin("google")}
            className="w-full border border-neutral-200 rounded-lg px-4 py-2 text-sm font-medium text-neutral-900 hover:bg-neutral-50 transition-colors duration-200"
          >
            Google로 계속하기
          </button>
          <button
            onClick={() => handleSocialLogin("apple")}
            className="w-full border border-neutral-200 rounded-lg px-4 py-2 text-sm font-medium text-neutral-900 hover:bg-neutral-50 transition-colors duration-200"
          >
            Apple로 계속하기
          </button>
          <button
            onClick={() => handleSocialLogin("kakao")}
            className="w-full border border-neutral-200 rounded-lg px-4 py-2 text-sm font-medium text-neutral-900 hover:bg-neutral-50 transition-colors duration-200"
          >
            Kakao로 계속하기
          </button>
        </div>
      </div>

      <div className="text-center space-y-2">
        <Link
          href="/reset-password"
          className="text-sm text-neutral-500 hover:text-neutral-900 transition-colors duration-200"
        >
          비밀번호를 잊으셨나요?
        </Link>
        <p className="text-sm text-neutral-500">
          계정이 없으신가요?{" "}
          <Link
            href="/signup"
            className="font-medium text-neutral-900 hover:text-neutral-700 transition-colors duration-200"
          >
            회원가입
          </Link>
        </p>
      </div>
    </div>
  );
}
