<template>
  <div class="minigame-page">
    <!-- 未开始状态 -->
    <div v-if="gameState === 'idle'" class="intro-section">
      <div class="intro-card">
        <div class="title-section">
          <span class="flame-icon">🔥</span>
          <h1 class="game-title">焰灵试炼</h1>
          <span class="flame-icon">🔥</span>
        </div>
        
        <div class="rules-section">
          <h3>📜 试炼规则</h3>
          <ul class="rules-list">
            <li>⏱️ 限时 <strong>30秒</strong>，测试你的反应极限</li>
            <li>🔥 点击出现的火焰符文得分</li>
            <li>⚡ 点击越快得分越高：
              <span class="score-rule">< 0.3s = 150分</span>
              <span class="score-rule">< 0.6s = 100分</span>
              <span class="score-rule">< 1s = 50分</span>
              <span class="score-rule">> 1s = 20分</span>
            </li>
            <li>🎯 同时最多出现3个符文，每个存在1.5秒</li>
            <li>💎 根据总分发放焰晶奖励</li>
          </ul>
        </div>

        <div class="reward-section">
          <h3>🎁 奖励说明</h3>
          <div class="reward-tiers">
            <div class="reward-tier tier-1">
              <span class="tier-score">≥8000分</span>
              <span class="tier-prize">500焰晶</span>
            </div>
            <div class="reward-tier tier-2">
              <span class="tier-score">≥5000分</span>
              <span class="tier-prize">300焰晶</span>
            </div>
            <div class="reward-tier tier-3">
              <span class="tier-score">≥3000分</span>
              <span class="tier-prize">200焰晶</span>
            </div>
            <div class="reward-tier tier-4">
              <span class="tier-score">≥1000分</span>
              <span class="tier-prize">100焰晶</span>
            </div>
            <div class="reward-tier tier-5">
              <span class="tier-score"><1000分</span>
              <span class="tier-prize">50焰晶</span>
            </div>
          </div>
        </div>

        <div class="stats-section">
          <div class="stat-item">
            <span class="stat-label">今日剩余次数</span>
            <span class="stat-value" :class="{ 'no-plays': remainingPlays === 0 }">{{ remainingPlays }}/3</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">历史最高分</span>
            <span class="stat-value best">{{ bestScore }}</span>
          </div>
        </div>

        <button 
          class="start-btn" 
          @click="startGame" 
          :disabled="remainingPlays === 0 || loading"
          :class="{ 'disabled': remainingPlays === 0 }"
        >
          <span v-if="loading">加载中...</span>
          <span v-else-if="remainingPlays === 0">今日次数已用完</span>
          <span v-else>开始试炼</span>
        </button>
      </div>
    </div>

    <!-- 游戏进行中 -->
    <div v-else-if="gameState === 'playing'" class="game-section">
      <div class="game-header">
        <div class="score-display">
          <span class="label">得分</span>
          <span class="value">{{ score }}</span>
        </div>
        
        <div class="timer-display">
          <div class="timer-circle">
            <svg viewBox="0 0 100 100">
              <circle class="timer-bg" cx="50" cy="50" r="45"/>
              <circle 
                class="timer-progress" 
                cx="50" cy="50" r="45"
                :style="{ strokeDashoffset: timerOffset }"
              />
            </svg>
            <span class="timer-text">{{ remainingTime }}</span>
          </div>
        </div>

        <div class="hits-display">
          <span class="label">命中</span>
          <span class="value">{{ hits }}/{{ totalRunes }}</span>
        </div>
      </div>

      <div class="game-area" ref="gameArea" @click="handleMiss">
        <div 
          v-for="rune in activeRunes" 
          :key="rune.id"
          class="fire-rune"
          :style="rune.style"
          @click.stop="hitRune(rune)"
          :class="{ 'exploding': rune.exploding }"
        >
          <span class="rune-emoji">{{ rune.emoji }}</span>
          <div class="rune-glow"></div>
        </div>

        <div 
          v-for="popup in scorePopups" 
          :key="popup.id"
          class="score-popup"
          :style="popup.style"
        >
          +{{ popup.score }}
        </div>
      </div>
    </div>

    <!-- 游戏结束 -->
    <div v-else-if="gameState === 'ended'" class="result-section">
      <div class="result-card">
        <div class="result-title">
          <span v-if="score >= 8000">🔥 焰神降临 🔥</span>
          <span v-else-if="score >= 5000">⚡ 焰灵尊者 ⚡</span>
          <span v-else-if="score >= 3000">💫 焰灵高手 💫</span>
          <span v-else-if="score >= 1000">✨ 焰灵学徒 ✨</span>
          <span v-else>🌟 初入焰道 🌟</span>
        </div>

        <div class="result-stats">
          <div class="result-stat">
            <span class="label">最终得分</span>
            <span class="value big">{{ score }}</span>
          </div>
          <div class="result-stat">
            <span class="label">命中符文</span>
            <span class="value">{{ hits }}/{{ totalRunes }}</span>
          </div>
          <div class="result-stat">
            <span class="label">命中率</span>
            <span class="value">{{ totalRunes > 0 ? Math.round(hits / totalRunes * 100) : 0 }}%</span>
          </div>
        </div>

        <div class="reward-box" v-if="reward > 0">
          <div class="reward-label">获得奖励</div>
          <div class="reward-amount">
            <span class="gem-icon">💎</span>
            <span class="amount">{{ reward }}</span>
            <span class="unit">焰晶</span>
          </div>
        </div>

        <div class="remaining-info">
          今日剩余次数：<strong>{{ remainingPlays }}/3</strong>
        </div>

        <div class="result-buttons">
          <button 
            class="play-again-btn"
            @click="resetGame"
            :disabled="remainingPlays === 0"
            :class="{ 'disabled': remainingPlays === 0 }"
          >
            {{ remainingPlays === 0 ? '今日次数已用完' : '再来一次' }}
          </button>
          <button class="back-btn" @click="backToIntro">
            返回
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const gameState = ref('idle') // idle, playing, ended
const loading = ref(false)

// 游戏数据
const score = ref(0)
const hits = ref(0)
const totalRunes = ref(0)
const remainingTime = ref(30)
const gameTimer = ref(null)
const runeTimer = ref(null)
const activeRunes = ref([])
const scorePopups = ref([])
const gameToken = ref('')
const remainingPlays = ref(3)
const bestScore = ref(0)
const reward = ref(0)

// 从服务器获取的状态
const gameArea = ref(null)
let runeIdCounter = 0
let popupIdCounter = 0

// 计算倒计时圆环偏移
const timerOffset = computed(() => {
  const circumference = 2 * Math.PI * 45
  const progress = remainingTime.value / 30
  return circumference * (1 - progress)
})

// 获取游戏状态
const fetchStatus = async () => {
  try {
    const res = await authStore.apiGet('/minigame/status')
    if (res.success) {
      remainingPlays.value = res.remainingPlays
      bestScore.value = res.bestScore
    }
  } catch (e) {
    console.error('获取状态失败:', e)
  }
}

// 开始游戏
const startGame = async () => {
  if (remainingPlays.value === 0) return
  
  loading.value = true
  try {
    const res = await authStore.apiPost('/minigame/start')
    if (res.success) {
      gameToken.value = res.gameToken
      remainingPlays.value = res.remainingPlays
      initGame()
    } else {
      alert(res.message)
    }
  } catch (e) {
    console.error('开始游戏失败:', e)
    alert('开始游戏失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

// 初始化游戏
const initGame = () => {
  score.value = 0
  hits.value = 0
  totalRunes.value = 0
  remainingTime.value = 30
  activeRunes.value = []
  scorePopups.value = []
  gameState.value = 'playing'
  
  // 开始倒计时
  gameTimer.value = setInterval(() => {
    remainingTime.value--
    if (remainingTime.value <= 0) {
      endGame()
    }
  }, 1000)
  
  // 开始生成符文
  spawnRune()
  runeTimer.value = setInterval(spawnRune, 600)
}

// 生成符文
const spawnRune = () => {
  if (gameState.value !== 'playing') return
  if (activeRunes.value.length >= 3) return
  
  const gameAreaEl = gameArea.value
  if (!gameAreaEl) return
  
  const rect = gameAreaEl.getBoundingClientRect()
  const size = 60
  const padding = 20
  
  const maxX = rect.width - size - padding * 2
  const maxY = rect.height - size - padding * 2
  
  const rune = {
    id: runeIdCounter++,
    emoji: ['🔥', '🔥', '🔥', '✨', '⚡'][Math.floor(Math.random() * 5)],
    style: {
      left: `${padding + Math.random() * maxX}px`,
      top: `${padding + Math.random() * maxY}px`,
    },
    spawnTime: Date.now(),
    exploding: false
  }
  
  activeRunes.value.push(rune)
  totalRunes.value++
  
  // 1.5秒后自动消失
  setTimeout(() => {
    const idx = activeRunes.value.findIndex(r => r.id === rune.id)
    if (idx > -1 && !activeRunes.value[idx].exploding) {
      activeRunes.value.splice(idx, 1)
    }
  }, 1500)
}

// 点击符文
const hitRune = (rune) => {
  if (rune.exploding) return
  
  const reactionTime = Date.now() - rune.spawnTime
  let points = 20
  if (reactionTime < 300) points = 150
  else if (reactionTime < 600) points = 100
  else if (reactionTime < 1000) points = 50
  
  score.value += points
  hits.value++
  
  // 爆炸动画
  rune.exploding = true
  
  // 显示得分弹窗
  showScorePopup(rune.style.left, rune.style.top, points)
  
  // 移除符文
  setTimeout(() => {
    const idx = activeRunes.value.findIndex(r => r.id === rune.id)
    if (idx > -1) {
      activeRunes.value.splice(idx, 1)
    }
  }, 200)
}

// 显示得分弹窗
const showScorePopup = (left, top, points) => {
  const popup = {
    id: popupIdCounter++,
    score: points,
    style: {
      left,
      top
    }
  }
  scorePopups.value.push(popup)
  
  setTimeout(() => {
    const idx = scorePopups.value.findIndex(p => p.id === popup.id)
    if (idx > -1) {
      scorePopups.value.splice(idx, 1)
    }
  }, 800)
}

// 点击空白处（Miss）
const handleMiss = () => {
  // 可选：点击空白处扣分或什么都不做
}

// 结束游戏
const endGame = async () => {
  gameState.value = 'ended'
  clearInterval(gameTimer.value)
  clearInterval(runeTimer.value)
  activeRunes.value = []
  
  // 提交结果
  try {
    const res = await authStore.apiPost('/minigame/submit', {
      gameToken: gameToken.value,
      score: score.value,
      hits: hits.value,
      totalRunes: totalRunes.value
    })
    
    if (res.success) {
      reward.value = res.reward
      remainingPlays.value = res.remainingPlays
      bestScore.value = res.bestScore
    } else {
      alert(res.message)
    }
  } catch (e) {
    console.error('提交结果失败:', e)
  }
}

// 重置游戏
const resetGame = () => {
  if (remainingPlays.value === 0) return
  startGame()
}

// 返回介绍页
const backToIntro = () => {
  gameState.value = 'idle'
  fetchStatus()
}

onMounted(() => {
  fetchStatus()
})

onUnmounted(() => {
  clearInterval(gameTimer.value)
  clearInterval(runeTimer.value)
})
</script>

<style scoped>
.minigame-page {
  min-height: 100vh;
  background: #0b0b18;
  padding: 20px;
  color: #fff;
}

/* 介绍页样式 */
.intro-section {
  max-width: 600px;
  margin: 0 auto;
}

.intro-card {
  background: linear-gradient(145deg, #1a1a2e 0%, #0f0f1a 100%);
  border-radius: 16px;
  padding: 30px 20px;
  border: 1px solid rgba(212, 168, 67, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
}

.title-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 15px;
  margin-bottom: 30px;
}

.flame-icon {
  font-size: 32px;
  animation: flame-flicker 1.5s ease-in-out infinite;
}

@keyframes flame-flicker {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.1); opacity: 0.8; }
}

.game-title {
  font-size: 28px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843 0%, #ffd700 50%, #d4a843 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 0 30px rgba(212, 168, 67, 0.3);
  margin: 0;
}

.rules-section,
.reward-section {
  margin-bottom: 25px;
}

.rules-section h3,
.reward-section h3 {
  color: #d4a843;
  font-size: 16px;
  margin-bottom: 12px;
  border-left: 3px solid #ff6b35;
  padding-left: 10px;
}

.rules-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.rules-list li {
  padding: 8px 0;
  color: #ccc;
  font-size: 14px;
  line-height: 1.6;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.rules-list li:last-child {
  border-bottom: none;
}

.score-rule {
  display: inline-block;
  background: rgba(212, 168, 67, 0.1);
  padding: 2px 8px;
  border-radius: 4px;
  margin: 2px;
  font-size: 12px;
  color: #ffd700;
}

.reward-tiers {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.reward-tier {
  flex: 1;
  min-width: 100px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
  padding: 10px;
  text-align: center;
  border: 1px solid rgba(212, 168, 67, 0.1);
}

.tier-score {
  display: block;
  font-size: 12px;
  color: #999;
  margin-bottom: 4px;
}

.tier-prize {
  display: block;
  font-size: 14px;
  color: #ffd700;
  font-weight: bold;
}

.tier-1 { border-color: rgba(255, 107, 53, 0.5); background: rgba(255, 107, 53, 0.1); }
.tier-2 { border-color: rgba(212, 168, 67, 0.4); background: rgba(212, 168, 67, 0.1); }
.tier-3 { border-color: rgba(212, 168, 67, 0.3); background: rgba(212, 168, 67, 0.05); }
.tier-4 { border-color: rgba(212, 168, 67, 0.2); }
.tier-5 { border-color: rgba(255, 255, 255, 0.1); }

.stats-section {
  display: flex;
  justify-content: space-around;
  padding: 20px 0;
  margin-bottom: 20px;
  border-top: 1px solid rgba(212, 168, 67, 0.1);
  border-bottom: 1px solid rgba(212, 168, 67, 0.1);
}

.stat-item {
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 12px;
  color: #888;
  margin-bottom: 5px;
}

.stat-value {
  display: block;
  font-size: 24px;
  font-weight: bold;
  color: #ffd700;
}

.stat-value.no-plays {
  color: #ff6b35;
}

.stat-value.best {
  color: #ff6b35;
}

.start-btn {
  width: 100%;
  padding: 16px;
  font-size: 18px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 100%);
  border: none;
  border-radius: 12px;
  color: #0b0b18;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 20px rgba(212, 168, 67, 0.3);
}

.start-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(212, 168, 67, 0.4);
}

.start-btn:disabled,
.start-btn.disabled {
  background: linear-gradient(135deg, #444 0%, #333 100%);
  color: #666;
  cursor: not-allowed;
  box-shadow: none;
}

/* 游戏进行中的样式 */
.game-section {
  max-width: 800px;
  margin: 0 auto;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  background: linear-gradient(145deg, #1a1a2e 0%, #0f0f1a 100%);
  border-radius: 12px;
  margin-bottom: 15px;
  border: 1px solid rgba(212, 168, 67, 0.2);
}

.score-display,
.hits-display {
  text-align: center;
}

.score-display .label,
.hits-display .label {
  display: block;
  font-size: 12px;
  color: #888;
  margin-bottom: 4px;
}

.score-display .value {
  font-size: 28px;
  font-weight: bold;
  color: #ffd700;
}

.hits-display .value {
  font-size: 20px;
  font-weight: bold;
  color: #d4a843;
}

.timer-display {
  position: relative;
}

.timer-circle {
  width: 70px;
  height: 70px;
  position: relative;
}

.timer-circle svg {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.timer-bg {
  fill: none;
  stroke: rgba(255, 255, 255, 0.1);
  stroke-width: 6;
}

.timer-progress {
  fill: none;
  stroke: url(#timerGradient);
  stroke-width: 6;
  stroke-linecap: round;
  stroke-dasharray: 283;
  transition: stroke-dashoffset 1s linear;
}

.timer-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 20px;
  font-weight: bold;
  color: #ffd700;
}

.game-area {
  position: relative;
  height: calc(100vh - 200px);
  min-height: 400px;
  background: linear-gradient(145deg, #0f0f1a 0%, #1a1a2e 100%);
  border-radius: 16px;
  border: 2px solid rgba(212, 168, 67, 0.2);
  overflow: hidden;
  cursor: crosshair;
}

.fire-rune {
  position: absolute;
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  user-select: none;
  transition: transform 0.1s;
}

.fire-rune:active {
  transform: scale(0.9);
}

.rune-emoji {
  font-size: 40px;
  z-index: 2;
  animation: rune-pulse 0.5s ease-in-out infinite;
}

@keyframes rune-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.rune-glow {
  position: absolute;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle, rgba(255, 107, 53, 0.4) 0%, transparent 70%);
  border-radius: 50%;
  animation: glow-pulse 0.8s ease-in-out infinite;
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.6; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.2); }
}

.fire-rune.exploding {
  animation: explode 0.2s ease-out forwards;
}

@keyframes explode {
  0% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.5); opacity: 0.8; }
  100% { transform: scale(2); opacity: 0; }
}

.score-popup {
  position: absolute;
  font-size: 20px;
  font-weight: bold;
  color: #ffd700;
  pointer-events: none;
  animation: popup-float 0.8s ease-out forwards;
  text-shadow: 0 0 10px rgba(255, 215, 0, 0.5);
  z-index: 10;
}

@keyframes popup-float {
  0% { transform: translateY(0) scale(1); opacity: 1; }
  100% { transform: translateY(-50px) scale(1.2); opacity: 0; }
}

/* 结果页样式 */
.result-section {
  max-width: 500px;
  margin: 0 auto;
  padding-top: 20px;
}

.result-card {
  background: linear-gradient(145deg, #1a1a2e 0%, #0f0f1a 100%);
  border-radius: 16px;
  padding: 30px 20px;
  border: 1px solid rgba(212, 168, 67, 0.2);
  text-align: center;
}

.result-title {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(135deg, #ff6b35 0%, #ffd700 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 25px;
}

.result-stats {
  display: flex;
  justify-content: space-around;
  margin-bottom: 25px;
  padding: 20px 0;
  border-top: 1px solid rgba(212, 168, 67, 0.1);
  border-bottom: 1px solid rgba(212, 168, 67, 0.1);
}

.result-stat {
  text-align: center;
}

.result-stat .label {
  display: block;
  font-size: 12px;
  color: #888;
  margin-bottom: 5px;
}

.result-stat .value {
  display: block;
  font-size: 18px;
  color: #d4a843;
  font-weight: bold;
}

.result-stat .value.big {
  font-size: 36px;
  color: #ffd700;
}

.reward-box {
  background: linear-gradient(135deg, rgba(255, 107, 53, 0.2) 0%, rgba(212, 168, 67, 0.2) 100%);
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 20px;
  border: 1px solid rgba(255, 107, 53, 0.3);
}

.reward-label {
  font-size: 14px;
  color: #888;
  margin-bottom: 10px;
}

.reward-amount {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.gem-icon {
  font-size: 24px;
}

.reward-amount .amount {
  font-size: 36px;
  font-weight: bold;
  color: #ffd700;
}

.reward-amount .unit {
  font-size: 16px;
  color: #d4a843;
}

.remaining-info {
  font-size: 14px;
  color: #888;
  margin-bottom: 20px;
}

.remaining-info strong {
  color: #ffd700;
}

.result-buttons {
  display: flex;
  gap: 12px;
}

.play-again-btn,
.back-btn {
  flex: 1;
  padding: 14px;
  font-size: 16px;
  font-weight: bold;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.play-again-btn {
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 100%);
  color: #0b0b18;
}

.play-again-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(212, 168, 67, 0.4);
}

.play-again-btn:disabled,
.play-again-btn.disabled {
  background: linear-gradient(135deg, #444 0%, #333 100%);
  color: #666;
  cursor: not-allowed;
}

.back-btn {
  background: rgba(255, 255, 255, 0.1);
  color: #ccc;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #fff;
}

/* 移动端适配 */
@media (max-width: 768px) {
  .minigame-page {
    padding: 10px;
  }
  
  .intro-card {
    padding: 20px 15px;
  }
  
  .game-title {
    font-size: 22px;
  }
  
  .flame-icon {
    font-size: 24px;
  }
  
  .rules-list li {
    font-size: 13px;
  }
  
  .reward-tier {
    min-width: 80px;
    padding: 8px;
  }
  
  .tier-score,
  .tier-prize {
    font-size: 11px;
  }
  
  .game-header {
    padding: 10px 15px;
  }
  
  .score-display .value {
    font-size: 22px;
  }
  
  .timer-circle {
    width: 55px;
    height: 55px;
  }
  
  .timer-text {
    font-size: 16px;
  }
  
  .game-area {
    height: calc(100vh - 160px);
    min-height: 350px;
  }
  
  .fire-rune {
    width: 50px;
    height: 50px;
  }
  
  .rune-emoji {
    font-size: 32px;
  }
  
  .result-stats {
    flex-direction: column;
    gap: 15px;
  }
  
  .result-buttons {
    flex-direction: column;
  }
}

/* SVG渐变定义 */
.game-section::before {
  content: '';
  position: fixed;
  width: 0;
  height: 0;
}
</style>

<svg width="0" height="0" style="position: absolute;">
  <defs>
    <linearGradient id="timerGradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#ff6b35"/>
      <stop offset="100%" stop-color="#ffd700"/>
    </linearGradient>
  </defs>
</svg>
