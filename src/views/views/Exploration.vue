<template>
  <div class="explore-page">
    <!-- 地图区域 -->
    <div class="world-map">
      <div class="map-title">
        <span class="map-icon">🗺️</span>
        <span>焰天圣域地图</span>
        <span class="map-spirit">焰灵: {{ playerStore.spirit.toFixed(0) }}</span>
      </div>
      <div class="map-grid">
        <div
          v-for="loc in allLocations"
          :key="loc.id"
          class="map-node"
          :class="{
            locked: playerStore.level < loc.minLevel,
            active: selectedLocation?.id === loc.id,
            exploring: exploringLocations[loc.id]
          }"
          @click="selectLocation(loc)"
        >
          <div class="node-bg" :class="'bg-' + loc.id"></div>
          <div class="node-content">
            <span class="node-icon">{{ loc.icon }}</span>
            <span class="node-name">{{ loc.name }}</span>
            <span v-if="playerStore.level < loc.minLevel" class="node-lock">🔒 {{ getRealmName(loc.minLevel).name }}</span>
            <span v-else-if="exploringLocations[loc.id]" class="node-status exploring-pulse">探索中...</span>
            <span v-else class="node-cost">⚡{{ loc.spiritCost }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 选中地点详情 -->
    <transition name="slide">
      <div v-if="selectedLocation" class="location-detail">
        <n-card size="small">
          <div class="detail-header">
            <span class="detail-icon">{{ selectedLocation.icon }}</span>
            <div class="detail-info">
              <span class="detail-name">{{ selectedLocation.name }}</span>
              <span class="detail-desc">{{ selectedLocation.description }}</span>
            </div>
          </div>
          <n-space :size="8" style="margin-top:12px">
            <n-tag type="info" size="small">焰灵消耗: {{ selectedLocation.spiritCost }}</n-tag>
            <n-tag type="warning" size="small">最低焰阶: {{ getRealmName(selectedLocation.minLevel).name }}</n-tag>
          </n-space>
          <n-space style="margin-top:12px" :size="8">
            <n-button
              type="primary"
              @click="exploreLocation(selectedLocation)"
              :disabled="playerStore.spirit < selectedLocation.spiritCost || isAutoExploring || playerStore.level < selectedLocation.minLevel"
            >
              🔍 探索一次
            </n-button>
            <n-button
              :type="exploringLocations[selectedLocation.id] ? 'warning' : 'success'"
              @click="exploringLocations[selectedLocation.id] ? stopAutoExploration(selectedLocation) : startAutoExploration(selectedLocation)"
              :disabled="playerStore.spirit < selectedLocation.spiritCost || (isAutoExploring && !exploringLocations[selectedLocation.id]) || playerStore.level < selectedLocation.minLevel"
            >
              {{ exploringLocations[selectedLocation.id] ? '⏹ 停止' : '🔄 自动探索' }}
            </n-button>
          </n-space>
        </n-card>
      </div>
    </transition>

    <!-- 探索统计 -->
    <div class="explore-stats">
      <n-card size="small" title="📊 探索统计">
        <n-space :size="16">
          <span>探索 {{ playerStore.explorationCount }} 次</span>
          <span>焰晶 {{ playerStore.spiritStones }}</span>
          <span>焰草 {{ playerStore.herbs.length }}</span>
          <span>焰方残页 {{ Object.values(playerStore.pillFragments || {}).reduce((a, b) => a + b, 0) }}</span>
        </n-space>
      </n-card>
    </div>

    <!-- 日志 -->
    <n-space justify="end" style="margin-bottom: 8px">
      <n-button size="small" @click="clearLogPanel" type="error" secondary>清空日志</n-button>
    </n-space>
    <log-panel ref="logRef" title="探索日志" />
  </div>
</template>

<script setup>
  import { ref, computed, onMounted, onUnmounted } from 'vue'
  import { usePlayerStore } from '../stores/player'
  import { CompassOutline } from '@vicons/ionicons5'
  import { getRealmName } from '../plugins/realm'
  import { locations } from '../plugins/locations'
  import { triggerRandomEvent, getRandomReward, handleReward } from '../plugins/events'
  import LogPanel from '../components/LogPanel.vue'

  const logRef = ref(null)
  const playerStore = usePlayerStore()
  const selectedLocation = ref(null)

  // 地点图标映射
  const locationIcons = {
    newbie_village: '🏘️',
    celestial_mountain: '⛰️',
    phoenix_valley: '🔥',
    dragon_abyss: '🐉',
    immortal_realm: '✨'
  }

  // 所有地点（含图标）
  const allLocations = computed(() =>
    locations.map(loc => ({ ...loc, icon: locationIcons[loc.id] || '🗺️' }))
  )

  const selectLocation = (loc) => {
    if (playerStore.level >= loc.minLevel) {
      selectedLocation.value = loc
    }
  }
  // 探索相关数值
  const explorationInterval = 3000 // 探索间隔（毫秒）
  const exploringLocations = ref({}) // 记录每个地点的探索状态
  const explorationTimers = ref({}) // 记录每个地点的定时器
  const isAutoExploring = ref(false) // 是否有地点正在自动探索
  const autoExploringLocationId = ref(null) // 正在自动探索的地点ID
  const explorationWorker = ref(null)

  // 初始化 Web Worker
  const initWorker = () => {
    explorationWorker.value = new Worker(new URL('../workers/exploration.js', import.meta.url), { type: 'module' })
    explorationWorker.value.onmessage = ({ data }) => {
      if (data.type === 'exploration_result') {
        handleExplorationResult(data)
      } else if (data.type === 'error') {
        showMessage('error', data.message)
      }
    }
  }

  // 处理探索结果
  const handleExplorationResult = result => {
    playerStore.spirit -= result.spiritCost
    playerStore.explorationCount++

    if (result.eventTriggered) {
      if (triggerRandomEvent(playerStore, showMessage)) {
        showMessage('info', '你的福缘不错，触发了一个特殊事件！')
      }
    } else {
      const location = availableLocations.value.find(loc => loc.spiritCost === result.spiritCost)
      if (location && Array.isArray(location.rewards)) {
        const reward = getRandomReward(location.rewards)
        if (reward) {
          if (result.rewardMultiplier > 1) {
            reward.amount = Math.floor(reward.amount * result.rewardMultiplier)
            showMessage('success', '福缘加持，获得了更多奖励！')
          }
          handleReward(reward, playerStore, showMessage)
        }
      } else {
        showMessage('error', '无法获取探索奖励，请检查地点配置')
      }
    }
    playerStore.saveData()
  }

  // 探索指定地点
  const exploreLocation = location => {
    if (playerStore.spirit < location.spiritCost) {
      showMessage('error', '焰灵不足！')
      return
    }
    explorationWorker.value.postMessage({
      type: 'explore',
      playerData: { luck: playerStore.luck },
      location
    })
  }

  // 组件挂载时初始化 Worker
  onMounted(() => {
    initWorker()
  })

  // 组件卸载时清理 Worker 和定时器
  onUnmounted(() => {
    if (explorationWorker.value) {
      explorationWorker.value.terminate()
    }
    Object.values(explorationTimers.value).forEach(timer => clearInterval(timer))
    explorationTimers.value = {}
    exploringLocations.value = {}
  })

  // 获取可用地点列表
  const availableLocations = computed(() => {
    return locations.filter(loc => playerStore.level >= loc.minLevel)
  })

  // 显示消息并处理重复
  const showMessage = (type, content) => {
    return logRef.value?.addLog(type, content)
  }

  // 开始自动探索
  const startAutoExploration = location => {
    if (exploringLocations.value[location.id] || isAutoExploring.value) return
    isAutoExploring.value = true
    autoExploringLocationId.value = location.id
    exploringLocations.value[location.id] = true
    explorationTimers.value[location.id] = setInterval(() => {
      if (playerStore.spirit >= location.spiritCost) {
        exploreLocation(location)
      } else {
        stopAutoExploration(location)
        showMessage('warning', '焰灵不足，自动探索已停止！')
      }
    }, explorationInterval)
  }

  // 停止自动探索
  const stopAutoExploration = location => {
    if (explorationTimers.value[location.id]) {
      clearInterval(explorationTimers.value[location.id])
      delete explorationTimers.value[location.id]
    }
    exploringLocations.value[location.id] = false
    isAutoExploring.value = false
    autoExploringLocationId.value = null
  }

  // 组件卸载时清理所有定时器
  onUnmounted(() => {
    Object.values(explorationTimers.value).forEach(timer => clearInterval(timer))
    explorationTimers.value = {}
    exploringLocations.value = {}
  })

  const clearLogPanel = () => {
    logRef.value?.clearLogs()
  }
</script>

<style scoped>
.explore-page { padding: 0; }

.world-map {
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(212,168,67,0.2);
  margin-bottom: 12px;
  background: linear-gradient(180deg, #0a0a15 0%, #12102a 100%);
}
.map-title {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 14px;
  font-weight: bold;
  color: #d4a843;
  font-size: 14px;
  border-bottom: 1px solid rgba(212,168,67,0.15);
}
.map-icon { font-size: 18px; }
.map-spirit {
  margin-left: auto;
  font-size: 12px;
  color: #a09880;
  font-weight: normal;
}

.map-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  padding: 12px;
}

.map-node {
  position: relative;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.3s;
  border: 1px solid rgba(212,168,67,0.15);
  min-height: 100px;
}
.map-node:hover:not(.locked) {
  transform: translateY(-2px);
  border-color: rgba(212,168,67,0.5);
  box-shadow: 0 4px 15px rgba(0,0,0,0.3), 0 0 10px rgba(212,168,67,0.1);
}
.map-node.active {
  border-color: #d4a843;
  box-shadow: 0 0 15px rgba(212,168,67,0.2);
}
.map-node.locked {
  opacity: 0.4;
  cursor: not-allowed;
  filter: grayscale(0.8);
}
.map-node.exploring {
  border-color: #4caf50;
  box-shadow: 0 0 12px rgba(76,175,80,0.2);
}

.node-bg {
  position: absolute;
  inset: 0;
  opacity: 0.4;
}
.bg-newbie_village { background: linear-gradient(135deg, #1a3a1a, #0d1a0d); }
.bg-celestial_mountain { background: linear-gradient(135deg, #1a2a3a, #0d1520); }
.bg-phoenix_valley { background: linear-gradient(135deg, #3a1a1a, #200d0d); }
.bg-dragon_abyss { background: linear-gradient(135deg, #1a1a3a, #0d0d20); }
.bg-immortal_realm { background: linear-gradient(135deg, #3a2a1a, #201a0d); }

.node-content {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 12px 6px;
  gap: 4px;
}
.node-icon { font-size: 28px; }
.node-name {
  font-size: 12px;
  font-weight: bold;
  color: #e8e0d0;
}
.node-lock {
  font-size: 10px;
  color: #666;
}
.node-cost {
  font-size: 11px;
  color: #a09880;
}
.node-status {
  font-size: 10px;
  color: #4caf50;
  font-weight: bold;
}
.exploring-pulse {
  animation: epulse 1.5s ease-in-out infinite;
}
@keyframes epulse {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

/* 详情面板 */
.location-detail { margin-bottom: 12px; }
.detail-header {
  display: flex;
  align-items: center;
  gap: 12px;
}
.detail-icon { font-size: 36px; }
.detail-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.detail-name {
  font-size: 16px;
  font-weight: bold;
  color: #f0d68a;
  font-family: 'Noto Serif SC', serif;
}
.detail-desc {
  font-size: 12px;
  color: #a09880;
}

.explore-stats { margin-bottom: 12px; }
.explore-stats span {
  font-size: 12px;
  color: #a09880;
}

/* 过渡动画 */
.slide-enter-active { transition: all 0.3s ease; }
.slide-leave-active { transition: all 0.2s ease; }
.slide-enter-from { opacity: 0; transform: translateY(-10px); }
.slide-leave-to { opacity: 0; transform: translateY(-10px); }

@media (max-width: 480px) {
  .map-grid { grid-template-columns: repeat(2, 1fr); }
  .map-node { min-height: 80px; }
  .node-icon { font-size: 22px; }
}
</style>
