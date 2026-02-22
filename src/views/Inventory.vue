<template>
  <div class="storage-container">
    <game-guide>
      <p>🎒 共<strong>13个装备栏位</strong>：焰杖、头部、衣服、裤子、鞋子、肩甲、手套、护腕、焰心链、符文戒×2、腰带、焰器</p>
      <p>🎨 6个品质：<strong>凡品→下品→中品→上品→极品→仙品</strong></p>
      <p>🔥 <strong>淬火</strong>：消耗淬火石强化装备，每级+10%属性，最高100级</p>
      <p>✨ <strong>铭符</strong>：消耗符文石重随机属性，±30%浮动，30%概率换属性</p>
      <p>⚡ 一键穿戴/卸下快速管理装备</p>
      <p>🐾 <strong>焰兽</strong>：出战获得全属性加成，消耗精华升级，同名同品质焰兽可升星</p>
      <p>🌿 <strong>焰草</strong>：炼丹材料，5个品质（普通→仙品），品质越高效果倍率越大</p>
      <p>💊 <strong>焰丹</strong>：服用获得临时buff，效果随境界提升</p>
    </game-guide>
    <!-- 顶部操作栏 -->
    <div class="storage-header">
      <span class="storage-title">🏛️ 储藏室</span>
      <div class="storage-actions">
        <n-button type="primary" size="small" @click="oneKeyEquip">⚡ 一键穿戴</n-button>
        <n-button type="warning" size="small" @click="oneKeyUnequip">🔄 一键卸下</n-button>
      </div>
    </div>

    <!-- 装备栏 -->
    <div class="equip-bar">
      <div class="equip-bar-label">已装备</div>
      <div class="equip-bar-grid">
        <div
          v-for="(name, type) in equipmentTypes" :key="type"
          class="equip-bar-slot"
          :class="playerStore.equippedArtifacts[type] ? 'eq-quality-' + playerStore.equippedArtifacts[type].quality : 'eq-empty'"
          @click="onEquipSlotClick(type)"
        >
          <img v-if="equipTypeImages[type] && !imgLoadFailed[type]"
            :src="equipTypeImages[type]"
            class="eq-slot-icon"
            :class="{ 'eq-slot-icon-empty': !playerStore.equippedArtifacts[type] }"
            @error="onEquipImgError(type)"
          />
          <span v-else class="eq-slot-emoji" :class="{ 'eq-slot-emoji-empty': !playerStore.equippedArtifacts[type] }">{{ equipTypeIcons[type] || '📦' }}</span>
          <span class="eq-slot-name">{{ playerStore.equippedArtifacts[type] ? playerStore.equippedArtifacts[type].name : name }}</span>
          <span v-if="playerStore.equippedArtifacts[type]?.enhanceLevel" class="eq-enhance">+{{ playerStore.equippedArtifacts[type].enhanceLevel }}</span>
        </div>
      </div>
    </div>

    <!-- 筛选 tab -->
    <div class="filter-tabs">
      <span
        v-for="tab in filterTabs" :key="tab.value"
        class="filter-tab" :class="{ active: activeFilter === tab.value }"
        @click="activeFilter = tab.value"
      >{{ tab.label }}</span>
    </div>

    <!-- 容量条 -->
    <div class="capacity-bar" v-if="true">
      <span class="capacity-text">{{ currentCategoryLabel }} {{ currentCount }}/{{ currentLimit }}</span>
      <div class="capacity-track">
        <div class="capacity-fill" :style="{ width: capacityPercent + '%' }" :class="{ 'capacity-full': capacityPercent >= 90 }"></div>
      </div>
      <n-button v-if="canExpand(activeFilter)" size="tiny" type="warning" @click="expandStorage(activeFilter)">
        🔓 扩容 ({{ getExpandCost(activeFilter) }}焰晶)
      </n-button>
      <span v-else class="capacity-max">已满级</span>
    </div>

    <!-- 储藏室网格 -->
    <!-- 材料展示 -->
    <div class="material-section" v-if="activeFilter === 'material'">
      <div class="material-grid">
        <div class="material-card">
          <div class="material-icon">🔨</div>
          <div class="material-name">淬火石</div>
          <div class="material-count">{{ playerStore.reinforceStones || 0 }}</div>
          <div class="material-desc">装备淬火必备</div>
        </div>
        <div class="material-card">
          <div class="material-icon">🔮</div>
          <div class="material-name">洗练石</div>
          <div class="material-count">{{ playerStore.refinementStones || 0 }}</div>
          <div class="material-desc">装备铭符用</div>
        </div>
        <div class="material-card">
          <div class="material-icon">🐾</div>
          <div class="material-name">焰兽精华</div>
          <div class="material-count">{{ playerStore.petEssence || 0 }}</div>
          <div class="material-desc">焰兽升星用</div>
        </div>
        <div class="material-card">
          <div class="material-icon">💎</div>
          <div class="material-name">焰晶</div>
          <div class="material-count">{{ playerStore.spiritStones || 0 }}</div>
          <div class="material-desc">通用货币</div>
        </div>
      </div>
    </div>

    <div class="storage-grid" v-if="activeFilter !== 'formula' && activeFilter !== 'pet' && activeFilter !== 'material'">
      <div
        v-for="item in filteredStorageItems" :key="item._key"
        class="storage-cell"
        :class="getCellQualityClass(item)"
        @click="onStorageItemClick(item)"
      >
        <div class="cell-icon-area">
          <img v-if="item._icon && !item._imgFail" :src="item._icon" class="cell-img" @error="item._imgFail = true" />
          <span v-else class="cell-emoji">{{ item._emoji }}</span>
        </div>
        <span class="cell-label">{{ item._displayName || item.name }}</span>
        <span v-if="item._count > 1" class="cell-count">×{{ item._count }}</span>
        <span v-if="item._category === 'pill'" class="cell-use-hint">详情</span>
      </div>
      <!-- 空格子填充 -->
      <div v-for="n in emptySlots" :key="'empty-' + n" class="storage-cell storage-cell-empty">
        <span class="empty-dot">·</span>
      </div>
    </div>

    <!-- 焰方区域（保留原有） -->
    <div class="formula-section" v-if="activeFilter === 'formula'">
      <div class="equip-bar-label" style="margin-top:16px">📜 焰方</div>
      <n-tabs type="segment" size="small">
        <n-tab-pane name="complete" tab="完整焰方">
          <div class="storage-grid" v-if="groupedFormulas.complete.length">
            <div v-for="formula in groupedFormulas.complete" :key="formula.id" class="storage-cell formula-cell" @click="() => {}">
              <div class="cell-icon-area">
                <img v-if="getFormulaImage(formula.name)" :src="getFormulaImage(formula.name)" class="cell-img" />
                <span v-else class="cell-emoji">📜</span>
              </div>
              <span class="cell-label">{{ formula.name }}</span>
              <n-tag type="success" size="tiny" style="margin-top:2px">完整</n-tag>
            </div>
          </div>
          <n-empty v-else description="暂无完整焰方" size="small" />
        </n-tab-pane>
        <n-tab-pane name="incomplete" tab="残缺焰方">
          <div class="storage-grid" v-if="groupedFormulas.incomplete.length">
            <div v-for="formula in groupedFormulas.incomplete" :key="formula.id" class="storage-cell formula-cell" @click="() => {}">
              <div class="cell-icon-area">
                <img v-if="getFormulaImage(formula.name)" :src="getFormulaImage(formula.name)" class="cell-img" />
                <span v-else class="cell-emoji">📜</span>
              </div>
              <span class="cell-label">{{ formula.name }}</span>
              <n-tag type="warning" size="tiny" style="margin-top:2px">{{ formula.fragments }}/{{ formula.fragmentsNeeded }}</n-tag>
            </div>
          </div>
          <n-empty v-else description="暂无残缺焰方" size="small" />
        </n-tab-pane>
      </n-tabs>
    </div>

    <!-- 焰兽区域 -->
    <div class="pet-section" v-if="activeFilter === 'pet'">
      <div class="equip-bar-label" style="margin-top:16px">
        🐾 焰兽
        <n-space style="display:inline-flex;margin-left:12px" size="small">
          <n-select v-model:value="selectedRarityToRelease" :options="options" placeholder="品阶" style="width:120px" size="small" />
          <n-button size="small" @click="showBatchReleaseConfirm = true" :disabled="!playerStore.items.filter(item => item.type === 'pet').length">一键放生</n-button>
        </n-space>
      </div>
      <n-modal v-model:show="showBatchReleaseConfirm" preset="dialog" title="批量放生确认" style="max-width:600px;width:90vw">
        <p>确定要放生{{ selectedRarityToRelease === 'all' ? '所有' : petRarities[selectedRarityToRelease].name }}品阶的未出战焰兽吗？此操作不可撤销。</p>
        <n-space justify="end" style="margin-top:16px">
          <n-button size="small" @click="showBatchReleaseConfirm = false">取消</n-button>
          <n-button size="small" type="error" @click="batchReleasePets">确认放生</n-button>
        </n-space>
      </n-modal>
      <n-pagination v-if="filteredPets.length > 12" v-model:page="currentPage" :page-size="pageSize" :item-count="filteredPets.length" @update:page-size="onPageSizeChange" :page-slot="7" style="margin:8px 0" />
      <div class="storage-grid" v-if="displayPets.length">
        <div v-for="pet in displayPets" :key="pet.id"
          class="storage-cell pet-cell"
          :class="['pet-q-' + pet.rarity, playerStore.activePet?.id === pet.id ? 'pet-active-cell' : '']"
          @click="showPetDetails(pet)"
        >
          <img v-if="getPetImage(pet.name)" :src="getPetImage(pet.name)" class="cell-img pet-img" loading="lazy" />
          <span v-else class="cell-emoji">🐾</span>
          <span class="cell-label">{{ pet.name }}</span>
          <span class="pet-stars-mini">{{ '★'.repeat(Math.min(pet.star || 0, 5)) }}</span>
          <span v-if="playerStore.activePet?.id === pet.id" class="cell-count" style="background:#FFD700;color:#000">战</span>
        </div>
      </div>
      <n-empty v-else description="暂无焰兽" size="small" />
    </div>
  </div>

  <!-- 焰兽详情弹窗 -->
  <n-modal v-model:show="showPetModal" preset="dialog" title="焰兽详情" style="max-width:600px;width:90vw">
    <template v-if="selectedPet">
      <div class="pet-detail-header" v-if="getPetImage(selectedPet.name)">
        <img :src="getPetImage(selectedPet.name)" class="pet-detail-avatar" loading="lazy" />
      </div>
      <n-descriptions bordered>
        <n-descriptions-item label="名称">{{ selectedPet.name }}</n-descriptions-item>
        <n-descriptions-item label="品质"><n-tag :style="{ color: petRarities[selectedPet.rarity].color }">{{ petRarities[selectedPet.rarity].name }}</n-tag></n-descriptions-item>
        <n-descriptions-item label="等级">{{ selectedPet.level || 1 }}</n-descriptions-item>
        <n-descriptions-item label="星级">{{ selectedPet.star || 0 }}</n-descriptions-item>
        <n-descriptions-item label="焰阶">{{ Math.floor((selectedPet.star || 0) / 5) }}阶</n-descriptions-item>
      </n-descriptions>
      <n-divider>属性加成</n-divider>
      <n-descriptions bordered>
        <n-descriptions-item label="攻击加成">+{{ (getPetBonus(selectedPet).attack * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="防御加成">+{{ (getPetBonus(selectedPet).defense * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="生命加成">+{{ (getPetBonus(selectedPet).health * 100).toFixed(1) }}%</n-descriptions-item>
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
            <n-descriptions-item label="暴击率">{{ ((selectedPet.combatAttributes?.critRate || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="连击率">{{ ((selectedPet.combatAttributes?.comboRate || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="反击率">{{ ((selectedPet.combatAttributes?.counterRate || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="眩晕率">{{ ((selectedPet.combatAttributes?.stunRate || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="闪避率">{{ ((selectedPet.combatAttributes?.dodgeRate || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="吸血率">{{ ((selectedPet.combatAttributes?.vampireRate || 0) * 100).toFixed(1) }}%</n-descriptions-item>
          </n-descriptions>
          <n-divider>战斗抗性</n-divider>
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="抗暴击">{{ ((selectedPet.combatAttributes?.critResist || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="抗连击">{{ ((selectedPet.combatAttributes?.comboResist || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="抗反击">{{ ((selectedPet.combatAttributes?.counterResist || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="抗眩晕">{{ ((selectedPet.combatAttributes?.stunResist || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="抗闪避">{{ ((selectedPet.combatAttributes?.dodgeResist || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="抗吸血">{{ ((selectedPet.combatAttributes?.vampireResist || 0) * 100).toFixed(1) }}%</n-descriptions-item>
          </n-descriptions>
          <n-divider>特殊属性</n-divider>
          <n-descriptions bordered :column="3">
            <n-descriptions-item label="强化治疗">{{ ((selectedPet.combatAttributes?.healBoost || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="强化爆伤">{{ ((selectedPet.combatAttributes?.critDamageBoost || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="弱化爆伤">{{ ((selectedPet.combatAttributes?.critDamageReduce || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="最终增伤">{{ ((selectedPet.combatAttributes?.finalDamageBoost || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="最终减伤">{{ ((selectedPet.combatAttributes?.finalDamageReduce || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="战斗属性提升">{{ ((selectedPet.combatAttributes?.combatBoost || 0) * 100).toFixed(1) }}%</n-descriptions-item>
            <n-descriptions-item label="战斗抗性提升">{{ ((selectedPet.combatAttributes?.resistanceBoost || 0) * 100).toFixed(1) }}%</n-descriptions-item>
          </n-descriptions>
        </n-collapse-item>
      </n-collapse>
      <n-divider>操作</n-divider>
      <n-space vertical>
        <n-space justify="space-between">
          <span>{{ playerStore.activePet?.id === selectedPet.id ? '召回焰兽' : '出战焰兽' }}</span>
          <n-button size="small" type="primary" @click="useItem(selectedPet)">{{ playerStore.activePet?.id === selectedPet.id ? '召回' : '出战' }}</n-button>
        </n-space>
        <n-space justify="space-between">
          <span>升级（消耗{{ getUpgradeCost(selectedPet) }} / {{ playerStore.petEssence }}焰兽精华）</span>
          <n-button size="small" type="primary" @click="upgradePet(selectedPet)" :disabled="!canUpgrade(selectedPet)">升级</n-button>
        </n-space>
        <n-space justify="space-between">
          <span>升星（需要相同品质和名字的焰兽）</span>
          <n-select v-model:value="selectedFoodPet" :options="getAvailableFoodPets(selectedPet)" placeholder="选择升星材料" style="width:200px" />
          <n-button size="small" type="warning" @click="evolvePet(selectedPet)" :disabled="!selectedFoodPet">升星</n-button>
        </n-space>
        <n-space justify="space-between">
          <span>放生焰兽</span>
          <n-button size="small" type="error" @click="confirmReleasePet(selectedPet)">放生焰兽</n-button>
          <n-modal v-model:show="showReleaseConfirm" preset="dialog" title="焰兽放生" style="max-width:600px;width:90vw">
            <template v-if="petToRelease">
              <p>确定要放生 {{ petToRelease.name }} 吗？此操作不可撤销。</p>
              <n-space justify="end" style="margin-top:16px">
                <n-button size="small" @click="cancelReleasePet">取消</n-button>
                <n-button size="small" type="error" @click="releasePet">确认放生</n-button>
              </n-space>
              <GuideTooltip v-if="showGuide" v-bind="guideTexts.inventory || {}" @dismiss="dismissGuide" />
</template>
          </n-modal>
        </n-space>
      </n-space>
    </template>
  </n-modal>

  <!-- 装备列表弹窗 -->
  <n-modal v-model:show="showEquipmentModal" preset="dialog" :title="`${equipmentTypes[selectedEquipmentType]}列表`" style="max-width:800px;width:90vw">
    <n-space vertical>
      <n-space justify="space-between">
        <n-select v-model:value="selectedQuality" :options="qualityOptions" style="width:150px" />
        <n-button type="warning" :disabled="equipmentList.length === 0" @click="batchSellEquipments">一键卖出</n-button>
      </n-space>
      <n-pagination v-model:page="currentEquipmentPage" :page-size="equipmentPageSize" :item-count="filteredEquipmentList.length" v-if="equipmentList.length > 8" @update:page-size="onEquipmentPageSizeChange" :page-slot="7" />
      <div class="storage-grid" v-if="equipmentList.length">
        <div v-for="equipment in equipmentList" :key="equipment.id" @click="showEquipmentDetails(equipment)"
          class="storage-cell equip-list-cell" :class="'sq-' + equipment.quality"
        >
          <span class="cell-emoji">{{ equipTypeIcons[equipment.type] || '📦' }}</span>
          <span class="cell-label">{{ equipment.name }}</span>
          <span v-if="equipment.enhanceLevel" class="eq-enhance" style="position:static">+{{ equipment.enhanceLevel }}</span>
          <span class="cell-meta">{{ equipment.qualityInfo?.name }}</span>
          <n-button size="tiny" type="warning" class="cell-sell-btn" @click.stop="sellEquipment(equipment)">卖</n-button>
        </div>
      </div>
      <n-empty description="没有任何装备" v-else />
    </n-space>
  </n-modal>

  <!-- 装备详情弹窗 -->
  <n-modal v-model:show="showEquipmentDetailModal" preset="dialog" :title="selectedEquipment?.name || '装备详情'">
    <n-descriptions bordered>
      <n-descriptions-item label="品质">
        <span class="detail-quality-text" :style="{ color: selectedEquipment?.qualityInfo.color, textShadow: '0 0 8px ' + selectedEquipment?.qualityInfo.color + '66' }">{{ selectedEquipment?.qualityInfo.name }}</span>
      </n-descriptions-item>
      <n-descriptions-item label="类型"><span>{{ equipTypeIcons[selectedEquipment?.type] || '📦' }} {{ equipmentTypes[selectedEquipment?.type] }}</span></n-descriptions-item>
      <n-descriptions-item label="强化等级"><span class="eq-enhance" style="position:static">+{{ selectedEquipment?.enhanceLevel || 0 }}</span></n-descriptions-item>
      <template v-if="selectedEquipment?.stats">
        <n-descriptions-item v-for="(value, stat) in selectedEquipment.stats" :key="stat" :label="getStatName(stat)">{{ formatStatValue(stat, value) }}</n-descriptions-item>
      </template>
    </n-descriptions>
    <div class="stats-comparison" v-if="equipmentComparison && selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.type]?.id">
      <n-divider>属性对比</n-divider>
      <n-table :bordered="false" :single-line="false">
        <thead><tr><th>属性</th><th>当前装备</th><th>选中装备</th><th>属性变化</th></tr></thead>
        <tbody>
          <tr v-for="(comparison, stat) in equipmentComparison" :key="stat">
            <td>{{ getStatName(stat) }}</td>
            <td>{{ formatStatValue(stat, comparison.current) }}</td>
            <td>{{ formatStatValue(stat, comparison.selected) }}</td>
            <td><n-gradient-text :type="comparison.isPositive ? 'success' : 'error'">{{ comparison.isPositive ? '+' : '' }}{{ formatStatValue(stat, comparison.diff) }}</n-gradient-text></td>
          </tr>
        </tbody>
      </n-table>
    </div>
    <template #action>
      <n-space justify="space-between">
        <n-space>
          <n-tooltip trigger="hover" :disabled="selectedEquipment?.id === playerStore.equippedArtifacts[selectedEquipment?.type]?.id">
            <template #trigger>
              <n-button type="primary" @click="showEnhanceConfirm = true" :disabled="(selectedEquipment?.enhanceLevel || 0) >= 100 || selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.type]?.id">淬火</n-button>
            </template>
            请先装备后再淬火
          </n-tooltip>
          <n-tooltip trigger="hover" :disabled="selectedEquipment?.id === playerStore.equippedArtifacts[selectedEquipment?.type]?.id">
            <template #trigger>
              <n-button type="info" :disabled="playerStore.refinementStones === 0 || selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.type]?.id" @click="handleReforgeEquipment">铭符</n-button>
            </template>
            请先装备后再铭符
          </n-tooltip>
        </n-space>
        <n-space>
          <n-button @click="equipItem(selectedEquipment)" :disabled="playerStore.level < selectedEquipment?.requiredRealm" v-if="selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.type]?.id">装备</n-button>
          <n-button @click="unequipItem(selectedEquipment)" :disabled="playerStore.level < selectedEquipment?.requiredRealm" v-else>卸下</n-button>
          <n-button type="error" @click="sellEquipment(selectedEquipment)" v-if="selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.type]?.id">出售</n-button>
          <n-popconfirm @positive-click="recycleEquipment(selectedEquipment)" v-if="selectedEquipment?.id != playerStore.equippedArtifacts[selectedEquipment?.type]?.id">
            <template #trigger>
              <n-button type="warning">♻️ 回收</n-button>
            </template>
            <div>确认回收？预计获得：</div>
            <div style="color:#d4a843;font-size:12px">{{ getRecyclePreview(selectedEquipment) }}</div>
          </n-popconfirm>
        </n-space>
      </n-space>
    </template>
  </n-modal>

  <!-- 强化确认弹窗 -->
  <!-- 丹药详情弹窗 -->
  <n-modal v-model:show="showPillDetailModal" preset="card" title="丹药详情" style="width:90%;max-width:400px">
    <n-space vertical v-if="selectedPill">
      <div style="text-align:center;font-size:32px">💊</div>
      <div style="text-align:center;font-size:16px;font-weight:bold;color:#d4a843">{{ selectedPill.name }}</div>
      <div style="font-size:13px;color:#999">{{ selectedPill.description }}</div>
      <n-divider>效果预览</n-divider>
      <div v-if="selectedPill.effect" style="font-size:13px">
        <p>📈 效果：+{{ ((selectedPill.effect.value || 0) * 100).toFixed(0) }}%</p>
        <p>⏱️ 持续：{{ Math.floor((selectedPill.effect.duration || 0) / 60) }}分钟</p>
      </div>
      <n-space justify="end" style="margin-top:12px">
        <n-button @click="showPillDetailModal = false">关闭</n-button>
        <n-button type="success" @click="usePill(selectedPill); showPillDetailModal = false">服用</n-button>
      </n-space>
    </n-space>
  </n-modal>

  <n-modal v-model:show="showEnhanceConfirm" preset="dialog" title="装备淬火">
    <n-space vertical>
      <p>是否消耗 {{ ((selectedEquipment?.enhanceLevel || 0) + 1) * 10 }} 淬火石淬火装备？</p>
      <p>当前淬火石数量：{{ playerStore.reinforceStones }}</p>
    </n-space>
    <template #action>
      <n-space justify="end">
        <n-button @click="showEnhanceConfirm = false">取消</n-button>
        <n-button type="primary" @click="handleEnhanceEquipment" :disabled="playerStore.reinforceStones < ((selectedEquipment?.enhanceLevel || 0) + 1) * 10">确认淬火</n-button>
      </n-space>
    </template>
  </n-modal>

  <!-- 铭符确认弹窗 -->
  <n-modal v-model:show="showReforgeConfirm" preset="dialog" title="铭符结果确认">
    <template v-if="reforgeResult">
      <div class="reforge-compare">
        <div class="old-stats"><h3>原始属性</h3><div v-for="(value, key) in reforgeResult.oldStats" :key="key">{{ getStatName(key) }}: {{ formatStatValue(key, value) }}</div></div>
        <div class="new-stats"><h3>新属性</h3><div v-for="(value, key) in reforgeResult.newStats" :key="key">{{ getStatName(key) }}: {{ formatStatValue(key, value) }}</div></div>
      </div>
    </template>
    <template #action>
      <n-button type="primary" @click="confirmReforgeResult(true)">确认新属性</n-button>
      <n-button @click="confirmReforgeResult(false)">保留原属性</n-button>
    </template>
  </n-modal>
</template>

<script setup>
import img from '../utils/img.js'
import { hasSeenGuide, markGuideSeen, guideTexts } from '../utils/guide.js'
import GuideTooltip from '../components/GuideTooltip.vue'
  import { usePlayerStore } from '../stores/player'
  import { useAuthStore } from '../stores/auth'
  import { ref, computed, onMounted } from 'vue'
  import { useMessage } from 'naive-ui'
  import { getStatName, formatStatValue } from '../plugins/stats'
  import { getRealmName } from '../plugins/realm'
  import { pillRecipes, pillGrades, pillTypes, calculatePillEffect } from '../plugins/pills'
  import { enhanceEquipment, reforgeEquipment } from '../plugins/equipment'
  import GameGuide from '../components/GameGuide.vue'

  // 焰草ID -> 中文名映射（简单对象，像装备一样）
  const herbIdToName = {
    'spirit_grass': '灵精草',
    'cloud_flower': '云雾花',
    'thunder_root': '雷击根',
    'dragon_breath_herb': '龙息草',
    'immortal_jade_grass': '仙玉草',
    'dark_yin_grass': '玄阴草',
    'nine_leaf_lingzhi': '九叶灵芝',
    'purple_ginseng': '紫金参',
    'frost_lotus': '寒霜莲',
    'fire_heart_flower': '火心花',
    'moonlight_orchid': '月华兰',
    'sun_essence_flower': '日精花',
    'five_elements_grass': '五行草',
    'phoenix_feather_herb': '凤羽草',
    'celestial_dew_grass': '天露草'
  }

  // 焰草图片映射（简单对象，像装备一样）
  const herbImageMap = {
    'spirit_grass': img('/assets/images/herbs/herb_spirit_grass.png'),
    'cloud_flower': img('/assets/images/herbs/herb_cloud_flower.png'),
    'thunder_root': img('/assets/images/herbs/herb_thunder_root.png'),
    'dragon_breath_herb': img('/assets/images/herbs/herb_dragon_breath.png'),
    'immortal_jade_grass': img('/assets/images/herbs/herb_immortal_jade.png'),
    'dark_yin_grass': img('/assets/images/herbs/herb_dark_yin.png'),
    'nine_leaf_lingzhi': img('/assets/images/herbs/herb_nine_lingzhi.png'),
    'purple_ginseng': img('/assets/images/herbs/herb_purple_ginseng.png'),
    'frost_lotus': img('/assets/images/herbs/herb_frost_lotus.png'),
    'fire_heart_flower': img('/assets/images/herbs/herb_fire_heart.png'),
    'moonlight_orchid': img('/assets/images/herbs/herb_moonlight_orchid.png'),
    'sun_essence_flower': img('/assets/images/herbs/herb_sun_essence.png'),
    'five_elements_grass': img('/assets/images/herbs/herb_five_elements.png'),
    'phoenix_feather_herb': img('/assets/images/herbs/herb_phoenix_feather.png'),
    'celestial_dew_grass': img('/assets/images/herbs/herb_celestial_dew.png')
  }

  const petImageMap = {
    // 神品 (divine)
    '朱雀': img('/assets/images/pets/pet_firebird.png'),
    '青龙': img('/assets/images/pets/pet_firedragon.png'),
    '麒麟': img('/assets/images/pets/pet_firequilin.png'),
    '白虎': img('/assets/images/pets/pet_firetiger.png'),
    '玄武': img('/assets/images/pets/pet_fireturtle.png'),
    '应龙': img('/assets/images/pets/pet_yinglong.png'),
    '饕餮': img('/assets/images/pets/pet_taotie.png'),
    '穷奇': img('/assets/images/pets/pet_qiongqi.png'),
    '梼杌': img('/assets/images/pets/pet_taowu.png'),
    '混沌': img('/assets/images/pets/pet_hundun.png'),
    // 仙品 (celestial) - 龙生九子
    '囚牛': img('/assets/images/pets/pet_qiuniu.png'),
    '睚眦': img('/assets/images/pets/pet_yazi.png'),
    '嘲风': img('/assets/images/pets/pet_chaofeng.png'),
    '蒲牢': img('/assets/images/pets/pet_pulao.png'),
    '狻犴': img('/assets/images/pets/pet_suanni.png'),
    '霸下': img('/assets/images/pets/pet_baxia.png'),
    '狴犴': img('/assets/images/pets/pet_bian.png'),
    '负屃': img('/assets/images/pets/pet_fuxi.png'),
    '螭吻': img('/assets/images/pets/pet_firelizard.png'),
    // 玄品 (mystic)
    '火凤凰': img('/assets/images/pets/pet_firephoenix.png'),
    '雷鹰': img('/assets/images/pets/pet_thundereagle.png'),
    '冰狼': img('/assets/images/pets/pet_icewolf.png'),
    '岩龟': img('/assets/images/pets/pet_rockturtle.png'),
    // 灵品 (spiritual)
    '玄龟': img('/assets/images/pets/pet_darkturtle.png'),
    '风隼': img('/assets/images/pets/pet_windfalcon.png'),
    '地甲': img('/assets/images/pets/pet_eartharmor.png'),
    '云豹': img('/assets/images/pets/pet_cloudleopard.png'),
    // 凡品 (mortal)
    '灵猫': img('/assets/images/pets/pet_firefox.png'),
    '幻蝶': img('/assets/images/pets/pet_huandie.png'),
    '火鼠': img('/assets/images/pets/pet_huoshu.png'),
    '草兔': img('/assets/images/pets/pet_caotu.png'),
  }
  const getPetImage = (name) => petImageMap[name] || null

  // 焰丹图片映射
  const pillImageMap = {
    '聚灵丹': img('/assets/images/pills/pill_juling.png'),
    '聚气丹': img('/assets/images/pills/pill_juqi.png'),
    '雷灵丹': img('/assets/images/pills/pill_leiling.png'),
    '仙灵丹': img('/assets/images/pills/pill_xianling.png'),
    '五行丹': img('/assets/images/pills/pill_wuxing.png'),
    '天元丹': img('/assets/images/pills/pill_tianyuan.png'),
    '日月丹': img('/assets/images/pills/pill_riyue.png'),
    '涅槃丹': img('/assets/images/pills/pill_niepan.png'),
    '回灵丹': img('/assets/images/pills/pill_huiling.png'),
    '凝元丹': img('/assets/images/pills/pill_ningyuan.png'),
    '清心丹': img('/assets/images/pills/pill_qingxin.png'),
    '火元丹': img('/assets/images/pills/pill_huoyuan.png'),
  }
  const getPillImage = (name) => pillImageMap[name] || null

  // 焰方图片映射
  const formulaImageMap = {
    '聚灵丹方': img('/assets/images/formulas/formula_juling.png'),
    '聚气丹方': img('/assets/images/formulas/formula_juqi.png'),
    '雷灵丹方': img('/assets/images/formulas/formula_leiling.png'),
    '仙灵丹方': img('/assets/images/formulas/formula_xianling.png'),
    '五行丹方': img('/assets/images/formulas/formula_wuxing.png'),
    '天元丹方': img('/assets/images/formulas/formula_tianyuan.png'),
    '日月丹方': img('/assets/images/formulas/formula_riyue.png'),
    '涅槃丹方': img('/assets/images/formulas/formula_niepan.png'),
    '回灵丹方': img('/assets/images/formulas/formula_huiling.png'),
    '凝元丹方': img('/assets/images/formulas/formula_ningyuan.png'),
    '清心丹方': img('/assets/images/formulas/formula_qingxin.png'),
    '火元丹方': img('/assets/images/formulas/formula_huoyuan.png'),
  }
  const getFormulaImage = (name) => formulaImageMap[name] || null

  const showGuide = ref(!hasSeenGuide("inventory"))
const dismissGuide = () => { markGuideSeen("inventory"); showGuide.value = false }
const playerStore = usePlayerStore()
  const authStore = useAuthStore()
  const message = useMessage()

  // 进入储藏室时从服务端加载装备
  onMounted(async () => {
    if (authStore.isLoggedIn) {
      await playerStore.loadEquipmentFromServer()
      await playerStore.loadPetsFromServer()
      await playerStore.loadHerbsFromServer()
      await playerStore.loadPillsFromServer()
    }
  })

  // === 储存量上限（动态扩容） ===
  const EXPAND_CONFIG = {
    equip:   { base: 100, perLevel: 20, maxLevel: 10, basePrice: 5000 },
    herb:    { base: 200, perLevel: 50, maxLevel: 8,  basePrice: 3000 },
    pill:    { base: 50,  perLevel: 10, maxLevel: 10, basePrice: 4000 },
    pet:     { base: 30,  perLevel: 5,  maxLevel: 10, basePrice: 8000 },
    formula: { base: 50,  perLevel: 10, maxLevel: 5,  basePrice: 6000 },
  }
  const storageExpand = computed(() => playerStore.storageExpand || {})
  const getLimit = (cat) => {
    const cfg = EXPAND_CONFIG[cat]
    if (!cfg) return 0
    const level = storageExpand.value[cat] || 0
    return cfg.base + cfg.perLevel * level
  }
  const getExpandCost = (cat) => {
    const cfg = EXPAND_CONFIG[cat]
    if (!cfg) return 0
    const level = storageExpand.value[cat] || 0
    return cfg.basePrice * (level + 1)
  }
  const canExpand = (cat) => {
    const cfg = EXPAND_CONFIG[cat]
    if (!cfg) return false
    const level = storageExpand.value[cat] || 0
    return level < cfg.maxLevel
  }
  const getCategoryName = (cat) => ({ equip: '装备', herb: '焰草', pill: '焰丹', pet: '焰兽', formula: '焰方' }[cat] || cat)
  const expandStorage = async (category) => {
    const cost = getExpandCost(category)
    if (playerStore.spiritStones < cost) {
      message.error(`焰晶不足，需要${cost}焰晶`)
      return
    }
    try {
      const authStore = useAuthStore()
      const res = await fetch('/api/storage/expand', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + authStore.token },
        body: JSON.stringify({ category })
      })
      const data = await res.json()
      if (data.success) {
        if (!playerStore.storageExpand) playerStore.storageExpand = {}
        playerStore.storageExpand[category] = (playerStore.storageExpand[category] || 0) + 1
        playerStore.spiritStones = data.remaining
        message.success(`扩容成功！${getCategoryName(category)}容量提升至 ${data.newLimit}`)
      } else {
        message.error(data.error || '扩容失败')
      }
    } catch (e) {
      message.error('网络错误')
    }
  }

  // === 新增：储藏室筛选 ===
  const activeFilter = ref('equip')

  // 各分类真实数量（非堆叠后的种类数）
  const equipCount = computed(() => {
    const equippedIds = new Set(Object.values(playerStore.equippedArtifacts).filter(Boolean).map(e => e.id))
    return playerStore.items.filter(i => i.type && i.type !== 'pill' && i.type !== 'pet' && i.stats && !equippedIds.has(i.id)).length
  })
  const herbCount = computed(() => playerStore.herbs.length)
  const pillCount = computed(() => playerStore.items.filter(i => i.type === 'pill').length)
  const petCount = computed(() => playerStore.items.filter(i => i.type === 'pet').length)
  const formulaCount = computed(() => playerStore.pillRecipes.length)
  const totalCount = computed(() => equipCount.value + herbCount.value + pillCount.value + petCount.value + formulaCount.value)
  const totalLimit = computed(() => ['equip','herb','pill','pet','formula'].reduce((a, cat) => a + getLimit(cat), 0))

  const filterTabs = computed(() => [
    { label: `装备 ${equipCount.value}/${getLimit('equip')}`, value: 'equip' },
    { label: `焰草 ${herbCount.value}/${getLimit('herb')}`, value: 'herb' },
    { label: `焰丹 ${pillCount.value}/${getLimit('pill')}`, value: 'pill' },
    { label: `焰方 ${formulaCount.value}/${getLimit('formula')}`, value: 'formula' },
    { label: `焰兽 ${petCount.value}/${getLimit('pet')}`, value: 'pet' },
    { label: '材料', value: 'material' },
  ])

  // 容量条相关
  const categoryCountMap = { equip: equipCount, herb: herbCount, pill: pillCount, pet: petCount, formula: formulaCount }
  const categoryLabelMap = { equip: '装备', herb: '焰草', pill: '焰丹', pet: '焰兽', formula: '焰方' }
  const currentCount = computed(() => categoryCountMap[activeFilter.value]?.value ?? 0)
  const currentLimit = computed(() => getLimit(activeFilter.value))
  const currentCategoryLabel = computed(() => categoryLabelMap[activeFilter.value] ?? '')
  const capacityPercent = computed(() => currentLimit.value > 0 ? Math.min(100, Math.round(currentCount.value / currentLimit.value * 100)) : 0)

  // === 储藏室统一物品列表 ===
  const storageItems = computed(() => {
    const items = []
    // 未装备的装备（不堆叠）
    const equippedIds = new Set(Object.values(playerStore.equippedArtifacts).filter(Boolean).map(e => e.id))
    playerStore.items.filter(i => i.type && i.type !== 'pill' && i.type !== 'pet' && i.stats && !equippedIds.has(i.id)).forEach(eq => {
      items.push({
        ...eq,
        _key: 'eq-' + eq.id,
        _category: 'equip',
        _emoji: equipTypeIcons[eq.type] || '📦',
        _icon: equipTypeImages[eq.type] && !imgLoadFailed.value[eq.type] ? equipTypeImages[eq.type] : null,
        _count: 1,
        _quality: eq.quality || 'common',
        _imgFail: false,
      })
    })
    // 焰草（堆叠）
    const herbGroups = {}
    playerStore.herbs.forEach(herb => {
      const herbId = herb.herbId || herb.herb_id || herb.id
      const herbIcon = herbImageMap[herbId] || null
      const chineseName = herbIdToName[herbId] || herbId
      if (!herbGroups[chineseName]) {
        herbGroups[chineseName] = { 
          ...herb, 
          _key: 'herb-' + chineseName, 
          _category: 'herb', 
          _emoji: '🌿', 
          _icon: herbIcon, 
          _count: 1, 
          _quality: herb.quality || 'common', 
          _imgFail: false,
          _displayName: chineseName
        }
      } else {
        herbGroups[chineseName]._count++
      }
    })
    items.push(...Object.values(herbGroups))
    // 焰丹（堆叠）
    const pillGroups = {}
    playerStore.items.filter(i => i.type === 'pill').forEach(pill => {
      const pillIcon = getPillImage(pill.name)
      if (!pillGroups[pill.name]) {
        pillGroups[pill.name] = { ...pill, _key: 'pill-' + pill.name, _category: 'pill', _emoji: '💊', _icon: pillIcon, _count: 1, _quality: pill.quality || 'common', _imgFail: false }
      } else {
        pillGroups[pill.name]._count++
      }
    })
    items.push(...Object.values(pillGroups))
    
    // 焰方
    playerStore.pillRecipes.forEach(recipeId => {
      const recipe = pillRecipes.find(r => r.id === recipeId)
      if (recipe) {
        items.push({
          ...recipe,
          _key: 'formula-' + recipeId,
          _category: 'formula',
          _emoji: '📜',
          _icon: getFormulaImage(recipe.name),
          _count: 1,
          _quality: recipe.grade?.replace('grade', '') || 'common',
          _imgFail: false,
          _displayName: recipe.name
        })
      }
    })
    
    // 焰兽
    const petGroups = {}
    playerStore.items.filter(i => i.type === 'pet').forEach(pet => {
      const petIcon = getPetImage(pet.name)
      if (!petGroups[pet.name]) {
        petGroups[pet.name] = {
          ...pet,
          _key: 'pet-' + pet.name,
          _category: 'pet',
          _emoji: '🐾',
          _icon: petIcon,
          _count: 1,
          _quality: pet.rarity || 'common',
          _imgFail: false,
          _displayName: pet.name
        }
      } else {
        petGroups[pet.name]._count++
      }
    })
    items.push(...Object.values(petGroups))
    
    return items
  })

  const filteredStorageItems = computed(() => {
    if (activeFilter.value === 'equip') return storageItems.value.filter(i => i._category === 'equip')
    if (activeFilter.value === 'herb') return storageItems.value.filter(i => i._category === 'herb')
    if (activeFilter.value === 'pill') return storageItems.value.filter(i => i._category === 'pill')
    if (activeFilter.value === 'formula') return []
    if (activeFilter.value === 'pet') return []
    return storageItems.value
  })

  const emptySlots = computed(() => {
    const count = filteredStorageItems.value.length
    const cols = 5
    const remainder = count % cols
    return remainder === 0 ? Math.max(0, cols - count) : (cols - remainder)
  })

  const getCellQualityClass = (item) => 'sq-' + (item._quality || 'common')

  const onEquipSlotClick = (type) => {
    if (playerStore.equippedArtifacts[type]) {
      showEquipmentDetails(playerStore.equippedArtifacts[type])
    } else {
      showEquipmentList(type)
    }
  }

  const onStorageItemClick = (item) => {
    if (item._category === 'equip') {
      showEquipmentDetails(item)
    } else if (item._category === 'pill') {
      selectedPill.value = item
      showPillDetailModal.value = true
    }
    // herb: no action (just display)
  }

  // === 原有逻辑保留 ===
  const currentPage = ref(1)
  const pageSize = ref(12)

  const filteredPets = computed(() => {
    const pets = playerStore.items.filter(item => item.type === 'pet')
    if (selectedRarityToRelease.value === 'all') return pets
    return pets.filter(pet => pet.rarity === selectedRarityToRelease.value)
  })

  const displayPets = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value
    return filteredPets.value.slice(start, start + pageSize.value)
  })

  const onPageSizeChange = size => { pageSize.value = size; currentPage.value = 1 }

  const usePill = async pill => {
    try {
      const authStore = useAuthStore()
      const resp = await authStore.apiPost('/pill/use', { pillId: pill.id })
      if (resp.success) {
        message.success(resp.message)
        if (resp.items) playerStore.items = resp.items
        if (resp.activeEffects) playerStore.activeEffects = resp.activeEffects
      } else {
        message.error(resp.message)
      }
    } catch (e) { message.error(e.message || '服用失败') }
  }

  const petRarities = {
    divine: { name: '神品', color: '#FF0000', probability: 0.02, essenceBonus: 50 },
    celestial: { name: '仙品', color: '#FFD700', probability: 0.08, essenceBonus: 30 },
    mystic: { name: '玄品', color: '#9932CC', probability: 0.15, essenceBonus: 20 },
    spiritual: { name: '灵品', color: '#1E90FF', probability: 0.25, essenceBonus: 10 },
    mortal: { name: '凡品', color: '#32CD32', probability: 0.5, essenceBonus: 5 }
  }

  const showPetModal = ref(false)
  const selectedPet = ref(null)
  const selectedFoodPet = ref(null)
  const showReleaseConfirm = ref(false)
  const showBatchReleaseConfirm = ref(false)
  const petToRelease = ref(null)

  const confirmReleasePet = pet => { petToRelease.value = pet; showReleaseConfirm.value = true }
  const cancelReleasePet = () => { petToRelease.value = null; showReleaseConfirm.value = false }

  const releasePet = async () => {
    if (petToRelease.value) {
      try {
        const authStore = useAuthStore()
        const resp = await authStore.apiPost('/pet/release', { petId: petToRelease.value.id })
        if (resp.success) {
          message.success(resp.message)
          if (resp.items) playerStore.items = resp.items
          if (resp.petEssence !== undefined) playerStore.petEssence = resp.petEssence
          if (resp.activePet !== undefined) playerStore.activePet = resp.activePet
        } else { message.error(resp.message) }
      } catch (e) { message.error('放生失败') }
      showReleaseConfirm.value = false; showPetModal.value = false; petToRelease.value = null
    }
  }

  const selectedRarityToRelease = ref('all')

  const batchReleasePets = async () => {
    try {
      const authStore = useAuthStore()
      const resp = await authStore.apiPost('/pet/release-batch', { rarity: selectedRarityToRelease.value })
      if (resp.success) {
        message.success(resp.message)
        if (resp.items) playerStore.items = resp.items
        if (resp.petEssence !== undefined) playerStore.petEssence = resp.petEssence
      } else { message.error(resp.message) }
    } catch (e) { message.error('批量放生失败') }
    showBatchReleaseConfirm.value = false
  }

  const showPetDetails = pet => { selectedPet.value = pet; selectedFoodPet.value = null; showPetModal.value = true }

  const getPetBonus = pet => {
    if (!pet) return { attack: 0, defense: 0, health: 0 }
    const qualityBonusMap = { divine: 0.5, celestial: 0.3, mystic: 0.2, spiritual: 0.1, mortal: 0.05 }
    const starBonusPerQuality = { divine: 0.1, celestial: 0.08, mystic: 0.06, spiritual: 0.04, mortal: 0.02 }
    const baseBonus = qualityBonusMap[pet.rarity] || 0.05
    const starBonus = (pet.star || 0) * (starBonusPerQuality[pet.rarity] || 0.02)
    const totalBonus = baseBonus + starBonus
    const phase = Math.floor((pet.star || 0) / 5)
    const phaseBonus = phase * (baseBonus * 0.5)
    const finalBonus = totalBonus + phaseBonus
    return { attack: finalBonus, defense: finalBonus, health: finalBonus }
  }

  const getUpgradeCost = pet => (pet.level || 1) * 10
  const canUpgrade = pet => playerStore.petEssence >= getUpgradeCost(pet)

  const getAvailableFoodPets = pet => {
    if (!pet) return []
    return playerStore.items.filter(item => item.type === 'pet' && item.id !== pet.id && item.star === pet.star && item.rarity === pet.rarity && item.name === pet.name)
      .map(item => ({ label: `${item.name} (${item.level || 1}级 ${item.star || 0}星)`, value: item.id }))
  }

  const upgradePet = async pet => {
    try {
      const authStore = useAuthStore()
      const resp = await authStore.apiPost('/pet/upgrade', { petId: pet.id })
      if (resp.success) {
        message.success(resp.message)
        if (resp.petEssence !== undefined) playerStore.petEssence = resp.petEssence
        // 更新本地焰兽数据
        const idx = playerStore.items.findIndex(i => String(i.id) === String(pet.id))
        if (idx > -1 && resp.pet) playerStore.items[idx] = resp.pet
        if (selectedPet.value) selectedPet.value = resp.pet
        if (playerStore.activePet && String(playerStore.activePet.id) === String(pet.id)) {
          playerStore.activePet = resp.pet
        }
      } else {
        message.error(resp.message)
      }
    } catch (e) { message.error(e.message || '升级失败') }
  }

  const evolvePet = async pet => {
    if (!selectedFoodPet.value) { message.error('请选择用于升星的焰兽'); return }
    try {
      const authStore = useAuthStore()
      const resp = await authStore.apiPost('/pet/evolve', { petId: pet.id, foodPetId: selectedFoodPet.value })
      if (resp.success) {
        message.success(resp.message)
        if (resp.items) playerStore.items = resp.items
        if (resp.pet) {
          selectedPet.value = resp.pet
          if (playerStore.activePet && String(playerStore.activePet.id) === String(pet.id)) playerStore.activePet = resp.pet
        }
        selectedFoodPet.value = null; showPetModal.value = false
      } else { message.error(resp.message) }
    } catch (e) { message.error('升星失败') }
  }

  const equipTypeIcons = {
    weapon: '⚔️', head: '⛑️', body: '🛡️', legs: '👖', feet: '👢',
    shoulder: '🦺', hands: '🧤', wrist: '⌚', necklace: '📿',
    ring1: '💍', ring2: '💍', belt: '🎗️', artifact: '🔮'
  }

  const equipTypeImages = {
    weapon: img('/assets/images/equip/weapon.png'), head: img('/assets/images/equip/head.png'),
    body: img('/assets/images/equip/body.png'), legs: img('/assets/images/equip/legs.png'),
    feet: img('/assets/images/equip/feet.png'), shoulder: img('/assets/images/equip/shoulder.png'),
    hands: img('/assets/images/equip/hands.png'), wrist: img('/assets/images/equip/wrist.png'),
    necklace: img('/assets/images/equip/necklace.png'), ring1: img('/assets/images/equip/ring.png'),
    ring2: img('/assets/images/equip/ring.png'), belt: img('/assets/images/equip/belt.png'),
    artifact: img('/assets/images/equip/artifact.png')
  }

  const imgLoadFailed = ref({})
  const onEquipImgError = (type) => { imgLoadFailed.value[type] = true }

  const equipmentTypes = {
    weapon: '焰杖', head: '头部', body: '衣服', legs: '裤子', feet: '鞋子',
    shoulder: '肩甲', hands: '手套', wrist: '护腕', necklace: '焰心链',
    ring1: '符文戒1', ring2: '符文戒2', belt: '腰带', artifact: '焰器'
  }

  const selectedType = ref('')
  const showEquipmentList = type => { selectedType.value = type; selectedEquipmentType.value = type; showEquipmentModal.value = true }

  const unequipItem = async (equipment) => {
    if (!equipment) { message.error('未选择装备'); return }
    const slot = equipment.equippedSlot || equipment.slot || equipment.type
    try {
      const authStore = useAuthStore()
      const resp = await authStore.apiPost('/equip/unwear', { slot })
      if (resp.success) {
        if (resp.items) playerStore.items = resp.items
        if (resp.equippedArtifacts) playerStore.equippedArtifacts = resp.equippedArtifacts
        // 更新属性面板
        if (resp.baseAttributes) playerStore.baseAttributes = resp.baseAttributes
        if (resp.combatAttributes) playerStore.combatAttributes = resp.combatAttributes
        if (resp.combatResistance) playerStore.combatResistance = resp.combatResistance
        if (resp.specialAttributes) playerStore.specialAttributes = resp.specialAttributes
        if (resp.artifactBonuses) playerStore.artifactBonuses = resp.artifactBonuses
        showEquipmentDetailModal.value = false
        message.success('当前装备已卸下')
      } else { message.error(resp.message || '卸下装备失败') }
    } catch (e) { message.error('卸下装备失败') }
  }

  const showEquipmentModal = ref(false)
  const selectedEquipmentType = ref('')
  const selectedQuality = ref('all')
  const currentEquipmentPage = ref(1)
  const equipmentPageSize = ref(8)

  const qualityOptions = computed(() => {
    const equipmentsByQuality = {}
    playerStore.items.filter(item => !selectedEquipmentType.value || item.type === selectedEquipmentType.value)
      .forEach(item => { equipmentsByQuality[item.quality] = (equipmentsByQuality[item.quality] || 0) + 1 })
    return [
      { label: '仙品', value: 'mythic', disabled: !equipmentsByQuality['mythic'] },
      { label: '极品', value: 'legendary', disabled: !equipmentsByQuality['legendary'] },
      { label: '上品', value: 'epic', disabled: !equipmentsByQuality['epic'] },
      { label: '中品', value: 'rare', disabled: !equipmentsByQuality['rare'] },
      { label: '下品', value: 'uncommon', disabled: !equipmentsByQuality['uncommon'] },
      { label: '凡品', value: 'common', disabled: !equipmentsByQuality['common'] }
    ]
  })

  const filteredEquipmentList = computed(() => {
    return playerStore.items.filter(item => {
      if (!selectedEquipmentType.value) return false
      if (item.type !== selectedEquipmentType.value) return false
      if (selectedQuality.value !== 'all' && item.quality !== selectedQuality.value) return false
      return true
    })
  })

  const equipmentList = computed(() => {
    const start = (currentEquipmentPage.value - 1) * equipmentPageSize.value
    return filteredEquipmentList.value.slice(start, start + equipmentPageSize.value)
  })

  const onEquipmentPageSizeChange = size => { equipmentPageSize.value = size; currentEquipmentPage.value = 1 }

  const batchSellEquipments = async () => {
    if (authStore.isLoggedIn) {
      try {
        const resp = await authStore.apiPost('/equipment/batch-sell', {
          quality: selectedQuality.value === 'all' ? null : selectedQuality.value,
          equipmentType: selectedEquipmentType.value
        })
        playerStore.reinforceStones = resp.reinforceStones
        // 重新从服务端同步 items
        if (resp.count > 0) {
          const loadResp = await authStore.apiGet('/game/load')
          if (loadResp.player?.game_data?.items) playerStore.items = loadResp.player.game_data.items
        }
        message.success(`成功卖出${resp.count}件装备，获得${resp.totalStones}个淬火石`)
      } catch (e) { message.error(e.message || '批量卖出失败') }
    }
  }

  const sellEquipment = async equipment => {
    try {
      const resp = await authStore.apiPost('/equipment/sell', { equipmentId: equipment.id })
      playerStore.reinforceStones = resp.reinforceStones
      const idx = playerStore.items.findIndex(i => String(i.id) === String(equipment.id))
      if (idx > -1) playerStore.items.splice(idx, 1)
      message.success(`成功卖出装备，获得${resp.stones}个淬火石`)
      showEquipmentDetailModal.value = false
    } catch (e) { message.error(e.message || '卖出失败') }
  }

  // 官方回收（分解）
  const recycleRewards = {
    common: '50💎 + 1淬火石',
    uncommon: '150💎 + 3淬火石',
    rare: '500💎 + 8淬火石',
    epic: '2000💎 + 20淬火石 + 5洗练石',
    legendary: '8000💎 + 50淬火石 + 15洗练石',
    mythic: '30000💎 + 100淬火石 + 50洗练石 + 20精华'
  }
  const getRecyclePreview = (equip) => {
    const base = recycleRewards[equip?.quality] || '50💎 + 1淬火石'
    const enhLvl = equip?.enhanceLevel || 0
    return enhLvl > 0 ? base + ` (+${enhLvl * 200}💎 强化返还)` : base
  }
  const recycleEquipment = async (equipment) => {
    if (!authStore.isLoggedIn) { message.warning('请先登录'); return }
    try {
      const resp = await authStore.apiPost('/equipment/disassemble', { equipmentId: equipment.id })
      if (resp.ok) {
        const idx = playerStore.items.findIndex(i => String(i.id) === String(equipment.id))
        if (idx > -1) playerStore.items.splice(idx, 1)
        const r = resp.reward
        let msg = `回收成功！获得 ${r.stones}💎`
        if (r.reinforce) msg += ` + ${r.reinforce}淬火石`
        if (r.refinement) msg += ` + ${r.refinement}洗练石`
        if (r.essence) msg += ` + ${r.essence}精华`
        message.success(msg)
        showEquipmentDetailModal.value = false
      }
    } catch (e) { message.error(e.message || '回收失败') }
  }

  const showEquipmentDetails = equipment => { selectedEquipment.value = equipment; showEquipmentDetailModal.value = true }
  const showEquipmentDetailModal = ref(false)
  const selectedPill = ref(null)
  const showPillDetailModal = ref(false)
  const selectedEquipment = ref(null)
  const showEnhanceConfirm = ref(false)

  const handleEnhanceEquipment = async () => {
    if (!selectedEquipment.value) return
    try {
      const resp = await authStore.apiPost('/equipment/enhance', { equipmentId: selectedEquipment.value.id })
      if (resp.enhanced) {
        selectedEquipment.value.stats = { ...resp.newStats }
        selectedEquipment.value.enhanceLevel = resp.newLevel
        playerStore.reinforceStones = resp.reinforceStones
        message.success('淬火成功')
      } else {
        playerStore.reinforceStones = resp.reinforceStones
        message.warning(resp.message || '淬火失败，淬火石已消耗')
      }
    } catch (e) { message.error(e.message || '淬火失败') }
    showEnhanceConfirm.value = false
  }

  const showReforgeConfirm = ref(false)
  const reforgeResult = ref(null)

  const handleReforgeEquipment = async () => {
    if (!selectedEquipment.value) return
    try {
      const resp = await authStore.apiPost('/equipment/reforge', { equipmentId: selectedEquipment.value.id })
      playerStore.refinementStones = resp.refinementStones
      reforgeResult.value = { success: true, oldStats: resp.oldStats, newStats: resp.newStats, cost: resp.cost }
      showReforgeConfirm.value = true
    } catch (e) { message.error(e.message || '铭符失败') }
  }

  const confirmReforgeResult = async (keepNew) => {
    if (!reforgeResult.value) return
    try {
      await authStore.apiPost('/equipment/reforge-confirm', { confirm: keepNew })
      if (keepNew && selectedEquipment.value) {
        selectedEquipment.value.stats = reforgeResult.value.newStats
      }
      message.success(keepNew ? '已确认新属性' : '已保留原有属性')
    } catch (e) { message.error(e.message || '确认失败') }
    showReforgeConfirm.value = false; reforgeResult.value = null
  }

  const equipItem = async (equipment) => {
    try {
      const authStore = useAuthStore()
      const resp = await authStore.apiPost('/equip/wear', { equipId: equipment.id, slot: equipment.type })
      if (resp.success) {
        if (resp.items) playerStore.items = resp.items
        if (resp.equippedArtifacts) playerStore.equippedArtifacts = resp.equippedArtifacts
        // 更新属性面板
        if (resp.baseAttributes) playerStore.baseAttributes = resp.baseAttributes
        if (resp.combatAttributes) playerStore.combatAttributes = resp.combatAttributes
        if (resp.combatResistance) playerStore.combatResistance = resp.combatResistance
        if (resp.specialAttributes) playerStore.specialAttributes = resp.specialAttributes
        if (resp.artifactBonuses) playerStore.artifactBonuses = resp.artifactBonuses
        message.success(resp.message)
        showEquipmentModal.value = false
        showEquipmentDetailModal.value = false
      } else { message.error(resp.message || '装备失败') }
    } catch (e) { message.error('装备失败') }
  }

  const getEquipPower = (equip) => {
    if (!equip || !equip.stats) return 0
    return Object.values(equip.stats).reduce((sum, v) => sum + (typeof v === 'number' ? v : 0), 0)
  }

  const oneKeyEquip = async () => {
    let count = 0
    const authStore = useAuthStore()
    for (const slot of Object.keys(equipmentTypes)) {
      const candidates = playerStore.items.filter(item => item.type === slot && (!item.requiredRealm || playerStore.level >= item.requiredRealm))
      if (candidates.length === 0) continue
      const best = candidates.reduce((a, b) => getEquipPower(a) > getEquipPower(b) ? a : b)
      const current = playerStore.equippedArtifacts[slot]
      if (!current || getEquipPower(best) > getEquipPower(current)) {
        try {
          const resp = await authStore.apiPost('/equip/wear', { equipId: best.id, slot })
          if (resp.success) {
            if (resp.items) playerStore.items = resp.items
            if (resp.equippedArtifacts) playerStore.equippedArtifacts = resp.equippedArtifacts
            count++
          }
        } catch (e) {}
      }
    }
    if (count > 0) message.success(`一键穿戴完成，更换了 ${count} 件装备`)
    else message.info('没有更强的装备可以替换')
  }

  const oneKeyUnequip = async () => {
    let count = 0
    const authStore = useAuthStore()
    for (const slot of Object.keys(equipmentTypes)) {
      if (playerStore.equippedArtifacts[slot]) {
        try {
          const resp = await authStore.apiPost('/equip/unwear', { slot })
          if (resp.success) {
            if (resp.items) playerStore.items = resp.items
            if (resp.equippedArtifacts) playerStore.equippedArtifacts = resp.equippedArtifacts
        // 更新属性面板
        if (resp.baseAttributes) playerStore.baseAttributes = resp.baseAttributes
        if (resp.combatAttributes) playerStore.combatAttributes = resp.combatAttributes
        if (resp.combatResistance) playerStore.combatResistance = resp.combatResistance
        if (resp.specialAttributes) playerStore.specialAttributes = resp.specialAttributes
        if (resp.artifactBonuses) playerStore.artifactBonuses = resp.artifactBonuses
            count++
          }
        } catch (e) {}
      }
    }
    if (count > 0) message.success(`已卸下 ${count} 件装备`)
    else message.info('没有装备需要卸下')
  }

  const groupedHerbs = computed(() => {
    const groups = {}
    playerStore.herbs.forEach(herb => {
      if (!groups[herb.name]) groups[herb.name] = { ...herb, count: 1 }
      else groups[herb.name].count++
    })
    return Object.values(groups)
  })

  const groupedFormulas = computed(() => {
    const complete = playerStore.pillRecipes.map(recipeId => {
      const recipe = pillRecipes.find(r => r.id === recipeId)
      return recipe ? { id: recipe.id, name: recipe.name, description: recipe.description, grade: recipe.grade, type: recipe.type, isComplete: true } : null
    }).filter(Boolean)
    const incomplete = Object.entries(playerStore.pillFragments).map(([recipeId, fragments]) => {
      const recipe = pillRecipes.find(r => r.id === recipeId)
      return recipe ? { id: recipe.id, name: recipe.name, description: recipe.description, grade: recipe.grade, type: recipe.type, isComplete: false, fragments, fragmentsNeeded: recipe.fragmentsNeeded } : null
    }).filter(Boolean)
    return { complete, incomplete }
  })

  const groupedPills = computed(() => {
    const groups = {}
    playerStore.items.filter(item => item.type === 'pill').forEach(pill => {
      if (!groups[pill.name]) groups[pill.name] = { ...pill, count: 1 }
      else groups[pill.name].count++
    })
    return Object.values(groups)
  })

  const useItem = async item => {
    if (item.type === 'pet') {
      try {
        const authStore = useAuthStore()
        const isDeployed = playerStore.activePet && String(playerStore.activePet.id) === String(item.id)
        const resp = await authStore.apiPost('/pet/deploy', { petId: isDeployed ? null : item.id })
        if (resp.success) {
          playerStore.activePet = resp.activePet
          message.success(resp.message)
        } else { message.error(resp.message || '操作失败') }
      } catch (e) { message.error('操作失败') }
    }
  }

  const equipmentComparison = computed(() => {
    if (!selectedEquipment.value || !selectedEquipment.value.type) return null
    const slotKey = selectedEquipment.value.slot || selectedEquipment.value.type
    const currentEquipment = playerStore.equippedArtifacts[slotKey]
    if (!currentEquipment) return null
    const comparison = {}
    const allStats = new Set([...Object.keys(selectedEquipment.value.stats), ...Object.keys(currentEquipment.stats)])
    allStats.forEach(stat => {
      const selectedValue = selectedEquipment.value.stats[stat] || 0
      const currentValue = currentEquipment.stats[stat] || 0
      const diff = selectedValue - currentValue
      comparison[stat] = { current: currentValue, selected: selectedValue, diff, isPositive: diff > 0 }
    })
    return comparison
  })

  const options = [
    { label: '神品', value: 'divine' },
    { label: '仙品', value: 'celestial' },
    { label: '玄品', value: 'mystic' },
    { label: '灵品', value: 'spiritual' },
    { label: '凡品', value: 'mortal' }
  ]
</script>

<style scoped>
  /* === 储藏室容器 === */
  .storage-container { padding: 8px; }
  .storage-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
  .storage-title { font-size: 18px; font-weight: 700; color: #d4a843; text-shadow: 0 0 10px rgba(212,168,67,0.4); }
  .storage-actions { display: flex; gap: 8px; }

  /* === 装备栏 === */
  .equip-bar { margin-bottom: 16px; padding: 10px; border-radius: 12px; background: rgba(10,8,18,0.6); border: 1px solid rgba(212,168,67,0.15); }
  .equip-bar-label { font-size: 13px; color: #8a7a5a; margin-bottom: 8px; font-weight: 600; }
  .equip-bar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px; }
  @media (max-width: 500px) { .equip-bar-grid { grid-template-columns: repeat(5, 1fr); } }

  .equip-bar-slot {
    position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center;
    width: 100%; aspect-ratio: 1; border-radius: 8px; cursor: pointer;
    background: rgba(15,15,25,0.8); transition: all 0.25s ease; padding: 4px 2px; overflow: hidden;
  }
  .equip-bar-slot:hover { transform: translateY(-2px); }
  .eq-empty { border: 1.5px dashed rgba(212,168,67,0.2); }
  .eq-empty:hover { border-color: rgba(212,168,67,0.5); box-shadow: 0 0 10px rgba(212,168,67,0.15); }

  .eq-slot-icon { width: 28px; height: 28px; object-fit: contain; image-rendering: pixelated; filter: drop-shadow(0 0 4px rgba(212,168,67,0.5)); }
  .eq-slot-icon-empty { opacity: 0.3; filter: grayscale(0.6); }
  .eq-slot-emoji { font-size: 20px; }
  .eq-slot-emoji-empty { opacity: 0.3; filter: grayscale(0.6); }
  .eq-slot-name { font-size: 9px; color: #a09070; text-align: center; line-height: 1.2; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; width: 100%; margin-top: 2px; }
  .eq-enhance { position: absolute; top: 1px; right: 2px; font-size: 9px; color: #FFD700; font-weight: bold; text-shadow: 0 0 4px rgba(255,215,0,0.6); }

  /* 装备栏品质 */
  .eq-quality-common { border: 1.5px solid #555; }
  .eq-quality-uncommon { border: 1.5px solid #4caf50; box-shadow: 0 0 6px rgba(76,175,80,0.3); }
  .eq-quality-rare { border: 1.5px solid #2196f3; box-shadow: 0 0 6px rgba(33,150,243,0.3); }
  .eq-quality-epic { border: 1.5px solid #9c27b0; box-shadow: 0 0 8px rgba(156,39,176,0.3); }
  .eq-quality-legendary { border: 1.5px solid #ff9800; box-shadow: 0 0 8px rgba(255,152,0,0.4); }
  .eq-quality-mythic { border: 1.5px solid #e91e63; box-shadow: 0 0 10px rgba(233,30,99,0.4); animation: mythic-pulse 2s ease-in-out infinite; }

  @keyframes mythic-pulse {
    0%,100% { box-shadow: 0 0 8px rgba(233,30,99,0.4); }
    50% { box-shadow: 0 0 18px rgba(233,30,99,0.7), 0 0 30px rgba(233,30,99,0.2); }
  }

  /* === 筛选 tab === */
  .filter-tabs { display: flex; gap: 4px; margin-bottom: 12px; flex-wrap: wrap; }

  /* === 容量条 === */
  .capacity-bar { display: flex; align-items: center; gap: 8px; padding: 4px 8px; margin-bottom: 8px; }
  .capacity-text { font-size: 12px; color: #b8860b; white-space: nowrap; }
  .capacity-track { flex: 1; height: 4px; background: #333; border-radius: 2px; overflow: hidden; }
  .capacity-fill { height: 100%; background: linear-gradient(90deg, #b8860b, #ffd700); border-radius: 2px; transition: width 0.3s; }
  .capacity-fill.capacity-full { background: linear-gradient(90deg, #ff4444, #ff6666); }
  .capacity-max { font-size: 11px; color: #666; white-space: nowrap; }
  .filter-tab {
    padding: 4px 14px; border-radius: 16px; font-size: 13px; cursor: pointer; color: #8a7a5a;
    background: rgba(15,15,25,0.6); border: 1px solid rgba(212,168,67,0.1); transition: all 0.25s;
  }
  .filter-tab:hover { color: #d4a843; border-color: rgba(212,168,67,0.3); }
  .filter-tab.active { color: #000; background: linear-gradient(135deg, #d4a843, #f0c060); border-color: #d4a843; font-weight: 600; }

  /* === 储藏室网格 === */
  .storage-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 8px; }
  @media (max-width: 500px) { .storage-grid { grid-template-columns: repeat(4, 1fr); } }

  .storage-cell {
    position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center;
    aspect-ratio: 1; border-radius: 10px; cursor: pointer; padding: 6px 4px;
    background: rgba(15,15,25,0.8); transition: all 0.25s ease; overflow: hidden;
  }
  .storage-cell:hover { transform: translateY(-3px) scale(1.03); z-index: 2; }

  .storage-cell-empty {
    background: rgba(15,15,25,0.4); border: 1.5px dashed rgba(212,168,67,0.08); cursor: default;
  }
  .storage-cell-empty:hover { transform: none; }
  .empty-dot { color: rgba(212,168,67,0.1); font-size: 20px; }

  /* 网格品质边框 */
  .sq-common { border: 1.5px solid #9e9e9e44; }
  .sq-common:hover { border-color: #9e9e9e; box-shadow: 0 0 8px rgba(158,158,158,0.3); }
  .sq-uncommon { border: 1.5px solid #4caf5066; }
  .sq-uncommon:hover { border-color: #4caf50; box-shadow: 0 0 10px rgba(76,175,80,0.4); }
  .sq-rare { border: 1.5px solid #2196f366; }
  .sq-rare:hover { border-color: #2196f3; box-shadow: 0 0 10px rgba(33,150,243,0.4); }
  .sq-epic { border: 1.5px solid #9c27b066; }
  .sq-epic:hover { border-color: #9c27b0; box-shadow: 0 0 12px rgba(156,39,176,0.4); }
  .sq-legendary { border: 1.5px solid #ff980066; }
  .sq-legendary:hover { border-color: #ff9800; box-shadow: 0 0 12px rgba(255,152,0,0.5); }
  .sq-mythic { border: 1.5px solid #e91e6366; animation: mythic-pulse 2s ease-in-out infinite; }
  .sq-mythic:hover { border-color: #e91e63; box-shadow: 0 0 16px rgba(233,30,99,0.6); }

  /* 格子内容 */
  .cell-icon-area { width: 32px; height: 32px; display: flex; align-items: center; justify-content: center; margin-bottom: 2px; }
  .cell-img { width: 30px; height: 30px; object-fit: contain; image-rendering: pixelated; filter: drop-shadow(0 0 4px rgba(212,168,67,0.4)); }
  .cell-emoji { font-size: 22px; }
  .cell-label { font-size: 10px; color: #d4a843; text-align: center; line-height: 1.2; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; width: 100%; font-weight: 600; }
  .cell-count {
    position: absolute; bottom: 3px; right: 3px; background: linear-gradient(135deg, #d4a843, #b8860b);
    color: #000; border-radius: 8px; padding: 0 5px; font-size: 10px; font-weight: bold; line-height: 16px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.4);
  }
  .cell-use-hint { font-size: 9px; color: #d4a843; opacity: 0; transition: opacity 0.25s; }
  .storage-cell:hover .cell-use-hint { opacity: 1; }
  .cell-meta { font-size: 9px; color: #8a7a5a; }
  .cell-sell-btn { position: absolute; top: 2px; right: 2px; }

  /* === 焰兽格子 === */
  .pet-img { width: 30px; height: 30px; border-radius: 6px; }
  .pet-stars-mini { font-size: 8px; color: #FFD700; line-height: 1; }
  .pet-q-mortal { border: 1.5px solid #32CD3266; }
  .pet-q-mortal:hover { border-color: #32CD32; box-shadow: 0 0 8px rgba(50,205,50,0.4); }
  .pet-q-spiritual { border: 1.5px solid #1E90FF66; }
  .pet-q-spiritual:hover { border-color: #1E90FF; box-shadow: 0 0 8px rgba(30,144,255,0.4); }
  .pet-q-mystic { border: 1.5px solid #9932CC66; }
  .pet-q-mystic:hover { border-color: #9932CC; box-shadow: 0 0 10px rgba(153,50,204,0.4); }
  .pet-q-celestial { border: 1.5px solid #FFD70066; }
  .pet-q-celestial:hover { border-color: #FFD700; box-shadow: 0 0 10px rgba(255,215,0,0.5); }
  .pet-q-divine { border: 1.5px solid #FF000066; animation: divine-glow 2s ease-in-out infinite; }
  .pet-q-divine:hover { border-color: #FF0000; box-shadow: 0 0 14px rgba(255,0,0,0.5); }
  .pet-active-cell { animation: active-pulse 1.5s ease-in-out infinite !important; }

  @keyframes divine-glow {
    0%,100% { box-shadow: 0 0 8px rgba(255,0,0,0.4); }
    50% { box-shadow: 0 0 18px rgba(255,0,0,0.7), 0 0 28px rgba(255,0,0,0.2); }
  }
  @keyframes active-pulse {
    0%,100% { box-shadow: 0 0 6px rgba(255,215,0,0.4); }
    50% { box-shadow: 0 0 14px rgba(255,215,0,0.8), 0 0 24px rgba(255,215,0,0.3); }
  }

  /* === 焰方格子 === */
  .formula-cell { border: 1px solid rgba(212,168,67,0.2); }
  .formula-cell:hover { border-color: rgba(212,168,67,0.5); box-shadow: 0 0 10px rgba(212,168,67,0.2); }
  .formula-section :deep(.n-tabs-tab) { font-size: 12px; }

  /* === 弹窗内样式 === */
  .pet-detail-header { display: flex; justify-content: center; margin-bottom: 12px; }
  .pet-detail-avatar { width: 96px; height: 96px; border-radius: 12px; border: 2px solid rgba(212,168,67,0.5); box-shadow: 0 0 16px rgba(212,168,67,0.4); object-fit: cover; }
  .detail-quality-text { font-weight: bold; font-size: 15px; }
  .stats-comparison :deep(.n-gradient-text) { font-weight: bold; font-size: 14px; }
  .reforge-compare { display: flex; justify-content: space-between; gap: 20px; margin: 16px 0; }
  .old-stats, .new-stats { flex: 1; padding: 16px; border-radius: 10px; background: rgba(20,18,30,0.8); border: 1px solid rgba(212,168,67,0.15); }
  .old-stats h3, .new-stats h3 { margin-top: 0; margin-bottom: 12px; font-size: 16px; color: #d4a843; }

  /* 装备列表弹窗中的格子 */
  .equip-list-cell { aspect-ratio: auto; min-height: 70px; padding: 8px; }

  @media (max-width: 500px) {
    .reforge-compare { flex-direction: column; gap: 10px; }
    .storage-grid { grid-template-columns: repeat(3, 1fr); }
    .equip-bar-grid { grid-template-columns: repeat(4, 1fr); }
  }
.material-section { padding: 8px 0; }
.material-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }
.material-card { background: rgba(26,26,46,0.8); border: 1px solid rgba(212,168,67,0.2); border-radius: 10px; padding: 16px; text-align: center; transition: all 0.2s; }
.material-card:hover { border-color: rgba(212,168,67,0.5); }
.material-icon { font-size: 32px; margin-bottom: 6px; }
.material-name { font-size: 13px; color: #d4a843; font-weight: bold; }
.material-count { font-size: 22px; color: #e0d0b0; font-weight: bold; margin: 4px 0; }
.material-desc { font-size: 11px; color: #666; }
</style>
