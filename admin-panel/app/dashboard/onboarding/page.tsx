'use client';

import { useEffect, useState } from 'react';
import type { FunnelData } from '@/lib/types';

export default function OnboardingPage() {
  const [data, setData] = useState<FunnelData | null>(null);
  const [days, setDays] = useState(30);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);
    fetch(`/api/metrics/onboarding-funnel?days=${days}`)
      .then((res) => res.json())
      .then((d) => {
        setData(d);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, [days]);

  const maxCount = data?.funnel?.[0]?.count || 1;

  return (
    <div>
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Onboarding Funnel</h2>
          <p className="text-sm text-gray-500 mt-1">Where users drop off in the onboarding flow</p>
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

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="text-gray-400 text-sm">Loading funnel data...</div>
        </div>
      ) : !data?.funnel?.length ? (
        <div className="bg-white rounded-2xl border border-gray-100 p-12 text-center">
          <p className="text-gray-400 text-sm">No onboarding data yet. Events will appear here once users start onboarding with the new analytics build.</p>
        </div>
      ) : (
        <div className="bg-white rounded-2xl border border-gray-100 p-6 space-y-3">
          {data.funnel.map((step, index) => {
            const width = maxCount > 0 ? (step.count / maxCount) * 100 : 0;
            const isDropHeavy = step.dropOff && parseFloat(step.dropOff) > 20;

            return (
              <div key={step.step} className="flex items-center gap-4">
                <div className="w-36 text-right">
                  <p className="text-xs font-medium text-gray-600">{step.label}</p>
                </div>
                <div className="flex-1">
                  <div className="h-8 bg-gray-50 rounded-lg overflow-hidden">
                    <div
                      className="h-full bg-gray-900 rounded-lg transition-all duration-500 flex items-center justify-end pr-2"
                      style={{ width: `${Math.max(width, 2)}%` }}
                    >
                      {width > 15 && (
                        <span className="text-xs font-medium text-white">{step.count}</span>
                      )}
                    </div>
                  </div>
                </div>
                <div className="w-20 text-right">
                  {width <= 15 && (
                    <span className="text-xs font-medium text-gray-900">{step.count}</span>
                  )}
                </div>
                <div className="w-16 text-right">
                  {index > 0 && (
                    <span className={`text-xs font-medium ${isDropHeavy ? 'text-red-500' : 'text-gray-400'}`}>
                      {step.dropOff !== '-' ? `−${step.dropOff}` : ''}
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
