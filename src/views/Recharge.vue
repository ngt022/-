<template>
      <n-space vertical :size="16">
        <!-- 首充提示 -->
        <n-alert v-if="authStore.isLoggedIn && !authStore.firstRecharge" type="success" title="🎁 首充双倍！">
          首次充值焰晶翻倍，不要错过！
        </n-alert>

        <!-- 充值面板 -->
        <n-card title="💎 焰晶充值" v-if="authStore.isLoggedIn">
          <n-space vertical>
            <n-text>汇率：1 ROON = 10,000 焰晶</n-text>
            <n-text v-if="!authStore.firstRecharge" type="success">首充双倍：1 ROON = 20,000 焰晶！</n-text>
            <n-grid :cols="3" :x-gap="12" :y-gap="12">
              <n-gi v-for="pkg in packages" :key="pkg.roon">
                <n-card hoverable size="small" @click="selectPackage(pkg)" 
                  :class="{ selected: selectedPkg?.roon === pkg.roon }">
                  <n-space vertical align="center">
                    <n-text strong style="font-size:18px">{{ pkg.roon }} ROON</n-text>
                    <n-text type="warning">{{ pkg.stones.toLocaleString() }} 焰晶</n-text>
                    <n-text v-if="!authStore.firstRecharge" type="success" style="font-size:12px">
                      首充：{{ (pkg.stones * 2).toLocaleString() }}
                    </n-text>
                  </n-space>
                </n-card>
              </n-gi>
            </n-grid>
            <n-input-number v-model:value="customAmount" :min="0.1" :step="1" placeholder="自定义金额 (ROON)" @update:value="onCustomInput">
              <template #prefix>ROON</template>
            </n-input-number>
            <n-button type="primary" block :loading="isRecharging" @click="doRecharge" :disabled="!selectedPkg && !customAmount">
              {{ isRecharging ? '处理中...' : '立即充值' }}
            </n-button>
          </n-space>
        </n-card>

        <n-card v-else title="请先登录">
          <n-text>连接钱包后即可充值</n-text>
        </n-card>

        <!-- 充值记录 -->
        <n-card title="📜 充值记录" v-if="authStore.isLoggedIn">
          <n-data-table :columns="columns" :data="records" :bordered="false" size="small" />
        </n-card>
      </n-space>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'
import { useMessage } from 'naive-ui'
import { BrowserProvider, parseEther } from 'ethers'

const authStore = useAuthStore()
const playerStore = usePlayerStore()
const message = useMessage()

const VAULT = '0xBce51d77b325C1A42d2aF8359f9744699102698e'
const isRecharging = ref(false)
const customAmount = ref(null)
const selectedPkg = ref(null)
const records = ref([])

const packages = [
  { roon: 1, stones: 10000 },
  { roon: 5, stones: 50000 },
  { roon: 10, stones: 100000 },
  { roon: 50, stones: 500000 },
  { roon: 100, stones: 1000000 },
  { roon: 500, stones: 5000000 },
]

const columns = [
  { title: '金额(ROON)', key: 'amount', render: (r) => Number(r.amount).toFixed(2) },
  { title: '焰晶', key: 'spirit_stones', render: (r) => Number(r.spirit_stones).toLocaleString() },
  { title: '赠送', key: 'bonus_stones', render: (r) => Number(r.bonus_stones).toLocaleString() },
  { title: '时间', key: 'created_at', render: (r) => new Date(r.created_at).toLocaleString() },
]

const selectPackage = (pkg) => { selectedPkg.value = pkg; customAmount.value = null }
const onCustomInput = (val) => { if (val) selectedPkg.value = null }

const doRecharge = async () => {
  const amount = selectedPkg.value?.roon || customAmount.value
  if (!amount || amount <= 0) return message.warning('请选择充值金额')
  
  isRecharging.value = true
  try {
    const provider = new BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()
    const tx = await signer.sendTransaction({
      to: VAULT,
      value: parseEther(amount.toString())
    })
    message.info('交易已发送，等待确认...')
    await tx.wait()
    
    const result = await authStore.confirmRecharge(tx.hash)
    playerStore.spiritStones += result.spiritStones
    playerStore.saveData()
    
    message.success(`充值成功！获得 ${result.spiritStones.toLocaleString()} 焰晶` + 
      (result.bonusStones > 0 ? `（含首充赠送 ${result.bonusStones.toLocaleString()}）` : ''))
    
    if (result.vipLevel > 0) message.info(`VIP等级提升至 VIP${result.vipLevel}`)
    
    loadRecords()
  } catch (e) {
    message.error('充值失败：' + (e.reason || e.message))
  } finally {
    isRecharging.value = false
  }
}

const loadRecords = async () => {
  try {
    const data = await authStore.getRechargeHistory()
    records.value = data.records || []
  } catch {}
}

onMounted(() => { if (authStore.isLoggedIn) loadRecords() })
</script>

<style scoped>
.recharge-content { padding: 16px; }
.selected { border: 2px solid #2080f0; }
</style>
