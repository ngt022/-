<template>
      <n-space vertical :size="16">
        <!-- 当前VIP -->
        <n-card v-if="authStore.isLoggedIn">
          <n-space vertical align="center">
            <n-text style="font-size:32px">{{ vipInfo.vipName || '普通' }}</n-text>
            <n-text>累计充值：{{ Number(vipInfo.totalRecharge || 0).toFixed(2) }} ROON</n-text>
            <n-progress v-if="vipInfo.nextLevel" type="line" :percentage="progressPct" :show-indicator="true">
              <template #default>距 {{ vipInfo.nextLevel.benefits.name }} 还需 {{ Number(vipInfo.nextLevel.need).toFixed(2) }} ROON</template>
            </n-progress>
            <n-text v-else type="success">已达最高VIP等级！</n-text>
          </n-space>
        </n-card>

        <!-- 当前特权 -->
        <n-card title="🌟 当前特权" v-if="vipInfo.benefits">
          <n-descriptions bordered :column="2">
            <n-descriptions-item label="冥想加速">{{ ((vipInfo.benefits.cultivationBoost - 1) * 100).toFixed(0) }}%</n-descriptions-item>
            <n-descriptions-item label="抽卡折扣">{{ ((1 - vipInfo.benefits.gachaDiscount) * 100).toFixed(0) }}%</n-descriptions-item>
            <n-descriptions-item label="额外掉落">{{ (vipInfo.benefits.extraDrop * 100).toFixed(0) }}%</n-descriptions-item>
          </n-descriptions>
        </n-card>

        <!-- VIP等级一览 -->
        <n-card title="📋 VIP等级一览">
          <n-data-table :columns="vipColumns" :data="vipInfo.allLevels || []" :bordered="false" size="small" />
        </n-card>

        <!-- 薪火令 -->
        <n-card title="💳 薪火令" v-if="authStore.isLoggedIn">
          <n-space vertical :size="12">
            <n-alert v-if="monthlyCard.active" type="success" :show-icon="false">
              <n-space justify="space-between" align="center">
                <span>薪火令生效中 · 已领 {{ monthlyCard.daysClaimed }} 天 · {{ monthlyCardDaysLeft }} 天后到期</span>
              </n-space>
            </n-alert>
            <n-alert v-else type="warning" :show-icon="false">
              开通薪火令，每日领取 5000 焰晶 + 冥想加速20% + 每日免费抽卡1次！仅需 10 ROON
            </n-alert>

            <n-space justify="center" :size="12">
              <n-button
                v-if="monthlyCard.active && !monthlyCard.claimedToday"
                type="success"
                size="large"
                @click="claimMonthlyCard"
                :loading="mcLoading"
              >
                🎁 领取今日 5000 焰晶
              </n-button>
              <n-button
                v-else-if="monthlyCard.active && monthlyCard.claimedToday"
                type="info"
                size="large"
                disabled
              >
                ✅ 今日已领取
              </n-button>
              <n-button
                v-if="!monthlyCard.active"
                type="warning"
                size="large"
                @click="buyMonthlyCard"
                :loading="mcLoading"
              >
                💳 开通薪火令 (10 ROON)
              </n-button>
              <n-button
                v-if="monthlyCard.active"
                type="warning"
                size="small"
                @click="buyMonthlyCard"
                :loading="mcLoading"
              >
                续费薪火令
              </n-button>
            </n-space>

            <n-descriptions bordered :column="2" size="small">
              <n-descriptions-item label="价格">10 ROON</n-descriptions-item>
              <n-descriptions-item label="每日焰晶">5000</n-descriptions-item>
              <n-descriptions-item label="冥想加速">+20%</n-descriptions-item>
              <n-descriptions-item label="每日免费抽卡">1次</n-descriptions-item>
              <n-descriptions-item label="有效期">30 天</n-descriptions-item>
              <n-descriptions-item label="总焰晶价值">150000</n-descriptions-item>
            </n-descriptions>
          </n-space>
        </n-card>

        <!-- 每日燃火 -->
        <n-card title="📅 每日燃火">
          <n-space vertical>
            <n-grid :cols="7" :x-gap="8" :y-gap="8">
              <n-gi v-for="(r, i) in signRewards" :key="i">
                <n-card size="small" :class="{ 'sign-done': i < (authStore.dailySignStreak || 0) }">
                  <n-space vertical align="center" :size="4">
                    <n-text strong>第{{ i + 1 }}天</n-text>
                    <n-text style="font-size:12px">{{ r.stones }}焰晶</n-text>
                    <n-text style="font-size:11px;color:#999">{{ r.items }}</n-text>
                  </n-space>
                </n-card>
              </n-gi>
            </n-grid>
            <n-button type="success" block @click="doSign" :disabled="signedToday" :loading="signing">
              {{ signedToday ? '今日已燃火 ✓' : '立即燃火' }}
            </n-button>
          </n-space>
        </n-card>
      </n-space>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'
import { useMessage } from 'naive-ui'

const authStore = useAuthStore()
const playerStore = usePlayerStore()
const message = useMessage()

const vipInfo = ref({})
const signing = ref(false)
const monthlyCard = ref({ active: false, daysClaimed: 0, claimedToday: false })
const mcLoading = ref(false)

const monthlyCardDaysLeft = computed(() => {
  if (!monthlyCard.value.expiresAt) return 0
  const diff = new Date(monthlyCard.value.expiresAt).getTime() - Date.now()
  return Math.max(0, Math.ceil(diff / 86400000))
})

const loadMonthlyCard = async () => {
  try {
    const res = await fetch('/api/monthly-card/status', {
      headers: { 'Authorization': `Bearer ${authStore.token}` }
    })
    monthlyCard.value = await res.json()
  } catch {}
}

const buyMonthlyCard = async () => {
  if (!window.ethereum) return message.error('请安装 MetaMask 钱包')
  mcLoading.value = true
  try {
    const { BrowserProvider, parseEther } = await import('ethers')
    const provider = new BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()
    const tx = await signer.sendTransaction({
      to: '0xBce51d77b325C1A42d2aF8359f9744699102698e',
      value: parseEther('10')
    })
    message.info('交易已发送，等待确认...')
    await tx.wait()

    const res = await fetch('/api/monthly-card/buy', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${authStore.token}` },
      body: JSON.stringify({ txHash: tx.hash })
    })
    const data = await res.json()
    if (!res.ok) throw new Error(data.error)

    message.success('薪火令开通成功！每日可领取 3000 焰晶')
    await loadMonthlyCard()
  } catch (e) {
    message.error(e.message || '购买失败')
  } finally {
    mcLoading.value = false
  }
}

const claimMonthlyCard = async () => {
  mcLoading.value = true
  try {
    const res = await fetch('/api/monthly-card/claim', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${authStore.token}` }
    })
    const data = await res.json()
    if (!res.ok) throw new Error(data.error)

    playerStore.spiritStones += data.stones
    playerStore.saveData()
    message.success(`领取成功！获得 ${data.stones} 焰晶`)
    await loadMonthlyCard()
  } catch (e) {
    message.error(e.message || '领取失败')
  } finally {
    mcLoading.value = false
  }
}

const signRewards = [
  { day: 1, stones: 500, items: '淬火石x2' },
  { day: 2, stones: 800, items: '符文石x2' },
  { day: 3, stones: 1000, items: '淬火石x5' },
  { day: 4, stones: 1500, items: '符文石x5' },
  { day: 5, stones: 2000, items: '淬火石x10' },
  { day: 6, stones: 3000, items: '符文石x10' },
  { day: 7, stones: 5000, items: '源火碎片x1' },
]

const signedToday = computed(() => {
  return authStore.dailySignDate === new Date().toISOString().split('T')[0]
})

const progressPct = computed(() => {
  if (!vipInfo.value.nextLevel) return 100
  const current = Number(vipInfo.value.totalRecharge || 0)
  const need = Number(vipInfo.value.nextLevel.benefits.minRecharge)
  const prev = vipInfo.value.benefits?.minRecharge || 0
  return Math.min(100, Math.floor(((current - prev) / (need - prev)) * 100))
})

const vipColumns = [
  { title: '等级', key: 'name' },
  { title: '充值(ROON)', key: 'minRecharge' },
  { title: '冥想加速', key: 'cultivationBoost', render: (r) => `+${((r.cultivationBoost - 1) * 100).toFixed(0)}%` },
  { title: '抽卡折扣', key: 'gachaDiscount', render: (r) => `${((1 - r.gachaDiscount) * 100).toFixed(0)}%` },
  { title: '额外掉落', key: 'extraDrop', render: (r) => `+${(r.extraDrop * 100).toFixed(0)}%` },
]

const doSign = async () => {
  signing.value = true
  try {
    const data = await authStore.dailySign()
    playerStore.spiritStones += data.reward.stones
    // 签到物品奖励
    const itemRewards = {
      '淬火石x2': { key: 'reinforceStones', amount: 2 },
      '符文石x2': { key: 'refinementStones', amount: 2 },
      '淬火石x5': { key: 'reinforceStones', amount: 5 },
      '符文石x5': { key: 'refinementStones', amount: 5 },
      '淬火石x10': { key: 'reinforceStones', amount: 10 },
      '符文石x10': { key: 'refinementStones', amount: 10 },
    }
    const reward = itemRewards[data.reward.items]
    if (reward) playerStore[reward.key] += reward.amount
    playerStore.saveData()
    message.success(`燃火成功！第${data.streak}天，获得 ${data.reward.stones} 焰晶 + ${data.reward.items}`)
  } catch (e) {
    message.error(e.message)
  } finally {
    signing.value = false
  }
}

onMounted(async () => {
  if (authStore.isLoggedIn) {
    try { vipInfo.value = await authStore.getVipInfo() } catch {}
    await loadMonthlyCard()
  }
})
</script>

<style scoped>
.vip-content { padding: 16px; }
.sign-done { background: #e8f5e9; border-color: #4caf50; }
</style>
