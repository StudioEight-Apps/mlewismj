'use client';

import { useEffect, useState } from 'react';
import MetricCard from '@/components/MetricCard';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import type { EngagementData } from '@/lib/types';

export default function EngagementPage() {
  const [data, setData] = useState<EngagementData | null>(null);
  const [days, setDays] = useState(30);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetch(`/api/metrics/engagement?days=${days}`)
      .then((res) => res.json())
      .then((d) => {
        setData(d);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [days]);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-400 text-sm">Loading engagement data...</div>
      </div>
    );
  }

  if (!data) return null;

  const guidedCount = data.journalTypes?.['guided'] || 0;
  const freeCount = data.journalTypes?.['free'] || 0;
  const total = guidedCount + freeCount;
  const guidedPct = total > 0 ? ((guidedCount / total) * 100).toFixed(0) : '0';

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Engagement</h2>
          <p className="text-sm text-gray-500 mt-1">How users interact with journaling</p>
        </div>
        <select
          value={days}
          onChange={(e) => setDays(Number(e.target.value))}
          className="text-sm border border-gray-200 rounded-lg px-3 py-2 bg-white"
        >
          <option value={7}>Last 7 days</option>
          <option value={14}>Last 14 days</option>
          <option value={30}>Last 30 days</option>
          <option value={90}>Last 90 days</option>
        </select>
      </div>

      {/* Metric cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <MetricCard label="Total Entries" value={data.totalEntries.toLocaleString()} />
        <MetricCard label="Active Journalers" value={data.uniqueUsers} />
        <MetricCard label="Avg Entries/User" value={data.avgEntriesPerUser} />
        <MetricCard label="Guided vs Free" value={`${guidedPct}% guided`} />
      </div>

      {/* Daily entries chart */}
      {data.dailyEntries.length > 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">Daily Journal Entries</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={data.dailyEntries}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="date"
                tickFormatter={(d: string) => d.slice(5)}
                tick={{ fontSize: 11, fill: '#9a9a9a' }}
              />
              <YAxis tick={{ fontSize: 11, fill: '#9a9a9a' }} />
              <Tooltip />
              <Line type="monotone" dataKey="count" stroke="#1a1a1a" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Top moods */}
      {data.topMoods.length > 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">Top Moods</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={data.topMoods} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis type="number" tick={{ fontSize: 11, fill: '#9a9a9a' }} />
              <YAxis
                dataKey="mood"
                type="category"
                tick={{ fontSize: 12, fill: '#1a1a1a' }}
                width={100}
              />
              <Tooltip />
              <Bar dataKey="count" fill="#C4A574" radius={[0, 4, 4, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}
    </div>
  );
}
