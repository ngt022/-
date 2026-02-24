<template>
      <n-spin :show="loading">
        <game-guide>
          <p>🏯 创建焰盟需<strong>50,000焰晶</strong>，或搜索加入已有焰盟</p>
          <p>📈 焰盟有等级系统，等级越高加成越强</p>
          <p>🎁 完成焰盟任务获得<strong>贡献度+焰晶</strong></p>
          <p>💰 捐献焰晶：每10焰晶=1贡献度，焰晶转为焰盟经验</p>
          <p>👑 职位：盟主→焰长→盟士，不同权限</p>
        </game-guide>
        <!-- 未加入焰盟 -->
        <div v-if="!mySect">
          <n-space vertical :size="16">
            <n-card title="🏯 创建焰盟" class="gold-card">
              <n-form :model="createForm" label-placement="left" label-width="80">
                <n-form-item label="焰盟名">
                  <n-input v-model:value="createForm.name" placeholder="2-20字" maxlength="20" />
                </n-form-item>
                <n-form-item label="简介">
                  <n-input v-model:value="createForm.description" type="textarea" placeholder="焰盟简介(可选)" maxlength="100" />
                </n-form-item>
                <n-form-item>
                  <n-button type="warning" @click="createSect" :loading="creating">
                    创建焰盟 (消耗 50000 焰晶)
                  </n-button>
                </n-form-item>
              </n-form>
            </n-card>
            <n-card title="📜 焰盟列表" class="gold-card">
              <template #header-extra>
                <n-input v-model:value="searchKey" placeholder="搜索焰盟" size="small" style="width:160px" clearable @update:value="loadSectList" />
                <GuideTooltip v-if="showGuide" v-bind="guideTexts.sect || {}" @dismiss="dismissGuide" />
</template>
              <n-data-table :columns="listColumns" :data="sectList" :bordered="false" size="small" :loading="listLoading" />
            </n-card>
          </n-space>
        </div>

        <!-- 已加入焰盟 -->
        <div v-else>
          <n-space vertical :size="16">
            <!-- 焰盟信息 -->
            <n-card class="gold-card">
              <template #header>
                <n-space align="center">
                  <span style="font-size:20px">🏯</span>
                  <span class="sect-name">{{ mySect.name }}</span>
                  <n-tag type="warning" size="small">Lv.{{ mySect.level }}</n-tag>
                </n-space>
              </template>
              <n-space vertical :size="8">
                <div class="info-row">
                  <span class="label">经验:</span>
                  <n-progress type="line" :percentage="expPercent" :show-indicator="true" indicator-placement="inside" color="#d4a017" rail-color="#333" />
                  <span class="exp-text">{{ mySect.exp }} / {{ nextLevelExp }}</span>
                </div>
                <div class="info-row">
                  <span class="label">成员:</span>
                  <span>{{ members.length }} / {{ mySect.max_members }}</span>
                </div>
                <div class="info-row">
                  <span class="label">我的身份:</span>
                  <n-tag :type="roleTagType(myRole)" size="small">{{ roleLabel(myRole) }}</n-tag>
                </div>
                <div class="info-row">
                  <span class="label">我的贡献:</span>
                  <span style="color:#d4a017">{{ myContribution }}</span>
                </div>
                <n-divider style="margin:8px 0" />
                <div class="announcement-box">
                  <div class="label">📢 公告</div>
                  <div class="announcement-text">{{ mySect.announcement || '暂无公告' }}</div>
                </div>
              </n-space>
            </n-card>

            <!-- 焰盟任务 -->
            <n-card title="📋 焰盟任务" class="gold-card">
              <n-tabs type="segment" animated>
                <n-tab-pane name="daily" tab="每日任务">
                  <n-list bordered>
                    <n-list-item v-for="t in dailyTasks" :key="t.id">
                      <n-thing :title="t.title" :description="t.description">
                        <template #header-extra>
                          <n-tag v-if="isTaskDone(t)" type="success" size="small">已完成</n-tag>
                          <n-button v-else size="small" type="warning" @click="completeTask(t.id)">完成</n-button>
                        </template>
                      </n-thing>
                      <div class="task-reward">贡献+{{ t.reward_contribution }} 焰晶+{{ t.reward_stones }}</div>
                    </n-list-item>
                  </n-list>
                </n-tab-pane>
                <n-tab-pane name="weekly" tab="每周任务">
                  <n-list bordered>
                    <n-list-item v-for="t in weeklyTasks" :key="t.id">
                      <n-thing :title="t.title" :description="t.description">
                        <template #header-extra>
                          <n-tag v-if="isTaskDone(t)" type="success" size="small">已完成</n-tag>
                          <n-button v-else size="small" type="warning" @click="completeTask(t.id)">完成</n-button>
                        </template>
                      </n-thing>
                      <div class="task-reward">贡献+{{ t.reward_contribution }} 焰晶+{{ t.reward_stones }}</div>
                    </n-list-item>
                  </n-list>
                </n-tab-pane>
              </n-tabs>
            </n-card>

            <!-- 捐献焰晶 -->
            <n-card title="💰 捐献焰晶" class="gold-card">
              <n-space>
                <n-input-number v-model:value="donateAmount" :min="100" :step="1000" placeholder="最少100" style="width:180px" />
                <n-button type="warning" @click="donate" :loading="donating">捐献</n-button>
              </n-space>
              <div style="margin-top:8px;color:#888;font-size:12px">每10焰晶=1贡献度，焰晶全部转为焰盟经验</div>
            </n-card>

            <!-- 成员列表 -->
            <n-card title="👥 成员列表" class="gold-card">
              <n-data-table :columns="memberColumns" :data="members" :bordered="false" size="small" />
            </n-card>

            <!-- 管理功能 (盟主/焰长) -->
            <n-card v-if="myRole === 'leader' || myRole === 'elder'" title="⚙️ 管理" class="gold-card">
              <n-space vertical :size="12">
                <div v-if="myRole === 'leader' || myRole === 'elder'">
                  <div class="label" style="margin-bottom:4px">修改公告</div>
                  <n-space>
                    <n-input v-model:value="newAnnouncement" placeholder="新公告(最多200字)" maxlength="200" style="width:260px" />
                    <n-button type="warning" size="small" @click="updateAnnouncement">更新</n-button>
                  </n-space>
                </div>
              </n-space>
            </n-card>

            <!-- 退出焰盟 -->
            <n-card class="gold-card">
              <n-popconfirm @positive-click="leaveSect">
                <template #trigger>
                  <n-button type="error" ghost>退出焰盟</n-button>
                </template>
                确定退出焰盟？贡献度将清零！
              </n-popconfirm>
            </n-card>
          </n-space>
        </div>
      </n-spin>
</template>

<script setup>
import { hasSeenGuide, markGuideSeen, guideTexts } from "../utils/guide.js"
import GuideTooltip from "../components/GuideTooltip.vue"
import { ref, computed, onMounted, h } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'
import { NButton, NTag, createDiscreteApi } from 'naive-ui'
import GameGuide from '../components/GameGuide.vue'

const showGuide = ref(!hasSeenGuide("sect"))
const dismissGuide = () => { markGuideSeen("sect"); showGuide.value = false }
const authStore = useAuthStore()
const playerStore = usePlayerStore()
const { message } = createDiscreteApi(['message'])

const loading = ref(false)
const creating = ref(false)
const donating = ref(false)
const listLoading = ref(false)
const mySect = ref(null)
const myRole = ref('')
const myContribution = ref(0)
const members = ref([])
const tasks = ref([])
const sectList = ref([])
const searchKey = ref('')
const donateAmount = ref(1000)
const newAnnouncement = ref('')
const createForm = ref({ name: '', description: '' })

const LEVEL_EXP = [0, 1000, 3000, 8000, 20000, 50000, 100000, 200000, 500000, 1000000]

const nextLevelExp = computed(() => {
  if (!mySect.value) return 1000
  const lv = mySect.value.level || 1
  return lv >= 10 ? LEVEL_EXP[9] : LEVEL_EXP[lv]
})

const expPercent = computed(() => {
  if (!mySect.value) return 0
  return Math.min(100, Math.floor((mySect.value.exp / nextLevelExp.value) * 100))
})

const dailyTasks = computed(() => tasks.value.filter(t => t.type === 'daily'))
const weeklyTasks = computed(() => tasks.value.filter(t => t.type === 'weekly'))

function isTaskDone(task) {
  const cb = task.completed_by || []
  return cb.includes(authStore.wallet?.toLowerCase())
}

function roleLabel(r) {
  return r === 'leader' ? '盟主' : r === 'elder' ? '焰长' : '盟士'
}
function roleTagType(r) {
  return r === 'leader' ? 'warning' : r === 'elder' ? 'info' : 'default'
}

const api = async (method, url, body) => {
  const opts = { method, headers: { 'Authorization': `Bearer ${authStore.token}`, 'Content-Type': 'application/json' } }
  if (body) opts.body = JSON.stringify(body)
  const r = await fetch(`/api${url}`, opts)
  const data = await r.json()
  if (!r.ok) throw new Error(data.error || '请求失败')
  return data
}

async function loadMySect() {
  try {
    const data = await api('GET', '/sect/my')
    if (data.sect) {
      mySect.value = data.sect
      myRole.value = data.myRole
      myContribution.value = data.myContribution
      members.value = data.members || []
      newAnnouncement.value = data.sect.announcement || ''
      await loadTasks()
    } else {
      mySect.value = null
      await loadSectList()
    }
  } catch (e) { message.error(e.message) }
}

async function loadSectList() {
  listLoading.value = true
  try {
    const data = await api('GET', `/sect/list?search=${searchKey.value}&sort=level`)
    sectList.value = data.sects || []
  } catch (e) { message.error(e.message) }
  listLoading.value = false
}

async function loadTasks() {
  try {
    const data = await api('GET', '/sect/tasks')
    tasks.value = data.tasks || []
  } catch {}
}

async function createSect() {
  if (!createForm.value.name) return message.warning('请输入焰盟名称')
  creating.value = true
  try {
    await api('POST', '/sect/create', createForm.value)
    message.success('焰盟创建成功！')
    await loadMySect()
  } catch (e) { message.error(e.message) }
  creating.value = false
}

async function joinSect(sectId) {
  try {
    await api('POST', '/sect/join', { sectId })
    message.success('加入成功！')
    await loadMySect()
  } catch (e) { message.error(e.message) }
}

async function leaveSect() {
  try {
    await api('POST', '/sect/leave')
    message.success('已退出焰盟')
    mySect.value = null
    await loadSectList()
  } catch (e) { message.error(e.message) }
}

async function completeTask(taskId) {
  try {
    const data = await api('POST', `/sect/tasks/${taskId}/complete`)
    message.success(`任务完成！贡献+${data.reward_contribution} 焰晶+${data.reward_stones}`)
    if (data.reward_stones) playerStore.spiritStones += data.reward_stones
    await loadMySect()
  } catch (e) { message.error(e.message) }
}

async function donate() {
  if (!donateAmount.value || donateAmount.value < 100) return message.warning('最少捐献100焰晶')
  donating.value = true
  try {
    const data = await api('POST', '/sect/donate', { amount: donateAmount.value })
    message.success(`捐献成功！贡献+${data.contribution}`)
    playerStore.spiritStones -= donateAmount.value
    await loadMySect()
  } catch (e) { message.error(e.message) }
  donating.value = false
}

async function updateAnnouncement() {
  try {
    await api('POST', '/sect/announcement', { announcement: newAnnouncement.value })
    message.success('公告已更新')
    await loadMySect()
  } catch (e) { message.error(e.message) }
}

async function kickMember(wallet) {
  try {
    await api('POST', '/sect/kick', { wallet })
    message.success('已踢出')
    await loadMySect()
  } catch (e) { message.error(e.message) }
}

async function promoteMember(wallet) {
  try {
    await api('POST', '/sect/promote', { wallet })
    message.success('已升为焰长')
    await loadMySect()
  } catch (e) { message.error(e.message) }
}

async function demoteMember(wallet) {
  try {
    await api('POST', '/sect/demote', { wallet })
    message.success('已降为盟士')
    await loadMySect()
  } catch (e) { message.error(e.message) }
}

const listColumns = [
  { title: '焰盟', key: 'name' },
  { title: '等级', key: 'level', width: 60, render: r => h(NTag, { type: 'warning', size: 'small' }, () => `Lv.${r.level}`) },
  { title: '成员', key: 'member_count', width: 70, render: r => `${r.member_count}/${r.max_members}` },
  { title: '操作', key: 'action', width: 80, render: r => h(NButton, { size: 'tiny', type: 'warning', onClick: () => joinSect(r.id) }, () => '加入') }
]

const memberColumns = computed(() => {
  const cols = [
    { title: '焰名', key: 'name', render: r => r.name || '无名焰修' },
    { title: '身份', key: 'role', width: 70, render: r => h(NTag, { type: roleTagType(r.role), size: 'small' }, () => roleLabel(r.role)) },
    { title: '战力', key: 'combat_power', width: 80, render: r => r.combat_power || 0 },
    { title: '贡献', key: 'contribution', width: 80 },
  ]
  if (myRole.value === 'leader') {
    cols.push({
      title: '管理', key: 'manage', width: 140,
      render: r => {
        if (r.role === 'leader') return ''
        const btns = []
        if (r.role === 'member') btns.push(h(NButton, { size: 'tiny', type: 'info', onClick: () => promoteMember(r.wallet), style: 'margin-right:4px' }, () => '升职'))
        if (r.role === 'elder') btns.push(h(NButton, { size: 'tiny', type: 'warning', onClick: () => demoteMember(r.wallet), style: 'margin-right:4px' }, () => '降职'))
        btns.push(h(NButton, { size: 'tiny', type: 'error', onClick: () => kickMember(r.wallet) }, () => '踢出'))
        return h('div', {}, btns)
      }
    })
  } else if (myRole.value === 'elder') {
    cols.push({
      title: '管理', key: 'manage', width: 80,
      render: r => {
        if (r.role !== 'member') return ''
        return h(NButton, { size: 'tiny', type: 'error', onClick: () => kickMember(r.wallet) }, () => '踢出')
      }
    })
  }
  return cols
})

onMounted(async () => {
  loading.value = true
  await loadMySect()
  loading.value = false
})
</script>

<style scoped>
.gold-card { background: rgba(15,15,30,0.9); border: 1px solid rgba(212,168,67,0.12); }
.gold-card :deep(.n-card-header__main) { color: #d4a843; font-weight: bold; }
.sect-name { font-size: 18px; font-weight: bold; color: #d4a843; text-shadow: 0 0 8px rgba(212,168,67,0.3); }
.info-row { display: flex; align-items: center; gap: 8px; }
.info-row .label { color: #999; min-width: 70px; flex-shrink: 0; }
.exp-text { color: #d4a843; font-size: 12px; white-space: nowrap; }
.announcement-box { background: rgba(10,10,20,0.5); border-radius: 6px; padding: 8px 12px; border: 1px solid rgba(212,168,67,0.06); }
.announcement-box .label { color: #d4a843; font-size: 13px; margin-bottom: 4px; }
.announcement-text { color: #ccc; font-size: 13px; line-height: 1.5; }
.task-reward { color: #d4a843; font-size: 12px; margin-top: 4px; }
.gold-card :deep(.n-card) { transition: all 0.2s; }
.gold-card :deep(.n-card:hover) { border-color: rgba(212,168,67,0.25) !important; box-shadow: 0 4px 16px rgba(0,0,0,0.3); }
:deep(.n-button--warning-type) {
  background: linear-gradient(135deg, #8b2000, #ff6b35) !important;
  border: none !important; color: #fff !important; font-weight: 600;
}
:deep(.n-button--warning-type:hover) { opacity: 0.9; }
:deep(.n-button--error-type.n-button--ghost) {
  color: #a0522d !important; border-color: #a0522d !important;
}
:deep(.n-progress .n-progress-graph-line-fill) { background: linear-gradient(90deg, #8b2000, #d4a843) !important; }
:deep(.n-progress .n-progress-graph-line-rail) { background: rgba(30,30,50,0.8) !important; }
:deep(.n-tabs .n-tabs-tab--active) { color: #d4a843 !important; }
:deep(.n-tabs .n-tabs-tab) { color: #888; }
:deep(.n-list) { background: transparent; }
:deep(.n-list-item) { border-bottom-color: rgba(212,168,67,0.06) !important; }
:deep(.n-data-table .n-data-table-th) { color: #d4a843; background: rgba(10,10,20,0.5); }
:deep(.n-data-table .n-data-table-td) { border-bottom-color: rgba(212,168,67,0.06); }
:deep(.n-divider) { border-color: rgba(212,168,67,0.1) !important; }
</style>
