<template>
  <div class="cultivation-container">
    <!-- 背景火焰粒子 -->
    <div class="fire-particles">
      <span v-for="i in 20" :key="i" class="fire-particle" :style="particleStyle(i)"></span>
    </div>
    <!-- 底部火焰光晕 -->
    <div class="fire-glow"></div>
    
    <n-card class="cultivation-card">
      <n-space vertical>
        <game-guide>
          <p>🧘 <strong>冥想</strong>消耗焰灵获得焰力，焰力达到上限后可<strong>突破焰阶</strong></p>
          <p>⬆️ 突破提升境界，解锁新地点和功能，共14大境界126级</p>
          <p>⚡ 焰灵自动恢复，速率随等级提升（每秒 2+等级×0.5）</p>
          <p>🔮 VIP/月卡/修炼加速卡可叠加冥想加成，最高2.7倍</p>
          <p>🤖 <strong>一键冥想</strong>一次性消耗所有焰灵转化为焰力（服务端计算，防作弊）</p>
          <p>💤 离线最多累积<strong>12小时</strong>收益（焰力+焰晶+焰灵）</p>
        </game-guide>
        
        <!-- 圆形进度环核心区域 -->
        <div class="cultivation-core" :class="{ 'is-meditating': isMeditating }">
          <!-- SVG 圆环 -->
          <div class="progress-ring-container">
            <svg class="progress-ring" viewBox="0 0 200 200">
              <!-- 渐变定义 -->
              <defs>
                <linearGradient id="fireGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stop-color="#8b0000" />
                  <stop offset="50%" stop-color="#ffa500" />
                  <stop offset="100%" stop-color="#ffd700" />
                </linearGradient>
                <filter id="glow">
                  <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                  <feMerge>
                    <feMergeNode in="coloredBlur"/>
                    <feMergeNode in="SourceGraphic"/>
                  </feMerge>
                </filter>
              </defs>
              <!-- 背景圆环 -->
              <circle cx="100" cy="100" r="85" fill="none" stroke="rgba(139,0,0,0.2)" stroke-width="8" />
              <!-- 进度圆环 -->
              <circle 
                class="progress-ring-circle"
                cx="100" 
                cy="100" 
                r="85" 
                fill="none" 
                stroke="url(#fireGradient)" 
                stroke-width="8"
                stroke-linecap="round"
                :stroke-dasharray="circumference"
                :stroke-dashoffset="strokeOffset"
                filter="url(#glow)"
              />
            </svg>
            
            <!-- 火焰粒子轨道 -->
            <div class="orbit-particles" :class="{ 'speed-up': isMeditating }">
              <span v-for="i in 8" :key="i" class="orbit-particle" :style="orbitStyle(i)"></span>
            </div>
            
            <!-- 脉冲波纹效果 -->
            <div v-if="isMeditating" class="pulse-waves">
              <span v-for="i in 3" :key="i" class="pulse-wave" :style="{ animationDelay: (i * 0.3) + 's' }"></span>
            </div>
            
            <!-- 中心内容 -->
            <div class="ring-center">
              <div class="cultivation-value">
                <span class="current-value" :class="{ 'number-jump': numberJump }">{{ Math.floor(playerStore.cultivation) }}</span>
                <span class="separator">/</span>
                <span class="max-value">{{ playerStore.maxCultivation }}</span>
              </div>
              <div class="realm-name-center">{{ realmInfo?.name }}</div>
            </div>
          </div>
          
          <!-- 焰灵状态区 -->
          <div class="spirit-status" :class="{ 'spirit-full': isSpiritFull }">
            <div class="spirit-bar-container">
              <svg class="spirit-arc" viewBox="0 0 200 60">
                <defs>
                  <linearGradient id="spiritGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                    <stop offset="0%" stop-color="#ff6b35" />
                    <stop offset="100%" stop-color="#ffd700" />
                  </linearGradient>
                </defs>
                <!-- 背景弧 -->
                <path d="M 20 50 A 80 80 0 0 1 180 50" fill="none" stroke="rgba(255,107,53,0.2)" stroke-width="6" stroke-linecap="round" />
                <!-- 进度弧 -->
                <path 
                  class="spirit-arc-progress"
                  d="M 20 50 A 80 80 0 0 1 180 50" 
                  fill="none" 
                  stroke="url(#spiritGradient)" 
                  stroke-width="6" 
                  stroke-linecap="round"
                  :stroke-dasharray="spiritArcLength"
                  :stroke-dashoffset="spiritArcOffset"
                />
              </svg>
              <div class="spirit-info">
                <span class="spirit-label">焰灵</span>
                <span class="spirit-value">{{ Math.floor(playerStore.spirit) }} / {{ playerStore.maxSpirit }}</span>
                <span class="spirit-rate">(+{{ playerStore.getSpiritRegen().toFixed(1) }}/s)</span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 境界图标显示 -->
        <div class="realm-display">
          <img :src="realmIcon" class="realm-icon" loading="lazy" />
          <div class="realm-text">
            <span class="realm-name">{{ realmInfo?.name }}</span>
            <span class="realm-desc">当前境界</span>
          </div>
        </div>
        
        <!-- 游戏风格按钮组 -->
        <div class="cultivation-buttons">
          <button 
            class="game-btn btn-meditate"
            @click="handleCultivate"
            :disabled="playerStore.spirit < cultivationCost"
          >
            <span class="btn-icon">🔥</span>
            <span class="btn-text">焰心冥想</span>
            <span class="btn-cost">-{{ cultivationCost }} 焰灵</span>
          </button>
          
          <button 
            class="game-btn btn-oneclick"
            @click="handleOneClick"
            :disabled="playerStore.spirit < cultivationCost"
          >
            <span class="btn-icon">⚡</span>
            <span class="btn-text">一键冥想</span>
            <span class="btn-cost">消耗全部</span>
          </button>
          
          <button 
            class="game-btn btn-breakthrough"
            @click="handleBreakthrough"
            :disabled="playerStore.spirit < calculateBreakthroughCost()"
            :class="{ 'can-break': canBreakthrough() }"
          >
            <span class="btn-icon">✦</span>
            <span class="btn-text">冥想至突破</span>
            <span class="btn-cost" v-if="!canBreakthrough()">需 {{ calculateBreakthroughCost() }} 焰灵</span>
            <span class="btn-cost ready" v-else>可突破!</span>
          </button>
        </div>
        
        <log-panel ref="logRef" title="冥想日志" />
      </n-space>
    </n-card>
  </div>

  <!-- 突破全屏特效 -->
  <teleport to="body">
    <transition name="breakthrough-fx">
      <div v-if="showBreakthrough" class="breakthrough-overlay" @click="showBreakthrough = false">
        <div class="bt-particles">
          <span v-for="i in 30" :key="i" class="bt-particle" :style="btParticleStyle(i)"></span>
        </div>
        <div class="bt-content">
          <div class="bt-flash"></div>
          <div class="bt-icon">⚡</div>
          <div class="bt-title">突破成功</div>
          <div class="bt-realm">{{ breakthroughRealm }}</div>
          <div class="bt-hint">点击继续</div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
import { hasSeenGuide, markGuideSeen, guideTexts } from "../utils/guide.js"
  import { usePlayerStore } from '../stores/player'
  import { useGameConfigStore } from '../stores/gameConfig'
  import { ref, computed, onMounted, onUnmounted } from 'vue'
  import LogPanel from '../components/LogPanel.vue'
  import GameGuide from '../components/GameGuide.vue'
  import { getRealmName, getRealmImage } from '../plugins/realm'

  const showGuide = ref(!hasSeenGuide("cultivation"))
const showBreakthrough = ref(false)
const breakthroughRealm = ref('')

// 冥想动画状态
const isMeditating = ref(false)
const numberJump = ref(false)

// 圆环计算
const radius = 85
const circumference = 2 * Math.PI * radius
const strokeOffset = computed(() => {
  const progress = Math.min(playerStore.cultivation / playerStore.maxCultivation, 1)
  return circumference - (progress * circumference)
})

// 焰灵弧形进度
const spiritArcLength = 251 // 近似弧长
const spiritArcOffset = computed(() => {
  const progress = Math.min(playerStore.spirit / playerStore.maxSpirit, 1)
  return spiritArcLength - (progress * spiritArcLength)
})

// 焰灵是否充满
const isSpiritFull = computed(() => playerStore.spirit >= playerStore.maxSpirit * 0.95)

// 背景粒子样式
const particleStyle = (i) => ({
  left: Math.random() * 100 + '%',
  animationDelay: (Math.random() * 5) + 's',
  animationDuration: (8 + Math.random() * 6) + 's',
  opacity: 0.3 + Math.random() * 0.4
})

// 轨道粒子样式
const orbitStyle = (i) => ({
  '--orbit-angle': ((i / 8) * 360) + 'deg',
  animationDelay: (i * 0.2) + 's'
})

const btParticleStyle = (i) => {
  const angle = (i / 30) * 360
  const dist = 40 + Math.random() * 60
  return {
    '--angle': angle + 'deg',
    '--dist': dist + 'px',
    animationDelay: (i * 0.05) + 's',
    background: ['#ffd700','#ff6b00','#ff2d55','#d4a843','#fff'][i % 5],
  }
}

function triggerBreakthrough(realm) {
  breakthroughRealm.value = realm
  showBreakthrough.value = true
  setTimeout(() => { showBreakthrough.value = false }, 4000)
}

const dismissGuide = () => { markGuideSeen("cultivation"); showGuide.value = false }
const playerStore = usePlayerStore()
  const gameConfigStore = useGameConfigStore()
  const logRef = ref(null)

  const realmIcon = computed(() => getRealmImage(playerStore.level))
  const realmInfo = computed(() => getRealmName(playerStore.level))

  // 活动效果
  const eventMultiplier = ref(1)
  const fetchEventEffects = async () => {
    try {
      const res = await fetch('/api/events/effects')
      const data = await res.json()
      eventMultiplier.value = data.effects?.cultivationMultiplier || 1
    } catch {}
  }

  // 修炼相关数值
  const baseGainRate = 1 // 基础焰灵获取率
  const baseCultivationCost = 10 // 基础焰修消耗的焰灵
  const baseCultivationGain = 1 // 基础修炼获得的焰修
  const autoGainInterval = 1000 // 自动获取焰灵的间隔（毫秒）
  const extraCultivationChance = 0.3 // 获得额外焰修的基础概率

  // 计算当前境界的修炼消耗（从配置中心读取）
  const getCurrentCultivationCost = () => {
    return gameConfigStore.getCultivationCost(playerStore.level)
  }

  // 计算当前境界的修炼获得（从配置中心读取）
  const getCurrentCultivationGain = () => {
    return gameConfigStore.getCultivationGain(playerStore.level)
  }

  // 计算当前修炼消耗（作为计算属性）
  const cultivationCost = computed(() => {
    return getCurrentCultivationCost()
  })

  // 计算当前修炼获得（作为计算属性）
  const cultivationGain = computed(() => {
    return getCurrentCultivationGain()
  })

  // 计算突破所需的总焰灵
  const calculateBreakthroughCost = () => {
    const remainingCultivation = Math.max(0, playerStore.maxCultivation - playerStore.cultivation)
    const gain = cultivationGain?.value || 1
    if (gain <= 0) return 0
    const cultivationTimes = Math.ceil(remainingCultivation / gain)
    return Math.max(0, cultivationTimes * getCurrentCultivationCost())
  }

  // 显示消息并处理重复
  const showMessage = (type, content) => {
    return logRef.value?.addLog(type, content)
  }

  // 计算实际获得的焰修
  const calculateCultivationGain = () => {
    let gain = cultivationGain.value
    // 活动加成
    if (eventMultiplier.value > 1) gain = Math.floor(gain * eventMultiplier.value)
    // 根据幸运值计算是否获得额外焰修
    if (Math.random() < extraCultivationChance * playerStore.luck) {
      gain *= 2
      showMessage('success', '福缘不错，获得双倍焰力！')
    }
    return gain
   }

  // 检查是否可以突破
  const canBreakthrough = () => {
    return playerStore.cultivation >= playerStore.maxCultivation
  }

  // 修炼Worker
  const cultivationWorker = new Worker(new URL('../workers/cultivation.js', import.meta.url))

  // 处理Worker消息
  cultivationWorker.onmessage = async ({ data }) => {
    if (data.type === 'error') {
      showMessage('error', data.message)
      return
    }
    if (data.type === 'success') {
      const { spiritCost, cultivationGain, doubleGainTimes } = data.result
      const token = localStorage.getItem('xx_token')
      if (token) {
        // 已登录：走后端批量冥想
        try {
          const times = Math.ceil(spiritCost / (playerStore.cultivationCost || 1))
          const res = await fetch('/api/game/cultivate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
            body: JSON.stringify({ times: Math.min(times, 100) })
          })
          if (res.ok) {
            const d = await res.json()
            playerStore.spirit = d.spirit
            playerStore.cultivation = d.cultivation
            playerStore.level = d.level
            playerStore.realm = d.realm
            playerStore.maxCultivation = d.maxCultivation
            if (d.broke) {
              triggerBreakthrough(playerStore.realm)
            } else {
              showMessage('success', `冥想${d.actualTimes}次成功！`)
            }
          }
        } catch (e) {
          showMessage('error', '冥想失败：' + e.message)
        }
      } else {
        // 未登录：本地计算
        playerStore.spirit -= spiritCost
        await playerStore.cultivate(cultivationGain)
        if (doubleGainTimes > 0) {
          showMessage('success', `福缘不错，获得${doubleGainTimes}次双倍焰力！`)
        }
        if (canBreakthrough()) {
          const broke = await playerStore.tryBreakthrough()
          if (broke) {
            triggerBreakthrough(playerStore.realm)
          }
        } else {
          showMessage('success', '冥想成功！')
        }
      }
    }
    isMeditating.value = false
  }

  // 触发数字跳动动画
  const triggerNumberJump = () => {
    numberJump.value = true
    setTimeout(() => { numberJump.value = false }, 300)
  }

  // 包装后的修炼方法（带动画）
  const handleCultivate = async () => {
    isMeditating.value = true
    triggerNumberJump()
    await cultivate()
    setTimeout(() => { isMeditating.value = false }, 500)
  }

  // 包装后的一键冥想方法（带动画）
  const handleOneClick = async () => {
    isMeditating.value = true
    triggerNumberJump()
    await oneClickCultivate()
    setTimeout(() => { isMeditating.value = false }, 800)
  }

  // 包装后的突破方法（带动画）
  const handleBreakthrough = async () => {
    isMeditating.value = true
    triggerNumberJump()
    await cultivateUntilBreakthrough()
    setTimeout(() => { isMeditating.value = false }, 1000)
  }

  // 一键修炼（直到突破）
  const cultivateUntilBreakthrough = async () => {
    try {
      // 检查是否已经达到突破条件
      if (!canBreakthrough()) {
        // 发送数据到Worker进行计算
        cultivationWorker.postMessage({
          type: 'cultivateUntilBreakthrough',
          playerData: {
            level: playerStore.level,
            spirit: playerStore.spirit,
            cultivation: playerStore.cultivation,
            maxCultivation: playerStore.maxCultivation,
            luck: playerStore.luck
          }
        })
      } else {
        // 直接尝试突破
        const broke = await playerStore.tryBreakthrough()
        if (broke) {
          triggerBreakthrough(playerStore.realm)
        } else {
          showMessage('info', '已达到突破条件，但突破失败，请继续努力！')
        }
      }
    } catch (error) {
      console.error('焰力突破出错：', error)
      showMessage('error', '冥想失败！')
    }
  }

  // 手动修炼
  const cultivate = async () => {
    try {
      const currentCost = getCurrentCultivationCost()
      if (playerStore.spirit < currentCost) {
        showMessage('error', '焰灵不足！')
        return
      }
      const oldRealm = playerStore.realm
      // 本地预测扣除（展示用）
      playerStore.spirit -= currentCost
      // 调后端 API 执行冥想
      const result = await playerStore.cultivate(currentCost)
      if (result && result.broke) {
        triggerBreakthrough(playerStore.realm)
      } else if (playerStore.realm !== oldRealm) {
        triggerBreakthrough(playerStore.realm)
      } else {
        showMessage('success', '冥想成功！')
      }
    } catch (error) {
      console.error('修炼出错：', error)
      showMessage('error', '冥想失败！')
    }
  }

  // 一键冥想：一次性消耗所有焰灵
  const oneClickCultivate = async () => {
    const cost = cultivationCost.value
    if (playerStore.spirit < cost) {
      showMessage('error', '焰灵不足！')
      return
    }
    const times = Math.floor(playerStore.spirit / cost)
    if (times <= 0) return
    const token = localStorage.getItem('xx_token')
    if (token) {
      try {
        const res = await fetch('/api/game/cultivate', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
          body: JSON.stringify({ times: Math.min(times, 1000) })
        })
        if (res.ok) {
          const d = await res.json()
          playerStore.spirit = d.spirit
          playerStore.cultivation = d.cultivation
          playerStore.level = d.level
          playerStore.realm = d.realm
          playerStore.maxCultivation = d.maxCultivation
          playerStore.maxSpirit = d.maxSpirit
          if (d.broke) {
            triggerBreakthrough(playerStore.realm)
          } else {
            showMessage('success', `一键冥想${d.actualTimes}次，获得${d.actualTimes * d.cultGain}焰力！`)
          }
        }
      } catch (e) {
        showMessage('error', '冥想失败：' + e.message)
      }
    } else {
      // 未登录本地计算
      let count = 0
      while (playerStore.spirit >= cost && count < times) {
        playerStore.spirit -= cost
        playerStore.cultivation += cultivationGain.value
        count++
      }
      if (playerStore.cultivation >= playerStore.maxCultivation) {
        await playerStore.tryBreakthrough()
        triggerBreakthrough(playerStore.realm)
      } else {
        showMessage('success', `一键冥想${count}次！`)
      }
      playerStore.saveData()
    }
  }

  // 组件卸载时只清理 Worker，不停自动冥想
  onMounted(() => {
    fetchEventEffects()
  })

  onUnmounted(() => {
    try {
      cultivationWorker.terminate()
    } catch (error) {
      console.error('清理Worker出错：', error)
    }
  })
</script>

<style scoped>
/* ===== 容器与背景 ===== */
.cultivation-container {
  position: relative;
  min-height: 100vh;
  background: linear-gradient(180deg, #0a0a1a 0%, #1a1020 50%, #0d0d1a 100%);
  overflow: hidden;
}

/* 背景火焰粒子 */
.fire-particles {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
}

.fire-particle {
  position: absolute;
  width: 4px;
  height: 4px;
  background: radial-gradient(circle, #ff6b35 0%, transparent 70%);
  border-radius: 50%;
  animation: float-up linear infinite;
}

@keyframes float-up {
  0% {
    transform: translateY(100vh) scale(0);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 0.5;
  }
  100% {
    transform: translateY(-100px) scale(1.5);
    opacity: 0;
  }
}

/* 底部火焰光晕 */
.fire-glow {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 150%;
  height: 300px;
  background: radial-gradient(ellipse at center bottom, rgba(255,107,53,0.15) 0%, rgba(255,165,0,0.05) 40%, transparent 70%);
  pointer-events: none;
  z-index: 0;
  animation: glow-pulse 4s ease-in-out infinite;
}

@keyframes glow-pulse {
  0%, 100% { opacity: 0.6; transform: translateX(-50%) scale(1); }
  50% { opacity: 1; transform: translateX(-50%) scale(1.1); }
}

/* ===== 主卡片 ===== */
.cultivation-card {
  position: relative;
  z-index: 1;
  background: rgba(20, 20, 40, 0.85) !important;
  border: 1px solid rgba(212, 168, 67, 0.2) !important;
  box-shadow: 0 0 40px rgba(0, 0, 0, 0.5), inset 0 0 60px rgba(139, 0, 0, 0.1) !important;
}

/* ===== 圆形进度环核心区域 ===== */
.cultivation-core {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 30px 0;
  position: relative;
}

.progress-ring-container {
  position: relative;
  width: 260px;
  height: 260px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.progress-ring {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.progress-ring-circle {
  transition: stroke-dashoffset 0.5s ease;
}

/* 火焰粒子轨道 */
.orbit-particles {
  position: absolute;
  width: 100%;
  height: 100%;
  animation: orbit-rotate 20s linear infinite;
}

.orbit-particles.speed-up {
  animation-duration: 3s;
}

@keyframes orbit-rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.orbit-particle {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 8px;
  height: 8px;
  background: radial-gradient(circle, #ffd700 0%, #ff6b35 50%, transparent 70%);
  border-radius: 50%;
  box-shadow: 0 0 10px #ff6b35;
  transform: rotate(var(--orbit-angle)) translateX(115px) translate(-50%, -50%);
  animation: particle-pulse 2s ease-in-out infinite;
}

@keyframes particle-pulse {
  0%, 100% { opacity: 0.6; transform: rotate(var(--orbit-angle)) translateX(115px) scale(0.8); }
  50% { opacity: 1; transform: rotate(var(--orbit-angle)) translateX(115px) scale(1.2); }
}

/* 脉冲波纹效果 */
.pulse-waves {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.pulse-wave {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 200px;
  height: 200px;
  border: 2px solid rgba(255, 107, 53, 0.5);
  border-radius: 50%;
  transform: translate(-50%, -50%);
  animation: pulse-expand 1.5s ease-out infinite;
}

@keyframes pulse-expand {
  0% { transform: translate(-50%, -50%) scale(0.8); opacity: 0.8; }
  100% { transform: translate(-50%, -50%) scale(1.5); opacity: 0; }
}

/* 中心内容 */
.ring-center {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  z-index: 2;
}

.cultivation-value {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 4px;
  margin-bottom: 8px;
}

.current-value {
  font-size: 36px;
  font-weight: bold;
  background: linear-gradient(180deg, #ffd700 0%, #ff6b35 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 0 20px rgba(255, 107, 53, 0.5);
  transition: transform 0.1s;
}

.current-value.number-jump {
  animation: number-bounce 0.3s ease;
}

@keyframes number-bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-8px) scale(1.1); }
}

.separator {
  font-size: 20px;
  color: rgba(212, 168, 67, 0.6);
}

.max-value {
  font-size: 18px;
  color: rgba(212, 168, 67, 0.8);
}

.realm-name-center {
  font-size: 14px;
  color: #d4a843;
  font-family: 'Noto Serif SC', serif;
  text-shadow: 0 0 8px rgba(212, 168, 67, 0.4);
}

/* ===== 焰灵状态区 ===== */
.spirit-status {
  margin-top: 20px;
  width: 100%;
  max-width: 280px;
  padding: 15px;
  background: rgba(139, 0, 0, 0.1);
  border-radius: 12px;
  border: 1px solid rgba(255, 107, 53, 0.2);
  transition: all 0.3s;
}

.spirit-status.spirit-full {
  background: rgba(255, 215, 0, 0.1);
  border-color: rgba(255, 215, 0, 0.4);
  box-shadow: 0 0 20px rgba(255, 215, 0, 0.2);
  animation: spirit-glow 2s ease-in-out infinite;
}

@keyframes spirit-glow {
  0%, 100% { box-shadow: 0 0 20px rgba(255, 215, 0, 0.2); }
  50% { box-shadow: 0 0 30px rgba(255, 215, 0, 0.4); }
}

.spirit-bar-container {
  position: relative;
}

.spirit-arc {
  width: 100%;
  height: auto;
  margin-bottom: 8px;
}

.spirit-arc-progress {
  transition: stroke-dashoffset 0.5s ease;
}

.spirit-info {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  flex-wrap: wrap;
}

.spirit-label {
  font-size: 12px;
  color: #ff6b35;
  font-weight: bold;
}

.spirit-value {
  font-size: 14px;
  color: #f0d68a;
}

.spirit-rate {
  font-size: 11px;
  color: rgba(240, 214, 138, 0.6);
}

/* ===== 境界显示 ===== */
.realm-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  margin: 20px 0;
  padding: 14px;
  background: linear-gradient(135deg, rgba(212,168,67,0.08) 0%, rgba(10,8,18,0.6) 100%);
  border: 1px solid rgba(212,168,67,0.2);
  border-radius: 12px;
  position: relative;
  overflow: hidden;
}

.realm-display::before {
  content: '';
  position: absolute;
  top: -50%; left: -50%;
  width: 200%; height: 200%;
  background: radial-gradient(circle at 30% 30%, rgba(212,168,67,0.06) 0%, transparent 60%);
  animation: realm-glow 4s ease-in-out infinite;
}

@keyframes realm-glow {
  0%, 100% { opacity: 0.5; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.05); }
}

.realm-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  border: 2px solid rgba(212,168,67,0.5);
  box-shadow: 0 0 16px rgba(212,168,67,0.3), 0 0 32px rgba(212,168,67,0.1);
  object-fit: cover;
  position: relative;
  z-index: 1;
}

.realm-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  position: relative;
  z-index: 1;
}

.realm-name {
  font-size: 16px;
  font-weight: bold;
  color: #f0d68a;
  text-shadow: 0 0 8px rgba(212,168,67,0.4);
  font-family: 'Noto Serif SC', serif;
}

.realm-desc {
  font-size: 12px;
  color: rgba(240, 214, 138, 0.6);
}

/* ===== 游戏风格按钮 ===== */
.cultivation-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin: 20px 0;
}

.game-btn {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  overflow: hidden;
}

.game-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  filter: grayscale(0.5);
}

.game-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}

.game-btn:hover:not(:disabled)::before {
  left: 100%;
}

.game-btn:active:not(:disabled) {
  transform: scale(0.97);
}

.btn-icon {
  font-size: 18px;
}

.btn-text {
  flex: 1;
  text-align: left;
}

.btn-cost {
  font-size: 12px;
  opacity: 0.8;
  padding: 2px 8px;
  background: rgba(0,0,0,0.2);
  border-radius: 4px;
}

/* 焰心冥想按钮 */
.btn-meditate {
  background: linear-gradient(135deg, #ff6b35 0%, #e85d04 100%);
  color: #fff;
  box-shadow: 0 4px 15px rgba(255, 107, 53, 0.4), inset 0 1px 0 rgba(255,255,255,0.2);
  border: 1px solid rgba(255, 107, 53, 0.5);
}

.btn-meditate:hover:not(:disabled) {
  box-shadow: 0 6px 20px rgba(255, 107, 53, 0.6), inset 0 1px 0 rgba(255,255,255,0.2);
  transform: translateY(-1px);
}

/* 一键冥想按钮 */
.btn-oneclick {
  background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%);
  color: #fff;
  box-shadow: 0 4px 15px rgba(46, 204, 113, 0.4), inset 0 1px 0 rgba(255,255,255,0.2);
  border: 1px solid rgba(46, 204, 113, 0.5);
}

.btn-oneclick:hover:not(:disabled) {
  box-shadow: 0 6px 20px rgba(46, 204, 113, 0.6), inset 0 1px 0 rgba(255,255,255,0.2);
  transform: translateY(-1px);
}

/* 突破按钮 */
.btn-breakthrough {
  background: linear-gradient(135deg, #d4a843 0%, #b8860b 100%);
  color: #0a0a1a;
  box-shadow: 0 4px 15px rgba(212, 168, 67, 0.4), inset 0 1px 0 rgba(255,255,255,0.3);
  border: 1px solid rgba(212, 168, 67, 0.5);
}

.btn-breakthrough:hover:not(:disabled) {
  box-shadow: 0 6px 20px rgba(212, 168, 67, 0.6), inset 0 1px 0 rgba(255,255,255,0.3);
  transform: translateY(-1px);
}

/* 突破按钮可突破状态 - 金色闪烁 */
.btn-breakthrough.can-break {
  animation: breakthrough-shine 1.5s ease-in-out infinite;
}

@keyframes breakthrough-shine {
  0%, 100% {
    box-shadow: 0 4px 20px rgba(255, 215, 0, 0.6), inset 0 1px 0 rgba(255,255,255,0.4);
    filter: brightness(1);
  }
  50% {
    box-shadow: 0 6px 30px rgba(255, 215, 0, 0.8), inset 0 1px 0 rgba(255,255,255,0.5);
    filter: brightness(1.2);
  }
}

.btn-cost.ready {
  background: rgba(255, 215, 0, 0.3);
  color: #ffd700;
  font-weight: bold;
}

/* ===== 突破全屏特效 ===== */
.breakthrough-overlay {
  position: fixed; inset: 0; z-index: 99999;
  background: rgba(0,0,0,0.85);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
}

.bt-particles { position: absolute; inset: 0; overflow: hidden; pointer-events: none; }

.bt-particle {
  position: absolute; top: 50%; left: 50%;
  width: 6px; height: 6px; border-radius: 50%;
  animation: bt-explode 1.5s ease-out forwards;
}

@keyframes bt-explode {
  0% { transform: translate(-50%,-50%) scale(0); opacity: 1; }
  100% { transform: translate(calc(-50% + cos(var(--angle)) * var(--dist) * 3), calc(-50% + sin(var(--angle)) * var(--dist) * 3)) scale(0); opacity: 0; }
}

.bt-content { position: relative; z-index: 2; text-align: center; }

.bt-flash {
  position: fixed; inset: 0;
  background: radial-gradient(circle, rgba(255,215,0,0.4) 0%, transparent 70%);
  animation: bt-flash-anim 0.8s ease-out forwards;
  pointer-events: none;
}

@keyframes bt-flash-anim {
  0% { opacity: 1; transform: scale(0.5); }
  100% { opacity: 0; transform: scale(2); }
}

.bt-icon {
  font-size: 72px;
  animation: bt-icon-in 0.6s cubic-bezier(0.34,1.56,0.64,1) forwards;
  filter: drop-shadow(0 0 24px rgba(255,215,0,0.8));
}

@keyframes bt-icon-in {
  0% { transform: scale(0) rotate(-180deg); opacity: 0; }
  100% { transform: scale(1) rotate(0deg); opacity: 1; }
}

.bt-title {
  font-size: 32px; font-weight: 900; letter-spacing: 8px; margin-top: 16px;
  background: linear-gradient(180deg, #fff, #ffd700, #ff9800);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
  animation: bt-text-in 0.8s ease-out 0.3s both;
}

@keyframes bt-text-in {
  0% { transform: translateY(20px) scale(0.8); opacity: 0; }
  100% { transform: translateY(0) scale(1); opacity: 1; }
}

.bt-realm {
  font-size: 22px; color: #d4a843; margin-top: 8px;
  font-family: 'Noto Serif SC', serif;
  text-shadow: 0 0 16px rgba(212,168,67,0.6);
  animation: bt-text-in 0.8s ease-out 0.5s both;
}

.bt-hint {
  font-size: 12px; color: #666; margin-top: 24px;
  animation: bt-text-in 0.8s ease-out 0.8s both;
}

.breakthrough-fx-enter-active { transition: opacity 0.3s; }
.breakthrough-fx-leave-active { transition: opacity 0.5s; }
.breakthrough-fx-enter-from, .breakthrough-fx-leave-to { opacity: 0; }

/* ===== 响应式 ===== */
@media (max-width: 480px) {
  .progress-ring-container {
    width: 220px;
    height: 220px;
  }
  
  .current-value {
    font-size: 28px;
  }
  
  .game-btn {
    padding: 12px 16px;
    font-size: 14px;
  }
}
</style>
