<template>
  <div class="snake-game-container">
    <div class="game-header">
      <h1 class="game-title">🐍 焰蛇吞噬 🐍</h1>
      <div class="info-row">
        <span>今日剩余: {{ remainingPlays }}次</span>
        <span>最高分: {{ bestScore }}</span>
      </div>
    </div>

    <div v-if="gameState === 'idle'" class="start-panel">
      <div class="rules">
        <h3>🎮 游戏规则</h3>
        <ul>
          <li>控制焰蛇吃掉 🔥 焰灵</li>
          <li>每吃一个 +10分</li>
          <li>撞墙或撞自己游戏结束</li>
          <li>速度随分数递增</li>
          <li>每日限玩3次</li>
        </ul>
        <h3>🎁 奖励</h3>
        <div class="reward-list">
          <div class="rw">≥500分 → 500焰晶</div>
          <div class="rw">≥300分 → 300焰晶</div>
          <div class="rw">≥200分 → 200焰晶</div>
          <div class="rw">≥100分 → 100焰晶</div>
          <div class="rw">&lt;100分 → 50焰晶</div>
        </div>
      </div>
      <button class="btn-start" @click="startGame" :disabled="remainingPlays <= 0">
        {{ remainingPlays > 0 ? '开始游戏' : '今日次数已用完' }}
      </button>
    </div>

    <div v-if="gameState === 'playing'" class="game-area">
      <div class="score-bar">
        <span>分数: {{ score }}</span>
        <span>长度: {{ snakeLength }}</span>
      </div>
      <canvas ref="canvasRef" class="game-canvas" :width="canvasSize" :height="canvasSize"></canvas>
      <div class="controls">
        <div class="ctrl-row"><button class="ctrl-btn" @touchstart.prevent="setDir('up')" @click="setDir('up')">▲</button></div>
        <div class="ctrl-row">
          <button class="ctrl-btn" @touchstart.prevent="setDir('left')" @click="setDir('left')">◀</button>
          <button class="ctrl-btn" @touchstart.prevent="setDir('down')" @click="setDir('down')">▼</button>
          <button class="ctrl-btn" @touchstart.prevent="setDir('right')" @click="setDir('right')">▶</button>
        </div>
      </div>
    </div>

    <div v-if="gameState === 'over'" class="result-panel">
      <h2>游戏结束</h2>
      <div class="result-score">{{ score }} 分</div>
      <div class="result-reward" v-if="reward > 0">获得 💎 {{ reward }} 焰晶</div>
      <button class="btn-start" @click="resetGame" :disabled="remainingPlays <= 0">
        {{ remainingPlays > 0 ? '再来一次' : '今日次数已用完' }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from "vue"
import { useAuthStore } from "../stores/auth"
import { usePlayerStore } from "../stores/player"

const authStore = useAuthStore()
const playerStore = usePlayerStore()

const GRID = 20
const canvasSize = Math.min(350, window.innerWidth * 0.9)
const CELL = canvasSize / GRID

const gameState = ref("idle")
const score = ref(0)
const snakeLength = ref(3)
const reward = ref(0)
const remainingPlays = ref(3)
const bestScore = ref(0)
const canvasRef = ref(null)
const gameToken = ref("")

let snake = [{ x: 10, y: 10 }, { x: 9, y: 10 }, { x: 8, y: 10 }]
let food = { x: 15, y: 10 }
let dir = "right"
let nextDir = "right"
let timer = null
let speed = 150

const setDir = (d) => {
  const opp = { up: "down", down: "up", left: "right", right: "left" }
  if (d !== opp[dir]) nextDir = d
}

const onKey = (e) => {
  const map = { ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right", w: "up", s: "down", a: "left", d: "right" }
  if (map[e.key]) { setDir(map[e.key]); e.preventDefault() }
}

const genFood = () => {
  let f
  do { f = { x: Math.floor(Math.random() * GRID), y: Math.floor(Math.random() * GRID) } }
  while (snake.some(s => s.x === f.x && s.y === f.y))
  food = f
}

const draw = () => {
  const ctx = canvasRef.value?.getContext("2d")
  if (!ctx) return
  ctx.fillStyle = "#0b0b18"
  ctx.fillRect(0, 0, canvasSize, canvasSize)
  // grid
  ctx.strokeStyle = "rgba(212,168,67,0.08)"
  for (let i = 0; i <= GRID; i++) {
    ctx.beginPath(); ctx.moveTo(i * CELL, 0); ctx.lineTo(i * CELL, canvasSize); ctx.stroke()
    ctx.beginPath(); ctx.moveTo(0, i * CELL); ctx.lineTo(canvasSize, i * CELL); ctx.stroke()
  }
  // snake
  snake.forEach((seg, i) => {
    const b = Math.max(0.4, 1 - i / (snake.length + 3))
    ctx.fillStyle = i === 0 ? "#ffd700" : "rgba(255,107,53," + b + ")"
    const p = 1
    ctx.fillRect(seg.x * CELL + p, seg.y * CELL + p, CELL - p * 2, CELL - p * 2)
  })
  // food
  ctx.font = (CELL - 2) + "px serif"
  ctx.textAlign = "center"
  ctx.textBaseline = "middle"
  ctx.fillText("\uD83D\uDD25", food.x * CELL + CELL / 2, food.y * CELL + CELL / 2)
}

const tick = () => {
  dir = nextDir
  const head = { ...snake[0] }
  if (dir === "up") head.y--
  else if (dir === "down") head.y++
  else if (dir === "left") head.x--
  else head.x++
  if (head.x < 0 || head.x >= GRID || head.y < 0 || head.y >= GRID || snake.some(s => s.x === head.x && s.y === head.y)) {
    endGame(); return
  }
  snake.unshift(head)
  if (head.x === food.x && head.y === food.y) {
    score.value += 10
    snakeLength.value = snake.length
    genFood()
    speed = Math.max(60, 150 - Math.floor(score.value / 50) * 10)
    clearInterval(timer)
    timer = setInterval(tick, speed)
  } else {
    snake.pop()
  }
  draw()
}

const startGame = async () => {
  try {
    const res = await authStore.apiPost("/snake-game/start")
    if (!res.success) { alert(res.message); return }
    gameToken.value = res.gameToken
    remainingPlays.value = res.remainingPlays
  } catch (e) { alert("启动失败"); return }
  snake = [{ x: 10, y: 10 }, { x: 9, y: 10 }, { x: 8, y: 10 }]
  dir = "right"; nextDir = "right"
  score.value = 0; snakeLength.value = 3; speed = 150
  genFood()
  gameState.value = "playing"
  await nextTick()
  draw()
  timer = setInterval(tick, speed)
  window.addEventListener("keydown", onKey)
}

const endGame = async () => {
  clearInterval(timer)
  window.removeEventListener("keydown", onKey)
  gameState.value = "over"
  try {
    const res = await authStore.apiPost("/snake-game/submit", { gameToken: gameToken.value, score: score.value, length: snakeLength.value })
    if (res.success) {
      reward.value = res.reward
      remainingPlays.value = res.remainingPlays
      bestScore.value = res.bestScore
      playerStore.spiritStones = (playerStore.spiritStones || 0) + res.reward
    }
  } catch (e) { console.error(e) }
}

const resetGame = () => { gameState.value = "idle" }

onMounted(async () => {
  try {
    const res = await authStore.apiGet("/snake-game/status")
    if (res.success) { remainingPlays.value = res.remainingPlays; bestScore.value = res.bestScore }
  } catch (e) {}
})

onUnmounted(() => { clearInterval(timer); window.removeEventListener("keydown", onKey) })
</script>

<style scoped>
.snake-game-container { max-width: 400px; margin: 0 auto; padding: 16px; color: #d4a843; }
.game-title { text-align: center; font-size: 24px; margin-bottom: 8px; }
.info-row { display: flex; justify-content: space-between; font-size: 14px; color: #a08030; margin-bottom: 12px; }
.start-panel, .result-panel { text-align: center; }
.rules { background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.2); border-radius: 12px; padding: 16px; margin-bottom: 16px; text-align: left; }
.rules h3 { color: #ffd700; margin: 8px 0 4px; }
.rules ul { padding-left: 20px; font-size: 14px; color: #c0a050; }
.rules li { margin: 4px 0; }
.reward-list { font-size: 13px; color: #c0a050; }
.rw { padding: 2px 0; }
.btn-start { background: linear-gradient(135deg, #d4a843, #ff6b35); color: #0b0b18; border: none; border-radius: 25px; padding: 12px 40px; font-size: 18px; font-weight: bold; cursor: pointer; margin-top: 12px; }
.btn-start:disabled { opacity: 0.5; cursor: not-allowed; }
.score-bar { display: flex; justify-content: space-between; font-size: 16px; font-weight: bold; margin-bottom: 8px; }
.game-canvas { display: block; margin: 0 auto; border: 2px solid #d4a843; border-radius: 8px; }
.controls { display: flex; flex-direction: column; align-items: center; margin-top: 12px; gap: 4px; }
.ctrl-row { display: flex; gap: 8px; }
.ctrl-btn { width: 65px; height: 65px; font-size: 24px; background: rgba(212,168,67,0.15); border: 2px solid #d4a843; border-radius: 12px; color: #ffd700; cursor: pointer; user-select: none; -webkit-user-select: none; }
.ctrl-btn:active { background: rgba(255,107,53,0.3); transform: scale(0.95); }
.result-panel h2 { color: #ffd700; }
.result-score { font-size: 48px; font-weight: bold; color: #ff6b35; margin: 16px 0; }
.result-reward { font-size: 20px; color: #ffd700; margin-bottom: 16px; }
</style>
