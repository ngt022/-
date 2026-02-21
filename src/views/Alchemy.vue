<template>
  <n-card>
    <n-space vertical>
      <game-guide>
        <p>🧪 收集<strong>丹方残页</strong>→凑齐后自动解锁配方</p>
        <p>🌿 用焰草按配方炼丹，共12种丹方（一品→八品）</p>
        <p>🎲 成功率受品阶影响：一品90%→八品20%，<strong>幸运值和焰炼加成</strong>可提升</p>
        <p>💊 服用焰丹获得临时buff，效果随境界提升（每级+10%）</p>
        <p>📍 丹方残页和焰草主要通过<strong>探索</strong>获得</p>
        <p>⭐ 高品丹效果强力：天元丹焰修+100%、涅槃丹自动回血10%</p>
      </game-guide>
      <template v-if="unlockedRecipes.length > 0">
        <n-divider>焰方选择</n-divider>
        <!-- 焰方选择 -->
        <n-grid :cols="2" :x-gap="12" responsive="screen" :collapsed-rows="99">
          <n-grid-item v-for="recipe in unlockedRecipes" :key="recipe.id">
            <n-card :title="recipe.name" size="small" style="margin-bottom:8px">
              <n-space vertical>
                <n-text depth="3">{{ recipe.description }}</n-text>
                <div class="recipe-materials">
                  <span v-for="mat in recipe.materials" :key="mat.herb" class="mat-tag"
                    :class="{ 'mat-enough': getHerbCount(mat.herb) >= mat.count, 'mat-lack': getHerbCount(mat.herb) < mat.count }">
                    {{ getHerbName(mat.herb) }} {{ getHerbCount(mat.herb) }}/{{ mat.count }}
                  </span>
                </div>
                <div class="recipe-effect">
                  {{ getEffectText(recipe) }}
                </div>
                <n-space>
                  <n-tag type="info">{{ pillGrades[recipe.grade].name }}</n-tag>
                  <n-tag type="warning">{{ pillTypes[recipe.type].name }}</n-tag>
                </n-space>
                <n-button
                  @click="selectRecipe(recipe)"
                  block
                  type="primary"
                >
                  点击炼制
                </n-button>
              </n-space>
            </n-card>
          </n-grid-item>
        </n-grid>
        <GuideTooltip v-if="showGuide" v-bind="guideTexts.alchemy || {}" @dismiss="dismissGuide" />
</template>
      <n-space vertical v-else>
        <n-empty description="暂未掌握任何焰方" />
      </n-space>
      <!-- 炼丹确认弹窗 -->
    <n-modal
      v-model:show="showCraftConfirm"
      preset="card"
      :title="selectedRecipe ? '确认炼制：' + selectedRecipe.name : '炼丹'"
      style="width: 90%; max-width: 500px"
      :closable="false"
      :mask-closable="false"
    >
      <n-space vertical v-if="selectedRecipe">
        <n-text depth="3">{{ selectedRecipe.description }}</n-text>
        <n-space>
          <n-tag type="info">{{ pillGrades[selectedRecipe.grade].name }}</n-tag>
          <n-tag type="warning">{{ pillTypes[selectedRecipe.type].name }}</n-tag>
        </n-space>

        <n-divider>所需材料</n-divider>
        <n-list>
          <n-list-item v-for="material in selectedRecipe.materials" :key="material.herb">
            <n-space justify="space-between" style="width: 100%">
              <n-space>
                <span>{{ getHerbName(material.herb) }}</span>
                <n-tag size="small" type="info">需{{ material.count }}个</n-tag>
              </n-space>
              <n-tag
                :type="playerStore.herbs.filter(h => h.herb_id === material.herb || h.id === material.herb).length >= material.count ? 'success' : 'error'"
                size="small"
              >
                有{{ playerStore.herbs.filter(h => h.herb_id === material.herb || h.id === material.herb).length }}个
              </n-tag>
            </n-space>
          </n-list-item>
        </n-list>

        <n-divider>效果预览</n-divider>
        <n-descriptions bordered :column="1" size="small">
          <n-descriptions-item label="效果数值">+{{ ((currentEffect?.value || 0) * 100).toFixed(1) }}%</n-descriptions-item>
          <n-descriptions-item label="持续时间">{{ Math.floor((currentEffect?.duration || 0) / 60) }}分钟</n-descriptions-item>
          <n-descriptions-item label="成功率">{{ ((currentEffect?.successRate || 0.5) * 100).toFixed(1) }}%</n-descriptions-item>
        </n-descriptions>

        <n-space justify="end" style="width: 100%; margin-top: 16px">
          <n-button @click="closeCraftConfirm">取消</n-button>
          <n-button
            class="craft-confirm-btn"
            type="primary"
            :disabled="!checkMaterials(selectedRecipe)"
            @click="craftPill"
          >
            {{ !checkMaterials(selectedRecipe) ? '材料不足' : '确认炼制' }}
          </n-button>
        </n-space>
      </n-space>
    </n-modal>

    <log-panel ref="logRef" title="焰炼日志" />
  </n-space>
  </n-card>
</template>

<script setup>
import { hasSeenGuide, markGuideSeen, guideTexts } from "../utils/guide.js"
import GuideTooltip from "../components/GuideTooltip.vue"
  import { ref, computed } from 'vue'
  import { usePlayerStore } from '../stores/player'
  import { useAuthStore } from '../stores/auth'
  import { pillRecipes, pillGrades, pillTypes, calculatePillEffect } from '../plugins/pills'
  import { herbs } from '../plugins/herbs'
  import LogPanel from '../components/LogPanel.vue'
  import GameGuide from '../components/GameGuide.vue'

  const showGuide = ref(!hasSeenGuide("alchemy"))
const dismissGuide = () => { markGuideSeen("alchemy"); showGuide.value = false }
const playerStore = usePlayerStore()
  const authStore = useAuthStore()
  const logRef = ref(null)

  // 当前选择的焰方
  const selectedRecipe = ref(null)
  
  // 确认弹窗显示状态
  const showCraftConfirm = ref(false)

  // 已解锁的焰方列表
  const unlockedRecipes = computed(() => {
    return pillRecipes.filter(recipe => playerStore.pillRecipes.includes(recipe.id))
  })

  // 选择焰方 - 打开确认弹窗
  const selectRecipe = recipe => {
    selectedRecipe.value = recipe
    showCraftConfirm.value = true
  }
  
  // 关闭确认弹窗
  const closeCraftConfirm = () => {
    showCraftConfirm.value = false
    selectedRecipe.value = null
  }

  // 检查材料是否充足
  const checkMaterials = recipe => {
    if (!recipe) return false
    return recipe.materials.every(material => {
      const count = playerStore.herbs.filter(h => h.herbId === material.herb || h.herb_id === material.herb || h.id === material.herb).length
      return count >= material.count
    })
  }

  // 获取材料状态文本
  const getMaterialStatus = material => {
    const count = playerStore.herbs.filter(h => h.herbId === material.herb || h.herb_id === material.herb || h.id === material.herb).length
    return `${count}/${material.count}`
  }

  // 获取焰草名称
  const getHerbName = herbId => {
    const herb = herbs.find(h => h.id === herbId)
    return herb ? herb.name : herbId
  }

  const getHerbCount = (herbId) => {
    return playerStore.herbs.filter(h => h.herbId === herbId || h.herb_id === herbId || h.id === herbId).length
  }

  const getEffectText = (recipe) => {
    const effectNames = {
      spiritRate: '焰灵恢复', cultivationRate: '焰修速度', combatBoost: '战斗属性',
      allAttributes: '全属性', spiritCap: '焰灵上限', autoHeal: '自动回血',
      spiritRecovery: '焰灵恢复', cultivationEfficiency: '焰修效率',
      comprehension: '悟性', fireAttribute: '火属性焰修'
    }
    const e = recipe.baseEffect
    const name = effectNames[e.type] || e.type
    return `${name}+${(e.value * 100).toFixed(0)}％，持续${Math.floor(e.duration / 60)}分钟`
  }

  // 计算当前效果
  const currentEffect = computed(() => {
    if (!selectedRecipe.value) return null
    return calculatePillEffect(selectedRecipe.value, playerStore.level)
  })

  // 焰炼焰丹（网游化）
  const craftPill = async () => {
    if (!selectedRecipe.value) return
    
    const btn = document.querySelector('.craft-confirm-btn')
    
    if (authStore.isLoggedIn) {
      // 在线模式：调用服务器API
      const result = await playerStore.craftPillOnServer(selectedRecipe.value.id)
      if (result.success) {
        logRef.value?.addLog('success', result.message || '炼制成功！')
        // 关闭弹窗
        showCraftConfirm.value = false
        selectedRecipe.value = null
      } else {
        logRef.value?.addLog('error', `炼制失败：${result.message}`)
        if (btn) {
          btn.classList.add('fail-animation')
          setTimeout(() => btn.classList.remove('fail-animation'), 1000)
        }
      }
    } else {
      // 离线模式：本地计算
      const result = playerStore.craftPillOffline(selectedRecipe.value.id)
      if (result.success) {
        logRef.value?.addLog('success', '炼制成功！')
        // 关闭弹窗
        showCraftConfirm.value = false
        selectedRecipe.value = null
      } else {
        logRef.value?.addLog('error', `炼制失败：${result.message}`)
        if (btn) {
          btn.classList.add('fail-animation')
          setTimeout(() => btn.classList.remove('fail-animation'), 1000)
        }
      }
    }
  }
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

  .craft-button {
    position: relative;
    overflow: hidden;
  }

  @keyframes success-ripple {
    0% {
      transform: scale(0);
      opacity: 1;
    }
    100% {
      transform: scale(4);
      opacity: 0;
    }
  }

  @keyframes fail-shake {
    0%,
    100% {
      transform: translateX(0);
    }
    25% {
      transform: translateX(-10px);
    }
    75% {
      transform: translateX(10px);
    }
  }

  .success-animation::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 20px;
    height: 20px;
    background: rgba(0, 255, 0, 0.3);
    border-radius: 50%;
    transform: translate(-50%, -50%);
    animation: success-ripple 1s ease-out;
  }

  .fail-animation {
    animation: fail-shake 0.5s ease-in-out;
  }

  .recipe-materials { display: flex; flex-wrap: wrap; gap: 4px; margin: 6px 0; }
  .mat-tag { font-size: 11px; padding: 2px 6px; border-radius: 4px; border: 1px solid; }
  .mat-enough { background: rgba(76,175,80,0.15); color: #4caf50; border-color: rgba(76,175,80,0.3); }
  .mat-lack { background: rgba(244,67,54,0.15); color: #f44336; border-color: rgba(244,67,54,0.3); }
  .recipe-effect { font-size: 12px; color: #ffd54f; margin-top: 4px; font-weight: 500; }
</style>
