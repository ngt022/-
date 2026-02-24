<template>
  <div class="arena-page">
    <div class="tabs">
      <div class="tab" :class="{active: tab==='arena'}" @click="tab='arena'">⚔️ 竞技场</div>
      <div class="tab" :class="{active: tab==='log'}" @click="tab='log';loadHistory()">📜 战报</div>
      <div class="tab" :class="{active: tab==='notif'}" @click="tab='notif';loadNotifs()">
        🔔 通知<span v-if="unreadNotifs>0" class="badge">{{ unreadNotifs }}</span>
      </div>
    </div>

    <!-- 竞技场 -->
    <div v-if="tab==='arena'">
      <div class="my-info">
        <div class="tier-icon">{{ tierEmoji[myRank.tier] || '🔰' }}</div>
        <div class="my-detail">
          <div class="my-tier">{{ tierName[myRank.tier] || '铜段' }} · {{ myRank.score }}分</div>
          <div class="my-daily">今日 {{ daily.used }}/{{ daily.max }} · {{ daily.wins }}胜</div>
        </div>
      </div>

      <div v-if="resultShow" class="result-overlay" @click="resultShow=false">
        <div class="result-card" @click.stop>
          <div class="result-icon">{{ lastResult.winner==='attacker' ? '🏆' : '💀' }}</div>
          <div class="result-text">{{ lastResult.winner==='attacker' ? '胜利！' : '失败...' }}</div>
          <div class="result-score" :class="lastResult.scoreChangeA>0?'pos':'neg'">
            {{ lastResult.scoreChangeA>0?'+':'' }}{{ lastResult.scoreChangeA }} 积分
          </div>
          <div v-if="lastResult.reward>0" class="result-reward">💎 +{{ lastResult.reward }} 焰晶</div>
          <div v-if="lastResult.dailyReward>0" class="result-daily">🎁 每日奖励 +{{ lastResult.dailyReward }} 焰晶</div>
          <button class="btn gold" @click="resultShow=false">继续挑战</button>
        </div>
      </div>

      <div v-if="loading" class="loading">加载中...</div>
      <div v-else-if="opponents.length===0" class="empty">暂无对手，稍后刷新</div>
      <div v-else class="opp-list">
        <div v-for="o in opponents" :key="o.wallet" class="opp-card">
          <div class="opp-left">
            <div class="opp-tier" :style="{color: tierColor[o.rankTier]}">{{ tierEmoji[o.rankTier] }}</div>
            <div class="opp-info">
              <div class="opp-name">{{ o.name }}</div>
              <div class="opp-sub">{{ o.realm }} Lv.{{ o.level }}</div>
              <div class="opp-stats">
                <span :class="o.combatPower > myCombatPower ? 'cp-high' : 'cp-low'">⚔️{{ o.combatPower }}</span>
                <span>胜率{{ o.winRate }}%</span>
              </div>
            </div>
          </div>
          <button class="btn fire" @click="challenge(o)" :disabled="challenging">⚔️ 挑战</button>
        </div>
      </div>
      <button class="btn gold full" @click="loadOpponents" :disabled="loading" style="margin-top:12px">🔄 刷新对手</button>
    </div>

    <!-- 战报 -->
    <div v-if="tab==='log'">
      <div v-if="battles.length===0" class="empty">暂无战斗记录</div>
      <div v-for="b in battles" :key="b.id" class="log-card">
        <div class="log-left">
          <div class="log-result" :class="getLogResult(b)">{{ getLogResult(b)==="win"?"胜":"负" }}</div>
          <div class="log-info">
            <div class="log-name">vs {{ b.attacker_wallet===myWallet ? b.defender_name : b.attacker_name }}</div>
            <div class="log-time">{{ formatTime(b.created_at) }}</div>
          </div>
        </div>
        <div class="log-score" :class="getLogScore(b)>0?'pos':'neg'">
          {{ getLogScore(b)>0?"+":"" }}{{ getLogScore(b) }}
        </div>
      </div>
    </div>

    <!-- 通知 -->
    <div v-if="tab==='notif'">
      <div v-if="notifs.length===0" class="empty">暂无通知</div>
      <div v-for="n in notifs" :key="n.id" class="notif-card">
        <div class="notif-left">
          <div class="notif-text">💀 {{ n.attacker_name }} 击败了你</div>
          <div class="notif-score neg">积分 {{ n.score_change }}</div>
          <div class="notif-time">{{ formatTime(n.created_at) }}</div>
        </div>
        <button v-if="!n.revenged && canRevenge(n)" class="btn fire sm" @click="revenge(n)">🔥 复仇</button>
        <span v-else-if="n.revenged" class="revenged">已复仇</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue"
import { useAuthStore } from "../stores/auth"
import { usePlayerStore } from "../stores/player"

const authStore = useAuthStore()
const playerStore = usePlayerStore()
const myWallet = computed(() => authStore.wallet || "")
const myCombatPower = computed(() => playerStore.combatPower || 0)

const tab = ref("arena")
const loading = ref(false)
const challenging = ref(false)
const resultShow = ref(false)
const lastResult = ref({})
const opponents = ref([])
const myRank = ref({ score: 0, tier: "bronze" })
const daily = ref({ used: 0, max: 5, wins: 0 })
const unreadNotifs = ref(0)
const battles = ref([])
const notifs = ref([])

const tierEmoji = { bronze: "🥉", silver: "🥈", gold: "🥇", diamond: "💎", emperor: "👑" }
const tierName = { bronze: "铜段", silver: "银段", gold: "金段", diamond: "钻石", emperor: "焰帝" }
const tierColor = { bronze: "#cd7f32", silver: "#c0c0c0", gold: "#ffd700", diamond: "#b9f2ff", emperor: "#ff4500" }

const formatTime = (t) => {
  if (!t) return ""
  const d = new Date(t)
  return (d.getMonth()+1) + "/" + d.getDate() + " " + d.getHours() + ":" + String(d.getMinutes()).padStart(2,"0")
}

const getLogResult = (b) => {
  if (b.winner === myWallet.value) return "win"
  if (b.winner === "draw") return "draw"
  return "lose"
}

const getLogScore = (b) => {
  return b.attacker_wallet === myWallet.value ? b.attacker_score_change : b.defender_score_change
}

const canRevenge = (n) => {
  const created = new Date(n.created_at)
  return (Date.now() - created.getTime()) < 24 * 3600 * 1000
}

const loadOpponents = async () => {
  loading.value = true
  try {
    const res = await authStore.apiGet("/arena/opponents")
    if (res.success) {
      opponents.value = res.opponents
      myRank.value = res.myRank
      daily.value = res.daily
      unreadNotifs.value = res.unreadNotifs
    }
  } catch (e) { console.error(e) }
  loading.value = false
}

const challenge = async (opp) => {
  challenging.value = true
  try {
    const res = await authStore.apiPost("/arena/challenge", { targetWallet: opp.wallet })
    if (res.success) {
      lastResult.value = res.result
      resultShow.value = true
      if (res.result.reward > 0 || res.result.dailyReward > 0) {
        playerStore.spiritStones = (playerStore.spiritStones || 0) + (res.result.reward || 0) + (res.result.dailyReward || 0)
      }
      myRank.value = { score: res.result.newRankScore, tier: res.result.newRankTier }
      daily.value.used++
      if (res.result.winner === "attacker") daily.value.wins++
    } else {
      alert(res.message || "挑战失败")
    }
  } catch (e) { alert("网络错误") }
  challenging.value = false
}

const revenge = async (n) => {
  challenging.value = true
  try {
    const res = await authStore.apiPost("/arena/challenge", { targetWallet: n.attacker_wallet, isRevenge: true })
    if (res.success) {
      lastResult.value = res.result
      resultShow.value = true
      if (res.result.reward > 0 || res.result.dailyReward > 0) {
        playerStore.spiritStones = (playerStore.spiritStones || 0) + (res.result.reward || 0) + (res.result.dailyReward || 0)
      }
      n.revenged = true
    } else {
      alert(res.message || "复仇失败")
    }
  } catch (e) { alert("网络错误") }
  challenging.value = false
}

const loadHistory = async () => {
  try {
    const res = await authStore.apiGet("/arena/history")
    if (res.success) battles.value = res.battles
  } catch (e) {}
}

const loadNotifs = async () => {
  try {
    const res = await authStore.apiGet("/arena/notifications")
    if (res.success) { notifs.value = res.notifications; unreadNotifs.value = 0 }
  } catch (e) {}
}

onMounted(() => { loadOpponents() })
</script>

<style scoped>
.arena-page { max-width: 500px; margin: 0 auto; padding: 16px; color: #d4a843; }
.tabs { display: flex; gap: 4px; margin-bottom: 14px; }
.tab { flex: 1; text-align: center; padding: 10px 0; border-radius: 10px; background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.15); cursor: pointer; font-size: 14px; position: relative; }
.tab.active { background: rgba(212,168,67,0.2); border-color: #d4a843; color: #ffd700; font-weight: bold; }
.badge { position: absolute; top: -4px; right: 8px; background: #ff4500; color: #fff; font-size: 11px; padding: 1px 6px; border-radius: 10px; }
.my-info { display: flex; align-items: center; gap: 12px; padding: 12px; background: linear-gradient(135deg, rgba(212,168,67,0.12), rgba(139,32,0,0.08)); border: 1px solid rgba(212,168,67,0.25); border-radius: 12px; margin-bottom: 14px; }
.tier-icon { font-size: 36px; }
.my-tier { color: #ffd700; font-weight: bold; font-size: 16px; }
.my-daily { color: #a08030; font-size: 13px; margin-top: 2px; }
.loading, .empty { text-align: center; color: #a08030; padding: 40px 0; }
.opp-list { display: flex; flex-direction: column; gap: 8px; }
.opp-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; background: rgba(212,168,67,0.06); border: 1px solid rgba(212,168,67,0.12); border-radius: 10px; }
.opp-left { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }
.opp-tier { font-size: 24px; }
.opp-name { color: #ffd700; font-weight: bold; font-size: 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.opp-sub { color: #a08030; font-size: 12px; }
.opp-stats { display: flex; gap: 8px; font-size: 12px; margin-top: 2px; }
.cp-high { color: #ff4500; }
.cp-low { color: #4caf50; }
.btn { padding: 8px 16px; border: none; border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; }
.btn:disabled { opacity: 0.5; }
.btn.fire { background: linear-gradient(135deg, #ff6b35, #8b2000); color: #fff; }
.btn.gold { background: linear-gradient(135deg, #d4a843, #8b6914); color: #0b0b18; }
.btn.full { display: block; width: 100%; }
.btn.sm { padding: 6px 12px; font-size: 12px; }
.result-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.7); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.result-card { background: #1a1520; border: 2px solid #d4a843; border-radius: 16px; padding: 24px; text-align: center; min-width: 260px; }
.result-icon { font-size: 48px; margin-bottom: 8px; }
.result-text { font-size: 24px; font-weight: bold; color: #ffd700; margin-bottom: 8px; }
.result-score { font-size: 20px; font-weight: bold; margin-bottom: 8px; }
.pos { color: #4caf50; }
.neg { color: #ff4500; }
.result-reward { color: #ffd700; font-size: 16px; margin-bottom: 4px; }
.result-daily { color: #d4a843; font-size: 14px; margin-bottom: 12px; }
.log-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; margin-bottom: 6px; background: rgba(212,168,67,0.06); border: 1px solid rgba(212,168,67,0.1); border-radius: 10px; }
.log-left { display: flex; align-items: center; gap: 10px; }
.log-result { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold; color: #fff; }
.log-result.win { background: #4caf50; }
.log-result.lose { background: #ff4500; }
.log-result.draw { background: #a08030; }
.log-name { color: #ffd700; font-size: 14px; }
.log-time { color: #a08030; font-size: 11px; }
.log-score { font-size: 16px; font-weight: bold; }
.notif-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; margin-bottom: 6px; background: rgba(255,69,0,0.06); border: 1px solid rgba(255,69,0,0.15); border-radius: 10px; }
.notif-text { color: #ff6b35; font-size: 14px; }
.notif-score { font-size: 13px; }
.notif-time { color: #a08030; font-size: 11px; }
.revenged { color: #4caf50; font-size: 12px; }
</style>
