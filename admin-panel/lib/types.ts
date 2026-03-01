export interface OverviewMetrics {
  totalUsers: number;
  activeSubscribers: number;
  newUsersToday: number;
  dau: number;
  mau: number;
  conversionRate: string;
}

export interface FunnelStep {
  step: string;
  label: string;
  count: number;
  dropOff?: string;
}

export interface FunnelData {
  funnel: FunnelStep[];
  days: number;
}

export interface MoodCount {
  mood: string;
  count: number;
}

export interface DailyCount {
  date: string;
  count: number;
}

export interface EngagementData {
  totalEntries: number;
  uniqueUsers: number;
  avgEntriesPerUser: string;
  topMoods: MoodCount[];
  journalTypes: Record<string, number>;
  dailyEntries: DailyCount[];
  dailyActiveUsers: DailyCount[];
}

export interface GrowthPoint {
  date: string;
  newUsers: number;
}

export interface SubGrowthPoint {
  date: string;
  newSubscribers: number;
}

export interface UserGrowthData {
  userGrowth: GrowthPoint[];
  subscriptionGrowth: SubGrowthPoint[];
}
