<template>
  <div class="cultivation-container">
    <!-- 背景火焰粒子 -->
    <div class="fire-particles">
      <span v-for="i in 10" :key="i" class="fire-particle" :style="particleStyle(i)"></span>
    </div>
    <div class="fire-glow"></div>
        
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
        
    <log-panel ref="logRef" title="冥想日志" class="cult-log" />
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
.cultivation-container {
  position: relative;
  padding: 0;
  background: linear-gradient(180deg, #0b0b18 0%, #12101f 60%, #0b0b18 100%);
  min-height: 75vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* 背景粒子 */
.fire-particles { position: absolute; inset: 0; pointer-events: none; }
.fire-particle {
  position: absolute; width: 2px; height: 2px;
  background: rgba(255,180,60,0.7); border-radius: 50%;
  animation: fp-rise linear infinite;
}
@keyframes fp-rise {
  0% { transform: translateY(75vh); opacity: 0; }
  10% { opacity: 0.5; }
  90% { opacity: 0.2; }
  100% { transform: translateY(-10px); opacity: 0; }
}
.fire-glow {
  position: absolute; bottom: 0; left: 0; right: 0; height: 120px;
  background: radial-gradient(ellipse at center bottom, rgba(212,168,67,0.06) 0%, transparent 70%);
  pointer-events: none;
}

/* === 圆环核心 === */
.cultivation-core {
  display: flex; flex-direction: column; align-items: center;
  padding: 24px 0 8px; width: 100%;
}
.progress-ring-container {
  position: relative; width: 220px; height: 220px;
}
.progress-ring { width: 100%; height: 100%; transform: rotate(-90deg); }
.progress-ring-circle { transition: stroke-dashoffset 0.6s ease; }

/* 轨道粒子 */
.orbit-particles {
  position: absolute; inset: 0;
  animation: orb-spin 22s linear infinite;
}
.orbit-particles.speed-up { animation-duration: 2s; }
@keyframes orb-spin { to { transform: rotate(360deg); } }
.orbit-particle {
  position: absolute; top: 50%; left: 50%;
  width: 4px; height: 4px;
  background: #ffd700; border-radius: 50%;
  box-shadow: 0 0 6px rgba(255,215,0,0.5);
  transform: rotate(var(--orbit-angle)) translateX(100px);
  animation: op-blink 2.5s ease-in-out infinite;
}
@keyframes op-blink {
  0%,100% { opacity: 0.3; } 50% { opacity: 1; }
}

/* 脉冲 */
.pulse-waves { position: absolute; inset: 0; pointer-events: none; }
.pulse-wave {
  position: absolute; top: 50%; left: 50%; width: 160px; height: 160px;
  border: 1px solid rgba(212,168,67,0.25); border-radius: 50%;
  transform: translate(-50%,-50%);
  animation: pw-expand 2s ease-out infinite;
}
@keyframes pw-expand {
  0% { transform: translate(-50%,-50%) scale(0.85); opacity: 0.5; }
  100% { transform: translate(-50%,-50%) scale(1.35); opacity: 0; }
}

/* 中心数值 */
.ring-center {
  position: absolute; top: 50%; left: 50%;
  transform: translate(-50%,-50%); text-align: center;
}
.cultivation-value {
  display: flex; align-items: baseline; justify-content: center; gap: 3px;
}
.current-value {
  font-size: 28px; font-weight: 700; color: #ffd700;
  text-shadow: 0 0 10px rgba(255,215,0,0.25);
}
.current-value.number-jump { animation: nj 0.2s ease; }
@keyframes nj { 50% { transform: scale(1.12); } }
.separator { font-size: 14px; color: rgba(212,168,67,0.35); }
.max-value { font-size: 13px; color: rgba(212,168,67,0.45); }
.realm-name-center {
  font-size: 12px; color: rgba(212,168,67,0.6);
  margin-top: 2px; letter-spacing: 3px;
}

/* === 焰灵状态 === */
.spirit-status {
  width: 90%; max-width: 240px; margin-top: 12px;
  padding: 8px 12px;
  background: rgba(212,168,67,0.04);
  border: 1px solid rgba(212,168,67,0.1);
  border-radius: 8px;
}
.spirit-status.spirit-full {
  border-color: rgba(255,215,0,0.25);
  box-shadow: 0 0 12px rgba(255,215,0,0.08);
}
.spirit-arc { width: 100%; }
.spirit-arc-progress { transition: stroke-dashoffset 0.5s ease; }
.spirit-info {
  display: flex; align-items: center; justify-content: center;
  gap: 6px; font-size: 12px;
}
.spirit-label { color: #d4a843; font-weight: 600; font-size: 11px; }
.spirit-value { color: rgba(240,214,138,0.85); font-size: 13px; }
.spirit-rate { color: rgba(240,214,138,0.35); font-size: 10px; }

/* === 按钮组 === */
.cultivation-buttons {
  width: 90%; max-width: 320px;
  display: flex; flex-direction: column; gap: 8px;
  margin: 16px auto 8px;
}
.game-btn {
  display: flex; align-items: center; gap: 8px;
  padding: 11px 14px;
  border: none; border-radius: 8px;
  font-size: 14px; font-weight: 600;
  cursor: pointer; transition: all 0.15s;
  color: rgba(255,255,255,0.9); position: relative; overflow: hidden;
}
.game-btn:disabled { opacity: 0.3; cursor: not-allowed; }
.game-btn:active:not(:disabled) { transform: scale(0.97); }
.game-btn::after {
  content: ''; position: absolute; top: 0; left: -100%;
  width: 100%; height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
  transition: left 0.35s;
}
.game-btn:hover:not(:disabled)::after { left: 100%; }

.btn-icon { font-size: 15px; width: 20px; text-align: center; }
.btn-text { flex: 1; }
.btn-cost {
  font-size: 10px; opacity: 0.6;
  padding: 2px 6px; background: rgba(0,0,0,0.2); border-radius: 3px;
}

.btn-meditate {
  background: linear-gradient(135deg, #6b2000, #8b3010);
  border: 1px solid rgba(139,48,16,0.5);
}
.btn-oneclick {
  background: linear-gradient(135deg, #8b5500, #a06800);
  border: 1px solid rgba(160,104,0,0.5);
}
.btn-breakthrough {
  background: linear-gradient(135deg, #6b5a00, #8b7500);
  border: 1px solid rgba(139,117,0,0.5);
}
.btn-breakthrough.can-break {
  background: linear-gradient(135deg, #c49b30, #e6b800);
  color: #1a1a2e; border-color: rgba(230,184,0,0.5);
  animation: can-brk 2.5s ease-in-out infinite;
}
@keyframes can-brk {
  0%,100% { box-shadow: 0 0 8px rgba(230,184,0,0.2); }
  50% { box-shadow: 0 0 16px rgba(230,184,0,0.4); }
}
.btn-cost.ready { background: rgba(0,0,0,0.25); color: #ffd700; font-weight: 700; }

/* 日志 */
.cult-log { margin: 8px 12px 12px; }

/* === 突破特效 === */
.breakthrough-overlay {
  position: fixed; inset: 0; z-index: 99999;
  background: rgba(0,0,0,0.92);
  display: flex; align-items: center; justify-content: center;
  cursor: pointer;
}
.bt-particles { position: absolute; inset: 0; overflow: hidden; pointer-events: none; }
.bt-particle {
  position: absolute; top: 50%; left: 50%;
  width: 4px; height: 4px; border-radius: 50%;
  animation: bt-exp 1.5s ease-out forwards;
}
@keyframes bt-exp {
  0% { transform: translate(-50%,-50%) scale(0); opacity: 1; }
  100% { transform: translate(calc(-50% + cos(var(--angle))*var(--dist)*3), calc(-50% + sin(var(--angle))*var(--dist)*3)) scale(0); opacity: 0; }
}
.bt-content { position: relative; z-index: 2; text-align: center; }
.bt-flash {
  position: fixed; inset: 0;
  background: radial-gradient(circle, rgba(255,215,0,0.25) 0%, transparent 70%);
  animation: btf 0.8s ease-out forwards; pointer-events: none;
}
@keyframes btf { 0% { opacity:1; transform:scale(0.5); } 100% { opacity:0; transform:scale(2); } }
.bt-icon {
  font-size: 56px;
  animation: bti 0.6s cubic-bezier(0.34,1.56,0.64,1) forwards;
  filter: drop-shadow(0 0 16px rgba(255,215,0,0.6));
}
@keyframes bti { 0% { transform:scale(0) rotate(-180deg); opacity:0; } 100% { transform:scale(1) rotate(0); opacity:1; } }
.bt-title {
  font-size: 24px; font-weight: 800; letter-spacing: 4px; margin-top: 10px;
  background: linear-gradient(180deg, #fff, #ffd700);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
  animation: btt 0.8s ease-out 0.3s both;
}
@keyframes btt { 0% { transform:translateY(12px); opacity:0; } 100% { transform:translateY(0); opacity:1; } }
.bt-realm {
  font-size: 16px; color: #d4a843; margin-top: 4px;
  text-shadow: 0 0 10px rgba(212,168,67,0.4);
  animation: btt 0.8s ease-out 0.5s both;
}
.bt-hint { font-size: 10px; color: #444; margin-top: 16px; animation: btt 0.8s ease-out 0.8s both; }
.breakthrough-fx-enter-active { transition: opacity 0.3s; }
.breakthrough-fx-leave-active { transition: opacity 0.5s; }
.breakthrough-fx-enter-from, .breakthrough-fx-leave-to { opacity: 0; }

@media (max-width: 400px) {
  .progress-ring-container { width: 180px; height: 180px; }
  .current-value { font-size: 24px; }
  .game-btn { padding: 10px 12px; font-size: 13px; }
}
</style>