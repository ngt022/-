<template>
  <div class="monthly-rankings">
    <h2 class="title">🏆 荣耀殿堂</h2>
    <div class="tabs">
      <div v-for="tab in tabs" :key="tab.key" class="tab" :class="{ active: activeTab === tab.key }" @click="activeTab = tab.key; loadRankings()">
        {{ tab.icon }} {{ tab.label }}
      </div>
    </div>
    <div class="reward-info">
      <div class="reward-title">💰 月度奖励池：收入ROON的5%</div>
      <div class="reward-rules">
        🥇 第1名 30% · 🥈🥉 第2-3名各15% · 第4-10名平分25% · 第11-50名平分15%
      </div>
    </div>
    <div class="list">
      <div v-if="loading" class="loading">加载中...</div>
      <div v-else-if="rankings.length === 0" class="empty">暂无数据</div>
      <div v-else>
        <div v-for="(r, i) in rankings" :key="r.wallet" class="rank-row" :class="{ top1: i===0, top2: i===1, top3: i===2, me: r.wallet === myWallet }">
          <div class="rank-pos">
            <span v-if="i===0">🥇</span>
            <span v-else-if="i===1">🥈</span>
            <span v-else-if="i===2">🥉</span>
            <span v-else class="rank-num">{{ i + 1 }}</span>
          </div>
          <div class="rank-info">
            <div class="rank-name">{{ r.name || '无名修士' }}</div>
            <div class="rank-realm">{{ r.realm || '' }} Lv.{{ r.level || '?' }}</div>
          </div>
          <div class="rank-score">{{ formatScore(r.score) }}</div>
        </div>
      </div>
    </div>
    <div v-if="myRank" class="my-rank">
      <span>我的排名: 第{{ myRank.rank }}名</span>
      <span>{{ formatScore(myRank.score) }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue"
import { useAuthStore } from "../stores/auth"

const authStore = useAuthStore()
const myWallet = ref("")

const tabs = [
  { key: "power", icon: "⚔️", label: "战力" },
  { key: "pk", icon: "🏆", label: "天梯" },
  { key: "level", icon: "📈", label: "等级" },
  { key: "spending", icon: "💎", label: "消费" },
  { key: "minigame", icon: "🎮", label: "游戏" },
]

const activeTab = ref("power")
const rankings = ref([])
const myRank = ref(null)
const loading = ref(false)

const formatScore = (s) => {
  if (!s && s !== 0) return "-"
  return Number(s).toLocaleString()
}

const loadRankings = async () => {
  loading.value = true
  try {
    const res = await authStore.apiGet("/monthly/current/" + activeTab.value)
    if (res.success) {
      rankings.value = res.rankings || []
      myRank.value = res.myRank
    }
  } catch (e) { console.error(e) }
  loading.value = false
}

onMounted(() => {
  myWallet.value = authStore.wallet || ""
  loadRankings()
})
</script>

<style scoped>
.monthly-rankings { max-width: 500px; margin: 0 auto; padding: 16px; color: #d4a843; }
.title { text-align: center; color: #ffd700; font-size: 24px; margin-bottom: 12px; }
.tabs { display: flex; overflow-x: auto; gap: 4px; margin-bottom: 12px; -webkit-overflow-scrolling: touch; }
.tab { flex-shrink: 0; padding: 8px 14px; border-radius: 20px; font-size: 13px; background: rgba(212,168,67,0.1); border: 1px solid rgba(212,168,67,0.2); cursor: pointer; white-space: nowrap; transition: all 0.2s; }
.tab.active { background: rgba(212,168,67,0.25); border-color: #d4a843; color: #ffd700; font-weight: bold; }
.reward-info { background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.15); border-radius: 10px; padding: 10px; margin-bottom: 12px; text-align: center; }
.reward-title { color: #ffd700; font-size: 14px; font-weight: bold; margin-bottom: 4px; }
.reward-rules { color: #a08030; font-size: 12px; }
.list { min-height: 200px; }
.loading, .empty { text-align: center; color: #a08030; padding: 40px 0; }
.rank-row { display: flex; align-items: center; padding: 10px 12px; margin-bottom: 6px; background: rgba(212,168,67,0.06); border: 1px solid rgba(212,168,67,0.1); border-radius: 10px; transition: all 0.2s; }
.rank-row.top1 { background: linear-gradient(135deg, rgba(255,215,0,0.15), rgba(255,107,53,0.1)); border-color: rgba(255,215,0,0.4); box-shadow: 0 0 12px rgba(255,215,0,0.15); }
.rank-row.top2 { background: linear-gradient(135deg, rgba(192,192,192,0.1), rgba(212,168,67,0.08)); border-color: rgba(192,192,192,0.3); }
.rank-row.top3 { background: linear-gradient(135deg, rgba(205,127,50,0.1), rgba(212,168,67,0.08)); border-color: rgba(205,127,50,0.3); }
.rank-row.me { border-color: #ff6b35; box-shadow: 0 0 8px rgba(255,107,53,0.2); }
.rank-pos { width: 36px; text-align: center; font-size: 20px; flex-shrink: 0; }
.rank-num { color: #a08030; font-size: 14px; font-weight: bold; }
.rank-info { flex: 1; min-width: 0; }
.rank-name { color: #ffd700; font-size: 15px; font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.rank-realm { color: #a08030; font-size: 12px; }
.rank-score { color: #ff6b35; font-size: 16px; font-weight: bold; flex-shrink: 0; margin-left: 8px; }
.my-rank { position: sticky; bottom: 0; background: linear-gradient(135deg, #1a1520, #0b0b18); border: 1px solid #ff6b35; border-radius: 10px; padding: 10px 16px; display: flex; justify-content: space-between; color: #ffd700; font-weight: bold; margin-top: 12px; }
</style>
