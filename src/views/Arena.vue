<template>
  <div class="arena-page">
    <!-- 战斗回放 -->
    <template v-if="battleResult">
      <div class="battle-arena">
        <!-- 倒计时 -->
        <div v-if="showCountdown" class="battle-intro">
          <div class="intro-fighters">
            <div class="intro-fighter">
              <div class="intro-avatar fa">{{ battleResult.nameA[0] }}</div>
              <div class="intro-name">{{ battleResult.nameA }}</div>
            </div>
            <div class="intro-vs">VS</div>
            <div class="intro-fighter">
              <div class="intro-avatar fb">{{ battleResult.nameB[0] }}</div>
              <div class="intro-name">{{ battleResult.nameB }}</div>
            </div>
          </div>
          <div class="countdown">{{ countdownText }}</div>
        </div>

        <!-- 战斗主体 -->
        <div v-else-if="!battleEnded">
          <div class="battle-header">
            <div class="fighter">
              <div class="fighter-avatar fa">{{ battleResult.nameA[0] }}</div>
              <div class="fighter-info">
                <div class="fighter-name">{{ battleResult.nameA }}</div>
                <div class="hp-wrapper">
                  <div class="hp-bar"><div class="hp-fill" :class="hpColorClass(currentHpA, battleResult.maxHpA)" :style="{width: hpPercent(currentHpA, battleResult.maxHpA)}"></div></div>
                  <span class="hp-text">{{ currentHpA }}/{{ battleResult.maxHpA }}</span>
                </div>
              </div>
            </div>
            <div class="vs-center">
              <span class="vs-text">VS</span>
              <span class="round-num">第{{ currentRoundIndex+1 }}回合</span>
            </div>
            <div class="fighter">
              <div class="fighter-avatar fb">{{ battleResult.nameB[0] }}</div>
              <div class="fighter-info">
                <div class="fighter-name">{{ battleResult.nameB }}</div>
                <div class="hp-wrapper">
                  <div class="hp-bar"><div class="hp-fill" :class="hpColorClass(currentHpB, battleResult.maxHpB)" :style="{width: hpPercent(currentHpB, battleResult.maxHpB)}"></div></div>
                  <span class="hp-text">{{ currentHpB }}/{{ battleResult.maxHpB }}</span>
                </div>
              </div>
            </div>
          </div>
          <div class="current-round" v-if="currentRound">
            <div v-for="(a, i) in currentRound.actions" :key="i" class="action-line" :class="{flash: actionFlash}">
              <span :class="a.attacker===A?side-a:side-b">{{ a.attacker===A?battleResult.nameA:battleResult.nameB }}</span>
              <span class="arrow">→</span>
              <span :class="a.attacker===A?side-b:side-a">{{ a.attacker===A?battleResult.nameB:battleResult.nameA }}</span>
              <template v-if="a.isDodged"><span class="eff dodge">💨 闪避</span></template>
              <template v-else>
                <span class="dmg" :class="{crit:a.isCrit}">-{{ a.damage }}</span>
                <span v-if="a.isCrit" class="eff crit">💥暴击</span>
                <span v-if="a.isVampire" class="eff vamp">🩸+{{ a.vampireHeal }}</span>
              </template>
            </div>
          </div>
          <div v-if="showKillShot" class="kill-shot">致命一击！</div>
          <button class="btn gold full" @click="skipAnimation" style="margin-top:12px">⏩ 跳过</button>
        </div>

        <!-- 战斗结束 -->
        <div v-else class="result-card">
          <div class="result-icon">{{ resultEmoji }}</div>
          <div class="result-text">{{ resultLabel }}</div>
          <div class="result-score" :class="lastScoreChange>0?'pos':'neg'">{{ lastScoreChange>0?"+":"" }}{{ lastScoreChange }} 积分</div>
          <div v-if="lastReward>0" class="result-reward">💎 +{{ lastReward }} 焰晶</div>
          <div v-if="lastDailyReward>0" class="result-daily">🎁 每日奖励 +{{ lastDailyReward }} 焰晶</div>
          <button class="btn gold full" @click="battleResult=null" style="margin-top:12px">继续挑战</button>
        </div>
      </div>
    </template>

    <!-- 主界面 -->
    <template v-else>
      <div class="tabs">
        <div class="tab" :class="{active:tab===arena}" @click="tab=arena">⚔️ 竞技场</div>
        <div class="tab" :class="{active:tab===log}" @click="tab=log;loadHistory()">📜 战报</div>
        <div class="tab" :class="{active:tab===notif}" @click="tab=notif;loadNotifs()">🔔 通知<span v-if="unreadNotifs>0" class="badge">{{ unreadNotifs }}</span></div>
      </div>

      <div v-if="tab===arena">
        <div class="my-info">
          <div class="tier-icon">{{ tierEmoji[myRank.tier] || '🔰' }}</div>
          <div class="my-detail">
            <div class="my-tier">{{ tierName[myRank.tier]||铜段 }} · {{ myRank.score }}分</div>
            <div class="my-daily">今日 {{ daily.used }}/{{ daily.max }}次{{ daily.used>=daily.max?" (额外200💎/次)":"" }} · {{ daily.wins }}胜</div>
          </div>
        </div>
        <div v-if="loading" class="loading">加载中...</div>
        <div v-else-if="opponents.length===0" class="empty">暂无对手，稍后刷新</div>
        <div v-else class="opp-list">
          <div v-for="o in opponents" :key="o.wallet" class="opp-card">
            <div class="opp-left">
              <div class="opp-tier" :style="{color:tierColor[o.rankTier]}">{{ tierEmoji[o.rankTier] }}</div>
              <div class="opp-info">
                <div class="opp-name">{{ o.name }}</div>
                <div class="opp-sub">{{ o.realm }} Lv.{{ o.level }}</div>
                <div class="opp-stats">
                  <span :class="o.combatPower>myCombatPower?cp-high:cp-low">⚔️{{ o.combatPower }}</span>
                  <span>胜率{{ o.winRate }}%</span>
                </div>
              </div>
            </div>
            <button class="btn fire" @click="challenge(o)" :disabled="challenging">⚔️ {{ daily.used>=daily.max ? "挑战(200💎)" : "挑战" }}</button>
          </div>
        </div>
        <button class="btn gold full" @click="loadOpponents" :disabled="loading" style="margin-top:12px">🔄 刷新对手</button>
      </div>

      <div v-if="tab==='log'">
        <div v-if="battles.length===0" class="empty">暂无战斗记录</div>
        <div v-for="b in battles" :key="b.id" class="log-card">
          <div class="log-left">
            <div class="log-result" :class="getLogResult(b)">{{ getLogResult(b)==="win"?"胜":"负" }}</div>
            <div class="log-info">
              <div class="log-name">vs {{ b.attacker_wallet===myWallet?b.defender_name:b.attacker_name }}</div>
              <div class="log-time">{{ formatTime(b.created_at) }}</div>
            </div>
          </div>
          <div class="log-score" :class="getLogScore(b)>0?'pos':'neg'">{{ getLogScore(b)>0?"+":"" }}{{ getLogScore(b) }}</div>
        </div>
      </div>

      <div v-if="tab==='notif'">
        <div v-if="notifs.length===0" class="empty">暂无通知</div>
        <div v-for="n in notifs" :key="n.id" class="notif-card">
          <div class="notif-left">
            <div class="notif-text">💀 {{ n.attacker_name }} 击败了你</div>
            <div class="notif-score neg">积分 {{ n.score_change }}</div>
            <div class="notif-time">{{ formatTime(n.created_at) }}</div>
          </div>
          <button v-if="!n.revenged&&canRevenge(n)" class="btn fire sm" @click="revenge(n)">🔥 复仇</button>
          <span v-else-if="n.revenged" class="revenged">已复仇</span>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, onUnmounted } from "vue"
import { useAuthStore } from "../stores/auth"
import { usePlayerStore } from "../stores/player"

const authStore = useAuthStore()
const playerStore = usePlayerStore()
const myWallet = computed(() => authStore.wallet || "")
const myCombatPower = computed(() => playerStore.combatPower || 0)

const tab = ref("arena")
const loading = ref(false)
const challenging = ref(false)
const opponents = ref([])
const myRank = ref({ score: 0, tier: "bronze" })
const daily = ref({ used: 0, max: 5, wins: 0 })
const unreadNotifs = ref(0)
const battles = ref([])
const notifs = ref([])

// Battle replay state
const battleResult = ref(null)
const showCountdown = ref(false)
const countdownText = ref("3")
const currentRoundIndex = ref(0)
const currentHpA = ref(0)
const currentHpB = ref(0)
const battleEnded = ref(false)
const showKillShot = ref(false)
const actionFlash = ref(false)
const animationTimer = ref(null)
const lastWinner = ref("")
const lastScoreChange = ref(0)
const lastReward = ref(0)
const lastDailyReward = ref(0)

const resultEmoji = computed(() => lastWinner.value === 'attacker' ? '\u{1F3C6}' : '\u{1F480}')
const resultLabel = computed(() => lastWinner.value === 'attacker' ? '胜利！' : '失败...')

const currentRound = computed(() => {
  if (!battleResult.value?.rounds) return null
  return battleResult.value.rounds[currentRoundIndex.value]
})

const tierEmoji = { bronze: "🥉", silver: "🥈", gold: "🥇", diamond: "💎", emperor: "👑" }
const tierName = { bronze: "铜段", silver: "银段", gold: "金段", diamond: "钻石", emperor: "焰帝" }
const tierColor = { bronze: "#cd7f32", silver: "#c0c0c0", gold: "#ffd700", diamond: "#b9f2ff", emperor: "#ff4500" }

const hpPercent = (hp, max) => `${Math.max(0, (hp / max) * 100).toFixed(1)}%`
const hpColorClass = (hp, max) => {
  const pct = hp / max
  if (pct > 0.5) return "hp-green"
  if (pct > 0.2) return "hp-yellow"
  return "hp-red"
}

const formatTime = (t) => {
  if (!t) return ""
  const d = new Date(t)
  return (d.getMonth()+1) + "/" + d.getDate() + " " + d.getHours() + ":" + String(d.getMinutes()).padStart(2,"0")
}
const getLogResult = (b) => b.winner === myWallet.value ? "win" : b.winner === "draw" ? "draw" : "lose"
const getLogScore = (b) => b.attacker_wallet === myWallet.value ? b.attacker_score_change : b.defender_score_change
const canRevenge = (n) => (Date.now() - new Date(n.created_at).getTime()) < 24 * 3600 * 1000

const clearTimer = () => { if (animationTimer.value) { clearTimeout(animationTimer.value); animationTimer.value = null } }

const startCountdown = () => {
  showCountdown.value = true
  let num = 3
  countdownText.value = "3"
  const step = () => {
    num--
    if (num > 0) { countdownText.value = String(num); animationTimer.value = setTimeout(step, 1000) }
    else { countdownText.value = "开战！"; animationTimer.value = setTimeout(() => { showCountdown.value = false; startBattlePlayback() }, 800) }
  }
  animationTimer.value = setTimeout(step, 1000)
}

const startBattlePlayback = () => {
  currentHpA.value = battleResult.value.maxHpA
  currentHpB.value = battleResult.value.maxHpB
  currentRoundIndex.value = 0
  battleEnded.value = false
  showKillShot.value = false
  playNextAction()
}

const playNextAction = () => {
  if (!battleResult.value) return
  const rounds = battleResult.value.rounds
  if (currentRoundIndex.value >= rounds.length) { endBattle(); return }
  const round = rounds[currentRoundIndex.value]
  actionFlash.value = true
  setTimeout(() => { actionFlash.value = false }, 300)
  const hasCrit = round.actions?.some(a => a.isCrit)
  if (hasCrit) {
    const el = document.querySelector(".battle-arena")
    if (el) { el.classList.add("screen-shake"); setTimeout(() => el.classList.remove("screen-shake"), 400) }
  }
  for (const action of (round.actions || [])) {
    if (!action.isDodged) {
      if (action.attacker === "A") currentHpB.value = Math.max(0, currentHpB.value - action.damage)
      else currentHpA.value = Math.max(0, currentHpA.value - action.damage)
    }
    if (action.isVampire && action.vampireHeal) {
      if (action.attacker === "A") currentHpA.value = Math.min(battleResult.value.maxHpA, currentHpA.value + action.vampireHeal)
      else currentHpB.value = Math.min(battleResult.value.maxHpB, currentHpB.value + action.vampireHeal)
    }
  }
  if (round.hpA !== undefined) currentHpA.value = round.hpA
  if (round.hpB !== undefined) currentHpB.value = round.hpB
  const isLast = currentRoundIndex.value === rounds.length - 1
  if (isLast) {
    animationTimer.value = setTimeout(() => {
      showKillShot.value = true
      animationTimer.value = setTimeout(() => { showKillShot.value = false; endBattle() }, 1500)
    }, 800)
  } else {
    currentRoundIndex.value++
    animationTimer.value = setTimeout(playNextAction, 1200)
  }
}

const endBattle = () => {
  battleEnded.value = true
  if (battleResult.value.finalHpA !== undefined) currentHpA.value = battleResult.value.finalHpA
  if (battleResult.value.finalHpB !== undefined) currentHpB.value = battleResult.value.finalHpB
}

const skipAnimation = () => {
  clearTimer()
  showCountdown.value = false
  showKillShot.value = false
  if (battleResult.value?.rounds?.length) currentRoundIndex.value = battleResult.value.rounds.length - 1
  if (battleResult.value.finalHpA !== undefined) currentHpA.value = battleResult.value.finalHpA
  if (battleResult.value.finalHpB !== undefined) currentHpB.value = battleResult.value.finalHpB
  battleEnded.value = true
}

const startBattle = (res) => {
  lastWinner.value = res.result.winner
  lastScoreChange.value = res.result.scoreChangeA
  lastReward.value = res.result.reward || 0
  lastDailyReward.value = res.result.dailyReward || 0
  battleResult.value = res.result
  if (res.result.reward > 0 || res.result.dailyReward > 0) {
    playerStore.spiritStones = (playerStore.spiritStones || 0) + (res.result.reward || 0) + (res.result.dailyReward || 0)
  }
  myRank.value = { score: res.result.newRankScore, tier: res.result.newRankTier }
  startCountdown()
}

const loadOpponents = async () => {
  loading.value = true
  try {
    const res = await authStore.apiGet("/arena/opponents")
    if (res.success) { opponents.value = res.opponents; myRank.value = res.myRank; daily.value = res.daily; unreadNotifs.value = res.unreadNotifs }
  } catch (e) { console.error(e) }
  loading.value = false
}

const challenge = async (opp) => {
  challenging.value = true
  try {
    const res = await authStore.apiPost("/arena/challenge", { targetWallet: opp.wallet })
    if (res.success) { daily.value.used++; if (res.result.winner === "attacker") daily.value.wins++; startBattle(res) }
    else { if (res.needPay && confirm("免费次数已用完，花费200焰晶继续挑战？")) { /* 前端已处理，后端自动扣费 */ } else alert(res.message || "挑战失败") }
  } catch (e) { alert("网络错误") }
  challenging.value = false
}

const revenge = async (n) => {
  challenging.value = true
  try {
    const res = await authStore.apiPost("/arena/challenge", { targetWallet: n.attacker_wallet, isRevenge: true })
    if (res.success) { n.revenged = true; startBattle(res) }
    else alert(res.message || "复仇失败")
  } catch (e) { alert("网络错误") }
  challenging.value = false
}

const loadHistory = async () => { try { const r = await authStore.apiGet("/arena/history"); if (r.success) battles.value = r.battles } catch(e){} }
const loadNotifs = async () => { try { const r = await authStore.apiGet("/arena/notifications"); if (r.success) { notifs.value = r.notifications; unreadNotifs.value = 0 } } catch(e){} }

onMounted(() => { loadOpponents() })
onUnmounted(() => { clearTimer() })
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
.cp-high { color: #ff4500; } .cp-low { color: #4caf50; }
.btn { padding: 8px 16px; border: none; border-radius: 8px; font-size: 14px; font-weight: bold; cursor: pointer; }
.btn:disabled { opacity: 0.5; }
.btn.fire { background: linear-gradient(135deg, #ff6b35, #8b2000); color: #fff; }
.btn.gold { background: linear-gradient(135deg, #d4a843, #8b6914); color: #0b0b18; }
.btn.full { display: block; width: 100%; }
.btn.sm { padding: 6px 12px; font-size: 12px; }
/* Battle */
.battle-arena { padding: 8px; }
.battle-intro { text-align: center; padding: 40px 0; }
.intro-fighters { display: flex; justify-content: center; align-items: center; gap: 24px; margin-bottom: 20px; }
.intro-fighter { text-align: center; }
.intro-avatar { width: 56px; height: 56px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: bold; color: #fff; margin: 0 auto 8px; }
.intro-avatar.fa { background: linear-gradient(135deg, #d4a843, #8b6914); }
.intro-avatar.fb { background: linear-gradient(135deg, #ff6b35, #8b2000); }
.intro-name { color: #ffd700; font-weight: bold; }
.intro-vs { font-size: 28px; font-weight: bold; color: #ff4500; }
.countdown { font-size: 48px; font-weight: bold; color: #ffd700; animation: pulse 0.5s ease-in-out; }
@keyframes pulse { 0%{transform:scale(0.5);opacity:0} 50%{transform:scale(1.2)} 100%{transform:scale(1);opacity:1} }
.battle-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; margin-bottom: 12px; }
.fighter { flex: 1; text-align: center; }
.fighter-avatar { width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 18px; font-weight: bold; color: #fff; margin: 0 auto 4px; }
.fighter-avatar.fa { background: linear-gradient(135deg, #d4a843, #8b6914); }
.fighter-avatar.fb { background: linear-gradient(135deg, #ff6b35, #8b2000); }
.fighter-name { color: #ffd700; font-size: 13px; font-weight: bold; margin-bottom: 4px; }
.hp-wrapper { width: 100%; }
.hp-bar { height: 10px; background: rgba(255,255,255,0.1); border-radius: 5px; overflow: hidden; }
.hp-fill { height: 100%; transition: width 0.5s ease; border-radius: 5px; }
.hp-green { background: #4caf50; } .hp-yellow { background: #ff9800; } .hp-red { background: #f44336; }
.hp-text { font-size: 11px; color: #a08030; }
.vs-center { text-align: center; padding: 0 4px; }
.vs-text { color: #ff4500; font-weight: bold; font-size: 16px; }
.round-num { display: block; color: #a08030; font-size: 11px; }
.current-round { background: rgba(0,0,0,0.3); border-radius: 10px; padding: 10px; margin-bottom: 8px; }
.action-line { padding: 4px 0; font-size: 13px; display: flex; flex-wrap: wrap; gap: 4px; align-items: center; }
.action-line.flash { animation: flashBg 0.3s; }
@keyframes flashBg { 0%{background:rgba(255,215,0,0.2)} 100%{background:transparent} }
.side-a { color: #d4a843; font-weight: bold; } .side-b { color: #ff6b35; font-weight: bold; }
.arrow { color: #666; }
.dmg { color: #ff4500; font-weight: bold; } .dmg.crit { color: #ff0; font-size: 15px; }
.eff { font-size: 12px; margin-left: 2px; } .eff.dodge { color: #aaa; } .eff.crit { color: #ff0; } .eff.vamp { color: #f44; }
.kill-shot { text-align: center; font-size: 28px; font-weight: bold; color: #ff4500; animation: pulse 0.5s; padding: 16px; }
.result-card { text-align: center; padding: 24px; background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.25); border-radius: 16px; }
.result-icon { font-size: 48px; margin-bottom: 8px; }
.result-text { font-size: 24px; font-weight: bold; color: #ffd700; margin-bottom: 8px; }
.result-score { font-size: 20px; font-weight: bold; margin-bottom: 8px; }
.pos { color: #4caf50; } .neg { color: #ff4500; }
.result-reward { color: #ffd700; font-size: 16px; margin-bottom: 4px; }
.result-daily { color: #d4a843; font-size: 14px; margin-bottom: 12px; }
.log-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; margin-bottom: 6px; background: rgba(212,168,67,0.06); border: 1px solid rgba(212,168,67,0.1); border-radius: 10px; }
.log-left { display: flex; align-items: center; gap: 10px; }
.log-result { width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold; color: #fff; }
.log-result.win { background: #4caf50; } .log-result.lose { background: #ff4500; } .log-result.draw { background: #a08030; }
.log-name { color: #ffd700; font-size: 14px; } .log-time { color: #a08030; font-size: 11px; }
.log-score { font-size: 16px; font-weight: bold; }
.notif-card { display: flex; align-items: center; justify-content: space-between; padding: 10px 12px; margin-bottom: 6px; background: rgba(255,69,0,0.06); border: 1px solid rgba(255,69,0,0.15); border-radius: 10px; }
.notif-text { color: #ff6b35; font-size: 14px; } .notif-score { font-size: 13px; } .notif-time { color: #a08030; font-size: 11px; }
.revenged { color: #4caf50; font-size: 12px; }
@keyframes battle-shake { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-4px)} 75%{transform:translateX(4px)} }
.screen-shake { animation: battle-shake 0.4s ease-out; }
</style>
