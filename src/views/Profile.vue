<template>
  <div class="profile-page">
    <game-guide>
      <p>📋 查看角色<strong>属性、战力、境界</strong>等详细信息</p>
      <p>✏️ 可修改<strong>道号</strong>（焰名）</p>
      <p>💪 战力公式：攻击×4 + 生命×0.5 + 防御×3 + 速度×2 + 战斗属性×500 + 等级×100</p>
    </game-guide>
    <n-card>
      <n-space vertical>
        <div class="profile-realm-row">
          <img :src="realmIcon" class="profile-realm-icon" loading="lazy" />
          <div class="profile-realm-info">
            <span class="profile-realm-name">{{ realmName }}</span>
            <span class="profile-player-name">{{ playerStore.name || '无名焰修' }}</span>
          </div>
        </div>
        <n-descriptions bordered>
          <n-descriptions-item label="焰名">{{ playerStore.name || '无名焰修' }}</n-descriptions-item>
          <n-descriptions-item label="焰阶">{{ realmName }}</n-descriptions-item>
          <n-descriptions-item label="焰力">{{ playerStore.cultivation || 0 }} / {{ playerStore.maxCultivation || 100 }}</n-descriptions-item>
          <n-descriptions-item label="焰灵">{{ (Number(playerStore.spirit) || 0).toFixed(2) }}</n-descriptions-item>
          <n-descriptions-item label="焰晶">{{ playerStore.spiritStones || 0 }}</n-descriptions-item>
          <n-descriptions-item label="淬火石">{{ playerStore.reinforceStones || 0 }}</n-descriptions-item>
        </n-descriptions>
        <n-progress
          type="line"
          :percentage="cultivationPct"
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
        <n-descriptions-item label="生命值">{{ safeNum(totalStats, 'health') }}</n-descriptions-item>
        <n-descriptions-item label="攻击力">{{ safeNum(totalStats, 'attack') }}</n-descriptions-item>
        <n-descriptions-item label="防御力">{{ safeNum(totalStats, 'defense') }}</n-descriptions-item>
        <n-descriptions-item label="速度">{{ safeNum(totalStats, 'speed') }}</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="暴击率">{{ safePct(totalStats, 'critRate') }}</n-descriptions-item>
        <n-descriptions-item label="连击率">{{ safePct(totalStats, 'comboRate') }}</n-descriptions-item>
        <n-descriptions-item label="反击率">{{ safePct(totalStats, 'counterRate') }}</n-descriptions-item>
        <n-descriptions-item label="眩晕率">{{ safePct(totalStats, 'stunRate') }}</n-descriptions-item>
        <n-descriptions-item label="闪避率">{{ safePct(totalStats, 'dodgeRate') }}</n-descriptions-item>
        <n-descriptions-item label="吸血率">{{ safePct(totalStats, 'vampireRate') }}</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="抗暴击">{{ safePct(totalStats, 'critResist') }}</n-descriptions-item>
        <n-descriptions-item label="抗连击">{{ safePct(totalStats, 'comboResist') }}</n-descriptions-item>
        <n-descriptions-item label="抗反击">{{ safePct(totalStats, 'counterResist') }}</n-descriptions-item>
        <n-descriptions-item label="抗眩晕">{{ safePct(totalStats, 'stunResist') }}</n-descriptions-item>
        <n-descriptions-item label="抗闪避">{{ safePct(totalStats, 'dodgeResist') }}</n-descriptions-item>
        <n-descriptions-item label="抗吸血">{{ safePct(totalStats, 'vampireResist') }}</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <n-card style="margin-top:12px">
      <n-descriptions bordered :column="2">
        <n-descriptions-item label="强化治疗">{{ safePct(totalStats, 'healBoost') }}</n-descriptions-item>
        <n-descriptions-item label="强化爆伤">{{ safePct(totalStats, 'critDamageBoost') }}</n-descriptions-item>
        <n-descriptions-item label="弱化爆伤">{{ safePct(totalStats, 'critDamageReduce') }}</n-descriptions-item>
        <n-descriptions-item label="最终增伤">{{ safePct(totalStats, 'finalDamageBoost') }}</n-descriptions-item>
        <n-descriptions-item label="最终减伤">{{ safePct(totalStats, 'finalDamageReduce') }}</n-descriptions-item>
        <n-descriptions-item label="战斗属性提升">{{ safePct(totalStats, 'combatBoost') }}</n-descriptions-item>
        <n-descriptions-item label="战斗抗性提升">{{ safePct(totalStats, 'resistanceBoost') }}</n-descriptions-item>
      </n-descriptions>
    </n-card>
  </div>
</template>

<script setup>
import { usePlayerStore } from '../stores/player'
import { getRealmName, getRealmImage } from '../plugins/realm'
import { computed } from 'vue'
import GameGuide from '../components/GameGuide.vue'

const playerStore = usePlayerStore()

const realmIcon = computed(function () {
  return getRealmImage(playerStore.level)
})

const realmName = computed(function () {
  var info = getRealmName(playerStore.level)
  return info && info.name ? info.name : '燃火一重'
})

const cultivationPct = computed(function () {
  var c = Number(playerStore.cultivation) || 0
  var m = Number(playerStore.maxCultivation) || 1
  return Number(((c / m) * 100).toFixed(2))
})
const totalStats = computed(() => playerStore.getTotalStats())

function safeNum(obj, key) {
  if (!obj) return '0'
  var v = Number(obj[key])
  if (isNaN(v)) return '0'
  return v.toFixed(0)
}

function safePct(obj, key) {
  if (!obj) return '0.0%'
  var v = Number(obj[key])
  if (isNaN(v)) return '0.0%'
  return (v * 100).toFixed(1) + '%'
}
</script>

<style scoped>
.profile-page {
  padding: 0;
}
.profile-realm-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding: 10px;
  background: rgba(212,168,67,0.06);
  border: 1px solid rgba(212,168,67,0.15);
  border-radius: 10px;
}
.profile-realm-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  border: 2px solid rgba(212,168,67,0.5);
  box-shadow: 0 0 10px rgba(212,168,67,0.3);
  object-fit: cover;
}
.profile-realm-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.profile-realm-name {
  font-size: 16px;
  font-weight: bold;
  color: #f0d68a;
  text-shadow: 0 0 8px rgba(212,168,67,0.4);
  font-family: 'Noto Serif SC', serif;
}
.profile-player-name {
  font-size: 13px;
  color: #a09880;
}
</style>
