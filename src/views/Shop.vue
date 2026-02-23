<template>
  <div class="shop-page">
    <!-- 顶部焰晶余额 -->
    <div class="balance-bar">
      <span class="balance-icon">💎</span>
      <span class="balance-label">焰晶余额</span>
      <span class="balance-value">{{ formatNum(playerStore.spiritStones) }}</span>
    </div>

    <n-tabs type="segment" v-model:value="activeTab" animated class="shop-tabs">
      <!-- ⚔️ 装备商城 -->
      <n-tab-pane name="equip" tab="⚔️ 装备">
        <n-tabs type="line" v-model:value="equipQuality" class="quality-tabs">
          <n-tab-pane v-for="q in equipQualities" :key="q.key" :name="q.key" :tab="q.label">
            <div class="equip-grid">
              <div v-for="slot in equipSlots" :key="slot.key"
                class="equip-card" :style="{ borderColor: q.color + '80' }"
                @click="openEquipBuy(q, slot)">
                <div class="card-glow" :style="{ background: q.color + '15' }"></div>
                <img :src="slot.img" class="equip-icon-img" />
                <div class="equip-name" :style="{ color: q.color }">{{ q.prefix }}{{ slot.name }}</div>
                <div class="equip-price">💎 {{ formatNum(q.price) }}</div>
              </div>
            </div>
          </n-tab-pane>
        </n-tabs>
      </n-tab-pane>

      <!-- 💊 焰丹商城 -->
      <n-tab-pane name="pill" tab="💊 焰丹">
        <div class="section-title">🔮 焰灵药水</div>
        <div class="item-grid">
          <div v-for="p in spiritPills" :key="p.id" class="item-card pill-card" @click="openPillBuy(p)">
            <img v-if="p.img" :src="p.img" class="shop-item-img" /><div v-else class="item-icon">{{ p.icon }}</div>
            <div class="item-name">{{ p.name }}</div>
            <div class="item-desc">{{ p.desc }}</div>
            <div class="item-price">💎 {{ formatNum(p.price) }}</div>
          </div>
        </div>
        <div class="section-title">📿 修为丹</div>
        <div class="item-grid">
          <div v-for="p in cultPills" :key="p.id" class="item-card pill-card" @click="openPillBuy(p)">
            <img v-if="p.img" :src="p.img" class="shop-item-img" /><div v-else class="item-icon">{{ p.icon }}</div>
            <div class="item-name">{{ p.name }}</div>
            <div class="item-desc">{{ p.desc }}</div>
            <div class="item-price">💎 {{ formatNum(p.price) }}</div>
          </div>
        </div>
        <div class="section-title">⬆️ 经验丹</div>
        <div class="item-grid">
          <div v-for="p in expPills" :key="p.id" class="item-card pill-card exp-card" @click="openPillBuy(p)">
            <img v-if="p.img" :src="p.img" class="shop-item-img" /><div v-else class="item-icon">{{ p.icon }}</div>
            <div class="item-name">{{ p.name }}</div>
            <div class="item-desc">{{ p.desc }}</div>
            <div class="item-price">💎 {{ formatNum(p.price) }}</div>
          </div>
        </div>
        <div class="section-title">💪 属性丹 (永久)</div>
        <div class="item-grid">
          <div v-for="p in attrPills" :key="p.id" class="item-card pill-card attr-card" @click="openPillBuy(p)">
            <img v-if="p.img" :src="p.img" class="shop-item-img" /><div v-else class="item-icon">{{ p.icon }}</div>
            <div class="item-name">{{ p.name }}</div>
            <div class="item-desc">{{ p.desc }}</div>
            <div class="item-price">💎 {{ formatNum(p.price) }}</div>
          </div>
        </div>
        <div class="section-title">🧩 焰方碎片</div>
        <div class="item-grid">
          <div v-for="p in fragItems" :key="p.id" class="item-card pill-card" @click="openMaterialBuy(p)">
            <img v-if="p.img" :src="p.img" class="shop-item-img" /><div v-else class="item-icon">{{ p.icon }}</div>
            <div class="item-name">{{ p.name }}</div>
            <div class="item-desc">{{ p.desc }}</div>
            <div class="item-price">💎 {{ formatNum(p.price) }}</div>
          </div>
        </div>
      </n-tab-pane>

      <!-- 🌿 焰草商城 -->
      <n-tab-pane name="herb" tab="🌿 焰草">
        <n-tabs type="line" v-model:value="selectedHerbQuality" class="quality-tabs">
          <n-tab-pane v-for="q in herbQualityOptions" :key="q.key" :name="q.key" :tab="q.label">
            <div class="item-grid">
              <div v-for="herb in herbShopItems" :key="herb.id" class="item-card herb-card" @click="openHerbBuy(herb)">
                <img v-if="herb.img" :src="herb.img" class="shop-item-img" />
                <div v-else class="item-icon">🌿</div>
                <div class="item-name" :style="{ color: q.color }">{{ herb.name }}</div>
                <div class="item-desc">{{ herb.desc }}</div>
                <div class="item-price">💎 {{ formatNum(Math.floor(herb.baseValue * q.mult * 100)) }}</div>
                <n-tag size="tiny" :style="{ background: q.color + '30', color: q.color, borderColor: q.color }" class="tier-tag">{{ herb.grade }}品</n-tag>
              </div>
            </div>
          </n-tab-pane>
        </n-tabs>
      </n-tab-pane>

      <!-- 📜 焰方商城 -->
      <n-tab-pane name="formula" tab="📜 焰方">
        <div class="item-grid formula-grid">
          <div v-for="formula in formulaShopItems" :key="formula.id" class="item-card formula-card" @click="openFormulaBuy(formula)"
            :class="{ 'owned': playerStore.pillRecipes.includes(formula.id) }">
            <img v-if="formula.img" :src="formula.img" class="shop-item-img" />
            <div v-else class="item-icon">📜</div>
            <div class="item-name">{{ formula.name }}</div>
            <n-tag size="tiny" type="info" class="grade-tag">{{ formula.grade }}</n-tag>
            <div class="item-desc">{{ formula.desc }}</div>
            <div class="item-price">💎 {{ formatNum(formula.price) }}</div>
            <div v-if="playerStore.pillRecipes.includes(formula.id)" class="owned-badge">已拥有</div>
          </div>
        </div>
      </n-tab-pane>

      <!-- 🔧 材料商城 -->
      <n-tab-pane name="material" tab="🔧 材料">
        <div class="item-grid">
          <div v-for="m in materialItems" :key="m.id" class="item-card material-card" @click="openMaterialBuy(m)">
            <img v-if="m.img" :src="m.img" class="shop-item-img" /><div v-else class="item-icon">{{ m.icon }}</div>
            <div class="item-name">{{ m.name }}</div>
            <div class="item-desc">{{ m.desc }}</div>
            <div class="item-price">💎 {{ formatNum(m.price) }}</div>
            <n-tag v-if="m.discount" type="error" size="tiny" class="discount-tag">{{ m.discount }}</n-tag>
          </div>
        </div>
      </n-tab-pane>

      <!-- 🎁 礼包商城 -->
      <n-tab-pane name="pack" tab="🎁 礼包">
        <div class="pack-list">
          <div v-for="pk in packItems" :key="pk.id"
            class="pack-card" :class="{ purchased: purchasedPacks.includes(pk.id) }"
            @click="openPackBuy(pk)">
            <div class="pack-badge">超值</div>
            <img v-if="pk.img" :src="pk.img" class="shop-pack-img" /><div v-else class="pack-icon">{{ pk.icon }}</div>
            <div class="pack-info">
              <div class="pack-name">{{ pk.name }}</div>
              <div class="pack-desc">{{ pk.desc }}</div>
              <div class="pack-price">💎 {{ formatNum(pk.price) }}</div>
            </div>
            <div v-if="purchasedPacks.includes(pk.id)" class="pack-sold">已购买</div>
          </div>
        </div>
      </n-tab-pane>

      <!-- 💎 特权商城 -->
      <n-tab-pane name="buff" tab="💎 特权">
        <div class="item-grid buff-grid">
          <div v-for="b in buffItems" :key="b.id" class="item-card buff-card" @click="openBuffBuy(b)">
            <img v-if="b.img" :src="b.img" class="shop-item-img" /><div v-else class="item-icon">{{ b.icon }}</div>
            <div class="item-name">{{ b.name }}</div>
            <div class="item-desc">{{ b.desc }}</div>
            <div class="item-price">💎 {{ formatNum(b.price) }}</div>
            <div v-if="getBuffRemaining(b.buffKey)" class="buff-active">
              ⏳ 剩余 {{ getBuffRemaining(b.buffKey) }}
            </div>
          </div>
        </div>
      </n-tab-pane>
    </n-tabs>

    <!-- 购买确认弹窗 -->
    <n-modal v-model:show="showBuyModal" preset="card" :title="buyModalTitle"
      style="width:340px;max-width:90vw" :bordered="false" class="buy-modal">
      <div class="buy-content" v-if="buyTarget">
        <img v-if="buyTarget.img" :src="buyTarget.img" class="buy-icon-img" /><div v-else class="buy-icon">{{ buyTarget.icon || '📦' }}</div>
        <div class="buy-name">{{ buyTarget.name }}</div>
        <div class="buy-desc">{{ buyTarget.desc || '' }}</div>
        <div v-if="buyTarget.canMulti" class="buy-count">
          <span>数量</span>
          <n-input-number v-model:value="buyCount" :min="1" :max="99" size="small" style="width:100px" />
        </div>
        <div class="buy-total">
          总价：<span class="total-price">💎 {{ formatNum(buyTarget.price * buyCount) }}</span>
        </div>
        <n-button type="warning" block strong :loading="isBuying" @click="confirmBuy" :disabled="playerStore.spiritStones < buyTarget.price * buyCount">
          {{ playerStore.spiritStones < buyTarget.price * buyCount ? '焰晶不足' : '确认购买' }}
        </n-button>
      </div>
    </n-modal>
  </div>
</template>

<script setup>
import img from '../utils/img.js'
import { ref, onMounted, computed } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { useMessage } from 'naive-ui'
import sfx from '../plugins/sfx'

const playerStore = usePlayerStore()
const authStore = useAuthStore()
const message = useMessage()

const activeTab = ref('equip')
const equipQuality = ref('rare')
const showBuyModal = ref(false)
const buyTarget = ref(null)
const buyCount = ref(1)
const isBuying = ref(false)
const buyModalTitle = ref('购买确认')
const purchasedPacks = ref([])
const playerBuffs = ref({})

const formatNum = (n) => {
  if (!n) return '0'
  return Number(n).toLocaleString()
}

// 装备品质
const equipQualities = [
  { key: 'rare', label: '🔵 中品', color: '#2196f3', prefix: '中品·', price: 2000 },
  { key: 'epic', label: '🟣 上品', color: '#9c27b0', prefix: '上品·', price: 8000 },
  { key: 'legendary', label: '🟠 极品(周限1)', color: '#ff9800', prefix: '极品·', price: 30000 },
]

// 装备部位
const equipSlotImages = {
  weapon: img('/assets/images/equip/weapon.png'), head: img('/assets/images/equip/head.png'),
  body: img('/assets/images/equip/body.png'), legs: img('/assets/images/equip/legs.png'),
  feet: img('/assets/images/equip/feet.png'), shoulder: img('/assets/images/equip/shoulder.png'),
  hands: img('/assets/images/equip/hands.png'), wrist: img('/assets/images/equip/wrist.png'),
  necklace: img('/assets/images/equip/necklace.png'), ring1: img('/assets/images/equip/ring.png'),
  ring2: img('/assets/images/equip/ring.png'), belt: img('/assets/images/equip/belt.png'),
  artifact: img('/assets/images/equip/artifact.png')
}

const equipSlots = [
  { key: 'weapon', name: '武器', img: equipSlotImages.weapon },
  { key: 'head', name: '头部', img: equipSlotImages.head },
  { key: 'body', name: '衣服', img: equipSlotImages.body },
  { key: 'legs', name: '裤子', img: equipSlotImages.legs },
  { key: 'feet', name: '鞋子', img: equipSlotImages.feet },
  { key: 'shoulder', name: '肩甲', img: equipSlotImages.shoulder },
  { key: 'hands', name: '手套', img: equipSlotImages.hands },
  { key: 'wrist', name: '护腕', img: equipSlotImages.wrist },
  { key: 'necklace', name: '焰心链', img: equipSlotImages.necklace },
  { key: 'ring1', name: '符文戒1', img: equipSlotImages.ring1 },
  { key: 'ring2', name: '符文戒2', img: equipSlotImages.ring2 },
  { key: 'belt', name: '腰带', img: equipSlotImages.belt },
  { key: 'artifact', name: '焰器', img: equipSlotImages.artifact },
]

// 丹药
const spiritPills = [
  { id: 'spirit_small', name: '小焰灵药水', img: img('/assets/images/pills/pill_juling.png'), desc: '+200焰灵', price: 500, canMulti: true, buyType: 'pill' },
  { id: 'spirit_medium', name: '中焰灵药水', img: img('/assets/images/pills/pill_juqi.png'), desc: '+800焰灵', price: 2000, canMulti: true, buyType: 'pill' },
  { id: 'spirit_large', name: '大焰灵药水', img: img('/assets/images/pills/pill_xianling.png'), desc: '+3,000焰灵', price: 8000, canMulti: true, buyType: 'pill' },
]
const cultPills = [
  { id: 'cult_small', name: '小修为丹', img: img('/assets/images/pills/pill_ningyuan.png'), desc: '+等级×10修为(日限5)', price: 2000, canMulti: true, buyType: 'pill' },
  { id: 'cult_medium', name: '中修为丹', img: img('/assets/images/pills/pill_tianyuan.png'), desc: '+等级×40修为(日限3)', price: 10000, canMulti: true, buyType: 'pill' },
  { id: 'cult_large', name: '大修为丹', img: img('/assets/images/pills/pill_niepan.png'), desc: '+等级×150修为(日限1)', price: 50000, canMulti: true, buyType: 'pill' },
]
const expPills = [
  { id: 'exp_1', name: '1级经验丹', img: img('/assets/images/pills/pill_wuxing.png'), desc: '直接升1级(日限3)', price: 250000, canMulti: true, buyType: 'pill' },
  { id: 'exp_5', name: '5级经验丹', img: img('/assets/images/pills/pill_riyue.png'), desc: '直接升5级(日限1)', price: 1000000, canMulti: true, buyType: 'pill' },
  { id: 'exp_10', name: '10级经验丹', img: img('/assets/images/pills/pill_niepan.png'), desc: '直接升10级(日限1)', price: 3000000, canMulti: true, buyType: 'pill' },
]
const attrPills = [
  { id: 'attr_attack', name: '攻击丹', img: img('/assets/images/pills/pill_leiling.png'), desc: '永久+10攻击(日限5)', price: 5000, canMulti: true, buyType: 'pill' },
  { id: 'attr_health', name: '生命丹', img: img('/assets/images/pills/pill_huiling.png'), desc: '永久+100生命(日限5)', price: 5000, canMulti: true, buyType: 'pill' },
  { id: 'attr_defense', name: '防御丹', img: img('/assets/images/pills/pill_qingxin.png'), desc: '永久+8防御(日限5)', price: 5000, canMulti: true, buyType: 'pill' },
  { id: 'attr_speed', name: '速度丹', img: img('/assets/images/pills/pill_huoyuan.png'), desc: '永久+5速度(日限5)', price: 5000, canMulti: true, buyType: 'pill' },
]
const fragItems = [
  { id: 'pill_frag_health', name: '回春焰丹碎片', img: img('/assets/images/pills/pill_huiling.png'), desc: '收集5个合成回春焰方', price: 1000, canMulti: true, buyType: 'material' },
  { id: 'pill_frag_attack', name: '破军焰丹碎片', img: img('/assets/images/pills/pill_leiling.png'), desc: '收集5个合成破军焰方', price: 1500, canMulti: true, buyType: 'material' },
  { id: 'pill_frag_defense', name: '金钟焰丹碎片', img: img('/assets/images/pills/pill_qingxin.png'), desc: '收集5个合成金钟焰方', price: 1500, canMulti: true, buyType: 'material' },
  { id: 'pill_frag_speed', name: '疾风焰丹碎片', img: img('/assets/images/pills/pill_huoyuan.png'), desc: '收集5个合成疾风焰方', price: 1200, canMulti: true, buyType: 'material' },
]

// 焰草商城
const herbShopItems = [
  { id: 'spirit_grass', name: '灵精草', baseValue: 10, desc: '最常见的焰草。可炼制：聚灵丹', grade: 1, img: img('/assets/images/herbs/herb_spirit_grass.png') },
  { id: 'cloud_flower', name: '云雾花', baseValue: 15, desc: '云雾中的焰花。可炼制：聚灵丹、聚气丹', grade: 1, img: img('/assets/images/herbs/herb_cloud_flower.png') },
  { id: 'thunder_root', name: '雷击根', baseValue: 25, desc: '雷霆淬炼的焰根。可炼制：聚气丹、雷灵丹', grade: 2, img: img('/assets/images/herbs/herb_thunder_root.png') },
  { id: 'dark_yin_grass', name: '玄阴草', baseValue: 30, desc: '阴暗处的奇草。可炼制：回灵丹', grade: 2, img: img('/assets/images/herbs/herb_dark_yin.png') },
  { id: 'fire_heart_flower', name: '火心花', baseValue: 35, desc: '火山口的奇花。可炼制：清心丹、火元丹', grade: 2, img: img('/assets/images/herbs/herb_fire_heart.png') },
  { id: 'dragon_breath_herb', name: '龙息草', baseValue: 40, desc: '龙气孕育的焰草。可炼制：雷灵丹、仙灵丹、火元丹', grade: 3, img: img('/assets/images/herbs/herb_dragon_breath.png') },
  { id: 'nine_leaf_lingzhi', name: '九叶灵芝', baseValue: 45, desc: '千年灵芝。可炼制：凝元丹', grade: 3, img: img('/assets/images/herbs/herb_nine_lingzhi.png') },
  { id: 'purple_ginseng', name: '紫金参', baseValue: 50, desc: '千年紫参。可炼制：凝元丹', grade: 3, img: img('/assets/images/herbs/herb_purple_ginseng.png') },
  { id: 'frost_lotus', name: '寒霜莲', baseValue: 55, desc: '极寒之莲。可炼制：回灵丹、清心丹', grade: 4, img: img('/assets/images/herbs/herb_frost_lotus.png') },
  { id: 'immortal_jade_grass', name: '仙玉草', baseValue: 60, desc: '仙境焰草。可炼制：仙灵丹', grade: 4, img: img('/assets/images/herbs/herb_immortal_jade.png') },
  { id: 'moonlight_orchid', name: '月华兰', baseValue: 70, desc: '月圆绽放的兰花。可炼制：天元丹、日月丹', grade: 5, img: img('/assets/images/herbs/herb_moonlight_orchid.png') },
  { id: 'sun_essence_flower', name: '日精花', baseValue: 75, desc: '太阳精华之花。可炼制：日月丹', grade: 5, img: img('/assets/images/herbs/herb_sun_essence.png') },
  { id: 'five_elements_grass', name: '五行草', baseValue: 80, desc: '五行合一的奇珍。可炼制：五行丹', grade: 6, img: img('/assets/images/herbs/herb_five_elements.png') },
  { id: 'phoenix_feather_herb', name: '凤羽草', baseValue: 85, desc: '凤凰栖息地的神草。可炼制：五行丹、涅槃丹', grade: 6, img: img('/assets/images/herbs/herb_phoenix_feather.png') },
  { id: 'celestial_dew_grass', name: '天露草', baseValue: 90, desc: '天地精华凝聚。可炼制：天元丹、涅槃丹', grade: 6, img: img('/assets/images/herbs/herb_celestial_dew.png') },
]

const herbQualityOptions = [
  { key: 'common', label: '普通', mult: 1, color: '#9e9e9e' },
  { key: 'uncommon', label: '优质', mult: 1.5, color: '#4caf50' },
  { key: 'rare', label: '稀有', mult: 2, color: '#2196f3' },
  { key: 'epic', label: '极品', mult: 3, color: '#9c27b0' },
  { key: 'legendary', label: '仙品', mult: 5, color: '#ff9800' },
]

const selectedHerbQuality = ref('common')

// 焰方商城
const formulaShopItems = [
  { id: 'spirit_gathering', name: '聚灵丹方', img: img('/assets/images/pills/pill_juling.png'), grade: '一品', desc: '焰灵恢复+20%，持续60分钟。需要：灵精草×2、云雾花×1', price: 5000 },
  { id: 'cultivation_boost', name: '聚气丹方', img: img('/assets/images/pills/pill_juqi.png'), grade: '二品', desc: '焰修速度+30%，持续30分钟。需要：云雾花×2、雷击根×1', price: 10000 },
  { id: 'spirit_recovery', name: '回灵丹方', img: img('/assets/images/pills/pill_huiling.png'), grade: '二品', desc: '焰灵恢复+40%，持续20分钟。需要：玄阴草×2、寒霜莲×1', price: 10000 },
  { id: 'thunder_power', name: '雷灵丹方', img: img('/assets/images/pills/pill_leiling.png'), grade: '三品', desc: '战斗属性+40%，持续15分钟。需要：雷击根×2、龙息草×1', price: 20000 },
  { id: 'essence_condensation', name: '凝元丹方', img: img('/assets/images/pills/pill_ningyuan.png'), grade: '三品', desc: '焰修效率+50%，持续25分钟。需要：九叶灵芝×2、紫金参×1', price: 20000 },
  { id: 'mind_clarity', name: '清心丹方', img: img('/assets/images/pills/pill_qingxin.png'), grade: '三品', desc: '悟性+30%，持续40分钟。需要：寒霜莲×2、火心花×1', price: 20000 },
  { id: 'immortal_essence', name: '仙灵丹方', img: img('/assets/images/pills/pill_xianling.png'), grade: '四品', desc: '全属性+50%，持续10分钟。需要：龙息草×2、仙玉草×1', price: 40000 },
  { id: 'fire_essence', name: '火元丹方', img: img('/assets/images/pills/pill_huoyuan.png'), grade: '四品', desc: '火属性焰修+60%，持续30分钟。需要：火心花×2、龙息草×1', price: 40000 },
  { id: 'five_elements_pill', name: '五行丹方', img: img('/assets/images/pills/pill_wuxing.png'), grade: '五品', desc: '全属性+80%，持续20分钟。需要：五行草×2、凤羽草×1', price: 80000 },
  { id: 'celestial_essence_pill', name: '天元丹方', img: img('/assets/images/pills/pill_tianyuan.png'), grade: '六品', desc: '焰修速度+100%，持续30分钟。需要：天露草×2、月华兰×1', price: 150000 },
  { id: 'sun_moon_pill', name: '日月丹方', img: img('/assets/images/pills/pill_riyue.png'), grade: '七品', desc: '焰灵上限+150%，持续40分钟。需要：日精花×2、月华兰×2', price: 300000 },
  { id: 'phoenix_rebirth_pill', name: '涅槃丹方', img: img('/assets/images/pills/pill_niepan.png'), grade: '八品', desc: '自动回血10%，持续60分钟。需要：凤羽草×3、天露草×1', price: 500000 },
]

// 材料
const materialItems = [
  { id: 'reinforce_1', name: '淬火石 x1', img: img('/assets/images/equip/weapon.png'), desc: '装备淬火必备', price: 1000, canMulti: true, buyType: 'material' },
  { id: 'reinforce_10', name: '淬火石 x10', img: img('/assets/images/equip/weapon.png'), desc: '批量购买9折', price: 9000, canMulti: true, buyType: 'material', discount: '9折' },
  { id: 'refine_1', name: '符文石 x1', img: img('/assets/images/equip/artifact.png'), desc: '重置副属性', price: 1500, canMulti: true, buyType: 'material' },
  { id: 'refine_10', name: '符文石 x10', img: img('/assets/images/equip/artifact.png'), desc: '批量购买9折', price: 13500, canMulti: true, buyType: 'material', discount: '9折' },
  { id: 'pet_essence', name: '焰兽精华', img: img('/assets/images/menu/menu_gacha.png'), desc: '+100精华', price: 2000, canMulti: true, buyType: 'material' },
  { id: 'pet_ticket', name: '焰兽召唤券', img: img('/assets/images/menu/menu_gacha.png'), desc: '等同一次焰兽抽卡', price: 5000, canMulti: true, buyType: 'material' },
]

// 礼包
const packItems = [
  { id: 'pack_starter', name: '🌟 新手礼包', img: img('/assets/images/menu/menu_shop.png'), desc: '中品武器+中品衣服+淬火石x10+中焰灵药水x5', price: 10000, buyType: 'pack' },
  { id: 'pack_advanced', name: '🌙 进阶礼包', img: img('/assets/images/menu/menu_shop.png'), desc: '上品武器+上品衣服+符文石x20+中修为丹x5', price: 50000, buyType: 'pack' },
  { id: 'pack_supreme', name: '☀️ 至尊礼包', img: img('/assets/images/menu/menu_shop.png'), desc: '极品全套装备(13件)+淬火石x50+符文石x30', price: 200000, buyType: 'pack' },
  { id: 'pack_mythic', name: '🔥 仙品礼包', img: img('/assets/images/menu/menu_shop.png'), desc: '仙品武器+仙品衣服+仙品焰器+5级经验丹x2', price: 500000, buyType: 'pack' },
]

// 特权
const buffItems = [
  { id: 'double_crystal', name: '焰晶双倍卡', img: img('/assets/images/icon-crystal.png'), desc: '24小时焰晶获取翻倍', price: 30000, buyType: 'buff', buffKey: 'doubleCrystal' },
  { id: 'cultivation_boost', name: '修炼加速卡', img: img('/assets/images/menu/menu_alchemy.png'), desc: '24小时修炼速度x3', price: 20000, buyType: 'buff', buffKey: 'cultivationBoost' },
  { id: 'lucky_charm', name: '幸运符', img: img('/assets/images/menu/menu_gacha.png'), desc: '24小时抽卡概率+50%', price: 10000, buyType: 'buff', buffKey: 'luckyCharm' },
]

const getBuffRemaining = (buffKey) => {
  const expires = playerBuffs.value[buffKey]
  if (!expires) return null
  const remaining = expires - Date.now()
  if (remaining <= 0) return null
  const hours = Math.floor(remaining / 3600000)
  const mins = Math.floor((remaining % 3600000) / 60000)
  return hours + '时' + mins + '分'
}

const apiCall = async (url, body) => {
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + authStore.token },
    body: JSON.stringify(body)
  })
  const result = await response.json()
  if (!response.ok) throw new Error(result.error || '请求失败')
  return result
}

const openEquipBuy = (quality, slot) => {
  buyTarget.value = {
    name: quality.prefix + slot.name,
    img: slot.img,
    desc: '等级=当前等级 品质=' + quality.label,
    price: quality.price,
    canMulti: false,
    buyType: 'equip',
    quality: quality.key,
    equipType: slot.key
  }
  buyCount.value = 1
  buyModalTitle.value = '购买装备'
  showBuyModal.value = true
}

const openPillBuy = (pill) => {
  buyTarget.value = pill
  buyCount.value = 1
  buyModalTitle.value = '购买焰丹'
  showBuyModal.value = true
}

const openMaterialBuy = (mat) => {
  buyTarget.value = mat
  buyCount.value = 1
  buyModalTitle.value = '购买材料'
  showBuyModal.value = true
}

const openHerbBuy = (herb) => {
  const mult = herbQualityOptions.find(q => q.key === selectedHerbQuality.value)?.mult || 1
  buyTarget.value = {
    ...herb,
    price: Math.floor(herb.baseValue * mult * 100),
    quality: selectedHerbQuality.value,
    canMulti: true,
    buyType: 'herb',
    icon: '🌿'
  }
  buyCount.value = 1
  buyModalTitle.value = '购买焰草'
  showBuyModal.value = true
}

const openFormulaBuy = (formula) => {
  if (playerStore.pillRecipes.includes(formula.id)) {
    message.warning('已拥有该焰方')
    return
  }
  buyTarget.value = { ...formula, canMulti: false, buyType: 'formula', icon: '📜' }
  buyCount.value = 1
  buyModalTitle.value = '购买焰方'
  showBuyModal.value = true
}

const openPackBuy = (pk) => {
  if (purchasedPacks.value.includes(pk.id)) {
    message.warning('该礼包已购买过')
    return
  }
  buyTarget.value = { ...pk, canMulti: false }
  buyCount.value = 1
  buyModalTitle.value = '购买礼包'
  showBuyModal.value = true
}

const openBuffBuy = (b) => {
  buyTarget.value = { ...b, canMulti: false }
  buyCount.value = 1
  buyModalTitle.value = '购买特权'
  showBuyModal.value = true
}

const confirmBuy = async () => {
  if (!buyTarget.value) return
  const target = buyTarget.value
  const totalPrice = target.price * buyCount.value

  if (playerStore.spiritStones < totalPrice) {
    message.error('焰晶不足！')
    sfx.error()
    return
  }

  if (!authStore.isLoggedIn) {
    message.warning('请先登录')
    return
  }

  isBuying.value = true
  try {
    let result
    if (target.buyType === 'equip') {
      result = await apiCall('/api/shop/buy-equip', { quality: target.quality, equipType: target.equipType })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        playerStore.items.push(result.equip)
        message.success('获得装备：' + result.equip.name)
      }
    } else if (target.buyType === 'pill') {
      result = await apiCall('/api/shop/buy-pill', { pillId: target.id, count: buyCount.value })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        // 同步gameData关键字段
        const gd = result.gameData
        if (gd) {
          if (gd.spirit !== undefined) playerStore.spirit = gd.spirit
          if (gd.cultivation !== undefined) playerStore.cultivation = gd.cultivation
          if (gd.level !== undefined) playerStore.level = gd.level
          if (gd.realm !== undefined) playerStore.realm = gd.realm
          if (gd.maxCultivation !== undefined) playerStore.maxCultivation = gd.maxCultivation
          if (gd.baseAttributes) playerStore.baseAttributes = gd.baseAttributes
          if (gd.spiritRate !== undefined) playerStore.spiritRate = gd.spiritRate
        }
        message.success(result.message || '购买成功')
      }
    } else if (target.buyType === 'material') {
      result = await apiCall('/api/shop/buy-material', { itemId: target.id, count: buyCount.value })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        const items = result.items
        if (items.reinforceStones) playerStore.reinforceStones += items.reinforceStones
        if (items.refinementStones) playerStore.refinementStones += items.refinementStones
        if (items.petEssence) playerStore.petEssence += items.petEssence
        if (items.pillFragments) {
          for (const [pid, amt] of Object.entries(items.pillFragments)) {
            if (!playerStore.pillFragments[pid]) playerStore.pillFragments[pid] = 0
            playerStore.pillFragments[pid] += amt
          }
        }
        if (items.pets && items.pets.length) {
          items.pets.forEach(p => playerStore.items.push({ ...p, type: 'pet' }))
          message.success('获得焰兽：' + items.pets.map(p => p.name).join(', '))
        } else {
          message.success('购买成功')
        }
      }
    } else if (target.buyType === 'herb') {
      result = await apiCall('/api/shop/buy-herb', { herbId: target.id, quality: target.quality, quantity: buyCount.value })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        message.success(result.message || '购买成功')
        // 刷新焰草数据
        if (typeof playerStore.loadHerbsFromServer === 'function') {
          await playerStore.loadHerbsFromServer()
        }
      }
    } else if (target.buyType === 'formula') {
      result = await apiCall('/api/shop/buy-formula', { formulaId: target.id })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        playerStore.pillRecipes.push(target.id)
        message.success(result.message || '焰方解锁成功')
      }
    } else if (target.buyType === 'pack') {
      result = await apiCall('/api/shop/buy-pack', { packId: target.id })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        purchasedPacks.value.push(target.id)
        if (result.equips) result.equips.forEach(e => playerStore.items.push(e))
        const gd = result.gameData
        if (gd) {
          if (gd.level !== undefined) playerStore.level = gd.level
          if (gd.realm !== undefined) playerStore.realm = gd.realm
          if (gd.baseAttributes) playerStore.baseAttributes = gd.baseAttributes
          if (gd.reinforceStones !== undefined) playerStore.reinforceStones = gd.reinforceStones
          if (gd.refinementStones !== undefined) playerStore.refinementStones = gd.refinementStones
          if (gd.spirit !== undefined) playerStore.spirit = gd.spirit
          if (gd.cultivation !== undefined) playerStore.cultivation = gd.cultivation
        }
        message.success('礼包开启成功！')
      }
    } else if (target.buyType === 'buff') {
      result = await apiCall('/api/shop/buy-buff', { buffId: target.id })
      if (result.success) {
        playerStore.spiritStones = result.spiritStones
        playerBuffs.value[result.buffKey] = result.expiresAt
        message.success('特权激活成功！')
      }
    }
    sfx.purchase()
    playerStore.saveData()
    showBuyModal.value = false
  } catch (e) {
    message.error(e.message || '购买失败')
    sfx.error()
  } finally {
    isBuying.value = false
  }
}

onMounted(async () => {
  if (authStore.isLoggedIn) {
    try {
      const resp = await fetch('/api/shop/purchased-packs', {
        headers: { 'Authorization': 'Bearer ' + authStore.token }
      })
      const data = await resp.json()
      purchasedPacks.value = data.purchasedPacks || []
      playerBuffs.value = data.buffs || {}
    } catch (e) {}
  }
})
</script>

<style scoped>
.shop-page { padding: 8px; }
.balance-bar {
  display: flex; align-items: center; justify-content: center; gap: 8px;
  padding: 12px 16px; margin-bottom: 12px; border-radius: 12px;
  background: linear-gradient(135deg, rgba(212,168,67,0.15), rgba(255,152,0,0.1));
  border: 1px solid rgba(212,168,67,0.3);
}
.balance-icon { font-size: 24px; }
.balance-label { color: #aaa; font-size: 14px; }
.balance-value { font-size: 22px; font-weight: bold; color: #ffd54f; text-shadow: 0 0 10px rgba(255,213,79,0.3); }

.shop-tabs :deep(.n-tabs-tab) { font-size: 13px; }

.quality-tabs { margin-top: 8px; }

/* 装备网格 */
.equip-grid {
  display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-top: 8px;
}
.equip-card {
  position: relative; overflow: hidden; cursor: pointer;
  padding: 10px 6px; border-radius: 8px; text-align: center;
  border: 1px solid rgba(255,255,255,0.1);
  background: rgba(30,30,40,0.6); transition: all 0.3s;
}
.equip-card:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
.card-glow { position: absolute; top: 0; left: 0; right: 0; bottom: 0; pointer-events: none; }
.equip-icon { font-size: 28px; margin-bottom: 4px; position: relative; z-index: 1; }
.equip-name { font-size: 11px; font-weight: 600; margin-bottom: 2px; position: relative; z-index: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.equip-price { font-size: 11px; color: #ffd54f; position: relative; z-index: 1; }

/* 通用商品网格 */
.section-title { font-size: 14px; font-weight: 600; margin: 12px 0 6px; color: #ddd; }
.item-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; }
.item-card {
  cursor: pointer; padding: 10px; border-radius: 8px;
  border: 1px solid rgba(255,255,255,0.08);
  background: rgba(30,30,40,0.6); transition: all 0.3s; position: relative;
}
.item-card:hover { transform: translateY(-2px); border-color: rgba(212,168,67,0.4); }
.item-icon { font-size: 28px; margin-bottom: 4px; }
.item-name { font-size: 13px; font-weight: 600; color: #eee; }
.item-desc { font-size: 11px; color: #999; margin: 2px 0; }
.item-price { font-size: 12px; color: #ffd54f; font-weight: 600; }
.discount-tag { position: absolute; top: 6px; right: 6px; }
.tier-tag { position: absolute; top: 6px; right: 6px; }
.grade-tag { margin: 4px 0; }

/* 焰草卡片 */
.herb-card { border-color: rgba(76,175,80,0.2) !important; }
.herb-card:hover { border-color: rgba(76,175,80,0.5) !important; }

/* 焰方卡片 */
.formula-grid { grid-template-columns: 1fr; }
.formula-card {
  display: flex; flex-wrap: wrap; align-items: center; gap: 8px;
  border-color: rgba(103,58,183,0.2) !important;
  background: linear-gradient(135deg, rgba(103,58,183,0.08), rgba(30,30,40,0.6)) !important;
}
.formula-card.owned { opacity: 0.6; pointer-events: none; }
.formula-card .item-icon { font-size: 32px; }
.formula-card .item-name { flex: 1; }
.owned-badge {
  position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%) rotate(-15deg);
  font-size: 18px; font-weight: bold; color: rgba(76,175,80,0.8);
  border: 2px solid rgba(76,175,80,0.5); padding: 2px 12px; border-radius: 6px;
  background: rgba(0,0,0,0.5);
}

.exp-card { border-color: rgba(255,152,0,0.3) !important; background: linear-gradient(135deg, rgba(255,152,0,0.08), rgba(30,30,40,0.6)) !important; }
.attr-card { border-color: rgba(156,39,176,0.3) !important; background: linear-gradient(135deg, rgba(156,39,176,0.08), rgba(30,30,40,0.6)) !important; }

/* 礼包 */
.pack-list { display: flex; flex-direction: column; gap: 10px; }
.pack-card {
  display: flex; align-items: center; gap: 12px; padding: 14px;
  border-radius: 10px; cursor: pointer; position: relative; overflow: hidden;
  border: 1px solid rgba(212,168,67,0.3);
  background: linear-gradient(135deg, rgba(61,43,31,0.4), rgba(18,18,26,0.8));
  transition: all 0.3s;
}
.pack-card:hover { transform: translateY(-2px); box-shadow: 0 4px 20px rgba(212,168,67,0.15); }
.pack-card.purchased { opacity: 0.5; pointer-events: none; }
.pack-badge {
  position: absolute; top: -2px; right: 10px;
  background: linear-gradient(135deg, #ff6b35, #ff9800); color: #fff;
  font-size: 10px; font-weight: bold; padding: 2px 8px 4px;
  border-radius: 0 0 6px 6px;
}
.pack-icon { font-size: 36px; flex-shrink: 0; }
.pack-info { flex: 1; }
.pack-name { font-size: 15px; font-weight: bold; color: #ffd54f; }
.pack-desc { font-size: 11px; color: #aaa; margin: 4px 0; line-height: 1.4; }
.pack-price { font-size: 14px; color: #ff9800; font-weight: bold; }
.pack-sold {
  position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) rotate(-15deg);
  font-size: 24px; font-weight: bold; color: rgba(255,255,255,0.3);
  border: 3px solid rgba(255,255,255,0.2); padding: 4px 16px; border-radius: 8px;
}

/* 特权 */
.buff-grid { grid-template-columns: 1fr !important; }
.buff-card { display: flex; flex-wrap: wrap; align-items: center; gap: 8px;
  border-color: rgba(103,58,183,0.3) !important;
  background: linear-gradient(135deg, rgba(103,58,183,0.1), rgba(30,30,40,0.6)) !important;
}
.buff-card .item-icon { font-size: 32px; }
.buff-card .item-name { flex: 1; }
.buff-active { width: 100%; font-size: 11px; color: #4caf50; font-weight: 600; }

/* 购买弹窗 */
.buy-modal :deep(.n-card) { background: rgba(25,25,35,0.98) !important; }
.buy-content { text-align: center; }
.buy-icon { font-size: 48px; margin-bottom: 8px; }
.buy-name { font-size: 18px; font-weight: bold; color: #ffd54f; margin-bottom: 4px; }
.buy-desc { font-size: 13px; color: #aaa; margin-bottom: 12px; }
.buy-count { display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 12px; }
.buy-total { font-size: 16px; margin-bottom: 14px; color: #ddd; }
.total-price { color: #ffd54f; font-weight: bold; font-size: 18px; }
.equip-icon-img {
  width: 48px;
  height: 48px;
  object-fit: contain;
  image-rendering: pixelated;
  filter: drop-shadow(0 0 6px rgba(212,168,67,0.6));
  transition: transform 0.2s;
}
.equip-card:hover .equip-icon-img {
  transform: scale(1.15);
}
.buy-icon-img {
  width: 64px;
  height: 64px;
  object-fit: contain;
  image-rendering: pixelated;
  filter: drop-shadow(0 0 8px rgba(212,168,67,0.7));
  margin: 8px auto;
}
.shop-item-img {
  width: 40px;
  height: 40px;
  object-fit: contain;
  image-rendering: pixelated;
  filter: drop-shadow(0 0 4px rgba(212,168,67,0.5));
}
.shop-pack-img {
  width: 56px;
  height: 56px;
  object-fit: contain;
  image-rendering: pixelated;
  filter: drop-shadow(0 0 6px rgba(212,168,67,0.6));
  flex-shrink: 0;
}
</style>
