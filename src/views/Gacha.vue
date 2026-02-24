<template>
  <div class="gacha-page">
    <!-- 装饰性顶部背景 -->
    <div class="gacha-page-bg"></div>
    <game-guide>
      <p>🎰 支持<strong>单抽/10连/50连/100连</strong>，费用随境界提升（初始300/500焰晶）</p>
      <p>📦 两个卡池：<strong>装备池</strong>、<strong>焰兽池</strong></p>
      <p>⚔️ 装备概率：凡品40%、良品30%、优品18%、极品8%、仙品3%、神品0.5%</p>
      <p>🐾 焰兽概率：凡品50%、灵品28%、玄品16%、仙品5.8%、<strong>神品0.2%</strong>（保底系统）</p>
      <p>💎 VIP可享抽卡折扣，最高7折</p>
      <p>🎯 开启<strong>心愿单</strong>可定向提升指定品质概率（费用翻倍）</p>
      <p>🤖 可设置<strong>自动出售/回收</strong>低品质物品</p>
    </game-guide>
    <n-card :bordered="false" class="gacha-main-card">
      <div class="gacha-container">
        <!-- 卡池信息区 -->
        <div class="pool-info-section">
          <h2 class="pool-title">{{ {equipment:'装备·锻造池',pet:'焰兽·召唤池'}[gachaType] }}</h2>
          <div class="gacha-type-selector">
            <n-radio-group v-model:value="gachaType" name="gachaType">
              
              <n-radio-button value="equipment">装备池</n-radio-button>
              <n-radio-button value="pet">焰兽池</n-radio-button>
            </n-radio-group>
          </div>
        </div>

        <!-- 焰晶显示 -->
        <div class="spirit-stones">
          <span class="spirit-stones-icon">💎</span>
          <n-statistic label="焰晶" :value="playerStore.spiritStones" />
        </div>

        <!-- 抽卡动画区 -->
        <div class="gacha-item-container">
          <div class="gacha-item-glow"></div>
          <div class="gacha-pool-ring">
            <div class="ring-text">{{ gachaType === 'equipment' ? '锻 造' : '召 唤' }}</div>
          </div>
          <div
            class="gacha-item"
            :class="{ shake: isShaking, open: isOpening }"
          >
            {{ types[gachaType] }}
          </div>
        </div>

        <!-- 抽卡按钮区 -->
        <div class="gacha-buttons">
          <div class="gacha-btn-row">
            <button
              v-for="(item, index) in [1, 10, 50, 100]"
              :key="index"
              class="gacha-btn"
              :class="{ 'gacha-btn-multi': item >= 10, 'gacha-btn-mega': item >= 50, 'gacha-btn-100': item === 100 }"
              @click="performGacha(item)"
              :disabled="
                playerStore.spiritStones < Math.floor((playerStore.wishlistEnabled ? item * getGachaCostTier(playerStore.level||1).wishlist : item * getGachaCostTier(playerStore.level||1).normal) * (authStore.isLoggedIn ? vipDiscounts[authStore.vipLevel]||1 : 1)) || isDrawing
              "
            >
              <span class="gacha-btn-label">抽{{ item }}次</span>
              <span class="gacha-btn-cost">💎 {{ Math.floor((playerStore.wishlistEnabled ? item * getGachaCostTier(playerStore.level||1).wishlist : item * getGachaCostTier(playerStore.level||1).normal) * (authStore.isLoggedIn ? vipDiscounts[authStore.vipLevel]||1 : 1)) }}</span>
            </button>
          </div>
          <div class="gacha-tool-row">
            <n-button quaternary circle size="small" @click="showProbabilityInfo = true">
              <template #icon><n-icon><Help /></n-icon>  <GuideTooltip v-if="showGuide" v-bind="guideTexts.gacha || {}" @dismiss="dismissGuide" />
</template>
            </n-button>
            <n-button quaternary circle size="small" @click="showWishlistSettings = true">
              <template #icon><n-icon><HeartOutline /></n-icon></template>
            </n-button>
            <n-button quaternary circle size="small" @click="showAutoSettings = true">
              <template #icon><n-icon><SettingsOutline /></n-icon></template>
            </n-button>
          </div>
        </div>

        <!-- 翻牌动画 -->
        <n-modal v-model:show="showFlipAnimation" :mask-closable="false" :close-on-esc="false"
          :style="{ maxWidth: '95vw', width: '600px', background: 'transparent', boxShadow: 'none' }">
          <div class="flip-stage">
            <div class="flip-cards">
              <div v-for="(card, i) in flipCards" :key="i"
                class="flip-card" :class="{ flipped: card.flipped, ['quality-' + card.qualityKey]: card.flipped }"
                @click="flipSingleCard(i)">
                <div class="flip-card-inner">
                  <div class="flip-card-back">
                    <span class="card-back-icon">✦</span>
                  </div>
                  <div class="flip-card-front" :style="{ borderColor: card.color }">
                    <div class="card-glow" :style="{ background: card.color + '30' }"></div>
                    <span class="card-icon">{{ card.icon }}</span>
                    <span class="card-name">{{ card.name }}</span>
                    <span class="card-quality" :style="{ color: card.color }">{{ card.qualityName }}</span>
                  </div>
                </div>
              </div>
            </div>
            <div class="flip-actions">
              <n-button type="warning" @click="flipAllCards" v-if="!allFlipped">跳过动画</n-button>
              <n-button type="primary" @click="closeFlipAnimation" v-else>确认</n-button>
            </div>
          </div>
        </n-modal>

        <!-- 抽卡结果弹窗 -->
        <n-modal
          v-model:show="showResult"
          preset="dialog"
          title="抽卡结果"
          :style="{ maxWidth: '90vw', width: '800px' }"
        >
          <n-card :bordered="false">
            <div class="result-summary" v-if="lastResult">
              <n-space justify="center" :size="24">
                <n-statistic label="消耗焰晶" :value="lastResult.cost" />
                <n-statistic label="自动出售" :value="lastResult.autoSold?.count || 0" v-if="lastResult.autoSold?.count" />
                <n-statistic label="获得淬火石" :value="lastResult.autoSold?.income || 0" v-if="lastResult.autoSold?.income" />
                <n-statistic label="自动回收" :value="lastResult.autoReleased || 0" v-if="lastResult.autoReleased" />
                <n-statistic label="获得精华" :value="lastResult.petEssenceGained || 0" v-if="lastResult.petEssenceGained" />
              </n-space>
            </div>
            <div class="filter-section" v-if="gachaType !== 'all'">
              <n-space align="center" justify="center" :wrap="true" :size="16">
                <n-select
                  v-model:value="selectedQuality"
                  placeholder="装备品质筛选"
                  clearable
                  :options="equipmentQualityOptions"
                  :style="{ width: '180px' }"
                  @update:value="currentPage = 1"
                  v-if="gachaType === 'equipment'"
                ></n-select>
                <n-select
                  v-model:value="selectedRarity"
                  placeholder="焰兽品质筛选"
                  clearable
                  :options="petRarityOptions"
                  :style="{ width: '180px' }"
                  @update:value="currentPage = 1"
                  v-if="gachaType === 'pet'"
                ></n-select>
              </n-space>
            </div>
            <n-space justify="center">
              <button
                class="gacha-btn gacha-btn-multi"
                @click="performGacha(gachaNumber)"
                :disabled="
                  playerStore.spiritStones < Math.floor((playerStore.wishlistEnabled ? gachaNumber * getGachaCostTier(playerStore.level||1).wishlist : gachaNumber * getGachaCostTier(playerStore.level||1).normal) * (authStore.isLoggedIn ? vipDiscounts[authStore.vipLevel]||1 : 1)) || isDrawing
                "
              >
                <span class="gacha-btn-label">再抽{{ gachaNumber }}次</span>
                <span class="gacha-btn-cost">💎 {{ Math.floor((playerStore.wishlistEnabled ? gachaNumber * getGachaCostTier(playerStore.level||1).wishlist : gachaNumber * getGachaCostTier(playerStore.level||1).normal) * (authStore.isLoggedIn ? vipDiscounts[authStore.vipLevel]||1 : 1)) }}</span>
              </button>
            </n-space>
            <div class="result-grid">
              <div
                v-for="item in currentPageResults"
                :key="item.id"
                :class="[
                  'result-item',
                  'result-quality-' + (item.quality || item.rarity || 'common'),
                  {
                    'wish-bonus':
                      playerStore.wishlistEnabled &&
                      ((item.qualityInfo && playerStore.selectedWishEquipQuality === item.quality) ||
                        (item.type === 'pet' && playerStore.selectedWishPetRarity === item.rarity))
                  }
                ]"
                :style="{
                  borderColor: item.qualityInfo
                    ? item.qualityInfo.color
                    : petRarities[item.rarity]?.color || '#CCCCCC'
                }"
              >
                <div class="result-item-glow" :style="{ background: (item.qualityInfo ? item.qualityInfo.color : petRarities[item.rarity]?.color || '#ccc') + '15' }"></div>
                <h4>{{ item.name }}</h4>
                <p class="result-quality-text" :style="{ color: item.qualityInfo ? item.qualityInfo.color : petRarities[item.rarity]?.color || '#ccc' }">
                  品质：{{ item.qualityInfo ? item.qualityInfo.name : petRarities[item.rarity]?.name || '未知' }}
                </p>
                <p v-if="equipmentTypes2.includes(item.type)">类型：{{ equipmentTypes[item.equipType]?.name || item.type }}</p>
                <p v-else-if="item.type === 'pet'">{{ item.description || '暂无描述' }}</p>
              </div>
            </div>
            <template #footer>
              <n-space justify="center">
                <n-pagination
                  v-model:page="currentPage"
                  :page-slot="6"
                  :page-count="totalPages"
                  :page-size="pageSize"
                />
              </n-space>
            </template>
          </n-card>
        </n-modal>

        <!-- 概率说明弹窗 -->
        <n-modal v-model:show="showProbabilityInfo" preset="dialog" title="抽卡概率说明">
          <n-tabs type="segment" animated v-model:value="probTab">
            <n-tab-pane name="equipment" tab="装备池">
              <n-card class="prob-card">
                <div class="probability-bars">
                  <div v-for="(probability, quality) in serverProbabilities?.equipment || getAdjustedEquipProbabilities()" :key="quality" class="prob-item">
                    <div class="prob-label">
                      <span :style="{ color: equipmentQualities[quality].color }">{{ equipmentQualities[quality].name }}</span>
                    </div>
                    <n-progress type="line" :percentage="probability * 100" :indicator-placement="'inside'" :color="equipmentQualities[quality].color" :height="20" :border-radius="4"
                      :class="{ 'wish-bonus': playerStore.wishlistEnabled && playerStore.selectedWishEquipQuality === quality }" :show-indicator="true">
                      <template #indicator>{{ (probability * 100).toFixed(1) }}%</template>
                    </n-progress>
                  </div>
                </div>
              </n-card>
            </n-tab-pane>
            <n-tab-pane name="pet" tab="焰兽池">
              <n-card class="prob-card">
                <div class="probability-bars">
                  <div v-for="(probability, rarity) in serverProbabilities?.pet || getAdjustedPetProbabilities()" :key="rarity" class="prob-item">
                    <div class="prob-label">
                      <span :style="{ color: petRarities[rarity].color }">{{ petRarities[rarity].name }}</span>
                    </div>
                    <n-progress type="line" :percentage="probability * 100" :indicator-placement="'inside'"
                      :class="{ 'wish-bonus': playerStore.wishlistEnabled && playerStore.selectedWishPetRarity === rarity }"
                      :color="petRarities[rarity].color" :height="20" :border-radius="4" :show-indicator="true">
                      <template #indicator>{{ (probability * 100).toFixed(1) }}%</template>
                    </n-progress>
                  </div>
                </div>
              </n-card>
            </n-tab-pane>
          </n-tabs>
        </n-modal>

        <!-- 心愿单设置弹窗 -->
        <n-modal v-model:show="showWishlistSettings" preset="dialog" title="心愿单设置" style="max-width:800px;width:90vw">
          <n-card :bordered="false">
            <n-space vertical>
              <n-switch v-model:value="playerStore.wishlistEnabled">
                <template #checked>心愿单已启用</template>
                <template #unchecked>心愿单已禁用</template>
              </n-switch>
              <n-divider>装备品质心愿</n-divider>
              <n-select
                v-model:value="playerStore.selectedWishEquipQuality"
                :options="equipmentQualityOptions"
                clearable
                placeholder="选择装备品质"
                :disabled="!playerStore.wishlistEnabled"
              >
                <template #option="{ option }">
                  <span :style="{ color: equipmentQualities[option.value].color }">
                    {{ equipmentQualities[option.value].name }}
                    <n-tag v-if="option.value === playerStore.selectedWishEquipQuality" type="success" size="small">已选择</n-tag>
                  </span>
                </template>
              </n-select>
              <n-divider>焰兽品质心愿</n-divider>
              <n-select
                v-model:value="playerStore.selectedWishPetRarity"
                :options="petRarityOptions"
                clearable
                placeholder="选择焰兽品质"
                :disabled="!playerStore.wishlistEnabled"
              >
                <template #option="{ option }">
                  <span :style="{ color: petRarities[option.value].color }">
                    {{ petRarities[option.value].name }}
                    <n-tag v-if="option.value === playerStore.selectedWishPetRarity" type="success" size="small">已选择</n-tag>
                  </span>
                </template>
              </n-select>
              <n-alert type="info" title="心愿单说明">
                启用心愿单后，所需焰晶会翻倍,
                选中的品质将根据其基础概率获得不同程度的概率提升（基础概率越低，提升越高）。每次只能选择一个装备品质和一个焰兽品质作为心愿。
              </n-alert>
            </n-space>
          </n-card>
        </n-modal>

        <!-- 自动处理设置弹窗 -->
        <n-modal v-model:show="showAutoSettings" preset="dialog" title="自动处理设置" style="max-width:800px;width:90vw">
          <n-card :bordered="false">
            <n-space vertical>
              <n-divider>装备自动出售</n-divider>
              <n-checkbox-group v-model:value="playerStore.autoSellQualities" @update:value="handleAutoSellChange">
                <n-space wrap>
                  <n-checkbox value="all" :disabled="!!playerStore.autoSellQualities?.length && !playerStore.autoSellQualities.includes('all')">全部品阶</n-checkbox>
                  <n-checkbox v-for="(quality, key) in equipmentQualities" :key="key" :value="key" :disabled="playerStore.autoSellQualities?.includes('all')">
                    <span :style="{ color: quality.color }">{{ quality.name }}</span>
                  </n-checkbox>
                </n-space>
              </n-checkbox-group>
              <n-divider>焰兽自动回收</n-divider>
              <n-checkbox-group v-model:value="playerStore.autoReleaseRarities" @update:value="handleAutoReleaseChange">
                <n-space wrap>
                  <n-checkbox value="all" :disabled="!!playerStore.autoReleaseRarities?.length && !playerStore.autoReleaseRarities.includes('all')">全部品质</n-checkbox>
                  <n-checkbox v-for="(rarity, key) in petRarities" :key="key" :value="key" :disabled="playerStore.autoReleaseRarities?.includes('all')">
                    <span :style="{ color: rarity.color }">{{ rarity.name }}</span>
                  </n-checkbox>
                </n-space>
              </n-checkbox-group>
            </n-space>
          </n-card>
          <template #footer>
            <n-space justify="end">
              <n-button @click="showAutoSettings = false">关闭</n-button>
            </n-space>
          </template>
        </n-modal>
      </div>
    </n-card>
  </div>
</template>

<script setup>
import { hasSeenGuide, markGuideSeen, guideTexts } from "../utils/guide.js"
import GuideTooltip from "../components/GuideTooltip.vue"
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { ref, onMounted, computed, watch } from 'vue'
import { useMessage } from 'naive-ui'
import { Help, HeartOutline, SettingsOutline } from '@vicons/ionicons5'
import sfx from '../plugins/sfx'
import GameGuide from '../components/GameGuide.vue'

const showGuide = ref(!hasSeenGuide("gacha"))
const dismissGuide = () => { markGuideSeen("gacha"); showGuide.value = false }
const playerStore = usePlayerStore()
const authStore = useAuthStore()
const message = useMessage()

// VIP折扣配置
const vipDiscounts = [1, 0.95, 0.9, 0.85, 0.8, 0.7]

// 抽卡费用阶梯
function getGachaCostTier(level) {
  if (level >= 91) return { normal: 1800, wishlist: 2500 };
  if (level >= 55) return { normal: 1200, wishlist: 1800 };
  if (level >= 37) return { normal: 800, wishlist: 1200 };
  if (level >= 19) return { normal: 500, wishlist: 800 };
  return { normal: 300, wishlist: 500 };
}

// 活动效果和服务器概率
const gachaRateBoost = ref(1)
const serverProbabilities = ref(null)
const probTab = ref('equipment')

// 抽卡类型
const gachaType = ref('equipment')
const isShaking = ref(false)
const isOpening = ref(false)
const showResult = ref(false)
const showFlipAnimation = ref(false)
const flipCards = ref([])
const allFlipped = ref(false)
const gachaResult = ref(null)
const showProbabilityInfo = ref(false)
const isDrawing = ref(false)
const lastResult = ref(null)

// 获取服务器概率
const fetchProbabilities = async () => {
  try {
    const params = new URLSearchParams()
    params.append('type', gachaType.value)
    params.append('wishlistEnabled', playerStore.wishlistEnabled)
    if (playerStore.selectedWishEquipQuality) params.append('wishEquipQuality', playerStore.selectedWishEquipQuality)
    if (playerStore.selectedWishPetRarity) params.append('wishPetRarity', playerStore.selectedWishPetRarity)
    
    const res = await fetch(`/api/gacha/probabilities?${params}`)
    if (res.ok) {
      serverProbabilities.value = await res.json()
    }
  } catch (e) {
    console.error('获取概率失败:', e)
  }
}

// 监听心愿单和活动变化，更新概率
watch([() => playerStore.wishlistEnabled, () => playerStore.selectedWishEquipQuality, () => playerStore.selectedWishPetRarity, gachaType], () => {
  fetchProbabilities()
}, { immediate: true })

onMounted(async () => {
  try {
    const res = await fetch('/api/events/effects')
    const data = await res.json()
    gachaRateBoost.value = data.effects?.gachaRateBoost || 1
  } catch {}
  fetchProbabilities()
})



const getCardInfo = (item) => {
  const isEquip = item.qualityInfo || item.quality
  const isPet = item.type === 'pet'
  const color = isEquip ? (equipmentQualities[item.quality]?.color || '#9e9e9e') : (petRarities[item.rarity]?.color || '#9e9e9e')
  const qualityName = isEquip ? (equipmentQualities[item.quality]?.name || '未知') : (petRarities[item.rarity]?.name || '未知')
  const qualityKey = isEquip ? item.quality : (item.rarity || 'common')
  const icon = isPet ? '🐾' : '⚔️'
  return { name: item.name, color, qualityName, qualityKey, icon, flipped: false }
}

const startFlipAnimation = (results) => {
  if (results.length > 10) {
    showResult.value = true
    return
  }
  flipCards.value = results.map(r => getCardInfo(r))
  allFlipped.value = false
  showFlipAnimation.value = true
  let delay = 300
  flipCards.value.forEach((card, i) => {
    setTimeout(() => {
      card.flipped = true
      sfx.cardFlip()
      if (['mythic', 'legendary', 'epic', 'divine', 'celestial'].includes(card.qualityKey)) {
        setTimeout(() => sfx.cardRare(), 200)
      }
      if (i === flipCards.value.length - 1) allFlipped.value = true
    }, delay + i * 400)
  })
}

const flipSingleCard = (i) => {
  if (!flipCards.value[i].flipped) {
    flipCards.value[i].flipped = true
    sfx.cardFlip()
    if (['mythic', 'legendary', 'epic', 'divine', 'celestial'].includes(flipCards.value[i].qualityKey)) {
      setTimeout(() => sfx.cardRare(), 200)
    }
    if (flipCards.value.every(c => c.flipped)) allFlipped.value = true
  }
}

const flipAllCards = () => {
  flipCards.value.forEach(c => c.flipped = true)
  allFlipped.value = true
}

const closeFlipAnimation = () => {
  showFlipAnimation.value = false
  showResult.value = true
}

const currentPage = ref(1)
const pageSize = ref(12)
const selectedQuality = ref(null)
const selectedRarity = ref(null)
const showAutoSettings = ref(false)
const showWishlistSettings = ref(false)

// 装备品质配置
const equipmentQualities = {
  common: { name: '凡品', color: '#9e9e9e', statMod: 1.0, maxStatMod: 1.5 },
  uncommon: { name: '下品', color: '#4caf50', statMod: 1.2, maxStatMod: 2.0 },
  rare: { name: '中品', color: '#2196f3', statMod: 1.5, maxStatMod: 2.5 },
  epic: { name: '上品', color: '#9c27b0', statMod: 2.0, maxStatMod: 3.0 },
  legendary: { name: '极品', color: '#ff9800', statMod: 2.5, maxStatMod: 3.5 },
  mythic: { name: '仙品', color: '#e91e63', statMod: 3.0, maxStatMod: 4.0 }
}

// 装备类型配置
const equipmentTypes = {
  weapon: { name: '焰杖', slot: 'weapon', prefixes: ['九天', '太虚', '混沌', '玄天', '紫霄', '青冥', '赤炎', '幽冥'] },
  head: { name: '头部', slot: 'head', prefixes: ['天灵', '玄冥', '紫金', '青玉', '赤霞', '幽月', '星辰', '云霄'] },
  body: { name: '衣服', slot: 'body', prefixes: ['九霄', '太素', '混元', '玄阳', '紫薇', '青龙', '赤凤', '幽冥'] },
  legs: { name: '裤子', slot: 'legs', prefixes: ['天罡', '玄武', '紫电', '青云', '赤阳', '幽灵', '星光', '云雾'] },
  feet: { name: '鞋子', slot: 'feet', prefixes: ['天行', '玄风', '紫霞', '青莲', '赤焰', '幽影', '星步', '云踪'] },
  shoulder: { name: '肩甲', slot: 'shoulder', prefixes: ['天护', '玄甲', '紫雷', '青锋', '赤羽', '幽岚', '星芒', '云甲'] },
  hands: { name: '手套', slot: 'hands', prefixes: ['天罗', '玄玉', '紫晶', '青钢', '赤金', '幽银', '星铁', '云纹'] },
  wrist: { name: '护腕', slot: 'wrist', prefixes: ['天绝', '玄铁', '紫玉', '青石', '赤铜', '幽钢', '星晶', '云纱'] },
  necklace: { name: '焰心链', slot: 'necklace', prefixes: ['天珠', '玄圣', '紫灵', '青魂', '赤心', '幽魄', '星魂', '云珠'] },
  ring1: { name: '符文戒1', slot: 'ring1', prefixes: ['天命', '玄命', '紫命', '青命', '赤命', '幽命', '星命', '云命'] },
  ring2: { name: '符文戒2', slot: 'ring2', prefixes: ['天道', '玄道', '紫道', '青道', '赤道', '幽道', '星道', '云道'] },
  belt: { name: '腰带', slot: 'belt', prefixes: ['天系', '玄系', '紫系', '青系', '赤系', '幽系', '星系', '云系'] },
  artifact: { name: '焰器', slot: 'artifact', prefixes: ['天宝', '玄宝', '紫宝', '青宝', '赤宝', '幽宝', '星宝', '云宝'] }
}

const equipmentTypes2 = ['weapon','head','body','legs','feet','shoulder','hands','wrist','necklace','ring1','ring2','belt','artifact']

// 焰兽品质配置
const petRarities = {
  divine: { name: '神品', color: '#FF0000', probability: 0.002, essenceBonus: 50 },
  celestial: { name: '仙品', color: '#FFD700', probability: 0.0581, essenceBonus: 30 },
  mystic: { name: '玄品', color: '#9932CC', probability: 0.1601, essenceBonus: 20 },
  spiritual: { name: '灵品', color: '#1E90FF', probability: 0.2801, essenceBonus: 10 },
  mortal: { name: '凡品', color: '#32CD32', probability: 0.4997, essenceBonus: 5 }
}

const getEquipProbabilities = {
  common: 0.5, uncommon: 0.3, rare: 0.12, epic: 0.05, legendary: 0.02, mythic: 0.01
}

const wishlistBonus = {
  equipment: quality => Math.min(1.0, 0.2 / getEquipProbabilities[quality]),
  pet: rarity => Math.min(1.0, 0.2 / petRarities[rarity].probability)
}

const getAdjustedEquipProbabilities = () => {
  const baseProbs = { ...getEquipProbabilities }
  if (gachaRateBoost.value > 1) {
    const rareKeys = ['rare', 'epic', 'legendary', 'mythic']
    let boosted = 0
    rareKeys.forEach(k => { const old = baseProbs[k]; baseProbs[k] = Math.min(old * gachaRateBoost.value, 0.5); boosted += baseProbs[k] - old })
    baseProbs.common = Math.max(0.05, baseProbs.common - boosted * 0.7)
    baseProbs.uncommon = Math.max(0.05, baseProbs.uncommon - boosted * 0.3)
  }
  if (playerStore.wishlistEnabled && playerStore.selectedWishEquipQuality) {
    const quality = playerStore.selectedWishEquipQuality
    const bonus = wishlistBonus.equipment(quality)
    baseProbs[quality] *= 1 + bonus
    const totalOtherProb = Object.entries(baseProbs).filter(([q]) => q !== quality).reduce((sum, [, prob]) => sum + prob, 0)
    const reductionFactor = (1 - baseProbs[quality]) / totalOtherProb
    Object.keys(baseProbs).forEach(q => { if (q !== quality) baseProbs[q] *= reductionFactor })
  }
  return baseProbs
}

const getAdjustedPetProbabilities = () => {
  const baseProbs = {}
  Object.entries(petRarities).forEach(([rarity, config]) => { baseProbs[rarity] = config.probability })
  if (gachaRateBoost.value > 1) {
    const rareKeys = ['mystic', 'celestial', 'divine']
    let boosted = 0
    rareKeys.forEach(k => { if (baseProbs[k]) { const old = baseProbs[k]; baseProbs[k] = Math.min(old * gachaRateBoost.value, 0.4); boosted += baseProbs[k] - old } })
    if (baseProbs.mortal) baseProbs.mortal = Math.max(0.05, baseProbs.mortal - boosted * 0.6)
    if (baseProbs.spiritual) baseProbs.spiritual = Math.max(0.05, baseProbs.spiritual - boosted * 0.4)
  }
  if (playerStore.wishlistEnabled && playerStore.selectedWishPetRarity) {
    const rarity = playerStore.selectedWishPetRarity
    const bonus = wishlistBonus.pet(rarity)
    baseProbs[rarity] *= 1 + bonus
    const totalOtherProb = Object.entries(baseProbs).filter(([r]) => r !== rarity).reduce((sum, [, prob]) => sum + prob, 0)
    const reductionFactor = (1 - baseProbs[rarity]) / totalOtherProb
    Object.keys(baseProbs).forEach(r => { if (r !== rarity) baseProbs[r] *= reductionFactor })
  }
  return baseProbs
}

const getAllPoolProbabilities = () => {
  const equipProbs = getEquipProbabilities
  const adjustedEquipProbs = {}
  Object.entries(equipProbs).forEach(([quality, prob]) => { adjustedEquipProbs[quality] = prob * 0.5 })
  const adjustedPetProbs = {}
  Object.entries(petRarities).forEach(([rarity, config]) => { adjustedPetProbs[rarity] = config.probability * 0.5 })
  return { equipment: adjustedEquipProbs, pet: adjustedPetProbs }
}

const gachaNumber = ref(1)

// 主抽卡函数 - 登录用户调用API，未登录用户使用本地生成
const performGacha = async (times) => {
  gachaNumber.value = times
  showResult.value = false
  
  const costTier = getGachaCostTier(playerStore.level||1)
  const baseCost = playerStore.wishlistEnabled ? times * costTier.wishlist : times * costTier.normal
  const discount = vipDiscounts[authStore.vipLevel] || 1
  const cost = Math.floor(baseCost * discount)
  
  if (playerStore.spiritStones < cost) {
    message.error('焰晶不足！')
    return
  }
  
  // 检查背包容量
  const equipCount = playerStore.items.filter(i => i.type && i.type !== 'pill' && i.type !== 'pet' && i.stats).length
  const petCount = playerStore.items.filter(i => i.type === 'pet').length
  const equipLimit = playerStore.getStorageLimit('equip')
  const petLimit = playerStore.getStorageLimit('pet')
  
  if (gachaType.value === 'equipment' && equipCount >= equipLimit) {
    message.error(`装备背包已满(${equipCount}/${equipLimit})，请先处理一些装备`)
    return
  }
  if (gachaType.value === 'pet' && petCount >= petLimit) {
    message.error(`焰兽背包已满(${petCount}/${petLimit})，请先处理一些焰兽`)
    return
  }
  if (gachaType.value === 'all' && equipCount >= equipLimit && petCount >= petLimit) {
    message.error('装备和焰兽背包均已满，请先处理')
    return
  }
  
  if (isDrawing.value) return
  isDrawing.value = true
  
  // 播放动画
  isShaking.value = true
  await new Promise(resolve => setTimeout(resolve, 1000))
  isShaking.value = false
  isOpening.value = true
  await new Promise(resolve => setTimeout(resolve, 1000))
  
  let results = []
  
  // 已登录用户调用服务端API
  if (authStore.isLoggedIn) {
    try {
      const token = authStore.token
      const res = await fetch('/api/gacha/draw', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({
          count: times,
          type: gachaType.value,
          wishlistEnabled: playerStore.wishlistEnabled,
          wishEquipQuality: playerStore.selectedWishEquipQuality,
          wishPetRarity: playerStore.selectedWishPetRarity
        })
      })
      
      const data = await res.json()
      
      if (!res.ok) {
        message.error(data.error || '抽卡失败')
        isDrawing.value = false
        isOpening.value = false
        return
      }
      
      results = data.results || []
      lastResult.value = data
      
      // 更新本地数据
      playerStore.spiritStones = data.spiritStones
      if (data.petEssenceGained) {
        playerStore.petEssence = (playerStore.petEssence || 0) + data.petEssenceGained
      }
      if (data.autoSold?.income) {
        playerStore.reinforceStones = (playerStore.reinforceStones || 0) + data.autoSold.income
      }
      
      // 添加物品到本地
      results.forEach(item => {
        item.id = item.id || (Date.now() + Math.random())
        if (equipmentTypes2.includes(item.type)) {
          item.qualityInfo = equipmentQualities[item.quality]
        }
        playerStore.items.push(item)
      })
      
      // 显示自动处理消息
      if (data.autoSold?.count) {
        message.success(`自动出售了 ${data.autoSold.count} 件装备，获得 ${data.autoSold.income} 淬火石`)
      }
      if (data.autoReleased) {
        message.success(`自动回收了 ${data.autoReleased} 只焰兽`)
      }
      
    } catch (e) {
      console.error('抽卡请求失败:', e)
      message.error('抽卡请求失败，请稍后重试')
      isDrawing.value = false
      isOpening.value = false
      return
    }
  } else {
    // 未登录用户使用本地抽卡（降级方案）
    playerStore.spiritStones -= cost
    
    for (let i = 0; i < times; i++) {
      let item = localDraw()
      
      // 自动处理
      if (item.type === 'pet') {
        playerStore.petEssence += petRarities[item.rarity]?.essenceBonus || 0
        if (playerStore.autoReleaseRarities?.length > 0 && (playerStore.autoReleaseRarities.includes('all') || playerStore.autoReleaseRarities.includes(item.rarity))) {
          continue
        }
      } else {
        if (playerStore.autoSellQualities?.length > 0 && (playerStore.autoSellQualities.includes('all') || playerStore.autoSellQualities.includes(item.quality))) {
          const price = { mythic: 6, legendary: 5, epic: 4, rare: 3, uncommon: 2, common: 1 }[item.quality] || 1
          playerStore.reinforceStones = (playerStore.reinforceStones || 0) + price
          continue
        }
      }
      
      item.id = Date.now() + Math.random()
      playerStore.items.push(item)
      results.push(item)
    }
    
    lastResult.value = { cost, autoSold: { count: 0, income: 0 }, autoReleased: 0 }
    playerStore.saveData()
  }
  
  gachaResult.value = results
  currentPage.value = 1
  selectedRarity.value = null
  selectedQuality.value = null
  isOpening.value = false
  isDrawing.value = false
  
  startFlipAnimation(results)
}

// 本地抽卡函数（未登录用户使用）
const localDraw = () => {
  if (gachaType.value === 'equipment') {
    return localDrawEquip()
  } else if (gachaType.value === 'pet') {
    return localDrawPet()
  } else {
    return Math.random() < 0.5 ? localDrawEquip() : localDrawPet()
  }
}

const localDrawEquip = () => {
  const probs = getAdjustedEquipProbabilities()
  const random = Math.random()
  let accumulated = 0
  let quality = 'common'
  
  for (const [q, p] of Object.entries(probs)) {
    accumulated += p
    if (random <= accumulated) {
      quality = q
      break
    }
  }
  
  const types = Object.keys(equipmentTypes)
  const type = types[Math.floor(Math.random() * types.length)]
  const minLv = Math.max(1, (playerStore.level || 1) - 10)
  const level = Math.floor(Math.random() * ((playerStore.level || 1) - minLv + 1)) + minLv
  const qualityMod = equipmentQualities[quality].statMod
  const levelMod = 1 + level * 0.1
  
  const stats = {}
  Object.entries(equipmentBaseStats[type]).forEach(([stat, config]) => {
    const base = config.min + Math.random() * (config.max - config.min)
    const value = base * qualityMod * levelMod
    if (['critRate', 'critDamageBoost', 'dodgeRate', 'vampireRate', 'finalDamageBoost', 'finalDamageReduce', 'comboRate', 'counterRate', 'stunRate', 'healBoost', 'spiritRate', 'combatBoost', 'resistanceBoost'].includes(stat)) {
      stats[stat] = Math.round(value * 100) / 100
    } else {
      stats[stat] = Math.round(value)
    }
  })
  
  return {
    type,
    slot: type,
    quality,
    level,
    requiredRealm: level,
    name: generateLocalEquipName(type, quality),
    stats,
    equipType: type,
    qualityInfo: equipmentQualities[quality]
  }
}

const generateLocalEquipName = (type, quality) => {
  const typeInfo = equipmentTypes[type]
  const prefix = typeInfo.prefixes[Math.floor(Math.random() * typeInfo.prefixes.length)]
  const suffixes = ['', '·真', '·极', '·道', '·天', '·仙', '·圣', '·神']
  const idx = { common: 0, uncommon: 3, rare: 4, epic: 5, legendary: 6, mythic: 7 }[quality] || 0
  return `${prefix}${typeInfo.name}${suffixes[idx]}`
}

const getRarityMultiplier = (rarity) => {
  const m = { divine: { base: 5, percent: 2 }, celestial: { base: 4, percent: 1.8 }, mystic: { base: 3, percent: 1.6 }, spiritual: { base: 2, percent: 1.4 }, mortal: { base: 1, percent: 1 } }
  return m[rarity] || m.mortal
}

const localDrawPet = () => {
  const probs = getAdjustedPetProbabilities()
  const random = Math.random()
  let accumulated = 0
  let rarity = 'mortal'
  
  for (const [r, p] of Object.entries(probs)) {
    accumulated += p
    if (random <= accumulated) {
      rarity = r
      break
    }
  }
  
  const pool = {
    divine: [{ name: '玄武', description: '北方守护神兽' }, { name: '白虎', description: '西方守护神兽' }],
    celestial: [{ name: '囚牛', description: '龙之长子' }, { name: '睚眦', description: '龙之次子' }],
    mystic: [{ name: '火凤凰', description: '浴火重生' }, { name: '雷鹰', description: '雷电猛禽' }],
    spiritual: [{ name: '玄龟', description: '水系焰兽' }, { name: '风隼', description: '飞行焰兽' }],
    mortal: [{ name: '灵猫', description: '敏捷小型焰兽' }, { name: '幻蝶', description: '美丽蝴蝶' }]
  }
  
  const pets = pool[rarity] || pool.mortal
  const pet = pets[Math.floor(Math.random() * pets.length)]
  const multiplier = getRarityMultiplier(rarity)
  
  return {
    ...pet,
    type: 'pet',
    rarity,
    quality: { strength: Math.floor(Math.random() * 10) + 1, agility: Math.floor(Math.random() * 10) + 1, intelligence: Math.floor(Math.random() * 10) + 1, constitution: Math.floor(Math.random() * 10) + 1 },
    power: 0, experience: 0, maxExperience: 100, level: 1, star: 0,
    upgradeItems: { divine: 5, celestial: 4, mystic: 3, spiritual: 2, mortal: 1 }[rarity] || 1,
    combatAttributes: generateLocalPetCombatAttrs(multiplier)
  }
}

const generateLocalPetCombatAttrs = (multiplier) => {
  const attrs = {}
  const stats = ['attack', 'health', 'defense', 'speed', 'critRate', 'comboRate', 'counterRate', 'stunRate', 'dodgeRate', 'vampireRate']
  stats.forEach(s => {
    if (['critRate', 'comboRate', 'counterRate', 'stunRate', 'dodgeRate', 'vampireRate'].includes(s)) {
      attrs[s] = Math.min(1, Math.round((0.05 + Math.random() * 0.05) * multiplier.percent * 100) / 100)
    } else if (s === 'speed') {
      attrs[s] = Math.round((10 + Math.random() * 5) * multiplier.base * 0.6)
    } else {
      attrs[s] = Math.round((s === 'attack' ? 10 : s === 'health' ? 100 : 5) + Math.random() * (s === 'attack' ? 5 : s === 'health' ? 20 : 3) * multiplier.base)
    }
  })
  return attrs
}

const equipmentBaseStats = {
  weapon: { attack: { name: '攻击', min: 10, max: 20 }, critRate: { name: '暴击率', min: 0.05, max: 0.1 }, critDamageBoost: { name: '暴击伤害', min: 0.1, max: 0.3 } },
  head: { defense: { name: '防御', min: 5, max: 10 }, health: { name: '生命', min: 50, max: 100 }, stunResist: { name: '抗眩晕', min: 0.05, max: 0.1 } },
  body: { defense: { name: '防御', min: 8, max: 15 }, health: { name: '生命', min: 80, max: 150 }, finalDamageReduce: { name: '最终减伤', min: 0.05, max: 0.1 } },
  legs: { defense: { name: '防御', min: 6, max: 12 }, speed: { name: '速度', min: 5, max: 10 }, dodgeRate: { name: '闪避率', min: 0.05, max: 0.1 } },
  feet: { defense: { name: '防御', min: 4, max: 8 }, speed: { name: '速度', min: 8, max: 15 }, dodgeRate: { name: '闪避率', min: 0.05, max: 0.1 } },
  shoulder: { defense: { name: '防御', min: 5, max: 10 }, health: { name: '生命', min: 40, max: 80 }, counterRate: { name: '反击率', min: 0.05, max: 0.1 } },
  hands: { attack: { name: '攻击', min: 5, max: 10 }, critRate: { name: '暴击率', min: 0.03, max: 0.08 }, comboRate: { name: '连击率', min: 0.05, max: 0.1 } },
  wrist: { defense: { name: '防御', min: 3, max: 8 }, counterRate: { name: '反击率', min: 0.05, max: 0.1 }, vampireRate: { name: '吸血率', min: 0.05, max: 0.1 } },
  necklace: { health: { name: '生命', min: 60, max: 120 }, healBoost: { name: '强化治疗', min: 0.1, max: 0.2 }, spiritRate: { name: '焰灵获取', min: 0.1, max: 0.2 } },
  ring1: { attack: { name: '攻击', min: 5, max: 10 }, critDamageBoost: { name: '暴击伤害', min: 0.1, max: 0.2 }, finalDamageBoost: { name: '最终增伤', min: 0.05, max: 0.1 } },
  ring2: { defense: { name: '防御', min: 5, max: 10 }, critDamageReduce: { name: '爆伤减免', min: 0.1, max: 0.2 }, resistanceBoost: { name: '抗性提升', min: 0.05, max: 0.1 } },
  belt: { health: { name: '生命', min: 40, max: 80 }, defense: { name: '防御', min: 4, max: 8 }, combatBoost: { name: '战斗属性', min: 0.05, max: 0.1 } },
  artifact: { attack: { name: '攻击力', min: 0.1, max: 0.3 }, critRate: { name: '暴击率', min: 0.1, max: 0.3 }, comboRate: { name: '连击率', min: 0.1, max: 0.3 } }
}

const filteredResults = computed(() => {
  if (!gachaResult.value) return []
  return gachaResult.value.filter(item => {
    if (item.type === 'pet') return !selectedRarity.value || item.rarity === selectedRarity.value
    return !selectedQuality.value || item.quality === selectedQuality.value
  })
})

watch([selectedQuality, selectedRarity], () => { currentPage.value = 1 })

const currentPageResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  return filteredResults.value.slice(start, start + pageSize.value)
})

const totalPages = computed(() => Math.ceil(filteredResults.value.length / pageSize.value))

const types = { equipment: '📦', pet: '🥚', all: '🎁' }

const equipmentQualityOptions = computed(() => {
  return Object.entries(equipmentQualities).map(([key, value]) => ({ label: value.name, value: key, style: { color: value.color } }))
})

const petRarityOptions = computed(() => {
  return Object.entries(petRarities).map(([key, value]) => ({ label: value.name, value: key, style: { color: value.color } }))
})

const handleAutoSellChange = values => {
  if (values.includes('all')) playerStore.autoSellQualities = ['all']
  else if (values.length > 0) playerStore.autoSellQualities = values.filter(v => v !== 'all')
}

const handleAutoReleaseChange = values => {
  if (values.includes('all')) playerStore.autoReleaseRarities = ['all']
  else if (values.length > 0) playerStore.autoReleaseRarities = values.filter(v => v !== 'all')
}
</script>

<style scoped>
/* === 页面整体 === */
.gacha-page {
  position: relative;
  min-height: 100vh;
  background: #0a0a14;
  color: #e8e0d0;
  overflow-x: hidden;
}

/* 浮动粒子背景 */
.gacha-page::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    radial-gradient(2px 2px at 20px 30px, rgba(212,168,67,0.4), transparent),
    radial-gradient(2px 2px at 40px 70px, rgba(153,50,204,0.3), transparent),
    radial-gradient(1px 1px at 90px 40px, rgba(255,215,0,0.4), transparent),
    radial-gradient(2px 2px at 160px 120px, rgba(212,168,67,0.3), transparent),
    radial-gradient(1px 1px at 230px 80px, rgba(153,50,204,0.4), transparent),
    radial-gradient(2px 2px at 300px 150px, rgba(255,215,0,0.3), transparent),
    radial-gradient(1px 1px at 350px 50px, rgba(212,168,67,0.4), transparent),
    radial-gradient(2px 2px at 450px 200px, rgba(153,50,204,0.3), transparent);
  background-repeat: repeat;
  background-size: 500px 250px;
  animation: particle-float 20s linear infinite;
  pointer-events: none;
  z-index: 0;
}

@keyframes particle-float {
  0% { transform: translateY(0) translateX(0); }
  25% { transform: translateY(-10px) translateX(5px); }
  50% { transform: translateY(-5px) translateX(-5px); }
  75% { transform: translateY(-15px) translateX(3px); }
  100% { transform: translateY(0) translateX(0); }
}

.gacha-page-bg {
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 320px;
  background: 
    linear-gradient(180deg, #1a1030 0%, #12091e 30%, transparent 100%),
    radial-gradient(ellipse at 50% 0%, rgba(212,168,67,0.2) 0%, transparent 50%),
    radial-gradient(ellipse at 30% 20%, rgba(153,50,204,0.15) 0%, transparent 40%),
    radial-gradient(ellipse at 70% 10%, rgba(255,215,0,0.1) 0%, transparent 35%);
  pointer-events: none;
  z-index: 0;
}

/* 顶部光晕装饰 */
.gacha-page-bg::after {
  content: '';
  position: absolute;
  top: -50px;
  left: 50%;
  transform: translateX(-50%);
  width: 600px;
  height: 200px;
  background: radial-gradient(ellipse, rgba(212,168,67,0.15) 0%, transparent 70%);
  filter: blur(20px);
  animation: halo-pulse 4s ease-in-out infinite;
}

@keyframes halo-pulse {
  0%, 100% { opacity: 0.6; transform: translateX(-50%) scale(1); }
  50% { opacity: 1; transform: translateX(-50%) scale(1.1); }
}

.gacha-main-card {
  position: relative;
  z-index: 1;
  background: transparent !important;
}
.gacha-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 20px 0;
}

/* === 卡池信息区 === */
.pool-info-section {
  text-align: center;
  position: relative;
}
.pool-title {
  font-size: 32px;
  font-weight: 800;
  background: linear-gradient(135deg, #d4a843 0%, #f0d060 30%, #fff8a0 50%, #f0d060 70%, #d4a843 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: none;
  margin: 0 0 20px 0;
  letter-spacing: 4px;
  position: relative;
  filter: drop-shadow(0 2px 4px rgba(212,168,67,0.3));
}

.pool-title::after {
  content: attr(data-text);
  position: absolute;
  left: 0;
  top: 0;
  width: 100%;
  background: linear-gradient(135deg, transparent 40%, rgba(255,255,255,0.8) 50%, transparent 60%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: title-shine 3s ease-in-out infinite;
}

@keyframes title-shine {
  0%, 100% { background-position: -200% center; }
  50% { background-position: 200% center; }
}

/* 卡池选择器 - 美化n-radio-group样式 */
.gacha-type-selector {
  margin-bottom: 8px;
}

.gacha-type-selector :deep(.n-radio-group) {
  background: rgba(20,15,35,0.6);
  padding: 6px;
  border-radius: 16px;
  border: 1px solid rgba(212,168,67,0.2);
  box-shadow: 0 4px 20px rgba(0,0,0,0.3), inset 0 1px 0 rgba(255,255,255,0.05);
}

.gacha-type-selector :deep(.n-radio-button) {
  background: transparent;
  border: 1px solid transparent;
  border-radius: 12px;
  color: #a09080;
  font-weight: 600;
  padding: 10px 28px;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.gacha-type-selector :deep(.n-radio-button)::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(212,168,67,0.1), rgba(153,50,204,0.1));
  opacity: 0;
  transition: opacity 0.3s;
}

.gacha-type-selector :deep(.n-radio-button:hover) {
  color: #d4a843;
  background: rgba(212,168,67,0.1);
}

.gacha-type-selector :deep(.n-radio-button.n-radio-button--checked) {
  background: linear-gradient(135deg, rgba(212,168,67,0.2), rgba(153,50,204,0.15));
  border-color: rgba(212,168,67,0.5);
  color: #f0d060;
  box-shadow: 
    0 4px 15px rgba(212,168,67,0.3),
    inset 0 1px 0 rgba(255,255,255,0.1),
    0 0 20px rgba(212,168,67,0.2);
  text-shadow: 0 0 10px rgba(240,208,96,0.5);
}

.gacha-type-selector :deep(.n-radio-button.n-radio-button--checked)::after {
  content: '✦';
  position: absolute;
  top: 2px;
  right: 6px;
  font-size: 8px;
  color: #f0d060;
  animation: star-twinkle 1.5s ease-in-out infinite;
}

@keyframes star-twinkle {
  0%, 100% { opacity: 0.5; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.2); }
}

/* === 焰晶显示 === */
.spirit-stones {
  display: flex;
  align-items: center;
  gap: 10px;
  background: linear-gradient(135deg, rgba(212,168,67,0.12), rgba(212,168,67,0.05));
  border: 1px solid rgba(212,168,67,0.3);
  border-radius: 24px;
  padding: 8px 24px;
  box-shadow: 
    0 4px 15px rgba(212,168,67,0.15),
    inset 0 1px 0 rgba(255,255,255,0.1);
  position: relative;
  overflow: hidden;
}

.spirit-stones::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
  animation: crystal-shine 3s ease-in-out infinite;
}

@keyframes crystal-shine {
  0%, 100% { left: -100%; }
  50% { left: 100%; }
}

.spirit-stones-icon {
  font-size: 22px;
  filter: drop-shadow(0 0 8px rgba(212,168,67,0.6));
  animation: crystal-pulse 2s ease-in-out infinite;
}

@keyframes crystal-pulse {
  0%, 100% { transform: scale(1); filter: drop-shadow(0 0 8px rgba(212,168,67,0.6)); }
  50% { transform: scale(1.1); filter: drop-shadow(0 0 15px rgba(212,168,67,0.9)); }
}

/* === 抽卡动画区 === */
.gacha-item-container {
  position: relative;
  width: 240px;
  height: 240px;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 多层光晕背景 */
.gacha-item-glow {
  position: absolute;
  width: 200px; 
  height: 200px;
  border-radius: 50%;
  background: 
    radial-gradient(circle at 30% 30%, rgba(212,168,67,0.4) 0%, transparent 50%),
    radial-gradient(circle at 70% 70%, rgba(153,50,204,0.3) 0%, transparent 50%),
    radial-gradient(circle, rgba(212,168,67,0.2) 0%, transparent 70%);
  animation: glow-pulse 3s ease-in-out infinite;
}

.gacha-item-glow::before {
  content: '';
  position: absolute;
  inset: -20px;
  border-radius: 50%;
  border: 2px solid rgba(212,168,67,0.1);
  animation: ring-expand 3s ease-out infinite;
}

.gacha-item-glow::after {
  content: '';
  position: absolute;
  inset: -40px;
  border-radius: 50%;
  border: 1px solid rgba(153,50,204,0.1);
  animation: ring-expand 3s ease-out infinite 0.5s;
}

@keyframes ring-expand {
  0% { transform: scale(0.8); opacity: 0.6; }
  100% { transform: scale(1.3); opacity: 0; }
}

@keyframes glow-pulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.1); opacity: 1; }
}

/* 粒子环绕效果 */
.gacha-item-container::before {
  content: '';
  position: absolute;
  width: 220px;
  height: 220px;
  border-radius: 50%;
  background: 
    radial-gradient(circle at 0% 50%, rgba(212,168,67,0.3) 0%, transparent 8%),
    radial-gradient(circle at 25% 10%, rgba(153,50,204,0.3) 0%, transparent 6%),
    radial-gradient(circle at 75% 10%, rgba(212,168,67,0.3) 0%, transparent 6%),
    radial-gradient(circle at 100% 50%, rgba(153,50,204,0.3) 0%, transparent 8%),
    radial-gradient(circle at 75% 90%, rgba(212,168,67,0.3) 0%, transparent 6%),
    radial-gradient(circle at 25% 90%, rgba(153,50,204,0.3) 0%, transparent 6%);
  animation: orbit-rotate 8s linear infinite;
}

@keyframes orbit-rotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.gacha-item {
  font-size: 100px;
  transition: all 0.3s ease;
  position: relative;
  z-index: 1;
  filter: drop-shadow(0 0 20px rgba(212,168,67,0.5));
}

.gacha-item:hover {
  transform: scale(1.05);
  filter: drop-shadow(0 0 30px rgba(212,168,67,0.8));
}

.gacha-item.shake { animation: shake 0.5s ease-in-out infinite; }
.gacha-item.open { animation: open 1s ease-in-out; }

@keyframes shake {
  0%, 100% { transform: rotate(0deg) scale(1); }
  25% { transform: rotate(-8deg) scale(1.02); }
  75% { transform: rotate(8deg) scale(1.02); }
}

@keyframes open {
  0% { transform: scale(1); opacity: 1; filter: brightness(1); }
  30% { transform: scale(1.15); filter: brightness(1.5) drop-shadow(0 0 40px rgba(212,168,67,0.8)); }
  60% { transform: scale(0.8); opacity: 0.7; }
  100% { transform: scale(0); opacity: 0; }
}

/* === 抽卡按钮 === */
.gacha-buttons {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 18px;
  width: 100%;
}
.gacha-btn-row {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 16px;
}

.gacha-btn {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 14px 32px;
  border: none;
  border-radius: 30px;
  background: linear-gradient(135deg, #b8860b, #d4a843, #f0d060, #d4a843, #b8860b);
  background-size: 200% 200%;
  color: #1a1a2e;
  font-weight: 800;
  font-size: 15px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 
    0 4px 15px rgba(212,168,67,0.4),
    0 0 0 1px rgba(212,168,67,0.3),
    inset 0 1px 0 rgba(255,255,255,0.3);
  overflow: hidden;
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* 流光效果 */
.gacha-btn::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    135deg, 
    transparent 30%, 
    rgba(255,255,255,0.4) 45%, 
    rgba(255,255,255,0.6) 50%, 
    rgba(255,255,255,0.4) 55%, 
    transparent 70%
  );
  transform: translateX(-100%);
  transition: transform 0.6s;
}

.gacha-btn:hover::before { 
  transform: translateX(100%); 
}

.gacha-btn:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 
    0 8px 30px rgba(212,168,67,0.6),
    0 0 0 2px rgba(212,168,67,0.5),
    0 0 40px rgba(212,168,67,0.3),
    inset 0 1px 0 rgba(255,255,255,0.4);
  background-position: 100% 100%;
}

.gacha-btn:active {
  transform: translateY(1px) scale(0.97);
  box-shadow: 
    0 2px 10px rgba(212,168,67,0.3),
    inset 0 2px 4px rgba(0,0,0,0.2);
}

.gacha-btn:disabled {
  background: linear-gradient(135deg, #3a3a45, #4a4a55, #3a3a45);
  color: #888;
  cursor: not-allowed;
  box-shadow: none;
  transform: none;
}

.gacha-btn:disabled:hover { 
  transform: none; 
  box-shadow: none; 
}

.gacha-btn:disabled::before { display: none; }

/* 多抽按钮 - 更大更华丽 */
.gacha-btn-multi {
  padding: 16px 40px;
  font-size: 16px;
  border: 2px solid rgba(255,215,0,0.7);
  box-shadow: 
    0 4px 20px rgba(212,168,67,0.5), 
    inset 0 0 20px rgba(255,215,0,0.15),
    0 0 0 1px rgba(212,168,67,0.4);
  animation: multi-pulse 2s ease-in-out infinite;
}

@keyframes multi-pulse {
  0%, 100% { box-shadow: 0 4px 20px rgba(212,168,67,0.5), inset 0 0 20px rgba(255,215,0,0.15), 0 0 0 1px rgba(212,168,67,0.4); }
  50% { box-shadow: 0 6px 30px rgba(212,168,67,0.7), inset 0 0 30px rgba(255,215,0,0.25), 0 0 0 2px rgba(212,168,67,0.6), 0 0 30px rgba(255,215,0,0.2); }
}

.gacha-btn-multi:hover {
  box-shadow: 
    0 10px 40px rgba(212,168,67,0.8), 
    inset 0 0 30px rgba(255,215,0,0.25), 
    0 0 0 3px rgba(255,215,0,0.5),
    0 0 60px rgba(255,215,0,0.3);
  animation: none;
}

/*  mega按钮 - 最华丽 */
.gacha-btn-mega {
  padding: 18px 48px;
  font-size: 18px;
  background: linear-gradient(135deg, #c9952c, #f0d060, #fff8a0, #f0d060, #d4a843, #c9952c);
  background-size: 300% 300%;
  border: 3px solid rgba(255,223,0,0.9);
  box-shadow: 
    0 4px 30px rgba(212,168,67,0.6), 
    inset 0 0 30px rgba(255,215,0,0.2),
    0 0 0 2px rgba(212,168,67,0.5);
  animation: mega-shine 3s ease-in-out infinite, mega-glow 2s ease-in-out infinite;
}

@keyframes mega-shine {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

@keyframes mega-glow {
  0%, 100% { filter: brightness(1); }
  50% { filter: brightness(1.1); }
}

.gacha-btn-mega:hover {
  box-shadow: 
    0 12px 50px rgba(212,168,67,0.9), 
    inset 0 0 40px rgba(255,215,0,0.3),
    0 0 0 4px rgba(255,223,0,0.6),
    0 0 80px rgba(255,215,0,0.4);
  animation: none;
  filter: brightness(1.15);
}

.gacha-btn-label { 
  position: relative; 
  z-index: 1;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
}

.gacha-btn-cost {
  position: relative; 
  z-index: 1;
  font-size: 12px;
  opacity: 0.9;
  font-weight: 600;
}

.gacha-tool-row {
  display: flex;
  gap: 12px;
}

.gacha-tool-row :deep(.n-button) {
  background: rgba(212,168,67,0.1);
  border: 1px solid rgba(212,168,67,0.2);
  transition: all 0.3s;
}

.gacha-tool-row :deep(.n-button:hover) {
  background: rgba(212,168,67,0.2);
  border-color: rgba(212,168,67,0.4);
  box-shadow: 0 0 15px rgba(212,168,67,0.3);
  transform: translateY(-2px);
}

/* === 结果卡片 === */
.result-summary {
  padding: 20px;
  margin-bottom: 20px;
  background: linear-gradient(135deg, rgba(212,168,67,0.12), rgba(212,168,67,0.05));
  border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.25);
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.05);
}

.filter-section {
  padding: 20px;
  margin-bottom: 20px;
  background: rgba(255,255,255,0.03);
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,0.08);
}

.result-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
  margin: 20px 0;
}

.result-item {
  position: relative;
  background: linear-gradient(135deg, rgba(25,25,40,0.9), rgba(15,15,25,0.9));
  border: 2px solid;
  border-radius: 12px;
  padding: 16px;
  text-align: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
}

.result-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
}

.result-item:hover {
  transform: translateY(-5px) scale(1.02);
}

.result-item-glow {
  position: absolute;
  inset: 0;
  border-radius: 12px;
  pointer-events: none;
  opacity: 0.5;
}

.result-item h4 {
  margin: 0 0 10px 0;
  position: relative;
  z-index: 1;
  font-size: 15px;
}

.result-item p {
  margin: 6px 0;
  font-size: 0.9em;
  position: relative;
  z-index: 1;
}

.result-quality-text {
  font-weight: 700;
}

/* 品质特效 - 结果卡片 - 大幅提升 */
.result-quality-common { border-color: rgba(158,158,158,0.5); }
.result-quality-uncommon { border-color: rgba(76,175,80,0.5); box-shadow: 0 0 8px rgba(76,175,80,0.2); }
.result-quality-rare { border-color: rgba(33,150,243,0.5); box-shadow: 0 0 10px rgba(33,150,243,0.25); }

.result-quality-epic,
.result-quality-mystic {
  border-color: rgba(156,39,176,0.6);
  box-shadow: 
    0 0 15px rgba(156,39,176,0.3),
    inset 0 0 20px rgba(156,39,176,0.1);
}

.result-quality-epic::after,
.result-quality-mystic::after {
  content: '';
  position: absolute;
  inset: -1px;
  border-radius: 12px;
  border: 1px solid transparent;
  background: linear-gradient(135deg, rgba(156,39,176,0.4), transparent, rgba(156,39,176,0.4)) border-box;
  -webkit-mask: linear-gradient(#fff 0 0) padding-box, linear-gradient(#fff 0 0);
  mask: linear-gradient(#fff 0 0) padding-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
}

.result-quality-legendary,
.result-quality-celestial {
  border-color: rgba(255,152,0,0.7);
  box-shadow: 
    0 0 20px rgba(255,152,0,0.4),
    0 0 40px rgba(255,152,0,0.15),
    inset 0 0 30px rgba(255,152,0,0.1);
  animation: legendary-breathe 3s ease-in-out infinite;
}

@keyframes legendary-breathe {
  0%, 100% { 
    box-shadow: 0 0 20px rgba(255,152,0,0.4), 0 0 40px rgba(255,152,0,0.15), inset 0 0 30px rgba(255,152,0,0.1);
  }
  50% { 
    box-shadow: 0 0 30px rgba(255,152,0,0.6), 0 0 60px rgba(255,152,0,0.25), inset 0 0 40px rgba(255,152,0,0.15);
  }
}

.result-quality-mythic,
.result-quality-divine {
  border-color: rgba(244,67,54,0.8);
  box-shadow: 
    0 0 25px rgba(244,67,54,0.5),
    0 0 50px rgba(244,67,54,0.2),
    0 0 80px rgba(244,67,54,0.1),
    inset 0 0 40px rgba(244,67,54,0.15);
  animation: mythic-breathe 2.5s ease-in-out infinite;
}

@keyframes mythic-breathe {
  0%, 100% { 
    box-shadow: 0 0 25px rgba(244,67,54,0.5), 0 0 50px rgba(244,67,54,0.2), 0 0 80px rgba(244,67,54,0.1), inset 0 0 40px rgba(244,67,54,0.15);
    filter: brightness(1);
  }
  50% { 
    box-shadow: 0 0 40px rgba(244,67,54,0.8), 0 0 80px rgba(244,67,54,0.35), 0 0 120px rgba(244,67,54,0.2), inset 0 0 50px rgba(244,67,54,0.2);
    filter: brightness(1.1);
  }
}

/* === 概率说明 === */
.prob-card {
  background: linear-gradient(135deg, rgba(20,18,35,0.95), rgba(15,13,25,0.95)) !important;
  border: 1px solid rgba(212,168,67,0.15);
  border-radius: 12px;
}

.probability-bars {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.prob-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 4px 0;
}

.prob-label {
  min-width: 70px;
  text-align: right;
  font-weight: 700;
}

.prob-item :deep(.n-progress) {
  flex: 1;
}

.prob-item :deep(.n-progress .n-progress-rail) {
  background: rgba(255,255,255,0.05);
  border-radius: 6px;
  overflow: hidden;
}

.prob-item :deep(.n-progress .n-progress-rail::after) {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
  animation: progress-shimmer 3s ease-in-out infinite;
}

@keyframes progress-shimmer {
  0%, 100% { transform: translateX(-100%); }
  50% { transform: translateX(100%); }
}

/* === 心愿单 === */
@keyframes rotate-stars {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.wish-bonus {
  position: relative;
  z-index: 1;
  border-color: #ffd700 !important;
  box-shadow: 
    0 0 20px rgba(255,215,0,0.4),
    inset 0 0 30px rgba(255,215,0,0.1) !important;
  animation: wish-pulse 2s ease-in-out infinite;
}

@keyframes wish-pulse {
  0%, 100% { box-shadow: 0 0 20px rgba(255,215,0,0.4), inset 0 0 30px rgba(255,215,0,0.1); }
  50% { box-shadow: 0 0 30px rgba(255,215,0,0.6), inset 0 0 40px rgba(255,215,0,0.15); }
}

.wish-bonus::before {
  content: '★';
  position: absolute;
  top: -12px;
  right: -12px;
  color: #ffd700;
  font-size: 24px;
  text-shadow: 0 0 12px rgba(255,215,0,1), 0 0 24px rgba(255,215,0,0.8);
  animation: rotate-stars 3s linear infinite;
  transform-origin: center;
  z-index: 2;
}

/* 心愿单弹窗美化 */
:deep(.n-modal .n-card) {
  background: linear-gradient(135deg, rgba(25,22,40,0.98), rgba(15,12,25,0.98)) !important;
  border: 1px solid rgba(212,168,67,0.2);
}

:deep(.n-modal .n-divider) {
  border-color: rgba(212,168,67,0.15);
}

:deep(.n-modal .n-divider__title) {
  color: #d4a843;
  font-weight: 600;
}

:deep(.n-modal .n-alert) {
  background: rgba(212,168,67,0.08);
  border-color: rgba(212,168,67,0.2);
}

:deep(.n-modal .n-alert .n-alert__header) {
  color: #f0d060;
}

/* === 翻牌动画 === */
.flip-stage {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 24px;
  padding: 24px;
  background: rgba(10,10,20,0.6);
  border-radius: 20px;
  backdrop-filter: blur(10px);
}

.flip-cards {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 16px;
}

.flip-card {
  width: 110px;
  height: 155px;
  perspective: 1000px;
  cursor: pointer;
}

.flip-card-inner {
  position: relative;
  width: 100%; 
  height: 100%;
  transition: transform 0.7s cubic-bezier(0.4, 0, 0.2, 1);
  transform-style: preserve-3d;
}

.flip-card.flipped .flip-card-inner { 
  transform: rotateY(180deg); 
}

.flip-card-back, .flip-card-front {
  position: absolute;
  inset: 0;
  backface-visibility: hidden;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* 卡牌背面 - 精致花纹 */
.flip-card-back {
  background: 
    linear-gradient(135deg, #1a1535 0%, #2a1f4e 50%, #1a1535 100%);
  border: 2px solid rgba(212,168,67,0.5);
  box-shadow: 
    0 0 20px rgba(212,168,67,0.2),
    inset 0 0 30px rgba(0,0,0,0.3);
  position: relative;
  overflow: hidden;
}

/* 背面花纹装饰 */
.flip-card-back::before {
  content: '';
  position: absolute;
  inset: 8px;
  border: 1px solid rgba(212,168,67,0.3);
  border-radius: 8px;
}

.flip-card-back::after {
  content: '';
  position: absolute;
  inset: 0;
  background: 
    radial-gradient(circle at 20% 20%, rgba(212,168,67,0.1) 0%, transparent 20%),
    radial-gradient(circle at 80% 20%, rgba(212,168,67,0.1) 0%, transparent 20%),
    radial-gradient(circle at 20% 80%, rgba(212,168,67,0.1) 0%, transparent 20%),
    radial-gradient(circle at 80% 80%, rgba(212,168,67,0.1) 0%, transparent 20%),
    radial-gradient(circle at 50% 50%, rgba(153,50,204,0.05) 0%, transparent 30%);
}

.card-back-icon {
  font-size: 36px;
  color: rgba(212,168,67,0.7);
  text-shadow: 0 0 20px rgba(212,168,67,0.5);
  animation: back-pulse 2s ease-in-out infinite;
  position: relative;
  z-index: 1;
}

/* 四角装饰 */
.flip-card-back .corner-decoration {
  position: absolute;
  width: 20px;
  height: 20px;
  border-color: rgba(212,168,67,0.4);
  border-style: solid;
  border-width: 0;
}

@keyframes back-pulse {
  0%, 100% { opacity: 0.5; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.15); }
}

.flip-card-front {
  background: linear-gradient(135deg, #12121a, #1a1a2e);
  border: 2px solid;
  transform: rotateY(180deg);
  gap: 8px;
  padding: 10px;
  overflow: hidden;
  position: relative;
}

/* 正面光效 */
.flip-card-front::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: conic-gradient(from 0deg, transparent, rgba(255,255,255,0.1), transparent 30%);
  animation: front-rotate 4s linear infinite;
}

@keyframes front-rotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.card-glow {
  position: absolute;
  inset: 0;
  border-radius: 12px;
  pointer-events: none;
}

.card-icon { 
  font-size: 32px; 
  position: relative; 
  z-index: 1;
  filter: drop-shadow(0 2px 4px rgba(0,0,0,0.3));
}

.card-name {
  font-size: 12px; 
  color: #e8e0d0; 
  text-align: center;
  font-weight: 700; 
  position: relative; 
  z-index: 1;
  line-height: 1.3; 
  max-height: 2.6em; 
  overflow: hidden;
  text-shadow: 0 1px 2px rgba(0,0,0,0.5);
}

.card-quality { 
  font-size: 11px; 
  font-weight: 800; 
  position: relative; 
  z-index: 1;
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* 翻牌品质特效 - 大幅提升 */
.flip-card.quality-common.flipped { filter: drop-shadow(0 0 5px rgba(158,158,158,0.5)); }
.flip-card.quality-uncommon.flipped { filter: drop-shadow(0 0 8px rgba(76,175,80,0.6)); }
.flip-card.quality-rare.flipped { filter: drop-shadow(0 0 10px rgba(33,150,243,0.6)); }

.flip-card.quality-epic.flipped,
.flip-card.quality-mystic.flipped { 
  animation: epic-flip-glow 2s ease-in-out infinite;
}

@keyframes epic-flip-glow {
  0%, 100% { filter: drop-shadow(0 0 10px #9c27b0) drop-shadow(0 0 20px #9c27b080); }
  50% { filter: drop-shadow(0 0 20px #9c27b0) drop-shadow(0 0 40px #9c27b0) drop-shadow(0 0 60px #9c27b040); }
}

.flip-card.quality-legendary.flipped,
.flip-card.quality-celestial.flipped { 
  animation: legendary-flip-glow 2s ease-in-out infinite;
}

@keyframes legendary-flip-glow {
  0%, 100% { filter: drop-shadow(0 0 15px #ff9800) drop-shadow(0 0 30px #ff980060) drop-shadow(0 0 45px #ff980030); }
  50% { filter: drop-shadow(0 0 30px #ff9800) drop-shadow(0 0 60px #ff9800) drop-shadow(0 0 90px #ff980060) drop-shadow(0 0 120px #ff980030); }
}

.flip-card.quality-mythic.flipped,
.flip-card.quality-divine.flipped { 
  animation: mythic-flip-glow 1.5s ease-in-out infinite;
}

@keyframes mythic-flip-glow {
  0%, 100% { filter: drop-shadow(0 0 20px #e91e63) drop-shadow(0 0 40px #e91e6380) drop-shadow(0 0 60px #e91e6340); }
  50% { filter: drop-shadow(0 0 40px #e91e63) drop-shadow(0 0 80px #e91e63) drop-shadow(0 0 120px #e91e6380) drop-shadow(0 0 160px #e91e6340); }
}

.flip-actions { 
  margin-top: 12px; 
  display: flex;
  gap: 16px;
}

.flip-actions .n-button {
  padding: 12px 32px;
  font-weight: 600;
}

/* === 弹窗整体美化 === */
:deep(.n-dialog) {
  background: linear-gradient(135deg, rgba(20,18,35,0.98), rgba(12,10,20,0.98)) !important;
  border: 1px solid rgba(212,168,67,0.2);
  border-radius: 16px;
}

:deep(.n-dialog__title) {
  color: #f0d060;
  font-weight: 700;
  font-size: 18px;
}

:deep(.n-dialog__close) {
  color: rgba(212,168,67,0.6);
}

:deep(.n-dialog__close:hover) {
  color: #f0d060;
  background: rgba(212,168,67,0.1);
}

/* Tabs美化 */
:deep(.n-tabs .n-tabs-nav) {
  background: rgba(212,168,67,0.05);
  border-radius: 12px;
  padding: 4px;
}

:deep(.n-tabs .n-tabs-tab) {
  color: #a09080;
  font-weight: 600;
  transition: all 0.3s;
}

:deep(.n-tabs .n-tabs-tab:hover) {
  color: #d4a843;
}

:deep(.n-tabs .n-tabs-tab.n-tabs-tab--active) {
  color: #1a1a2e;
  background: linear-gradient(135deg, #d4a843, #f0d060);
  border-radius: 8px;
  box-shadow: 0 4px 15px rgba(212,168,67,0.4);
}

/* === 响应式 === */
@media screen and (max-width: 768px) {
  .result-grid { grid-template-columns: repeat(2, 1fr); }
  .pool-title { font-size: 26px; }
  .gacha-btn { padding: 12px 24px; font-size: 14px; }
  .gacha-btn-multi { padding: 14px 32px; font-size: 15px; }
  .gacha-btn-mega { padding: 16px 36px; font-size: 16px; }
  .gacha-item-container { width: 200px; height: 200px; }
  .gacha-item { font-size: 80px; }
}

@media (max-width: 480px) {
  .flip-card { width: 90px; height: 126px; }
  .card-icon { font-size: 26px; }
  .card-name { font-size: 10px; }
  .gacha-btn-row { gap: 10px; }
  .pool-title { font-size: 22px; letter-spacing: 2px; }
  .gacha-type-selector :deep(.n-radio-button) {
    padding: 8px 18px;
    font-size: 13px;
  }
}

/* === Light theme 适配 === */
:root .gacha-page {
  --gacha-bg: #0a0a14;
}

@media (prefers-color-scheme: light) {
  .gacha-page {
    background: #f5f0e8;
    color: #2c2c2c;
  }
  
  .gacha-page::before {
    opacity: 0.5;
  }
  
  .gacha-page-bg {
    background: 
      linear-gradient(180deg, #e8dcc8 0%, #f0e8d8 30%, transparent 100%),
      radial-gradient(ellipse at 50% 0%, rgba(212,168,67,0.12) 0%, transparent 50%),
      radial-gradient(ellipse at 30% 20%, rgba(153,50,204,0.1) 0%, transparent 40%);
  }
  
  .pool-title {
    filter: drop-shadow(0 2px 4px rgba(212,168,67,0.2));
  }
  
  .gacha-type-selector :deep(.n-radio-group) {
    background: rgba(255,255,255,0.8);
    border-color: rgba(212,168,67,0.3);
  }
  
  .spirit-stones {
    background: linear-gradient(135deg, rgba(212,168,67,0.15), rgba(212,168,67,0.08));
    border-color: rgba(212,168,67,0.4);
  }
  
  .gacha-btn {
    color: #1a1a2e;
    box-shadow: 0 4px 15px rgba(212,168,67,0.3);
  }
  
  .gacha-btn:hover {
    box-shadow: 0 8px 30px rgba(212,168,67,0.5);
  }
  
  .result-item {
    background: linear-gradient(135deg, rgba(255,255,255,0.95), rgba(245,245,250,0.95));
    border-color: rgba(0,0,0,0.1);
  }
  
  .filter-section {
    background: rgba(0,0,0,0.03);
    border-color: rgba(0,0,0,0.08);
  }
  
  .flip-stage {
    background: rgba(255,255,255,0.8);
  }
  
  .flip-card-front {
    background: linear-gradient(135deg, #f8f6f0, #ede8dc);
  }
  
  .card-name { color: #2c2c2c; }
  
  :deep(.n-modal .n-card),
  :deep(.n-dialog) {
    background: linear-gradient(135deg, rgba(255,255,255,0.98), rgba(250,248,245,0.98)) !important;
  }
}

/* === 卡池环形装饰 === */
.gacha-pool-ring {
  position: absolute;
  width: 180px;
  height: 180px;
  border-radius: 50%;
  border: 2px solid rgba(212,168,67,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: ring-rotate 12s linear infinite;
  z-index: 0;
}
.gacha-pool-ring::before {
  content: '';
  position: absolute;
  inset: -8px;
  border-radius: 50%;
  border: 1px dashed rgba(212,168,67,0.15);
  animation: ring-rotate 20s linear infinite reverse;
}
.gacha-pool-ring::after {
  content: '';
  position: absolute;
  inset: 8px;
  border-radius: 50%;
  border: 1px solid rgba(153,50,204,0.2);
  animation: ring-rotate 8s linear infinite;
}
.ring-text {
  position: absolute;
  bottom: -28px;
  font-size: 13px;
  color: rgba(212,168,67,0.6);
  letter-spacing: 8px;
  font-weight: 600;
}
@keyframes ring-rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* === 按钮网格优化 === */
.gacha-btn-row {
  display: grid !important;
  grid-template-columns: 1fr 1fr;
  gap: 12px !important;
  width: 100%;
  max-width: 360px;
}
.gacha-btn {
  width: 100%;
  justify-content: center;
}
.gacha-btn-100 {
  background: linear-gradient(135deg, #8b2fc9, #c850c0, #ff6ec7, #c850c0, #8b2fc9) !important;
  background-size: 300% 300% !important;
  border: 3px solid rgba(200,80,192,0.8) !important;
  color: #fff !important;
  animation: mega-shine 3s ease-in-out infinite, btn100-glow 2s ease-in-out infinite !important;
}
.gacha-btn-100:hover {
  box-shadow: 0 12px 50px rgba(200,80,192,0.7), 0 0 80px rgba(200,80,192,0.3) !important;
}
@keyframes btn100-glow {
  0%, 100% { box-shadow: 0 4px 30px rgba(200,80,192,0.5), inset 0 0 20px rgba(255,110,199,0.15); }
  50% { box-shadow: 0 6px 40px rgba(200,80,192,0.7), inset 0 0 30px rgba(255,110,199,0.25), 0 0 40px rgba(200,80,192,0.3); }
}

/* === 焰晶显示优化 === */
.spirit-stones {
  background: linear-gradient(135deg, rgba(20,15,35,0.8), rgba(30,20,50,0.6)) !important;
  border: 1px solid rgba(212,168,67,0.3) !important;
  border-radius: 16px !important;
  padding: 8px 24px !important;
  backdrop-filter: blur(10px);
}

/* === 移动端按钮优化 === */
@media (max-width: 480px) {
  .gacha-btn-row {
    max-width: 300px;
    gap: 8px !important;
  }
  .gacha-btn { padding: 10px 16px !important; font-size: 13px !important; }
  .gacha-btn-multi { padding: 12px 20px !important; font-size: 14px !important; }
  .gacha-btn-mega, .gacha-btn-100 { padding: 14px 24px !important; font-size: 15px !important; }
  .gacha-pool-ring { width: 140px; height: 140px; }
  .gacha-item-container { width: 180px !important; height: 180px !important; }
  .gacha-item { font-size: 70px !important; }
}

</style>
