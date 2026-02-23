<template>
  <div class="pk-page">
    <game-guide>
      <p>⚔️ 和其他在线玩家<strong>实时对战</strong></p>
      <p>🤖 自动回合制战斗，<strong>属性决定胜负</strong></p>
      <p>🏆 胜利获得<strong>焰晶</strong>奖励，排行榜展示最强修士</p>
      <p>💡 提升装备、焰兽、焰丹buff来增强战力</p>
    </game-guide>
    <n-card>
      <n-space justify="end" style="margin-bottom: 8px">
        <n-tag :type="wsConnected ? 'success' : 'error'" size="small">
          {{ wsConnected ? '已连接' : '未连接' }}
        </n-tag>
      </n-space>

      <!-- 被挑战弹窗 -->
      <n-modal v-model:show="showChallengeModal" preset="dialog" title="⚔️ 收到挑战！" positive-text="应战" negative-text="拒绝"
        @positive-click="acceptChallenge" @negative-click="declineChallenge">
        <n-space vertical align="center">
          <span style="font-size:40px">🗡️</span>
          <n-text strong>{{ incomingChallenge?.fromName }}</n-text>
          <n-text depth="3">战力: {{ incomingChallenge?.fromCombatPower }}</n-text>
          <n-text type="warning">向你发起了焰武挑战！</n-text>
        </n-space>
      </n-modal>

      <!-- 战斗回放 -->
      <template v-if="battleResult">
        <div class="battle-replay">
          <div class="battle-header">
            <div class="fighter" :class="{ winner: battleResult.winner === 'A' }">
              <div class="fighter-avatar fa">{{ battleResult.nameA[0] }}</div>
              <n-text strong>{{ battleResult.nameA }}</n-text>
              <div class="fighter-hp-bar">
                <div class="fighter-hp-fill hp-a" :style="{ width: `${(battleResult.finalHpA / battleResult.maxHpA) * 100}%` }"></div>
              </div>
            </div>
            <div class="vs-center">
              <span class="vs-text">VS</span>
            </div>
            <div class="fighter" :class="{ winner: battleResult.winner === 'B' }">
              <div class="fighter-avatar fb">{{ battleResult.nameB[0] }}</div>
              <n-text strong>{{ battleResult.nameB }}</n-text>
              <div class="fighter-hp-bar">
                <div class="fighter-hp-fill hp-b" :style="{ width: `${(battleResult.finalHpB / battleResult.maxHpB) * 100}%` }"></div>
              </div>
            </div>
          </div>

          <!-- 回合记录 -->
          <div class="rounds-log">
            <div v-for="r in battleResult.rounds" :key="r.round" class="round-item">
              <n-tag size="tiny" :bordered="false">第{{ r.round }}回合</n-tag>
              <div v-for="(a, i) in r.actions" :key="i" class="action-item">
                <span class="action-attacker" :class="a.attacker === 'A' ? 'side-a' : 'side-b'">
                  {{ a.attacker === 'A' ? battleResult.nameA : battleResult.nameB }}
                </span>
                <template v-if="a.isDodged">
                  <span class="action-dodge">被闪避!</span>
                </template>
                <template v-else>
                  <span class="action-dmg">-{{ a.damage }}</span>
                  <span v-if="a.isCrit" class="action-crit">暴击!</span>
                  <span v-if="a.isCombo" class="action-combo">连击!</span>
                </template>
              </div>
            </div>
          </div>

          <!-- 结果 -->
          <div class="battle-result-banner" :class="'result-' + battleResult.winner">
            <template v-if="battleResult.winner === 'draw'">
              <span>⚖️ 平局</span>
            </template>
            <template v-else>
              <span>🏆 {{ battleResult.winnerName }} 获胜！</span>
              <n-text type="warning" style="font-size:12px">+{{ battleResult.reward }} 焰晶</n-text>
            </template>
          </div>

          <n-button block @click="battleResult = null" style="margin-top:12px">返回大厅</n-button>
        </div>
      </template>

      <!-- PK 大厅 -->
      <template v-else>
        <n-space vertical :size="16">
          <n-alert type="info" :show-icon="false">
            我的战力：<n-text strong type="warning">{{ myCombatPower }}</n-text>
            <n-text depth="3" style="margin-left:12px">胜者获得 {{ PK_REWARD }} 焰晶</n-text>
          </n-alert>

          <!-- 战绩统计 -->
          <div class="stats-bar" v-if="pkStats">
            <div class="stat-item">
              <span class="stat-num">{{ pkStats.total }}</span>
              <span class="stat-label">总场次</span>
            </div>
            <div class="stat-item win">
              <span class="stat-num">{{ pkStats.wins }}</span>
              <span class="stat-label">胜</span>
            </div>
            <div class="stat-item lose">
              <span class="stat-num">{{ pkStats.losses }}</span>
              <span class="stat-label">负</span>
            </div>
            <div class="stat-item reward">
              <span class="stat-num">{{ pkStats.totalReward }}</span>
              <span class="stat-label">焰晶收益</span>
            </div>
          </div>

          <n-tabs type="segment" v-model:value="activeTab">
            <n-tab-pane name="lobby" tab="🏟️ 大厅">
              <n-button type="primary" block @click="refreshPlayers" :loading="refreshing" style="margin-top:12px">
                🔄 刷新在线玩家
              </n-button>

              <div v-if="onlinePlayers.length === 0" style="text-align:center;padding:30px 0">
                <span style="font-size:32px">🏜️</span>
                <n-text depth="3" tag="div" style="margin-top:8px">暂无其他在线玩家</n-text>
              </div>

              <div v-for="p in onlinePlayers" :key="p.fullWallet" class="player-card" style="margin-top:10px">
                <div class="player-left">
                  <div class="player-av">{{ p.name[0] }}</div>
                  <div class="player-info">
                    <n-text strong>{{ p.name }}</n-text>
                    <n-text depth="3" style="font-size:11px">{{ p.realm }} · 战力 {{ p.combatPower }}</n-text>
                  </div>
                </div>
                <n-button type="error" size="small" @click="sendChallenge(p)" :disabled="challengeSent">
                  {{ challengeSent ? '已发送' : '⚔️ 挑战' }}
                </n-button>
              </div>
            </n-tab-pane>

            <n-tab-pane name="history" tab="📜 战绩">
              <div v-if="pkHistory.length === 0" style="text-align:center;padding:30px 0">
                <n-text depth="3">暂无战绩记录</n-text>
              </div>
              <div v-for="r in pkHistory" :key="r.id" class="history-item" :class="'h-' + r.isMe">
                <div class="h-left">
                  <span class="h-result" :class="'hr-' + r.isMe">{{ r.isMe === 'win' ? '胜' : r.isMe === 'draw' ? '平' : '负' }}</span>
                  <div class="h-info">
                    <n-text strong>vs {{ r.opponent }}</n-text>
                    <n-text depth="3" style="font-size:11px">{{ formatTime(r.created_at) }}</n-text>
                  </div>
                </div>
                <n-text v-if="r.isMe === 'win'" type="warning" style="font-size:12px">+{{ r.reward }} 焰晶</n-text>
              </div>
            </n-tab-pane>
          </n-tabs>
        </n-space>
      </template>
    </n-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useMessage } from 'naive-ui'
import sfx from '../plugins/sfx'
import GameGuide from '../components/GameGuide.vue'

const playerStore = usePlayerStore()
const message = useMessage()
const PK_REWARD = 500

const wsConnected = ref(false)
const onlinePlayers = ref([])
const refreshing = ref(false)
const challengeSent = ref(false)
const showChallengeModal = ref(false)
const incomingChallenge = ref(null)
const battleResult = ref(null)

let ws = null
let reconnectTimer = null

const myCombatPower = playerStore.getCombatPower()
const activeTab = ref('lobby')
const pkStats = ref(null)
const pkHistory = ref([])

const fetchPkData = async () => {
  const token = localStorage.getItem('xx_token') || localStorage.getItem('roon_auth_token')
  if (!token) return
  const headers = { 'Authorization': `Bearer ${token}` }
  try {
    const [statsRes, histRes] = await Promise.all([
      fetch('/api/pk/stats', { headers }),
      fetch('/api/pk/history', { headers })
    ])
    pkStats.value = await statsRes.json()
    const histData = await histRes.json()
    pkHistory.value = histData.records || []
  } catch {}
}

const formatTime = (t) => {
  const d = new Date(t)
  return `${d.getMonth() + 1}/${d.getDate()} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

const getMyStats = () => {
  const s = playerStore.getTotalStats()
  return {
    health: s.health,
    attack: s.attack,
    defense: s.defense,
    speed: s.speed,
    critRate: s.critRate,
    comboRate: s.comboRate,
    dodgeRate: s.dodgeRate,
    critDamageBoost: s.critDamageBoost,
    finalDamageReduce: s.finalDamageReduce,
  }
}

const connectWs = () => {
  const proto = location.protocol === 'https:' ? 'wss:' : 'ws:'
  ws = new WebSocket(`${proto}//${location.host}/ws`)

  ws.onopen = () => {
    wsConnected.value = true
    const token = localStorage.getItem('xx_token') || localStorage.getItem('roon_auth_token')
    if (token) {
      ws.send(JSON.stringify({ type: 'auth', token, name: playerStore.name }))
      // 发送战斗数据
      setTimeout(() => {
        ws.send(JSON.stringify({
          type: 'pk_update_stats',
          stats: getMyStats(),
          level: playerStore.level,
          realm: playerStore.realm,
          combatPower: myCombatPower
        }))
      }, 500)
    }
  }

  ws.onmessage = (e) => {
    try {
      const data = JSON.parse(e.data)

      if (data.type === 'pk_players') {
        onlinePlayers.value = data.players
        refreshing.value = false
      }

      if (data.type === 'pk_challenged') {
        incomingChallenge.value = data
        showChallengeModal.value = true
        sfx.click()
      }

      if (data.type === 'pk_challenge_sent') {
        challengeSent.value = true
        message.info('挑战已发送，等待对方回应...')
        setTimeout(() => { challengeSent.value = false }, 30000)
      }

      if (data.type === 'pk_result') {
        battleResult.value = data
        showChallengeModal.value = false
        challengeSent.value = false
        fetchPkData() // 刷新战绩
        // 判断自己是否赢了
        const myWallet = localStorage.getItem('xx_wallet') || ''
        if (data.winnerName && ((data.winner === 'A' && data.walletA === myWallet) || (data.winner === 'B' && data.walletB === myWallet))) {
          sfx.victory()
          playerStore.spiritStones += PK_REWARD
          playerStore.saveData()
        } else if (data.winner !== 'draw') {
          sfx.defeat()
        }
      }

      if (data.type === 'pk_declined') {
        challengeSent.value = false
        message.warning(`${data.by} 拒绝了你的挑战`)
      }

      if (data.type === 'pk_error') {
        message.error(data.msg)
        challengeSent.value = false
      }
    } catch {}
  }

  ws.onclose = () => {
    wsConnected.value = false
    reconnectTimer = setTimeout(connectWs, 3000)
  }

  ws.onerror = () => { ws.close() }
}

const refreshPlayers = () => {
  if (!ws || ws.readyState !== 1) return
  refreshing.value = true
  ws.send(JSON.stringify({ type: 'pk_get_players' }))
}

const sendChallenge = (player) => {
  // 战斗时停止自动冥想
  playerStore.stopAutoCultivation()
  if (!ws || ws.readyState !== 1) return
  ws.send(JSON.stringify({ type: 'pk_challenge', targetWallet: player.fullWallet }))
}

const acceptChallenge = () => {
  // 战斗时停止自动冥想
  playerStore.stopAutoCultivation()
  if (!ws || ws.readyState !== 1 || !incomingChallenge.value) return
  ws.send(JSON.stringify({
    type: 'pk_accept',
    challengeId: incomingChallenge.value.challengeId
  }))
  showChallengeModal.value = false
}

const declineChallenge = () => {
  if (!ws || ws.readyState !== 1 || !incomingChallenge.value) return
  ws.send(JSON.stringify({
    type: 'pk_decline',
    challengeId: incomingChallenge.value.challengeId
  }))
  showChallengeModal.value = false
  incomingChallenge.value = null
}

onMounted(() => {
  connectWs()
  setTimeout(refreshPlayers, 1000)
  fetchPkData()
})

onUnmounted(() => {
  if (reconnectTimer) clearTimeout(reconnectTimer)
  if (ws) { ws.onclose = null; ws.close() }
})
</script>

<style scoped>
.pk-page { max-width: 600px; margin: 0 auto; }

.player-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  border-radius: 10px;
  border: 1px solid rgba(212,168,67,0.15);
  background: rgba(18,18,26,0.7);
  transition: all 0.3s;
}
.player-card:hover {
  border-color: rgba(212,168,67,0.4);
  box-shadow: 0 0 15px rgba(212,168,67,0.08);
}
.player-left { display: flex; align-items: center; gap: 12px; }
.player-av {
  width: 40px; height: 40px; border-radius: 10px;
  background: linear-gradient(135deg, #ff5722, #e91e63);
  display: flex; align-items: center; justify-content: center;
  font-weight: bold; color: #fff; font-size: 16px;
}
.player-info { display: flex; flex-direction: column; gap: 2px; }

/* 战斗回放 */
.battle-replay { padding: 8px 0; }
.battle-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px; margin-bottom: 16px;
  background: rgba(10,10,15,0.6); border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.15);
}
.fighter { display: flex; flex-direction: column; align-items: center; gap: 6px; flex: 1; }
.fighter.winner { filter: drop-shadow(0 0 8px rgba(212,168,67,0.5)); }
.fighter-avatar {
  width: 50px; height: 50px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  font-weight: bold; color: #fff; font-size: 20px;
}
.fa { background: linear-gradient(135deg, #4caf50, #2196f3); }
.fb { background: linear-gradient(135deg, #ff5722, #e91e63); }
.fighter.winner .fighter-avatar {
  box-shadow: 0 0 15px rgba(212,168,67,0.5);
  border: 2px solid #d4a843;
}
.fighter-hp-bar {
  width: 80px; height: 6px; border-radius: 3px;
  background: rgba(255,255,255,0.1); overflow: hidden;
}
.fighter-hp-fill { height: 100%; border-radius: 3px; transition: width 0.5s; }
.hp-a { background: linear-gradient(90deg, #2196f3, #4caf50); }
.hp-b { background: linear-gradient(90deg, #ff4444, #ff8800); }

.vs-center { padding: 0 16px; }
.vs-text {
  font-size: 20px; font-weight: 900; color: #d4a843;
  text-shadow: 0 0 10px rgba(212,168,67,0.4);
}

.rounds-log {
  max-height: 300px; overflow-y: auto;
  padding: 8px; border-radius: 8px;
  background: rgba(10,10,15,0.4);
  border: 1px solid rgba(212,168,67,0.1);
}
.round-item { margin-bottom: 8px; }
.action-item {
  display: flex; align-items: center; gap: 6px;
  padding: 2px 8px; font-size: 12px;
}
.action-attacker { font-weight: bold; }
.side-a { color: #4caf50; }
.side-b { color: #ff5722; }
.action-dmg { color: #ff4444; font-weight: bold; }
.action-dodge { color: #88ccff; font-style: italic; }
.action-crit { color: #ff4444; font-size: 11px; font-weight: bold; }
.action-combo { color: #ffaa00; font-size: 11px; }

.battle-result-banner {
  text-align: center; padding: 16px; margin-top: 12px;
  border-radius: 10px; font-size: 18px; font-weight: bold;
  display: flex; flex-direction: column; align-items: center; gap: 4px;
}
.result-A, .result-B {
  background: linear-gradient(135deg, rgba(212,168,67,0.15), rgba(212,168,67,0.05));
  border: 1px solid rgba(212,168,67,0.3);
  color: #f0d68a;
}
.result-draw {
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(255,255,255,0.1);
  color: #a09880;
}

/* 战绩统计 */
.stats-bar {
  display: flex; justify-content: space-around;
  padding: 12px; border-radius: 10px;
  background: rgba(10,10,15,0.6);
  border: 1px solid rgba(212,168,67,0.15);
}
.stat-item { display: flex; flex-direction: column; align-items: center; gap: 2px; }
.stat-num { font-size: 18px; font-weight: bold; color: #e8e0d0; }
.stat-label { font-size: 11px; color: #a09880; }
.stat-item.win .stat-num { color: #4caf50; }
.stat-item.lose .stat-num { color: #ff5722; }
.stat-item.reward .stat-num { color: #d4a843; }

/* 历史记录 */
.history-item {
  display: flex; align-items: center; justify-content: space-between;
  padding: 10px 12px; margin-top: 8px; border-radius: 8px;
  border: 1px solid rgba(212,168,67,0.1);
  background: rgba(18,18,26,0.5);
}
.h-left { display: flex; align-items: center; gap: 10px; }
.h-info { display: flex; flex-direction: column; gap: 2px; }
.h-result {
  width: 28px; height: 28px; border-radius: 6px;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: bold; color: #fff;
}
.hr-win { background: #4caf50; }
.hr-lose { background: #ff5722; }
.hr-draw { background: #666; }
.h-win { border-left: 3px solid #4caf50; }
.h-lose { border-left: 3px solid #ff5722; }
.h-draw { border-left: 3px solid #666; }
</style>
