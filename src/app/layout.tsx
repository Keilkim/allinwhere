import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Allinwhere",
  description: "공유 캘린더, Task, 파일을 하나로 — 팀을 위한 통합 그룹웨어",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko">
      <body className="antialiased font-sans bg-white text-neutral-900">
        {children}
      </body>
    </html>
  );
}
