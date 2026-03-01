import { NextResponse } from 'next/server';
import { getDb } from '@/lib/firebase-admin';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const db = getDb();
    const usersRef = db.collection('users');

    // Total users
    let totalUsers = 0;
    try {
      const usersSnapshot = await usersRef.count().get();
      totalUsers = usersSnapshot.data().count;
    } catch (e: any) {
      // Fallback: get all docs
      const snap = await usersRef.get();
      totalUsers = snap.size;
    }

    // Active subscribers
    let activeSubscribers = 0;
    try {
      const activeSubsSnapshot = await usersRef
        .where('hasActive', '==', true)
        .count()
        .get();
      activeSubscribers = activeSubsSnapshot.data().count;
    } catch {
      // Field may not exist yet
    }

    // New users today
    let newUsersToday = 0;
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    try {
      const newTodaySnapshot = await usersRef
        .where('onboarding_completed_at', '>=', todayStart)
        .count()
        .get();
      newUsersToday = newTodaySnapshot.data().count;
    } catch {
      // Field may not exist yet
    }

    // DAU & MAU via collection group queries (require Firestore indexes)
    let dau = 0;
    let mau = 0;
    try {
      const journalEntriesRef = db.collectionGroup('journalEntries');
      const todayEntriesSnapshot = await journalEntriesRef
        .where('createdAt', '>=', todayStart)
        .get();
      dau = new Set(
        todayEntriesSnapshot.docs.map((doc) => doc.ref.parent.parent?.id)
      ).size;

      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      const monthEntriesSnapshot = await journalEntriesRef
        .where('createdAt', '>=', thirtyDaysAgo)
        .get();
      mau = new Set(
        monthEntriesSnapshot.docs.map((doc) => doc.ref.parent.parent?.id)
      ).size;
    } catch (e: any) {
      console.warn('DAU/MAU query failed (index may be needed):', e?.message);
    }

    return NextResponse.json({
      totalUsers,
      activeSubscribers,
      newUsersToday,
      dau,
      mau,
      conversionRate:
        totalUsers > 0
          ? ((activeSubscribers / totalUsers) * 100).toFixed(1)
          : '0',
    });
  } catch (error: any) {
    console.error('Overview metrics error:', error?.message || error);
    return NextResponse.json({ error: 'Failed to fetch metrics', detail: error?.message }, { status: 500 });
  }
}
