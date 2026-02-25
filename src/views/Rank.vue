<template>
  <div class="rank-page">
    <!-- 大Tab: 实时排行 / 月度荣耀 -->
    <div class="main-tabs">
      <div class="main-tab" :class="{active:mainTab==='realtime'}" @click="mainTab='realtime';loadRank()">📊 实时排行</div>
      <div class="main-tab" :class="{active:mainTab==='monthly'}" @click="mainTab='monthly';loadMonthly()">👑 月度荣耀</div>
    </div>

    <!-- 实时排行 -->
    <template v-if="mainTab==='realtime'">
      <div class="rank-tabs">
        <div v-for="t in tabs" :key="t.value" class="rank-tab" :class="{ active: rankType === t.value }" @click="rankType = t.value; loadRank()">
          {{ t.icon }} {{ t.label }}
        </div>
      </div>
      <div v-if="myRank" class="my-rank-card">
        <span class="my-rank-label">我的排名</span>
        <span class="my-rank-num">#{{ myRank.rank || '未上榜' }}</span>
        <span class="my-rank-val">{{ myRankValue }}</span>
      </div>
      <div class="rank-list" v-if="!loading">
        <div v-for="(item, i) in rankData" :key="i"
          class="rank-item" :class="{ 'rank-me': isMe(item), ['rank-top-' + (i+1)]: i < 3 }">
          <div class="rank-pos">
            <span v-if="i === 0" class="medal">🥇</span>
            <span v-else-if="i === 1" class="medal">🥈</span>
            <span v-else-if="i === 2" class="medal">🥉</span>
            <span v-else class="rank-num">{{ i + 1 }}</span>
          </div>
          <div class="rank-info">
            <div class="rank-name">
              {{ item.name || shortWallet(item.wallet) }}
              <span v-if="item.vip_level" class="vip-badge">V{{ item.vip_level }}</span>
            </div>
            <div class="rank-sub">{{ item.realm || '' }}</div>
          </div>
          <div class="rank-value">
            <template v-if="rankType === 'power'">{{ Number(item.combat_power).toLocaleString() }}</template>
            <template v-else-if="rankType === 'level'">Lv.{{ item.level }}</template>
            <template v-else>{{ Number(item.total_recharge).toFixed(1) }} ROON</template>
          </div>
        </div>
        <div v-if="rankData.length === 0" class="rank-empty">暂无数据</div>
      </div>
      <div v-else class="rank-loading">加载中...</div>
    </template>

    <!-- 月度荣耀 -->
    <template v-if="mainTab==='monthly'">
      <div class="rank-tabs">
        <div v-for="t in monthlyTabs" :key="t.key" class="rank-tab" :class="{ active: monthlyType === t.key }" @click="monthlyType = t.key; loadMonthly()">
          {{ t.icon }} {{ t.label }}
        </div>
      </div>
      <div class="reward-info">
        <div class="reward-title">💰 月度荣耀 · {{ monthlyDateRange }}</div>
        <div class="reward-rules">🏆 焰晶奖励: 1名20000 / 2-3名10000 / 4-10名5000 / 11-50名2000</div>
        <div class="reward-rules" style="font-size:11px;opacity:0.7">每月自动结算，奖励直接发放到邮箱</div>
      </div>
      <div v-if="monthlyMyRank" class="my-rank-card">
        <span class="my-rank-label">我的排名</span>
        <span class="my-rank-num">#{{ monthlyMyRank.rank }}</span>
        <span class="my-rank-val">{{ formatScore(monthlyMyRank.score) }}</span>
      </div>
      <div class="rank-list" v-if="!monthlyLoading">
        <div v-for="(r, i) in monthlyData" :key="r.wallet"
          class="rank-item" :class="{ 'rank-me': isMe(r), ['rank-top-' + (i+1)]: i < 3 }">
          <div class="rank-pos">
            <span v-if="i === 0" class="medal">🥇</span>
            <span v-else-if="i === 1" class="medal">🥈</span>
            <span v-else-if="i === 2" class="medal">🥉</span>
            <span v-else class="rank-num">{{ i + 1 }}</span>
          </div>
          <div class="rank-info">
            <div class="rank-name">{{ r.name || '无名修士' }}</div>
            <div class="rank-sub">{{ r.realm || '' }} Lv.{{ r.level || '?' }}</div>
          </div>
          <div class="rank-value">{{ formatScore(r.score) }}</div>
        </div>
        <div v-if="monthlyData.length === 0" class="rank-empty">暂无数据</div>
      </div>
      <div v-else class="rank-loading">加载中...</div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()

const monthlyDateRange = computed(() => {
  const now = new Date()
  const y = now.getFullYear()
  const m = now.getMonth()
  const start = new Date(y, m, 1)
  const end = new Date(y, m + 1, 0)
  const fmt = d => `${d.getMonth()+1}/${d.getDate()}`
  return `${y}年${m+1}月 (${fmt(start)} - ${fmt(end)})`
})
const mainTab = ref('realtime')

// === 实时排行 ===
const rankType = ref('power')
const rankData = ref([])
const loading = ref(false)
const tabs = [
  { value: 'power', label: '战力榜', icon: '⚔️' },
  { value: 'level', label: '焰阶榜', icon: '🏔️' },
  { value: 'recharge', label: '充值榜', icon: '💰' },
]
const shortWallet = (w) => w ? w.slice(0, 6) + '...' + w.slice(-4) : '???'
const isMe = (item) => {
  const myWallet = authStore.wallet || localStorage.getItem('xx_wallet')
  return myWallet && item.wallet?.toLowerCase() === myWallet.toLowerCase()
}
const myRank = computed(() => {
  const myWallet = authStore.wallet || localStorage.getItem('xx_wallet')
  if (!myWallet) return null
  const idx = rankData.value.findIndex(r => r.wallet?.toLowerCase() === myWallet.toLowerCase())
  if (idx >= 0) return { ...rankData.value[idx], rank: idx + 1 }
  return { rank: null }
})
const myRankValue = computed(() => {
  if (!myRank.value || !myRank.value.rank) return ''
  const item = myRank.value
  if (rankType.value === 'power') return Number(item.combat_power).toLocaleString()
  if (rankType.value === 'level') return 'Lv.' + item.level
  return Number(item.total_recharge).toFixed(1) + ' ROON'
})
const loadRank = async () => {
  loading.value = true
  try {
    const data = await authStore.getLeaderboard(rankType.value)
    rankData.value = data.data || []
  } catch {} finally { loading.value = false }
}

// === 月度荣耀 ===
const monthlyType = ref('power')
const monthlyData = ref([])
const monthlyMyRank = ref(null)
const monthlyLoading = ref(false)
const monthlyTabs = [
  { key: 'power', icon: '⚔️', label: '战力' },
  { key: 'pk', icon: '🏆', label: '天梯' },
  { key: 'level', icon: '📈', label: '等级' },
  { key: 'spending', icon: '💎', label: '消费' },
  { key: 'minigame', icon: '🎮', label: '游戏' },
]
const formatScore = (s) => { if (!s && s !== 0) return '-'; return Number(s).toLocaleString() }
const loadMonthly = async () => {
  monthlyLoading.value = true
  try {
    const res = await authStore.apiGet('/monthly/current/' + monthlyType.value)
    if (res.success) { monthlyData.value = res.rankings || []; monthlyMyRank.value = res.myRank }
  } catch (e) { console.error(e) }
  monthlyLoading.value = false
}

onMounted(() => loadRank())
</script>

<style scoped>
.rank-page { padding: 8px; }
.main-tabs { display: flex; gap: 8px; margin-bottom: 14px; }
.main-tab { flex: 1; text-align: center; padding: 12px 0; border-radius: 12px; font-size: 15px; font-weight: bold; cursor: pointer; background: rgba(15,15,30,0.6); border: 1px solid rgba(212,168,67,0.15); color: rgba(212,168,67,0.5); transition: all 0.2s; }
.main-tab.active { background: linear-gradient(135deg, rgba(212,168,67,0.2), rgba(255,107,53,0.1)); border-color: #d4a843; color: #ffd700; }
.rank-tabs { display: flex; gap: 6px; margin-bottom: 12px; }
.rank-tab { flex: 1; text-align: center; padding: 8px 4px; border-radius: 8px; font-size: 13px; cursor: pointer; color: rgba(212,168,67,0.5); background: rgba(15,15,30,0.6); border: 1px solid rgba(212,168,67,0.1); transition: all 0.2s; }
.rank-tab:hover { color: #d4a843; border-color: rgba(212,168,67,0.3); }
.rank-tab.active { color: #1a1a2e; background: linear-gradient(135deg, #d4a843, #f0c060); border-color: #d4a843; font-weight: 700; }
.reward-info { background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.15); border-radius: 10px; padding: 10px; margin-bottom: 12px; text-align: center; }
.reward-title { color: #ffd700; font-size: 14px; font-weight: bold; margin-bottom: 4px; }
.reward-rules { color: #a08030; font-size: 12px; }
.my-rank-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; margin-bottom: 10px; border-radius: 10px; background: rgba(212,168,67,0.06); border: 1px solid rgba(212,168,67,0.15); }
.my-rank-label { font-size: 12px; color: rgba(212,168,67,0.5); }
.my-rank-num { font-size: 20px; font-weight: 900; color: #ffd700; }
.my-rank-val { font-size: 13px; color: #d4a843; }
.rank-list { display: flex; flex-direction: column; gap: 4px; }
.rank-item { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 8px; background: rgba(15,15,30,0.7); border: 1px solid rgba(212,168,67,0.06); transition: all 0.15s; }
.rank-item:hover { border-color: rgba(212,168,67,0.2); }
.rank-me { background: rgba(212,168,67,0.08) !important; border-color: rgba(212,168,67,0.25) !important; }
.rank-top-1 { border-color: rgba(255,215,0,0.3); }
.rank-top-2 { border-color: rgba(192,192,192,0.2); }
.rank-top-3 { border-color: rgba(205,127,50,0.2); }
.rank-pos { width: 32px; text-align: center; flex-shrink: 0; }
.medal { font-size: 22px; }
.rank-num { font-size: 14px; color: rgba(212,168,67,0.4); font-weight: 700; }
.rank-info { flex: 1; min-width: 0; }
.rank-name { font-size: 13px; color: #f0d68a; font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.rank-sub { font-size: 11px; color: rgba(212,168,67,0.4); }
.vip-badge { display: inline-block; font-size: 10px; padding: 0 4px; background: rgba(255,165,0,0.15); color: #ffa500; border-radius: 4px; margin-left: 4px; font-weight: 700; }
.rank-value { font-size: 14px; color: #ffd700; font-weight: 700; white-space: nowrap; flex-shrink: 0; }
.rank-empty, .rank-loading { text-align: center; padding: 40px 0; color: rgba(212,168,67,0.3); font-size: 14px; }
</style>
