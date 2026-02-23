<template>
      <n-card :bordered="false">
        <game-guide>
          <p>🏅 完成特定条件解锁成就，获得<strong>焰灵+永久属性加成</strong></p>
          <p>📂 共7大类：装备、探索、战斗、焰修、突破、收集、资源、焰炼</p>
          <p>💪 成就奖励包括：伤害加成、防御加成、幸运值、焰灵速率等</p>
          <p>🎯 每类10个成就，由易到难逐步解锁</p>
        </game-guide>
        <n-tabs type="line">
          <n-tab-pane
            v-for="category in achievementCategories"
            :key="category.key"
            :name="category.key"
            :tab="category.name"
          >
            <n-space vertical>
              <n-grid :cols="2" :x-gap="12" :y-gap="8">
                <n-grid-item v-for="achievement in category.achievements" :key="achievement.id">
                  <n-card
                    :class="{ completed: isAchievementCompleted(achievement.id) }"
                    size="small"
                    hoverable
                    @click="showAchievementDetails(achievement)"
                  >
                    <template #header>
                      <n-space justify="space-between" align="center">
                        <span>{{ achievement.name }}</span>
                        <n-tag :type="isAchievementCompleted(achievement.id) ? 'success' : 'default'">
                          {{ isAchievementCompleted(achievement.id) ? '已完成' : '未完成' }}
                        </n-tag>
                      </n-space>
                    </template>
                    <p>{{ achievement.description }}</p>
                    <n-progress
                      type="line"
                      :percentage="getProgress(achievement)"
                      :color="isAchievementCompleted(achievement.id) ? '#18a058' : '#2080f0'"
                      :height="8"
                      :border-radius="4"
                      :show-indicator="true"
                    />
                  </n-card>
                </n-grid-item>
              </n-grid>
            </n-space>
          </n-tab-pane>
        </n-tabs>
      </n-card>
</template>

<script setup>
  import { usePlayerStore } from '../stores/player'
  import { achievements, getAchievementProgress } from '../plugins/achievements'
  import { ref, onMounted } from 'vue'
  import { useMessage } from 'naive-ui'
  import { checkAchievements } from '../plugins/achievements'
  import GameGuide from '../components/GameGuide.vue'

  const playerStore = usePlayerStore()
  const message = useMessage()

  // 检查成就完成情况
  onMounted(() => {
    const newlyCompletedAchievements = checkAchievements(playerStore)
    // 显示新完成的成就
    newlyCompletedAchievements.forEach(achievement => {
      message.success(`恭喜解锁新焰功：${achievement.name}！\n\n${achievement.description}`, { duration: 3000 })
    })
  })

  // 获取成就类别名称
  const getCategoryName = (category) => {
    const categoryNames = {
      equipment: '装备焰功',
      dungeon_explore: '焚天塔探索',
      dungeon_combat: '焚天塔战斗',
      cultivation: '冥想焰功',
      breakthrough: '突破焰功',
      exploration: '探索焰功',
      collection: '收集焰功',
      resources: '资源焰功',
      alchemy: '焰炼焰功'
    }
    return categoryNames[category] || '其他焰功'
  }

  // 获取所有成就类别
  const achievementCategories = Object.entries(achievements).map(([key, value]) => ({
    key,
    name: getCategoryName(key),
    achievements: value
  }))

  // 检查成就是否完成
  const isAchievementCompleted = achievementId => {
    return playerStore.completedAchievements.includes(achievementId)
  }

  // 显示成就详情
  const showAchievementDetails = achievement => {
    let rewardText = '奖励：'
    if (achievement.reward) {
      if (achievement.reward.spirit) rewardText += `\n${achievement.reward.spirit} 焰灵`
      if (achievement.reward.spiritRate)
        rewardText += `\n${(achievement.reward.spiritRate * 100 - 100).toFixed(0)}% 焰灵获取提升`
      if (achievement.reward.herbRate)
        rewardText += `\n${(achievement.reward.herbRate * 100 - 100).toFixed(0)}% 焰草获取提升`
      if (achievement.reward.alchemyRate)
        rewardText += `\n${(achievement.reward.alchemyRate * 100 - 100).toFixed(0)}% 焰炼成功率提升`
      if (achievement.reward.luck) rewardText += `\n${(achievement.reward.luck * 100 - 100).toFixed(0)}% 幸运提升`
    }
    message.info(`${achievement.name}\n\n${achievement.description}\n\n${rewardText}`, { duration: 5000 })
  }

  // 获取成就进度
  const getProgress = achievement => {
    try {
      const progress = getAchievementProgress(playerStore, achievement)
      return Number.isFinite(progress) ? Math.min(100, Math.max(0, Math.round(progress))) : 0
    } catch (error) {
      console.error('成就进度报错:', error)
      return 0
    }
  }
</script>

<style scoped>
  .completed {
    background-color: rgba(24, 160, 88, 0.1);
  }
  @media (max-width: 500px) {
    :deep(.n-grid) {
      display: grid !important;
      grid-template-columns: 1fr !important;
    }
    :deep(.n-grid .n-gi) {
      grid-column: auto !important;
    }
  }
</style>
