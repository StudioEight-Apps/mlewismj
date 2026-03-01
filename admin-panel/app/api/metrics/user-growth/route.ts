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

    // User signups over time
    let userGrowth: { date: string; newUsers: number }[] = [];
    try {
      const usersRef = db.collection('users');
      const snapshot = await usersRef
        .where('onboarding_completed_at', '>=', sinceDate)
        .orderBy('onboarding_completed_at', 'asc')
        .get();

      const dailySignups: Record<string, number> = {};
      snapshot.docs.forEach((doc) => {
        const data = doc.data();
        const date = data.onboarding_completed_at?.toDate();
        if (date) {
          const dateKey = date.toISOString().split('T')[0];
          dailySignups[dateKey] = (dailySignups[dateKey] || 0) + 1;
        }
      });

      userGrowth = Object.entries(dailySignups)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([date, count]) => ({ date, newUsers: count }));
    } catch (e: any) {
      console.warn('User growth query failed (index may be needed):', e?.message);
    }

    // Subscription growth
    let subscriptionGrowth: { date: string; newSubscribers: number }[] = [];
    try {
      const subsRef = db.collectionGroup('subscriptions');
      const subsSnapshot = await subsRef
        .where('purchaseDate', '>=', sinceDate)
        .get();

      const dailySubs: Record<string, number> = {};
      subsSnapshot.docs.forEach((doc) => {
        const data = doc.data();
        const date = data.purchaseDate?.toDate();
        if (date) {
          const dateKey = date.toISOString().split('T')[0];
          dailySubs[dateKey] = (dailySubs[dateKey] || 0) + 1;
        }
      });

      subscriptionGrowth = Object.entries(dailySubs)
        .sort(([a], [b]) => a.localeCompare(b))
        .map(([date, count]) => ({ date, newSubscribers: count }));
    } catch (e: any) {
      console.warn('Subscription growth query failed (index may be needed):', e?.message);
    }

    return NextResponse.json({ userGrowth, subscriptionGrowth });
  } catch (error: any) {
    console.error('User growth error:', error?.message || error);
    return NextResponse.json({ error: 'Failed to fetch growth data', detail: error?.message }, { status: 500 });
  }
}
