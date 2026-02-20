<template>
  <n-card :bordered="false">
        <n-tabs type="line">
          <n-tab-pane name="equipment" tab="装备">
            <n-space justify="end" style="margin-bottom:8px">
              <n-button type="primary" size="small" @click="oneKeyEquip">⚡ 一键穿戴最强</n-button>
              <n-button type="warning" size="small" @click="oneKeyUnequip">🔄 一键卸下</n-button>
            </n-space>
            <n-grid :cols="2" :x-gap="12" :y-gap="8">
              <n-grid-item v-for="(name, type) in equipmentTypes" :key="type">
                <n-card hoverable @click="showEquipmentList(type)"
                  :class="['equip-slot-card', playerStore.equippedArtifacts[type] ? 'quality-' + playerStore.equippedArtifacts[type].quality : 'slot-empty']"
                >
                  <template #header>
                    <n-space justify="space-between" align="center">
                      <span class="slot-header"><span class="equip-type-icon">{{ equipTypeIcons[type] || '📦' }}</span> {{ name }}</span>
                      <n-button
                        size="small"
                        type="error"
                        @click.stop="unequipItem(type)"
                        v-if="playerStore.equippedArtifacts[type]"
                      >
                        卸下
                      </n-button>
                    </n-space>
                  </template>
                  <div v-if="playerStore.equippedArtifacts[type]" class="equipped-item-info">
                    <span class="equipped-badge">已装备</span>
                    <span class="equip-name">{{ playerStore.equippedArtifacts[type].name }}</span>
                    <span v-if="playerStore.equippedArtifacts[type].enhanceLevel" class="enhance-level">+{{ playerStore.equippedArtifacts[type].enhanceLevel }}</span>
                  </div>
                  <p v-else class="empty-slot-text">未装备</p>
                  <template #footer>
                    <n-space justify="space-between">
                      <span>{{ name }}</span>
                      <n-button
                        size="small"
                        type="info"
                        @click.stop="showEquipmentDetails(playerStore.equippedArtifacts[type])"
                        v-if="playerStore.equippedArtifacts[type]"
                      >
                        详细
                      </n-button>
                    </n-space>
                  </template>
                </n-card>
              </n-grid-item>
            </n-grid>
          </n-tab-pane>
          <n-tab-pane name="herbs" tab="焰草">
            <div class="item-grid item-grid-4" v-if="groupedHerbs.length">
              <div v-for="herb in groupedHerbs" :key="herb.id" class="grid-cell herb-cell" :class="'quality-' + (herb.quality || 'common')">
                <span class="cell-icon">🌿</span>
                <span class="cell-name">{{ herb.name }}</span>
                <span class="item-count-badge">{{ herb.count }}</span>
              </div>
            </div>
            <n-empty v-else />
          </n-tab-pane>
          <n-tab-pane name="pills" tab="焰丹">
            <div class="item-grid item-grid-4" v-if="groupedPills.length">
              <div v-for="pill in groupedPills" :key="pill.id" class="grid-cell pill-cell" :class="'quality-' + (pill.quality || 'common')" @click="usePill(pill)">
                <span class="cell-icon">💊</span>
                <span class="cell-name">{{ pill.name }}</span>
                <span class="item-count-badge">{{ pill.count }}</span>
                <span class="cell-action">服用</span>
              </div>
            </div>
            <n-empty v-else />
          </n-tab-pane>
          <n-tab-pane name="formulas" tab="焰方">
            <n-tabs type="segment">
              <n-tab-pane name="complete" tab="完整焰方">
                <n-grid :cols="2" :x-gap="12" :y-gap="8" v-if="groupedFormulas.complete.length">
                  <n-grid-item v-for="formula in groupedFormulas.complete" :key="formula.id">
                    <n-card hoverable>
                      <template #header>
                        <n-space justify="space-between">
                          <span>{{ formula.name }}</span>
                          <n-space>
                            <n-tag type="success" size="small">完整</n-tag>
                            <n-tag type="info" size="small">{{ pillGrades[formula.grade].name }}</n-tag>
                            <n-tag type="warning" size="small">{{ pillTypes[formula.type].name }}</n-tag>
                          </n-space>
                        </n-space>
                      </template>
                      <p>{{ formula.description }}</p>
                    </n-card>
                  </n-grid-item>
                </n-grid>
                <n-empty v-else />
              </n-tab-pane>
              <n-tab-pane name="incomplete" tab="残缺焰方">
                <n-grid :cols="2" :x-gap="12" :y-gap="8" v-if="groupedFormulas.incomplete.length">
                  <n-grid-item v-for="formula in groupedFormulas.incomplete" :key="formula.id">
                    <n-card hoverable>
                      <template #header>
                        <n-space justify="space-between">
                          <span>{{ formula.name }}</span>
                          <n-space>
                            <n-tag type="warning" size="small">残缺</n-tag>
                            <n-tag type="info" size="small">{{ pillGrades[formula.grade].name }}</n-tag>
                            <n-tag type="warning" size="small">{{ pillTypes[formula.type].name }}</n-tag>
                          </n-space>
                        </n-space>
                      </template>
                      <p>{{ formula.description }}</p>
                      <n-progress
                        type="line"
                        :percentage="Number(((formula.fragments / formula.fragmentsNeeded) * 100).toFixed(2))"
                        :show-indicator="true"
                        indicator-placement="inside"
                      >
                        收集进度: {{ formula.fragments }}/{{ formula.fragmentsNeeded }}
                      </n-progress>
                    </n-card>
                  </n-grid-item>
                </n-grid>
                <n-empty v-else />
              </n-tab-pane>
            </n-tabs>
          </n-tab-pane>
          <n-tab-pane name="pets" tab="焰兽">
            <n-space style="margin-bottom: 16px">
              <n-select
                v-model:value="selectedRarityToRelease"
                :options="options"
                placeholder="选择放生品阶"
                style="width: 150px"
              />
              <n-button
                @click="showBatchReleaseConfirm = true"
                :disabled="!playerStore.items.filter(item => item.type === 'pet').length"
              >
                一键放生
              </n-button>
            </n-space>
            <n-modal v-model:show="showBatchReleaseConfirm" preset="dialog" title="批量放生确认" style="width: 600px">
              <p>
                确定要放生{{
                  selectedRarityToRelease === 'all' ? '所有' : petRarities[selectedRarityToRelease].name
                }}品阶的未出战焰兽吗？此操作不可撤销。
              </p>
              <n-space justify="end" style="margin-top: 16px">
                <n-button size="small" @click="showBatchReleaseConfirm = false">取消</n-button>
                <n-button size="small" type="error" @click="batchReleasePets">确认放生</n-button>
              </n-space>
            </n-modal>
            <n-pagination
              v-if="filteredPets.length > 12"
              v-model:page="currentPage"
              :page-size="pageSize"
              :item-count="filteredPets.length"
              @update:page-size="onPageSizeChange"
              :page-slot="7"
            />
            <n-grid v-if="displayPets.length" :cols="2" :x-gap="12" :y-gap="8" style="margin-top: 16px">
              <n-grid-item v-for="pet in displayPets" :key="pet.id">
                <n-card hoverable
                  :class="['pet-card', 'pet-quality-' + pet.rarity, playerStore.activePet?.id === pet.id ? 'pet-active' : '']"
                >
                  <template #header>
                    <n-space justify="space-between" align="center">
                      <span class="pet-name-row">
                        <span>🐾 {{ pet.name }}</span>
                        <span class="pet-stars">{{ '⭐'.repeat(Math.min(pet.star || 0, 5)) }}</span>
                      </span>
                      <n-button size="small" type="primary" @click="useItem(pet)">
                        {{ playerStore.activePet?.id === pet.id ? '召回' : '出战' }}
                      </n-button>
                    </n-space>
                  </template>
                  <p>{{ pet.description }}</p>
                  <n-space vertical>
                    <span class="pet-quality-tag" :style="{ background: 'linear-gradient(135deg, ' + petRarities[pet.rarity].color + '33, ' + petRarities[pet.rarity].color + '11)', color: petRarities[pet.rarity].color, border: '1px solid ' + petRarities[pet.rarity].color + '66' }">
                      {{ petRarities[pet.rarity].name }}
                    </span>
                    <n-space justify="space-between">
                      <n-text>等级: {{ pet.level || 1 }}</n-text>
                      <n-text>星级: {{ pet.star || 0 }}</n-text>
                      <n-button size="small" @click="showPetDetails(pet)">详情</n-button>
                    </n-space>
                  </n-space>
                  <span v-if="playerStore.activePet?.id === pet.id" class="pet-active-badge">出战中</span>
                </n-card>
              </n-grid-item>
            </n-grid>
            <n-empty v-else />
          </n-tab-pane>
        </n-tabs>
      </n-card>
  <!-- 焰兽详情弹窗 -->
  <n-modal v-model:show="showPetModal" preset="dialog" title="焰兽详情" style="width: 600px">
    <template v-if="selectedPet">
      <n-descriptions bordered>
        <n-descriptions-item label="名称">{{ selectedPet.name }}</n-descriptions-item>
        <n-descriptions-item label="品质">
          <n-tag :style="{ color: petRarities[selectedPet.rarity].color }">
            {{ petRarities[selectedPet.rarity].name }}
          </n-tag>
        </n-descriptions-item>
        <n-descriptions-item label="等级">{{ selectedPet.level || 1 }}</n-descriptions-item>
        <n-descriptions-item label="星级">{{ selectedPet.star || 0 }}</n-descriptions-item>
        <n-descriptions-item label="焰阶">{{ Math.floor((selectedPet.star || 0) / 5) }}阶</n-descriptions-item>
      </n-descriptions>
      <n-divider>属性加成</n-divider>
      <n-descriptions bordered>
        <n-descriptions-item label="攻击加成">
          +{{ (getPetBonus(selectedPet).attack * 100).toFixed(1) }}%
        </n-descriptions-item>
        <n-descriptions-item label="防御加成">
          +{{ (getPetBonus(selectedPet).defense * 100).toFixed(1) }}%
        </n-descriptions-item>
        <n-descriptions-item label="生命加成">
          +{{ (getPetBonus(selectedPet).health * 100).toFixed(1) }}%
        </n-descriptions-item>
      </n-descriptions>
      <n-divider>焰兽属性</n-divider>
      <n-collapse>
        <n-collapse-item title="展开" name="1">
          <n-divider>基础属性</n-divider>
          <n-descriptions bordered :column="2">
            <n-descriptions-item label="攻击力">{{ selectedPet.combatAttributes?.attack || 0 }}</n-descriptions-item>
            <n-descriptions-item label="生命值">{{ selectedPet.combatAttributes?.health || 0 }}</n-descriptions-item>
            <n-descriptions-item label="防御力">{{ selectedPet.combatAttributes?.defense || 0 }}</n-descriptions-item>
            <n-descriptions-item label="速度">{{ selectedPet.combatAttributes?.speed || 0 }}</n-descriptions-item>
          </n-descriptions>
          <n-divider>战斗属性</n-divider>
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="暴击率">
              {{ ((selectedPet.combatAttributes?.critRate || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="连击率">
              {{ ((selectedPet.combatAttributes?.comboRate || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="反击率">
              {{ ((selectedPet.combatAttributes?.counterRate || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="眩晕率">
              {{ ((selectedPet.combatAttributes?.stunRate || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="闪避率">
              {{ ((selectedPet.combatAttributes?.dodgeRate || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="吸血率">
              {{ ((selectedPet.combatAttributes?.vampireRate || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
          </n-descriptions>
          <n-divider>战斗抗性</n-divider>
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="抗暴击">
              {{ ((selectedPet.combatAttributes?.critResist || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="抗连击">
              {{ ((selectedPet.combatAttributes?.comboResist || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="抗反击">
              {{ ((selectedPet.combatAttributes?.counterResist || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="抗眩晕">
              {{ ((selectedPet.combatAttributes?.stunResist || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="抗闪避">
              {{ ((selectedPet.combatAttributes?.dodgeResist || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="抗吸血">
              {{ ((selectedPet.combatAttributes?.vampireResist || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
          </n-descriptions>
          <n-divider>特殊属性</n-divider>
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="强化治疗">
              {{ ((selectedPet.combatAttributes?.healBoost || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="强化爆伤">
              {{ ((selectedPet.combatAttributes?.critDamageBoost || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="弱化爆伤">
              {{ ((selectedPet.combatAttributes?.critDamageReduce || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="最终增伤">
              {{ ((selectedPet.combatAttributes?.finalDamageBoost || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="最终减伤">
              {{ ((selectedPet.combatAttributes?.finalDamageReduce || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="战斗属性提升">
              {{ ((selectedPet.combatAttributes?.combatBoost || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
            <n-descriptions-item label="战斗抗性提升">
              {{ ((selectedPet.combatAttributes?.resistanceBoost || 0) * 100).toFixed(1) }}%
            </n-descriptions-item>
          </n-descriptions>
        </n-collapse-item>
      </n-collapse>
      <n-divider>操作</n-divider>
      <n-space vertical>
        <n-space justify="space-between">
          <span>升级（消耗{{ getUpgradeCost(selectedPet) }} / {{ playerStore.petEssence }}焰兽精华）</span>
          <n-button size="small" type="primary" @click="upgradePet(selectedPet)" :disabled="!canUpgrade(selectedPet)">
            升级
          </n-button>
        </n-space>
        <n-space justify="space-between">
          <span>升星（需要相同品质和名字的焰兽）</span>
          <n-select
            v-model:value="selectedFoodPet"
            :options="getAvailableFoodPets(selectedPet)"
            placeholder="选择升星材料"
            style="width: 200px"
          />
          <n-button size="small" type="warning" @click="evolvePet(selectedPet)" :disabled="!selectedFoodPet">
            升星
          </n-button>
        </n-space>
        <n-space justify="space-between">
          <span>放生焰兽（不会返还已消耗的道具）</span>
          <n-button size="small" type="error" @click="confirmReleasePet(selectedPet)">放生焰兽</n-button>
          <n-modal v-model:show="showReleaseConfirm" preset="dialog" title="焰兽放生" style="width: 600px">
            <template v-if="petToRelease">
              <p>确定要放生 {{ petToRelease.name }} 吗？此操作不可撤销，且不会返还已消耗的道具。</p>
              <n-space justify="end" style="margin-top: 16px">
                <n-button size="small" @click="cancelReleasePet">取消</n-button>
                <n-button size="small" type="error" @click="releasePet">确认放生</n-button>
              </n-space>
            </template>
          </n-modal>
        </n-space>
      </n-space>
    </template>
  </n-modal>
  <!-- 装备列表弹窗 -->
  <n-modal
    v-model:show="showEquipmentModal"
    preset="dialog"
    :title="`${equipmentTypes[selectedEquipmentType]}列表`"
    style="width: 800px"
  >
    <n-space vertical>
      <n-space justify="space-between">
        <n-select v-model:value="selectedQuality" :options="qualityOptions" style="width: 150px" />
        <n-button type="warning" :disabled="equipmentList.length === 0" @click="batchSellEquipments">一键卖出</n-button>
      </n-space>
      <n-pagination
        v-model:page="currentEquipmentPage"
        :page-size="equipmentPageSize"
        :item-count="filteredEquipmentList.length"
        v-if="equipmentList.length > 8"
        @update:page-size="onEquipmentPageSizeChange"
        :page-slot="7"
      />
      <div class="equip-list-grid" v-if="equipmentList.length">
        <div v-for="equipment in equipmentList" :key="equipment.id" @click="showEquipmentDetails(equipment)"
          class="equip-list-item" :class="'quality-' + equipment.quality"
        >
          <div class="equip-list-header">
            <span class="equip-type-icon">{{ equipTypeIcons[equipment.type] || '📦' }}</span>
            <span class="equip-list-name">{{ equipment.name }}</span>
            <span v-if="equipment.enhanceLevel" class="enhance-level">+{{ equipment.enhanceLevel }}</span>
          </div>
          <div class="equip-list-meta">
            <span class="equip-quality-label" :style="{ color: equipment.qualityInfo.color }">{{ equipment.qualityInfo.name }}</span>
            <span class="equip-realm-req">{{ getRealmName(equipment.requiredRealm).name }}</span>
          </div>
          <n-button size="tiny" type="warning" class="equip-sell-btn" @click.stop="sellEquipment(equipment)">卖出</n-button>
        </div>
      </div>
      <n-empty description="没有任何装备" v-else></n-empty>
    </n-space>
  </n-modal>
  <!-- 装备详情弹窗 -->
  <n-modal v-model:show="showEquipmentDetailModal" preset="dialog" :title="selectedEquipment?.name || '装备详情'">
    <n-descriptions bordered>
      <n-descriptions-item label="品质">
        <span class="detail-quality-text" :style="{ color: selectedEquipment?.qualityInfo.color, textShadow: '0 0 8px ' + selectedEquipment?.qualityInfo.color + '66' }">
          {{ selectedEquipment?.qualityInfo.name }}
        </span>
      </n-descriptions-item>
      <n-descriptions-item label="类型">
        <span>{{ equipTypeIcons[selectedEquipment?.type] || '📦' }} {{ equipmentTypes[selectedEquipment?.type] }}</span>
      </n-descriptions-item>
      <n-descriptions-item label="强化等级"><span class="enhance-level-detail">+{{ selectedEquipment?.enhanceLevel || 0 }}</span></n-descriptions-item>
      <template v-if="selectedEquipment?.stats">
        <n-descriptions-item v-for="(value, stat) in selectedEquipment.stats" :key="stat" :label="getStatName(stat)">
          {{ formatStatValue(stat, value) }}
        </n-descriptions-item>
      </template>
    </n-descriptions>
    <div
      class="stats-comparison"
      v-if="equipmentComparison && selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.slot]?.id"
    >
      <n-divider>属性对比</n-divider>
      <n-table :bordered="false" :single-line="false">
        <thead>
          <tr>
            <th>属性</th>
            <th>当前装备</th>
            <th>选中装备</th>
            <th>属性变化</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(comparison, stat) in equipmentComparison" :key="stat">
            <td>{{ getStatName(stat) }}</td>
            <td>{{ formatStatValue(stat, comparison.current) }}</td>
            <td>{{ formatStatValue(stat, comparison.selected) }}</td>
            <td>
              <n-gradient-text :type="comparison.isPositive ? 'success' : 'error'">
                {{ comparison.isPositive ? '+' : '' }}{{ formatStatValue(stat, comparison.diff) }}
              </n-gradient-text>
            </td>
          </tr>
        </tbody>
      </n-table>
    </div>
    <template #action>
      <n-space justify="space-between">
        <n-space>
          <n-button
            type="primary"
            @click="showEnhanceConfirm = true"
            :disabled="(selectedEquipment?.enhanceLevel || 0) >= 100"
          >
            淬火
          </n-button>
          <n-button type="info" :disabled="playerStore.refinementStones === 0" @click="handleReforgeEquipment">
            铭符
          </n-button>
        </n-space>
        <n-space>
          <n-button
            @click="equipItem(selectedEquipment)"
            :disabled="playerStore.level < selectedEquipment?.requiredRealm"
            v-if="selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.slot]?.id"
          >
            装备
          </n-button>
          <n-button
            @click="unequipItem(selectedEquipment?.slot)"
            :disabled="playerStore.level < selectedEquipment?.requiredRealm"
            v-else
          >
            卸下
          </n-button>
          <n-button
            type="error"
            @click="sellEquipment(selectedEquipment)"
            v-if="selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.slot]?.id"
          >
            出售
          </n-button>
        </n-space>
      </n-space>
    </template>
  </n-modal>
  <!-- 强化确认弹窗 -->
  <n-modal v-model:show="showEnhanceConfirm" preset="dialog" title="装备淬火">
    <n-space vertical>
      <p>是否消耗 {{ ((selectedEquipment?.enhanceLevel || 0) + 1) * 10 }} 淬火石淬火装备？</p>
      <p>当前淬火石数量：{{ playerStore.reinforceStones }}</p>
    </n-space>
    <template #action>
      <n-space justify="end">
        <n-button @click="showEnhanceConfirm = false">取消</n-button>
        <n-button
          type="primary"
          @click="handleEnhanceEquipment"
          :disabled="playerStore.reinforceStones < ((selectedEquipment?.enhanceLevel || 0) + 1) * 10"
        >
          确认淬火
        </n-button>
      </n-space>
    </template>
  </n-modal>
  <!-- 铭符确认弹窗 -->
  <n-modal v-model:show="showReforgeConfirm" preset="dialog" title="铭符结果确认">
    <template v-if="reforgeResult">
      <div class="reforge-compare">
        <div class="old-stats">
          <h3>原始属性</h3>
          <div v-for="(value, key) in reforgeResult.oldStats" :key="key">
            {{ getStatName(key) }}: {{ formatStatValue(key, value) }}
          </div>
        </div>
        <div class="new-stats">
          <h3>新属性</h3>
          <div v-for="(value, key) in reforgeResult.newStats" :key="key">
            {{ getStatName(key) }}: {{ formatStatValue(key, value) }}
          </div>
        </div>
      </div>
    </template>
    <template #action>
      <n-button type="primary" @click="confirmReforgeResult(true)">确认新属性</n-button>
      <n-button @click="confirmReforgeResult(false)">保留原属性</n-button>
    </template>
  </n-modal>
</template>

<script setup>
  import { usePlayerStore } from '../stores/player'
  import { ref, computed } from 'vue'
  import { useMessage } from 'naive-ui'
  import { getStatName, formatStatValue } from '../plugins/stats'
  import { getRealmName } from '../plugins/realm'
  import { pillRecipes, pillGrades, pillTypes, calculatePillEffect } from '../plugins/pills'
  import { enhanceEquipment, reforgeEquipment } from '../plugins/equipment'

  // 分页相关
  const currentPage = ref(1)
  const pageSize = ref(12)

  // 过滤后的焰兽列表
  const filteredPets = computed(() => {
    const pets = playerStore.items.filter(item => item.type === 'pet')
    if (selectedRarityToRelease.value === 'all') {
      return pets
    }
    return pets.filter(pet => pet.rarity === selectedRarityToRelease.value)
  })

  // 当前页显示的焰兽
  const displayPets = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    const end = start + pageSize.value
    return filteredPets.value.slice(start, end)
  })

  // 页大小改变处理
  const onPageSizeChange = size => {
    pageSize.value = size
    currentPage.value = 1
  }

  const playerStore = usePlayerStore()
  const message = useMessage()

  // 使用焰丹
  const usePill = pill => {
    const result = playerStore.usePill(pill)
    if (result.success) {
      message.success(result.message)
    } else {
      message.error(result.message)
    }
  }

  // 焰兽品质配置
  const petRarities = {
    divine: {
      name: '神品',
      color: '#FF0000',
      probability: 0.02,
      essenceBonus: 50
    },
    celestial: {
      name: '仙品',
      color: '#FFD700',
      probability: 0.08,
      essenceBonus: 30
    },
    mystic: {
      name: '玄品',
      color: '#9932CC',
      probability: 0.15,
      essenceBonus: 20
    },
    spiritual: {
      name: '灵品',
      color: '#1E90FF',
      probability: 0.25,
      essenceBonus: 10
    },
    mortal: {
      name: '凡品',
      color: '#32CD32',
      probability: 0.5,
      essenceBonus: 5
    }
  }

  // 焰兽详情相关
  const showPetModal = ref(false)
  const selectedPet = ref(null)
  const selectedFoodPet = ref(null)

  // 放生确认弹窗
  const showReleaseConfirm = ref(false)
  const showBatchReleaseConfirm = ref(false)
  const petToRelease = ref(null)

  // 显示放生确认弹窗
  const confirmReleasePet = pet => {
    petToRelease.value = pet
    showReleaseConfirm.value = true
  }

  // 取消放生
  const cancelReleasePet = () => {
    petToRelease.value = null
    showReleaseConfirm.value = false
  }

  // 执行放生
  const releasePet = () => {
    if (petToRelease.value) {
      // 如果焰兽正在出战，先取消出战
      if (playerStore.activePet?.id === petToRelease.value.id) {
        playerStore.activePet = null
      }
      // 从背包中移除焰兽
      const index = playerStore.items.findIndex(item => item.id === petToRelease.value.id)
      if (index > -1) {
        playerStore.items.splice(index, 1)
        playerStore.saveData()
        message.success('已放生焰兽')
      }
      // 关闭所有相关弹窗
      showReleaseConfirm.value = false
      showPetModal.value = false
      petToRelease.value = null
    }
  }

  // 选中的放生品阶
  const selectedRarityToRelease = ref('all')

  // 批量放生函数
  const batchReleasePets = () => {
    playerStore.items = playerStore.items.filter(
      item =>
        item.type !== 'pet' ||
        item.id === playerStore.activePet?.id ||
        (selectedRarityToRelease.value !== 'all' && item.rarity !== selectedRarityToRelease.value)
    )
    showBatchReleaseConfirm.value = false
    message.success(
      `已放生${
        selectedRarityToRelease.value === 'all' ? '所有' : petRarities[selectedRarityToRelease.value].name
      }品阶的未出战焰兽`
    )
  }

  // 显示焰兽详情
  const showPetDetails = pet => {
    selectedPet.value = pet
    selectedFoodPet.value = null
    showPetModal.value = true
  }

  // 计算焰兽属性加成
  const getPetBonus = pet => {
    if (!pet) return { attack: 0, defense: 0, health: 0 }
    const qualityBonusMap = {
      divine: 0.5,
      celestial: 0.3,
      mystic: 0.2,
      spiritual: 0.1,
      mortal: 0.05
    }
    const starBonusPerQuality = {
      divine: 0.1,
      celestial: 0.08,
      mystic: 0.06,
      spiritual: 0.04,
      mortal: 0.02
    }
    const baseBonus = qualityBonusMap[pet.rarity] || 0.05
    const starBonus = (pet.star || 0) * (starBonusPerQuality[pet.rarity] || 0.02)
    const totalBonus = baseBonus + starBonus
    const phase = Math.floor((pet.star || 0) / 5)
    const phaseBonus = phase * (baseBonus * 0.5)
    const finalBonus = totalBonus + phaseBonus
    return {
      attack: finalBonus,
      defense: finalBonus,
      health: finalBonus
    }
  }

  // 获取升级所需精华数量
  const getUpgradeCost = pet => {
    return (pet.level || 1) * 10
  }

  // 检查是否可以升级
  const canUpgrade = pet => {
    const cost = getUpgradeCost(pet)
    return playerStore.petEssence >= cost
  }

  // 获取可用作升星材料的焰兽列表
  const getAvailableFoodPets = pet => {
    if (!pet) return []
    return playerStore.items
      .filter(
        item =>
          item.type === 'pet' &&
          item.id !== pet.id &&
          item.star === pet.star &&
          item.rarity === pet.rarity &&
          item.name === pet.name
      )
      .map(item => ({
        label: `${item.name} (${item.level || 1}级 ${item.star || 0}星)`,
        value: item.id
      }))
  }

  // 升级焰兽
  const upgradePet = pet => {
    const result = playerStore.upgradePet(pet, getUpgradeCost(pet))
    if (result.success) {
      message.success(result.message)
    } else {
      message.error(result.message)
    }
  }

  // 升星焰兽
  const evolvePet = pet => {
    if (!selectedFoodPet.value) {
      message.error('请选择用于升星的焰兽')
      return
    }
    // 通过id查找对应的焰兽对象
    const foodPet = playerStore.items.find(item => item.id === selectedFoodPet.value)
    if (!foodPet) {
      message.error('升星材料焰兽不存在')
      return
    }
    const result = playerStore.evolvePet(pet, foodPet)
    if (result.success) {
      message.success(result.message)
      selectedFoodPet.value = null
      showPetModal.value = false
    } else {
      message.error(result.message)
    }
  }

  // 装备类型图标
  const equipTypeIcons = {
    weapon: '⚔️',
    head: '⛑️',
    body: '🛡️',
    legs: '👖',
    feet: '👢',
    shoulder: '🦺',
    hands: '🧤',
    wrist: '⌚',
    necklace: '📿',
    ring1: '💍',
    ring2: '💍',
    belt: '🎗️',
    artifact: '🔮'
  }

  // 装备类型配置
  const equipmentTypes = {
    weapon: '焰杖',
    head: '头部',
    body: '衣服',
    legs: '裤子',
    feet: '鞋子',
    shoulder: '肩甲',
    hands: '手套',
    wrist: '护腕',
    necklace: '焰心链',
    ring1: '符文戒1',
    ring2: '符文戒2',
    belt: '腰带',
    artifact: '焰器'
  }

  // 当前选中的装备类型
  const selectedType = ref('')

  // 显示装备类型弹窗
  const showEquipmentList = type => {
    selectedType.value = type
    selectedEquipmentType.value = type
    showEquipmentModal.value = true
  }

  // 卸下装备
  const unequipItem = slot => {
    const result = playerStore.unequipArtifact(slot)
    if (result) {
      showEquipmentDetailModal.value = false
      message.success('当前装备已卸下')
    } else {
      message.error('卸下装备失败')
    }
  }

  // 装备列表相关
  const showEquipmentModal = ref(false)
  const selectedEquipmentType = ref('')
  const selectedQuality = ref('all')
  const currentEquipmentPage = ref(1)
  const equipmentPageSize = ref(8)

  // 装备品质选项
  const qualityOptions = computed(() => {
    const equipmentsByQuality = {}
    playerStore.items
      .filter(item => !selectedEquipmentType.value || item.type === selectedEquipmentType.value)
      .forEach(item => {
        equipmentsByQuality[item.quality] = (equipmentsByQuality[item.quality] || 0) + 1
      })
    return [
      { label: '全部品质', value: 'all' },
      { label: '仙品', value: 'mythic', disabled: !equipmentsByQuality['mythic'] },
      { label: '极品', value: 'legendary', disabled: !equipmentsByQuality['legendary'] },
      { label: '上品', value: 'epic', disabled: !equipmentsByQuality['epic'] },
      { label: '中品', value: 'rare', disabled: !equipmentsByQuality['rare'] },
      { label: '下品', value: 'uncommon', disabled: !equipmentsByQuality['uncommon'] },
      { label: '凡品', value: 'common', disabled: !equipmentsByQuality['common'] }
    ]
  })

  // 过滤后的装备列表
  const filteredEquipmentList = computed(() => {
    let list = playerStore.items.filter(item => {
      if (!selectedEquipmentType.value) return false
      if (item.type !== selectedEquipmentType.value) return false
      if (selectedQuality.value !== 'all' && item.quality !== selectedQuality.value) return false
      return true
    })
    return list
  })

  // 当前页显示的装备
  const equipmentList = computed(() => {
    const start = (currentEquipmentPage.value - 1) * equipmentPageSize.value
    const end = start + equipmentPageSize.value
    return filteredEquipmentList.value.slice(start, end)
  })

  // 装备页大小改变处理
  const onEquipmentPageSizeChange = size => {
    equipmentPageSize.value = size
    currentEquipmentPage.value = 1
  }

  // 批量卖出装备
  const batchSellEquipments = async () => {
    const result = await playerStore.batchSellEquipments(
      selectedQuality.value === 'all' ? null : selectedQuality.value,
      selectedEquipmentType.value
    )
    if (result.success) {
      message.success(result.message)
    } else {
      message.error(result.message || '批量卖出失败')
    }
  }

  // 卖出单件装备
  const sellEquipment = async equipment => {
    const result = await playerStore.sellEquipment(equipment)
    if (result.success) {
      message.success(result.message)
      showEquipmentDetailModal.value = false
    } else {
      message.error(result.message || '卖出失败')
    }
  }

  // 显示装备详情
  const showEquipmentDetails = equipment => {
    selectedEquipment.value = equipment
    showEquipmentDetailModal.value = true
  }

  // 装备详情相关
  const showEquipmentDetailModal = ref(false)
  const selectedEquipment = ref(null)

  // 强化确认弹窗
  const showEnhanceConfirm = ref(false)

  // 强化装备
  const handleEnhanceEquipment = () => {
    if (!selectedEquipment.value) return
    const result = enhanceEquipment(selectedEquipment.value, playerStore.reinforceStones)
    if (result.success) {
      playerStore.reinforceStones -= result.cost
      selectedEquipment.value.stats = { ...result.newStats }
      selectedEquipment.value.enhanceLevel = result.newLevel
      message.success('淬火成功')
      playerStore.saveData()
    } else {
      message.error(result.message || '淬火失败')
    }
  }

  // 洗练确认弹窗
  const showReforgeConfirm = ref(false)
  const reforgeResult = ref(null)

  // 洗练装备
  const handleReforgeEquipment = () => {
    if (!selectedEquipment.value) return
    const result = reforgeEquipment(selectedEquipment.value, playerStore.refinementStones, false)
    if (result.success) {
      playerStore.refinementStones -= result.cost
      reforgeResult.value = result
      showReforgeConfirm.value = true
    } else {
      message.error(result.message || '铭符失败')
    }
  }

  // 确认洗练结果
  const confirmReforgeResult = confirm => {
    if (!reforgeResult.value) return
    if (confirm) {
      // 用户确认后，应用新属性
      selectedEquipment.value.stats = reforgeResult.value.newStats
      message.success('已确认新属性')
    } else {
      // 用户取消，保留原属性
      message.info('已保留原有属性')
    }
    showReforgeConfirm.value = false
    reforgeResult.value = null
    playerStore.saveData()
  }

  // 使用装备
  const equipItem = equipment => {
    const result = playerStore.equipArtifact(equipment, equipment.type)
    if (result.success) {
      message.success(result.message)
      showEquipmentModal.value = false
      showEquipmentDetailModal.value = false
    } else {
      message.error(result.message || '装备失败')
    }
  }

  // 计算装备总属性值（用于比较强弱）
  const getEquipPower = (equip) => {
    if (!equip || !equip.stats) return 0
    return Object.values(equip.stats).reduce((sum, v) => sum + (typeof v === 'number' ? v : 0), 0)
  }

  // 一键穿戴最强装备
  const oneKeyEquip = () => {
    let count = 0
    Object.keys(equipmentTypes).forEach(slot => {
      // 找背包里该槽位可穿的装备
      const candidates = playerStore.items.filter(item =>
        item.type === slot && (!item.requiredRealm || playerStore.level >= item.requiredRealm)
      )
      if (candidates.length === 0) return

      // 找最强的
      const best = candidates.reduce((a, b) => getEquipPower(a) > getEquipPower(b) ? a : b)

      // 比当前装备强才换
      const current = playerStore.equippedArtifacts[slot]
      if (!current || getEquipPower(best) > getEquipPower(current)) {
        const result = playerStore.equipArtifact(best, slot)
        if (result.success) count++
      }
    })
    if (count > 0) {
      message.success(`一键穿戴完成，更换了 ${count} 件装备`)
    } else {
      message.info('没有更强的装备可以替换')
    }
  }

  // 一键卸下所有装备
  const oneKeyUnequip = () => {
    let count = 0
    Object.keys(equipmentTypes).forEach(slot => {
      if (playerStore.equippedArtifacts[slot]) {
        playerStore.unequipArtifact(slot)
        count++
      }
    })
    if (count > 0) {
      message.success(`已卸下 ${count} 件装备`)
    } else {
      message.info('没有装备需要卸下')
    }
  }

  // 计算焰草分组
  const groupedHerbs = computed(() => {
    const groups = {}
    playerStore.herbs.forEach(herb => {
      if (!groups[herb.name]) {
        groups[herb.name] = {
          ...herb,
          count: 1
        }
      } else {
        groups[herb.name].count++
      }
    })
    return Object.values(groups)
  })

  // 计算焰方分组
  const groupedFormulas = computed(() => {
    // 从pillRecipes中获取完整焰方
    const complete = playerStore.pillRecipes
      .map(recipeId => {
        const recipe = pillRecipes.find(r => r.id === recipeId)
        return recipe
          ? {
              id: recipe.id,
              name: recipe.name,
              description: recipe.description,
              grade: recipe.grade,
              type: recipe.type,
              isComplete: true
            }
          : null
      })
      .filter(Boolean)

    // 从pillFragments中获取残缺焰方
    const incomplete = Object.entries(playerStore.pillFragments)
      .map(([recipeId, fragments]) => {
        const recipe = pillRecipes.find(r => r.id === recipeId)
        return recipe
          ? {
              id: recipe.id,
              name: recipe.name,
              description: recipe.description,
              grade: recipe.grade,
              type: recipe.type,
              isComplete: false,
              fragments,
              fragmentsNeeded: recipe.fragmentsNeeded
            }
          : null
      })
      .filter(Boolean)

    return { complete, incomplete }
  })

  // 计算焰丹分组
  const groupedPills = computed(() => {
    const groups = {}
    playerStore.items
      .filter(item => item.type === 'pill')
      .forEach(pill => {
        if (!groups[pill.name]) {
          groups[pill.name] = {
            ...pill,
            count: 1
          }
        } else {
          groups[pill.name].count++
        }
      })
    return Object.values(groups)
  })
  // 使用物品
  const useItem = item => {
    if (item.type === 'pet') {
      const result = playerStore.usePet(item)
      if (result.success) {
        message.success(result.message)
      } else {
        message.error(result.message || '操作失败')
      }
    }
  }

  // 装备属性对比计算
  const equipmentComparison = computed(() => {
    if (!selectedEquipment.value || !selectedEquipmentType.value) return null
    const currentEquipment = playerStore.equippedArtifacts[selectedEquipmentType.value]
    if (!currentEquipment) return null
    const comparison = {}
    const allStats = new Set([...Object.keys(selectedEquipment.value.stats), ...Object.keys(currentEquipment.stats)])
    allStats.forEach(stat => {
      const selectedValue = selectedEquipment.value.stats[stat] || 0
      const currentValue = currentEquipment.stats[stat] || 0
      const diff = selectedValue - currentValue
      comparison[stat] = {
        current: currentValue,
        selected: selectedValue,
        diff: diff,
        isPositive: diff > 0
      }
    })
    return comparison
  })

  const options = [
    { label: '全部品阶', value: 'all' },
    { label: '神品', value: 'divine' },
    { label: '仙品', value: 'celestial' },
    { label: '玄品', value: 'mystic' },
    { label: '灵品', value: 'spiritual' },
    { label: '凡品', value: 'mortal' }
  ]
</script>

<style scoped>
  .n-card { cursor: pointer; }

  /* === 品质发光边框 === */
  .quality-common { border: 1.5px solid #888 !important; box-shadow: 0 0 5px rgba(136,136,136,0.3); background: linear-gradient(135deg, rgba(136,136,136,0.08), transparent) !important; }
  .quality-uncommon { border: 1.5px solid #4caf50 !important; box-shadow: 0 0 8px rgba(76,175,80,0.4); background: linear-gradient(135deg, rgba(76,175,80,0.1), transparent) !important; }
  .quality-rare { border: 1.5px solid #2196f3 !important; box-shadow: 0 0 10px rgba(33,150,243,0.4); background: linear-gradient(135deg, rgba(33,150,243,0.1), transparent) !important; }
  .quality-epic { border: 1.5px solid #9c27b0 !important; box-shadow: 0 0 12px rgba(156,39,176,0.5); background: linear-gradient(135deg, rgba(156,39,176,0.1), transparent) !important; }
  .quality-legendary { border: 1.5px solid #ff9800 !important; box-shadow: 0 0 15px rgba(255,152,0,0.5); background: linear-gradient(135deg, rgba(255,152,0,0.12), transparent) !important; }
  .quality-mythic { border: 1.5px solid #f44336 !important; box-shadow: 0 0 18px rgba(244,67,54,0.6); background: linear-gradient(135deg, rgba(244,67,54,0.12), transparent) !important; animation: mythic-glow 2s ease-in-out infinite; }

  @keyframes mythic-glow {
    0%, 100% { box-shadow: 0 0 15px rgba(244,67,54,0.5); }
    50% { box-shadow: 0 0 25px rgba(244,67,54,0.8), 0 0 40px rgba(244,67,54,0.3); }
  }

  /* === 焰兽品质 === */
  .pet-quality-mortal { border: 1.5px solid #32CD32 !important; box-shadow: 0 0 6px rgba(50,205,50,0.3); background: linear-gradient(135deg, rgba(50,205,50,0.08), transparent) !important; }
  .pet-quality-spiritual { border: 1.5px solid #1E90FF !important; box-shadow: 0 0 8px rgba(30,144,255,0.4); background: linear-gradient(135deg, rgba(30,144,255,0.1), transparent) !important; }
  .pet-quality-mystic { border: 1.5px solid #9932CC !important; box-shadow: 0 0 10px rgba(153,50,204,0.4); background: linear-gradient(135deg, rgba(153,50,204,0.1), transparent) !important; }
  .pet-quality-celestial { border: 1.5px solid #FFD700 !important; box-shadow: 0 0 12px rgba(255,215,0,0.5); background: linear-gradient(135deg, rgba(255,215,0,0.12), transparent) !important; }
  .pet-quality-divine { border: 1.5px solid #FF0000 !important; box-shadow: 0 0 15px rgba(255,0,0,0.5); background: linear-gradient(135deg, rgba(255,0,0,0.12), transparent) !important; animation: divine-glow 2s ease-in-out infinite; }

  @keyframes divine-glow {
    0%, 100% { box-shadow: 0 0 12px rgba(255,0,0,0.5); }
    50% { box-shadow: 0 0 22px rgba(255,0,0,0.8), 0 0 35px rgba(255,0,0,0.3); }
  }

  /* === 出战焰兽脉动边框 === */
  .pet-active { animation: active-pulse 1.5s ease-in-out infinite !important; position: relative; }
  @keyframes active-pulse {
    0%, 100% { box-shadow: 0 0 8px rgba(255,215,0,0.5), inset 0 0 4px rgba(255,215,0,0.1); }
    50% { box-shadow: 0 0 18px rgba(255,215,0,0.9), 0 0 30px rgba(255,215,0,0.3), inset 0 0 8px rgba(255,215,0,0.15); }
  }
  .pet-active-badge { position: absolute; top: 6px; right: 6px; background: linear-gradient(135deg, #FFD700, #FFA500); color: #000; padding: 2px 8px; border-radius: 10px; font-size: 10px; font-weight: bold; z-index: 1; }
  .pet-card { position: relative; transition: transform 0.2s, box-shadow 0.2s; border-radius: 8px; overflow: visible; }
  .pet-card:hover { transform: translateY(-2px); }
  .pet-name-row { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
  .pet-stars { font-size: 12px; line-height: 1; }
  .pet-quality-tag { display: inline-block; padding: 2px 10px; border-radius: 10px; font-size: 12px; font-weight: 600; }

  /* === 装备槽位卡片 === */
  .equip-slot-card { position: relative; border-radius: 8px; transition: transform 0.2s, box-shadow 0.2s; }
  .equip-slot-card:hover { transform: translateY(-2px); }
  .slot-empty { border: 1.5px dashed #555 !important; opacity: 0.7; }
  .slot-header { display: flex; align-items: center; gap: 4px; }
  .equip-type-icon { font-size: 16px; }
  .equipped-item-info { position: relative; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
  .equip-name { font-weight: 600; }
  .empty-slot-text { color: #666; font-style: italic; }

  /* === 强化等级 === */
  .enhance-level { color: #FFD700; font-weight: bold; text-shadow: 0 0 6px rgba(255,215,0,0.5); font-size: 14px; }
  .enhance-level-detail { color: #FFD700; font-weight: bold; font-size: 16px; text-shadow: 0 0 8px rgba(255,215,0,0.6); }

  /* === 已装备角标 === */
  .equipped-badge { position: absolute; top: -22px; right: -8px; background: linear-gradient(135deg, #4caf50, #2e7d32); color: #fff; padding: 1px 8px; border-radius: 8px; font-size: 10px; font-weight: bold; z-index: 1; }

  /* === 物品网格（焰草/焰丹） === */
  .item-grid { display: grid; gap: 10px; }
  .item-grid-4 { grid-template-columns: repeat(4, 1fr); }
  @media (max-width: 600px) { .item-grid-4 { grid-template-columns: repeat(2, 1fr); } }
  .grid-cell { position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 14px 8px 18px; border-radius: 8px; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s; min-height: 80px; text-align: center; }
  .grid-cell:hover { transform: scale(1.06); z-index: 2; }
  .cell-icon { font-size: 24px; margin-bottom: 4px; }
  .cell-name { font-size: 13px; font-weight: 600; line-height: 1.3; }
  .cell-action { font-size: 10px; color: #1E90FF; margin-top: 2px; opacity: 0; transition: opacity 0.2s; }
  .grid-cell:hover .cell-action { opacity: 1; }

  /* === 数量角标 === */
  .item-count-badge { position: absolute; bottom: 4px; right: 4px; background: rgba(212,168,67,0.9); color: #000; border-radius: 50%; width: 22px; height: 22px; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: bold; box-shadow: 0 1px 3px rgba(0,0,0,0.3); }

  /* === 装备列表弹窗网格 === */
  .equip-list-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
  @media (max-width: 700px) { .equip-list-grid { grid-template-columns: repeat(2, 1fr); } }
  .equip-list-item { position: relative; padding: 10px; border-radius: 8px; cursor: pointer; transition: transform 0.2s, box-shadow 0.2s; display: flex; flex-direction: column; gap: 4px; }
  .equip-list-item:hover { transform: translateY(-2px); z-index: 2; }
  .equip-list-header { display: flex; align-items: center; gap: 4px; flex-wrap: wrap; }
  .equip-list-name { font-weight: 600; font-size: 13px; flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .equip-list-meta { display: flex; justify-content: space-between; font-size: 11px; opacity: 0.8; }
  .equip-quality-label { font-weight: 600; }
  .equip-realm-req { color: #999; }
  .equip-sell-btn { position: absolute; top: 6px; right: 6px; }

  /* === 装备详情品质文字 === */
  .detail-quality-text { font-weight: bold; font-size: 15px; }

  /* === 属性对比更醒目 === */
  .stats-comparison :deep(.n-gradient-text) { font-weight: bold; font-size: 14px; }

  /* === 洗练对比 === */
  .reforge-compare { display: flex; justify-content: space-between; gap: 20px; margin: 16px 0; }
  .old-stats, .new-stats { flex: 1; padding: 16px; border-radius: 8px; background-color: rgba(0,0,0,0.05); }
  .old-stats h3, .new-stats h3 { margin-top: 0; margin-bottom: 12px; font-size: 16px; color: #666; }
</style>
