import { NextRequest, NextResponse } from 'next/server';
import { getDb } from '@/lib/firebase-admin';

export const dynamic = 'force-dynamic';

const STEP_ORDER = [
  { key: 'intro1', label: 'Welcome' },
  { key: 'voiceContext', label: 'Voice Setup Intro' },
  { key: 'q1_innerVoice', label: 'Q1: Inner Voice' },
  { key: 'q2_selfTalk', label: 'Q2: Self Talk' },
  { key: 'q3_stressResponse', label: 'Q3: Stress' },
  { key: 'q4_hardestPart', label: 'Q4: Hardest Part' },
  { key: 'q5_trustAdvice', label: 'Q5: Trust' },
  { key: 'q6_endOfDay', label: 'Q6: End of Day' },
  { key: 'q7_quoteResonance', label: 'Q7: Quotes' },
  { key: 'q8_overthinking', label: 'Q8: Overthinking' },
  { key: 'voiceReveal', label: 'Voice Reveal' },
  { key: 'authScreen', label: 'Sign Up' },
  { key: 'complete', label: 'Complete' },
];

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const days = parseInt(searchParams.get('days') || '30');

    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - days);

    const db = getDb();
    const funnelRef = db.collection('onboarding_funnel');
    const snapshot = await funnelRef.where('timestamp', '>=', sinceDate).get();

    // Count unique sessions per step
    const stepCounts: Record<string, Set<string>> = {};
    for (const { key } of STEP_ORDER) {
      stepCounts[key] = new Set();
    }

    snapshot.docs.forEach((doc) => {
      const data = doc.data();
      const step = data.step;
      const sessionId = data.session_id;
      if (stepCounts[step]) {
        stepCounts[step].add(sessionId);
      }
    });

    const funnel = STEP_ORDER.map((step, index) => {
      const count = stepCounts[step.key]?.size || 0;
      const prevCount = index > 0 ? stepCounts[STEP_ORDER[index - 1].key]?.size || 0 : count;
      const dropOff =
        prevCount > 0 && index > 0
          ? `${(((prevCount - count) / prevCount) * 100).toFixed(1)}%`
          : '-';

      return {
        step: step.key,
        label: step.label,
        count,
        dropOff,
      };
    });

    return NextResponse.json({ funnel, days });
  } catch (error) {
    console.error('Onboarding funnel error:', error);
    return NextResponse.json({ error: 'Failed to fetch funnel data' }, { status: 500 });
  }
}
