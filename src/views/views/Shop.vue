<template>
  <n-card>
    <n-space vertical :size="16">
      <n-alert type="info" :show-icon="false">
        当前焰晶：<n-text strong type="warning">{{ playerStore.spiritStones }}</n-text>
      </n-alert>

      <!-- 商品分类 -->
      <n-tabs type="segment" v-model:value="activeTab">
        <n-tab-pane name="materials" tab="🔧 材料">
          <n-grid :cols="2" :x-gap="12" :y-gap="12" style="margin-top:12px">
            <n-gi v-for="item in materialItems" :key="item.id">
              <n-card size="small" hoverable class="shop-item" @click="buyItem(item)">
                <div class="item-icon">{{ item.icon }}</div>
                <div class="item-info">
                  <n-text strong>{{ item.name }}</n-text>
                  <n-text depth="3" style="font-size:12px">{{ item.desc }}</n-text>
                  <n-space align="center" :size="4" style="margin-top:4px">
                    <n-tag type="warning" size="small">{{ item.price }} 焰晶</n-tag>
                    <n-text depth="3" style="font-size:11px">库存: ∞</n-text>
                  </n-space>
                </div>
              </n-card>
            </n-gi>
          </n-grid>
        </n-tab-pane>

        <n-tab-pane name="pills" tab="💊 焰方">
          <n-grid :cols="2" :x-gap="12" :y-gap="12" style="margin-top:12px">
            <n-gi v-for="item in pillItems" :key="item.id">
              <n-card size="small" hoverable class="shop-item" @click="buyItem(item)">
                <div class="item-icon">{{ item.icon }}</div>
                <div class="item-info">
                  <n-text strong>{{ item.name }}</n-text>
                  <n-text depth="3" style="font-size:12px">{{ item.desc }}</n-text>
                  <n-space align="center" :size="4" style="margin-top:4px">
                    <n-tag type="warning" size="small">{{ item.price }} 焰晶</n-tag>
                  </n-space>
                </div>
              </n-card>
            </n-gi>
          </n-grid>
        </n-tab-pane>

        <n-tab-pane name="packs" tab="🎁 礼包">
          <n-grid :cols="1" :x-gap="12" :y-gap="12" style="margin-top:12px">
            <n-gi v-for="item in packItems" :key="item.id">
              <n-card size="small" hoverable class="shop-item pack-item" @click="buyItem(item)">
                <div class="item-icon">{{ item.icon }}</div>
                <div class="item-info">
                  <n-text strong>{{ item.name }}</n-text>
                  <n-text depth="3" style="font-size:12px">{{ item.desc }}</n-text>
                  <n-space align="center" :size="4" style="margin-top:4px">
                    <n-tag type="warning" size="small">{{ item.price }} 焰晶</n-tag>
                    <n-tag v-if="item.discount" type="error" size="small">{{ item.discount }}</n-tag>
                  </n-space>
                </div>
              </n-card>
            </n-gi>
          </n-grid>
        </n-tab-pane>
      </n-tabs>
    </n-space>
  </n-card>

  <!-- 购买弹窗 -->
  <n-modal v-model:show="showBuyModal" preset="dialog" title="购买确认" positive-text="购买" negative-text="取消"
    @positive-click="confirmBuy" @negative-click="showBuyModal = false">
    <n-space vertical align="center" v-if="selectedItem">
      <span style="font-size:40px">{{ selectedItem.icon }}</span>
      <n-text strong>{{ selectedItem.name }}</n-text>
      <n-input-number v-model:value="buyCount" :min="1" :max="99" size="small" style="width:120px" />
      <n-text>总价：<n-text type="warning" strong>{{ selectedItem.price * buyCount }}</n-text> 焰晶</n-text>
    </n-space>
  </n-modal>
</template>

<script setup>
import { ref } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useMessage } from 'naive-ui'
import sfx from '../plugins/sfx'

const playerStore = usePlayerStore()
const message = useMessage()

const activeTab = ref('materials')
const showBuyModal = ref(false)
const selectedItem = ref(null)
const buyCount = ref(1)

const materialItems = [
  { id: 'reinforce_1', name: '淬火石 x1', icon: '🔨', price: 500, desc: '装备淬火必备材料', give: { reinforceStones: 1 } },
  { id: 'reinforce_10', name: '淬火石 x10', icon: '🔨', price: 4500, desc: '批量购买9折优惠', give: { reinforceStones: 10 }, discount: '9折' },
  { id: 'refine_1', name: '符文石 x1', icon: '💠', price: 800, desc: '重置装备副属性', give: { refinementStones: 1 } },
  { id: 'refine_10', name: '符文石 x10', icon: '💠', price: 7200, desc: '批量购买9折优惠', give: { refinementStones: 10 }, discount: '9折' },
]

const pillItems = [
  { id: 'pill_frag_health', name: '回春焰丹碎片 x1', icon: '🧩', price: 1000, desc: '收集5个合成回春焰方', give: { pillFragment: 'health_pill' } },
  { id: 'pill_frag_attack', name: '破军焰丹碎片 x1', icon: '🧩', price: 1500, desc: '收集5个合成破军焰方', give: { pillFragment: 'attack_pill' } },
  { id: 'pill_frag_defense', name: '金钟焰丹碎片 x1', icon: '🧩', price: 1500, desc: '收集5个合成金钟焰方', give: { pillFragment: 'defense_pill' } },
  { id: 'pill_frag_speed', name: '疾风焰丹碎片 x1', icon: '🧩', price: 1200, desc: '收集5个合成疾风焰方', give: { pillFragment: 'speed_pill' } },
]

const packItems = [
  { id: 'pack_starter', name: '修焰者礼包', icon: '🎁', price: 5000, desc: '淬火石x5 + 符文石x3 + 回春焰丹碎片x1', discount: '超值',
    give: { reinforceStones: 5, refinementStones: 3, pillFragment: 'health_pill' } },
  { id: 'pack_advanced', name: '铸炉者礼包', icon: '🎊', price: 15000, desc: '淬火石x20 + 符文石x10 + 随机焰方碎片x3', discount: '限量',
    give: { reinforceStones: 20, refinementStones: 10, randomPillFragments: 3 } },
]

const buyItem = (item) => {
  selectedItem.value = item
  buyCount.value = 1
  showBuyModal.value = true
}

const confirmBuy = () => {
  const item = selectedItem.value
  if (!item) return

  const totalPrice = item.price * buyCount.value
  if (playerStore.spiritStones < totalPrice) {
    message.error('焰晶不足！')
    sfx.error()
    return
  }

  playerStore.spiritStones -= totalPrice

  for (let i = 0; i < buyCount.value; i++) {
    const give = item.give
    if (give.reinforceStones) playerStore.reinforceStones += give.reinforceStones
    if (give.refinementStones) playerStore.refinementStones += give.refinementStones
    if (give.pillFragment) {
      if (!playerStore.pillFragments[give.pillFragment]) {
        playerStore.pillFragments[give.pillFragment] = 0
      }
      playerStore.pillFragments[give.pillFragment] += 1
    }
    if (give.randomPillFragments) {
      const pillIds = ['health_pill', 'attack_pill', 'defense_pill', 'speed_pill']
      for (let j = 0; j < give.randomPillFragments; j++) {
        const pid = pillIds[Math.floor(Math.random() * pillIds.length)]
        if (!playerStore.pillFragments[pid]) playerStore.pillFragments[pid] = 0
        playerStore.pillFragments[pid] += 1
      }
    }
  }

  playerStore.saveData()
  sfx.purchase()
  message.success(`购买成功！${item.name} x${buyCount.value}`)
  showBuyModal.value = false
}
</script>

<style scoped>
.shop-item {
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 12px;
}
.shop-item:hover {
  transform: translateY(-2px);
  border-color: rgba(212,168,67,0.5) !important;
  box-shadow: 0 0 15px rgba(212,168,67,0.1);
}
.shop-item :deep(.n-card__content) {
  display: flex;
  align-items: center;
  gap: 12px;
}
.item-icon {
  font-size: 32px;
  flex-shrink: 0;
}
.item-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.pack-item {
  border-color: rgba(212,168,67,0.3) !important;
  background: linear-gradient(135deg, rgba(61,43,31,0.3), rgba(18,18,26,0.7)) !important;
}
</style>
