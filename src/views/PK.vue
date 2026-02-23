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
            <!-- 战斗回放 -->
      <template v-if="battleResult">
        <div class="battle-replay">
          <!-- 战斗预告 -->
          <div v-if="showCountdown" class="battle-intro">
            <div class="intro-fighters">
              <div class="intro-fighter">
                <div class="intro-avatar fa">{{ battleResult.nameA[0] }}</div>
                <n-text strong>{{ battleResult.nameA }}</n-text>
              </div>
              <div class="intro-vs">VS</div>
              <div class="intro-fighter">
                <div class="intro-avatar fb">{{ battleResult.nameB[0] }}</div>
                <n-text strong>{{ battleResult.nameB }}</n-text>
              </div>
            </div>
            <div class="countdown" :class="'count-' + countdownNum">{{ countdownText }}</div>
          </div>

          <!-- 战斗主体 -->
          <div v-else>
            <!-- 血条区域 -->
            <div class="battle-header">
              <div class="fighter" :class="{ winner: battleResult.winner === 'A' && battleEnded }">
                <div class="fighter-avatar fa">{{ battleResult.nameA[0] }}</div>
                <n-text strong>{{ battleResult.nameA }}</n-text>
                <div class="hp-wrapper">
                  <div class="fighter-hp-bar">
                    <div class="fighter-hp-fill" :class="hpColorClass(currentHpA, battleResult.maxHpA)"
                      :style="{ width: hpPercent(currentHpA, battleResult.maxHpA) }"></div>
                  </div>
                  <span class="hp-text">{{ currentHpA }}/{{ battleResult.maxHpA }}</span>
                </div>
              </div>
              <div class="vs-center">
                <span class="vs-text">VS</span>
                <span class="round-indicator" v-if="!battleEnded">第{{ currentRoundIndex + 1 }}回合</span>
              </div>
              <div class="fighter" :class="{ winner: battleResult.winner === 'B' && battleEnded }">
                <div class="fighter-avatar fb">{{ battleResult.nameB[0] }}</div>
                <n-text strong>{{ battleResult.nameB }}</n-text>
                <div class="hp-wrapper">
                  <div class="fighter-hp-bar">
                    <div class="fighter-hp-fill" :class="hpColorClass(currentHpB, battleResult.maxHpB)"
                      :style="{ width: hpPercent(currentHpB, battleResult.maxHpB) }"></div>
                  </div>
                  <span class="hp-text">{{ currentHpB }}/{{ battleResult.maxHpB }}</span>
                </div>
              </div>
            </div>

            <!-- 当前回合显示 -->
            <div class="current-round" v-if="!battleEnded && currentAction">
              <div class="action-display" :class="{ 'action-flash': actionFlash }">
                <span class="action-attacker" :class="currentAction.attacker === 'A' ? 'side-a' : 'side-b'">
                  {{ currentAction.attacker === 'A' ? battleResult.nameA : battleResult.nameB }}
                </span>
                
                <template v-if="currentAction.isDodged">
                  <span class="effect-text effect-dodge">💨 闪避!</span>
                </template>
                <template v-else>
                  <span class="damage-number" :class="{ 'crit-dmg': currentAction.isCrit }">-{{ currentAction.damage }}</span>
                  <span v-if="currentAction.isCrit" class="effect-text effect-crit">💥 暴击!</span>
                  <span v-if="currentAction.isCombo" class="effect-text effect-combo">⚡ 连击!</span>
                  <span v-if="currentAction.isCounter" class="effect-text effect-counter">🔄 反击!</span>
                  <span v-if="currentAction.isStun" class="effect-text effect-stun">💫 眩晕!</span>
                  <span v-if="currentAction.isVampire" class="effect-text effect-vampire">🩸 吸血 +{{ currentAction.vampireHeal }}!</span>
                </template>
              </div>
            </div>

            <!-- 击杀特写 -->
            <div v-if="showKillShot" class="kill-shot">
              <div class="kill-text">致命一击！</div>
            </div>

            <!-- 结果横幅 -->
            <div v-if="battleEnded" class="battle-result-banner" :class="'result-' + battleResult.winner">
              <template v-if="battleResult.winner === 'draw'">
                <span>⚖️ 平局</span>
              </template>
              <template v-else>
                <span>🏆 {{ battleResult.winnerName }} 获胜！</span>
                <n-text type="warning" style="font-size:12px">+{{ battleResult.reward }} 焰晶</n-text>
              </template>
            </div>

            <!-- 控制按钮 -->
            <div class="battle-controls">
              <n-button v-if="!battleEnded" block type="warning" @click="skipAnimation">⏭️ 跳过动画</n-button>
              <n-button v-else block @click="battleResult = null">返回大厅</n-button>
            </div>
          </div>
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
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
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

// ============ 战斗回放动画控制 ============
const showCountdown = ref(false)
const countdownNum = ref(3)
const countdownText = ref('3')
const currentRoundIndex = ref(0)
const currentActionIndex = ref(0)
const currentHpA = ref(0)
const currentHpB = ref(0)
const battleEnded = ref(false)
const showKillShot = ref(false)
const actionFlash = ref(false)
const animationTimer = ref(null)

const currentRound = computed(() => {
  if (!battleResult.value || !battleResult.value.rounds) return null
  return battleResult.value.rounds[currentRoundIndex.value]
})

const currentAction = computed(() => {
  if (!currentRound.value) return null
  return currentRound.value.actions[currentActionIndex.value]
})

const hpPercent = (hp, max) => `${Math.max(0, (hp / max) * 100).toFixed(1)}%`

const hpColorClass = (hp, max) => {
  const pct = hp / max
  if (pct > 0.5) return 'hp-green'
  if (pct > 0.2) return 'hp-yellow'
  return 'hp-red'
}

const clearAnimationTimer = () => {
  if (animationTimer.value) {
    clearTimeout(animationTimer.value)
    animationTimer.value = null
  }
}

const startCountdown = () => {
  showCountdown.value = true
  countdownNum.value = 3
  countdownText.value = '3'
  
  const step = () => {
    countdownNum.value--
    if (countdownNum.value > 0) {
      countdownText.value = String(countdownNum.value)
      animationTimer.value = setTimeout(step, 1000)
    } else {
      countdownText.value = '开战！'
      animationTimer.value = setTimeout(() => {
        showCountdown.value = false
        startBattlePlayback()
      }, 800)
    }
  }
  animationTimer.value = setTimeout(step, 1000)
}

const startBattlePlayback = () => {
  // 初始化血量
  currentHpA.value = battleResult.value.maxHpA
  currentHpB.value = battleResult.value.maxHpB
  currentRoundIndex.value = 0
  currentActionIndex.value = 0
  battleEnded.value = false
  showKillShot.value = false
  
  playNextAction()
}

const playNextAction = () => {
  if (!battleResult.value) return
  
  const rounds = battleResult.value.rounds
  if (currentRoundIndex.value >= rounds.length) {
    // 所有回合播放完毕，结束战斗
    endBattle()
    return
  }
  
  const round = rounds[currentRoundIndex.value]
  if (currentActionIndex.value >= round.actions.length) {
    // 当前回合动作播放完毕，进入下一回合
    currentRoundIndex.value++
    currentActionIndex.value = 0
    animationTimer.value = setTimeout(playNextAction, 500)
    return
  }
  
  const action = round.actions[currentActionIndex.value]
  
  // 触发动作闪烁效果
  actionFlash.value = true
  setTimeout(() => { actionFlash.value = false }, 300)
  
  // 计算伤害后的血量
  if (!action.isDodged) {
    if (action.attacker === 'A') {
      currentHpB.value = Math.max(0, currentHpB.value - action.damage)
    } else {
      currentHpA.value = Math.max(0, currentHpA.value - action.damage)
    }
  }
  
  // 检查是否是最后一个动作
  const isLastRound = currentRoundIndex.value === rounds.length - 1
  const isLastAction = currentActionIndex.value === round.actions.length - 1
  
  if (isLastRound && isLastAction) {
    // 最后一击，显示击杀特写
    animationTimer.value = setTimeout(() => {
      showKillShot.value = true
      animationTimer.value = setTimeout(() => {
        showKillShot.value = false
        endBattle()
      }, 1500)
    }, 800)
  } else {
    // 继续下一个动作
    currentActionIndex.value++
    animationTimer.value = setTimeout(playNextAction, 1500)
  }
}

const endBattle = () => {
  battleEnded.value = true
  // 设置最终血量
  currentHpA.value = battleResult.value.finalHpA
  currentHpB.value = battleResult.value.finalHpB
}

const skipAnimation = () => {
  clearAnimationTimer()
  showCountdown.value = false
  showKillShot.value = false
  currentRoundIndex.value = (battleResult.value.rounds?.length || 1) - 1
  currentActionIndex.value = 0
  currentHpA.value = battleResult.value.finalHpA
  currentHpB.value = battleResult.value.finalHpB
  battleEnded.value = true
}

// 监听battleResult变化，自动开始动画
watch(() => battleResult.value, (newVal) => {
  clearAnimationTimer()
  if (newVal) {
    startCountdown()
  }
}, { immediate: false })

// 清理定时器
onUnmounted(() => {
  clearAnimationTimer()
})
// ============ 战斗回放动画控制结束 ============


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

/* 战斗预告 */
.battle-intro {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  animation: fadeIn 0.3s ease;
}
.intro-fighters {
  display: flex;
  align-items: center;
  gap: 30px;
  margin-bottom: 30px;
}
.intro-fighter {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}
.intro-avatar {
  width: 60px;
  height: 60px;
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: #fff;
  font-size: 24px;
}
.intro-vs {
  font-size: 28px;
  font-weight: 900;
  color: #d4a843;
  text-shadow: 0 0 20px rgba(212,168,67,0.6);
  animation: pulse 1s infinite;
}
.countdown {
  font-size: 48px;
  font-weight: 900;
  color: #ff5722;
  text-shadow: 0 0 30px rgba(255,87,34,0.8);
  animation: countdownPop 0.8s ease;
}
.countdown.count-0 {
  color: #4caf50;
}
@keyframes countdownPop {
  0% { transform: scale(0.5); opacity: 0; }
  50% { transform: scale(1.3); }
  100% { transform: scale(1); opacity: 1; }
}
@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* 血条动画 */
.hp-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.fighter-hp-bar {
  width: 100px;
  height: 10px;
  border-radius: 5px;
  background: rgba(255,255,255,0.1);
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.1);
}
.fighter-hp-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.5s ease, background-color 0.3s ease;
}
.fighter-hp-fill.hp-green {
  background: linear-gradient(90deg, #4caf50, #8bc34a);
  box-shadow: 0 0 8px rgba(76,175,80,0.4);
}
.fighter-hp-fill.hp-yellow {
  background: linear-gradient(90deg, #ff9800, #ffc107);
  box-shadow: 0 0 8px rgba(255,152,0,0.4);
}
.fighter-hp-fill.hp-red {
  background: linear-gradient(90deg, #f44336, #ff5722);
  box-shadow: 0 0 8px rgba(244,67,54,0.5);
}
.hp-text {
  font-size: 11px;
  color: #a09880;
}
.round-indicator {
  font-size: 12px;
  color: #d4a843;
  margin-top: 4px;
}

/* 当前回合显示 */
.current-round {
  min-height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  margin: 16px 0;
  background: rgba(10,10,15,0.6);
  border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.15);
}
.action-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
}
.action-display.action-flash {
  animation: flashAction 0.3s ease;
}
@keyframes flashAction {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}
.damage-number {
  font-size: 28px;
  font-weight: 900;
  color: #fff;
  text-shadow: 0 0 15px rgba(255,255,255,0.5);
  animation: damageFloat 0.8s ease;
}
.damage-number.crit-dmg {
  color: #ff4444;
  font-size: 36px;
  text-shadow: 0 0 20px rgba(255,68,68,0.8);
}
@keyframes damageFloat {
  0% { transform: translateY(10px); opacity: 0; }
  20% { transform: translateY(-5px); opacity: 1; }
  100% { transform: translateY(0); opacity: 1; }
}

/* 特效文字 */
.effect-text {
  font-size: 14px;
  font-weight: bold;
  padding: 4px 10px;
  border-radius: 6px;
  animation: effectPop 0.5s ease;
}
@keyframes effectPop {
  0% { transform: scale(0); opacity: 0; }
  50% { transform: scale(1.3); }
  100% { transform: scale(1); opacity: 1; }
}
.effect-crit {
  color: #fff;
  background: linear-gradient(135deg, #ff4444, #cc0000);
  font-size: 18px;
  box-shadow: 0 0 15px rgba(255,68,68,0.5);
}
.effect-combo {
  color: #fff;
  background: linear-gradient(135deg, #ff9800, #f57c00);
  box-shadow: 0 0 10px rgba(255,152,0,0.4);
}
.effect-dodge {
  color: #fff;
  background: linear-gradient(135deg, #2196f3, #1976d2);
  animation: dodgeFade 1s ease;
}
@keyframes dodgeFade {
  0% { transform: translateX(0); opacity: 0; }
  30% { transform: translateX(-10px); opacity: 1; }
  70% { transform: translateX(10px); opacity: 1; }
  100% { transform: translateX(0); opacity: 0.7; }
}
.effect-counter {
  color: #fff;
  background: linear-gradient(135deg, #9c27b0, #7b1fa2);
  box-shadow: 0 0 10px rgba(156,39,176,0.4);
}
.effect-stun {
  color: #333;
  background: linear-gradient(135deg, #ffeb3b, #fbc02d);
  box-shadow: 0 0 10px rgba(255,235,59,0.4);
}
.effect-vampire {
  color: #fff;
  background: linear-gradient(135deg, #4caf50, #388e3c);
  box-shadow: 0 0 10px rgba(76,175,80,0.4);
}

/* 击杀特写 */
.kill-shot {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 100;
  pointer-events: none;
}
.kill-text {
  font-size: 48px;
  font-weight: 900;
  color: #ff2222;
  text-shadow: 
    0 0 20px rgba(255,34,34,0.8),
    0 0 40px rgba(255,34,34,0.5),
    4px 4px 0 #000;
  animation: killShot 1s ease;
  white-space: nowrap;
}
@keyframes killShot {
  0% { transform: scale(0) rotate(-10deg); opacity: 0; }
  30% { transform: scale(1.5) rotate(5deg); opacity: 1; }
  60% { transform: scale(1.2) rotate(-3deg); }
  100% { transform: scale(1) rotate(0); }
}

/* 战斗控制按钮 */
.battle-controls {
  margin-top: 16px;
}

</style>
