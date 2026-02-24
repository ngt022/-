<template>
  <div class="daily-dungeon">
    <game-guide>
      <p>📅 每日限次挑战副本，每日重置</p>
      <p>⚔️ 4个难度：简单→普通→困难→<strong>地狱</strong>，难度越高奖励越好</p>
      <p>🎁 奖励：焰晶、焰力、焰兽精华、符文石等</p>
      <p>💡 每天记得打满次数，不要浪费！</p>
    </game-guide>
    <div class="page-title">每日焰境</div>

    <!-- 战斗界面 -->
    <div v-if="battleState" class="battle-overlay">
      <div class="battle-box">
        <div class="battle-header">
          <span class="enemy-name">{{ battleEnemy.name }}</span>
          <span class="enemy-level">Lv.{{ battleEnemy.level }}</span>
        </div>
        <div class="hp-bar-wrap">
          <div class="hp-bar" :style="{ width: enemyHpPercent + '%' }"></div>
          <span class="hp-text">{{ enemyHpDisplay }} / {{ battleEnemy.hp }}</span>
        </div>
        <div class="battle-log" ref="logBox">
          <div v-for="(log, i) in displayedLogs" :key="i" :class="['log-line', log.actor === 'player' ? 'log-player' : 'log-enemy']">
            <span v-if="log.actor === 'player'">
              ⚔️ 第{{ log.round }}回合 — 你发起攻击，造成 <b :class="{ crit: log.crit }">{{ log.damage }}</b> 点伤害
              <span v-if="log.crit" class="crit-tag">暴击!</span>
            </span>
            <span v-else>
              🛡️ 第{{ log.round }}回合 — {{ battleEnemy.name }}攻击你，造成 <b :class="{ crit: log.crit }">{{ log.damage }}</b> 点伤害
              <span v-if="log.crit" class="crit-tag">暴击!</span>
            </span>
          </div>
        </div>
        <div v-if="battleDone" class="battle-result">
          <div v-if="battleResult === 'victory'" class="result-victory">
            <div class="result-title">🎉 大获全胜!</div>
            <div class="reward-list">
              <div v-if="battleRewards.spiritStones" class="reward-item">💎 焰晶 +{{ battleRewards.spiritStones }}</div>
              <div v-if="battleRewards.cultivation" class="reward-item">📖 焰力 +{{ battleRewards.cultivation }}</div>
              <div v-if="battleRewards.items" v-for="item in battleRewards.items" :key="item" class="reward-item">🎁 {{ item }}</div>
              <div v-if="battleRewards.petEssence" class="reward-item">🐾 焰兽精华 +{{ battleRewards.petEssence }}</div>
              <div v-if="battleRewards.refinementStones" class="reward-item">💠 符文石 +{{ battleRewards.refinementStones }}</div>
            </div>
          </div>
          <div v-else class="result-defeat">
            <div class="result-title">💀 挑战失败</div>
            <div class="result-sub">实力不足，下次再来！</div>
          </div>
          <button class="btn-back" @click="closeBattle">返 回</button>
        </div>
      </div>
    </div>

    <!-- 副本卡片 -->
    <div class="dungeon-grid">
      <div v-for="d in dungeons" :key="d.id" :class="['dungeon-card', d.difficulty, { locked: d.locked, exhausted: !d.locked && d.remaining <= 0 }]" @click="enterDungeon(d)">
        <div class="card-diff" :class="d.difficulty">{{ diffLabel[d.difficulty] }}</div>
        <div class="card-name">{{ d.name }}</div>
        <div class="card-desc">{{ d.description }}</div>
        <div class="card-info">
          <span>等级要求: Lv.{{ d.min_level }}</span>
          <span>次数: {{ d.remaining }}/{{ d.max_entries }}</span>
        </div>
        <div class="card-reward">
          <span v-if="d.rewards_config.spiritStones">💎{{ d.rewards_config.spiritStones }}</span>
          <span v-if="d.rewards_config.cultivation">📖{{ d.rewards_config.cultivation }}</span>
        </div>
        <div v-if="d.locked" class="lock-mask">🔒 等级不足</div>
        <div v-else-if="d.remaining <= 0" class="lock-mask exhausted-mask">已耗尽</div>
      </div>
    </div>

    <!-- 今日记录 -->
    <div class="history-section">
      <div class="section-title">今日挑战记录</div>
      <div v-if="!history.length" class="empty-hint">暂无记录</div>
      <div v-for="h in history" :key="h.id" :class="['history-item', h.result]">
        <span class="h-name">{{ h.dungeon_name }}</span>
        <span :class="['h-result', h.result]">{{ h.result === 'victory' ? '✅ 胜利' : '❌ 失败' }}</span>
        <span class="h-rewards" v-if="h.result === 'victory' && h.rewards_earned">
          💎{{ h.rewards_earned.spiritStones || 0 }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue"
import { useAuthStore } from "../stores/auth"
import { usePlayerStore } from "../stores/player"
import { useMessage } from "naive-ui"
import sfx from "../plugins/sfx"
import GameGuide from '../components/GameGuide.vue'

const authStore = useAuthStore()
const playerStore = usePlayerStore()
const message = useMessage()
const API = "/api/dungeon-daily"
const headers = () => ({ Authorization: `Bearer ${authStore.token}`, "Content-Type": "application/json" })

const dungeons = ref([])
const history = ref([])
const battleState = ref(false)
const battleDone = ref(false)
const battleResult = ref("")
const battleRewards = ref({})
const battleEnemy = ref({})
const displayedLogs = ref([])
const enemyHpDisplay = ref(0)
const enemyHpPercent = ref(100)
const logBox = ref(null)
const loading = ref(false)

const diffLabel = { easy: "简单", normal: "普通", hard: "困难", hell: "地狱" }

async function fetchList() {
  try {
    const r = await fetch(API + "/list", { headers: headers() })
    const d = await r.json()
    if (d.dungeons) dungeons.value = d.dungeons
  } catch {}
}

async function fetchHistory() {
  try {
    const r = await fetch(API + "/history", { headers: headers() })
    const d = await r.json()
    if (d.history) history.value = d.history
  } catch {}
}

async function enterDungeon(d) {
  // 战斗时停止自动冥想
  playerStore.stopAutoCultivation()
  if (d.locked || d.remaining <= 0 || loading.value) return
  sfx.click()
  loading.value = true
  try {
    const r = await fetch(API + "/enter", {
      method: "POST", headers: headers(),
      body: JSON.stringify({ dungeon_id: d.id })
    })
    const data = await r.json()
    if (!r.ok) { sfx.error(); message.error(data.error || '进入失败'); return }

    battleState.value = true
    battleDone.value = false
    battleResult.value = data.result
    battleRewards.value = data.rewards || {}
    battleEnemy.value = data.enemy
    displayedLogs.value = []
    enemyHpDisplay.value = data.enemy.hp
    enemyHpPercent.value = 100

    const logs = data.combatLog || []
    for (let i = 0; i < logs.length; i++) {
      await sleep(600)
      displayedLogs.value.push(logs[i])
      if (logs[i].enemyHp !== undefined) {
        enemyHpDisplay.value = logs[i].enemyHp
        enemyHpPercent.value = Math.max(0, (logs[i].enemyHp / logs[i].enemyMaxHp) * 100)
      }
      if (logs[i].actor === "player") {
        logs[i].crit ? sfx.crit() : sfx.hit()
      } else {
        sfx.hit()
      }
      await nextTick()
      if (logBox.value) logBox.value.scrollTop = logBox.value.scrollHeight
    }

    await sleep(500)
    battleDone.value = true
    data.result === "victory" ? sfx.victory() : sfx.defeat()

    // 同步焰晶奖励
    if (data.rewards?.spiritStones) playerStore.spiritStones += data.rewards.spiritStones
    if (data.rewards?.cultivation) playerStore.cultivation += data.rewards.cultivation
    if (data.rewards?.petEssence) playerStore.petEssence = (playerStore.petEssence || 0) + data.rewards.petEssence
    if (data.rewards?.refinementStones) playerStore.refinementStones = (playerStore.refinementStones || 0) + data.rewards.refinementStones

    fetchList()
    fetchHistory()
  } catch (e) { sfx.error(); message.error("网络错误") }
  finally { loading.value = false }
}

function closeBattle() { battleState.value = false }
function sleep(ms) { return new Promise(r => setTimeout(r, ms)) }

onMounted(() => { fetchList(); fetchHistory() })
</script>

<style scoped>
.daily-dungeon { padding: 16px; max-width: 800px; margin: 0 auto; }
.page-title { font-size: 22px; font-weight: bold; color: #d4a843; text-align: center; margin-bottom: 20px; text-shadow: 0 0 10px rgba(212,168,67,0.3); }
.dungeon-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; margin-bottom: 24px; }
.dungeon-card { background: rgba(15,15,30,0.9); border: 1px solid rgba(212,168,67,0.12); border-radius: 12px; padding: 16px; cursor: pointer; position: relative; overflow: hidden; transition: all 0.3s; }
.dungeon-card:hover:not(.locked):not(.exhausted) { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(212,168,67,0.15); border-color: rgba(212,168,67,0.4); }
.dungeon-card.locked { opacity: 0.5; cursor: not-allowed; }
.dungeon-card.exhausted { opacity: 0.6; cursor: not-allowed; }
.card-diff { display: inline-block; padding: 2px 10px; border-radius: 10px; font-size: 12px; font-weight: bold; margin-bottom: 8px; }
.card-diff.easy { background: rgba(212,168,67,0.15); color: #f0d68a; }
.card-diff.normal { background: rgba(212,168,67,0.25); color: #d4a843; }
.card-diff.hard { background: rgba(255,107,53,0.2); color: #ff6b35; }
.card-diff.hell { background: rgba(139,32,0,0.4); color: #ff4444; text-shadow: 0 0 6px rgba(255,68,68,0.5); }
.card-name { font-size: 18px; font-weight: bold; color: #eee; margin-bottom: 6px; }
.card-desc { font-size: 13px; color: #888; margin-bottom: 10px; line-height: 1.4; }
.card-info { display: flex; justify-content: space-between; font-size: 13px; color: #999; margin-bottom: 8px; }
.card-reward { display: flex; gap: 12px; font-size: 13px; color: #d4a843; }
.lock-mask { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; background: rgba(0,0,0,0.6); font-size: 18px; color: #888; font-weight: bold; border-radius: 12px; }
.exhausted-mask { color: #a0522d; }
.battle-overlay { position: fixed; inset: 0; z-index: 1000; background: rgba(5,5,15,0.95); display: flex; align-items: center; justify-content: center; padding: 16px; }
.battle-box { width: 100%; max-width: 500px; background: rgba(15,15,30,0.95); border: 1px solid rgba(212,168,67,0.2); border-radius: 16px; padding: 20px; }
.battle-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.enemy-name { font-size: 20px; font-weight: bold; color: #ff6b35; }
.enemy-level { font-size: 14px; color: #999; }
.hp-bar-wrap { position: relative; height: 22px; background: rgba(30,30,50,0.8); border-radius: 11px; overflow: hidden; margin-bottom: 16px; border: 1px solid rgba(139,32,0,0.3); }
.hp-bar { height: 100%; background: linear-gradient(90deg, #8b2000, #ff4444); transition: width 0.5s ease; border-radius: 11px; }
.hp-text { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 12px; color: #fff; text-shadow: 0 1px 2px #000; }
.battle-log { max-height: 250px; overflow-y: auto; margin-bottom: 16px; padding: 8px; background: rgba(10,10,20,0.5); border-radius: 8px; }
.log-line { padding: 6px 8px; font-size: 13px; border-bottom: 1px solid rgba(255,255,255,0.04); animation: fadeIn 0.3s; }
.log-player { color: #f0d68a; }
.log-enemy { color: #ff6b35; }
.log-line b { font-weight: bold; }
.log-line b.crit { color: #ffd700; font-size: 15px; }
.crit-tag { color: #ffd700; font-size: 11px; margin-left: 4px; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: translateY(0); } }
.battle-result { text-align: center; padding: 16px 0; animation: fadeIn 0.5s; }
.result-victory .result-title { font-size: 28px; color: #ffd700; font-weight: bold; text-shadow: 0 0 20px rgba(255,215,0,0.4); margin-bottom: 12px; }
.result-defeat .result-title { font-size: 28px; color: #888; font-weight: bold; margin-bottom: 8px; }
.result-sub { color: #999; font-size: 14px; margin-bottom: 12px; }
.reward-list { display: flex; flex-wrap: wrap; gap: 8px; justify-content: center; margin-bottom: 16px; }
.reward-item { background: rgba(212,168,67,0.1); border: 1px solid rgba(212,168,67,0.2); padding: 6px 14px; border-radius: 8px; font-size: 14px; color: #d4a843; }
.btn-back { background: linear-gradient(135deg, #8b2000, #ff6b35); color: #fff; border: none; padding: 10px 32px; border-radius: 8px; font-size: 15px; font-weight: bold; cursor: pointer; }
.btn-back:hover { opacity: 0.9; }
.history-section { margin-top: 8px; }
.section-title { font-size: 16px; color: #d4a843; font-weight: bold; margin-bottom: 12px; border-left: 3px solid #d4a843; padding-left: 10px; }
.empty-hint { color: #555; font-size: 14px; text-align: center; padding: 20px; }
.history-item { display: flex; align-items: center; gap: 12px; padding: 10px 12px; background: rgba(20,20,35,0.5); border-radius: 8px; margin-bottom: 6px; font-size: 14px; border: 1px solid rgba(212,168,67,0.06); }
.h-name { color: #ccc; flex: 1; }
.h-result.victory { color: #ffd700; }
.h-result.defeat { color: #a0522d; }
.h-rewards { color: #d4a843; }
</style>
