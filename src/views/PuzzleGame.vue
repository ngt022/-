<template>
  <div class="puzzle-game">
    <!-- 背景装饰 -->
    <div class="bg-decoration">
      <svg class="fire-orb" viewBox="0 0 100 100">
        <defs>
          <radialGradient id="fireGrad" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stop-color="#ff6b35" stop-opacity="0.3"/>
            <stop offset="100%" stop-color="#ff6b35" stop-opacity="0"/>
          </radialGradient>
        </defs>
        <circle cx="50" cy="50" r="40" fill="url(#fireGrad)"/>
      </svg>
    </div>

    <!-- 头部标题 -->
    <div class="game-header">
      <h1 class="title">🔥 五行拼图</h1>
      <p class="subtitle">滑动符文，还原秩序</p>
    </div>

    <!-- 状态：未开始 -->
    <div v-if="gameState === 'idle'" class="game-section">
      <div class="rules-card">
        <h3>📜 游戏规则</h3>
        <ul>
          <li>3×3 网格，8个符文块 + 1个空位</li>
          <li>点击空位相邻的符文块来移动</li>
          <li>目标：按顺序排列所有符文</li>
          <li>步数越少，奖励越丰厚</li>
        </ul>
        
        <div class="rune-legend">
          <h4>五行符文</h4>
          <div class="runes-row">
            <span class="rune-item"><span class="rune-icon metal">🔱</span>金</span>
            <span class="rune-item"><span class="rune-icon wood">🌿</span>木</span>
            <span class="rune-item"><span class="rune-icon water">💧</span>水</span>
            <span class="rune-item"><span class="rune-icon fire">🔥</span>火</span>
          </div>
          <div class="runes-row">
            <span class="rune-item"><span class="rune-icon earth">🪨</span>土</span>
            <span class="rune-item"><span class="rune-icon wind">🌀</span>风</span>
            <span class="rune-item"><span class="rune-icon thunder">⚡</span>雷</span>
            <span class="rune-item"><span class="rune-icon light">✨</span>光</span>
          </div>
        </div>

        <div class="rewards-table">
          <h4>🏆 奖励规则</h4>
          <div class="reward-row reward-gold"><span>≤20步</span><span>500 焰晶</span></div>
          <div class="reward-row reward-silver"><span>≤30步</span><span>300 焰晶</span></div>
          <div class="reward-row reward-bronze"><span>≤50步</span><span>200 焰晶</span></div>
          <div class="reward-row"><span>≤80步</span><span>100 焰晶</span></div>
          <div class="reward-row"><span>>80步</span><span>50 焰晶</span></div>
        </div>
      </div>

      <div class="daily-status">
        <p>今日剩余次数: <span :class="remainingPlays > 0 ? 'has-plays' : 'no-plays'">{{ remainingPlays }}/3</span></p>
      </div>

      <button 
        class="start-btn" 
        :disabled="remainingPlays <= 0 || isLoading"
        @click="startGame"
      >
        <span v-if="isLoading">启动中...</span>
        <span v-else-if="remainingPlays <= 0">今日次数已用完</span>
        <span v-else>开始挑战</span>
      </button>
    </div>

    <!-- 状态：游戏中 -->
    <div v-if="gameState === 'playing'" class="game-section">
      <div class="game-stats">
        <div class="stat-box">
          <span class="stat-label">⏱️ 时间</span>
          <span class="stat-value">{{ formatTime }}</span>
        </div>
        <div class="stat-box">
          <span class="stat-label">👣 步数</span>
          <span class="stat-value">{{ moves }}</span>
        </div>
        <div class="stat-box">
          <span class="stat-label">🎯 目标</span>
          <span class="stat-value">≤20步</span>
        </div>
      </div>

      <div class="puzzle-board">
        <div class="grid-container">
          <div
            v-for="(tile, index) in tiles"
            :key="index"
            class="tile"
            :class="{
              'tile-empty': tile === 0,
              'tile-metal': tile === 1,
              'tile-wood': tile === 2,
              'tile-water': tile === 3,
              'tile-fire': tile === 4,
              'tile-earth': tile === 5,
              'tile-wind': tile === 6,
              'tile-thunder': tile === 7,
              'tile-light': tile === 8
            }"
            :style="getTilePosition(index)"
            @click="handleTileClick(index)"
          >
            <template v-if="tile !== 0">
              <span class="tile-number">{{ tile }}</span>
              <span class="tile-rune">{{ runeSymbols[tile - 1] }}</span>
            </template>
          </div>
        </div>
      </div>

      <div class="game-controls">
        <button class="control-btn give-up" @click="giveUp">放弃挑战</button>
        <button class="control-btn hint" @click="showHint = !showHint">
          {{ showHint ? '隐藏提示' : '显示提示' }}
        </button>
      </div>

      <!-- 目标状态提示 -->
      <div v-if="showHint" class="hint-section">
        <p class="hint-title">目标排列:</p>
        <div class="hint-grid">
          <div v-for="n in 9" :key="n" class="hint-tile" :class="{ 'hint-empty': n === 9 }">
            <template v-if="n < 9">
              <span class="hint-number">{{ n }}</span>
              <span class="hint-rune">{{ runeSymbols[n - 1] }}</span>
            </template>
          </div>
        </div>
      </div>
    </div>

    <!-- 状态：结束 -->
    <div v-if="gameState === 'ended'" class="game-section">
      <div class="result-card" :class="resultClass">
        <div class="result-icon">{{ resultIcon }}</div>
        <h2 class="result-title">{{ resultTitle }}</h2>
        
        <div class="result-stats">
          <div class="result-stat">
            <span class="result-label">用时</span>
            <span class="result-value">{{ formatTime }}</span>
          </div>
          <div class="result-stat">
            <span class="result-label">步数</span>
            <span class="result-value">{{ moves }}</span>
          </div>
        </div>

        <div v-if="completed" class="reward-display">
          <p class="reward-label">获得奖励</p>
          <p class="reward-amount">+{{ reward }} 焰晶</p>
        </div>

        <div class="daily-status ended">
          <p>今日剩余次数: <span :class="remainingPlays > 0 ? 'has-plays' : 'no-plays'">{{ remainingPlays }}/3</span></p>
        </div>
      </div>

      <div class="result-actions">
        <button 
          v-if="remainingPlays > 0"
          class="start-btn" 
          :disabled="isLoading"
          @click="startGame"
        >
          <span v-if="isLoading">启动中...</span>
          <span v-else>再玩一次</span>
        </button>
        <button class="control-btn" @click="backToRules">返回规则</button>
      </div>
    </div>

    <!-- 错误提示 -->
    <div v-if="errorMsg" class="error-toast">
      <span>{{ errorMsg }}</span>
      <button @click="errorMsg = ''">✕</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'

const authStore = useAuthStore()
const playerStore = usePlayerStore()

// 游戏状态: idle(未开始), playing(游戏中), ended(结束)
const gameState = ref('idle')
const isLoading = ref(false)
const errorMsg = ref('')

// 游戏数据
const gameToken = ref('')
const tiles = ref([1, 2, 3, 4, 5, 6, 7, 8, 0]) // 当前拼图状态
const moves = ref(0)
const timeSeconds = ref(0)
const timer = ref(null)
const remainingPlays = ref(3)
const completed = ref(false)
const reward = ref(0)
const showHint = ref(false)

// 符文符号
const runeSymbols = ['🔱', '🌿', '💧', '🔥', '🪨', '🌀', '⚡', '✨']

// 目标状态 [1,2,3,4,5,6,7,8,0]
const goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0]

// 计算属性
const formatTime = computed(() => {
  const mins = Math.floor(timeSeconds.value / 60)
  const secs = timeSeconds.value % 60
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
})

const resultClass = computed(() => {
  if (!completed.value) return 'failed'
  if (moves.value <= 20) return 'perfect'
  if (moves.value <= 30) return 'excellent'
  if (moves.value <= 50) return 'good'
  return 'completed'
})

const resultIcon = computed(() => {
  if (!completed.value) return '❌'
  if (moves.value <= 20) return '🏆'
  if (moves.value <= 30) return '🥈'
  if (moves.value <= 50) return '🥉'
  return '✅'
})

const resultTitle = computed(() => {
  if (!completed.value) return '挑战失败'
  if (moves.value <= 20) return '完美通关!'
  if (moves.value <= 30) return '表现优异!'
  if (moves.value <= 50) return '干得不错!'
  return '挑战完成'
})

// 获取瓦片位置样式（用于动画）
function getTilePosition(index) {
  const row = Math.floor(index / 3)
  const col = index % 3
  return {
    top: `${row * 33.33}%`,
    left: `${col * 33.33}%`
  }
}

// 检查是否可移动（是否与空位相邻）
function canMove(index) {
  const emptyIndex = tiles.value.indexOf(0)
  const emptyRow = Math.floor(emptyIndex / 3)
  const emptyCol = emptyIndex % 3
  const tileRow = Math.floor(index / 3)
  const tileCol = index % 3

  // 检查是否相邻（上下左右）
  const rowDiff = Math.abs(emptyRow - tileRow)
  const colDiff = Math.abs(emptyCol - tileCol)
  
  return (rowDiff === 1 && colDiff === 0) || (rowDiff === 0 && colDiff === 1)
}

// 处理瓦片点击
function handleTileClick(index) {
  if (gameState.value !== 'playing') return
  if (tiles.value[index] === 0) return // 点击空位无效
  
  if (canMove(index)) {
    const emptyIndex = tiles.value.indexOf(0)
    // 交换位置
    const temp = tiles.value[index]
    tiles.value[index] = tiles.value[emptyIndex]
    tiles.value[emptyIndex] = temp
    moves.value++
    
    // 检查是否完成
    if (checkComplete()) {
      endGame(true)
    }
  }
}

// 检查是否完成
function checkComplete() {
  for (let i = 0; i < 9; i++) {
    if (tiles.value[i] !== goalState[i]) {
      return false
    }
  }
  return true
}

// 计算逆序数
function countInversions(arr) {
  let inversions = 0
  const flat = arr.filter(x => x !== 0) // 去掉空位
  for (let i = 0; i < flat.length; i++) {
    for (let j = i + 1; j < flat.length; j++) {
      if (flat[i] > flat[j]) {
        inversions++
      }
    }
  }
  return inversions
}

// 检查状态是否可解（逆序数为偶数）
function isSolvable(arr) {
  return countInversions(arr) % 2 === 0
}

// 生成可解的随机状态
function generateSolvablePuzzle() {
  let arr
  do {
    // 随机打乱
    arr = [1, 2, 3, 4, 5, 6, 7, 8, 0].sort(() => Math.random() - 0.5)
  } while (!isSolvable(arr))
  return arr
}

// 开始游戏
async function startGame() {
  if (remainingPlays.value <= 0) {
    errorMsg.value = '今日次数已用完，请明日再来'
    return
  }
  
  isLoading.value = true
  errorMsg.value = ''
  
  try {
    const data = await authStore.apiPost('/puzzle-game/start')
    
    gameToken.value = data.gameToken || 'local-token'
    remainingPlays.value = data.remainingPlays || 3
    
    // 初始化游戏
    tiles.value = generateSolvablePuzzle()
    moves.value = 0
    timeSeconds.value = 0
    completed.value = false
    reward.value = 0
    showHint.value = false
    
    // 开始计时
    gameState.value = 'playing'
    timer.value = setInterval(() => {
      timeSeconds.value++
    }, 1000)
    
  } catch (err) {
    errorMsg.value = err.message || '启动游戏失败'
  } finally {
    isLoading.value = false
  }
}

// 结束游戏
async function endGame(isCompleted) {
  // 停止计时
  if (timer.value) {
    clearInterval(timer.value)
    timer.value = null
  }
  
  completed.value = isCompleted
  
  // 计算奖励
  if (isCompleted) {
    if (moves.value <= 20) reward.value = 500
    else if (moves.value <= 30) reward.value = 300
    else if (moves.value <= 50) reward.value = 200
    else if (moves.value <= 80) reward.value = 100
    else reward.value = 50
  } else {
    reward.value = 0
  }
  
  gameState.value = 'ended'
  
  // 提交结果
  try {
    const data = await authStore.apiPost('/puzzle-game/submit', {
      gameToken: gameToken.value,
      moves: moves.value,
      timeSeconds: timeSeconds.value,
      completed: isCompleted
    })
    
    remainingPlays.value = data.remainingPlays || 0
    
    // 更新玩家焰晶
    if (data.spiritStones !== undefined) {
      playerStore.spiritStones = Number(data.spiritStones) || 0
    }
  } catch (err) {
    console.error('提交结果失败:', err)
    // 本地更新剩余次数
    remainingPlays.value = Math.max(0, remainingPlays.value - 1)
  }
}

// 放弃挑战
function giveUp() {
  if (confirm('确定要放弃当前挑战吗？')) {
    endGame(false)
  }
}

// 返回规则页面
function backToRules() {
  gameState.value = 'idle'
  errorMsg.value = ''
}

// 获取游戏状态
async function fetchStatus() {
  try {
    const data = await authStore.apiGet('/puzzle-game/status')
    remainingPlays.value = data.remainingPlays || 3
  } catch (err) {
    console.error('获取状态失败:', err)
    remainingPlays.value = 3
  }
}

// 生命周期
onMounted(() => {
  fetchStatus()
})

onUnmounted(() => {
  if (timer.value) {
    clearInterval(timer.value)
  }
})
</script>

<style scoped>
.puzzle-game {
  min-height: 100vh;
  background: linear-gradient(135deg, #0b0b18 0%, #1a1a2e 50%, #0b0b18 100%);
  padding: 20px;
  position: relative;
  overflow-x: hidden;
}

.bg-decoration {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 600px;
  height: 600px;
  pointer-events: none;
  z-index: 0;
}

.fire-orb {
  width: 100%;
  height: 100%;
  animation: pulse 4s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 0.5; }
  50% { transform: scale(1.1); opacity: 0.8; }
}

.game-header {
  text-align: center;
  margin-bottom: 24px;
  position: relative;
  z-index: 1;
}

.title {
  font-size: 28px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 50%, #d4a843 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0 0 8px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.subtitle {
  color: #888;
  font-size: 14px;
  margin: 0;
}

.game-section {
  max-width: 400px;
  margin: 0 auto;
  position: relative;
  z-index: 1;
}

/* 规则卡片 */
.rules-card {
  background: linear-gradient(135deg, rgba(212, 168, 67, 0.1) 0%, rgba(255, 107, 53, 0.05) 100%);
  border: 1px solid rgba(212, 168, 67, 0.3);
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 16px;
}

.rules-card h3 {
  color: #d4a843;
  font-size: 16px;
  margin: 0 0 12px 0;
  text-align: center;
}

.rules-card ul {
  color: #ccc;
  font-size: 13px;
  line-height: 1.8;
  margin: 0 0 16px 0;
  padding-left: 20px;
}

.rules-card li {
  margin-bottom: 4px;
}

.rune-legend {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
  padding: 12px;
  margin-bottom: 16px;
}

.rune-legend h4 {
  color: #d4a843;
  font-size: 14px;
  margin: 0 0 10px 0;
  text-align: center;
}

.runes-row {
  display: flex;
  justify-content: space-around;
  margin-bottom: 8px;
}

.runes-row:last-child {
  margin-bottom: 0;
}

.rune-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  color: #aaa;
  font-size: 12px;
}

.rune-icon {
  font-size: 20px;
  margin-bottom: 2px;
}

.rewards-table {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 12px;
  padding: 12px;
}

.rewards-table h4 {
  color: #d4a843;
  font-size: 14px;
  margin: 0 0 10px 0;
  text-align: center;
}

.reward-row {
  display: flex;
  justify-content: space-between;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 13px;
  color: #ccc;
  margin-bottom: 4px;
}

.reward-row:last-child {
  margin-bottom: 0;
}

.reward-gold {
  background: linear-gradient(90deg, rgba(255, 215, 0, 0.2) 0%, rgba(255, 215, 0, 0.05) 100%);
  color: #ffd700;
}

.reward-silver {
  background: linear-gradient(90deg, rgba(192, 192, 192, 0.2) 0%, rgba(192, 192, 192, 0.05) 100%);
  color: #c0c0c0;
}

.reward-bronze {
  background: linear-gradient(90deg, rgba(205, 127, 50, 0.2) 0%, rgba(205, 127, 50, 0.05) 100%);
  color: #cd7f32;
}

/* 每日状态 */
.daily-status {
  text-align: center;
  margin-bottom: 16px;
}

.daily-status p {
  color: #888;
  font-size: 14px;
  margin: 0;
}

.has-plays {
  color: #4ade80;
  font-weight: bold;
}

.no-plays {
  color: #ef4444;
  font-weight: bold;
}

/* 按钮 */
.start-btn {
  width: 100%;
  padding: 16px 24px;
  font-size: 16px;
  font-weight: bold;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 100%);
  color: #0b0b18;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(212, 168, 67, 0.4);
}

.start-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(212, 168, 67, 0.5);
}

.start-btn:disabled {
  background: linear-gradient(135deg, #555 0%, #333 100%);
  color: #888;
  cursor: not-allowed;
  box-shadow: none;
}

/* 游戏中状态 */
.game-stats {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 20px;
}

.stat-box {
  flex: 1;
  background: linear-gradient(135deg, rgba(212, 168, 67, 0.15) 0%, rgba(255, 107, 53, 0.1) 100%);
  border: 1px solid rgba(212, 168, 67, 0.2);
  border-radius: 12px;
  padding: 12px 8px;
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 11px;
  color: #888;
  margin-bottom: 4px;
}

.stat-value {
  display: block;
  font-size: 18px;
  font-weight: bold;
  color: #d4a843;
}

/* 拼图板 */
.puzzle-board {
  background: linear-gradient(135deg, rgba(0, 0, 0, 0.4) 0%, rgba(0, 0, 0, 0.2) 100%);
  border: 2px solid rgba(212, 168, 67, 0.3);
  border-radius: 16px;
  padding: 12px;
  margin-bottom: 16px;
}

.grid-container {
  position: relative;
  width: 100%;
  padding-bottom: 100%; /* 1:1 比例 */
}

.tile {
  position: absolute;
  width: 31%;
  height: 31%;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 
    inset 0 1px 0 rgba(255, 255, 255, 0.2),
    0 4px 8px rgba(0, 0, 0, 0.3),
    0 2px 4px rgba(0, 0, 0, 0.2);
}

.tile:hover:not(.tile-empty) {
  transform: scale(1.02);
  box-shadow: 
    inset 0 1px 0 rgba(255, 255, 255, 0.3),
    0 6px 12px rgba(0, 0, 0, 0.4),
    0 3px 6px rgba(0, 0, 0, 0.3);
}

.tile-number {
  font-size: 12px;
  font-weight: bold;
  color: rgba(255, 255, 255, 0.6);
  position: absolute;
  top: 4px;
  left: 6px;
}

.tile-rune {
  font-size: 28px;
}

/* 空位 */
.tile-empty {
  background: transparent;
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
  cursor: default;
}

/* 各元素样式 */
.tile-metal {
  background: linear-gradient(135deg, #4a5568 0%, #2d3748 50%, #1a202c 100%);
  border: 1px solid rgba(160, 174, 192, 0.4);
}

.tile-wood {
  background: linear-gradient(135deg, #2f855a 0%, #276749 50%, #22543d 100%);
  border: 1px solid rgba(104, 211, 145, 0.4);
}

.tile-water {
  background: linear-gradient(135deg, #2b6cb0 0%, #2c5282 50%, #2a4365 100%);
  border: 1px solid rgba(99, 179, 237, 0.4);
}

.tile-fire {
  background: linear-gradient(135deg, #c53030 0%, #9b2c2c 50%, #742a2a 100%);
  border: 1px solid rgba(252, 129, 129, 0.4);
}

.tile-earth {
  background: linear-gradient(135deg, #744210 0%, #553c9a 0%, #5F4B32 50%, #3E3221 100%);
  background: linear-gradient(135deg, #744210 0%, #5F4B32 50%, #3E3221 100%);
  border: 1px solid rgba(214, 158, 46, 0.4);
}

.tile-wind {
  background: linear-gradient(135deg, #319795 0%, #2c7a7b 50%, #285e61 100%);
  border: 1px solid rgba(129, 230, 217, 0.4);
}

.tile-thunder {
  background: linear-gradient(135deg, #6b46c1 0%, #553c9a 50%, #44337a 100%);
  border: 1px solid rgba(183, 148, 244, 0.4);
}

.tile-light {
  background: linear-gradient(135deg, #d69e2e 0%, #b7791f 50%, #975a16 100%);
  border: 1px solid rgba(246, 224, 94, 0.4);
}

/* 游戏控制 */
.game-controls {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.control-btn {
  flex: 1;
  padding: 12px;
  font-size: 14px;
  border: 1px solid rgba(212, 168, 67, 0.4);
  border-radius: 10px;
  background: rgba(212, 168, 67, 0.1);
  color: #d4a843;
  cursor: pointer;
  transition: all 0.3s ease;
}

.control-btn:hover {
  background: rgba(212, 168, 67, 0.2);
  border-color: rgba(212, 168, 67, 0.6);
}

.control-btn.give-up {
  border-color: rgba(239, 68, 68, 0.4);
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}

.control-btn.give-up:hover {
  background: rgba(239, 68, 68, 0.2);
  border-color: rgba(239, 68, 68, 0.6);
}

/* 提示区域 */
.hint-section {
  background: rgba(0, 0, 0, 0.3);
  border-radius: 12px;
  padding: 16px;
  text-align: center;
}

.hint-title {
  color: #888;
  font-size: 13px;
  margin: 0 0 12px 0;
}

.hint-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
  max-width: 180px;
  margin: 0 auto;
}

.hint-tile {
  aspect-ratio: 1;
  background: linear-gradient(135deg, rgba(212, 168, 67, 0.2) 0%, rgba(255, 107, 53, 0.1) 100%);
  border: 1px solid rgba(212, 168, 67, 0.3);
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.hint-empty {
  background: rgba(0, 0, 0, 0.2);
  border-color: rgba(255, 255, 255, 0.1);
}

.hint-number {
  font-size: 8px;
  color: rgba(255, 255, 255, 0.4);
  position: absolute;
  top: 2px;
  left: 4px;
}

.hint-rune {
  font-size: 16px;
}

/* 结果卡片 */
.result-card {
  background: linear-gradient(135deg, rgba(212, 168, 67, 0.1) 0%, rgba(255, 107, 53, 0.05) 100%);
  border: 2px solid rgba(212, 168, 67, 0.3);
  border-radius: 20px;
  padding: 32px 24px;
  text-align: center;
  margin-bottom: 20px;
}

.result-card.perfect {
  border-color: #ffd700;
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.15) 0%, rgba(255, 107, 53, 0.05) 100%);
  box-shadow: 0 0 30px rgba(255, 215, 0, 0.2);
}

.result-card.excellent {
  border-color: #c0c0c0;
  background: linear-gradient(135deg, rgba(192, 192, 192, 0.15) 0%, rgba(255, 107, 53, 0.05) 100%);
}

.result-card.good {
  border-color: #cd7f32;
  background: linear-gradient(135deg, rgba(205, 127, 50, 0.15) 0%, rgba(255, 107, 53, 0.05) 100%);
}

.result-card.completed {
  border-color: #4ade80;
  background: linear-gradient(135deg, rgba(74, 222, 128, 0.1) 0%, rgba(255, 107, 53, 0.05) 100%);
}

.result-card.failed {
  border-color: #ef4444;
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.1) 0%, rgba(255, 107, 53, 0.05) 100%);
}

.result-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.result-title {
  font-size: 22px;
  font-weight: bold;
  color: #d4a843;
  margin: 0 0 20px 0;
}

.result-stats {
  display: flex;
  justify-content: center;
  gap: 32px;
  margin-bottom: 20px;
}

.result-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.result-label {
  font-size: 12px;
  color: #888;
  margin-bottom: 4px;
}

.result-value {
  font-size: 24px;
  font-weight: bold;
  color: #fff;
}

.reward-display {
  background: linear-gradient(90deg, rgba(212, 168, 67, 0.2) 0%, rgba(255, 107, 53, 0.2) 100%);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.reward-label {
  font-size: 13px;
  color: #888;
  margin: 0 0 4px 0;
}

.reward-amount {
  font-size: 28px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
}

.result-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 错误提示 */
.error-toast {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(239, 68, 68, 0.95);
  color: white;
  padding: 12px 20px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
  z-index: 1000;
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    transform: translateX(-50%) translateY(20px);
    opacity: 0;
  }
  to {
    transform: translateX(-50%) translateY(0);
    opacity: 1;
  }
}

.error-toast button {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  font-size: 14px;
  padding: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 移动端适配 */
@media (max-width: 480px) {
  .puzzle-game {
    padding: 16px;
  }
  
  .title {
    font-size: 24px;
  }
  
  .game-section {
    max-width: 100%;
  }
  
  .rules-card {
    padding: 16px;
  }
  
  .tile-rune {
    font-size: 24px;
  }
  
  .tile-number {
    font-size: 10px;
  }
  
  .stat-value {
    font-size: 16px;
  }
}
</style>
