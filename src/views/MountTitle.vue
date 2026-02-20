<template>
      <n-tabs type="line" v-model:value="activeTab" animated>
        <!-- 焰骑 Tab -->
        <n-tab-pane name="mount" tab="🐎 焰骑">
          <!-- 当前焰骑展示 -->
          <div v-if="activeMount" class="active-mount-card" :class="'quality-' + activeMount.quality">
            <div class="mount-emoji">{{ activeMount.emoji }}</div>
            <div class="mount-info">
              <div class="mount-name">
                {{ activeMount.name }}
                <span class="quality-tag" :class="'qt-' + activeMount.quality">{{ qualityNames[activeMount.quality] }}</span>
              </div>
              <div class="mount-bonuses">
                <span v-if="activeMount.attack_bonus">⚔️攻击+{{ (activeMount.attack_bonus*100).toFixed(0) }}%</span>
                <span v-if="activeMount.defense_bonus">🛡️防御+{{ (activeMount.defense_bonus*100).toFixed(0) }}%</span>
                <span v-if="activeMount.health_bonus">❤️生命+{{ (activeMount.health_bonus*100).toFixed(0) }}%</span>
                <span v-if="activeMount.speed_bonus">💨速度+{{ (activeMount.speed_bonus*100).toFixed(0) }}%</span>
              </div>
              <div class="mount-effect">✨ {{ activeMount.special_effect }}</div>
            </div>
            <n-button type="error" size="small" @click="deactivateMount">卸下</n-button>
          </div>
          <div v-else class="empty-active">🐾 尚未装备焰骑</div>

          <n-divider>焰骑图鉴</n-divider>
          <div class="mount-grid">
            <div v-for="m in allMounts" :key="m.id"
              class="mount-card" :class="[m.owned ? 'quality-' + m.quality : 'locked', activeMountId === m.id ? 'card-active' : '']">
              <div class="mount-card-emoji" :class="{grayscale: !m.owned}">{{ m.emoji }}</div>
              <div class="mount-card-name">{{ m.name }}</div>
              <span class="quality-tag" :class="'qt-' + m.quality">{{ qualityNames[m.quality] }}</span>
              <div v-if="!m.owned" class="lock-overlay">
                <span class="lock-icon">🔒</span>
                <div class="obtain-hint">{{ m.obtain_method }}</div>
                <n-button v-if="canBuy(m)" type="warning" size="tiny" @click="buyMount(m)" :loading="buying">
                  {{ m.name === '白鹤' ? '免费领取' : '💎 ' + getMountPrice(m) + '焰晶' }}
                </n-button>
              </div>
              <div v-else class="owned-actions">
                <n-button v-if="activeMountId !== m.id" type="primary" size="tiny" @click="activateMount(m)">骑乘</n-button>
                <n-tag v-else type="success" size="small">骑乘中</n-tag>
              </div>
            </div>
          </div>
        </n-tab-pane>

        <!-- 焰号 Tab -->
        <n-tab-pane name="title" tab="👑 焰号">
          <!-- 当前焰号展示 -->
          <div v-if="activeTitle" class="active-title-card" :class="'quality-' + activeTitle.quality">
            <div class="title-display" :style="{color: activeTitle.color, textShadow: '0 0 10px ' + activeTitle.color + '88'}">
              {{ activeTitle.name }}
            </div>
            <div class="title-desc">{{ activeTitle.description }}</div>
            <div class="mount-bonuses">
              <span v-if="activeTitle.attack_bonus">⚔️攻击+{{ (activeTitle.attack_bonus*100).toFixed(0) }}%</span>
              <span v-if="activeTitle.defense_bonus">🛡️防御+{{ (activeTitle.defense_bonus*100).toFixed(0) }}%</span>
              <span v-if="activeTitle.health_bonus">❤️生命+{{ (activeTitle.health_bonus*100).toFixed(0) }}%</span>
            </div>
            <n-button type="error" size="small" @click="deactivateTitle">卸下</n-button>
          </div>
          <div v-else class="empty-active">👑 尚未佩戴焰号</div>

          <n-divider>
            <n-button type="info" size="small" @click="checkTitles" :loading="checking">🔍 检查新焰号</n-button>
          </n-divider>

          <div class="title-list">
            <div v-for="t in allTitles" :key="t.id"
              class="title-card" :class="[t.unlocked ? 'quality-' + t.quality : 'locked', activeTitleId === t.id ? 'card-active' : '']">
              <div class="title-card-header">
                <span class="title-card-name" :style="t.unlocked ? {color: t.color, textShadow: '0 0 6px ' + t.color + '66'} : {}">
                  {{ t.name }}
                </span>
                <span class="quality-tag" :class="'qt-' + t.quality">{{ qualityNames[t.quality] }}</span>
              </div>
              <div class="title-card-desc">{{ t.description }}</div>
              <div v-if="t.attack_bonus || t.defense_bonus || t.health_bonus" class="title-card-bonus">
                <span v-if="t.attack_bonus">⚔️+{{ (t.attack_bonus*100).toFixed(0) }}%</span>
                <span v-if="t.defense_bonus">🛡️+{{ (t.defense_bonus*100).toFixed(0) }}%</span>
                <span v-if="t.health_bonus">❤️+{{ (t.health_bonus*100).toFixed(0) }}%</span>
              </div>
              <div v-if="!t.unlocked" class="title-progress">
                <div class="progress-label">{{ conditionLabels[t.condition_type] }}: {{ t.current }} / {{ t.condition_value }}</div>
                <n-progress :percentage="t.progress" :show-indicator="false" :height="8"
                  :color="t.progress >= 100 ? '#4caf50' : '#ffd700'" rail-color="rgba(255,255,255,0.1)" />
              </div>
              <div v-else class="title-card-actions">
                <n-button v-if="activeTitleId !== t.id" type="primary" size="tiny" @click="activateTitle(t)">佩戴</n-button>
                <n-tag v-else type="success" size="small">佩戴中</n-tag>
              </div>
            </div>
          </div>
        </n-tab-pane>
      </n-tabs>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'
import { createDiscreteApi } from 'naive-ui'

const { message: msg } = createDiscreteApi(['message'])
const authStore = useAuthStore()
const playerStore = usePlayerStore()

const activeTab = ref('mount')
const allMounts = ref([])
const myMounts = ref([])
const activeMount = ref(null)
const allTitles = ref([])
const myTitles = ref([])
const activeTitle = ref(null)
const buying = ref(false)
const checking = ref(false)

const qualityNames = { common: '凡品', rare: '灵品', epic: '仙品', legendary: '神品', mythic: '神话' }
const conditionLabels = { level: '焰阶等级', kills: '击杀数', dungeon_floor: '焚天塔层数', spirit_stones: '焰晶', friends: '焰友数', contribution: '焰盟贡献', boss_kill: 'Boss击杀' }

const activeMountId = computed(() => activeMount.value?.mount_id || null)
const activeTitleId = computed(() => activeTitle.value?.title_id || null)

function canBuy(m) { return m.name === '白鹤' || m.name === '赤焰马' }
function getMountPrice(m) { return m.name === '赤焰马' ? 10000 : 0 }

function syncMountBonus(m) {
  playerStore.activeMountBonus = m
    ? { attack_bonus: m.attack_bonus || 0, defense_bonus: m.defense_bonus || 0, health_bonus: m.health_bonus || 0, speed_bonus: m.speed_bonus || 0 }
    : { attack_bonus: 0, defense_bonus: 0, health_bonus: 0, speed_bonus: 0 }
}
function syncTitleBonus(t) {
  playerStore.activeTitleBonus = t
    ? { attack_bonus: t.attack_bonus || 0, defense_bonus: t.defense_bonus || 0, health_bonus: t.health_bonus || 0, speed_bonus: t.speed_bonus || 0 }
    : { attack_bonus: 0, defense_bonus: 0, health_bonus: 0, speed_bonus: 0 }
}

async function loadMounts() {
  try {
    const [listRes, activeRes] = await Promise.all([
      authStore.apiGet('/mount/list'),
      authStore.apiGet('/mount/active')
    ])
    allMounts.value = listRes.mounts
    activeMount.value = activeRes.mount
    syncMountBonus(activeMount.value)
    const myRes = await authStore.apiGet('/mount/my')
    myMounts.value = myRes.mounts
  } catch (e) { msg.error(e.message) }
}

async function loadTitles() {
  try {
    const [listRes, myRes] = await Promise.all([
      authStore.apiGet('/title/list'),
      authStore.apiGet('/title/my')
    ])
    allTitles.value = listRes.titles
    myTitles.value = myRes.titles
    activeTitle.value = myTitles.value.find(t => t.is_active) || null
    syncTitleBonus(activeTitle.value)
  } catch (e) { msg.error(e.message) }
}

async function buyMount(m) {
  buying.value = true
  try {
    const res = await authStore.apiPost('/mount/buy', { mount_id: m.id })
    msg.success(res.message)
    await loadMounts()
  } catch (e) { msg.error(e.message) }
  buying.value = false
}

async function activateMount(m) {
  try {
    const pm = myMounts.value.find(pm => pm.mount_id === m.id)
    if (!pm) return msg.error('未拥有该焰骑')
    await authStore.apiPost('/mount/activate', { player_mount_id: pm.id })
    msg.success('骑乘成功')
    await loadMounts()
  } catch (e) { msg.error(e.message) }
}

async function deactivateMount() {
  try {
    await authStore.apiPost('/mount/deactivate', {})
    msg.success('已卸下焰骑')
    await loadMounts()
  } catch (e) { msg.error(e.message) }
}

async function checkTitles() {
  checking.value = true
  try {
    const res = await authStore.apiPost('/title/check', {})
    if (res.count > 0) {
      msg.success('解锁了 ' + res.count + ' 个新焰号！')
      res.newlyUnlocked.forEach(t => msg.info('🎉 获得焰号: ' + t.name))
    } else {
      msg.info('暂无新焰号可解锁')
    }
    await loadTitles()
  } catch (e) { msg.error(e.message) }
  checking.value = false
}

async function activateTitle(t) {
  try {
    const pt = myTitles.value.find(pt => pt.title_id === t.id)
    if (!pt) return msg.error('未解锁该焰号')
    await authStore.apiPost('/title/activate', { player_title_id: pt.id })
    msg.success('佩戴成功')
    await loadTitles()
  } catch (e) { msg.error(e.message) }
}

async function deactivateTitle() {
  try {
    await authStore.apiPost('/title/deactivate', {})
    msg.success('已卸下焰号')
    await loadTitles()
  } catch (e) { msg.error(e.message) }
}

onMounted(() => { loadMounts(); loadTitles() })
</script>

<style scoped>
.active-mount-card, .active-title-card {
  display: flex; align-items: center; gap: 16px; padding: 16px;
  border-radius: 12px; background: rgba(0,0,0,0.4); margin-bottom: 12px;
}
.mount-emoji { font-size: 64px; line-height: 1; }
.mount-info { flex: 1; }
.mount-name { font-size: 18px; font-weight: bold; color: #ffd700; margin-bottom: 6px; }
.mount-bonuses { display: flex; flex-wrap: wrap; gap: 8px; font-size: 13px; color: #aaa; margin-bottom: 4px; }
.mount-bonuses span { background: rgba(255,215,0,0.1); padding: 2px 8px; border-radius: 4px; }
.mount-effect { font-size: 13px; color: #e0c068; }
.title-display { font-size: 24px; font-weight: bold; flex: 1; }
.title-desc { font-size: 13px; color: #aaa; margin-top: 4px; }
.empty-active { text-align: center; padding: 24px; color: #666; font-size: 15px; background: rgba(0,0,0,0.3); border-radius: 12px; margin-bottom: 12px; border: 1px dashed #333; }

.mount-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.mount-card { position: relative; text-align: center; padding: 16px 8px; border-radius: 10px; background: rgba(0,0,0,0.3); border: 1.5px solid #333; transition: all 0.3s; }
.mount-card:hover { transform: translateY(-2px); }
.mount-card-emoji { font-size: 40px; line-height: 1; margin-bottom: 6px; }
.mount-card-name { font-size: 14px; font-weight: 600; color: #ddd; margin-bottom: 4px; }
.grayscale { filter: grayscale(1) opacity(0.5); }
.locked { border-color: #444 !important; background: rgba(0,0,0,0.5) !important; }
.lock-overlay { margin-top: 8px; }
.lock-icon { font-size: 20px; }
.obtain-hint { font-size: 11px; color: #888; margin: 4px 0; }
.owned-actions { margin-top: 8px; }
.card-active { box-shadow: 0 0 15px rgba(255,215,0,0.5) !important; border-color: #ffd700 !important; }

.title-list { display: flex; flex-direction: column; gap: 10px; }
.title-card { padding: 12px 16px; border-radius: 10px; background: rgba(0,0,0,0.3); border: 1.5px solid #333; transition: all 0.3s; }
.title-card:hover { transform: translateX(4px); }
.title-card-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.title-card-name { font-size: 16px; font-weight: bold; }
.title-card-desc { font-size: 12px; color: #888; margin-bottom: 6px; }
.title-card-bonus { display: flex; gap: 8px; font-size: 12px; color: #aaa; margin-bottom: 6px; }
.title-card-bonus span { background: rgba(255,215,0,0.1); padding: 1px 6px; border-radius: 4px; }
.title-card-actions { margin-top: 4px; }
.title-progress { margin-top: 6px; }
.progress-label { font-size: 11px; color: #888; margin-bottom: 4px; }

.quality-tag { display: inline-block; padding: 1px 8px; border-radius: 8px; font-size: 11px; font-weight: 600; }
.qt-common { background: rgba(136,136,136,0.2); color: #888; border: 1px solid #88888866; }
.qt-rare { background: rgba(33,150,243,0.2); color: #2196f3; border: 1px solid #2196f366; }
.qt-epic { background: rgba(156,39,176,0.2); color: #9c27b0; border: 1px solid #9c27b066; }
.qt-legendary { background: rgba(255,152,0,0.2); color: #ff9800; border: 1px solid #ff980066; }
.qt-mythic { background: rgba(244,67,54,0.2); color: #f44336; border: 1px solid #f4433666; animation: mythic-pulse 2s ease-in-out infinite; }

.quality-common { border: 1.5px solid #888 !important; box-shadow: 0 0 5px rgba(136,136,136,0.3); background: linear-gradient(135deg, rgba(136,136,136,0.08), transparent) !important; }
.quality-rare { border: 1.5px solid #2196f3 !important; box-shadow: 0 0 10px rgba(33,150,243,0.4); background: linear-gradient(135deg, rgba(33,150,243,0.1), transparent) !important; }
.quality-epic { border: 1.5px solid #9c27b0 !important; box-shadow: 0 0 12px rgba(156,39,176,0.5); background: linear-gradient(135deg, rgba(156,39,176,0.1), transparent) !important; }
.quality-legendary { border: 1.5px solid #ff9800 !important; box-shadow: 0 0 15px rgba(255,152,0,0.5); background: linear-gradient(135deg, rgba(255,152,0,0.12), transparent) !important; }
.quality-mythic { border: 1.5px solid #f44336 !important; box-shadow: 0 0 18px rgba(244,67,54,0.6); background: linear-gradient(135deg, rgba(244,67,54,0.12), transparent) !important; animation: mythic-glow 2s ease-in-out infinite; }

@keyframes mythic-glow {
  0%, 100% { box-shadow: 0 0 18px rgba(244,67,54,0.6); }
  50% { box-shadow: 0 0 30px rgba(244,67,54,0.9), 0 0 60px rgba(244,67,54,0.3); }
}
@keyframes mythic-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

@media (max-width: 600px) {
  .mount-grid { grid-template-columns: repeat(2, 1fr); }
  .active-mount-card, .active-title-card { flex-direction: column; text-align: center; }
}
</style>
