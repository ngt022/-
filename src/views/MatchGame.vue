<template>
  <div class="matchgame-page">
    <!-- 未开始状态 -->
    <div v-if="gameState === 'idle'" class="intro-section">
      <div class="intro-card">
        <div class="title-section">
          <span class="rune-icon">🔥</span>
          <h1 class="game-title">焰符连连看</h1>
          <span class="rune-icon">🔥</span>
        </div>
        
        <div class="rules-section">
          <h3>📜 游戏规则</h3>
          <ul class="rules-list">
            <li>⏱️ 限时 <strong>60秒</strong>，挑战你的记忆力</li>
            <li>🎯 4×4 网格，8种焰符，每种2个</li>
            <li>🔥 点击翻开焰符，寻找相同配对</li>
            <li>💎 每对消除得100分，连续配对有COMBO加成</li>
            <li>⚡ COMBO加成：x1.5 → x2 → x2.5 → x3...</li>
          </ul>
        </div>

        <div class="reward-section">
          <h3>🎁 奖励说明</h3>
          <div class="reward-tiers">
            <div class="reward-tier tier-1">
              <span class="tier-score">≥2000分</span>
              <span class="tier-prize">500焰晶</span>
            </div>
            <div class="reward-tier tier-2">
              <span class="tier-score">≥1500分</span>
              <span class="tier-prize">300焰晶</span>
            </div>
            <div class="reward-tier tier-3">
              <span class="tier-score">≥1000分</span>
              <span class="tier-prize">200焰晶</span>
            </div>
            <div class="reward-tier tier-4">
              <span class="tier-score">≥500分</span>
              <span class="tier-prize">100焰晶</span>
            </div>
            <div class="reward-tier tier-5">
              <span class="tier-score">&lt;500分</span>
              <span class="tier-prize">50焰晶</span>
            </div>
          </div>
        </div>

        <div class="stats-section">
          <div class="stat-item">
            <span class="stat-label">今日剩余次数</span>
            <span class="stat-value" :class="{ 'no-plays': remainingPlays === 0 }">{{ remainingPlays }}/3</span>
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
          <span v-else>开始游戏</span>
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
            <svg viewBox="0 0 100 100" class="timer-svg">
              <defs>
                <linearGradient id="timerGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" style="stop-color:#ff6b35;stop-opacity:1" />
                  <stop offset="100%" style="stop-color:#d4a843;stop-opacity:1" />
                </linearGradient>
              </defs>
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

        <div class="combo-display">
          <span class="label">COMBO</span>
          <span class="value" :class="{ 'combo-active': combo > 1 }">x{{ comboMultiplier }}</span>
        </div>
      </div>

      <div class="progress-bar">
        <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
      </div>

      <div class="game-grid">
        <div 
          v-for="(cell, index) in grid" 
          :key="index"
          class="grid-cell"
          :class="{ 
            'flipped': cell.flipped || cell.matched,
            'matched': cell.matched,
            'mismatch': cell.mismatch
          }"
          @click="flipCell(index)"
        >
          <div class="cell-inner">
            <div class="cell-front">
              <svg viewBox="0 0 60 60" class="rune-svg">
                <defs>
                  <linearGradient id="flameGrad" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#ff6b35;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#d4a843;stop-opacity:1" />
                  </linearGradient>
                </defs>
                <path d="M30 5 L35 20 L50 15 L40 28 L52 40 L35 35 L30 52 L25 35 L8 40 L20 28 L10 15 L25 20 Z" 
                      fill="url(#flameGrad)" opacity="0.8"/>
              </svg>
            </div>
            <div class="cell-back">
              <span class="rune-emoji">{{ cell.rune }}</span>
            </div>
          </div>
        </div>
      </div>

      <div class="pairs-info">
        <span>已消除: {{ pairsMatched }}/8 对</span>
      </div>
    </div>

    <!-- 游戏结束 -->
    <div v-else-if="gameState === 'ended'" class="result-section">
      <div class="result-card">
        <div class="result-title">
          <span v-if="score >= 2000">🔥 焰神之眼 🔥</span>
          <span v-else-if="score >= 1500">⚡ 焰灵尊者 ⚡</span>
          <span v-else-if="score >= 1000">💫 焰灵高手 💫</span>
          <span v-else-if="score >= 500">✨ 焰灵学徒 ✨</span>
          <span v-else>🌟 初入焰道 🌟</span>
        </div>

        <div class="result-stats">
          <div class="result-stat">
            <span class="label">最终得分</span>
            <span class="value big">{{ score }}</span>
          </div>
          <div class="result-stat">
            <span class="label">消除对数</span>
            <span class="value">{{ pairsMatched }}/8</span>
          </div>
          <div class="result-stat">
            <span class="label">最高连击</span>
            <span class="value">x{{ maxComboMultiplier }}</span>
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
            {{ remainingPlays === 0 ? '今日次数已用完' : '再来一局' }}
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
import { usePlayerStore } from '../stores/player'

const authStore = useAuthStore()
const playerStore = usePlayerStore()

const gameState = ref('idle') // idle, playing, ended
const loading = ref(false)

// 游戏数据
const score = ref(0)
const remainingTime = ref(60)
const gameTimer = ref(null)
const grid = ref([])
const flippedIndices = ref([])
const pairsMatched = ref(0)
const combo = ref(0)
const maxCombo = ref(0)
const gameToken = ref('')
const remainingPlays = ref(3)
const reward = ref(0)
const isProcessing = ref(false)

// 符文列表
const runes = ['🔥', '🌙', '⭐', '💎', '🌊', '⚡', '🍃', '🎯']

// 计算属性
const comboMultiplier = computed(() => {
  if (combo.value <= 1) return 1
  return 1 + (combo.value - 1) * 0.5
})

const maxComboMultiplier = computed(() => {
  if (maxCombo.value <= 1) return 1
  return 1 + (maxCombo.value - 1) * 0.5
})

const timerOffset = computed(() => {
  const circumference = 2 * Math.PI * 45
  const progress = remainingTime.value / 60
  return circumference * (1 - progress)
})

const progressPercent = computed(() => {
  return (pairsMatched.value / 8) * 100
})

// 获取游戏状态
const fetchStatus = async () => {
  try {
    const res = await authStore.apiGet('/match-game/status')
    if (res.success) {
      remainingPlays.value = res.remainingPlays
    }
  } catch (e) {
    console.error('获取状态失败:', e)
  }
}

// 生成随机网格
const generateGrid = () => {
  // 创建8对符文
  const pairs = [...runes, ...runes]
  // 随机打乱
  for (let i = pairs.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[pairs[i], pairs[j]] = [pairs[j], pairs[i]]
  }
  
  grid.value = pairs.map((rune, index) => ({
    id: index,
    rune,
    flipped: false,
    matched: false,
    mismatch: false
  }))
}

// 开始游戏
const startGame = async () => {
  if (remainingPlays.value === 0) return
  
  loading.value = true
  try {
    const res = await authStore.apiPost('/match-game/start')
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
  remainingTime.value = 60
  pairsMatched.value = 0
  combo.value = 0
  maxCombo.value = 0
  flippedIndices.value = []
  isProcessing.value = false
  reward.value = 0
  
  generateGrid()
  gameState.value = 'playing'
  
  // 开始倒计时
  gameTimer.value = setInterval(() => {
    remainingTime.value--
    if (remainingTime.value <= 0) {
      endGame()
    }
  }, 1000)
}

// 翻转格子
const flipCell = (index) => {
  if (isProcessing.value) return
  if (gameState.value !== 'playing') return
  
  const cell = grid.value[index]
  if (cell.flipped || cell.matched) return
  if (flippedIndices.value.length >= 2) return
  
  cell.flipped = true
  flippedIndices.value.push(index)
  
  if (flippedIndices.value.length === 2) {
    checkMatch()
  }
}

// 检查匹配
const checkMatch = () => {
  isProcessing.value = true
  const [idx1, idx2] = flippedIndices.value
  const cell1 = grid.value[idx1]
  const cell2 = grid.value[idx2]
  
  if (cell1.rune === cell2.rune) {
    // 匹配成功
    combo.value++
    if (combo.value > maxCombo.value) {
      maxCombo.value = combo.value
    }
    
    const basePoints = 100
    const totalPoints = Math.floor(basePoints * comboMultiplier.value)
    score.value += totalPoints
    
    setTimeout(() => {
      cell1.matched = true
      cell2.matched = true
      cell1.flipped = false
      cell2.flipped = false
      pairsMatched.value++
      flippedIndices.value = []
      isProcessing.value = false
      
      // 检查是否全部消除
      if (pairsMatched.value >= 8) {
        endGame()
      }
    }, 300)
  } else {
    // 匹配失败
    combo.value = 0
    cell1.mismatch = true
    cell2.mismatch = true
    
    setTimeout(() => {
      cell1.flipped = false
      cell2.flipped = false
      cell1.mismatch = false
      cell2.mismatch = false
      flippedIndices.value = []
      isProcessing.value = false
    }, 800)
  }
}

// 计算奖励
const calculateReward = (score) => {
  if (score >= 2000) return 500
  if (score >= 1500) return 300
  if (score >= 1000) return 200
  if (score >= 500) return 100
  return 50
}

// 结束游戏
const endGame = async () => {
  gameState.value = 'ended'
  clearInterval(gameTimer.value)
  
  // 计算奖励
  reward.value = calculateReward(score.value)
  
  // 提交结果
  try {
    const res = await authStore.apiPost('/match-game/submit', {
      gameToken: gameToken.value,
      score: score.value,
      pairs: pairsMatched.value,
      totalPairs: 8
    })
    
    if (res.success) {
      remainingPlays.value = res.remainingPlays
      if (res.spiritStones !== undefined) {
        playerStore.spiritStones = Number(res.spiritStones) || 0
      }
    } else {
      console.error('提交失败:', res.message)
    }
  } catch (e) {
    console.error('提交结果失败:', e)
  }
}

// 重置游戏
const resetGame = () => {
  gameState.value = 'idle'
  fetchStatus()
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
})
</script>

<style scoped>
.matchgame-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #0b0b18 0%, #1a1a2e 50%, #0b0b18 100%);
  padding: 16px;
  box-sizing: border-box;
}

/* 介绍页面样式 */
.intro-section {
  max-width: 480px;
  margin: 0 auto;
  padding-top: 20px;
}

.intro-card {
  background: rgba(20, 20, 35, 0.9);
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(212, 168, 67, 0.3);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5), 0 0 20px rgba(212, 168, 67, 0.1);
}

.title-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin-bottom: 24px;
}

.rune-icon {
  font-size: 32px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.game-title {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843, #ffd700);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
}

.rules-section,
.reward-section {
  margin-bottom: 20px;
}

.rules-section h3,
.reward-section h3 {
  color: #ff6b35;
  font-size: 16px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.rules-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.rules-list li {
  color: #b8b8c8;
  font-size: 14px;
  padding: 6px 0;
  border-bottom: 1px solid rgba(212, 168, 67, 0.1);
}

.rules-list li:last-child {
  border-bottom: none;
}

.rules-list strong {
  color: #ffd700;
}

.reward-tiers {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.reward-tier {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 14px;
  border-radius: 8px;
  background: rgba(212, 168, 67, 0.1);
  border: 1px solid rgba(212, 168, 67, 0.2);
}

.reward-tier.tier-1 { background: linear-gradient(90deg, rgba(255, 107, 53, 0.2), rgba(212, 168, 67, 0.1)); border-color: rgba(255, 107, 53, 0.4); }
.reward-tier.tier-2 { background: linear-gradient(90deg, rgba(212, 168, 67, 0.2), rgba(212, 168, 67, 0.1)); }
.reward-tier.tier-3 { background: linear-gradient(90deg, rgba(212, 168, 67, 0.15), rgba(212, 168, 67, 0.05)); }
.reward-tier.tier-4 { background: linear-gradient(90deg, rgba(212, 168, 67, 0.1), rgba(212, 168, 67, 0.02)); }
.reward-tier.tier-5 { background: rgba(100, 100, 120, 0.1); border-color: rgba(100, 100, 120, 0.2); }

.tier-score {
  color: #ffd700;
  font-weight: 500;
  font-size: 14px;
}

.tier-prize {
  color: #ff6b35;
  font-weight: bold;
  font-size: 14px;
}

.stats-section {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 12px 24px;
  background: rgba(212, 168, 67, 0.1);
  border-radius: 12px;
  border: 1px solid rgba(212, 168, 67, 0.2);
}

.stat-label {
  font-size: 12px;
  color: #888;
}

.stat-value {
  font-size: 20px;
  font-weight: bold;
  color: #ffd700;
}

.stat-value.no-plays {
  color: #ff4444;
}

.start-btn {
  width: 100%;
  padding: 16px;
  font-size: 18px;
  font-weight: bold;
  color: #0b0b18;
  background: linear-gradient(135deg, #d4a843, #ffd700);
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.start-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(212, 168, 67, 0.4);
}

.start-btn:disabled,
.start-btn.disabled {
  background: linear-gradient(135deg, #555, #777);
  cursor: not-allowed;
  opacity: 0.7;
}

/* 游戏页面样式 */
.game-section {
  max-width: 400px;
  margin: 0 auto;
  padding-top: 10px;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding: 0 8px;
}

.score-display,
.combo-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.score-display .label,
.combo-display .label {
  font-size: 11px;
  color: #888;
  text-transform: uppercase;
}

.score-display .value {
  font-size: 24px;
  font-weight: bold;
  color: #ffd700;
}

.combo-display .value {
  font-size: 20px;
  font-weight: bold;
  color: #666;
}

.combo-display .value.combo-active {
  color: #ff6b35;
  animation: comboPulse 0.5s ease;
}

@keyframes comboPulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.3); }
  100% { transform: scale(1); }
}

.timer-circle {
  position: relative;
  width: 70px;
  height: 70px;
}

.timer-svg {
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

.progress-bar {
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
  margin-bottom: 16px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #ff6b35, #ffd700);
  border-radius: 3px;
  transition: width 0.3s ease;
}

/* 游戏网格 */
.game-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  margin-bottom: 16px;
}

.grid-cell {
  aspect-ratio: 1;
  cursor: pointer;
  perspective: 1000px;
}

.cell-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transition: transform 0.4s ease;
  transform-style: preserve-3d;
}

.grid-cell.flipped .cell-inner,
.grid-cell.matched .cell-inner {
  transform: rotateY(180deg);
}

.cell-front,
.cell-back {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cell-front {
  background: linear-gradient(135deg, rgba(212, 168, 67, 0.2), rgba(212, 168, 67, 0.05));
  border: 2px solid rgba(212, 168, 67, 0.3);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.cell-back {
  background: linear-gradient(135deg, rgba(255, 107, 53, 0.3), rgba(212, 168, 67, 0.2));
  border: 2px solid rgba(255, 107, 53, 0.5);
  transform: rotateY(180deg);
  box-shadow: 0 4px 12px rgba(255, 107, 53, 0.2);
}

.rune-svg {
  width: 60%;
  height: 60%;
}

.rune-emoji {
  font-size: 32px;
}

.grid-cell.matched .cell-back {
  background: linear-gradient(135deg, rgba(50, 200, 50, 0.3), rgba(50, 200, 50, 0.1));
  border-color: rgba(50, 200, 50, 0.5);
  animation: matchSuccess 0.4s ease forwards;
}

@keyframes matchSuccess {
  0% { transform: rotateY(180deg) scale(1); opacity: 1; }
  50% { transform: rotateY(180deg) scale(1.1); opacity: 1; }
  100% { transform: rotateY(180deg) scale(0); opacity: 0; }
}

.grid-cell.mismatch .cell-back {
  background: linear-gradient(135deg, rgba(255, 50, 50, 0.3), rgba(255, 50, 50, 0.1));
  border-color: rgba(255, 50, 50, 0.5);
  animation: shake 0.4s ease;
}

@keyframes shake {
  0%, 100% { transform: rotateY(180deg) translateX(0); }
  25% { transform: rotateY(180deg) translateX(-5px); }
  75% { transform: rotateY(180deg) translateX(5px); }
}

.pairs-info {
  text-align: center;
  color: #888;
  font-size: 14px;
}

/* 结果页面样式 */
.result-section {
  max-width: 400px;
  margin: 0 auto;
  padding-top: 30px;
}

.result-card {
  background: rgba(20, 20, 35, 0.95);
  border-radius: 20px;
  padding: 28px;
  border: 2px solid rgba(212, 168, 67, 0.4);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.6), 0 0 30px rgba(212, 168, 67, 0.15);
}

.result-title {
  text-align: center;
  font-size: 22px;
  font-weight: bold;
  background: linear-gradient(135deg, #ff6b35, #ffd700);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 24px;
}

.result-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.result-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 14px;
  background: rgba(212, 168, 67, 0.1);
  border-radius: 12px;
}

.result-stat .label {
  font-size: 12px;
  color: #888;
}

.result-stat .value {
  font-size: 18px;
  font-weight: bold;
  color: #ffd700;
}

.result-stat .value.big {
  font-size: 28px;
  color: #ff6b35;
}

.reward-box {
  text-align: center;
  padding: 20px;
  background: linear-gradient(135deg, rgba(255, 107, 53, 0.15), rgba(212, 168, 67, 0.15));
  border-radius: 16px;
  margin-bottom: 20px;
  border: 1px solid rgba(212, 168, 67, 0.3);
}

.reward-label {
  font-size: 14px;
  color: #888;
  margin-bottom: 8px;
}

.reward-amount {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.gem-icon {
  font-size: 28px;
}

.reward-amount .amount {
  font-size: 36px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843, #ffd700);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.reward-amount .unit {
  font-size: 16px;
  color: #ffd700;
}

.remaining-info {
  text-align: center;
  color: #888;
  font-size: 14px;
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
  background: linear-gradient(135deg, #ff6b35, #ff8c42);
  color: white;
}

.play-again-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(255, 107, 53, 0.4);
}

.play-again-btn:disabled,
.play-again-btn.disabled {
  background: linear-gradient(135deg, #555, #777);
  cursor: not-allowed;
  opacity: 0.7;
}

.back-btn {
  background: rgba(212, 168, 67, 0.2);
  color: #d4a843;
  border: 1px solid rgba(212, 168, 67, 0.4);
}

.back-btn:hover {
  background: rgba(212, 168, 67, 0.3);
}
</style>
