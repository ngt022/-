<template>
      <n-space vertical :size="16">
        <n-radio-group v-model:value="rankType" @update:value="loadRank">
          <n-radio-button value="power">⚔️ 战力焰榜</n-radio-button>
          <n-radio-button value="level">🏔️ 焰阶榜</n-radio-button>
          <n-radio-button value="recharge">💰 充值焰榜</n-radio-button>
        </n-radio-group>

        <n-card>
          <n-data-table :columns="currentColumns" :data="rankData" :bordered="false" :loading="loading" size="small" />
        </n-card>
      </n-space>
</template>

<script setup>
import { ref, computed, onMounted, h } from 'vue'
import { useAuthStore } from '../stores/auth'
import { NText, NTag } from 'naive-ui'

const authStore = useAuthStore()
const rankType = ref('power')
const rankData = ref([])
const loading = ref(false)

const rankCol = { title: '#', key: 'rank', width: 50, render: (r) => {
  const colors = { 1: '#FFD700', 2: '#C0C0C0', 3: '#CD7F32' }
  return h(NText, { strong: true, style: { color: colors[r.rank] || '' } }, () => r.rank)
}}
const nameCol = { title: '焰名', key: 'name' }
const walletCol = { title: '钱包', key: 'wallet', width: 120 }
const vipCol = { title: 'VIP', key: 'vip_level', width: 60, render: (r) => {
  if (!r.vip_level) return ''
  return h(NTag, { type: 'warning', size: 'small' }, () => `V${r.vip_level}`)
}}

const powerColumns = [rankCol, nameCol, walletCol, vipCol,
  { title: '战力', key: 'combat_power', render: (r) => Number(r.combat_power).toLocaleString() },
  { title: '焰阶', key: 'realm' },
]
const levelColumns = [rankCol, nameCol, walletCol, vipCol,
  { title: '焰阶', key: 'realm' },
  { title: '等级', key: 'level' },
  { title: '战力', key: 'combat_power', render: (r) => Number(r.combat_power).toLocaleString() },
]
const rechargeColumns = [rankCol, nameCol, walletCol, vipCol,
  { title: '充值(ROON)', key: 'total_recharge', render: (r) => Number(r.total_recharge).toFixed(2) },
]

const currentColumns = computed(() => {
  switch (rankType.value) {
    case 'power': return powerColumns
    case 'level': return levelColumns
    case 'recharge': return rechargeColumns
    default: return powerColumns
  }
})

const loadRank = async () => {
  loading.value = true
  try {
    const data = await authStore.getLeaderboard(rankType.value)
    rankData.value = data.data || []
  } catch {} finally {
    loading.value = false
  }
}

onMounted(() => loadRank())
</script>

<style scoped>
.rank-content { padding: 16px; }
</style>
