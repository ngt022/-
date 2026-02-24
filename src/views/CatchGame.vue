<template>
  <div class="catch-game-container">
    <!-- 游戏标题 -->
    <div class="game-header">
      <h1 class="game-title">焰灵接龙</h1>
      <div class="score-board">
        <span class="score">得分: {{ score }}</span>
        <span class="lives">生命: <span class="hearts">{{ hearts }}</span></span>
      </div>
    </div>

    <!-- 游戏画布 -->
    <div class="canvas-wrapper">
      <canvas
        ref="gameCanvas"
        :width="canvasWidth"
        :height="canvasHeight"
        @mousemove="handleMouseMove"
        @touchstart="handleTouchStart"
        @touchmove="handleTouchMove"
        @touchend="handleTouchEnd"
      ></canvas>
    </div>

    <!-- 状态遮罩层 -->
    <div v-if="gameState !== 'playing'" class="overlay">
      <div class="overlay-content">
        <h2 v-if="gameState === 'ready'" class="overlay-title">准备好了吗？</h2>
        <h2 v-if="gameState === 'gameOver'" class="overlay-title">游戏结束</h2>
        
        <div v-if="gameState === 'gameOver'" class="final-score">
          <p>最终得分: <span class="highlight">{{ score }}</span></p>
          <p>获得焰晶: <span class="highlight">{{ reward }} 焰晶</span></p>
          <p>接住: {{ caught }} | 漏掉: {{ missed }}</p>
        </div>

        <div class="controls-hint">
          <p>🎮 PC: 方向键 ← → 或鼠标移动</p>
          <p>📱 手机: 触摸滑动</p>
        </div>

        <button class="start-btn" @click="startGame">
          {{ gameState === 'ready' ? '开始游戏' : '再来一局' }}
        </button>
      </div>
    </div>

    <!-- SVG 图标定义 -->
    <svg style="display: none;">
      <!-- 普通焰灵 -->
      <symbol id="flame-normal" viewBox="0 0 40 50">
        <defs>
          <linearGradient id="flameGrad" x1="0%" y1="100%" x2="0%" y2="0%">
            <stop offset="0%" style="stop-color:#ff6b35;stop-opacity:1" />
            <stop offset="50%" style="stop-color:#ff8c42;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#ffd93d;stop-opacity:1" />
          </linearGradient>
          <filter id="flameGlow">
            <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
            <feMerge>
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
        <path d="M20 45 Q10 35 10 20 Q10 5 20 0 Q30 5 30 20 Q30 35 20 45 M15 35 Q12 25 15 15 Q18 25 15 35 M25 35 Q22 25 25 15 Q28 25 25 35" 
              fill="url(#flameGrad)" filter="url(#flameGlow)"/>
      </symbol>

      <!-- 金色焰灵 -->
      <symbol id="flame-gold" viewBox="0 0 40 50">
        <defs>
          <linearGradient id="goldGrad" x1="0%" y1="100%" x2="0%" y2="0%">
            <stop offset="0%" style="stop-color:#d4a843;stop-opacity:1" />
            <stop offset="50%" style="stop-color:#f0d78c;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#fff8dc;stop-opacity:1" />
          </linearGradient>
          <filter id="goldGlow">
            <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
            <feMerge>
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
        <path d="M20 45 Q8 32 8 18 Q8 8 20 0 Q32 8 32 18 Q32 32 20 45 M14 32 Q10 22 14 12 Q18 22 14 32 M26 32 Q22 22 26 12 Q30 22 26 32" 
              fill="url(#goldGrad)" filter="url(#goldGlow)"/>
        <text x="20" y="30" text-anchor="middle" fill="#8b6914" font-size="12" font-weight="bold">★</text>
      </symbol>

      <!-- 接盘 -->
      <symbol id="paddle" viewBox="0 0 100 20">
        <defs>
          <linearGradient id="paddleGrad" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" style="stop-color:#f0d78c;stop-opacity:1" />
            <stop offset="50%" style="stop-color:#d4a843;stop-opacity:1" />
            <stop offset="100%" style="stop-color:#b8941f;stop-opacity:1" />
          </linearGradient>
          <filter id="paddleGlow">
            <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
            <feMerge>
              <feMergeNode in="coloredBlur"/>
              <feMergeNode in="SourceGraphic"/>
            </feMerge>
          </filter>
        </defs>
        <rect x="0" y="5" width="100" height="12" rx="6" fill="url(#paddleGrad)" filter="url(#paddleGlow)"/>
        <rect x="5" y="7" width="90" height="8" rx="4" fill="#fff8dc" opacity="0.3"/>
      </symbol>
    </svg>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'

const authStore = useAuthStore()
const playerStore = usePlayerStore()

// 画布尺寸
const canvasWidth = 350
const canvasHeight = 500

// 游戏状态
const gameState = ref('ready') // 'ready', 'playing', 'gameOver'
const score = ref(0)
const lives = ref(3)
const caught = ref(0)
const missed = ref(0)
const gameToken = ref('')

// 画布引用
const gameCanvas = ref(null)
let ctx = null
let animationId = null
let lastSpawnTime = 0
let gameStartTime = 0

// 游戏对象
const paddle = ref({
  x: canvasWidth / 2 - 50,
  y: canvasHeight - 30,
  width: 100,
  height: 20,
  speed: 0
})

const flames = ref([])
const particles = ref([])

// 触摸控制
const touchStartX = ref(0)
const paddleStartX = ref(0)
const isTouching = ref(false)

// 计算属性
const hearts = computed(() => '❤️'.repeat(lives.value) + '🖤'.repeat(3 - lives.value))

const reward = computed(() => {
  if (score.value >= 800) return 500
  if (score.value >= 500) return 300
  if (score.value >= 300) return 200
  if (score.value >= 100) return 100
  return 50
})

// apiPost 和 apiGet 函数（本地实现，适配项目）
const apiPost = async (url, data = {}) => {
  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    })
    return await response.json()
  } catch (e) {
    console.error('API POST error:', e)
    throw e
  }
}

const apiGet = async (url) => {
  try {
    const response = await fetch(url)
    return await response.json()
  } catch (e) {
    console.error('API GET error:', e)
    throw e
  }
}

// 获取当前速度（随时间递增）
const getCurrentSpeed = () => {
  const elapsed = Date.now() - gameStartTime
  const baseSpeed = 2
  const speedIncrease = Math.min(elapsed / 30000, 3)
  return baseSpeed + speedIncrease + Math.random() * 0.5
}

// 生成焰灵
const spawnFlame = () => {
  const isGold = Math.random() < 0.15
  const flame = {
    x: Math.random() * (canvasWidth - 40) + 20,
    y: -50,
    width: 30,
    height: 40,
    speed: getCurrentSpeed(),
    type: isGold ? 'gold' : 'normal',
    rotation: Math.random() * Math.PI * 2,
    rotationSpeed: (Math.random() - 0.5) * 0.1
  }
  flames.value.push(flame)
}

// 生成拖尾粒子
const spawnParticle = (x, y, type) => {
  const color = type === 'gold' ? '#d4a843' : '#ff6b35'
  for (let i = 0; i < 3; i++) {
    particles.value.push({
      x: x + Math.random() * 20 - 10,
      y: y + Math.random() * 20,
      vx: (Math.random() - 0.5) * 2,
      vy: Math.random() * 2 + 1,
      life: 1,
      decay: 0.03 + Math.random() * 0.02,
      color,
      size: Math.random() * 4 + 2
    })
  }
}

// 绘制火焰形状
const drawFlame = (x, y, width, height, type) => {
  const isGold = type === 'gold'
  
  // 外层光晕
  const outerGradient = ctx.createRadialGradient(x, y + height/2, 0, x, y + height/2, width)
  if (isGold) {
    outerGradient.addColorStop(0, 'rgba(212, 168, 67, 0.8)')
    outerGradient.addColorStop(0.5, 'rgba(240, 215, 140, 0.4)')
    outerGradient.addColorStop(1, 'rgba(212, 168, 67, 0)')
  } else {
    outerGradient.addColorStop(0, 'rgba(255, 107, 53, 0.8)')
    outerGradient.addColorStop(0.5, 'rgba(255, 140, 66, 0.4)')
    outerGradient.addColorStop(1, 'rgba(255, 107, 53, 0)')
  }
  
  ctx.fillStyle = outerGradient
  ctx.beginPath()
  ctx.arc(x, y + height/2, width * 1.2, 0, Math.PI * 2)
  ctx.fill()
  
  // 火焰主体
  const gradient = ctx.createLinearGradient(x, y + height, x, y)
  if (isGold) {
    gradient.addColorStop(0, '#d4a843')
    gradient.addColorStop(0.5, '#f0d78c')
    gradient.addColorStop(1, '#fff8dc')
  } else {
    gradient.addColorStop(0, '#ff6b35')
    gradient.addColorStop(0.5, '#ff8c42')
    gradient.addColorStop(1, '#ffd93d')
  }
  
  ctx.fillStyle = gradient
  ctx.beginPath()
  ctx.moveTo(x, y + height)
  ctx.quadraticCurveTo(x - width/2, y + height/2, x - width/3, y)
  ctx.quadraticCurveTo(x - width/4, y - height/4, x, y - height/6)
  ctx.quadraticCurveTo(x + width/4, y - height/4, x + width/3, y)
  ctx.quadraticCurveTo(x + width/2, y + height/2, x, y + height)
  ctx.fill()
  
  // 内部高光
  ctx.fillStyle = isGold ? 'rgba(255, 248, 220, 0.6)' : 'rgba(255, 217, 61, 0.6)'
  ctx.beginPath()
  ctx.ellipse(x - width/6, y + height/3, width/8, height/4, 0, 0, Math.PI * 2)
  ctx.fill()
  
  // 金色焰灵显示星星
  if (isGold) {
    ctx.fillStyle = '#8b6914'
    ctx.font = 'bold 14px Arial'
    ctx.textAlign = 'center'
    ctx.fillText('★', x, y + height/2 + 5)
  }
}

// 绘制接盘
const drawPaddle = () => {
  const p = paddle.value
  const centerX = p.x + p.width / 2
  const centerY = p.y + p.height / 2
  
  // 发光效果
  const glowGradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, p.width)
  glowGradient.addColorStop(0, 'rgba(212, 168, 67, 0.5)')
  glowGradient.addColorStop(0.7, 'rgba(212, 168, 67, 0.2)')
  glowGradient.addColorStop(1, 'rgba(212, 168, 67, 0)')
  ctx.fillStyle = glowGradient
  ctx.fillRect(p.x - 10, p.y - 5, p.width + 20, p.height + 10)
  
  // 接盘主体
  const gradient = ctx.createLinearGradient(p.x, p.y, p.x, p.y + p.height)
  gradient.addColorStop(0, '#f0d78c')
  gradient.addColorStop(0.5, '#d4a843')
  gradient.addColorStop(1, '#b8941f')
  
  ctx.fillStyle = gradient
  ctx.beginPath()
  ctx.roundRect(p.x, p.y, p.width, p.height, 6)
  ctx.fill()
  
  // 内部高光
  ctx.fillStyle = 'rgba(255, 248, 220, 0.3)'
  ctx.beginPath()
  ctx.roundRect(p.x + 5, p.y + 2, p.width - 10, p.height - 4, 4)
  ctx.fill()
  
  // 边框
  ctx.strokeStyle = '#f0d78c'
  ctx.lineWidth = 1
  ctx.beginPath()
  ctx.roundRect(p.x, p.y, p.width, p.height, 6)
  ctx.stroke()
}

// 绘制函数
const draw = () => {
  if (!ctx) return

  // 清空画布
  ctx.fillStyle = '#0b0b18'
  ctx.fillRect(0, 0, canvasWidth, canvasHeight)

  // 绘制背景网格
  ctx.strokeStyle = 'rgba(212, 168, 67, 0.1)'
  ctx.lineWidth = 1
  for (let i = 0; i < canvasWidth; i += 35) {
    ctx.beginPath()
    ctx.moveTo(i, 0)
    ctx.lineTo(i, canvasHeight)
    ctx.stroke()
  }
  for (let i = 0; i < canvasHeight; i += 35) {
    ctx.beginPath()
    ctx.moveTo(0, i)
    ctx.lineTo(canvasWidth, i)
    ctx.stroke()
  }

  // 绘制拖尾粒子
  particles.value.forEach(p => {
    ctx.globalAlpha = p.life
    ctx.fillStyle = p.color
    ctx.beginPath()
    ctx.arc(p.x, p.y, p.size * p.life, 0, Math.PI * 2)
    ctx.fill()
  })
  ctx.globalAlpha = 1

  // 绘制焰灵
  flames.value.forEach(flame => {
    ctx.save()
    ctx.translate(flame.x + flame.width / 2, flame.y + flame.height / 2)
    ctx.rotate(flame.rotation)
    drawFlame(0, -flame.height / 2, flame.width, flame.height, flame.type)
    ctx.restore()
  })

  // 绘制接盘
  drawPaddle()
}

// 更新游戏逻辑
const update = () => {
  if (gameState.value !== 'playing') return

  const now = Date.now()

  // 生成新焰灵
  const spawnInterval = Math.max(1000 - (now - gameStartTime) / 100, 400)
  if (now - lastSpawnTime > spawnInterval) {
    spawnFlame()
    lastSpawnTime = now
  }

  // 更新焰灵
  flames.value = flames.value.filter(flame => {
    flame.y += flame.speed
    flame.rotation += flame.rotationSpeed
    
    // 生成拖尾
    if (Math.random() < 0.3) {
      spawnParticle(flame.x + flame.width / 2, flame.y + flame.height, flame.type)
    }

    // 检查碰撞（接住）
    const paddleCenter = paddle.value.x + paddle.value.width / 2
    const flameCenter = flame.x + flame.width / 2
    const horizontalDist = Math.abs(paddleCenter - flameCenter)
    const verticalDist = Math.abs(paddle.value.y - (flame.y + flame.height))

    if (horizontalDist < (paddle.value.width / 2 + flame.width / 2) * 0.8 && 
        verticalDist < 20 && flame.y + flame.height >= paddle.value.y) {
      // 接住了！
      if (flame.type === 'gold') {
        score.value += 50
      } else {
        score.value += 10
      }
      caught.value++
      
      // 添加特效粒子
      for (let i = 0; i < 10; i++) {
        particles.value.push({
          x: flame.x + flame.width / 2,
          y: flame.y + flame.height / 2,
          vx: (Math.random() - 0.5) * 6,
          vy: (Math.random() - 0.5) * 6,
          life: 1,
          decay: 0.05,
          color: flame.type === 'gold' ? '#d4a843' : '#ff6b35',
          size: Math.random() * 6 + 3
        })
      }
      return false
    }

    // 检查是否漏掉
    if (flame.y > canvasHeight) {
      lives.value--
      missed.value++
      if (lives.value <= 0) {
        endGame()
      }
      return false
    }

    return true
  })

  // 更新粒子
  particles.value = particles.value.filter(p => {
    p.x += p.vx
    p.y += p.vy
    p.life -= p.decay
    return p.life > 0
  })
}

// 游戏循环
const gameLoop = () => {
  update()
  draw()
  if (gameState.value === 'playing') {
    animationId = requestAnimationFrame(gameLoop)
  }
}

// 开始游戏
const startGame = async () => {
  try {
    const res = await apiPost('/api/catch-game/start')
    gameToken.value = res.gameToken || ''
  } catch (e) {
    console.log('Start game API failed, continuing with local game')
    gameToken.value = Date.now().toString()
  }

  // 重置游戏状态
  score.value = 0
  lives.value = 3
  caught.value = 0
  missed.value = 0
  flames.value = []
  particles.value = []
  gameState.value = 'playing'
  gameStartTime = Date.now()
  lastSpawnTime = 0
  paddle.value.x = canvasWidth / 2 - paddle.value.width / 2

  gameLoop()
}

// 结束游戏
const endGame = async () => {
  gameState.value = 'gameOver'
  if (animationId) {
    cancelAnimationFrame(animationId)
  }

  try {
    await apiPost('/api/catch-game/submit', {
      gameToken: gameToken.value,
      score: score.value,
      caught: caught.value,
      missed: missed.value
    })
    // 更新玩家焰晶
    if (playerStore.fetchPlayerData) {
      await playerStore.fetchPlayerData()
    } else {
      playerStore.spiritStones = (playerStore.spiritStones || 0) + reward.value
    }
  } catch (e) {
    console.log('Submit failed:', e)
    // 本地模拟奖励
    playerStore.spiritStones = (playerStore.spiritStones || 0) + reward.value
  }
}

// 控制处理
const handleMouseMove = (e) => {
  if (gameState.value !== 'playing') return
  const rect = gameCanvas.value.getBoundingClientRect()
  const scaleX = canvasWidth / rect.width
  const x = (e.clientX - rect.left) * scaleX
  paddle.value.x = Math.max(0, Math.min(canvasWidth - paddle.value.width, x - paddle.value.width / 2))
}

const handleTouchStart = (e) => {
  if (gameState.value !== 'playing') return
  isTouching.value = true
  touchStartX.value = e.touches[0].clientX
  paddleStartX.value = paddle.value.x
}

const handleTouchMove = (e) => {
  if (!isTouching.value || gameState.value !== 'playing') return
  e.preventDefault()
  const rect = gameCanvas.value.getBoundingClientRect()
  const scaleX = canvasWidth / rect.width
  const deltaX = (e.touches[0].clientX - touchStartX.value) * scaleX
  paddle.value.x = Math.max(0, Math.min(canvasWidth - paddle.value.width, paddleStartX.value + deltaX))
}

const handleTouchEnd = () => {
  isTouching.value = false
}

// 键盘控制
const handleKeyDown = (e) => {
  if (gameState.value !== 'playing') return
  const speed = 20
  if (e.key === 'ArrowLeft') {
    paddle.value.x = Math.max(0, paddle.value.x - speed)
  } else if (e.key === 'ArrowRight') {
    paddle.value.x = Math.min(canvasWidth - paddle.value.width, paddle.value.x + speed)
  }
}

// 生命周期
onMounted(() => {
  ctx = gameCanvas.value.getContext('2d')
  window.addEventListener('keydown', handleKeyDown)
  draw()
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyDown)
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
})
</script>

<style scoped>
.catch-game-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(180deg, #0b0b18 0%, #1a1a2e 100%);
  padding: 20px;
  position: relative;
}

.game-header {
  text-align: center;
  margin-bottom: 20px;
}

.game-title {
  font-size: 28px;
  font-weight: bold;
  color: #d4a843;
  text-shadow: 0 0 20px rgba(212, 168, 67, 0.5);
  margin-bottom: 15px;
}

.score-board {
  display: flex;
  gap: 30px;
  font-size: 18px;
  color: #fff;
}

.score {
  color: #ff6b35;
  font-weight: bold;
}

.lives {
  color: #ff4444;
}

.hearts {
  letter-spacing: 5px;
}

.canvas-wrapper {
  position: relative;
  border: 2px solid #d4a843;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 0 30px rgba(212, 168, 67, 0.3);
}

canvas {
  display: block;
  width: min(350px, 90vw);
  height: auto;
  background: #0b0b18;
  cursor: none;
}

.overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(11, 11, 24, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.overlay-content {
  text-align: center;
  padding: 40px;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border-radius: 15px;
  border: 2px solid #d4a843;
  box-shadow: 0 0 40px rgba(212, 168, 67, 0.4);
}

.overlay-title {
  font-size: 32px;
  color: #d4a843;
  margin-bottom: 20px;
  text-shadow: 0 0 15px rgba(212, 168, 67, 0.5);
}

.final-score {
  margin: 20px 0;
  font-size: 18px;
  color: #fff;
  line-height: 2;
}

.highlight {
  color: #d4a843;
  font-weight: bold;
  font-size: 24px;
}

.controls-hint {
  margin: 20px 0;
  padding: 15px;
  background: rgba(212, 168, 67, 0.1);
  border-radius: 8px;
  color: #aaa;
  font-size: 14px;
  line-height: 1.8;
}

.start-btn {
  padding: 15px 50px;
  font-size: 20px;
  font-weight: bold;
  color: #0b0b18;
  background: linear-gradient(135deg, #d4a843 0%, #f0d78c 50%, #d4a843 100%);
  border: none;
  border-radius: 30px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(212, 168, 67, 0.4);
}

.start-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(212, 168, 67, 0.6);
}

.start-btn:active {
  transform: translateY(0);
}
</style>
