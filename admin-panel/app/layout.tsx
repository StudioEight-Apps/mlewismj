import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Whisper Admin',
  description: 'Analytics dashboard for Whisper app',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 text-gray-900 antialiased">{children}</body>
    </html>
  );
}
