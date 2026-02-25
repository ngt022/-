<template>
  <div class="explore-page">
    <game-guide>
      <p>🗺️ 探索不同地点，获得<strong>焰草、焰晶、焰力、丹方残页</strong></p>
      <p>📍 5个地点：薪火村(1级)→赤霄峰(10级)→涅槃谷(19级)→焰渊(28级)→焰天圣域(37级)</p>
      <p>🍀 <strong>幸运值</strong>影响焰草品质和探索奖励</p>
      <p>⚡ 探索消耗焰灵：薪火村50→赤霄峰300→涅槃谷500→焰渊750→焰天圣域1000</p>
      <p>🎲 可能触发随机事件：古修遗府(大量奖励)、顿悟、灵泉等</p>
      <p>🤖 开启<strong>自动探索</strong>每3秒探索一次，焰灵不足自动停止</p>
    </game-guide>
    <!-- 地图区域 -->
    <div class="world-map">
      <div class="map-title">
        <span class="map-icon">🗺️</span>
        <span>焰天圣域地图</span>
        <span class="map-spirit">焰灵: {{ playerStore.spirit.toFixed(0) }}/{{ playerStore.getMaxSpirit() }}</span>
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
          <div class="node-bg" :class="'bg-' + loc.id" :style="locationBgImages[loc.id] ? { background: `linear-gradient(rgba(0,0,0,0.5), rgba(0,0,0,0.7)), url(${locationBgImages[loc.id]}) center/cover no-repeat` } : {}"></div>
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
              :disabled="playerStore.spirit < selectedLocation.spiritCost || isAutoExploring || playerStore.level < selectedLocation.minLevel || isExploring"
              :loading="isExploring"
            >
              🔍 探索一次
            </n-button>
            <n-button
              :type="exploringLocations[selectedLocation.id] ? 'warning' : 'success'"
              @click="exploringLocations[selectedLocation.id] ? stopAutoExploration(selectedLocation) : startAutoExploration(selectedLocation)"
              :disabled="playerStore.spirit < selectedLocation.spiritCost || (isAutoExploring && !exploringLocations[selectedLocation.id]) || playerStore.level < selectedLocation.minLevel || isExploring"
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
    <!-- 随机事件弹窗 -->
    <n-modal v-model:show="showRandomEvent" preset="card" title="✨ 随机事件" style="width: 85%; max-width: 400px">
      <div v-if="randomEventData" style="text-align: center; padding: 16px 0;">
        <div style="font-size: 40px; margin-bottom: 12px;">
          {{ {treasure_chest:"🎁",mysterious_npc:"👴",herb_garden:"🌿",ancient_ruin:"🏛️",spirit_spring:"💧",ambush:"⚔️"}[randomEventData.id] || "✨" }}
        </div>
        <h3 style="color: #ffd700; margin: 0 0 8px; font-size: 18px;">{{ randomEventData.name }}</h3>
        <p style="color: rgba(240,214,138,0.7); font-size: 14px; margin: 0 0 16px;">{{ randomEventData.desc }}</p>
        <div style="background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.15); border-radius: 8px; padding: 10px; color: #d4a843; font-size: 13px;">
          奖励：
          <span v-if="randomEventData.reward.spiritStones">💎 {{ randomEventData.reward.spiritStones }} 焰晶</span>
          <span v-if="randomEventData.reward.reinforceStones">🔨 {{ randomEventData.reward.reinforceStones }} 淬火石</span>
          <span v-if="randomEventData.reward.cultivation">📖 {{ randomEventData.reward.cultivation }} 焰修</span>
          <span v-if="randomEventData.reward.spiritFull">🔥 焰灵恢复满</span>
        </div>
      </div>
    </n-modal>
  </div>
  <GuideTooltip v-if="showGuide" v-bind="guideTexts.exploration || {}" @dismiss="dismissGuide" />
</template>

<script setup>
import img from '../utils/img.js'
import { hasSeenGuide, markGuideSeen, guideTexts } from '../utils/guide.js'
import GuideTooltip from '../components/GuideTooltip.vue'
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { getRealmName } from '../plugins/realm'
import { locations } from '../plugins/locations'
import { triggerRandomEvent, getRandomReward, handleReward } from '../plugins/events'
import LogPanel from '../components/LogPanel.vue'
import GameGuide from '../components/GameGuide.vue'

const logRef = ref(null)
const showGuide = ref(!hasSeenGuide("explomation"))
const randomEventData = ref(null)
const showRandomEvent = ref(false)
const dismissGuide = () => { markGuideSeen("exploration"); showGuide.value = false }
const playerStore = usePlayerStore()
const authStore = useAuthStore()
const selectedLocation = ref(null)
const isExploring = ref(false)

// 地点图标映射
const locationIcons = {
  newbie_village: '🏘️',
  celestial_mountain: '⛰️',
  phoenix_valley: '🔥',
  dragon_abyss: '🐉',
  immortal_realm: '✨'
}

// 地点背景图映射
const locationBgImages = {
  newbie_village: img('/assets/images/area-xinhuocun.png'),
  celestial_mountain: img('/assets/images/area-chixiaofeng.png'),
  phoenix_valley: img('/assets/images/area-niepangu.png'),
  dragon_abyss: img('/assets/images/area-yanyuan.png'),
  immortal_realm: img('/assets/images/area-yantianshenyu.png'),
  void_realm: img('/assets/images/area-yanxumijing.png'),
  fusion_forbidden: img('/assets/images/area-yanhejindi.png'),
  great_flame_palace: img('/assets/images/area-dayantiangong.png'),
  tribulation_temple: img('/assets/images/area-duyanshengdian.png')
}

// 所有地点（含图标）
const allLocations = computed(() =>
  locations.map(loc => ({ ...loc, icon: locationIcons[loc.id] || '🗺️' }))
)

const selectLocation = (loc) => {
  if (playerStore.level >= loc.minLevel) {
    selectedLocation.value = loc
  } else {
    window.$message?.warning(`需要达到 ${getRealmName(loc.minLevel).name} 才能探索此地`)
  }
}

// 探索相关数值
const explorationInterval = 3000 // 探索间隔（毫秒）
const exploringLocations = ref({}) // 记录每个地点的探索状态
const explorationTimers = ref({}) // 记录每个地点的定时器
const isAutoExploring = ref(false) // 是否有地点正在自动探索

// 显示消息并处理重复
const showMessage = (type, content) => {
  if (logRef.value?.addLog) {
    return logRef.value.addLog(type, content)
  }
  // fallback to global message
  if (type === "error") window.$message?.error(content)
  else if (type === "success") window.$message?.success(content)
  else window.$message?.info(content)
}

// 探索指定地点
const exploreLocation = async (location) => {
  if (isExploring.value) return
  
  // 战斗时停止自动冥想
  playerStore.stopAutoCultivation()
  
  if (playerStore.spirit < location.spiritCost) {
    showMessage('error', '焰灵不足！')
    return
  }

  isExploring.value = true

  // 未登录用户使用本地探索
  if (!authStore.isLoggedIn) {
    localExplore(location)
    isExploring.value = false
    return
  }

  // 已登录用户调用API
  try {
    const response = await fetch('/api/exploration/explore', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + authStore.token
      },
      body: JSON.stringify({
        locationId: location.id
      })
    })

    const result = await response.json()
    
    if (!response.ok) {
      if (result.remainingSeconds) {
        showMessage('error', `冷却中，${result.remainingSeconds}秒后可再次探索`)
      } else {
        showMessage('error', result.error || '探索失败')
      }
      if (isAutoExploring.value && selectedLocation.value?.id === location.id) {
        stopAutoExploration(location)
      }
      isExploring.value = false
      return
    }

    if (result.success) {
      // 更新前端状态
      playerStore.spirit = result.spirit
      playerStore.spiritStones = Number(result.spiritStones) || 0
      playerStore.cultivation = result.cultivation
      playerStore.explorationCount++

      // 处理事件
      if (result.event) {
        showMessage('info', `[${result.event.name}]${result.event.description}`)
        if (result.event.effect) {
          const eff = result.event.effect
          if (eff.type === 'cultivation') {
            showMessage('success', `[${result.event.name}]领悟石碑上的功法，获得${eff.amount}点焰修`)
          } else if (eff.type === 'spirit') {
            showMessage('success', `[${result.event.name}]饮用灵泉，焰灵增加${eff.amount}点`)
          } else if (eff.type === 'double') {
            showMessage('success', `[${result.event.name}]获得上古大能传承，焰修增加${eff.cultivation}点，焰灵增加${eff.spirit}点`)
          } else if (eff.type === 'stones') {
            showMessage('success', `[${result.event.name}]发现宝藏，获得${eff.amount}颗焰晶`)
          } else if (eff.type === 'enlightenment') {
            showMessage('success', `[${result.event.name}]突然顿悟，获得${eff.cultivation}点焰修，焰灵获取速率提升5%`)
          } else if (eff.type === 'damage') {
            if (eff.spirit && eff.cultivation) {
              showMessage('error', `[${result.event.name}]遭受心魔侵扰，损失${eff.spirit}点焰灵和修为`)
            } else if (eff.spirit) {
              showMessage('error', `[${result.event.name}]与黑焰兽激战，损失${eff.spirit}点焰灵`)
            } else if (eff.cultivation) {
              showMessage('error', `[${result.event.name}]走火入魔，损失${eff.cultivation}点焰修`)
            }
          }
        }
      }

      // 处理奖励
      if (result.reward) {
        const reward = result.reward
        if (reward.type === 'spirit_stone') {
          showMessage('success', `[焰晶获取]获得${reward.amount}颗焰晶`)
        } else if (reward.type === 'herb') {
          showMessage('success', `[焰草获取]获得${reward.amount}个焰草`)
          // 焰草已在服务端添加到game_data，前端需要刷新数据
          await refreshPlayerData()
        } else if (reward.type === 'cultivation') {
          showMessage('success', `[修为获取]获得${reward.amount}点焰修`)
        } else if (reward.type === 'pill_fragment') {
          showMessage('success', `[丹方获取]获得${reward.amount}个丹方残页`)
          // 丹方碎片已在服务端添加到game_data，前端需要刷新数据
          await refreshPlayerData()
        }
      }

      // 检查随机事件
      if (result.randomEvent) {
        randomEventData.value = result.randomEvent
        showRandomEvent.value = true
      }

      playerStore.saveData()
    }
  } catch (e) {
    showMessage('error', '探索失败：' + e.message)
    if (isAutoExploring.value && selectedLocation.value?.id === location.id) {
      stopAutoExploration(location)
    }
  } finally {
    isExploring.value = false
  }
}

// 本地探索（未登录用户）
const localExplore = (location) => {
  playerStore.spirit -= location.spiritCost
  playerStore.explorationCount++

  if (triggerRandomEvent(playerStore, showMessage)) {
    showMessage('info', '你的福缘不错，触发了一个特殊事件！')
  } else {
    const reward = getRandomReward(location.rewards)
    if (reward) {
      handleReward(reward, playerStore, showMessage)
    }
  }
  playerStore.saveData()
}

// 刷新玩家数据
const refreshPlayerData = async () => {
  if (!authStore.isLoggedIn) return
  try {
    const response = await fetch('/api/game/load', {
      headers: {
        'Authorization': 'Bearer ' + authStore.token
      }
    })
    if (response.ok) {
      const result = await response.json()
      if (result.player?.gameData) {
        const gd = result.player.gameData
        if (gd.herbs) playerStore.herbs = gd.herbs
        if (gd.pillFragments) playerStore.pillFragments = gd.pillFragments
      }
    }
  } catch (e) {
    console.warn('刷新数据失败:', e)
  }
}

// 开始自动探索
const startAutoExploration = (location) => {
  if (exploringLocations.value[location.id] || isAutoExploring.value) return
  isAutoExploring.value = true
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
const stopAutoExploration = (location) => {
  if (explorationTimers.value[location.id]) {
    clearInterval(explorationTimers.value[location.id])
    delete explorationTimers.value[location.id]
  }
  exploringLocations.value[location.id] = false
  isAutoExploring.value = false
}

// 组件卸载时清理定时器
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
.explore-page {
  padding: 0;
  background: linear-gradient(180deg, #0b0b18 0%, #12101f 100%);
  min-height: 75vh;
}

/* === 地图区域 === */
.world-map {
  position: relative;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(212,168,67,0.15);
  margin-bottom: 12px;
  background: linear-gradient(180deg, #0a0a15 0%, #10101f 100%);
}
.world-map::before {
  content: '';
  position: absolute; top: 0; left: 0; right: 0;
  height: 80px;
  background: radial-gradient(ellipse at center top, rgba(212,168,67,0.06) 0%, transparent 70%);
  pointer-events: none; z-index: 1;
}

.map-title {
  display: flex; align-items: center; gap: 8px;
  padding: 10px 14px;
  font-weight: 700; color: #d4a843; font-size: 14px;
  border-bottom: 1px solid rgba(212,168,67,0.1);
  letter-spacing: 1px;
}
.map-icon { font-size: 18px; }
.map-spirit {
  margin-left: auto; font-size: 11px;
  color: rgba(212,168,67,0.5); font-weight: normal;
  background: rgba(212,168,67,0.06);
  padding: 2px 8px; border-radius: 4px;
}

.map-grid {
  display: grid; grid-template-columns: repeat(3, 1fr);
  gap: 8px; padding: 12px;
}

/* === 地图节点 === */
.map-node {
  position: relative; border-radius: 10px;
  overflow: hidden; cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid rgba(212,168,67,0.1);
  min-height: 130px;
}
.map-node:hover:not(.locked) {
  transform: translateY(-3px);
  border-color: rgba(212,168,67,0.4);
  box-shadow: 0 6px 20px rgba(0,0,0,0.4), 0 0 15px rgba(212,168,67,0.1);
}
.map-node.active {
  border-color: rgba(212,168,67,0.6);
}
.map-node.active::after {
  content: '';
  position: absolute; inset: -1px;
  border-radius: 11px;
  border: 2px solid rgba(212,168,67,0.5);
  animation: node-pulse 2.5s ease-in-out infinite;
  pointer-events: none; z-index: 2;
}
@keyframes node-pulse {
  0%,100% { box-shadow: 0 0 8px rgba(212,168,67,0.2); }
  50% { box-shadow: 0 0 18px rgba(212,168,67,0.4); }
}
.map-node.locked {
  opacity: 0.3; cursor: not-allowed; filter: grayscale(0.8);
}
.map-node.exploring {
  border-color: rgba(255,165,0,0.4);
}
.map-node.exploring::before {
  content: '';
  position: absolute; inset: 0; border-radius: 10px;
  background: radial-gradient(circle, rgba(255,165,0,0.08) 0%, transparent 70%);
  animation: expl-glow 2s ease-in-out infinite;
  pointer-events: none; z-index: 1;
}
@keyframes expl-glow {
  0%,100% { opacity: 0.4; } 50% { opacity: 1; }
}

.node-bg {
  position: absolute; inset: 0;
  background-size: cover; background-position: center;
  pointer-events: none;
  transition: transform 0.4s ease;
}
.map-node:hover:not(.locked) .node-bg {
  transform: scale(1.05);
}

.bg-newbie_village { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-xinhuocun.png') center/cover no-repeat; }
.bg-celestial_mountain { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-chixiaofeng.png') center/cover no-repeat; }
.bg-phoenix_valley { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-niepangu.png') center/cover no-repeat; }
.bg-dragon_abyss { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-yanyuan.png') center/cover no-repeat; }
.bg-immortal_realm { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-yantianshenyu.png') center/cover no-repeat; }
.bg-void_realm { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-yanxumijing.png') center/cover no-repeat; }
.bg-fusion_forbidden { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-yanhejindi.png') center/cover no-repeat; }
.bg-great_flame_palace { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-dayantiangong.png') center/cover no-repeat; }
.bg-tribulation_temple { background: linear-gradient(rgba(0,0,0,0.45), rgba(0,0,0,0.65)), url('/assets/images/area-duyanshengdian.png') center/cover no-repeat; }

.node-content {
  position: relative; z-index: 1;
  display: flex; flex-direction: column;
  align-items: center; justify-content: center;
  padding: 14px 6px; gap: 4px;
}
.node-icon {
  font-size: 28px;
  filter: drop-shadow(0 0 6px rgba(212,168,67,0.3));
}
.node-name {
  font-size: 12px; font-weight: 700;
  color: #e8e0d0;
  text-shadow: 0 1px 3px rgba(0,0,0,0.6);
}
.node-lock { font-size: 10px; color: #555; }
.node-cost {
  font-size: 11px; color: rgba(212,168,67,0.6);
  background: rgba(0,0,0,0.3);
  padding: 1px 6px; border-radius: 3px;
}
.node-status {
  font-size: 10px; color: #ffa500; font-weight: 700;
}
.exploring-pulse {
  animation: epulse 1.5s ease-in-out infinite;
}
@keyframes epulse { 0%,100% { opacity: 0.5; } 50% { opacity: 1; } }

/* === 详情面板 === */
.location-detail { margin-bottom: 12px; }
.location-detail .n-card {
  background: rgba(15,15,30,0.9) !important;
  border: 1px solid rgba(212,168,67,0.15) !important;
  border-radius: 10px !important;
}
.detail-header { display: flex; align-items: center; gap: 12px; }
.detail-icon {
  font-size: 36px;
  filter: drop-shadow(0 0 8px rgba(212,168,67,0.3));
  transition: transform 0.3s;
}
.location-detail:hover .detail-icon { transform: scale(1.08); }
.detail-info { display: flex; flex-direction: column; gap: 2px; }
.detail-name {
  font-size: 15px; font-weight: 700; color: #f0d68a;
  letter-spacing: 1px;
}
.detail-desc { font-size: 12px; color: rgba(160,152,128,0.7); }

/* === 统计 === */
.explore-stats { margin-bottom: 12px; }
.explore-stats .n-card {
  background: rgba(15,15,30,0.9) !important;
  border: 1px solid rgba(212,168,67,0.1) !important;
  border-radius: 10px !important;
}
.explore-stats span { font-size: 12px; color: rgba(160,152,128,0.7); }

/* === 过渡 === */
.slide-enter-active { transition: all 0.3s ease; }
.slide-leave-active { transition: all 0.2s ease; }
.slide-enter-from { opacity: 0; transform: translateY(-8px); }
.slide-leave-to { opacity: 0; transform: translateY(-8px); }

@media (max-width: 480px) {
  .map-grid { grid-template-columns: repeat(2, 1fr); }
  .map-node { min-height: 110px; }
  .node-icon { font-size: 22px; }
}
</style>