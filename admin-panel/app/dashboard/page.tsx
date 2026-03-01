'use client';

import { useEffect, useState } from 'react';
import MetricCard from '@/components/MetricCard';
import type { OverviewMetrics } from '@/lib/types';

export default function DashboardPage() {
  const [metrics, setMetrics] = useState<OverviewMetrics | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/metrics/overview')
      .then((res) => res.json())
      .then((data) => {
        setMetrics(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-400 text-sm">Loading metrics...</div>
      </div>
    );
  }

  if (!metrics || (metrics as any).error) {
    return (
      <div className="text-red-500 text-sm">
        Failed to load metrics. {(metrics as any)?.detail || 'Check your Firebase credentials in .env.local'}
      </div>
    );
  }

  return (
    <div>
      <div className="mb-8">
        <h2 className="text-2xl font-bold text-gray-900">Dashboard</h2>
        <p className="text-sm text-gray-500 mt-1">Real-time metrics from Firestore</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <MetricCard
          label="Total Users"
          value={(metrics.totalUsers ?? 0).toLocaleString()}
        />
        <MetricCard
          label="Active Subscribers"
          value={(metrics.activeSubscribers ?? 0).toLocaleString()}
          subtitle={`${metrics.conversionRate}% conversion`}
        />
        <MetricCard
          label="New Users Today"
          value={metrics.newUsersToday}
        />
        <MetricCard
          label="DAU"
          value={metrics.dau}
          subtitle="Daily active users"
        />
        <MetricCard
          label="MAU"
          value={metrics.mau}
          subtitle="Monthly active users"
        />
        <MetricCard
          label="DAU/MAU Ratio"
          value={
            metrics.mau > 0
              ? `${((metrics.dau / metrics.mau) * 100).toFixed(0)}%`
              : '0%'
          }
          subtitle="Stickiness"
        />
      </div>
    </div>
  );
}
