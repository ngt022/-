<template>
  <div class="profile-page">
    <n-card>
      <n-space vertical>
        <n-descriptions bordered>
          <n-descriptions-item label="焰名">{{ playerStore.name }}</n-descriptions-item>
          <n-descriptions-item label="焰阶">{{ getRealmName(playerStore.level).name }}</n-descriptions-item>
          <n-descriptions-item label="焰力">{{ playerStore.cultivation }} / {{ playerStore.maxCultivation }}</n-descriptions-item>
          <n-descriptions-item label="焰灵">{{ playerStore.spirit.toFixed(2) }}</n-descriptions-item>
          <n-descriptions-item label="焰晶">{{ playerStore.spiritStones }}</n-descriptions-item>
          <n-descriptions-item label="淬火石">{{ playerStore.reinforceStones }}</n-descriptions-item>
        </n-descriptions>
        <n-progress
          type="line"
          :percentage="Number(((playerStore.cultivation / playerStore.maxCultivation) * 100).toFixed(2))"
          indicator-text-color="rgba(255, 255, 255, 0.82)"
          rail-color="rgba(32, 128, 240, 0.2)"
          color="#2080f0"
          :show-indicator="true"
          indicator-placement="inside"
          processing
        />
      </n-space>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="生命值">{{ (playerStore.baseAttributes.health || 0).toFixed(0) }}</n-descriptions-item>
        <n-descriptions-item label="攻击力">{{ (playerStore.baseAttributes.attack || 0).toFixed(0) }}</n-descriptions-item>
        <n-descriptions-item label="防御力">{{ (playerStore.baseAttributes.defense || 0).toFixed(0) }}</n-descriptions-item>
        <n-descriptions-item label="速度">{{ (playerStore.baseAttributes.speed || 0).toFixed(0) }}</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="暴击率">{{ (playerStore.combatAttributes.critRate * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="连击率">{{ (playerStore.combatAttributes.comboRate * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="反击率">{{ (playerStore.combatAttributes.counterRate * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="眩晕率">{{ (playerStore.combatAttributes.stunRate * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="闪避率">{{ (playerStore.combatAttributes.dodgeRate * 100).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="吸血率">{{ (playerStore.combatAttributes.vampireRate * 100).toFixed(1) }}%</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="抗暴击">{{ (playerStore.combatResistance.critResist * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="抗连击">{{ (playerStore.combatResistance.comboResist * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="抗反击">{{ (playerStore.combatResistance.counterResist * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="抗眩晕">{{ (playerStore.combatResistance.stunResist * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="抗闪避">{{ (playerStore.combatResistance.dodgeResist * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="抗吸血">{{ (playerStore.combatResistance.vampireResist * 100 || 0).toFixed(1) }}%</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="强化治疗">{{ (playerStore.specialAttributes.healBoost * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="强化爆伤">{{ (playerStore.specialAttributes.critDamageBoost * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="弱化爆伤">{{ (playerStore.specialAttributes.critDamageReduce * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="最终增伤">{{ (playerStore.specialAttributes.finalDamageBoost * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="最终减伤">{{ (playerStore.specialAttributes.finalDamageReduce * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="战斗属性提升">{{ (playerStore.specialAttributes.combatBoost * 100 || 0).toFixed(1) }}%</n-descriptions-item>
        <n-descriptions-item label="战斗抗性提升">{{ (playerStore.specialAttributes.resistanceBoost * 100 || 0).toFixed(1) }}%</n-descriptions-item>
      </n-descriptions>
    </n-card>
  </div>
</template>

<script setup>
import { usePlayerStore } from '../stores/player'
import { getRealmName } from '../plugins/realm'
const playerStore = usePlayerStore()
</script>
