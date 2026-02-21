<template>
  <div class="boss-page">
    <game-guide>
      <p>🐉 <strong>世界Boss</strong>定时降临，全服玩家协力击杀</p>
      <p>⚔️ 每次攻击消耗<strong>10焰灵</strong>，冷却3秒</p>
      <p>🏆 按<strong>伤害排名</strong>发放焰晶奖励</p>
      <p>⏰ 限时开放，Boss被击杀后可领取奖励</p>
    </game-guide>
    <!-- 无Boss时 -->
    <template v-if="!boss">
      <n-card class="boss-card">
        <n-empty description="当前无黑焰入侵，请等待下次降临">
          <template #icon><span style="font-size:48px">🐉</span></template>
        </n-empty>
      </n-card>
      <n-card title="📜 历史记录" style="margin-top:16px" v-if="history.length">
        <n-table :bordered="false" size="small">
          <thead><tr><th>Boss</th><th>等级</th><th>HP</th><th>状态</th><th>时间</th></tr></thead>
          <tbody>
            <tr v-for="h in history" :key="h.id">
              <td>{{ h.name }}</td>
              <td>Lv.{{ h.level }}</td>
              <td>{{ formatNum(h.maxHp) }}</td>
              <td><n-tag :type="h.status==='dead'?'error':'info'" size="small">{{ h.status==='dead'?'已击杀':'进行中' }}</n-tag></td>
              <td>{{ formatTime(h.spawnTime) }}</td>
            </tr>
          </tbody>
        </n-table>
      </n-card>
    </template>

    <!-- 有Boss时 -->
    <template v-else>
      <!-- Boss 展示区 -->
      <n-card class="boss-card boss-main">
        <div class="boss-header">
          <div class="boss-title">
            <img v-if="getBossImage(boss.name)" :src="getBossImage(boss.name)" class="boss-avatar" loading="lazy" />
            <span v-else class="boss-icon">🐉</span>
            <span class="boss-name">{{ boss.name }}</span>
            <n-tag type="warning" size="small">Lv.{{ boss.level }}</n-tag>
            <n-tag :type="boss.status==='active'?'error':'default'" size="small" style="margin-left:6px">
              {{ boss.status==='active'?'⚔️ 战斗中':boss.status==='dead'?'💀 已击杀':'⏳ 等待中' }}
            </n-tag>
          </div>
          <n-tag :type="wsConnected?'success':'error'" size="tiny">{{ wsConnected?'实时连接':'未连接' }}</n-tag>
        </div>
        <p class="boss-desc">{{ boss.description }}</p>
        <!-- 血条 -->
        <div class="hp-bar-wrap">
          <div class="hp-bar-bg">
            <div class="hp-bar-fill" :style="{ width: hpPercent + '%' }"></div>
          </div>
          <div class="hp-text">{{ formatNum(boss.currentHp) }} / {{ formatNum(boss.maxHp) }} ({{ hpPercent.toFixed(1) }}%)</div>
        </div>
        <div class="boss-info-row">
          <n-tag size="small">攻击: {{ boss.attack }}</n-tag>
          <n-tag size="small">防御: {{ boss.defense }}</n-tag>
          <n-tag size="small">参与: {{ totalPlayers }}人</n-tag>
        </div>
      </n-card>

      <div class="boss-body">
        <!-- 左侧：攻击+排行 -->
        <div class="boss-left">
          <!-- 攻击区域 -->
          <n-card class="boss-card attack-card">
            <div class="attack-area">
              <div class="damage-float-container" ref="floatContainer">
                <transition-group name="float">
                  <div v-for="f in floatingDmg" :key="f.id" class="damage-float" :class="{ crit: f.isCrit }" :style="{ left: f.x + 'px' }">
                    {{ f.isCrit ? '暴击! ' : '' }}-{{ formatNum(f.damage) }}
                  </div>
                </transition-group>
              </div>
              <n-button type="error" size="large" :disabled="!canAttack || boss.status!=='active'" :loading="attacking" @click="doAttack" class="attack-btn">
                {{ cooldown > 0 ? `冷却中 (${cooldown}s)` : '⚔️ 出手攻击' }}
              </n-button>
              <div class="attack-cost">消耗: 10 焰灵/次</div>
              <div class="my-stats" v-if="myDamage > 0">
                我的伤害: <span class="gold">{{ formatNum(myDamage) }}</span> | 排名: <span class="gold">#{{ myRank }}</span> | 攻击: {{ myAttacks }}次
              </div>
            </div>
          </n-card>

          <!-- 伤害焰榜 -->
          <n-card title="🏆 伤害焰榜" class="boss-card" style="margin-top:12px">
            <n-table :bordered="false" size="small" class="rank-table">
              <thead><tr><th>排名</th><th>玩家</th><th>总伤害</th><th>次数</th></tr></thead>
              <tbody>
                <tr v-for="r in ranking" :key="r.rank" :class="{ 'my-row': r.fullWallet === myWallet }">
                  <td>
                    <span v-if="r.rank===1" class="medal gold">🥇</span>
                    <span v-else-if="r.rank===2" class="medal silver">🥈</span>
                    <span v-else-if="r.rank===3" class="medal bronze">🥉</span>
                    <span v-else>{{ r.rank }}</span>
                  </td>
                  <td>{{ r.name }}</td>
                  <td class="dmg-col">{{ formatNum(r.damage) }}</td>
                  <td>{{ r.attacks }}</td>
                </tr>
              </tbody>
            </n-table>
          </n-card>
        </div>

        <!-- 右侧：战斗日志+奖励 -->
        <div class="boss-right">
          <!-- 实时战斗日志 -->
          <n-card title="📋 战斗日志" class="boss-card log-card">
            <div class="battle-log" ref="logRef">
              <div v-for="(log, i) in battleLogs" :key="i" class="log-item" :class="{ crit: log.isCrit }">
                <span class="log-name">{{ log.playerName }}</span>
                <span v-if="log.isCrit" class="log-crit">暴击！</span>
                对 Boss 造成了 <span class="log-dmg" :class="{ 'log-crit-dmg': log.isCrit }">{{ formatNum(log.damage) }}</span> 点伤害！
              </div>
              <div v-if="battleLogs.length===0" class="log-empty">暂无战斗记录</div>
            </div>
          </n-card>

          <!-- 奖励领取 -->
          <n-card title="🎁 Boss奖励" class="boss-card" style="margin-top:12px" v-if="rewards.length">
            <div v-for="r in rewards" :key="r.id" class="reward-item">
              <span>{{ r.bossName }} - 第{{ r.rank }}名</span>
              <span class="gold">{{ formatNum(r.stones) }} 焰晶</span>
              <n-tag v-if="r.claimed" type="default" size="small">已领取</n-tag>
            </div>
            <n-button type="warning" block @click="claimRewards" :loading="claiming" :disabled="!hasUnclaimed" style="margin-top:12px">
              {{ hasUnclaimed ? '领取全部奖励' : '已全部领取' }}
            </n-button>
          </n-card>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import img from '@/utils/img.js'
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useMessage } from 'naive-ui'
import sfx from '../plugins/sfx'
import GameGuide from '../components/GameGuide.vue'

const playerStore = usePlayerStore()
const message = useMessage()

const boss = ref(null)
const myDamage = ref(0)
const myAttacks = ref(0)
const myRank = ref(0)
const totalPlayers = ref(0)
const ranking = ref([])
const rewards = ref([])
const history = ref([])
const battleLogs = ref([])
const floatingDmg = ref([])
const wsConnected = ref(false)
const attacking = ref(false)
const claiming = ref(false)
const cooldown = ref(0)
const logRef = ref(null)
const floatContainer = ref(null)

let ws = null
let reconnectTimer = null
let cooldownTimer = null
let floatId = 0

const myWallet = localStorage.getItem('xx_wallet') || ''
const token = localStorage.getItem('xx_token') || ''
const headers = { 'Authorization': `Bearer ${token}` }

// Boss 图片映射
const bossImageMap = {
  '焰蚀蛛母': img('/assets/images/boss/boss_yanShi.png'),
  '魔焰龙': img('/assets/images/boss/boss_moYanLong.png'),
  '焰魔树': img('/assets/images/boss/boss_yanMoShu.png'),
  '黑焰巨人': img('/assets/images/boss/boss_heiYanJuRen.png'),
  '焰石兽': img('/assets/images/boss/boss_yanShiShou.png'),
  '魔焰凤凰': img('/assets/images/boss/boss_moYanFengHuang.png'),
  '远古妖龙': img('/assets/images/boss/boss_yuanGuYaoLong.png'),
}
const getBossImage = (name) => {
  if (!name) return null
  for (const key of Object.keys(bossImageMap)) {
    if (name.includes(key)) return bossImageMap[key]
  }
  return null
}

const hpPercent = computed(() => {
  if (!boss.value || boss.value.maxHp === 0) return 0
  return (boss.value.currentHp / boss.value.maxHp) * 100
})

const canAttack = computed(() => cooldown.value <= 0 && !attacking.value)
const hasUnclaimed = computed(() => rewards.value.some(r => !r.claimed))

function formatNum(n) {
  if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M'
  if (n >= 10000) return (n / 10000).toFixed(1) + 'W'
  return n?.toLocaleString() || '0'
}

function formatTime(t) {
  if (!t) return '-'
  const d = new Date(t)
  return `${d.getMonth()+1}/${d.getDate()} ${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}`
}

function startCooldown() {
  cooldown.value = 3
  if (cooldownTimer) clearInterval(cooldownTimer)
  cooldownTimer = setInterval(() => {
    cooldown.value--
    if (cooldown.value <= 0) clearInterval(cooldownTimer)
  }, 1000)
}

function addFloatingDmg(damage, isCrit) {
  const id = ++floatId
  const x = 40 + Math.random() * 120
  floatingDmg.value.push({ id, damage, isCrit, x })
  setTimeout(() => {
    floatingDmg.value = floatingDmg.value.filter(f => f.id !== id)
  }, 1500)
}

async function fetchBoss() {
  try {
    const res = await fetch('/api/boss/current', { headers })
    const data = await res.json()
    boss.value = data.boss
    myDamage.value = data.myDamage || 0
    myAttacks.value = data.myAttacks || 0
    myRank.value = data.myRank || 0
    totalPlayers.value = data.totalPlayers || 0
  } catch {}
}

async function fetchRanking() {
  try {
    const res = await fetch('/api/boss/ranking', { headers })
    const data = await res.json()
    ranking.value = data.ranking || []
  } catch {}
}

async function fetchRewards() {
  try {
    const res = await fetch('/api/boss/rewards', { headers })
    const data = await res.json()
    rewards.value = data.rewards || []
  } catch {}
}

async function fetchHistory() {
  try {
    const res = await fetch('/api/boss/history', { headers })
    const data = await res.json()
    history.value = data.bosses || []
  } catch {}
}

async function doAttack() {
  // 战斗时停止自动冥想
  playerStore.stopAutoCultivation()
  if (!canAttack.value || attacking.value) return
  attacking.value = true
  try {
    const res = await fetch('/api/boss/attack', { method: 'POST', headers: { ...headers, 'Content-Type': 'application/json' } })
    const data = await res.json()
    if (!res.ok) { message.error(data.error); return }
    // 更新数据
    if (boss.value) {
      boss.value.currentHp = data.bossHp
    }
    myDamage.value = data.myTotalDamage
    // 更新焰灵
    if (playerStore.spirit !== undefined) {
      playerStore.spirit = data.spirit
    }
    // 浮动伤害
    addFloatingDmg(data.damage, data.isCrit)
    // 音效
    if (data.isCrit) { try { sfx.crit() } catch {} }
    else { try { sfx.hit() } catch {} }
    startCooldown()
    // 刷新排行
    fetchRanking()
  } catch (e) {
    message.error('攻击失败')
  } finally {
    attacking.value = false
  }
}

async function claimRewards() {
  claiming.value = true
  try {
    const res = await fetch('/api/boss/rewards/claim', { method: 'POST', headers: { ...headers, 'Content-Type': 'application/json' } })
    const data = await res.json()
    if (!res.ok) { message.error(data.error); return }
    message.success(`领取成功！获得 ${formatNum(data.totalStones)} 焰晶`)
    playerStore.spiritStones = data.newSpiritStones
    fetchRewards()
  } catch {
    message.error('领取失败')
  } finally {
    claiming.value = false
  }
}

function connectWs() {
  const proto = location.protocol === 'https:' ? 'wss:' : 'ws:'
  ws = new WebSocket(`${proto}//${location.host}/ws`)
  ws.onopen = () => {
    wsConnected.value = true
    if (token) {
      ws.send(JSON.stringify({ type: 'auth', token, name: playerStore.name }))
    }
  }
  ws.onmessage = (e) => {
    try {
      const data = JSON.parse(e.data)
      if (data.type === 'boss_hit') {
        const d = data.data
        battleLogs.value.push({ playerName: d.playerName, damage: d.damage, isCrit: d.isCrit })
        if (battleLogs.value.length > 30) battleLogs.value.shift()
        if (boss.value) {
          boss.value.currentHp = d.bossHp
        }
        nextTick(() => {
          if (logRef.value) logRef.value.scrollTop = logRef.value.scrollHeight
        })
      }
      if (data.type === 'boss_dead') {
        const d = data.data
        message.success(`🐉 ${d.bossName} 已被击杀！最大功臣: ${d.killerName}`)
        if (boss.value) boss.value.status = 'dead'
        try { sfx.victory() } catch {}
        fetchRewards()
        fetchHistory()
      }
      if (data.type === 'boss_spawn') {
        const d = data.data
        message.info(`🐉 黑焰入侵【${d.bossName}】降临了！`)
        fetchBoss()
        fetchRanking()
        battleLogs.value = []
      }
    } catch {}
  }
  ws.onclose = () => {
    wsConnected.value = false
    reconnectTimer = setTimeout(connectWs, 3000)
  }
  ws.onerror = () => { ws.close() }
}

onMounted(() => {
  fetchBoss()
  fetchRanking()
  fetchRewards()
  fetchHistory()
  connectWs()
})

onUnmounted(() => {
  if (reconnectTimer) clearTimeout(reconnectTimer)
  if (cooldownTimer) clearInterval(cooldownTimer)
  if (ws) { ws.onclose = null; ws.close() }
})
</script>

<style scoped>
.boss-page { max-width: 1000px; margin: 0 auto; padding: 12px; }
.boss-card { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); border: 1px solid #333; border-radius: 12px; }
.boss-main { margin-bottom: 12px; }
.boss-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
.boss-title { display: flex; align-items: center; gap: 8px; }
.boss-icon { font-size: 32px; }
.boss-avatar {
  width: 64px;
  height: 64px;
  border-radius: 10px;
  border: 2px solid rgba(255,215,0,0.5);
  box-shadow: 0 0 14px rgba(255,68,68,0.4);
  object-fit: cover;
}
.boss-name { font-size: 22px; font-weight: bold; color: #ffd700; text-shadow: 0 0 10px rgba(255,215,0,0.5); }
.boss-desc { color: #aaa; font-size: 13px; margin: 8px 0; }
.hp-bar-wrap { margin: 12px 0; }
.hp-bar-bg { height: 28px; background: #333; border-radius: 14px; overflow: hidden; position: relative; }
.hp-bar-fill { height: 100%; background: linear-gradient(90deg, #ff4444, #ff6b6b, #ff4444); border-radius: 14px; transition: width 0.5s ease; box-shadow: 0 0 15px rgba(255,68,68,0.5); }
.hp-text { text-align: center; margin-top: 4px; font-size: 13px; color: #ddd; font-weight: bold; }
.boss-info-row { display: flex; gap: 8px; margin-top: 8px; }
.boss-body { display: flex; gap: 12px; }
.boss-left { flex: 1; min-width: 0; }
.boss-right { width: 340px; flex-shrink: 0; }
@media (max-width: 768px) {
  .boss-body { flex-direction: column; }
  .boss-right { width: 100%; }
}
.attack-area { text-align: center; position: relative; padding: 20px 0; }
.attack-btn { width: 200px; height: 50px; font-size: 18px; font-weight: bold; }
.attack-cost { color: #888; font-size: 12px; margin-top: 8px; }
.my-stats { margin-top: 12px; color: #ccc; font-size: 13px; }
.gold { color: #ffd700; font-weight: bold; }
.damage-float-container { position: absolute; top: 0; left: 0; right: 0; height: 60px; pointer-events: none; overflow: hidden; }
.damage-float { position: absolute; top: 0; font-weight: bold; font-size: 18px; color: #fff; animation: floatUp 1.5s ease-out forwards; text-shadow: 0 0 6px rgba(0,0,0,0.8); }
.damage-float.crit { font-size: 26px; color: #ff4444; text-shadow: 0 0 12px rgba(255,68,68,0.8); }
@keyframes floatUp {
  0% { opacity: 1; transform: translateY(40px) scale(1); }
  50% { opacity: 1; transform: translateY(0px) scale(1.2); }
  100% { opacity: 0; transform: translateY(-30px) scale(0.8); }
}
.float-enter-active { animation: floatUp 1.5s ease-out; }
.float-leave-active { display: none; }
.rank-table .my-row { background: rgba(255,215,0,0.1); }
.rank-table .my-row td { color: #ffd700; font-weight: bold; }
.medal { font-size: 18px; }
.dmg-col { color: #ff6b6b; font-weight: bold; }
.log-card { }
.battle-log { max-height: 300px; overflow-y: auto; padding: 4px; }
.log-item { padding: 4px 0; font-size: 13px; color: #ccc; border-bottom: 1px solid #222; }
.log-item.crit { color: #ff6b6b; }
.log-name { color: #4fc3f7; font-weight: bold; }
.log-crit { color: #ff4444; font-weight: bold; margin: 0 4px; }
.log-dmg { color: #fff; font-weight: bold; }
.log-crit-dmg { color: #ff4444; font-size: 15px; }
.log-empty { color: #666; text-align: center; padding: 20px; }
.reward-item { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #222; }
</style>
