<template>
<div class="friends-page">
  <n-card class="main-card" :bordered="false">
    <template #header>
      <div class="page-title">⚔️ 焰友系统</div>
      <div class="friend-count">焰友: {{ friends.length }}/50</div>
    </template>
    <n-tabs v-model:value="activeTab" type="line" animated>
      <n-tab-pane name="list" tab="焰友列表">
        <div v-if="friends.length === 0" class="empty-tip">暂无焰友，快去搜索添加吧~</div>
        <div class="friend-grid">
          <div v-for="f in friends" :key="f.wallet" class="friend-card">
            <div class="friend-info">
              <div class="friend-name">
                <span class="online-dot" :class="{ online: f.online }"></span>
                {{ f.name }}
              </div>
              <div class="friend-detail">Lv.{{ f.level }} · {{ f.realm }}</div>
              <div class="friend-detail">战力: {{ formatNum(f.combatPower) }}</div>
            </div>
            <div class="friend-actions">
              <n-button size="tiny" type="info" quaternary @click="viewProfile(f.wallet)">详情</n-button>
              <n-button size="tiny" type="warning" quaternary @click="openGiftModal(f)">送礼</n-button>
              <n-popconfirm @positive-click="removeFriend(f.wallet)">
                <template #trigger>
                  <n-button size="tiny" type="error" quaternary>删除</n-button>
                </template>
                确定删除焰友【{{ f.name }}】？
              </n-popconfirm>
            </div>
          </div>
        </div>
      </n-tab-pane>

      <n-tab-pane name="requests" :tab="requestTabLabel">
        <div v-if="requests.length === 0" class="empty-tip">暂无焰友申请</div>
        <div class="friend-grid">
          <div v-for="r in requests" :key="r.id" class="friend-card">
            <div class="friend-info">
              <div class="friend-name">{{ r.name }}</div>
              <div class="friend-detail">Lv.{{ r.level }} · {{ r.realm }}</div>
              <div class="friend-detail">战力: {{ formatNum(r.combatPower) }}</div>
            </div>
            <div class="friend-actions">
              <n-button size="tiny" type="success" @click="acceptRequest(r.id)">接受</n-button>
              <n-button size="tiny" type="error" quaternary @click="rejectRequest(r.id)">拒绝</n-button>
            </div>
          </div>
        </div>
      </n-tab-pane>

      <n-tab-pane name="search" tab="搜索添加">
        <n-input-group>
          <n-input v-model:value="searchKeyword" placeholder="输入焰名搜索..." @keyup.enter="doSearch" clearable />
          <n-button type="primary" @click="doSearch" :loading="searching">搜索</n-button>
        </n-input-group>
        <div v-if="searchResults.length" class="friend-grid" style="margin-top:12px">
          <div v-for="p in searchResults" :key="p.wallet" class="friend-card">
            <div class="friend-info">
              <div class="friend-name">{{ p.name }}</div>
              <div class="friend-detail">Lv.{{ p.level }} · {{ p.realm }}</div>
              <div class="friend-detail">战力: {{ formatNum(p.combatPower) }}</div>
            </div>
            <div class="friend-actions">
              <n-button v-if="p.isFriend" size="tiny" disabled>已添加</n-button>
              <n-button v-else size="tiny" type="primary" @click="addFriend(p.wallet)" :loading="p._adding">添加</n-button>
            </div>
          </div>
        </div>
      </n-tab-pane>

      <n-tab-pane name="gifts" :tab="giftTabLabel">
        <div v-if="gifts.length === 0" class="empty-tip">暂无礼物</div>
        <div class="friend-grid">
          <div v-for="g in gifts" :key="g.id" class="friend-card gift-card">
            <div class="friend-info">
              <div class="friend-name">来自: {{ g.fromName }}</div>
              <div class="friend-detail">{{ giftTypeLabel(g.giftType) }} x{{ formatNum(g.giftValue) }}</div>
              <div class="friend-detail gift-msg" v-if="g.message">💬 {{ g.message }}</div>
            </div>
            <div class="friend-actions">
              <n-button v-if="!g.claimed" size="small" type="success" @click="claimGift(g.id)">领取</n-button>
              <n-tag v-else size="small" type="default">已领取</n-tag>
            </div>
          </div>
        </div>
      </n-tab-pane>
    </n-tabs>
  </n-card>

  <!-- 焰友详情弹窗 -->
  <n-modal v-model:show="showProfile" preset="card" title="焰友详情" style="max-width:420px" :bordered="false">
    <div v-if="profileData" class="profile-modal">
      <div class="profile-row"><span class="label">焰名</span><span>{{ profileData.name }}</span></div>
      <div class="profile-row"><span class="label">等级</span><span>Lv.{{ profileData.level }}</span></div>
      <div class="profile-row"><span class="label">境界</span><span>{{ profileData.realm }}</span></div>
      <div class="profile-row"><span class="label">战力</span><span>{{ formatNum(profileData.combatPower) }}</span></div>
      <div class="profile-row"><span class="label">VIP</span><span>{{ profileData.vipLevel > 0 ? VIP+profileData.vipLevel : 无 }}</span></div>
      <div class="profile-row" v-if="profileData.sect"><span class="label">焰盟</span><span>{{ profileData.sect.name }}({{ roleLabel(profileData.sect.role) }})</span></div>
      <div class="profile-row" v-else><span class="label">焰盟</span><span>无</span></div>
      <n-divider>装备</n-divider>
      <div v-if="equipList.length">
        <div v-for="e in equipList" :key="e.slot" class="equip-row">
          <span class="equip-slot">{{ e.slot }}</span>
          <span class="equip-name" :style="{color: e.color}">{{ e.name }}</span>
        </div>
      </div>
      <div v-else class="empty-tip">未穿戴装备</div>
      <n-button type="warning" block style="margin-top:16px" @click="openGiftModal(profileData)">🎁 送礼</n-button>
    </div>
  </n-modal>

  <!-- 送礼弹窗 -->
  <n-modal v-model:show="showGift" preset="card" title="🎁 送礼" style="max-width:380px" :bordered="false">
    <n-form label-placement="left" label-width="80">
      <n-form-item label="送给">{{ giftTarget?.name || 未知 }}</n-form-item>
      <n-form-item label="类型">
        <n-select v-model:value="giftForm.gift_type" :options="giftTypeOptions" />
      </n-form-item>
      <n-form-item label="数量">
        <n-input-number v-model:value="giftForm.gift_value" :min="1" :max="100000" style="width:100%" />
      </n-form-item>
      <n-form-item label="留言">
        <n-input v-model:value="giftForm.message" placeholder="写点什么..." maxlength="50" />
      </n-form-item>
      <div class="gift-remaining">今日剩余送礼次数: {{ giftRemaining }}/3</div>
      <n-button type="warning" block @click="sendGift" :loading="giftSending" :disabled="giftRemaining<=0">确认送出</n-button>
    </n-form>
  </n-modal>
</div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue"
import { useAuthStore } from "../stores/auth"
import { createDiscreteApi } from "naive-ui"

const { message: msg } = createDiscreteApi(["message"])
const authStore = useAuthStore()
const API = "/api/friend"

const activeTab = ref("list")
const friends = ref([])
const requests = ref([])
const searchKeyword = ref("")
const searchResults = ref([])
const searching = ref(false)
const gifts = ref([])
const showProfile = ref(false)
const profileData = ref(null)
const showGift = ref(false)
const giftTarget = ref(null)
const giftSending = ref(false)
const giftRemaining = ref(3)
const giftForm = ref({ gift_type: "spirit_stones", gift_value: 100, message: "" })

const giftTypeOptions = [{ label: "焰晶", value: "spirit_stones" }]

const requestTabLabel = computed(() => requests.value.length ? `申请(${requests.value.length})` : "申请")
const giftTabLabel = computed(() => {
  const unclaimed = gifts.value.filter(g => !g.claimed).length
  return unclaimed ? `礼物(${unclaimed})` : "礼物"
})

const equipList = computed(() => {
  if (!profileData.value?.equippedArtifacts) return []
  const ea = profileData.value.equippedArtifacts
  const slotNames = { weapon: "焰杖", armor: "防具", accessory: "饰品", mount: "焰骑" }
  const colorMap = { common: "#aaa", rare: "#4fc3f7", epic: "#ab47bc", legendary: "#ffa726", mythic: "#ef5350" }
  return Object.entries(ea).filter(([, v]) => v).map(([slot, item]) => ({
    slot: slotNames[slot] || slot,
    name: item.name || "未知",
    color: colorMap[item.rarity] || "#ccc"
  }))
})

function headers() { return { Authorization: "Bearer " + authStore.token, "Content-Type": "application/json" } }

async function fetchFriends() {
  try {
    const r = await fetch(API + "/list", { headers: headers() })
    const d = await r.json(); if (d.ok) friends.value = d.friends
  } catch {}
}
async function fetchRequests() {
  try {
    const r = await fetch(API + "/requests", { headers: headers() })
    const d = await r.json(); if (d.ok) requests.value = d.requests
  } catch {}
}
async function fetchGifts() {
  try {
    const r = await fetch(API + "/gifts", { headers: headers() })
    const d = await r.json(); if (d.ok) gifts.value = d.gifts
  } catch {}
}
async function doSearch() {
  if (!searchKeyword.value.trim()) return
  searching.value = true
  try {
    const r = await fetch(API + "/search", { method: "POST", headers: headers(), body: JSON.stringify({ keyword: searchKeyword.value }) })
    const d = await r.json(); if (d.ok) searchResults.value = d.players
  } catch {} finally { searching.value = false }
}
async function addFriend(wallet) {
  try {
    const r = await fetch(API + "/add", { method: "POST", headers: headers(), body: JSON.stringify({ to_wallet: wallet }) })
    const d = await r.json()
    if (d.ok) { msg.success("焰友申请已发送"); doSearch() } else msg.warning(d.error)
  } catch {}
}
async function acceptRequest(id) {
  try {
    const r = await fetch(API + "/accept", { method: "POST", headers: headers(), body: JSON.stringify({ friendship_id: id }) })
    const d = await r.json()
    if (d.ok) { msg.success("已接受"); fetchRequests(); fetchFriends() } else msg.warning(d.error)
  } catch {}
}
async function rejectRequest(id) {
  try {
    const r = await fetch(API + "/reject", { method: "POST", headers: headers(), body: JSON.stringify({ friendship_id: id }) })
    const d = await r.json()
    if (d.ok) { msg.success("已拒绝"); fetchRequests() } else msg.warning(d.error)
  } catch {}
}
async function removeFriend(wallet) {
  try {
    const r = await fetch(API + "/remove", { method: "POST", headers: headers(), body: JSON.stringify({ wallet }) })
    const d = await r.json()
    if (d.ok) { msg.success("已删除焰友"); fetchFriends() } else msg.warning(d.error)
  } catch {}
}
async function viewProfile(wallet) {
  try {
    const r = await fetch(API + "/profile/" + wallet, { headers: headers() })
    const d = await r.json()
    if (d.ok) { profileData.value = d.profile; showProfile.value = true } else msg.warning(d.error)
  } catch {}
}
function openGiftModal(target) {
  giftTarget.value = target
  giftForm.value = { gift_type: "spirit_stones", gift_value: 100, message: "" }
  showGift.value = true
}
async function sendGift() {
  giftSending.value = true
  try {
    const r = await fetch(API + "/gift", { method: "POST", headers: headers(), body: JSON.stringify({
      to_wallet: giftTarget.value.wallet, ...giftForm.value
    }) })
    const d = await r.json()
    if (d.ok) { msg.success("礼物已送出"); giftRemaining.value = d.remaining; showGift.value = false; fetchFriends() }
    else msg.warning(d.error)
  } catch {} finally { giftSending.value = false }
}
async function claimGift(id) {
  try {
    const r = await fetch(API + "/gifts/" + id + "/claim", { method: "POST", headers: headers() })
    const d = await r.json()
    if (d.ok) { msg.success(`领取了 ${giftTypeLabel(d.giftType)} x${d.giftValue}`); fetchGifts() } else msg.warning(d.error)
  } catch {}
}
function formatNum(n) { return n >= 10000 ? (n/10000).toFixed(1) + "万" : String(n) }
function giftTypeLabel(t) { return t === "spirit_stones" ? "焰晶" : t }
function roleLabel(r) { return { leader: "盟主", elder: "焰长", member: "成员" }[r] || r }

onMounted(() => {
  if (authStore.isLoggedIn) { fetchFriends(); fetchRequests(); fetchGifts() }
})
</script>

<style scoped>
.friends-page { padding: 8px; max-width: 800px; margin: 0 auto; }
.main-card { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); border: 1px solid #d4a843; border-radius: 12px; }
.page-title { font-size: 20px; color: #d4a843; font-weight: bold; }
.friend-count { color: #aaa; font-size: 13px; margin-top: 4px; }
.friend-grid { display: flex; flex-direction: column; gap: 8px; margin-top: 8px; }
.friend-card { display: flex; justify-content: space-between; align-items: center; padding: 12px; background: rgba(212,168,67,0.06); border: 1px solid rgba(212,168,67,0.2); border-radius: 8px; transition: border-color 0.2s; }
.friend-card:hover { border-color: #d4a843; }
.friend-info { flex: 1; }
.friend-name { font-size: 15px; color: #e8d5a3; font-weight: 600; display: flex; align-items: center; gap: 6px; }
.friend-detail { font-size: 12px; color: #888; margin-top: 2px; }
.friend-actions { display: flex; gap: 4px; flex-shrink: 0; }
.online-dot { width: 8px; height: 8px; border-radius: 50%; background: #555; display: inline-block; }
.online-dot.online { background: #4caf50; box-shadow: 0 0 6px #4caf50; }
.empty-tip { text-align: center; color: #666; padding: 32px 0; font-size: 14px; }
.gift-msg { color: #d4a843; font-style: italic; }
.gift-card { background: rgba(212,168,67,0.1); }
.profile-modal { }
.profile-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.06); color: #ccc; font-size: 14px; }
.profile-row .label { color: #d4a843; font-weight: 600; }
.equip-row { display: flex; justify-content: space-between; padding: 4px 0; font-size: 13px; }
.equip-slot { color: #888; }
.equip-name { font-weight: 600; }
.gift-remaining { text-align: center; color: #d4a843; font-size: 13px; margin-bottom: 12px; }
:deep(.n-tabs-tab) { color: #888 !important; }
:deep(.n-tabs-tab--active) { color: #d4a843 !important; }
:deep(.n-tabs-bar) { background: #d4a843 !important; }
</style>
