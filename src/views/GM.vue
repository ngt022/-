<template>
  <div>
    <n-card title="基础属性编辑">
      <n-form>
        <n-form-item label="焰名">
          <n-input v-model:value="baseAttributes.name" />
        </n-form-item>
        <n-form-item label="焰阶等级">
          <n-input-number v-model:value="baseAttributes.level" />
        </n-form-item>
        <n-form-item label="焰阶名称">
          <n-input v-model:value="baseAttributes.realm" />
        </n-form-item>
        <n-form-item label="当前焰力">
          <n-input-number v-model:value="baseAttributes.cultivation" />
        </n-form-item>
        <n-form-item label="最大焰力">
          <n-input-number v-model:value="baseAttributes.maxCultivation" />
        </n-form-item>
        <n-form-item label="焰灵">
          <n-input-number v-model:value="baseAttributes.spirit" />
        </n-form-item>
        <n-form-item label="焰灵获取倍率">
          <n-input-number v-model:value="baseAttributes.spiritRate" />
        </n-form-item>
        <n-form-item label="幸运值">
          <n-input-number v-model:value="baseAttributes.luck" />
        </n-form-item>
        <n-form-item label="冥想速率">
          <n-input-number v-model:value="baseAttributes.cultivationRate" />
        </n-form-item>
        <n-form-item label="焰草获取倍率">
          <n-input-number v-model:value="baseAttributes.herbRate" />
        </n-form-item>
        <n-form-item label="焰炼成功率加成">
          <n-input-number v-model:value="baseAttributes.alchemyRate" />
        </n-form-item>
        <n-form-item label="焰晶">
          <n-input-number v-model:value="baseAttributes.spiritStones" />
        </n-form-item>
        <n-form-item label="焰兽精华">
          <n-input-number v-model:value="baseAttributes.petEssence" />
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space justify="end">
          <n-button type="info" @click="resetPlayerData">重置数据</n-button>
          <n-button type="primary" @click="updateAttributes">保存修改</n-button>
        </n-space>
      </template>
    </n-card>

    <n-card title="快捷操作" style="margin-top: 16px;">
      <n-space>
        <n-button type="error" size="large" @click="oneKeyMaxGear" :loading="maxGearLoading">
          🔥 一键满配（仙品+100全套）
        </n-button>
        <n-button type="warning" size="large" @click="clearAllEquipments">
          🗑️ 清空所有装备
        </n-button>
      </n-space>
      <div v-if="maxGearLog" style="margin-top:12px;padding:10px;background:rgba(212,168,67,0.1);border-radius:8px;font-size:13px;color:#d4a843;white-space:pre-line;">{{ maxGearLog }}</div>
    </n-card>

    <n-card title="物品空投" style="margin-top: 16px;">
      <n-tabs type="segment">
        <n-tab-pane name="equip" tab="装备空投">
          <n-space vertical>
            <n-space>
              <n-select v-model:value="equipForm.type" :options="equipTypeOptions" placeholder="选择装备类型" style="width: 180px;" />
              <n-select v-model:value="equipForm.quality" :options="equipQualityOptions" placeholder="选择品质" style="width: 140px;" />
              <n-input-number v-model:value="equipForm.count" :min="1" :max="99" placeholder="数量" style="width: 100px;" />
              <n-button type="primary" @click="airdropEquipment">空投</n-button>
            </n-space>
          </n-space>
        </n-tab-pane>
        <n-tab-pane name="herb" tab="焰草空投">
          <n-space vertical>
            <n-space>
              <n-select v-model:value="herbForm.id" :options="herbOptions" placeholder="选择焰草" style="width: 180px;" />
              <n-select v-model:value="herbForm.quality" :options="herbQualityOptions" placeholder="选择品质" style="width: 140px;" />
              <n-input-number v-model:value="herbForm.count" :min="1" :max="999" placeholder="数量" style="width: 100px;" />
              <n-button type="primary" @click="airdropHerb">空投</n-button>
            </n-space>
          </n-space>
        </n-tab-pane>
        <n-tab-pane name="pill" tab="焰丹空投">
          <n-space vertical>
            <n-space>
              <n-select v-model:value="pillForm.id" :options="pillOptions" placeholder="选择焰丹" style="width: 200px;" />
              <n-input-number v-model:value="pillForm.count" :min="1" :max="99" placeholder="数量" style="width: 100px;" />
              <n-button type="primary" @click="airdropPill">空投</n-button>
            </n-space>
          </n-space>
        </n-tab-pane>
        <n-tab-pane name="pet" tab="焰兽空投">
          <n-space vertical>
            <n-space>
              <n-select v-model:value="petForm.rarity" :options="petRarityOptions" placeholder="选择品质" style="width: 140px;" @update:value="onPetRarityChange" />
              <n-select v-model:value="petForm.name" :options="petNameOptions" placeholder="随机(不选)" clearable style="width: 160px;" />
              <n-input-number v-model:value="petForm.count" :min="1" :max="99" placeholder="数量" style="width: 100px;" />
              <n-button type="primary" @click="airdropPet">空投</n-button>
            </n-space>
          </n-space>
        </n-tab-pane>
      </n-tabs>
    </n-card>
  </div>
</template>

<script setup>
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { ref, computed } from 'vue'
import { useMessage } from 'naive-ui'
import { pillRecipes, calculatePillEffect } from '../plugins/pills'
import { herbs, herbQualities, getHerbValue } from '../plugins/herbs'

const playerStore = usePlayerStore()
const authStore = useAuthStore()
const message = useMessage()

// ========== 基础属性 ==========
const baseAttributes = ref({
  name: playerStore.name,
  level: playerStore.level,
  realm: playerStore.realm,
  cultivation: playerStore.cultivation,
  maxCultivation: playerStore.maxCultivation,
  spirit: playerStore.spirit,
  spiritRate: playerStore.spiritRate,
  luck: playerStore.luck,
  cultivationRate: playerStore.cultivationRate,
  herbRate: playerStore.herbRate,
  alchemyRate: playerStore.alchemyRate,
  spiritStones: playerStore.spiritStones,
  petEssence: playerStore.petEssence
})

const updateAttributes = () => {
  try {
    Object.entries(baseAttributes.value).forEach(([key, value]) => {
      if (typeof value === 'number') {
        playerStore[key] = Number(value)
      } else {
        playerStore[key] = value
      }
    })
    playerStore.saveData()
    message.success('属性更新成功')
  } catch (error) {
    message.error('更新失败：' + error.message)
  }
}

const resetPlayerData = async () => {
  try {
    playerStore.$reset()
    await playerStore.initializePlayer()
    message.success('数据重置成功')
    Object.entries(playerStore).forEach(([key, value]) => {
      if (key in baseAttributes.value) {
        baseAttributes.value[key] = value
      }
    })
  } catch (error) {
    message.error('重置失败：' + error.message)
  }
}

// ========== 一键满配 ==========
const maxGearLoading = ref(false)
const maxGearLog = ref('')

const oneKeyMaxGear = () => {
  maxGearLoading.value = true
  maxGearLog.value = ''
  try {
    const slots = Object.keys(equipmentTypes)
    const logs = []
    // 先卸下所有装备
    slots.forEach(slot => {
      if (playerStore.equippedArtifacts[slot]) {
        playerStore.unequipArtifact(slot)
      }
    })
    logs.push('✅ 已卸下所有旧装备')

    // 给每个栏位生成仙品装备并装备
    slots.forEach(slot => {
      const equip = generateEquipment(playerStore.level, slot, 'mythic')
      // 强化到+100
      for (let i = 0; i < 100; i++) {
        const currentLevel = equip.enhanceLevel || 0
        Object.keys(equip.stats).forEach(stat => {
          if (typeof equip.stats[stat] === 'number') {
            equip.stats[stat] *= 1.1
            if (['critRate', 'critDamageBoost', 'dodgeRate', 'vampireRate', 'finalDamageBoost', 'finalDamageReduce'].includes(stat)) {
              equip.stats[stat] = Math.round(equip.stats[stat] * 100) / 100
            } else {
              equip.stats[stat] = Math.round(equip.stats[stat])
            }
          }
        })
        equip.enhanceLevel = (equip.enhanceLevel || 0) + 1
      }
      // 先加入背包再装备
      playerStore.gainItem(equip)
      playerStore.equipArtifact(equip, slot)
      logs.push(`⚔️ ${equip.name} [仙品+100] → ${equipmentTypes[slot].name}`)
    })

    playerStore.saveData()
    maxGearLog.value = logs.join('\n')
    message.success('一键满配完成！13件仙品+100装备已穿戴')
  } catch (e) {
    message.error('满配失败：' + e.message)
  } finally {
    maxGearLoading.value = false
  }
}

const clearAllEquipments = () => {
  // 卸下所有装备
  Object.keys(equipmentTypes).forEach(slot => {
    if (playerStore.equippedArtifacts[slot]) {
      playerStore.unequipArtifact(slot)
    }
  })
  // 清空背包里的装备（保留pill和pet）
  playerStore.items = playerStore.items.filter(i => i.type === 'pill' || i.type === 'pet')
  playerStore.saveData()
  message.success('已清空所有装备')
}

// ========== 装备空投 ==========
const equipmentQualities = {
  common: { name: '凡品', color: '#9e9e9e', statMod: 1.0, maxStatMod: 1.5 },
  uncommon: { name: '下品', color: '#4caf50', statMod: 1.2, maxStatMod: 2.0 },
  rare: { name: '中品', color: '#2196f3', statMod: 1.5, maxStatMod: 2.5 },
  epic: { name: '上品', color: '#9c27b0', statMod: 2.0, maxStatMod: 3.0 },
  legendary: { name: '极品', color: '#ff9800', statMod: 2.5, maxStatMod: 3.5 },
  mythic: { name: '仙品', color: '#e91e63', statMod: 3.0, maxStatMod: 4.0 }
}

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

const equipmentBaseStats = {
  weapon: { attack: { min: 10, max: 20 }, critRate: { min: 0.05, max: 0.1 }, critDamageBoost: { min: 0.1, max: 0.3 } },
  head: { defense: { min: 5, max: 10 }, health: { min: 50, max: 100 }, stunResist: { min: 0.05, max: 0.1 } },
  body: { defense: { min: 8, max: 15 }, health: { min: 80, max: 150 }, finalDamageReduce: { min: 0.05, max: 0.1 } },
  legs: { defense: { min: 6, max: 12 }, speed: { min: 5, max: 10 }, dodgeRate: { min: 0.05, max: 0.1 } },
  feet: { defense: { min: 4, max: 8 }, speed: { min: 8, max: 15 }, dodgeRate: { min: 0.05, max: 0.1 } },
  shoulder: { defense: { min: 5, max: 10 }, health: { min: 40, max: 80 }, counterRate: { min: 0.05, max: 0.1 } },
  hands: { attack: { min: 5, max: 10 }, critRate: { min: 0.03, max: 0.08 }, comboRate: { min: 0.05, max: 0.1 } },
  wrist: { defense: { min: 3, max: 8 }, counterRate: { min: 0.05, max: 0.1 }, vampireRate: { min: 0.05, max: 0.1 } },
  necklace: { health: { min: 60, max: 120 }, healBoost: { min: 0.1, max: 0.2 }, spiritRate: { min: 0.1, max: 0.2 } },
  ring1: { attack: { min: 5, max: 10 }, critDamageBoost: { min: 0.1, max: 0.2 }, finalDamageBoost: { min: 0.05, max: 0.1 } },
  ring2: { defense: { min: 5, max: 10 }, critDamageReduce: { min: 0.1, max: 0.2 }, resistanceBoost: { min: 0.05, max: 0.1 } },
  belt: { health: { min: 40, max: 80 }, defense: { min: 4, max: 8 }, combatBoost: { min: 0.05, max: 0.1 } },
  artifact: { attack: { min: 0.1, max: 0.3 }, critRate: { min: 0.1, max: 0.3 }, comboRate: { min: 0.1, max: 0.3 } }
}

const generateEquipment = (level, type, quality) => {
  const qualityMod = equipmentQualities[quality].statMod
  const levelMod = 1 + level * 0.1
  const baseStats = {}
  Object.entries(equipmentBaseStats[type]).forEach(([stat, config]) => {
    const base = config.min + Math.random() * (config.max - config.min)
    const value = base * qualityMod * levelMod
    if (['critRate', 'critDamageBoost', 'dodgeRate', 'vampireRate', 'finalDamageBoost', 'finalDamageReduce'].includes(stat)) {
      baseStats[stat] = Math.round(value * 1) / 100
    } else {
      baseStats[stat] = Math.round(value)
    }
  })
  const typeInfo = equipmentTypes[type]
  const prefix = typeInfo.prefixes[Math.floor(Math.random() * typeInfo.prefixes.length)]
  const suffixes = ['', '·真', '·极', '·道', '·天', '·仙', '·圣', '·神']
  const suffix = quality === 'mythic' ? suffixes[7] : quality === 'legendary' ? suffixes[6] : quality === 'epic' ? suffixes[5] : quality === 'rare' ? suffixes[4] : quality === 'uncommon' ? suffixes[3] : suffixes[0]
  const name = `${prefix}${typeInfo.name}${suffix}`
  return {
    id: Date.now() + Math.random(),
    name, type, slot: type, quality, level, requiredRealm: level,
    stats: baseStats, equipType: type, qualityInfo: equipmentQualities[quality]
  }
}

const equipForm = ref({ type: 'weapon', quality: 'common', count: 1 })
const equipTypeOptions = Object.entries(equipmentTypes).map(([k, v]) => ({ label: v.name, value: k }))
const equipQualityOptions = Object.entries(equipmentQualities).map(([k, v]) => ({ label: v.name, value: k }))

const airdropEquipment = async () => {
  const { type, quality, count } = equipForm.value
  if (authStore.isLoggedIn) {
    for (let i = 0; i < count; i++) {
      await playerStore.generateEquipmentOnServer(playerStore.level, type, quality)
    }
  } else {
    for (let i = 0; i < count; i++) {
      const equip = generateEquipment(playerStore.level, type, quality)
      playerStore.gainItem(equip)
    }
  }
  message.success(`成功空投 ${count} 件 ${equipmentQualities[quality].name} ${equipmentTypes[type].name}`)
}

// ========== 焰草空投 ==========
const herbForm = ref({ id: 'spirit_grass', quality: 'common', count: 1 })
const herbOptions = herbs.map(h => ({ label: h.name, value: h.id }))
const herbQualityOptions = Object.entries(herbQualities).map(([k, v]) => ({ label: v.name, value: k }))

const airdropHerb = async () => {
  const { id, quality, count } = herbForm.value
  const herbInfo = herbs.find(h => h.id === id)
  if (!herbInfo) return message.error('焰草不存在')
  if (authStore.isLoggedIn) {
    for (let i = 0; i < count; i++) {
      await playerStore.addHerbOnServer(herbInfo.id, herbInfo.name, quality, getHerbValue(herbInfo, quality))
    }
  } else {
    for (let i = 0; i < count; i++) {
      playerStore.herbs.push({ ...herbInfo, quality, value: getHerbValue(herbInfo, quality) })
    }
    playerStore.saveData()
  }
  message.success(`成功空投 ${count} 株 ${herbQualities[quality].name} ${herbInfo.name}`)
}

// ========== 焰丹空投 ==========
const pillForm = ref({ id: pillRecipes[0]?.id || '', count: 1 })
const pillOptions = pillRecipes.map(r => ({ label: `${r.name}（${r.description}）`, value: r.id }))

const airdropPill = async () => {
  const { id, count } = pillForm.value
  const recipe = pillRecipes.find(r => r.id === id)
  if (!recipe) return message.error('焰丹不存在')
  const effect = calculatePillEffect(recipe, playerStore.level)
  if (authStore.isLoggedIn) {
    for (let i = 0; i < count; i++) {
      await playerStore.addPillOnServer(recipe.id, recipe.name, recipe.description, { type: effect.type, value: effect.value, duration: effect.duration })
    }
  } else {
    for (let i = 0; i < count; i++) {
      playerStore.gainItem({
        id: `${recipe.id}_${Date.now()}_${Math.random()}`,
        name: recipe.name, description: recipe.description, type: 'pill',
        effect: { type: effect.type, value: effect.value, duration: effect.duration }
      })
    }
  }
  message.success(`成功空投 ${count} 颗 ${recipe.name}`)
}

// ========== 焰兽空投 ==========
const petPool = {
  divine: [
    { name: '玄武', description: '北方守护神兽' }, { name: '白虎', description: '西方守护神兽' },
    { name: '朱雀', description: '南方守护神兽' }, { name: '青龙', description: '东方守护神兽' },
    { name: '应龙', description: '上古神龙' }, { name: '麒麟', description: '祥瑞之兽' },
    { name: '饕餮', description: '贪婪之兽' }, { name: '穷奇', description: '邪恶之兽' },
    { name: '梼杌', description: '凶暴之兽' }, { name: '混沌', description: '无序之兽' }
  ],
  celestial: [
    { name: '囚牛' }, { name: '睚眦' }, { name: '嘲风' }, { name: '蒲牢' },
    { name: '狻犴' }, { name: '霸下' }, { name: '狴犴' }, { name: '负屃' }, { name: '螭吻' }
  ],
  mystic: [{ name: '火凤凰' }, { name: '雷鹰' }, { name: '冰狼' }, { name: '岩龟' }],
  spiritual: [{ name: '玄龟' }, { name: '风隼' }, { name: '地甲' }, { name: '云豹' }],
  mortal: [{ name: '灵猫' }, { name: '幻蝶' }]
}

const petBaseStats = { divine: 100, celestial: 80, mystic: 60, spiritual: 40, mortal: 20 }
const petRarityOptions = [
  { label: '神品', value: 'divine' }, { label: '仙品', value: 'celestial' },
  { label: '玄品', value: 'mystic' }, { label: '灵品', value: 'spiritual' }, { label: '凡品', value: 'mortal' }
]

const petForm = ref({ rarity: 'divine', name: null, count: 1 })
const petNameOptions = computed(() => {
  const pool = petPool[petForm.value.rarity] || []
  return pool.map(p => ({ label: p.name, value: p.name }))
})
const onPetRarityChange = () => { petForm.value.name = null }

const generatePet = (rarity, petInfo) => {
  const base = petBaseStats[rarity]
  return {
    id: Date.now() + Math.random(), name: petInfo.name,
    description: petInfo.description || '', type: 'pet', rarity, level: 1, star: 0,
    combatAttributes: {
      attack: base, health: base * 10, defense: base, speed: base,
      critRate: 0, comboRate: 0, counterRate: 0, stunRate: 0, dodgeRate: 0, vampireRate: 0,
      critResist: 0, comboResist: 0, counterResist: 0, stunResist: 0, dodgeResist: 0, vampireResist: 0,
      healBoost: 0, critDamageBoost: 0, critDamageReduce: 0,
      finalDamageBoost: 0, finalDamageReduce: 0, combatBoost: 0, resistanceBoost: 0
    }
  }
}

const airdropPet = async () => {
  const { rarity, name, count } = petForm.value
  const pool = petPool[rarity]
  if (authStore.isLoggedIn) {
    for (let i = 0; i < count; i++) {
      const petInfo = name ? pool.find(p => p.name === name) : pool[Math.floor(Math.random() * pool.length)]
      await playerStore.generatePetOnServer(rarity, petInfo.name)
    }
  } else {
    for (let i = 0; i < count; i++) {
      const petInfo = name ? pool.find(p => p.name === name) : pool[Math.floor(Math.random() * pool.length)]
      playerStore.gainItem(generatePet(rarity, petInfo))
    }
  }
  const rarityLabel = petRarityOptions.find(o => o.value === rarity)?.label
  message.success(`成功空投 ${count} 只 ${rarityLabel} 焰兽${name ? '（' + name + '）' : '（随机）'}`)
}
</script>

<style scoped></style>
