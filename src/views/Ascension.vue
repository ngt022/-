<template>
  <div class="ascension-page">
    <game-guide>
      <p>🔥 达到<strong>100级</strong>后可涅槃飞升，最多<strong>7次</strong></p>
      <p>♻️ 飞升重置：等级归1、焰力清零、装备清除、损失90%焰晶</p>
      <p>✨ 飞升保留：10%焰晶、焰兽、焰号、<strong>永久属性加成</strong></p>
      <p>💪 每次飞升获得永久属性加成（攻/防/血/速/修炼速度）</p>
      <p>💎 飞升奖励：10000×飞升次数 焰晶 + 专属焰号</p>
      <p>🚀 飞升次数越多越强，是后期核心玩法</p>
    </game-guide>
    <!-- 飞升成功动画 -->
    <div v-if="showAnimation" class="ascension-animation-overlay" @click="showAnimation = false">
      <div class="animation-content">
        <div class="golden-burst"></div>
        <div class="ascend-text">涅槃飞升成功！</div>
        <div class="ascend-subtitle">第{{ ascensionResult?.ascensionCount }}世</div>
        <div class="reward-list">
          <div v-for="(item, i) in animationRewards" :key="i" class="reward-item" :style="{ animationDelay: (i * 0.5) + 's' }">
            {{ item }}
          </div>
        </div>
        <div class="click-hint">点击任意处关闭</div>
      </div>
    </div>

    <n-spin :show="loading">
      <!-- 顶部飞升状态卡片 -->
      <div class="ascension-header-card">
        <div class="header-bg-effect"></div>
        <div class="header-content">
          <div class="ascension-world">第{{ (info?.ascensionCount || 0) + 1 }}世</div>
          <div class="ascension-count-display">
            <span class="count-label">涅槃飞升次数</span>
            <span class="count-number">{{ info?.ascensionCount || 0 }}</span>
            <span class="count-max">/ {{ info?.maxAscension || 7 }}</span>
          </div>
          <div class="current-level">当前焰阶等级: Lv.{{ info?.currentLevel || 1 }}</div>
          <div style="margin-top: 16px">
            <n-button
              v-if="info?.canAscend"
              type="warning"
              size="large"
              class="ascend-btn pulse-gold"
              @click="showConfirmModal = true"
            >
              ⚡ 涅槃飞升 ⚡
            </n-button>
            <n-button v-else disabled size="large" class="ascend-btn-disabled">
              {{ (info?.ascensionCount || 0) >= 7 ? '已达最高涅槃飞升' : '需要达到100级' }}
            </n-button>
          </div>
        </div>
      </div>

      <!-- 飞升路径图 -->
      <div class="section-title">✨ 涅槃之路</div>
      <div class="path-container">
        <div class="path-line"></div>
        <div class="path-nodes">
          <div
            v-for="perk in perks"
            :key="perk.ascension_level"
            class="path-node"
            :class="{
              'node-unlocked': perk.unlocked,
              'node-current': perk.ascension_level === (info?.ascensionCount || 0) + 1,
              'node-locked': !perk.unlocked && perk.ascension_level !== (info?.ascensionCount || 0) + 1
            }"
          >
            <div class="node-circle">
              <span class="node-level">{{ perk.ascension_level }}</span>
            </div>
            <div class="node-info">
              <div class="node-name">{{ perk.name }}</div>
              <div class="node-desc">属性+{{ (perk.attack_bonus * 100).toFixed(0) }}%</div>
              <div class="node-special">{{ perk.special_perk }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 永久加成面板 -->
      <div class="section-title">🔥 永久加成</div>
      <div class="bonus-panel">
        <div class="bonus-grid">
          <div class="bonus-item">
            <div class="bonus-icon">⚔️</div>
            <div class="bonus-label">攻击</div>
            <div class="bonus-value">+{{ ((info?.currentBonuses?.attack || 0) * 100).toFixed(0) }}%</div>
          </div>
          <div class="bonus-item">
            <div class="bonus-icon">🛡️</div>
            <div class="bonus-label">防御</div>
            <div class="bonus-value">+{{ ((info?.currentBonuses?.defense || 0) * 100).toFixed(0) }}%</div>
          </div>
          <div class="bonus-item">
            <div class="bonus-icon">❤️</div>
            <div class="bonus-label">生命</div>
            <div class="bonus-value">+{{ ((info?.currentBonuses?.health || 0) * 100).toFixed(0) }}%</div>
          </div>
          <div class="bonus-item">
            <div class="bonus-icon">💨</div>
            <div class="bonus-label">速度</div>
            <div class="bonus-value">+{{ ((info?.currentBonuses?.speed || 0) * 100).toFixed(0) }}%</div>
          </div>
          <div class="bonus-item">
            <div class="bonus-icon">🧘</div>
            <div class="bonus-label">修炼速度</div>
            <div class="bonus-value">+{{ ((info?.currentBonuses?.cultivationSpeed || 0) * 100).toFixed(0) }}%</div>
          </div>
        </div>
      </div>

      <!-- 涅槃飞升焰榜 -->
      <div class="section-title">🏆 涅槃飞升焰榜</div>
      <div class="ranking-panel">
        <div v-if="ranking.length === 0" class="empty-rank">暂无涅槃飞升记录</div>
        <div v-for="r in ranking" :key="r.rank" class="rank-row" :class="'rank-' + r.rank">
          <div class="rank-pos">
            <span v-if="r.rank === 1">🥇</span>
            <span v-else-if="r.rank === 2">🥈</span>
            <span v-else-if="r.rank === 3">🥉</span>
            <span v-else>{{ r.rank }}</span>
          </div>
          <div class="rank-name">{{ r.name || '无名焰修' }}</div>
          <div class="rank-asc">飞升{{ r.ascension_count }}次</div>
          <div class="rank-lvl">Lv.{{ r.level }}</div>
        </div>
      </div>
    </n-spin>

    <!-- 涅槃飞升确认弹窗 -->
    <n-modal v-model:show="showConfirmModal" :mask-closable="false">
      <div class="confirm-modal">
        <div class="confirm-title">⚠️ 涅槃飞升确认 ⚠️</div>
        <div class="confirm-warning">涅槃飞升将重置等级、焰力、装备！</div>

        <div class="confirm-section">
          <div class="section-label lose-label">❌ 将失去</div>
          <div class="confirm-list lose-list">
            <div>等级（重置为1级）</div>
            <div>焰力（清零）</div>
            <div>所有装备</div>
            <div>背包物品</div>
            <div>90%焰晶</div>
          </div>
        </div>

        <div class="confirm-section">
          <div class="section-label keep-label">✅ 将保留</div>
          <div class="confirm-list keep-list">
            <div>10%焰晶</div>
            <div>永久加成</div>
            <div>焰骑</div>
            <div>焰号</div>
          </div>
        </div>

        <div class="confirm-section">
          <div class="section-label gain-label">🎁 将获得</div>
          <div class="confirm-list gain-list">
            <div>永久属性加成 +{{ nextPerkPreview }}%</div>
            <div>{{ 10000 * ((info?.ascensionCount || 0) + 1) }} 焰晶奖励</div>
            <div>涅槃飞升专属焰号</div>
            <div v-if="info?.nextPerk?.special_perk">特殊效果: {{ info.nextPerk.special_perk }}</div>
          </div>
        </div>

        <div class="confirm-input-area">
          <div class="input-hint">请输入「确认涅槃飞升」以继续</div>
          <n-input v-model:value="confirmText" placeholder="确认涅槃飞升" />
        </div>

        <div class="confirm-buttons">
          <n-button @click="showConfirmModal = false; confirmText = ''">取消</n-button>
          <n-button
            type="warning"
            :disabled="confirmText !== '确认涅槃飞升' || ascending"
            :loading="ascending"
            @click="doAscend"
          >
            确认涅槃飞升
          </n-button>
        </div>
      </div>
    </n-modal>
  </div>
</template>
<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { NButton, NInput, NModal, NSpin, useMessage } from 'naive-ui'
import GameGuide from '../components/GameGuide.vue'

const authStore = useAuthStore()
const message = useMessage()

const loading = ref(false)
const ascending = ref(false)
const showConfirmModal = ref(false)
const showAnimation = ref(false)
const confirmText = ref('')
const info = ref(null)
const perks = ref([])
const ranking = ref([])
const ascensionResult = ref(null)
const animationRewards = ref([])

const API = import.meta.env.VITE_API || ''

const headers = computed(() => ({
  'Content-Type': 'application/json',
  'Authorization': 'Bearer ' + (authStore.token || '')
}))

const nextPerkPreview = computed(() => {
  if (!info.value?.nextPerk) return '0'
  return (info.value.nextPerk.attack_bonus * 100).toFixed(0)
})

async function fetchInfo() {
  try {
    const res = await fetch(API + '/api/ascension/info', { headers: headers.value })
    const data = await res.json()
    if (res.ok) info.value = data
  } catch (e) { console.error(e) }
}

async function fetchPerks() {
  try {
    const res = await fetch(API + '/api/ascension/perks', { headers: headers.value })
    const data = await res.json()
    if (res.ok) perks.value = data.perks || []
  } catch (e) { console.error(e) }
}

async function fetchRanking() {
  try {
    const res = await fetch(API + '/api/ascension/ranking', { headers: headers.value })
    const data = await res.json()
    if (res.ok) ranking.value = data.ranking || []
  } catch (e) { console.error(e) }
}

async function doAscend() {
  if (confirmText.value !== '确认涅槃飞升') return
  ascending.value = true
  try {
    const res = await fetch(API + '/api/ascension/ascend', {
      method: 'POST',
      headers: headers.value
    })
    const data = await res.json()
    if (!res.ok) {
      message.error(data.error || '涅槃飞升失败')
      return
    }
    ascensionResult.value = data
    animationRewards.value = [
      '永久攻击 +' + (data.perk.bonuses.attack * 100).toFixed(0) + '%',
      '永久防御 +' + (data.perk.bonuses.defense * 100).toFixed(0) + '%',
      '永久生命 +' + (data.perk.bonuses.health * 100).toFixed(0) + '%',
      '永久速度 +' + (data.perk.bonuses.speed * 100).toFixed(0) + '%',
      '修炼速度 +' + (data.perk.bonuses.cultivationSpeed * 100).toFixed(0) + '%',
      '获得 ' + data.rewards.spiritStones + ' 焰晶',
      '特殊效果: ' + data.perk.specialPerk
    ]
    showConfirmModal.value = false
    confirmText.value = ''
    showAnimation.value = true
    message.success('涅槃飞升成功！')
    await fetchInfo()
    await fetchPerks()
    await fetchRanking()
  } catch (e) {
    message.error('涅槃飞升失败: ' + e.message)
  } finally {
    ascending.value = false
  }
}

onMounted(async () => {
  loading.value = true
  await Promise.all([fetchInfo(), fetchPerks(), fetchRanking()])
  loading.value = false
})
</script>
<style scoped>
.ascension-page {
  padding: 16px;
  max-width: 800px;
  margin: 0 auto;
  color: #e0d5c0;
}

/* 顶部卡片 */
.ascension-header-card {
  position: relative;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
  border: 2px solid #c9a84c;
  border-radius: 16px;
  padding: 32px 24px;
  text-align: center;
  overflow: hidden;
  margin-bottom: 24px;
  box-shadow: 0 0 30px rgba(201, 168, 76, 0.3);
}
.header-bg-effect {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(201, 168, 76, 0.1) 0%, transparent 70%);
  animation: rotate-bg 20s linear infinite;
}
@keyframes rotate-bg {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
.header-content { position: relative; z-index: 1; }
.ascension-world {
  font-size: 18px;
  color: #c9a84c;
  letter-spacing: 4px;
  margin-bottom: 8px;
}
.ascension-count-display { margin: 12px 0; }
.count-label {
  font-size: 14px;
  color: #999;
  display: block;
  margin-bottom: 4px;
}
.count-number {
  font-size: 64px;
  font-weight: bold;
  color: #ffd700;
  text-shadow: 0 0 20px rgba(255, 215, 0, 0.6);
  line-height: 1;
}
.count-max {
  font-size: 24px;
  color: #666;
  margin-left: 4px;
}
.current-level {
  font-size: 14px;
  color: #aaa;
  margin-top: 8px;
}

/* 飞升按钮 */
.ascend-btn {
  font-size: 18px !important;
  padding: 12px 48px !important;
  border-radius: 12px !important;
  font-weight: bold !important;
  background: linear-gradient(135deg, #ffd700, #ff8c00) !important;
  border: none !important;
  color: #1a1a2e !important;
}
.pulse-gold {
  animation: pulse-glow 2s ease-in-out infinite;
}
@keyframes pulse-glow {
  0%, 100% { box-shadow: 0 0 10px rgba(255, 215, 0, 0.5); }
  50% { box-shadow: 0 0 30px rgba(255, 215, 0, 0.9), 0 0 60px rgba(255, 140, 0, 0.4); }
}
.ascend-btn-disabled {
  font-size: 16px !important;
  padding: 10px 36px !important;
  border-radius: 12px !important;
}

/* 区块标题 */
.section-title {
  font-size: 18px;
  font-weight: bold;
  color: #ffd700;
  margin: 24px 0 12px;
  padding-left: 8px;
  border-left: 3px solid #ffd700;
}

/* 飞升路径 */
.path-container {
  position: relative;
  padding: 16px 0;
  overflow-x: auto;
}
.path-nodes {
  display: flex;
  gap: 8px;
  position: relative;
  min-width: fit-content;
}
.path-node {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 90px;
  flex: 1;
}
.node-circle {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 18px;
  margin-bottom: 8px;
  transition: all 0.3s;
}
.node-unlocked .node-circle {
  background: linear-gradient(135deg, #ffd700, #ff8c00);
  color: #1a1a2e;
  box-shadow: 0 0 15px rgba(255, 215, 0, 0.6);
}
.node-current .node-circle {
  background: linear-gradient(135deg, #ffd700, #ff8c00);
  color: #1a1a2e;
  animation: pulse-glow 2s ease-in-out infinite;
}
.node-locked .node-circle {
  background: #333;
  color: #666;
  border: 2px solid #555;
}
.node-info { text-align: center; }
.node-name {
  font-size: 12px;
  color: #c9a84c;
  font-weight: bold;
}
.node-desc {
  font-size: 11px;
  color: #aaa;
}
.node-special {
  font-size: 10px;
  color: #ff8c00;
  margin-top: 2px;
}
/* 永久加成面板 */
.bonus-panel {
  background: rgba(26, 26, 46, 0.8);
  border: 1px solid #333;
  border-radius: 12px;
  padding: 16px;
}
.bonus-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 12px;
}
.bonus-item {
  text-align: center;
  padding: 12px 8px;
  background: rgba(201, 168, 76, 0.1);
  border: 1px solid rgba(201, 168, 76, 0.3);
  border-radius: 8px;
}
.bonus-icon { font-size: 24px; margin-bottom: 4px; }
.bonus-label { font-size: 12px; color: #999; }
.bonus-value {
  font-size: 20px;
  font-weight: bold;
  color: #ffd700;
  margin-top: 4px;
}

/* 排行榜 */
.ranking-panel {
  background: rgba(26, 26, 46, 0.8);
  border: 1px solid #333;
  border-radius: 12px;
  padding: 12px;
  margin-bottom: 24px;
}
.empty-rank {
  text-align: center;
  color: #666;
  padding: 24px;
}
.rank-row {
  display: flex;
  align-items: center;
  padding: 10px 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  gap: 12px;
}
.rank-row:last-child { border-bottom: none; }
.rank-1 { background: rgba(255, 215, 0, 0.1); }
.rank-2 { background: rgba(192, 192, 192, 0.08); }
.rank-3 { background: rgba(205, 127, 50, 0.08); }
.rank-pos {
  width: 36px;
  text-align: center;
  font-size: 18px;
  font-weight: bold;
  color: #ffd700;
}
.rank-name {
  flex: 1;
  color: #e0d5c0;
  font-weight: bold;
}
.rank-asc {
  color: #ff8c00;
  font-size: 13px;
}
.rank-lvl {
  color: #999;
  font-size: 13px;
  min-width: 50px;
  text-align: right;
}

/* 确认弹窗 */
.confirm-modal {
  background: #1a1a2e;
  border: 2px solid #c9a84c;
  border-radius: 16px;
  padding: 24px;
  max-width: 420px;
  width: 90vw;
  color: #e0d5c0;
}
.confirm-title {
  text-align: center;
  font-size: 22px;
  font-weight: bold;
  color: #ffd700;
  margin-bottom: 12px;
}
.confirm-warning {
  text-align: center;
  color: #ff4444;
  font-size: 16px;
  font-weight: bold;
  padding: 8px;
  background: rgba(255, 68, 68, 0.1);
  border-radius: 8px;
  margin-bottom: 16px;
}
.confirm-section { margin-bottom: 12px; }
.section-label {
  font-weight: bold;
  font-size: 14px;
  margin-bottom: 6px;
}
.lose-label { color: #ff4444; }
.keep-label { color: #4caf50; }
.gain-label { color: #ffd700; }
.confirm-list {
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 13px;
  line-height: 1.8;
}
.lose-list { background: rgba(255, 68, 68, 0.08); }
.keep-list { background: rgba(76, 175, 80, 0.08); }
.gain-list { background: rgba(255, 215, 0, 0.08); }
.confirm-input-area { margin: 16px 0; }
.input-hint {
  font-size: 13px;
  color: #999;
  margin-bottom: 6px;
}
.confirm-buttons {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 16px;
}

/* 飞升动画 */
.ascension-animation-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.9);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.animation-content {
  text-align: center;
  position: relative;
}
.golden-burst {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 300px;
  height: 300px;
  margin: -150px 0 0 -150px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255, 215, 0, 0.4) 0%, transparent 70%);
  animation: burst 2s ease-out infinite;
}
@keyframes burst {
  0% { transform: scale(0.5); opacity: 1; }
  100% { transform: scale(2); opacity: 0; }
}
.ascend-text {
  font-size: 48px;
  font-weight: bold;
  color: #ffd700;
  text-shadow: 0 0 30px rgba(255, 215, 0, 0.8);
  animation: fadeInUp 1s ease-out;
  position: relative;
}
.ascend-subtitle {
  font-size: 24px;
  color: #ff8c00;
  margin-top: 8px;
  animation: fadeInUp 1s ease-out 0.3s both;
  position: relative;
}
.reward-list { margin-top: 24px; position: relative; }
.reward-item {
  font-size: 16px;
  color: #e0d5c0;
  padding: 4px 0;
  opacity: 0;
  animation: fadeInUp 0.5s ease-out forwards;
}
.click-hint {
  margin-top: 32px;
  color: #666;
  font-size: 13px;
  position: relative;
}
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
