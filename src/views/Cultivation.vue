<template>
  <n-card>
    <n-space vertical>
      <game-guide>
        <p>🧘 <strong>冥想</strong>消耗焰灵获得焰力，焰力达到上限后可<strong>突破焰阶</strong></p>
        <p>⬆️ 突破提升境界，解锁新地点和功能，共14大境界126级</p>
        <p>⚡ 焰灵自动恢复，速率随等级提升（每秒 2+等级×0.5）</p>
        <p>🔮 VIP/月卡/修炼加速卡可叠加冥想加成，最高2.7倍</p>
        <p>🤖 <strong>一键冥想</strong>一次性消耗所有焰灵转化为焰力（服务端计算，防作弊）</p>
        <p>💤 离线最多累积<strong>12小时</strong>收益（焰力+焰晶+焰灵）</p>
      </game-guide>
      <n-alert type="info" show-icon>
        <template #icon>
          <n-icon>
            <book-outline />
          </n-icon>
          <GuideTooltip v-if="showGuide" :title="guideTexts.cultivation.title" :text="guideTexts.cultivation.text" @dismiss="dismissGuide" />

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
        通过焰心冥想来提升焰力，积累足够的焰力后可以尝试突破焰阶。
      </n-alert>
      <n-space vertical>
        <n-button type="primary" size="large" block @click="cultivate" :disabled="playerStore.spirit < cultivationCost">
          焰心冥想 (消耗 {{ cultivationCost }} 焰灵)
        </n-button>
        <n-button type="success" size="large" block @click="oneClickCultivate" :disabled="playerStore.spirit < cultivationCost">
          一键冥想 (消耗全部焰灵)
        </n-button>
        <n-button
          type="info"
          size="large"
          block
          @click="cultivateUntilBreakthrough"
          :disabled="playerStore.spirit < calculateBreakthroughCost()"
        >
          焰力突破
        </n-button>
      </n-space>
      <n-divider>冥想详情</n-divider>
      <div class="realm-display">
        <img :src="realmIcon" class="realm-icon" loading="lazy" />
        <div class="realm-text">
          <span class="realm-name">{{ realmInfo?.name }}</span>
        </div>
      </div>
      <n-descriptions bordered>
        <n-descriptions-item label="焰灵恢复速率">{{ playerStore.getSpiritRegen().toFixed(1) }} / 秒</n-descriptions-item>
        <n-descriptions-item label="冥想效率">{{ cultivationGain }} 焰力 / 次</n-descriptions-item>
        <n-descriptions-item label="突破所需焰力">
          {{ playerStore.maxCultivation }}
        </n-descriptions-item>
      </n-descriptions>
      <log-panel ref="logRef" title="冥想日志" />
    </n-space>
  </n-card>
</template>

<script setup>
import { hasSeenGuide, markGuideSeen, guideTexts } from "../utils/guide.js"
import GuideTooltip from "../components/GuideTooltip.vue"
  import { usePlayerStore } from '../stores/player'
  import { useGameConfigStore } from '../stores/gameConfig'
  import { ref, computed, onMounted, onUnmounted } from 'vue'
  import { NIcon } from 'naive-ui'
  import { BookOutline } from '@vicons/ionicons5'
  import { getRealmName, getRealmImage } from '../plugins/realm'
  import LogPanel from '../components/LogPanel.vue'
  import GameGuide from '../components/GameGuide.vue'

  const showGuide = ref(!hasSeenGuide("cultivation"))
const showBreakthrough = ref(false)
const breakthroughRealm = ref('')
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

  // 自动修炼状态（从 store 读取）

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
  .n-space { width: 100%; }
  .n-button { margin-bottom: 12px; }
  .n-collapse { margin-top: 12px; }

  .realm-display {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
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
    width: 64px;
    height: 64px;
    border-radius: 12px;
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
    font-size: 18px;
    font-weight: bold;
    color: #f0d68a;
    text-shadow: 0 0 8px rgba(212,168,67,0.4);
    font-family: 'Noto Serif SC', serif;
  }

  /* 按钮美化 */
  :deep(.n-button--primary-type) {
    background: linear-gradient(135deg, #3498db, #2980b9) !important;
    border: none !important;
    box-shadow: 0 2px 12px rgba(52,152,219,0.3);
    transition: all 0.2s;
  }
  :deep(.n-button--primary-type:active) {
    transform: scale(0.97);
    box-shadow: 0 1px 6px rgba(52,152,219,0.3);
  }
  :deep(.n-button--success-type) {
    background: linear-gradient(135deg, #2ecc71, #27ae60) !important;
    border: none !important;
    box-shadow: 0 2px 12px rgba(46,204,113,0.3);
  }
  :deep(.n-button--success-type:active) {
    transform: scale(0.97);
  }
  :deep(.n-button--info-type) {
    background: linear-gradient(135deg, #d4a843, #b8860b) !important;
    border: none !important;
    box-shadow: 0 2px 12px rgba(212,168,67,0.3);
    color: #0a0a1a !important;
    font-weight: 600;
  }

  /* 进度条美化 */
  :deep(.n-progress .n-progress-graph-line-fill) {
    transition: width 0.5s ease;
  }

  /* 突破全屏特效 */
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
</style>
