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
          <div v-if="incomingChallenge?.betAmount > 0" style="color:#d4a843;margin-top:8px;font-size:14px">
            💰 赌注: {{ incomingChallenge.betAmount }} 焰晶（赢家获得 {{ Math.floor(incomingChallenge.betAmount * 2 * 0.9) }}）
          </div>
        </n-space>
      </n-modal>

      <!-- 赌注选择弹窗 -->
      <n-modal v-model:show="showBetModal" preset="card" title="⚔️ 选择赌注" style="max-width:320px">
        <div style="display:flex;flex-direction:column;gap:8px">
          <n-button v-for="b in [0, 100, 500, 1000, 5000]" :key="b"
            :type="selectedBet === b ? 'warning' : 'default'"
            @click="selectedBet = b">
            {{ b === 0 ? '🤝 友谊赛（无赌注）' : '💰 ' + b + ' 焰晶' }}
          </n-button>
        </div>
        <n-button type="primary" block style="margin-top:12px" @click="confirmChallenge">⚔️ 发起挑战</n-button>
      </n-modal>

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

            <!-- 当前回合显示（双方同时） -->
            <div class="current-round" v-if="!battleEnded && currentRound">
              <div v-for="(a, i) in currentRound.actions" :key="i" class="action-display" :class="{ 'action-flash': actionFlash }">
                <span class="action-attacker" :class="a.attacker === 'A' ? 'side-a' : 'side-b'">
                  {{ a.attacker === 'A' ? battleResult.nameA : battleResult.nameB }}
                </span>
                <span class="action-arrow">→</span>
                <span class="action-target" :class="a.attacker === 'A' ? 'side-b' : 'side-a'">
                  {{ a.attacker === 'A' ? battleResult.nameB : battleResult.nameA }}
                </span>
                
                <template v-if="a.isDodged">
                  <span class="effect-text effect-dodge">💨 闪避!</span>
                </template>
                <template v-else>
                  <span class="damage-number" :class="{ 'crit-dmg': a.isCrit }">-{{ a.damage }}</span>
                  <span v-if="a.isCrit" class="effect-text effect-crit">💥 暴击!</span>
                  <span v-if="a.isCombo" class="effect-text effect-combo">⚡ 连击!</span>
                  <span v-if="a.isCounter" class="effect-text effect-counter">🔄 反击!</span>
                  <span v-if="a.isStun" class="effect-text effect-stun">💫 眩晕!</span>
                  <span v-if="a.isVampire" class="effect-text effect-vampire">🩸 吸血 +{{ a.vampireHeal }}!</span>
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
                <div v-if="battleResult.betAmount > 0" style="margin-top:4px;font-size:13px">💰 {{ myBetResult }}</div>
                <div v-if="myScoreChange !== 0" style="margin-top:4px;font-size:13px">
                  <span :style="{color: myScoreChange > 0 ? '#d4a843' : '#8b2000'}">{{ myScoreChange > 0 ? '📈 +' : '📉 ' }}{{ myScoreChange }} 排位分</span>
                </div>
              </template>
              <template v-if="battleResult.winner === 'draw' && battleResult.betAmount > 0">
                <div style="font-size:13px;margin-top:4px">💰 赌注已退还</div>
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

          <n-tabs type="segment" v-model:value="activeTab">
            <n-tab-pane name="lobby" tab="⚔️ 大厅">
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
                    <n-text depth="3" style="font-size:11px">{{ p.realm }} Lv.{{ p.level }} · 战力 {{ p.combatPower }}</n-text>
                  </div>
                </div>
                <n-button type="error" size="small" @click="sendChallenge(p)" :disabled="challengeSent">
                  {{ challengeSent ? '已发送' : '⚔️ 挑战' }}
                </n-button>
              </div>
            </n-tab-pane>

            <n-tab-pane name="rankings" tab="🏆 排行榜">
              <div v-if="myRanking" style="text-align:center;padding:16px;background:rgba(255,255,255,0.03);border-radius:12px;margin-bottom:16px">
                <div style="font-size:36px">{{ tierIcon(myRanking.rank_tier) }}</div>
                <div style="font-size:18px;font-weight:bold;margin:4px 0">{{ tierName(myRanking.rank_tier) }}</div>
                <div style="color:#d4a843">{{ myRanking.rank_score }} 分 · 排名 #{{ myRanking.rank_pos || '-' }}</div>
                <div style="font-size:12px;color:#888;margin-top:4px">{{ myRanking.wins }}胜 {{ myRanking.losses }}负 {{ myRanking.draws }}平</div>
              </div>
              <div v-for="(r, i) in rankings" :key="r.wallet" style="display:flex;align-items:center;padding:10px;border-bottom:1px solid rgba(255,255,255,0.05);gap:10px">
                <span style="width:24px;text-align:center;font-weight:bold" :style="{color: i<3 ? '#d4a843' : '#888'}">{{ i+1 }}</span>
                <span style="font-size:20px">{{ tierIcon(r.rank_tier) }}</span>
                <div style="flex:1">
                  <div style="font-weight:bold">{{ r.name || '无名焰修' }} <span style="font-size:11px;color:#888">Lv.{{ r.level }}</span></div>
                  <div style="font-size:11px;color:#888">{{ r.wins }}胜 {{ r.losses }}负 · 连胜{{ r.win_streak }}</div>
                </div>
                <span style="color:#d4a843;font-weight:bold">{{ r.rank_score }}</span>
              </div>
              <div v-if="!rankings.length" style="text-align:center;color:#666;padding:40px">暂无排位数据</div>
            </n-tab-pane>

            <n-tab-pane name="stats" tab="📊 战绩">
              <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-bottom:16px;margin-top:12px">
                <div style="text-align:center;padding:12px;background:rgba(255,255,255,0.03);border-radius:8px">
                  <div style="font-size:20px;font-weight:bold;color:#d4a843">{{ myPkStats.wins || 0 }}</div>
                  <div style="font-size:11px;color:#888">胜场</div>
                </div>
                <div style="text-align:center;padding:12px;background:rgba(255,255,255,0.03);border-radius:8px">
                  <div style="font-size:20px;font-weight:bold;color:#8b2000">{{ myPkStats.losses || 0 }}</div>
                  <div style="font-size:11px;color:#888">败场</div>
                </div>
                <div style="text-align:center;padding:12px;background:rgba(255,255,255,0.03);border-radius:8px">
                  <div style="font-size:20px;font-weight:bold;color:#d4a843">{{ pkWinRate }}%</div>
                  <div style="font-size:11px;color:#888">胜率</div>
                </div>
                <div style="text-align:center;padding:12px;background:rgba(255,255,255,0.03);border-radius:8px">
                  <div style="font-size:20px;font-weight:bold;color:#ff9800">{{ myPkStats.max_win_streak || 0 }}</div>
                  <div style="font-size:11px;color:#888">最高连胜</div>
                </div>
              </div>
              <div style="font-weight:bold;margin-bottom:8px">最近对战</div>
              <div v-for="m in recentMatches" :key="m.created_at" style="display:flex;align-items:center;padding:8px;border-bottom:1px solid rgba(255,255,255,0.05);gap:8px">
                <span style="width:28px;text-align:center;font-weight:bold" :style="{color: isMatchWin(m) ? '#d4a843' : '#8b2000'}">{{ isMatchWin(m) ? '胜' : '负' }}</span>
                <div style="flex:1">
                  <span>vs {{ getOpponent(m) }}</span>
                  <span v-if="m.bet_amount > 0" style="color:#d4a843;font-size:11px;margin-left:6px">💰{{ m.bet_amount }}</span>
                </div>
                <span style="font-size:11px;color:#888">{{ formatMatchTime(m.created_at) }}</span>
              </div>
              <div v-if="!recentMatches.length" style="text-align:center;color:#666;padding:40px">暂无对战记录</div>
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
    endBattle()
    return
  }
  
  const round = rounds[currentRoundIndex.value]
  
  // 触发动作闪烁效果
  actionFlash.value = true
  setTimeout(() => { actionFlash.value = false }, 300)
  
  // 暴击屏幕震动
  const hasCrit = round.actions.some(a => a.isCrit)
  if (hasCrit) {
    const el = document.querySelector('.battle-arena') || document.querySelector('.pk-page')
    if (el) { el.classList.add('screen-shake'); setTimeout(() => el.classList.remove('screen-shake'), 400) }
  }
  
  // 一次性应用本回合所有 actions 的伤害
  for (const action of round.actions) {
    if (!action.isDodged) {
      if (action.attacker === 'A') {
        currentHpB.value = Math.max(0, currentHpB.value - action.damage)
      } else {
        currentHpA.value = Math.max(0, currentHpA.value - action.damage)
      }
    }
    // 吸血回血
    if (action.isVampire && action.vampireHeal) {
      if (action.attacker === 'A') {
        currentHpA.value = Math.min(battleResult.value.maxHpA, currentHpA.value + action.vampireHeal)
      } else {
        currentHpB.value = Math.min(battleResult.value.maxHpB, currentHpB.value + action.vampireHeal)
      }
    }
  }
  
  // 用后端记录的回合血量校正（更准确）
  if (round.hpA !== undefined) currentHpA.value = round.hpA
  if (round.hpB !== undefined) currentHpB.value = round.hpB
  
  const isLastRound = currentRoundIndex.value === rounds.length - 1
  
  if (isLastRound) {
    animationTimer.value = setTimeout(() => {
      showKillShot.value = true
      animationTimer.value = setTimeout(() => {
        showKillShot.value = false
        endBattle()
      }, 1500)
    }, 800)
  } else {
    currentRoundIndex.value++
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
const showBetModal = ref(false)
const selectedBet = ref(0)
const challengeTarget = ref(null)
const rankings = ref([])
const myRanking = ref(null)
const myPkStats = ref({})
const recentMatches = ref([])

const tierIcon = (t) => ({ bronze: '\u{1F949}', silver: '\u{1F948}', gold: '\u{1F947}', diamond: '\u{1F48E}', emperor: '\u{1F451}' }[t] || '\u{1F949}')
const tierName = (t) => ({ bronze: '青铜', silver: '白银', gold: '黄金', diamond: '钻石', emperor: '焰皇' }[t] || '青铜')

const pkWinRate = computed(() => {
  const total = (myPkStats.value.wins || 0) + (myPkStats.value.losses || 0)
  return total > 0 ? Math.round(myPkStats.value.wins / total * 100) : 0
})

const myScoreChange = computed(() => {
  if (!battleResult.value || battleResult.value.scoreChangeA === undefined) return 0
  const myWallet = localStorage.getItem('xx_wallet') || ''
  return battleResult.value.walletA === myWallet ? (battleResult.value.scoreChangeA || 0) : (battleResult.value.scoreChangeB || 0)
})

const myBetResult = computed(() => {
  if (!battleResult.value || !battleResult.value.betAmount) return ''
  const myWallet = localStorage.getItem('xx_wallet') || ''
  const isWinner = (battleResult.value.winner === 'A' && battleResult.value.walletA === myWallet) || (battleResult.value.winner === 'B' && battleResult.value.walletB === myWallet)
  if (battleResult.value.winner === 'draw') return '平局，赌注已退还'
  return isWinner ? '赢得 ' + battleResult.value.betWin + ' 焰晶' : '输掉 ' + battleResult.value.betAmount + ' 焰晶'
})

const isMatchWin = (m) => m.winner_wallet === (localStorage.getItem('xx_wallet') || '')
const getOpponent = (m) => m.wallet_a === (localStorage.getItem('xx_wallet') || '') ? m.name_b : m.name_a
const formatMatchTime = (t) => {
  const d = new Date(t)
  return (d.getMonth()+1) + '/' + d.getDate() + ' ' + d.getHours() + ':' + String(d.getMinutes()).padStart(2,'0')
}

async function loadRankings() {
  const token = localStorage.getItem('xx_token')
  if (!token) return
  try {
    const res = await fetch('/api/pk/rankings', { headers: { 'Authorization': 'Bearer ' + token } })
    if (res.ok) { const d = await res.json(); rankings.value = d.rankings || []; myRanking.value = d.myRanking || null }
  } catch {}
}

async function loadMyStats() {
  const token = localStorage.getItem('xx_token')
  if (!token) return
  try {
    const res = await fetch('/api/pk/my-stats', { headers: { 'Authorization': 'Bearer ' + token } })
    if (res.ok) { const d = await res.json(); myPkStats.value = d.ranking || {}; recentMatches.value = d.recentMatches || [] }
  } catch {}
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
        // 判断自己是否赢了
        const myWallet = localStorage.getItem('xx_wallet') || ''
        const iAmWinner = data.winnerName && ((data.winner === 'A' && data.walletA === myWallet) || (data.winner === 'B' && data.walletB === myWallet))
        if (iAmWinner) {
          sfx.victory()
          playerStore.spiritStones += PK_REWARD
          // 赌注赢了
          if (data.betAmount > 0 && data.betWin) {
            playerStore.spiritStones += data.betWin
          }
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
  challengeTarget.value = player
  selectedBet.value = 0
  showBetModal.value = true
}

const confirmChallenge = () => {
  playerStore.stopAutoCultivation()
  if (!ws || ws.readyState !== 1 || !challengeTarget.value) return
  ws.send(JSON.stringify({ type: 'pk_challenge', targetWallet: challengeTarget.value.fullWallet, betAmount: selectedBet.value }))
  showBetModal.value = false
  challengeTarget.value = null
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

watch(activeTab, (val) => {
  if (val === 'rankings') loadRankings()
  if (val === 'stats') loadMyStats()
})

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

/* 对战卡片 */
.player-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  margin-top: 10px;
  border-radius: 10px;
  border: 1px solid rgba(212,168,67,0.12);
  background: rgba(15,15,30,0.9);
  transition: all 0.3s;
}
.player-card:hover {
  border-color: rgba(212,168,67,0.35);
  box-shadow: 0 0 15px rgba(212,168,67,0.08);
}
.player-left { display: flex; align-items: center; gap: 12px; }
.player-av {
  width: 40px; height: 40px; border-radius: 10px;
  background: linear-gradient(135deg, #ff6b35, #8b2000);
  display: flex; align-items: center; justify-content: center;
  font-weight: bold; color: #fff; font-size: 16px;
}
.player-info { display: flex; flex-direction: column; gap: 2px; }

/* 赌注弹窗 */
.bet-modal-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 8px;
  background: rgba(15,15,30,0.9);
  border-radius: 8px;
  border: 1px solid rgba(212,168,67,0.12);
}

/* Tab 金色下划线 */
.pk-tabs :deep(.n-tabs-nav) {
  border-bottom: 1px solid rgba(212,168,67,0.15);
}
.pk-tabs :deep(.n-tabs-tab.n-tabs-tab--active) {
  color: #d4a843 !important;
}
.pk-tabs :deep(.n-tabs-bar) {
  background: #d4a843 !important;
}

/* 挑战按钮火焰渐变 */
.pk-challenge-btn {
  margin-top: 12px;
  background: linear-gradient(135deg, #8b2000 0%, #ff6b35 100%) !important;
  border: none !important;
}

/* 空状态 */
.empty-state {
  text-align: center;
  padding: 40px 0;
  color: #666;
}
.empty-icon {
  font-size: 32px;
  display: block;
  margin-bottom: 8px;
}

/* 战斗回放 */
.battle-replay { padding: 8px 0; }
.battle-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px; margin-bottom: 16px;
  background: rgba(15,15,30,0.9);
  border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.12);
}
.fighter { display: flex; flex-direction: column; align-items: center; gap: 6px; flex: 1; }
.fighter.winner { filter: drop-shadow(0 0 10px rgba(212,168,67,0.4)); }
.fighter-avatar {
  width: 50px; height: 50px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  font-weight: bold; color: #fff; font-size: 20px;
}
.fa { background: linear-gradient(135deg, #a0522d, #8b2000); }
.fb { background: linear-gradient(135deg, #ff6b35, #8b2000); }
.fighter.winner .fighter-avatar {
  box-shadow: 0 0 15px rgba(212,168,67,0.5);
  border: 2px solid #d4a843;
}

/* HP血条 - 红色系 */
.hp-wrapper { display: flex; flex-direction: column; align-items: center; gap: 4px; }
.fighter-hp-bar {
  width: 100px; height: 10px; border-radius: 5px;
  background: rgba(255,255,255,0.08); overflow: hidden;
  border: 1px solid rgba(255,255,255,0.1);
}
.fighter-hp-fill { height: 100%; border-radius: 4px; transition: width 0.5s ease, background-color 0.3s ease; }
.fighter-hp-fill.hp-green {
  background: linear-gradient(90deg, #8b2000, #ff6b35);
  box-shadow: 0 0 8px rgba(255,107,53,0.3);
}
.fighter-hp-fill.hp-yellow {
  background: linear-gradient(90deg, #a0522d, #ff6b35);
  box-shadow: 0 0 8px rgba(255,107,53,0.4);
}
.fighter-hp-fill.hp-red {
  background: linear-gradient(90deg, #8b0000, #ff4444);
  box-shadow: 0 0 10px rgba(255,68,68,0.5);
}
.hp-text { font-size: 11px; color: #a09880; }

.vs-center { padding: 0 16px; text-align: center; }
.vs-text {
  font-size: 20px; font-weight: 900; color: #d4a843;
  text-shadow: 0 0 10px rgba(212,168,67,0.4);
}
.round-indicator { font-size: 12px; color: #d4a843; margin-top: 4px; }

/* 当前回合显示 */
.current-round {
  min-height: 80px; display: flex; align-items: center; justify-content: center;
  padding: 16px; margin: 16px 0;
  background: rgba(15,15,30,0.9);
  border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.12);
}
.action-display { display: flex; align-items: center; justify-content: center; gap: 10px; flex-wrap: wrap; }
.action-display.action-flash { animation: flashAction 0.3s ease; }
@keyframes flashAction {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}
.action-attacker { font-weight: bold; }
.action-arrow { color: #666; margin: 0 6px; }
.side-a { color: #ffa500; }
.side-b { color: #ff6b35; }
.damage-number { font-size: 28px; font-weight: 900; color: #fff; text-shadow: 0 0 15px rgba(255,255,255,0.5); animation: damageFloat 0.8s ease; }
.damage-number.crit-dmg { color: #ff4444; font-size: 36px; text-shadow: 0 0 20px rgba(255,68,68,0.8); }
@keyframes damageFloat {
  0% { transform: translateY(10px); opacity: 0; }
  20% { transform: translateY(-5px); opacity: 1; }
  100% { transform: translateY(0); opacity: 1; }
}

/* 特效文字 - 火焰色系 */
.effect-text { font-size: 14px; font-weight: bold; padding: 4px 10px; border-radius: 6px; animation: effectPop 0.5s ease; }
@keyframes effectPop {
  0% { transform: scale(0); opacity: 0; }
  50% { transform: scale(1.3); }
  100% { transform: scale(1); opacity: 1; }
}
.effect-crit { color: #fff; background: linear-gradient(135deg, #ff4444, #8b0000); font-size: 18px; box-shadow: 0 0 15px rgba(255,68,68,0.5); }
.effect-combo { color: #fff; background: linear-gradient(135deg, #ff6b35, #a0522d); box-shadow: 0 0 10px rgba(255,107,53,0.4); }
.effect-dodge { color: #fff; background: linear-gradient(135deg, #a0522d, #8b2000); animation: dodgeFade 1s ease; }
@keyframes dodgeFade {
  0% { transform: translateX(0); opacity: 0; }
  30% { transform: translateX(-10px); opacity: 1; }
  70% { transform: translateX(10px); opacity: 1; }
  100% { transform: translateX(0); opacity: 0.7; }
}
.effect-counter { color: #fff; background: linear-gradient(135deg, #ff6b35, #8b2000); box-shadow: 0 0 10px rgba(255,107,53,0.4); }
.effect-stun { color: #0b0b18; background: linear-gradient(135deg, #ffd700, #d4a843); box-shadow: 0 0 10px rgba(212,168,67,0.4); }
.effect-vampire { color: #fff; background: linear-gradient(135deg, #a0522d, #8b2000); box-shadow: 0 0 10px rgba(160,82,45,0.4); }

/* 战斗结果横幅 */
.battle-result-banner {
  text-align: center; padding: 16px; margin-top: 12px;
  border-radius: 10px; font-size: 18px; font-weight: bold;
  display: flex; flex-direction: column; align-items: center; gap: 4px;
}
/* 胜利 - 金色 */
.result-A, .result-B {
  background: linear-gradient(135deg, rgba(212,168,67,0.15), rgba(212,168,67,0.05));
  border: 1px solid rgba(212,168,67,0.35);
  color: #f0d68a;
}
/* 平局 */
.result-draw {
  background: rgba(20,20,35,0.65);
  border: 1px solid rgba(212,168,67,0.15);
  color: #a09880;
}

/* 战斗预告 */
.battle-intro { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 0; animation: fadeIn 0.3s ease; }
.intro-fighters { display: flex; align-items: center; gap: 30px; margin-bottom: 30px; }
.intro-fighter { display: flex; flex-direction: column; align-items: center; gap: 8px; }
.intro-avatar { width: 60px; height: 60px; border-radius: 15px; display: flex; align-items: center; justify-content: center; font-weight: bold; color: #fff; font-size: 24px; }
.intro-vs { font-size: 28px; font-weight: 900; color: #d4a843; text-shadow: 0 0 20px rgba(212,168,67,0.6); animation: pulse 1s infinite; }
.countdown { font-size: 48px; font-weight: 900; color: #ff6b35; text-shadow: 0 0 30px rgba(255,107,53,0.8); animation: countdownPop 0.8s ease; }
@keyframes countdownPop { 0% { transform: scale(0.5); opacity: 0; } 50% { transform: scale(1.3); } 100% { transform: scale(1); opacity: 1; } }
@keyframes pulse { 0%, 100% { transform: scale(1); } 50% { transform: scale(1.1); } }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

/* 击杀特写 */
.kill-shot { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); z-index: 100; pointer-events: none; }
.kill-text {
  font-size: 48px; font-weight: 900; color: #ff2222;
  text-shadow: 0 0 20px rgba(255,34,34,0.8), 0 0 40px rgba(255,34,34,0.5), 4px 4px 0 #000;
  animation: killShot 1s ease; white-space: nowrap;
}
@keyframes killShot {
  0% { transform: scale(0) rotate(-10deg); opacity: 0; }
  30% { transform: scale(1.5) rotate(5deg); opacity: 1; }
  60% { transform: scale(1.2) rotate(-3deg); }
  100% { transform: scale(1) rotate(0); }
}

/* 战斗控制按钮 */
.battle-controls { margin-top: 16px; }

/* 排行榜 */
.my-ranking-card {
  text-align: center; padding: 16px;
  background: rgba(15,15,30,0.9);
  border-radius: 12px; margin-bottom: 16px;
  border: 1px solid rgba(212,168,67,0.12);
}
.my-ranking-card .tier-icon { font-size: 36px; }
.my-ranking-card .tier-name { font-size: 18px; font-weight: bold; margin: 4px 0; color: #e8e0d0; }
.my-ranking-card .tier-score { color: #d4a843; }
.my-ranking-card .tier-record { font-size: 12px; color: #888; margin-top: 4px; }

.rank-item {
  display: flex; align-items: center;
  padding: 10px; gap: 10px;
  border-bottom: 1px solid rgba(212,168,67,0.08);
}
.rank-num { width: 24px; text-align: center; font-weight: bold; color: #888; }
.rank-num.top-three { color: #d4a843; }
.rank-tier-icon { font-size: 20px; }
.rank-info { flex: 1; }
.rank-name { font-weight: bold; color: #e8e0d0; }
.rank-level { font-size: 11px; color: #888; }
.rank-stats { font-size: 11px; color: #888; }
.rank-score { color: #d4a843; font-weight: bold; }

/* 战绩统计 */
.stats-grid {
  display: grid; grid-template-columns: repeat(4,1fr); gap: 8px;
  margin: 12px 0 16px;
}
.stat-box {
  text-align: center; padding: 12px;
  background: rgba(15,15,30,0.9);
  border-radius: 8px;
  border: 1px solid rgba(212,168,67,0.1);
}
.stat-val { font-size: 20px; font-weight: bold; }
.stat-val.win { color: #d4a843; }
.stat-val.loss { color: #8b2000; }
.stat-val.gold { color: #d4a843; }
.stat-val.streak { color: #ff6b35; }
.stat-label { font-size: 11px; color: #888; margin-top: 2px; }

.recent-title { font-weight: bold; margin: 12px 0 8px; color: #e8e0d0; }
.match-item {
  display: flex; align-items: center;
  padding: 8px; gap: 8px;
  border-bottom: 1px solid rgba(212,168,67,0.08);
}
.match-result { width: 28px; text-align: center; font-weight: bold; }
.match-result.win { color: #d4a843; }
.match-result.loss { color: #8b2000; }
.match-info { flex: 1; }
.match-bet { color: #d4a843; font-size: 11px; margin-left: 6px; }
.match-time { font-size: 11px; color: #888; }

/* 暴击屏幕震动 */
@keyframes battle-shake {
  0%, 100% { transform: translateX(0); }
  10% { transform: translateX(-5px) translateY(3px); }
  20% { transform: translateX(5px) translateY(-3px); }
  30% { transform: translateX(-4px) translateY(2px); }
  40% { transform: translateX(4px) translateY(-2px); }
  50% { transform: translateX(-3px); }
  60% { transform: translateX(3px); }
  70% { transform: translateX(-2px); }
  80% { transform: translateX(2px); }
}
.screen-shake { animation: battle-shake 0.4s ease-out; }
</style>
