'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const navItems = [
  { href: '/dashboard', label: 'Overview', icon: '📊' },
  { href: '/dashboard/onboarding', label: 'Onboarding Funnel', icon: '🔽' },
  { href: '/dashboard/engagement', label: 'Engagement', icon: '📝' },
  { href: '/dashboard/users', label: 'User Growth', icon: '📈' },
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-60 bg-white border-r border-gray-100 min-h-screen p-6 flex flex-col">
      <div className="mb-10">
        <h1 className="text-lg font-bold text-gray-900">Whisper</h1>
        <p className="text-xs text-gray-400 mt-0.5">Admin Dashboard</p>
      </div>

      <nav className="flex-1 space-y-1">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm transition-colors ${
                isActive
                  ? 'bg-gray-900 text-white font-medium'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'
              }`}
            >
              <span className="text-base">{item.icon}</span>
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="pt-4 border-t border-gray-100 mt-auto">
        <p className="text-xs text-gray-400">Studio Eight Apps</p>
      </div>
    </aside>
  );
}
