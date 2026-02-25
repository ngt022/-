<template>
  <div class="wheel-game-page">
    <!-- 顶部标题 -->
    <div class="game-header">
      <h1 class="game-title">
        <span class="fire-icon">🔥</span>
        焰灵转盘
        <span class="fire-icon">🔥</span>
      </h1>
      <p class="game-subtitle">转动命运之轮，赢取丰厚奖励</p>
    </div>

    <!-- 转盘区域 -->
    <div class="wheel-container">
      <!-- 顶部指针 -->
      <div class="wheel-pointer">
        <svg viewBox="0 0 40 30" width="40" height="30">
          <polygon points="20,0 40,30 0,30" fill="#ff6b35" stroke="#d4a843" stroke-width="2"/>
        </svg>
      </div>

      <!-- 转盘主体 -->
      <div class="wheel-wrapper" ref="wheelWrapper">
        <!-- 旋转层（canvas+文字一起转） -->
        <div 
          class="wheel-rotate-layer" 
          ref="rotateLayer"
          :style="{ transform: `rotate(${rotation}deg)` }"
        >
          <canvas ref="wheelCanvas" class="wheel-canvas"></canvas>
          <!-- 扇区内容 -->
          <div 
            v-for="(prize, index) in prizes" 
            :key="index"
            class="prize-item"
            :style="getPrizeStyle(index)"
          >
            <span class="prize-icon">{{ prize.icon }}</span>
            <span class="prize-name">{{ prize.name }}</span>
          </div>
        </div>
        <!-- 转盘边框装饰 -->
        <div class="wheel-border"></div>
      </div>

      <!-- 中间按钮 -->
      <button 
        class="spin-btn" 
        @click="spin"
        :disabled="isSpinning || remainingSpins === 0 || loading"
      >
        <div class="spin-btn-inner">
          <span class="spin-text" v-if="!isSpinning">
            {{ remainingSpins > 0 ? '开始转动' : '次数用完' }}
          </span>
          <span class="spin-text" v-else>转动中...</span>
        </div>
      </button>
    </div>

    <!-- 次数信息 -->
    <div class="spins-info">
      <div class="info-card">
        <div class="info-row">
          <span class="info-label">今日次数</span>
          <span class="info-value">
            <span :class="{ 'no-spins': remainingSpins === 0 }">{{ usedSpins }}</span>
            <span class="separator">/</span>
            <span>{{ maxSpins }}</span>
          </span>
        </div>
        <div class="info-row">
          <span class="info-label">剩余次数</span>
          <span class="info-value remaining" :class="{ 'no-spins': remainingSpins === 0 }">
            {{ remainingSpins }}
          </span>
        </div>
        <div class="info-row">
          <span class="info-label">本次消耗</span>
          <span class="info-value cost">
            <span v-if="freeSpins > 0" class="free-badge">免费</span>
            <span v-else-if="remainingSpins > 0">
              <span class="crystal-icon">💎</span> {{ spinCost }}
            </span>
            <span v-else>-</span>
          </span>
        </div>
      </div>
    </div>

    <!-- 奖励预览 -->
    <div class="prizes-preview">
      <h3 class="preview-title">🎁 奖励一览</h3>
      <div class="prizes-grid">
        <div 
          v-for="(prize, index) in prizes" 
          :key="index"
          class="prize-card"
          :class="{ 'rare': prize.rare }"
        >
          <span class="prize-emoji">{{ prize.icon }}</span>
          <span class="prize-text">{{ prize.name }}</span>
          <span v-if="prize.rare" class="rare-badge">稀有</span>
        </div>
      </div>
    </div>

    <!-- 规则说明 -->
    <div class="rules-section">
      <h3 class="rules-title">📜 游戏规则</h3>
      <ul class="rules-list">
        <li>每日可免费转动 <strong>1</strong> 次</li>
        <li>额外转动消耗 <strong>200</strong> 焰晶/次</li>
        <li>每日最多转动 <strong>5</strong> 次</li>
        <li>稀有奖励 💎1000焰晶 等你来拿！</li>
      </ul>
    </div>

    <!-- 结果弹窗 -->
    <div v-if="showResult" class="result-modal" @click.self="closeResult">
      <div class="result-content">
        <div class="result-glow"></div>
        <div class="result-icon">{{ resultPrize?.icon }}</div>
        <h2 class="result-title">恭喜获得</h2>
        <div class="result-prize">{{ resultPrize?.name }}</div>
        <button class="result-btn" @click="closeResult">收下奖励</button>
      </div>
    </div>

    <!-- 错误提示 -->
    <div v-if="errorMessage" class="error-toast" @click="errorMessage = ''">
      {{ errorMessage }}
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'

const authStore = useAuthStore()
const playerStore = usePlayerStore()

// 转盘配置
const prizes = [
  { icon: '💎', name: '100焰晶', value: 100, type: 'crystal' },
  { icon: '💎', name: '200焰晶', value: 200, type: 'crystal' },
  { icon: '💎', name: '500焰晶', value: 500, type: 'crystal' },
  { icon: '💎', name: '1000焰晶', value: 1000, type: 'crystal', rare: true },
  { icon: '🔥', name: '焰灵x1000', value: 1000, type: 'spirit' },
  { icon: '🧪', name: '随机丹药', value: 1, type: 'pill' },
  { icon: '💎', name: '50焰晶', value: 50, type: 'crystal' },
  { icon: '💎', name: '150焰晶', value: 150, type: 'crystal' },
]

const sectorCount = 8
const sectorAngle = 360 / sectorCount
const spinCost = 200
const maxSpins = 5

// 状态
const loading = ref(false)
const isSpinning = ref(false)
const rotation = ref(0)
const usedSpins = ref(0)
const freeSpins = ref(0)
const showResult = ref(false)
const resultPrize = ref(null)
const errorMessage = ref('')
const wheelCanvas = ref(null)
const rotateLayer = ref(null)

// 计算属性
const remainingSpins = computed(() => maxSpins - usedSpins.value)

// 获取扇区文字样式
const getPrizeStyle = (index) => {
  const angle = index * sectorAngle + sectorAngle / 2
  const radius = 110 // 距离中心的半径
  const rad = (angle - 90) * Math.PI / 180
  const x = Math.cos(rad) * radius
  const y = Math.sin(rad) * radius
  
  return {
    transform: `translate(${x}px, ${y}px) rotate(${angle}deg)`,
  }
}

// 绘制转盘背景
const drawWheel = () => {
  const canvas = wheelCanvas.value
  if (!canvas) return
  
  const ctx = canvas.getContext('2d')
  const size = 300
  const center = size / 2
  const radius = size / 2 - 10
  
  // 设置canvas尺寸
  canvas.width = size
  canvas.height = size
  
  // 清空画布
  ctx.clearRect(0, 0, size, size)
  
  // 绘制扇区
  for (let i = 0; i < sectorCount; i++) {
    const startAngle = (i * sectorAngle - 90) * Math.PI / 180
    const endAngle = ((i + 1) * sectorAngle - 90) * Math.PI / 180
    
    ctx.beginPath()
    ctx.moveTo(center, center)
    ctx.arc(center, center, radius, startAngle, endAngle)
    ctx.closePath()
    
    // 交替颜色：深红/暗金
    if (i % 2 === 0) {
      ctx.fillStyle = '#8B1a1a' // 深红
    } else {
      ctx.fillStyle = '#8B6914' // 暗金
    }
    ctx.fill()
    
    // 绘制边框
    ctx.strokeStyle = '#d4a843'
    ctx.lineWidth = 2
    ctx.stroke()
  }
  
  // 绘制外圈装饰
  ctx.beginPath()
  ctx.arc(center, center, radius + 5, 0, Math.PI * 2)
  ctx.strokeStyle = '#d4a843'
  ctx.lineWidth = 3
  ctx.stroke()
  
  // 绘制内圈
  ctx.beginPath()
  ctx.arc(center, center, 50, 0, Math.PI * 2)
  ctx.fillStyle = '#0b0b18'
  ctx.fill()
  ctx.strokeStyle = '#d4a843'
  ctx.lineWidth = 2
  ctx.stroke()
}

// 获取游戏状态
const fetchStatus = async () => {
  try {
    const res = await authStore.apiGet('/wheel-game/status')
    if (res.success) {
      usedSpins.value = res.usedSpins || 0
      freeSpins.value = res.freeSpins || Math.max(0, 1 - usedSpins.value)
    }
  } catch (e) {
    console.error('获取状态失败:', e)
    showError('获取游戏状态失败')
  }
}

// 转动转盘
const spin = async () => {
  if (isSpinning.value || remainingSpins.value === 0) return
  
  loading.value = true
  try {
    const res = await authStore.apiPost('/wheel-game/spin')
    if (res.success) {
      // 更新状态
      usedSpins.value = res.usedSpins || usedSpins.value + 1
      freeSpins.value = res.freeSpins || Math.max(0, freeSpins.value - 1)
      
      // 开始动画
      startSpinAnimation(res.sectorIndex, res.prize)
    } else {
      showError(res.message || '转动失败')
    }
  } catch (e) {
    console.error('转动失败:', e)
    showError(e.message || '转动失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

// 开始旋转动画
const startSpinAnimation = (targetIndex, prize) => {
  isSpinning.value = true
  
  // 计算目标角度
  // 指针在顶部(0度)，canvas绘制时sector 0从-90度(顶部)开始
  // 要让sector N的中心对准指针，需要转: -(N * sectorAngle + sectorAngle/2)
  const targetSectorCenter = targetIndex * sectorAngle + sectorAngle / 2
  
  // 归一化当前角度
  const currentMod = rotation.value % 360
  // 目标绝对角度(负方向转到目标扇区中心)
  const targetAngle = 360 - targetSectorCenter
  
  // 至少转5圈 + 随机1-3圈
  const extraSpins = 5 + Math.floor(Math.random() * 3)
  const targetRotation = Math.floor(rotation.value / 360) * 360 + extraSpins * 360 + targetAngle
  
  // 设置动画
  rotation.value = targetRotation
  
  // 3.5秒后显示结果
  setTimeout(() => {
    isSpinning.value = false
    resultPrize.value = prize
    showResult.value = true
    
    // 更新玩家数据
    if (prize.type === 'crystal') {
      playerStore.spiritStones = (playerStore.spiritStones || 0) + prize.value
    } else if (prize.type === 'spirit') {
      playerStore.spirit = (playerStore.spirit || 0) + prize.value
    }
  }, 3500)
}

// 显示错误
const showError = (msg) => {
  errorMessage.value = msg
  setTimeout(() => {
    errorMessage.value = ''
  }, 3000)
}

// 关闭结果
const closeResult = () => {
  showResult.value = false
  resultPrize.value = null
}

onMounted(() => {
  drawWheel()
  fetchStatus()
  
  // 窗口大小改变时重绘
  window.addEventListener('resize', drawWheel)
})

onUnmounted(() => {
  window.removeEventListener('resize', drawWheel)
})
</script>

<style scoped>
.wheel-game-page {
  min-height: 100vh;
  background: #0b0b18;
  padding: 20px;
  color: #fff;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* 顶部标题 */
.game-header {
  text-align: center;
  margin-bottom: 20px;
}

.game-title {
  font-size: 24px;
  font-weight: bold;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  background: linear-gradient(135deg, #ff6b35 0%, #ffd700 50%, #ff6b35 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.fire-icon {
  font-size: 24px;
  animation: flame-flicker 1.5s ease-in-out infinite;
  -webkit-text-fill-color: initial;
}

@keyframes flame-flicker {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.1); opacity: 0.8; }
}

.game-subtitle {
  font-size: 14px;
  color: #888;
  margin: 0;
}

/* 转盘容器 */
.wheel-container {
  position: relative;
  width: 320px;
  height: 320px;
  margin-bottom: 20px;
}

/* 顶部指针 */
.wheel-pointer {
  position: absolute;
  top: -15px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 10;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.5));
}

/* 转盘主体 */
.wheel-wrapper {
  position: relative;
  width: 300px;
  height: 300px;
  margin: 20px auto 0;
}

.wheel-canvas {
  position: absolute;
  top: 0;
  left: 0;
  width: 300px;
  height: 300px;
}

.wheel-rotate-layer {
  position: absolute;
  top: 0;
  left: 0;
  width: 300px;
  height: 300px;
  border-radius: 50%;
  transition: transform 3.5s cubic-bezier(0.25, 0.1, 0.25, 1);
}

.wheel-border {
  position: absolute;
  top: -5px;
  left: -5px;
  right: -5px;
  bottom: -5px;
  border: 3px solid #d4a843;
  border-radius: 50%;
  box-shadow: 
    0 0 20px rgba(212, 168, 67, 0.3),
    inset 0 0 20px rgba(0,0,0,0.5);
  pointer-events: none;
}

/* 扇区奖品文字 */
.prize-item {
  position: absolute;
  top: 50%;
  left: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  transform-origin: center center;
  margin-left: -30px;
  margin-top: -20px;
  width: 60px;
  height: 40px;
  text-align: center;
}

.prize-icon {
  font-size: 20px;
  margin-bottom: 2px;
}

.prize-name {
  font-size: 10px;
  color: #fff;
  text-shadow: 0 1px 2px rgba(0,0,0,0.8);
  white-space: nowrap;
  font-weight: bold;
}

/* 中间按钮 */
.spin-btn {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80px;
  height: 80px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 100%);
  cursor: pointer;
  z-index: 20;
  box-shadow: 
    0 0 20px rgba(212, 168, 67, 0.6),
    0 0 40px rgba(212, 168, 67, 0.3),
    inset 0 -3px 10px rgba(0,0,0,0.3);
  transition: all 0.3s ease;
}

.spin-btn:hover:not(:disabled) {
  transform: translate(-50%, -50%) scale(1.05);
  box-shadow: 
    0 0 30px rgba(212, 168, 67, 0.8),
    0 0 60px rgba(255, 107, 53, 0.4),
    inset 0 -3px 10px rgba(0,0,0,0.3);
}

.spin-btn:disabled {
  background: linear-gradient(135deg, #444 0%, #333 100%);
  box-shadow: none;
  cursor: not-allowed;
}

.spin-btn-inner {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, transparent 50%);
}

.spin-text {
  font-size: 14px;
  font-weight: bold;
  color: #0b0b18;
  text-align: center;
  line-height: 1.2;
}

.spin-btn:disabled .spin-text {
  color: #666;
}

/* 次数信息 */
.spins-info {
  width: 100%;
  max-width: 320px;
  margin-bottom: 20px;
}

.info-card {
  background: linear-gradient(145deg, #1a1a2e 0%, #0f0f1a 100%);
  border-radius: 12px;
  padding: 15px 20px;
  border: 1px solid rgba(212, 168, 67, 0.2);
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid rgba(255,255,255,0.05);
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 14px;
  color: #888;
}

.info-value {
  font-size: 16px;
  font-weight: bold;
  color: #d4a843;
}

.info-value .no-spins {
  color: #ff6b35;
}

.info-value .separator {
  margin: 0 4px;
  color: #666;
}

.info-value.remaining {
  color: #ffd700;
}

.info-value.remaining.no-spins {
  color: #ff6b35;
}

.info-value.cost {
  display: flex;
  align-items: center;
  gap: 4px;
}

.free-badge {
  background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%);
  color: #fff;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.crystal-icon {
  font-size: 14px;
}

/* 奖励预览 */
.prizes-preview {
  width: 100%;
  max-width: 320px;
  margin-bottom: 20px;
}

.preview-title {
  font-size: 16px;
  color: #d4a843;
  margin: 0 0 12px 0;
  text-align: center;
}

.prizes-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}

.prize-card {
  background: rgba(255,255,255,0.05);
  border-radius: 8px;
  padding: 10px 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  border: 1px solid rgba(212, 168, 67, 0.1);
  position: relative;
}

.prize-card.rare {
  border-color: rgba(255, 107, 53, 0.4);
  background: rgba(255, 107, 53, 0.1);
}

.prize-emoji {
  font-size: 20px;
}

.prize-text {
  font-size: 10px;
  color: #ccc;
  text-align: center;
}

.rare-badge {
  position: absolute;
  top: -4px;
  right: -4px;
  background: #ff6b35;
  color: #fff;
  font-size: 8px;
  padding: 1px 4px;
  border-radius: 4px;
}

/* 规则说明 */
.rules-section {
  width: 100%;
  max-width: 320px;
}

.rules-title {
  font-size: 16px;
  color: #d4a843;
  margin: 0 0 12px 0;
}

.rules-list {
  list-style: none;
  padding: 0;
  margin: 0;
  background: rgba(255,255,255,0.03);
  border-radius: 8px;
  padding: 12px 16px;
}

.rules-list li {
  font-size: 13px;
  color: #aaa;
  padding: 6px 0;
  line-height: 1.5;
}

.rules-list li strong {
  color: #ffd700;
}

/* 结果弹窗 */
.result-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.result-content {
  background: linear-gradient(145deg, #1a1a2e 0%, #0f0f1a 100%);
  border-radius: 20px;
  padding: 40px 30px;
  text-align: center;
  border: 2px solid rgba(212, 168, 67, 0.3);
  position: relative;
  min-width: 250px;
  animation: result-pop 0.3s ease-out;
}

@keyframes result-pop {
  0% { transform: scale(0.8); opacity: 0; }
  100% { transform: scale(1); opacity: 1; }
}

.result-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(255, 107, 53, 0.3) 0%, transparent 70%);
  pointer-events: none;
}

.result-icon {
  font-size: 60px;
  margin-bottom: 15px;
  animation: icon-bounce 0.5s ease-out;
}

@keyframes icon-bounce {
  0% { transform: scale(0); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

.result-title {
  font-size: 18px;
  color: #888;
  margin: 0 0 10px 0;
}

.result-prize {
  font-size: 24px;
  font-weight: bold;
  color: #ffd700;
  margin-bottom: 25px;
}

.result-btn {
  padding: 12px 40px;
  font-size: 16px;
  font-weight: bold;
  background: linear-gradient(135deg, #d4a843 0%, #ff6b35 100%);
  border: none;
  border-radius: 25px;
  color: #0b0b18;
  cursor: pointer;
  transition: all 0.3s ease;
}

.result-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(212, 168, 67, 0.4);
}

/* 错误提示 */
.error-toast {
  position: fixed;
  bottom: 80px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(255, 107, 53, 0.9);
  color: #fff;
  padding: 12px 24px;
  border-radius: 8px;
  font-size: 14px;
  z-index: 1001;
  animation: slide-up 0.3s ease-out;
}

@keyframes slide-up {
  from { transform: translateX(-50%) translateY(20px); opacity: 0; }
  to { transform: translateX(-50%) translateY(0); opacity: 1; }
}

/* 移动端适配 */
@media (max-width: 375px) {
  .wheel-game-page {
    padding: 15px;
  }
  
  .game-title {
    font-size: 20px;
  }
  
  .wheel-container {
    width: 280px;
    height: 280px;
  }
  
  .wheel-wrapper,
  .wheel-canvas {
    width: 260px;
    height: 260px;
  }
  
  .wheel-rotate-layer {
    width: 260px;
    height: 260px;
  }
  
  .prize-item {
    transform-origin: center center;
    margin-left: -25px;
    margin-top: -18px;
    width: 50px;
    height: 36px;
  }
  
  .prize-icon {
    font-size: 16px;
  }
  
  .prize-name {
    font-size: 9px;
  }
  
  .spin-btn {
    width: 70px;
    height: 70px;
  }
  
  .spin-text {
    font-size: 12px;
  }
  
  .prizes-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: 6px;
  }
  
  .prize-card {
    padding: 8px 2px;
  }
  
  .prize-emoji {
    font-size: 16px;
  }
  
  .prize-text {
    font-size: 9px;
  }
}

@media (max-width: 320px) {
  .wheel-container {
    width: 260px;
    height: 260px;
  }
  
  .wheel-wrapper,
  .wheel-canvas {
    width: 240px;
    height: 240px;
  }
  
  .wheel-rotate-layer {
    width: 240px;
    height: 240px;
  }
}
</style>
