import { NextRequest, NextResponse } from 'next/server';
import { getDb } from '@/lib/firebase-admin';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const days = parseInt(searchParams.get('days') || '30');

    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - days);

    const db = getDb();

    let totalEntries = 0;
    const moodCounts: Record<string, number> = {};
    const typeCounts: Record<string, number> = {};
    const dailyCounts: Record<string, number> = {};
    const dailyUsers: Record<string, Set<string>> = {};
    let uniqueUserIds = new Set<string | undefined>();

    try {
      const entriesRef = db.collectionGroup('journalEntries');
      const snapshot = await entriesRef.where('createdAt', '>=', sinceDate).get();

      totalEntries = snapshot.size;

      snapshot.docs.forEach((doc) => {
        const data = doc.data();

        const mood = data.mood || 'unknown';
        moodCounts[mood] = (moodCounts[mood] || 0) + 1;

        const type = data.journalType || 'guided';
        typeCounts[type] = (typeCounts[type] || 0) + 1;

        const date = data.createdAt?.toDate();
        const dateKey = date ? date.toISOString().split('T')[0] : 'unknown';
        dailyCounts[dateKey] = (dailyCounts[dateKey] || 0) + 1;

        const userId = doc.ref.parent.parent?.id || 'unknown';
        uniqueUserIds.add(userId);
        if (!dailyUsers[dateKey]) dailyUsers[dateKey] = new Set();
        dailyUsers[dateKey].add(userId);
      });
    } catch (e: any) {
      console.warn('Engagement collectionGroup query failed (index may be needed):', e?.message);
    }

    const topMoods = Object.entries(moodCounts)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
      .map(([mood, count]) => ({ mood, count }));

    const uniqueUsers = uniqueUserIds.size;
    const avgEntriesPerUser =
      uniqueUsers > 0 ? (totalEntries / uniqueUsers).toFixed(1) : '0';

    return NextResponse.json({
      totalEntries,
      uniqueUsers,
      avgEntriesPerUser,
      topMoods,
      journalTypes: typeCounts,
      dailyEntries: Object.entries(dailyCounts)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([date, count]) => ({ date, count })),
      dailyActiveUsers: Object.entries(dailyUsers)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([date, users]) => ({ date, count: users.size })),
    });
  } catch (error: any) {
    console.error('Engagement metrics error:', error?.message || error);
    return NextResponse.json({ error: 'Failed to fetch engagement data', detail: error?.message }, { status: 500 });
  }
}
