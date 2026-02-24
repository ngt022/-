<template>
  <div class="sect-war-page">
    <game-guide>
      <p>⚔️ <strong>焰盟间PVP对战</strong>，盟主发起挑战</p>
      <p>👥 双方成员报名参战，按战力匹配逐轮对决</p>
      <p>🏆 胜方获得<strong>积分+焰晶+贡献度</strong></p>
      <p>📊 按积分排名，争夺焰盟荣耀！</p>
    </game-guide>
    <n-tabs v-model:value="activeTab" type="segment" animated>
      <n-tab-pane name="main" tab="⚔️ 焰盟战">
        <!-- 战绩卡片 -->
        <n-card class="war-stats-card" :bordered="false">
          <div class="stats-header">
            <span class="gold-title">⚔️ 焰盟战绩</span>
          </div>
          <div class="stats-grid" v-if="myRanking">
            <div class="stat-item"><div class="stat-value win">{{ myRanking.wins }}</div><div class="stat-label">胜场</div></div>
            <div class="stat-item"><div class="stat-value lose">{{ myRanking.losses }}</div><div class="stat-label">负场</div></div>
            <div class="stat-item"><div class="stat-value points">{{ myRanking.points }}</div><div class="stat-label">积分</div></div>
            <div class="stat-item"><div class="stat-value rank">{{ myRankPos || '-' }}</div><div class="stat-label">排名</div></div>
          </div>
          <div v-else class="no-data">暂无战绩</div>
        </n-card>

        <!-- 未领取奖励 -->
        <n-card v-if="unclaimedRewards.length" class="reward-alert-card" :bordered="false">
          <div class="reward-alert">
            <span>🎁 你有 {{ unclaimedRewards.length }} 个未领取的焰盟战奖励！</span>
            <n-button type="warning" size="small" @click="claimRewards" :loading="claiming">领取全部</n-button>
          </div>
        </n-card>

        <!-- 当前焰盟战 -->
        <n-card v-if="currentWar" class="current-war-card" :bordered="false">
          <div class="war-header">
            <span class="gold-title">🔥 当前焰盟战</span>
            <n-tag :type="currentWar.status === 'in_progress' ? 'warning' : 'info'" size="small">
              {{ currentWar.status === 'pending' ? '等待接受' : currentWar.rounds_data ? '已结束' : '报名中' }}
            </n-tag>
          </div>

          <div class="war-versus">
            <div class="war-side challenger">
              <div class="sect-name">{{ currentWar.challenger_name }}</div>
              <div class="sect-score">{{ currentWar.challenger_score }}</div>
            </div>
            <div class="vs-badge">VS</div>
            <div class="war-side defender">
              <div class="sect-name">{{ currentWar.defender_name }}</div>
              <div class="sect-score">{{ currentWar.defender_score }}</div>
            </div>
          </div>

          <!-- 参战名单 -->
          <div v-if="currentWar.status === 'in_progress'" class="participants-section">
            <div class="participants-grid">
              <div class="team-col">
                <div class="team-title">挑战方</div>
                <div v-for="p in challengerParticipants" :key="p.id" class="participant-item">
                  <span class="p-name">{{ p.player_name }}</span>
                  <span class="p-power">⚡{{ p.combat_power }}</span>
                </div>
                <div v-if="!challengerParticipants.length" class="no-participant">暂无报名</div>
              </div>
              <div class="team-col">
                <div class="team-title">防守方</div>
                <div v-for="p in defenderParticipants" :key="p.id" class="participant-item">
                  <span class="p-name">{{ p.player_name }}</span>
                  <span class="p-power">⚡{{ p.combat_power }}</span>
                </div>
                <div v-if="!defenderParticipants.length" class="no-participant">暂无报名</div>
              </div>
            </div>

            <div class="war-actions" v-if="!currentWar.rounds_data">
              <n-button v-if="canJoin" type="info" @click="joinWar" :loading="joining">📋 报名参战</n-button>
              <n-button v-if="isLeader" type="warning" @click="startBattle" :loading="starting"
                :disabled="!challengerParticipants.length || !defenderParticipants.length">
                ⚔️ 开始战斗
              </n-button>
            </div>
          </div>

          <!-- 战斗回放 -->
          <div v-if="currentWar.rounds_data" class="battle-replay">
            <div class="replay-title">⚔️ 战斗回放</div>
            <div v-for="round in parsedRounds" :key="round.round" class="round-item">
              <div class="round-header">第 {{ round.round }} 轮</div>
              <div class="round-battle">
                <div class="fighter left" :class="{ winner: round.challenger.win }">
                  <span class="fighter-name">{{ round.challenger.name }}</span>
                  <span class="fighter-power">⚡{{ round.challenger.combat_power }}</span>
                  <span class="fighter-result">{{ round.challenger.win ? '✅' : '❌' }}</span>
                </div>
                <div class="power-bar">
                  <div class="power-fill left" :style="{ width: getPowerPercent(round, 'challenger') + '%' }"></div>
                  <div class="power-fill right" :style="{ width: getPowerPercent(round, 'defender') + '%' }"></div>
                </div>
                <div class="fighter right" :class="{ winner: round.defender.win }">
                  <span class="fighter-result">{{ round.defender.win ? '✅' : '❌' }}</span>
                  <span class="fighter-power">⚡{{ round.defender.combat_power }}</span>
                  <span class="fighter-name">{{ round.defender.name }}</span>
                </div>
              </div>
            </div>
            <div class="final-result" :class="{ win: isWarWinner, lose: !isWarWinner && currentWar.winner_sect_id }">
              {{ isWarWinner ? '🎉 胜利！' : (!currentWar.winner_sect_id ? '⚖️ 平局' : '😔 失败...') }}
            </div>
          </div>
        </n-card>

        <!-- 发起挑战 -->
        <n-card class="challenge-card" :bordered="false">
          <div class="war-header">
            <span class="gold-title">📜 发起挑战</span>
          </div>
          <n-button type="warning" block @click="showChallengeModal = true" :disabled="!!currentWar">
            ⚔️ 选择焰盟发起挑战
          </n-button>
        </n-card>

        <!-- 收到的挑战 -->
        <n-card v-if="pendingWars.length" class="pending-card" :bordered="false">
          <div class="war-header">
            <span class="gold-title">📨 收到的挑战</span>
          </div>
          <div v-for="pw in pendingWars" :key="pw.id" class="pending-item">
            <div class="pending-info">
              <span class="pending-name">{{ pw.challenger_name }}</span>
              <span class="pending-members">{{ pw.challenger_members }}人</span>
            </div>
            <div class="pending-actions">
              <n-button type="success" size="small" @click="acceptWar(pw.id)" :loading="accepting">接受</n-button>
              <n-button type="error" size="small" @click="declineWar(pw.id)" :loading="declining">拒绝</n-button>
            </div>
          </div>
        </n-card>
      </n-tab-pane>

      <n-tab-pane name="history" tab="📜 历史">
        <div v-if="!historyWars.length" class="no-data">暂无焰盟战记录</div>
        <div v-for="hw in historyWars" :key="hw.id" class="history-item">
          <div class="history-left">
            <div class="history-names">
              {{ hw.challenger_name }} vs {{ hw.defender_name }}
            </div>
            <div class="history-time">{{ formatTime(hw.finished_at) }}</div>
          </div>
          <div class="history-right">
            <div class="history-score">{{ hw.challenger_score }} : {{ hw.defender_score }}</div>
            <n-tag :type="hw.winner_sect_id === mySectId ? 'success' : (hw.winner_sect_id ? 'error' : 'default')" size="small">
              {{ hw.winner_sect_id === mySectId ? '胜' : (hw.winner_sect_id ? '负' : '平') }}
            </n-tag>
          </div>
        </div>
      </n-tab-pane>

      <n-tab-pane name="ranking" tab="🏆 焰榜">
        <div v-if="!rankings.length" class="no-data">暂无排行数据</div>
        <div v-for="(r, idx) in rankings" :key="r.id" class="rank-item" :class="{ 'rank-gold': idx===0, 'rank-silver': idx===1, 'rank-bronze': idx===2 }">
          <div class="rank-pos">
            <span v-if="idx===0">🥇</span>
            <span v-else-if="idx===1">🥈</span>
            <span v-else-if="idx===2">🥉</span>
            <span v-else>{{ idx + 1 }}</span>
          </div>
          <div class="rank-info">
            <div class="rank-name">{{ r.sect_name }}</div>
            <div class="rank-detail">Lv.{{ r.sect_level }} | {{ r.wins }}胜 {{ r.losses }}负</div>
          </div>
          <div class="rank-points">{{ r.points }}分</div>
        </div>
      </n-tab-pane>

      <n-tab-pane name="rewards" tab="🎁 奖励">
        <div v-if="!allRewards.length" class="no-data">暂无奖励记录</div>
        <div v-for="rw in allRewards" :key="rw.id" class="reward-item">
          <div class="reward-info">
            <div>{{ rw.challenger_name }} vs {{ rw.defender_name }}</div>
            <div class="reward-detail">💎{{ rw.reward_stones }}焰晶 + 🏅{{ rw.reward_contribution }}贡献</div>
          </div>
          <n-tag :type="rw.claimed ? 'default' : 'warning'" size="small">
            {{ rw.claimed ? '已领取' : '未领取' }}
          </n-tag>
        </div>
        <n-button v-if="unclaimedRewards.length" type="warning" block style="margin-top:12px" @click="claimRewards" :loading="claiming">
          领取全部奖励
        </n-button>
      </n-tab-pane>
    </n-tabs>

    <!-- 选择焰盟弹窗 -->
    <n-modal v-model:show="showChallengeModal" preset="card" title="选择挑战目标" style="max-width:500px">
      <n-input v-model:value="searchSect" placeholder="搜索焰盟名称..." clearable style="margin-bottom:12px" />
      <div class="sect-list">
        <div v-for="s in filteredSects" :key="s.id" class="sect-option" @click="doChallenge(s.id)">
          <div class="sect-opt-name">{{ s.name }}</div>
          <div class="sect-opt-info">Lv.{{ s.level }} | {{ s.member_count }}人</div>
        </div>
        <div v-if="!filteredSects.length" class="no-data">没有可挑战的焰盟</div>
      </div>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { createDiscreteApi } from 'naive-ui'
import GameGuide from '../components/GameGuide.vue'

const { message } = createDiscreteApi(['message'])
const playerStore = usePlayerStore()
const authStore = useAuthStore()

const activeTab = ref('main')
const currentWar = ref(null)
const participants = ref([])
const mySectId = ref(null)
const pendingWars = ref([])
const historyWars = ref([])
const rankings = ref([])
const allRewards = ref([])
const sectList = ref([])
const myRanking = ref(null)
const myRankPos = ref(null)
const showChallengeModal = ref(false)
const searchSect = ref('')

const joining = ref(false)
const starting = ref(false)
const accepting = ref(false)
const declining = ref(false)
const claiming = ref(false)

const API = '/api'
const headers = () => ({ 'Content-Type': 'application/json', Authorization: `Bearer ${authStore.token}` })

const challengerParticipants = computed(() => participants.value.filter(p => p.sect_id === currentWar.value?.challenger_sect_id))
const defenderParticipants = computed(() => participants.value.filter(p => p.sect_id === currentWar.value?.defender_sect_id))
const unclaimedRewards = computed(() => allRewards.value.filter(r => !r.claimed))
const filteredSects = computed(() => {
  let list = sectList.value.filter(s => s.id !== mySectId.value)
  if (searchSect.value) list = list.filter(s => s.name.includes(searchSect.value))
  return list
})
const parsedRounds = computed(() => {
  if (!currentWar.value?.rounds_data) return []
  const d = currentWar.value.rounds_data
  return typeof d === 'string' ? JSON.parse(d) : d
})
const isWarWinner = computed(() => currentWar.value?.winner_sect_id === mySectId.value)
const isLeader = computed(() => {
  // check from sect info
  return authStore.wallet && currentWar.value && participants.value.length >= 0
    ? true : false // simplified, real check via API
})
const canJoin = computed(() => {
  if (!currentWar.value || currentWar.value.rounds_data) return false
  const myP = participants.value.find(p => p.wallet === authStore.wallet?.toLowerCase())
  return !myP
})

function getPowerPercent(round, side) {
  const c = round.challenger.combat_power || 1
  const d = round.defender.combat_power || 1
  const total = c + d
  return side === 'challenger' ? (c / total * 100).toFixed(1) : (d / total * 100).toFixed(1)
}

function formatTime(t) {
  if (!t) return ''
  return new Date(t).toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
}

async function fetchAll() {
  try {
    const [curRes, pendRes, histRes, rankRes, rewRes, sectRes] = await Promise.all([
      fetch(`${API}/sect-war/current`, { headers: headers() }),
      fetch(`${API}/sect-war/pending`, { headers: headers() }),
      fetch(`${API}/sect-war/history`, { headers: headers() }),
      fetch(`${API}/sect-war/ranking`, { headers: headers() }),
      fetch(`${API}/sect-war/rewards`, { headers: headers() }),
      fetch(`${API}/sect/list`, { headers: headers() }),
    ])
    const cur = await curRes.json()
    currentWar.value = cur.war
    participants.value = cur.participants || []
    mySectId.value = cur.mySectId

    const pend = await pendRes.json()
    pendingWars.value = pend.wars || []

    const hist = await histRes.json()
    historyWars.value = hist.wars || []
    if (hist.mySectId) mySectId.value = hist.mySectId

    const rank = await rankRes.json()
    rankings.value = rank.rankings || []
    // find my ranking
    if (mySectId.value) {
      const idx = rankings.value.findIndex(r => r.sect_id === mySectId.value)
      if (idx >= 0) { myRanking.value = rankings.value[idx]; myRankPos.value = idx + 1 }
    }

    const rew = await rewRes.json()
    allRewards.value = rew.rewards || []

    const sects = await sectRes.json()
    sectList.value = sects.sects || []
  } catch (e) { console.error(e) }
}

async function doChallenge(defId) {
  try {
    const res = await fetch(`${API}/sect-war/challenge`, {
      method: 'POST', headers: headers(), body: JSON.stringify({ defender_sect_id: defId })
    })
    const data = await res.json()
    if (data.ok) { message.success('挑战已发出！'); showChallengeModal.value = false; fetchAll() }
    else message.error(data.error || '发起失败')
  } catch (e) { message.error('网络错误') }
}

async function acceptWar(warId) {
  accepting.value = true
  try {
    const res = await fetch(`${API}/sect-war/accept`, {
      method: 'POST', headers: headers(), body: JSON.stringify({ war_id: warId })
    })
    const data = await res.json()
    if (data.ok) { message.success('已接受挑战！'); fetchAll() }
    else message.error(data.error)
  } catch (e) { message.error('网络错误') }
  accepting.value = false
}

async function declineWar(warId) {
  declining.value = true
  try {
    const res = await fetch(`${API}/sect-war/decline`, {
      method: 'POST', headers: headers(), body: JSON.stringify({ war_id: warId })
    })
    const data = await res.json()
    if (data.ok) { message.success('已拒绝挑战'); fetchAll() }
    else message.error(data.error)
  } catch (e) { message.error('网络错误') }
  declining.value = false
}

async function joinWar() {
  if (!currentWar.value) return
  joining.value = true
  try {
    const res = await fetch(`${API}/sect-war/join`, {
      method: 'POST', headers: headers(), body: JSON.stringify({ war_id: currentWar.value.id })
    })
    const data = await res.json()
    if (data.ok) { message.success('报名成功！'); fetchAll() }
    else message.error(data.error)
  } catch (e) { message.error('网络错误') }
  joining.value = false
}

async function startBattle() {
  // 战斗时停止自动冥想
  playerStore.stopAutoCultivation()
  if (!currentWar.value) return
  starting.value = true
  try {
    const res = await fetch(`${API}/sect-war/start`, {
      method: 'POST', headers: headers(), body: JSON.stringify({ war_id: currentWar.value.id })
    })
    const data = await res.json()
    if (data.ok) { message.success('战斗完成！'); fetchAll() }
    else message.error(data.error)
  } catch (e) { message.error('网络错误') }
  starting.value = false
}

async function claimRewards() {
  claiming.value = true
  try {
    const res = await fetch(`${API}/sect-war/rewards/claim`, {
      method: 'POST', headers: headers()
    })
    const data = await res.json()
    if (data.ok) { 
      message.success(data.message)
      if (data.stones) playerStore.spiritStones += data.stones
      fetchAll() 
    }
    else message.error(data.error)
  } catch (e) { message.error('网络错误') }
  claiming.value = false
}

onMounted(() => { if (authStore.token) fetchAll() })
</script>

<style scoped>
.sect-war-page { padding: 12px; max-width: 800px; margin: 0 auto; }
.gold-title { font-size: 18px; font-weight: bold; color: #d4a017; text-shadow: 0 0 8px rgba(212,160,23,0.3); }
.war-stats-card, .current-war-card, .challenge-card, .pending-card, .reward-alert-card {
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border: 1px solid #d4a01733; border-radius: 12px; margin-bottom: 12px;
}
.stats-header, .war-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; text-align: center; }
.stat-item { padding: 8px; background: #0d1117; border-radius: 8px; border: 1px solid #333; }
.stat-value { font-size: 24px; font-weight: bold; }
.stat-value.win { color: #b8960b; }
.stat-value.lose { color: #f44336; }
.stat-value.points { color: #d4a017; }
.stat-value.rank { color: #d4a843; }
.stat-label { font-size: 12px; color: #888; margin-top: 4px; }
.no-data { text-align: center; color: #666; padding: 20px; }

.war-versus { display: flex; align-items: center; justify-content: center; gap: 16px; margin: 16px 0; }
.war-side { text-align: center; flex: 1; }
.sect-name { font-size: 16px; font-weight: bold; color: #eee; }
.sect-score { font-size: 36px; font-weight: bold; color: #d4a017; margin-top: 4px; }
.vs-badge { font-size: 20px; font-weight: bold; color: #f44336; background: #f4433622; padding: 8px 12px; border-radius: 50%; }

.participants-section { margin-top: 12px; }
.participants-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.team-col { background: #0d1117; border-radius: 8px; padding: 8px; }
.team-title { text-align: center; font-weight: bold; color: #d4a017; margin-bottom: 8px; font-size: 14px; }
.participant-item { display: flex; justify-content: space-between; padding: 4px 8px; border-bottom: 1px solid #222; }
.p-name { color: #ddd; font-size: 13px; }
.p-power { color: #ff9800; font-size: 13px; }
.no-participant { text-align: center; color: #555; font-size: 12px; padding: 8px; }
.war-actions { display: flex; gap: 8px; margin-top: 12px; justify-content: center; }

.battle-replay { margin-top: 16px; }
.replay-title { text-align: center; font-size: 16px; font-weight: bold; color: #d4a017; margin-bottom: 12px; }
.round-item { background: #0d1117; border-radius: 8px; padding: 10px; margin-bottom: 8px; border: 1px solid #222; }
.round-header { text-align: center; font-size: 13px; color: #888; margin-bottom: 8px; }
.round-battle { display: flex; align-items: center; gap: 8px; }
.fighter { flex: 1; display: flex; align-items: center; gap: 4px; font-size: 13px; }
.fighter.left { justify-content: flex-end; }
.fighter.right { justify-content: flex-start; }
.fighter.winner .fighter-name { color: #b8960b; font-weight: bold; }
.fighter-name { color: #ddd; }
.fighter-power { color: #ff9800; font-size: 12px; }
.fighter-result { font-size: 16px; }
.power-bar { width: 80px; min-width: 80px; height: 8px; background: #333; border-radius: 4px; display: flex; overflow: hidden; }
.power-fill.left { background: linear-gradient(90deg, #d4a843, #e6b800); }
.power-fill.right { background: linear-gradient(90deg, #f44336, #ef5350); }
.final-result { text-align: center; font-size: 28px; font-weight: bold; margin-top: 16px; padding: 12px; border-radius: 8px; }
.final-result.win { color: #b8960b; background: #b8960b11; border: 1px solid #b8960b33; }
.final-result.lose { color: #f44336; background: #f4433611; border: 1px solid #f4433633; }

.reward-alert { display: flex; justify-content: space-between; align-items: center; }
.reward-alert span { color: #d4a017; font-weight: bold; }

.pending-item { display: flex; justify-content: space-between; align-items: center; padding: 10px; background: #0d1117; border-radius: 8px; margin-bottom: 8px; }
.pending-name { font-weight: bold; color: #eee; }
.pending-members { color: #888; font-size: 12px; margin-left: 8px; }
.pending-actions { display: flex; gap: 6px; }

.history-item { display: flex; justify-content: space-between; align-items: center; padding: 10px; background: linear-gradient(135deg, #1a1a2e, #16213e); border: 1px solid #d4a01722; border-radius: 8px; margin-bottom: 8px; }
.history-names { color: #ddd; font-size: 14px; font-weight: bold; }
.history-time { color: #666; font-size: 12px; margin-top: 2px; }
.history-score { font-size: 18px; font-weight: bold; color: #d4a017; margin-right: 8px; }
.history-right { display: flex; align-items: center; }

.rank-item { display: flex; align-items: center; padding: 10px; background: linear-gradient(135deg, #1a1a2e, #16213e); border: 1px solid #333; border-radius: 8px; margin-bottom: 8px; }
.rank-item.rank-gold { border-color: #d4a017; background: linear-gradient(135deg, #1a1a2e, #2a2000); }
.rank-item.rank-silver { border-color: #aaa; background: linear-gradient(135deg, #1a1a2e, #1a1a2a); }
.rank-item.rank-bronze { border-color: #cd7f32; background: linear-gradient(135deg, #1a1a2e, #1a1510); }
.rank-pos { width: 40px; text-align: center; font-size: 20px; }
.rank-info { flex: 1; margin-left: 8px; }
.rank-name { font-weight: bold; color: #eee; }
.rank-detail { font-size: 12px; color: #888; }
.rank-points { font-size: 18px; font-weight: bold; color: #d4a017; }

.reward-item { display: flex; justify-content: space-between; align-items: center; padding: 10px; background: #0d1117; border-radius: 8px; margin-bottom: 8px; }
.reward-detail { font-size: 12px; color: #888; margin-top: 2px; }

.sect-list { max-height: 400px; overflow-y: auto; }
.sect-option { padding: 10px; background: #0d1117; border-radius: 8px; margin-bottom: 6px; cursor: pointer; border: 1px solid #333; transition: all 0.2s; }
.sect-option:hover { border-color: #d4a017; background: #1a1a2e; }
.sect-opt-name { font-weight: bold; color: #eee; }
.sect-opt-info { font-size: 12px; color: #888; }
</style>
