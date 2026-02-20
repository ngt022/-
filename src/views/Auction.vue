<template>
  <div class="auction-page">
    <game-guide>
      <p>🏛️ 玩家间自由交易：装备、焰草、焰丹、焰兽、焰方</p>
      <p>📤 上架设置起拍价和一口价，持续12/24/48小时</p>
      <p>💰 上架费：起拍价的<strong>5%</strong></p>
      <p>🔨 竞拍最低加价：当前最高价的<strong>110%</strong></p>
      <p>⏰ 到期后最高出价者获得物品</p>
    </game-guide>
    <n-card class="auction-card">
      <template #header>
        <div class="auction-header">
          <span class="header-icon">🏛️</span>
          <span class="header-title">焰市</span>
          <n-tag type="warning" size="small" style="margin-left:8px">💰 {{ playerStore.spiritStones }} 焰晶</n-tag>
        </div>
      </template>

      <n-tabs type="segment" v-model:value="activeTab" animated>
        <!-- 浏览 Tab -->
        <n-tab-pane name="browse" tab="🔍 浏览">
          <div class="filter-bar">
            <n-select v-model:value="filterType" :options="typeOptions" placeholder="类型" style="width:120px" size="small" clearable />
            <n-select v-model:value="filterQuality" :options="qualityOptions" placeholder="品质" style="width:120px" size="small" clearable />
            <n-select v-model:value="sortBy" :options="sortOptions" placeholder="排序" style="width:140px" size="small" />
            <n-button size="small" type="primary" @click="loadBrowse" :loading="browseLoading">刷新</n-button>
          </div>
          <div v-if="browseLoading" style="text-align:center;padding:40px"><n-spin size="large" /></div>
          <div v-else-if="browseList.length === 0" style="text-align:center;padding:40px;color:#666">暂无拍卖物品</div>
          <div v-else class="auction-grid">
            <div v-for="item in browseList" :key="item.id" class="auction-item-card" :class="getQualityClass(item)" @click="openDetail(item.id)">
              <div class="item-top-row">
                <span class="item-emoji">{{ getTypeEmoji(item.item_type) }}</span>
                <span class="item-name">{{ item.item_name }}</span>
              </div>
              <div class="item-quality-tag" :style="{ color: getQualityColor(item) }">{{ getQualityName(item) }}</div>
              <div class="item-price-row">
                <div class="price-label">当前价</div>
                <div class="price-value">💰 {{ item.current_bid > 0 ? item.current_bid : item.starting_price }}</div>
              </div>
              <div v-if="item.buyout_price" class="item-price-row buyout-row">
                <div class="price-label">一口价</div>
                <div class="price-value buyout-price">💎 {{ item.buyout_price }}</div>
              </div>
              <div class="item-bottom-row">
                <span class="bid-count">{{ item.bid_count }} 次出价</span>
                <span class="time-left" :class="{ urgent: getTimeLeft(item.expires_at).urgent }">{{ getTimeLeft(item.expires_at).text }}</span>
              </div>
            </div>
          </div>
          <div v-if="browseTotal > browseLimit" style="display:flex;justify-content:center;margin-top:16px">
            <n-pagination v-model:page="browsePage" :page-count="Math.ceil(browseTotal / browseLimit)" @update:page="loadBrowse" />
          </div>
        </n-tab-pane>

        <!-- 上架 Tab -->
        <n-tab-pane name="list" tab="📦 上架">
          <div v-if="listableItems.length === 0" style="text-align:center;padding:40px;color:#666">背包中没有可上架的物品</div>
          <div v-else>
            <div class="listable-grid">
              <div v-for="item in listableItems" :key="item.id"
                class="listable-item" :class="[getItemQualityClass(item), selectedListItem?.id === item.id ? 'selected' : '']"
                @click="selectedListItem = item">
                <span class="item-emoji">{{ getTypeEmoji(item.type) }}</span>
                <span class="item-name">{{ item.name }}</span>
                <span class="item-quality-sm" :style="{ color: getItemQualityColor(item) }">{{ getItemQualityName(item) }}</span>
              </div>
            </div>
            <div v-if="selectedListItem" class="list-form">
              <n-divider>上架设置: {{ selectedListItem.name }}</n-divider>
              <n-space vertical :size="12">
                <n-input-number v-model:value="listPrice" :min="1" placeholder="起拍价" style="width:100%">
                  <template #prefix>起拍价 💰</template>
                </n-input-number>
                <n-input-number v-model:value="listBuyout" :min="0" placeholder="一口价（可选）" style="width:100%">
                  <template #prefix>一口价 💎</template>
                </n-input-number>
                <n-select v-model:value="listDuration" :options="durationOptions" placeholder="持续时间" />
                <div class="fee-preview" v-if="listPrice > 0">
                  上架费: <n-text type="warning">{{ Math.max(1, Math.floor(listPrice * 0.05)) }} 焰晶</n-text>
                </div>
                <n-button type="primary" block @click="doList" :loading="listLoading" :disabled="!listPrice">确认上架</n-button>
              </n-space>
            </div>
          </div>
        </n-tab-pane>

        <!-- 我的拍卖 Tab -->
        <n-tab-pane name="my" tab="📋 我的">
          <n-tabs type="line" v-model:value="mySubTab" size="small">
            <n-tab-pane name="myListings" tab="我的上架">
              <div v-if="myListLoading" style="text-align:center;padding:20px"><n-spin /></div>
              <div v-else-if="myListings.length === 0" style="text-align:center;padding:20px;color:#666">暂无上架物品</div>
              <div v-else class="my-list">
                <div v-for="item in myListings" :key="item.id" class="my-list-item" :class="getQualityClass(item)">
                  <div class="my-item-info">
                    <span>{{ getTypeEmoji(item.item_type) }} {{ item.item_name }}</span>
                    <n-tag :type="statusTagType(item.status)" size="small">{{ statusText(item.status) }}</n-tag>
                  </div>
                  <div class="my-item-price">
                    当前: {{ item.current_bid > 0 ? item.current_bid : item.starting_price }} 焰晶 | {{ item.bid_count }} 次出价
                  </div>
                  <n-button v-if="item.status === 'active' && item.bid_count === 0" size="tiny" type="error" @click="doCancel(item.id)" :loading="cancelLoading === item.id">取消</n-button>
                </div>
              </div>
            </n-tab-pane>
            <n-tab-pane name="myBids" tab="我的出价">
              <div v-if="myBidsLoading" style="text-align:center;padding:20px"><n-spin /></div>
              <div v-else-if="myBids.length === 0" style="text-align:center;padding:20px;color:#666">暂无出价记录</div>
              <div v-else class="my-list">
                <div v-for="bid in myBids" :key="bid.id" class="my-list-item">
                  <div class="my-item-info">
                    <span>{{ getTypeEmoji(bid.item_type) }} {{ bid.item_name }}</span>
                    <n-tag :type="bid.bidder_wallet === bid.current_bidder ? 'success' : 'default'" size="small">
                      {{ bid.bidder_wallet === bid.current_bidder ? '最高出价' : '已超过' }}
                    </n-tag>
                  </div>
                  <div class="my-item-price">我的出价: {{ bid.bid_amount }} 焰晶 | 当前最高: {{ bid.current_bid }}</div>
                </div>
              </div>
            </n-tab-pane>
          </n-tabs>
        </n-tab-pane>

        <!-- 成交记录 Tab -->
        <n-tab-pane name="history" tab="📜 成交">
          <div v-if="historyLoading" style="text-align:center;padding:20px"><n-spin /></div>
          <div v-else-if="historyList.length === 0" style="text-align:center;padding:20px;color:#666">暂无成交记录</div>
          <div v-else class="history-list">
            <div v-for="h in historyList" :key="h.id" class="history-item">
              <div class="history-item-name">{{ getTypeEmoji(h.item_type) }} {{ h.item_name }}</div>
              <div class="history-item-detail">
                <span>💰 {{ h.final_price }}</span>
                <span>{{ h.seller_name || '???' }} → {{ h.buyer_name || '???' }}</span>
                <span>{{ formatTime(h.sold_at) }}</span>
              </div>
            </div>
          </div>
        </n-tab-pane>
      </n-tabs>
    </n-card>

    <!-- 拍卖详情弹窗 -->
    <n-modal v-model:show="showDetail" preset="card" :title="detailData?.item_name || '拍卖详情'" style="max-width:500px" :bordered="false" class="detail-modal">
      <div v-if="detailLoading" style="text-align:center;padding:20px"><n-spin /></div>
      <div v-else-if="detailData" class="detail-content">
        <div class="detail-item-header" :class="getQualityClass(detailData)">
          <span style="font-size:36px">{{ getTypeEmoji(detailData.item_type) }}</span>
          <div>
            <div class="detail-item-name">{{ detailData.item_name }}</div>
            <div class="detail-item-quality" :style="{ color: getQualityColor(detailData) }">{{ getQualityName(detailData) }}</div>
          </div>
        </div>

        <div v-if="detailData.item_data?.stats" class="detail-stats">
          <div v-for="(val, key) in detailData.item_data.stats" :key="key" class="stat-row">
            <span class="stat-key">{{ statNames[key] || key }}</span>
            <span class="stat-val">+{{ val }}</span>
          </div>
        </div>

        <n-divider style="margin:12px 0" />
        <div class="detail-price-info">
          <div>起拍价: <n-text type="warning">{{ detailData.starting_price }} 焰晶</n-text></div>
          <div>当前最高: <n-text type="warning" strong>{{ detailData.current_bid > 0 ? detailData.current_bid : '无出价' }}</n-text></div>
          <div v-if="detailData.buyout_price">一口价: <n-text type="info">{{ detailData.buyout_price }} 焰晶</n-text></div>
          <div>剩余时间: <n-text :type="getTimeLeft(detailData.expires_at).urgent ? 'error' : 'default'">{{ getTimeLeft(detailData.expires_at).text }}</n-text></div>
          <div>出价次数: {{ detailData.bid_count }}</div>
          <div>卖家: {{ detailData.seller_name }}</div>
        </div>

        <div v-if="detailData.status === 'active'" class="detail-actions">
          <n-divider style="margin:12px 0">出价</n-divider>
          <n-input-number v-model:value="bidAmount" :min="minBidAmount" style="width:100%" placeholder="输入出价金额">
            <template #prefix>💰</template>
          </n-input-number>
          <div style="font-size:12px;color:#999;margin:4px 0">最低出价: {{ minBidAmount }} 焰晶</div>
          <n-space :size="8" style="margin-top:8px">
            <n-button type="primary" @click="doBid" :loading="bidLoading" :disabled="!bidAmount" style="flex:1">出价</n-button>
            <n-button v-if="detailData.buyout_price" type="warning" @click="doBuyout" :loading="buyoutLoading" style="flex:1">一口价 {{ detailData.buyout_price }}</n-button>
          </n-space>
        </div>

        <div v-if="detailBids.length > 0" class="bid-history">
          <n-divider style="margin:12px 0">出价历史</n-divider>
          <div v-for="b in detailBids" :key="b.created_at" class="bid-row">
            <span>{{ b.bidder_name }}</span>
            <span class="bid-amount">{{ b.bid_amount }} 焰晶</span>
            <span class="bid-time">{{ formatTime(b.created_at) }}</span>
          </div>
        </div>
      </div>
    </n-modal>
  </div>
</template>
<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { createDiscreteApi } from 'naive-ui'
import GameGuide from '../components/GameGuide.vue'

const { message } = createDiscreteApi(['message'])
const playerStore = usePlayerStore()
const authStore = useAuthStore()

const activeTab = ref('browse')
const mySubTab = ref('myListings')

// === 品质配置 ===
const equipQuality = {
  common: { name: '凡品', color: '#888' }, uncommon: { name: '良品', color: '#4caf50' },
  rare: { name: '稀有', color: '#2196f3' }, epic: { name: '史诗', color: '#9c27b0' },
  legendary: { name: '传说', color: '#ff9800' }, mythic: { name: '神话', color: '#f44336' }
}
const petQuality = {
  mortal: { name: '凡品', color: '#32CD32' }, spiritual: { name: '灵品', color: '#1E90FF' },
  mystic: { name: '玄品', color: '#9932CC' }, celestial: { name: '仙品', color: '#FFD700' },
  divine: { name: '神品', color: '#FF0000' }
}
const statNames = { attack: '攻击', defense: '防御', hp: '生命', speed: '速度', critRate: '暴击率', critDmg: '暴击伤害', dodge: '闪避', penetration: '穿透' }

const typeOptions = [
  { label: '全部', value: null }, { label: '⚔️ 装备', value: 'equipment' },
  { label: '🌿 焰草', value: 'herb' }, { label: '💊 焰丹', value: 'pill' },
  { label: '🐾 焰兽', value: 'pet' }, { label: '📜 焰方', value: 'formula' }
]
const qualityOptions = [
  { label: '全部品质', value: null },
  { label: '凡品', value: 'common' }, { label: '良品', value: 'uncommon' },
  { label: '稀有', value: 'rare' }, { label: '史诗', value: 'epic' },
  { label: '传说', value: 'legendary' }, { label: '神话', value: 'mythic' },
  { label: '灵品', value: 'spiritual' }, { label: '玄品', value: 'mystic' },
  { label: '仙品', value: 'celestial' }, { label: '神品', value: 'divine' }
]
const sortOptions = [
  { label: '最新上架', value: 'time_desc' }, { label: '即将结束', value: 'time_asc' },
  { label: '价格从低到高', value: 'price_asc' }, { label: '价格从高到低', value: 'price_desc' }
]
const durationOptions = [
  { label: '12小时', value: 12 }, { label: '24小时', value: 24 }, { label: '48小时', value: 48 }
]

// === 浏览 ===
const filterType = ref(null)
const filterQuality = ref(null)
const sortBy = ref('time_desc')
const browseList = ref([])
const browseTotal = ref(0)
const browsePage = ref(1)
const browseLimit = 12
const browseLoading = ref(false)

async function loadBrowse() {
  browseLoading.value = true
  try {
    const params = new URLSearchParams({ page: browsePage.value, limit: browseLimit, sort: sortBy.value })
    if (filterType.value) params.set('type', filterType.value)
    if (filterQuality.value) params.set('quality', filterQuality.value)
    const data = await authStore.apiGet(`/auction/browse?${params}`)
    browseList.value = data.listings
    browseTotal.value = data.total
  } catch (e) { message.error(e.message) }
  browseLoading.value = false
}

// === 详情 ===
const showDetail = ref(false)
const detailData = ref(null)
const detailBids = ref([])
const detailLoading = ref(false)
const bidAmount = ref(0)
const bidLoading = ref(false)
const buyoutLoading = ref(false)

const minBidAmount = computed(() => {
  if (!detailData.value) return 0
  return detailData.value.current_bid > 0 ? Math.ceil(detailData.value.current_bid * 1.1) : detailData.value.starting_price
})

async function openDetail(id) {
  showDetail.value = true
  detailLoading.value = true
  try {
    const data = await authStore.apiGet(`/auction/detail/${id}`)
    detailData.value = data.listing
    detailBids.value = data.bids
    bidAmount.value = data.listing.current_bid > 0 ? Math.ceil(data.listing.current_bid * 1.1) : data.listing.starting_price
  } catch (e) { message.error(e.message) }
  detailLoading.value = false
}

async function doBid() {
  bidLoading.value = true
  try {
    const data = await authStore.apiPost('/auction/bid', { listing_id: detailData.value.id, amount: bidAmount.value })
    message.success(data.message)
    await openDetail(detailData.value.id)
    await authStore.saveToCloud(playerStore)
  } catch (e) { message.error(e.message) }
  bidLoading.value = false
}

async function doBuyout() {
  buyoutLoading.value = true
  try {
    const data = await authStore.apiPost('/auction/buyout', { listing_id: detailData.value.id })
    message.success(data.message)
    showDetail.value = false
    loadBrowse()
    await authStore.saveToCloud(playerStore)
  } catch (e) { message.error(e.message) }
  buyoutLoading.value = false
}

// === 上架 ===
const selectedListItem = ref(null)
const listPrice = ref(100)
const listBuyout = ref(null)
const listDuration = ref(24)
const listLoading = ref(false)

const listableItems = computed(() => {
  const items = playerStore.items || []
  const equipped = playerStore.equippedArtifacts || {}
  const equippedIds = Object.values(equipped).filter(Boolean).map(e => e.id)
  return items.filter(i => !equippedIds.includes(i.id))
})

async function doList() {
  if (!selectedListItem.value) return
  listLoading.value = true
  try {
    const data = await authStore.apiPost('/auction/list', {
      item_id: selectedListItem.value.id,
      starting_price: listPrice.value,
      buyout_price: listBuyout.value || undefined,
      duration_hours: listDuration.value
    })
    message.success(data.message)
    playerStore.spiritStones = data.spiritStones
    // Reload player data
    const pd = await authStore.apiGet('/game/load')
    if (pd.gameData) playerStore.$patch(pd.gameData)
    selectedListItem.value = null
    listPrice.value = 100
    listBuyout.value = null
  } catch (e) { message.error(e.message) }
  listLoading.value = false
}

// === 我的拍卖 ===
const myListings = ref([])
const myListLoading = ref(false)
const cancelLoading = ref(null)
const myBids = ref([])
const myBidsLoading = ref(false)

async function loadMyListings() {
  myListLoading.value = true
  try {
    const data = await authStore.apiGet('/auction/my-listings')
    myListings.value = data.listings
  } catch (e) { message.error(e.message) }
  myListLoading.value = false
}

async function loadMyBids() {
  myBidsLoading.value = true
  try {
    const data = await authStore.apiGet('/auction/my-bids')
    myBids.value = data.bids
  } catch (e) { message.error(e.message) }
  myBidsLoading.value = false
}

async function doCancel(id) {
  cancelLoading.value = id
  try {
    const data = await authStore.apiPost('/auction/cancel', { listing_id: id })
    message.success(data.message)
    const pd = await authStore.apiGet('/game/load')
    if (pd.gameData) playerStore.$patch(pd.gameData)
    loadMyListings()
  } catch (e) { message.error(e.message) }
  cancelLoading.value = null
}

// === 成交记录 ===
const historyList = ref([])
const historyLoading = ref(false)

async function loadHistory() {
  historyLoading.value = true
  try {
    const data = await authStore.apiGet('/auction/history')
    historyList.value = data.history
  } catch (e) { message.error(e.message) }
  historyLoading.value = false
}

// === 工具函数 ===
function getTypeEmoji(type) {
  const map = { equipment: '⚔️', herb: '🌿', pill: '💊', pet: '🐾', formula: '📜' }
  return map[type] || '📦'
}
function getQualityClass(item) {
  const q = item.item_quality || 'common'
  if (['mortal','spiritual','mystic','celestial','divine'].includes(q)) return 'pet-quality-' + q
  return 'quality-' + q
}
function getItemQualityClass(item) {
  const q = item.quality || item.rarity || 'common'
  if (['mortal','spiritual','mystic','celestial','divine'].includes(q)) return 'pet-quality-' + q
  return 'quality-' + q
}
function getQualityColor(item) {
  const q = item.item_quality || 'common'
  return (equipQuality[q] || petQuality[q] || { color: '#888' }).color
}
function getItemQualityColor(item) {
  const q = item.quality || item.rarity || 'common'
  return (equipQuality[q] || petQuality[q] || { color: '#888' }).color
}
function getQualityName(item) {
  const q = item.item_quality || 'common'
  return (equipQuality[q] || petQuality[q] || { name: '凡品' }).name
}
function getItemQualityName(item) {
  const q = item.quality || item.rarity || 'common'
  return (equipQuality[q] || petQuality[q] || { name: '凡品' }).name
}
function getTimeLeft(expiresAt) {
  const diff = new Date(expiresAt) - Date.now()
  if (diff <= 0) return { text: '已结束', urgent: true }
  const h = Math.floor(diff / 3600000)
  const m = Math.floor((diff % 3600000) / 60000)
  if (h > 0) return { text: `${h}时${m}分`, urgent: h < 1 }
  return { text: `${m}分钟`, urgent: true }
}
function formatTime(t) {
  if (!t) return ''
  const d = new Date(t)
  return `${d.getMonth()+1}/${d.getDate()} ${d.getHours()}:${String(d.getMinutes()).padStart(2,'0')}`
}
function statusText(s) {
  const map = { active: '进行中', sold: '已售出', expired: '已过期', cancelled: '已取消' }
  return map[s] || s
}
function statusTagType(s) {
  const map = { active: 'info', sold: 'success', expired: 'warning', cancelled: 'default' }
  return map[s] || 'default'
}

// === Tab 切换加载 ===
function onTabChange(tab) {
  if (tab === 'browse') loadBrowse()
  else if (tab === 'my') { loadMyListings(); loadMyBids() }
  else if (tab === 'history') loadHistory()
}

// 倒计时刷新
let timer = null
onMounted(() => {
  loadBrowse()
  timer = setInterval(() => {
    if (activeTab.value === 'browse') browseList.value = [...browseList.value]
  }, 60000)
})
onUnmounted(() => { if (timer) clearInterval(timer) })

// Watch tab changes
watch(activeTab, onTabChange)
</script>
<style scoped>
.auction-page { max-width: 800px; margin: 0 auto; padding: 8px; }
.auction-card { background: linear-gradient(135deg, #1a1a2e, #16213e) !important; border: 1px solid #333 !important; }
.auction-header { display: flex; align-items: center; gap: 8px; }
.header-icon { font-size: 24px; }
.header-title { font-size: 18px; font-weight: bold; background: linear-gradient(135deg, #FFD700, #FFA500); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }

.filter-bar { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 12px; align-items: center; }

.auction-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
@media (max-width: 600px) { .auction-grid { grid-template-columns: repeat(2, 1fr); } }

.auction-item-card {
  background: rgba(255,255,255,0.03); border-radius: 8px; padding: 10px; cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s; border: 1.5px solid #333;
}
.auction-item-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(255,215,0,0.15); }

.item-top-row { display: flex; align-items: center; gap: 6px; margin-bottom: 4px; }
.item-emoji { font-size: 20px; }
.item-name { font-size: 13px; font-weight: 600; color: #eee; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; flex: 1; }
.item-quality-tag { font-size: 11px; margin-bottom: 6px; font-weight: 600; }
.item-price-row { display: flex; justify-content: space-between; align-items: center; font-size: 12px; margin: 2px 0; }
.price-label { color: #999; }
.price-value { color: #FFD700; font-weight: 600; }
.buyout-price { color: #64b5f6; }
.item-bottom-row { display: flex; justify-content: space-between; align-items: center; margin-top: 6px; font-size: 11px; }
.bid-count { color: #999; }
.time-left { color: #aaa; }
.time-left.urgent { color: #f44336; font-weight: 600; animation: pulse-text 1s infinite; }
@keyframes pulse-text { 0%,100% { opacity: 1; } 50% { opacity: 0.6; } }

/* 上架 */
.listable-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; max-height: 300px; overflow-y: auto; }
.listable-item {
  display: flex; align-items: center; gap: 6px; padding: 8px 10px; border-radius: 6px;
  cursor: pointer; border: 1.5px solid #333; background: rgba(255,255,255,0.02); transition: all 0.2s;
}
.listable-item:hover { background: rgba(255,255,255,0.06); }
.listable-item.selected { border-color: #FFD700 !important; box-shadow: 0 0 10px rgba(255,215,0,0.3); background: rgba(255,215,0,0.05) !important; }
.item-quality-sm { font-size: 11px; margin-left: auto; font-weight: 600; }
.list-form { margin-top: 16px; }
.fee-preview { text-align: center; font-size: 13px; padding: 8px; background: rgba(255,152,0,0.1); border-radius: 6px; }

/* 我的拍卖 */
.my-list { display: flex; flex-direction: column; gap: 8px; }
.my-list-item { padding: 10px; border-radius: 6px; border: 1px solid #333; background: rgba(255,255,255,0.02); }
.my-item-info { display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px; }
.my-item-price { font-size: 12px; color: #999; margin-bottom: 4px; }

/* 成交记录 */
.history-list { display: flex; flex-direction: column; gap: 6px; }
.history-item { padding: 10px; border-radius: 6px; border: 1px solid #333; background: rgba(255,255,255,0.02); }
.history-item-name { font-weight: 600; margin-bottom: 4px; }
.history-item-detail { display: flex; justify-content: space-between; font-size: 12px; color: #999; flex-wrap: wrap; gap: 4px; }

/* 详情弹窗 */
.detail-content { }
.detail-item-header { display: flex; align-items: center; gap: 12px; padding: 12px; border-radius: 8px; border: 1.5px solid #333; }
.detail-item-name { font-size: 16px; font-weight: bold; color: #eee; }
.detail-item-quality { font-size: 13px; font-weight: 600; }
.detail-stats { display: grid; grid-template-columns: repeat(2, 1fr); gap: 4px; margin-top: 10px; }
.stat-row { display: flex; justify-content: space-between; padding: 4px 8px; background: rgba(255,255,255,0.03); border-radius: 4px; font-size: 12px; }
.stat-key { color: #999; }
.stat-val { color: #4caf50; font-weight: 600; }
.detail-price-info { display: flex; flex-direction: column; gap: 6px; font-size: 13px; }
.detail-actions { margin-top: 8px; }
.bid-history { max-height: 200px; overflow-y: auto; }
.bid-row { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 12px; }
.bid-amount { color: #FFD700; font-weight: 600; }
.bid-time { color: #666; }

/* 品质发光边框 - 复用 Inventory 风格 */
.quality-common { border-color: #888 !important; box-shadow: 0 0 5px rgba(136,136,136,0.3); }
.quality-uncommon { border-color: #4caf50 !important; box-shadow: 0 0 8px rgba(76,175,80,0.4); }
.quality-rare { border-color: #2196f3 !important; box-shadow: 0 0 10px rgba(33,150,243,0.4); }
.quality-epic { border-color: #9c27b0 !important; box-shadow: 0 0 12px rgba(156,39,176,0.5); }
.quality-legendary { border-color: #ff9800 !important; box-shadow: 0 0 15px rgba(255,152,0,0.5); }
.quality-mythic { border-color: #f44336 !important; box-shadow: 0 0 18px rgba(244,67,54,0.6); animation: mythic-glow 2s ease-in-out infinite; }
@keyframes mythic-glow { 0%,100% { box-shadow: 0 0 15px rgba(244,67,54,0.5); } 50% { box-shadow: 0 0 25px rgba(244,67,54,0.8); } }

.pet-quality-mortal { border-color: #32CD32 !important; box-shadow: 0 0 6px rgba(50,205,50,0.3); }
.pet-quality-spiritual { border-color: #1E90FF !important; box-shadow: 0 0 8px rgba(30,144,255,0.4); }
.pet-quality-mystic { border-color: #9932CC !important; box-shadow: 0 0 10px rgba(153,50,204,0.4); }
.pet-quality-celestial { border-color: #FFD700 !important; box-shadow: 0 0 12px rgba(255,215,0,0.5); }
.pet-quality-divine { border-color: #FF0000 !important; box-shadow: 0 0 15px rgba(255,0,0,0.5); animation: divine-glow 2s ease-in-out infinite; }
@keyframes divine-glow { 0%,100% { box-shadow: 0 0 12px rgba(255,0,0,0.5); } 50% { box-shadow: 0 0 22px rgba(255,0,0,0.8); } }
</style>
