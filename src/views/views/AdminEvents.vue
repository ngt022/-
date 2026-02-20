<template>
  <div class="admin-events">
    <n-card :bordered="false">
      <!-- 统计卡片 -->
      <n-grid :cols="3" :x-gap="12" :y-gap="12" style="margin-bottom:20px">
        <n-gi>
          <n-card size="small" class="stat-card">
            <n-statistic label="活跃活动" :value="stats.activeEvents">
              <template #prefix><span style="color:#4caf50">🟢</span></template>
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card size="small" class="stat-card">
            <n-statistic label="总领取次数" :value="stats.totalClaims">
              <template #prefix><span>🎁</span></template>
            </n-statistic>
          </n-card>
        </n-gi>
        <n-gi>
          <n-card size="small" class="stat-card">
            <n-statistic label="总玩家数" :value="stats.totalPlayers">
              <template #prefix><span>👥</span></template>
            </n-statistic>
          </n-card>
        </n-gi>
      </n-grid>

      <n-space justify="end" style="margin-bottom:12px">
        <n-button type="primary" @click="openCreate">✨ 创建活动</n-button>
      </n-space>

      <!-- 活动列表 -->
      <n-data-table
        :columns="columns"
        :data="events"
        :loading="loading"
        :row-key="r => r.id"
        :row-class-name="rowClass"
      />
    </n-card>

    <!-- 创建/编辑弹窗 -->
    <n-modal v-model:show="showModal" preset="card" :title="editingId ? 编辑活动 : 创建活动" style="width:600px;max-width:95vw" :mask-closable="false">
      <n-form ref="formRef" :model="form" :rules="rules" label-placement="left" label-width="80">
        <n-form-item label="名称" path="name">
          <n-input v-model:value="form.name" placeholder="活动名称" />
        </n-form-item>
        <n-form-item label="描述" path="description">
          <n-input v-model:value="form.description" type="textarea" placeholder="活动描述" :rows="2" />
        </n-form-item>
        <n-form-item label="类型" path="type">
          <n-select v-model:value="form.type" :options="typeOptions" placeholder="选择活动类型" />
        </n-form-item>
        <n-form-item label="效果值">
          <n-input-number v-model:value="form.effectValue" :min="0" :step="0.1" placeholder="如倍率2, 折扣0.8" style="width:100%" />
        </n-form-item>
        <n-grid :cols="2" :x-gap="12">
          <n-gi>
            <n-form-item label="奖励类型">
              <n-select v-model:value="form.rewardType" :options="rewardTypeOptions" placeholder="奖励类型" />
            </n-form-item>
          </n-gi>
          <n-gi>
            <n-form-item label="奖励值">
              <n-input-number v-model:value="form.rewardValue" :min="0" placeholder="奖励数量" style="width:100%" />
            </n-form-item>
          </n-gi>
        </n-grid>
        <n-grid :cols="2" :x-gap="12">
          <n-gi>
            <n-form-item label="开始时间" path="starts_at">
              <n-date-picker v-model:value="form.starts_at" type="datetime" style="width:100%" />
            </n-form-item>
          </n-gi>
          <n-gi>
            <n-form-item label="结束时间" path="ends_at">
              <n-date-picker v-model:value="form.ends_at" type="datetime" style="width:100%" />
            </n-form-item>
          </n-gi>
        </n-grid>
        <n-form-item label="状态">
          <n-switch v-model:value="form.active" />
          <span style="margin-left:8px;color:#a09880">{{ form.active ? "启用" : "禁用" }}</span>
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space justify="end">
          <n-button @click="showModal=false">取消</n-button>
          <n-button type="primary" @click="submitForm" :loading="submitting">{{ editingId ? "保存" : "创建" }}</n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- 领取记录弹窗 -->
    <n-modal v-model:show="showClaims" preset="card" title="领取记录" style="width:550px;max-width:95vw">
      <n-data-table :columns="claimColumns" :data="claims" :loading="claimsLoading" size="small" />
    </n-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, h } from "vue"
import { useAuthStore } from "../stores/auth"
import { NButton, NSpace, NTag, createDiscreteApi } from "naive-ui"

const authStore = useAuthStore()
const { message, dialog } = createDiscreteApi(["message", "dialog"])
const API = "/api"
const headers = () => ({ "Content-Type": "application/json", Authorization: `Bearer ${authStore.token}` })

const events = ref([])
const loading = ref(false)
const stats = ref({ activeEvents: 0, totalClaims: 0, totalPlayers: 0 })
const showModal = ref(false)
const editingId = ref(null)
const submitting = ref(false)
const formRef = ref(null)
const showClaims = ref(false)
const claims = ref([])
const claimsLoading = ref(false)

const typeOptions = [
  { label: "双倍冥想", value: "double_cultivation" },
  { label: "抽卡概率UP", value: "gacha_rate_up" },
  { label: "双倍掉落", value: "double_drop" },
  { label: "焰晶商铺折扣", value: "discount" },
  { label: "登录奖励", value: "login_bonus" },
]
const rewardTypeOptions = [
  { label: "焰晶", value: "spirit_stones" },
  { label: "道具", value: "items" },
]
const typeMap = { double_cultivation: "双倍冥想", gacha_rate_up: "概率UP", double_drop: "双倍掉落", discount: "焰晶商铺折扣", login_bonus: "登录奖励" }

const defaultForm = () => ({ name: "", description: "", type: null, effectValue: 2, rewardType: "spirit_stones", rewardValue: 1000, starts_at: null, ends_at: null, active: true })
const form = ref(defaultForm())

const rules = {
  name: { required: true, message: "请输入名称", trigger: "blur" },
  type: { required: true, message: "请选择类型", trigger: "change" },
  starts_at: { type: "number", required: true, message: "请选择开始时间", trigger: "change" },
  ends_at: { type: "number", required: true, message: "请选择结束时间", trigger: "change" },
}

function getStatus(row) {
  const now = Date.now()
  const start = new Date(row.starts_at).getTime()
  const end = new Date(row.ends_at).getTime()
  if (!row.active) return { text: "已禁用", type: "default" }
  if (now < start) return { text: "未开始", type: "info" }
  if (now > end) return { text: "已结束", type: "default" }
  return { text: "进行中", type: "success" }
}

function rowClass(row) {
  const s = getStatus(row)
  return s.text === "已结束" ? "row-ended" : ""
}

function fmtTime(t) {
  if (!t) return "-"
  return new Date(t).toLocaleString("zh-CN", { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" })
}

const columns = [
  { title: "ID", key: "id", width: 50 },
  { title: "名称", key: "name", width: 140 },
  { title: "类型", key: "type", width: 100, render: r => h(NTag, { size: "small", type: "warning", bordered: false }, () => typeMap[r.type] || r.type) },
  { title: "效果", key: "config", width: 80, render: r => { const c = r.config || {}; return c.multiplier || c.rateBoost || c.discount || c.dailyStones || "-" } },
  { title: "开始", key: "starts_at", width: 110, render: r => fmtTime(r.starts_at) },
  { title: "结束", key: "ends_at", width: 110, render: r => fmtTime(r.ends_at) },
  { title: "状态", key: "status", width: 80, render: r => { const s = getStatus(r); return h(NTag, { size: "small", type: s.type, bordered: false }, () => s.text) } },
  { title: "操作", key: "actions", width: 200, render: r => h(NSpace, { size: 4 }, () => [
    h(NButton, { size: "tiny", type: "info", quaternary: true, onClick: () => viewClaims(r.id) }, () => "领取记录"),
    h(NButton, { size: "tiny", type: "warning", quaternary: true, onClick: () => openEdit(r) }, () => "编辑"),
    h(NButton, { size: "tiny", type: "error", quaternary: true, onClick: () => confirmDelete(r) }, () => "删除"),
  ]) },
]

const claimColumns = [
  { title: "玩家", key: "name", width: 120, render: r => r.name || "无名焰修" },
  { title: "钱包", key: "wallet", width: 140, render: r => r.wallet ? r.wallet.slice(0,6) + "..." + r.wallet.slice(-4) : "-" },
  { title: "领取时间", key: "claimed_at", render: r => fmtTime(r.claimed_at) },
]

async function fetchEvents() {
  loading.value = true
  try {
    const res = await fetch(`${API}/admin/events`, { headers: headers() })
    const data = await res.json()
    events.value = data.events || []
  } catch (e) { message.error("加载失败") }
  loading.value = false
}

async function fetchStats() {
  try {
    const res = await fetch(`${API}/admin/stats`, { headers: headers() })
    stats.value = await res.json()
  } catch {}
}

function openCreate() {
  editingId.value = null
  form.value = defaultForm()
  showModal.value = true
}

function openEdit(row) {
  editingId.value = row.id
  const c = row.config || {}
  const effectVal = c.multiplier || c.rateBoost || c.discount || c.dailyStones || 0
  const rewards = row.rewards || []
  const rw = rewards[0] || {}
  form.value = {
    name: row.name,
    description: row.description || "",
    type: row.type,
    effectValue: effectVal,
    rewardType: rw.type || "spirit_stones",
    rewardValue: rw.value || 0,
    starts_at: new Date(row.starts_at).getTime(),
    ends_at: new Date(row.ends_at).getTime(),
    active: row.active,
  }
  showModal.value = true
}

function buildBody() {
  const f = form.value
  const configKey = { double_cultivation: "multiplier", gacha_rate_up: "rateBoost", double_drop: "multiplier", discount: "discount", login_bonus: "dailyStones" }
  const config = {}
  config[configKey[f.type] || "multiplier"] = f.effectValue
  return {
    name: f.name, description: f.description, type: f.type,
    config, rewards: [{ type: f.rewardType, value: f.rewardValue }],
    starts_at: new Date(f.starts_at).toISOString(),
    ends_at: new Date(f.ends_at).toISOString(),
    active: f.active,
  }
}

async function submitForm() {
  try { await formRef.value?.validate() } catch { return }
  submitting.value = true
  try {
    const body = buildBody()
    const url = editingId.value ? `${API}/admin/events/${editingId.value}` : `${API}/admin/events`
    const method = editingId.value ? "PUT" : "POST"
    const res = await fetch(url, { method, headers: headers(), body: JSON.stringify(body) })
    const data = await res.json()
    if (data.error) { message.error(data.error); return }
    message.success(editingId.value ? "已更新" : "已创建")
    showModal.value = false
    fetchEvents()
    fetchStats()
  } catch (e) { message.error("操作失败") }
  submitting.value = false
}

function confirmDelete(row) {
  dialog.warning({
    title: "确认删除",
    content: `确定删除活动「${row.name}」？相关领取记录也会被删除。`,
    positiveText: "删除",
    negativeText: "取消",
    onPositiveClick: async () => {
      try {
        await fetch(`${API}/admin/events/${row.id}`, { method: "DELETE", headers: headers() })
        message.success("已删除")
        fetchEvents()
        fetchStats()
      } catch { message.error("删除失败") }
    },
  })
}

async function viewClaims(eventId) {
  showClaims.value = true
  claimsLoading.value = true
  try {
    const res = await fetch(`${API}/admin/events/${eventId}/claims`, { headers: headers() })
    const data = await res.json()
    claims.value = data.claims || []
  } catch { message.error("加载失败") }
  claimsLoading.value = false
}

onMounted(() => { fetchEvents(); fetchStats() })
</script>

<style scoped>
.admin-events { padding: 0; }
.stat-card {
  background: linear-gradient(135deg, rgba(212,168,67,0.08), rgba(124,92,191,0.06)) !important;
  border: 1px solid rgba(212,168,67,0.2) !important;
  text-align: center;
}
.stat-card :deep(.n-statistic-value) { color: #d4a843 !important; font-size: 28px; }
.stat-card :deep(.n-statistic-label) { color: #a09880 !important; }
:deep(.row-ended td) { opacity: 0.5; }
:deep(.n-data-table) { background: transparent !important; }
:deep(.n-data-table .n-data-table-th) { background: rgba(212,168,67,0.06) !important; color: #d4a843 !important; border-bottom: 1px solid rgba(212,168,67,0.15) !important; }
:deep(.n-data-table .n-data-table-td) { border-bottom: 1px solid rgba(255,255,255,0.04) !important; }
</style>
