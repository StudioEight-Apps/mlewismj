'use client';

import { useEffect, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import type { UserGrowthData } from '@/lib/types';

export default function UsersPage() {
  const [data, setData] = useState<UserGrowthData | null>(null);
  const [days, setDays] = useState(30);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetch(`/api/metrics/user-growth?days=${days}`)
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
        <div className="text-gray-400 text-sm">Loading growth data...</div>
      </div>
    );
  }

  if (!data) return null;

  // Calculate cumulative growth
  let cumulative = 0;
  const cumulativeData = data.userGrowth.map((point) => {
    cumulative += point.newUsers;
    return { date: point.date, total: cumulative, newUsers: point.newUsers };
  });

  const totalNewUsers = data.userGrowth.reduce((sum, p) => sum + p.newUsers, 0);
  const totalNewSubs = data.subscriptionGrowth.reduce((sum, p) => sum + p.newSubscribers, 0);

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">User Growth</h2>
          <p className="text-sm text-gray-500 mt-1">New users and subscriptions over time</p>
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

      {/* Summary cards */}
      <div className="grid grid-cols-2 gap-4 mb-8">
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <p className="text-xs font-medium text-gray-400 uppercase tracking-wider">New Users ({days}d)</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">{totalNewUsers}</p>
        </div>
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <p className="text-xs font-medium text-gray-400 uppercase tracking-wider">New Subscribers ({days}d)</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">{totalNewSubs}</p>
        </div>
      </div>

      {/* New users per day */}
      {data.userGrowth.length > 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">New Users Per Day</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={data.userGrowth}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="date"
                tickFormatter={(d: string) => d.slice(5)}
                tick={{ fontSize: 11, fill: '#9a9a9a' }}
              />
              <YAxis tick={{ fontSize: 11, fill: '#9a9a9a' }} />
              <Tooltip />
              <Line type="monotone" dataKey="newUsers" stroke="#1a1a1a" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Cumulative growth */}
      {cumulativeData.length > 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 p-6 mb-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">Cumulative User Growth</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={cumulativeData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="date"
                tickFormatter={(d: string) => d.slice(5)}
                tick={{ fontSize: 11, fill: '#9a9a9a' }}
              />
              <YAxis tick={{ fontSize: 11, fill: '#9a9a9a' }} />
              <Tooltip />
              <Line type="monotone" dataKey="total" stroke="#C4A574" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Subscriber growth */}
      {data.subscriptionGrowth.length > 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 p-6">
          <h3 className="text-sm font-semibold text-gray-900 mb-4">New Subscribers Per Day</h3>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={data.subscriptionGrowth}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis
                dataKey="date"
                tickFormatter={(d: string) => d.slice(5)}
                tick={{ fontSize: 11, fill: '#9a9a9a' }}
              />
              <YAxis tick={{ fontSize: 11, fill: '#9a9a9a' }} />
              <Tooltip />
              <Line type="monotone" dataKey="newSubscribers" stroke="#C4A574" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}

      {data.userGrowth.length === 0 && data.subscriptionGrowth.length === 0 && (
        <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
          <p className="text-gray-400 text-sm">No growth data for the selected period.</p>
        </div>
      )}
    </div>
  );
}
