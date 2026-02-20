<template>
  <n-card>
    <n-space vertical>
      <n-alert type="info" show-icon>
        <template #icon>
          <n-icon>
            <book-outline />
          </n-icon>
        </template>
        通过焰心冥想来提升焰力，积累足够的焰力后可以尝试突破焰阶。
      </n-alert>
      <n-space vertical>
        <n-button type="primary" size="large" block @click="cultivate" :disabled="playerStore.spirit < cultivationCost">
          焰心冥想 (消耗 {{ cultivationCost }} 焰灵)
        </n-button>
        <n-button :type="isAutoCultivating ? 'warning' : 'success'" size="large" block @click="toggleAutoCultivation">
          {{ isAutoCultivating ? '停止自动冥想' : '开始自动冥想' }}
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
      <n-descriptions bordered>
        <n-descriptions-item label="焰灵获取速率">{{ baseGainRate * playerStore.spiritRate }} / 秒</n-descriptions-item>
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
  import { usePlayerStore } from '../stores/player'
  import { ref, onMounted, onUnmounted } from 'vue'
  import { NIcon } from 'naive-ui'
  import { BookOutline } from '@vicons/ionicons5'
  import LogPanel from '../components/LogPanel.vue'

  const playerStore = usePlayerStore()
  const logRef = ref(null)

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
  const baseCultivationGain = 1 // 基础修炼获得的修为
  const autoGainInterval = 1000 // 自动获取焰灵的间隔（毫秒）
  const extraCultivationChance = 0.3 // 获得额外修为的基础概率

  // 计算当前境界的修炼消耗
  const getCurrentCultivationCost = () => {
    return Math.floor(baseCultivationCost * Math.pow(1.5, playerStore.level - 1))
  }

  // 计算当前境界的修炼获得
  const getCurrentCultivationGain = () => {
    return Math.floor(baseCultivationGain * Math.pow(1.2, playerStore.level - 1))
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

  // 自动修炼状态
  const isAutoCultivating = ref(false)
  const cultivationTimer = ref(null)

  // 显示消息并处理重复
  const showMessage = (type, content) => {
    return logRef.value?.addLog(type, content)
  }

  // 计算实际获得的修为
  const calculateCultivationGain = () => {
    let gain = cultivationGain.value
    // 活动加成
    if (eventMultiplier.value > 1) gain = Math.floor(gain * eventMultiplier.value)
    // 根据幸运值计算是否获得额外修为
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
  const cultivationWorker = new Worker(new URL('../workers/cultivation.js', import.meta.url), { type: 'module' })

  // 处理Worker消息
  cultivationWorker.onmessage = ({ data }) => {
    if (data.type === 'error') {
      showMessage('error', data.message)
      return
    }
    if (data.type === 'success') {
      const { spiritCost, cultivationGain, doubleGainTimes } = data.result
      // 扣除焰灵
      playerStore.spirit -= spiritCost
      // 增加修为
      playerStore.cultivate(cultivationGain)
      if (doubleGainTimes > 0) {
        showMessage('success', `福缘不错，获得${doubleGainTimes}次双倍焰力！`)
      }
      // 尝试突破
      if (canBreakthrough() && playerStore.tryBreakthrough()) {
        showMessage('success', `突破成功！恭喜进入${playerStore.realm}！`)
      } else if (canBreakthrough()) {
        showMessage('info', '已达到突破条件，但突破失败，请继续努力！')
      } else {
        showMessage('success', '冥想成功！')
      }
    }
  }

  // 一键修炼（直到突破）
  const cultivateUntilBreakthrough = () => {
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
        if (playerStore.tryBreakthrough()) {
          showMessage('success', `突破成功！恭喜进入${playerStore.realm}！`)
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
  const cultivate = () => {
    try {
      const currentCost = getCurrentCultivationCost()
      if (playerStore.spirit >= currentCost) {
        const oldRealm = playerStore.realm
        playerStore.spirit -= currentCost
        playerStore.cultivate(calculateCultivationGain())
        // 检查是否发生突破
        if (playerStore.realm !== oldRealm) {
          showMessage('success', `突破成功！恭喜进入${playerStore.realm}！`)
        } else {
          showMessage('success', '冥想成功！')
        }
      } else {
        showMessage('error', '焰灵不足！')
      }
    } catch (error) {
      console.error('修炼出错：', error)
      showMessage('error', '冥想失败！')
    }
  }

  // 切换自动修炼
  const toggleAutoCultivation = () => {
    try {
      isAutoCultivating.value = !isAutoCultivating.value
      if (isAutoCultivating.value) {
        if (cultivationTimer.value) return
        cultivationTimer.value = setInterval(() => {
          const currentCost = getCurrentCultivationCost()
          if (playerStore.spirit >= currentCost) {
            playerStore.spirit -= currentCost
            playerStore.cultivate(cultivationGain.value)
          }
        }, autoGainInterval)
      } else {
        if (cultivationTimer.value) {
          clearInterval(cultivationTimer.value)
          cultivationTimer.value = null
        }
      }
    } catch (error) {
      console.error('切换自动冥想出错：', error)
      logRef.value?.addLog('error', '切换失败！')
      isAutoCultivating.value = false
    }
  }

  // 组件卸载时清理定时器
  onMounted(() => {
    fetchEventEffects()
  })

  onUnmounted(() => {
    try {
      if (cultivationTimer.value) {
        clearInterval(cultivationTimer.value)
        cultivationTimer.value = null
      }
      isAutoCultivating.value = false
    } catch (error) {
      console.error('清理定时器出错：', error)
    }
  })
</script>

<style scoped>
  .n-space {
    width: 100%;
  }

  .n-button {
    margin-bottom: 12px;
  }

  .n-collapse {
    margin-top: 12px;
  }
</style>
