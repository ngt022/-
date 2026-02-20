<template>
  <div class="events-page">
    <n-card>
      <n-space justify="end" style="margin-bottom: 8px">
        <n-tag type="warning" size="small">{{ activeEvents.length }} 个进行中</n-tag>
      </n-space>

      <n-space vertical :size="16" v-if="activeEvents.length > 0">
        <div v-for="evt in activeEvents" :key="evt.id" class="event-card" :class="'evt-type-' + evt.type">
          <div class="evt-header">
            <span class="evt-icon">{{ getIcon(evt.type) }}</span>
            <div class="evt-title-area">
              <n-text strong style="font-size:16px">{{ evt.name }}</n-text>
              <n-text depth="3" style="font-size:12px">{{ evt.description }}</n-text>
            </div>
            <div class="evt-countdown">
              <n-text type="warning" style="font-size:12px">{{ formatTimeLeft(evt.ends_at) }}</n-text>
            </div>
          </div>

          <div class="evt-body">
            <!-- 双倍冥想 -->
            <div v-if="evt.type === 'double_cultivation'" class="evt-effect">
              <n-tag type="success" size="small">焰力 x{{ evt.config?.multiplier || 2 }}</n-tag>
              <n-text depth="3" style="font-size:12px">冥想、探索获得的焰力翻倍</n-text>
            </div>

            <!-- 抽卡概率UP -->
            <div v-if="evt.type === 'gacha_rate_up'" class="evt-effect">
              <n-tag type="info" size="small">稀有概率 +{{ Math.round(((evt.config?.rateBoost || 1.5) - 1) * 100) }}%</n-tag>
              <n-text depth="3" style="font-size:12px">紫色及以上品质出率提升</n-text>
            </div>

            <!-- 登录奖励 -->
            <div v-if="evt.type === 'login_bonus'" class="evt-effect">
              <n-tag type="warning" size="small">每日 {{ evt.config?.dailyStones || 2000 }} 焰晶</n-tag>
              <n-button
                size="small"
                type="primary"
                :disabled="claimedIds.has(evt.id)"
                @click="claimReward(evt)"
                style="margin-left:8px"
              >
                {{ claimedIds.has(evt.id) ? '已领取' : '领取奖励' }}
              </n-button>
            </div>

            <!-- 双倍掉落 -->
            <div v-if="evt.type === 'double_drop'" class="evt-effect">
              <n-tag type="success" size="small">掉落 x{{ evt.config?.multiplier || 2 }}</n-tag>
              <n-text depth="3" style="font-size:12px">焚天塔、探索掉落翻倍</n-text>
            </div>

            <!-- 焰晶商铺折扣 -->
            <div v-if="evt.type === 'discount'" class="evt-effect">
              <n-tag type="error" size="small">{{ Math.round((evt.config?.discount || 0.8) * 100) / 10 }}折</n-tag>
              <n-text depth="3" style="font-size:12px">焰晶商铺全场限时折扣</n-text>
            </div>
          </div>

          <div class="evt-progress">
            <n-progress
              type="line"
              :percentage="getProgress(evt)"
              :color="getColor(evt.type)"
              :rail-color="'rgba(255,255,255,0.05)'"
              :height="4"
              :show-indicator="false"
            />
            <n-text depth="3" style="font-size:10px">
              {{ formatDate(evt.starts_at) }} — {{ formatDate(evt.ends_at) }}
            </n-text>
          </div>
        </div>
      </n-space>

      <n-empty v-else description="暂无进行中的活动" style="padding:40px 0">
        <template #icon><span style="font-size:40px">🎐</span></template>
      </n-empty>

      <!-- 当前生效的全局效果 -->
      <n-card v-if="effects && hasActiveEffects" title="⚡ 当前生效" size="small" style="margin-top:16px" :bordered="false" class="effects-card">
        <n-space :size="8" wrap>
          <n-tag v-if="effects.cultivationMultiplier > 1" type="success">焰力 x{{ effects.cultivationMultiplier }}</n-tag>
          <n-tag v-if="effects.gachaRateBoost > 1" type="info">抽卡概率 +{{ Math.round((effects.gachaRateBoost - 1) * 100) }}%</n-tag>
          <n-tag v-if="effects.dropMultiplier > 1" type="success">掉落 x{{ effects.dropMultiplier }}</n-tag>
          <n-tag v-if="effects.shopDiscount < 1" type="error">焰晶商铺 {{ Math.round(effects.shopDiscount * 100) / 10 }}折</n-tag>
        </n-space>
      </n-card>
    </n-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useMessage } from 'naive-ui'
import { usePlayerStore } from '../stores/player'
import sfx from '../plugins/sfx'

const message = useMessage()
const playerStore = usePlayerStore()

const activeEvents = ref([])
const effects = ref(null)
const claimedIds = ref(new Set())
let timer = null

const hasActiveEffects = computed(() => {
  if (!effects.value) return false
  const e = effects.value
  return e.cultivationMultiplier > 1 || e.gachaRateBoost > 1 || e.dropMultiplier > 1 || e.shopDiscount < 1
})

const fetchEvents = async () => {
  try {
    const [evtRes, effRes] = await Promise.all([
      fetch('/api/events/active'),
      fetch('/api/events/effects')
    ])
    const evtData = await evtRes.json()
    const effData = await effRes.json()
    activeEvents.value = evtData.events || []
    effects.value = effData.effects || null
  } catch {}
}

const claimReward = async (evt) => {
  try {
    const token = localStorage.getItem('xiuxian_token') || localStorage.getItem('roon_auth_token')
    const res = await fetch(`/api/events/${evt.id}/claim`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` }
    })
    const data = await res.json()
    if (data.ok) {
      claimedIds.value.add(evt.id)
      sfx.purchase()
      message.success(`领取成功！获得 ${data.stones} 焰晶`)
      playerStore.spiritStones += data.stones
      playerStore.saveData()
    } else {
      message.warning(data.error || '领取失败')
    }
  } catch {
    message.error('网络错误')
  }
}

const getIcon = (type) => {
  const icons = { double_cultivation: '⚡', gacha_rate_up: '🎴', double_drop: '💎', discount: '🏷️', login_bonus: '🎁' }
  return icons[type] || '🎉'
}

const getColor = (type) => {
  const colors = { double_cultivation: '#7c5cbf', gacha_rate_up: '#4caf50', double_drop: '#42a5f5', discount: '#e53935', login_bonus: '#d4a843' }
  return colors[type] || '#d4a843'
}

const getProgress = (evt) => {
  const start = new Date(evt.starts_at).getTime()
  const end = new Date(evt.ends_at).getTime()
  const now = Date.now()
  if (now >= end) return 100
  if (now <= start) return 0
  return Math.round((now - start) / (end - start) * 100)
}

const formatTimeLeft = (endsAt) => {
  const diff = new Date(endsAt).getTime() - Date.now()
  if (diff <= 0) return '已结束'
  const d = Math.floor(diff / 86400000)
  const h = Math.floor((diff % 86400000) / 3600000)
  const m = Math.floor((diff % 3600000) / 60000)
  if (d > 0) return `剩余 ${d}天${h}时`
  return `剩余 ${h}时${m}分`
}

const formatDate = (dt) => {
  const d = new Date(dt)
  return `${d.getMonth() + 1}/${d.getDate()} ${String(d.getHours()).padStart(2, '0')}:${String(d.getMinutes()).padStart(2, '0')}`
}

onMounted(() => {
  fetchEvents()
  timer = setInterval(fetchEvents, 60000)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<style scoped>
.events-page { max-width: 600px; margin: 0 auto; }

.event-card {
  padding: 16px;
  border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.15);
  background: rgba(18,18,26,0.7);
  backdrop-filter: blur(8px);
  transition: all 0.3s;
}
.event-card:hover {
  border-color: rgba(212,168,67,0.4);
  box-shadow: 0 0 20px rgba(212,168,67,0.08);
}

.evt-header {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 12px;
}
.evt-icon { font-size: 32px; flex-shrink: 0; }
.evt-title-area { flex: 1; display: flex; flex-direction: column; gap: 2px; }
.evt-countdown {
  flex-shrink: 0;
  padding: 2px 10px;
  border-radius: 12px;
  background: rgba(212,168,67,0.1);
  border: 1px solid rgba(212,168,67,0.2);
}

.evt-body { margin-bottom: 12px; }
.evt-effect { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }

.evt-progress { display: flex; flex-direction: column; gap: 4px; }

.evt-type-double_cultivation { border-left: 3px solid #7c5cbf; }
.evt-type-gacha_rate_up { border-left: 3px solid #4caf50; }
.evt-type-double_drop { border-left: 3px solid #42a5f5; }
.evt-type-discount { border-left: 3px solid #e53935; }
.evt-type-login_bonus { border-left: 3px solid #d4a843; }

.effects-card {
  background: rgba(212,168,67,0.05) !important;
  border: 1px solid rgba(212,168,67,0.15) !important;
}
</style>
