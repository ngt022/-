<template>
  <n-config-provider :theme="darkTheme">
    <n-message-provider>
      <n-dialog-provider>
        <!-- 未登录：全屏连接钱包 -->
        <div v-if="!authStore.isLoggedIn" class="login-gate">
          <div class="login-bg">
            <span v-for="i in 30" :key="i" class="login-particle" :style="loginParticleStyle(i)"></span>
          </div>
          <div class="login-box">
            <img src="/assets/images/logo.png" class="login-logo" />
            <div class="login-title">火之文明</div>
            <div class="login-title-sub">焰修传说</div>
            <div class="login-divider"></div>
            <div class="login-subtitle">点燃你的火焰之力</div>
            <button class="login-btn-custom" @click="connectWallet" :disabled="authStore.isConnecting">
              {{ authStore.isConnecting ? '连接中...' : '连接钱包' }}
            </button>
            <div class="login-footer">Powered by Roon Chain</div>
          </div>
          <div class="login-version">v1.0</div>
        </div>

        <!-- 已登录：游戏主体 -->
        <n-spin v-else :show="isLoading" description="正在加载游戏数据...">
          <n-layout>
            <n-layout-header bordered class="app-header">
              <div class="header-content">
                <div class="header-title">火之文明</div>
                <div class="header-actions">
                  <span v-if="authStore.vipLevel > 0" class="header-vip-tag">VIP{{ authStore.vipLevel }}</span>
                  <button class="header-icon-btn mail-btn" @click="router.push('/mail')">
                    <n-icon :size="15"><SmileOutlined /></n-icon>
                    <span v-if="unreadMail > 0" class="mail-dot"></span>
                  </button>
                  <button class="header-icon-btn" @click="router.push('/settings')">
                    <n-icon :size="15"><SettingOutlined /></n-icon>
                  </button>
                  <n-dropdown :options="walletMenuOptions" @select="handleWalletMenu">
                    <button class="header-wallet-btn">{{ authStore.shortWallet }}</button>
                  </n-dropdown>
                </div>
              </div>
            </n-layout-header>
            <n-layout-content v-if="!showSplash">
              <!-- Buff状态栏 -->
              <div class="buff-bar" v-if="activeBuffs.length > 0">
                <span v-for="buff in activeBuffs" :key="buff.key" class="buff-tag" :title="buff.desc">
                  {{ buff.icon }} {{ buff.name }} {{ buff.remaining }}
                </span>
              </div>
              <div class="content-wrapper">
                <!-- 主城：只在首页显示 -->
                <GameScene
                  v-if="isHome"
                  :playerName="playerStore.name"
                  :playerRealm="getRealmName(playerStore.level).name"
                  :activeTab="activeTab"
                  @navigate="handleGameNavigate"
                  class="page-view"
                />
                <!-- 子页面：返回按钮 + 内容 -->
                <transition name="page-slide" mode="out-in">
                <div v-if="!isHome" key="subpage" class="page-view">
                  <div class="sub-page-header">
                    <button class="back-btn" @click="goBack">← 返回</button>
                    <span class="sub-page-title">{{ currentPageTitle }}</span>
                    <span class="sub-page-level">{{ playerStore.realm }} Lv.{{ playerStore.level }}</span>
                  </div>
                  <router-view v-slot="{ Component }">
                    <transition name="page-fade" mode="out-in">
                      <component :is="Component" />
                    </transition>
                  </router-view>
                </div>
                </transition>
              </div>
            </n-layout-content>
            <WorldChat v-if="!showSplash" />
            <div v-if="!showSplash" class="bottom-nav">
              <div class="bottom-nav-inner">
                <div v-for="tab in navTabs" :key="tab.key"
                  class="nav-tab"
                  :class="{ active: activeTab === tab.key }"
                  @click="switchTab(tab.key)">
                  <span class="nav-icon">{{ tab.icon }}</span>
                  <span class="nav-indicator"></span>
                  <span class="nav-label">{{ tab.label }}</span>
                </div>
              </div>
            </div>
          </n-layout>
        </n-spin>
      <BugReporter />
      </n-dialog-provider>
    </n-message-provider>
  </n-config-provider>
  <n-modal v-model:show="showAnnouncementPopup" preset="card" title="📢 今日公告" style="max-width:400px">
      <div v-for="a in popupAnnouncements" :key="a.id" style="padding:8px 0;border-bottom:1px solid #333">
        <n-tag :type="a.type==='event'?'warning':a.type==='promo'?'success':'info'" size="small" style="margin-right:8px">{{ a.type==='event'?'活动':a.type==='promo'?'促销':'公告' }}</n-tag>
        {{ a.content }}
      </div>
    </n-modal>
  </template>

<script setup>
  import { useRouter, useRoute } from 'vue-router'
  import { usePlayerStore } from './stores/player'
import { useGameConfigStore } from './stores/gameConfig'
  import { useAuthStore } from './stores/auth'
  import { h, ref, watch, onMounted, computed } from 'vue'
  import { NIcon, darkTheme, createDiscreteApi } from 'naive-ui'
  import {
    BookOutlined,
    ExperimentOutlined,
    CompassOutlined,
    TrophyOutlined,
    SettingOutlined,
    MedicineBoxOutlined,
    GiftOutlined,
    HomeOutlined,
    SmileOutlined,
    DollarOutlined,
    CrownOutlined,
    BarChartOutlined
  } from '@ant-design/icons-vue'
  import { Flash } from '@vicons/ionicons5'
  import { getRealmName } from './plugins/realm'
  import WorldChat from './components/WorldChat.vue'
  import GameScene from './components/GameScene.vue'
  import BugReporter from "./components/BugReporter.vue"

  const router = useRouter()
  const route = useRoute()
  const playerStore = usePlayerStore()
  const gameConfigStore = useGameConfigStore()
  const authStore = useAuthStore()
  const { dialog } = createDiscreteApi(["dialog"])
  const spiritWorker = ref(null)
  const menuOptions = ref([])
  const isNewPlayer = ref(false)
  const isLoading = ref(true)

  // 底部导航栏
  const navTabs = [
    { key: 'home', label: '主城', icon: '🏠' },
    { key: 'adventure', label: '冒险', icon: '⚔️' },
    { key: 'character', label: '角色', icon: '🎒' },
    { key: 'social', label: '社交', icon: '👥' },
    { key: 'market', label: '商城', icon: '💰' },
  ]

  const activeTab = ref('home')

// 开场 Loading
const showSplash = ref(true)
const splashProgress = ref(0)
const splashText = ref('正在连接焰灵城...')
const splashTexts = ['正在连接焰灵城...', '加载修炼数据...', '唤醒焰灵...', '准备就绪']
const splashParticleStyle = (i) => ({
  left: Math.random() * 100 + '%',
  animationDelay: (i * 0.15) + 's',
  animationDuration: (2 + Math.random() * 2) + 's',
  width: (2 + Math.random() * 4) + 'px',
  height: (2 + Math.random() * 4) + 'px',
})
function startSplash() {
  let p = 0
  const iv = setInterval(() => {
    p += Math.random() * 15 + 5
    if (p >= 100) p = 100
    splashProgress.value = p
    const idx = p < 30 ? 0 : p < 60 ? 1 : p < 90 ? 2 : 3
    splashText.value = splashTexts[idx]
    if (p >= 100) {
      clearInterval(iv)
      setTimeout(() => { showSplash.value = false }, 400)
    }
  }, 200)
}
// 立即启动 splash（登录状态才显示，否则跳过）
if (authStore.isLoggedIn) { startSplash() } else { showSplash.value = false }

  const routeTabMap = {
    cultivation: 'adventure', dungeon: 'adventure', 'daily-dungeon': 'adventure',
    exploration: 'adventure', boss: 'adventure',
    profile: 'character', inventory: 'character', alchemy: 'character',
    'mount-title': 'character', ascension: 'character', achievements: 'character',
    sect: 'social', 'sect-war': 'social', friends: 'social',
    pk: 'social', auction: 'social', rank: 'social',
    mail: 'social',
    shop: 'market', recharge: 'market', vip: 'market',
    gacha: 'market', events: 'market',
  }

  const switchTab = (key) => {
    activeTab.value = key
    if (route.path !== '/') {
      router.push('/')
    }
  }

  // 根据路由自动更新 activeTab
  watch(() => route.path, (path) => {
    const routeKey = path.slice(1)
    if (routeKey && routeTabMap[routeKey]) {
      activeTab.value = routeTabMap[routeKey]
    } else if (path === '/' || path === '') {
      // 保持当前 activeTab
    }
  })

  const walletMenuOptions = [
    
    { label: '断开连接', key: 'logout' }
  ]

  const connectWallet = async () => {
    try {
      const player = await authStore.connectWallet()
      if (player.gameData && Object.keys(player.gameData).length > 0) {
        Object.entries(player.gameData).forEach(([key, value]) => {
          if (key in playerStore.$state) playerStore[key] = value
        })
      }
      await initGame()
    } catch (e) {
      alert(e.message)
    }
  }

  const handleWalletMenu = async (key) => {
    if (key === 'logout') {
      authStore.logout()
    }
  }

  const initGame = async () => {
    isLoading.value = true
    // 加载服务端游戏配置
    await gameConfigStore.loadConfig()
    // 已登录用户：跳过 IndexedDB，直接用云端数据（避免旧数据覆盖）
    // 未登录用户：从 IndexedDB 加载
    if (!authStore.isLoggedIn) {
      await playerStore.initializePlayer()
    }
    if (authStore.isLoggedIn) {
      try {
        const cloudData = await authStore.loadFromCloud()
        if (cloudData) {
          authStore.vipLevel = cloudData.vipLevel || 0
          authStore.totalRecharge = cloudData.totalRecharge || 0
          authStore.firstRecharge = cloudData.firstRecharge || false
          authStore.dailySignDate = cloudData.dailySignDate || null
          authStore.dailySignStreak = cloudData.dailySignStreak || 0
          authStore.syncToStorage()
        }
        if (cloudData && cloudData.gameData && Object.keys(cloudData.gameData).length > 0) {
          Object.entries(cloudData.gameData).forEach(([key, value]) => {
            if (key in playerStore.$state) playerStore[key] = value
          })
        }
      } catch (e) {
        console.error("云存档加载失败:", e)
      }
    }
    isLoading.value = false
    getMenuOptions()
    playerStore.startSpiritRegen()

    // 云存档已改为操作触发（saveData 2秒防抖），不再需要定时器
    // 离线收益
    const reward = await playerStore.calculateOfflineReward()
    if (reward) {
      const hours = Math.floor(reward.offlineMin / 60)
      const mins = reward.offlineMin % 60
      const timeStr = hours > 0 ? `${hours}小时${mins}分钟` : `${mins}分钟`
      dialog.success({
        title: '🌙 离线焰力',
        content: () => h('div', { style: 'text-align:center;padding:8px 0' }, [
          h('div', { style: 'font-size:14px;color:#a09880;margin-bottom:12px' }, `你离开了 ${timeStr}`),
          h('div', { style: 'display:flex;justify-content:center;gap:20px' }, [
            h('div', { style: 'text-align:center' }, [
              h('div', { style: 'font-size:24px;font-weight:bold;color:#7c5cbf' }, `+${reward.cultivation}`),
              h('div', { style: 'font-size:12px;color:#a09880' }, '焰力')
            ]),
            h('div', { style: 'text-align:center' }, [
              h('div', { style: 'font-size:24px;font-weight:bold;color:#d4a843' }, `+${reward.stones}`),
              h('div', { style: 'font-size:12px;color:#a09880' }, '焰晶')
            ]),
            h('div', { style: 'text-align:center' }, [
              h('div', { style: 'font-size:24px;font-weight:bold;color:#4caf50' }, `+${reward.spirit}`),
              h('div', { style: 'font-size:12px;color:#a09880' }, '焰灵')
            ])
          ]),
          reward.vipBoost > 1 ? h('div', { style: 'margin-top:10px;font-size:12px;color:#d4a843' }, `VIP加成 x${reward.vipBoost}`) : null
        ]),
        positiveText: '太好了！',
      })
    }

    // 首次登录改名引导
    if (playerStore.nameChangeCount === 0 && (playerStore.name === '无名焰修' || playerStore.name === '无名修士')) {
      setTimeout(() => {
        dialog.info({
          title: '🔥 欢迎来到火之文明！',
          content: '请先给自己取一个焰名吧！首次改名免费哦~',
          positiveText: '去取名',
          negativeText: '稍后再说',
          onPositiveClick: () => router.push('/settings'),
        })
      }, 1500)
    }
  }

  // 如果已有 token（刷新页面），直接初始化
  if (authStore.isLoggedIn) {
    initGame()
  }

  watch(
    () => playerStore.isNewPlayer,
    bool => {
      isNewPlayer.value = bool
      if (!bool && route.path === '/') {
        router.push('/cultivation')
      }
    }
  )

  const baseGainRate = 1

  const getMenuOptions = () => {
    menuOptions.value = [
      ...(isNewPlayer.value
        ? [{ label: '欢迎', key: '', icon: renderIcon(HomeOutlined) }]
        : []),
      { label: '修炼', key: 'cultivation', icon: renderIcon(BookOutlined) },
      { label: '背包', key: 'inventory', icon: renderIcon(ExperimentOutlined) },
      { label: '抽奖', key: 'gacha', icon: renderIcon(GiftOutlined) },
      { label: '焰炼', key: 'alchemy', icon: renderIcon(MedicineBoxOutlined) },
      { label: '探索', key: 'exploration', icon: renderIcon(CompassOutlined) },
      { label: '秘境', key: 'dungeon', icon: renderIcon(Flash) },
      { label: '焰境', key: 'daily-dungeon', icon: renderIcon(CompassOutlined) },
      { label: '黑焰入侵', key: 'boss', icon: renderIcon(Flash) },
      { label: '焰功', key: 'achievements', icon: renderIcon(TrophyOutlined) },
      { label: '焰骑/焰号', key: 'mount-title', icon: renderIcon(CrownOutlined) },
      { label: '充值', key: 'recharge', icon: renderIcon(DollarOutlined) },
      { label: '焰晶商铺', key: 'shop', icon: renderIcon(GiftOutlined) },
      { label: '焰市', key: 'auction', icon: renderIcon(DollarOutlined) },
      { label: '焰阶', key: 'vip', icon: renderIcon(CrownOutlined) },
      { label: '焰盟', key: 'sect', icon: renderIcon(HomeOutlined) },
      { label: '焰盟战', key: 'sect-war', icon: renderIcon(Flash) },
      { label: '焰友', key: 'friends', icon: renderIcon(SmileOutlined) },
      { label: '焰榜', key: 'rank', icon: renderIcon(BarChartOutlined) },

      { label: '设置', key: 'settings', icon: renderIcon(SettingOutlined) },
      ...(authStore.wallet?.toLowerCase() === "0xfad7eb0814b6838b05191a07fb987957d50c4ca9" ? [{ label: "后台管理", key: "admin", icon: renderIcon(SettingOutlined) }, { label: "活动管理", key: "admin/events", icon: renderIcon(SettingOutlined) }] : []),
      ...(playerStore.isGMMode
        ? [{ label: 'GM调试', key: 'gm', icon: renderIcon(SmileOutlined) }]
        : [])
    ]
  }

  // Buff状态栏计算
  const activeBuffs = computed(() => {
    const now = Date.now()
    const result = []
    const buffs = playerStore.buffs || {}
    const buffDefs = {
      doubleCrystal: { icon: '💎', name: '焰晶双倍', desc: '所有焰晶收入×2' },
      cultivationBoost: { icon: '⚡', name: '修炼加速', desc: '探索修为+50%' },
      luckyCharm: { icon: '🍀', name: '幸运符', desc: '抽卡稀有概率+30%' }
    }
    for (const [key, expires] of Object.entries(buffs)) {
      if (expires > now && buffDefs[key]) {
        const remain = expires - now
        const hours = Math.floor(remain / 3600000)
        const mins = Math.floor((remain % 3600000) / 60000)
        result.push({ key, ...buffDefs[key], remaining: hours > 0 ? hours + 'h' + mins + 'm' : mins + 'm' })
      }
    }
    // 丹药buff
    const effects = (playerStore.activeEffects || []).filter(e => e.endTime > now)
    const effectNames = {
      spiritRate: '焰灵恢复', cultivationRate: '焰修速度', combatBoost: '战斗加成',
      allAttributes: '全属性', spiritCap: '焰灵上限', autoHeal: '自动回血',
      spiritRecovery: '焰灵恢复', cultivationEfficiency: '焰修效率',
      comprehension: '悟性', fireAttribute: '火属性'
    }
    for (const e of effects) {
      const remain = e.endTime - now
      const mins = Math.floor(remain / 60000)
      result.push({ key: 'pill_' + e.type, icon: '💊', name: effectNames[e.type] || e.type, remaining: mins + 'm', desc: '+' + ((e.value || 0) * 100).toFixed(0) + '%' })
    }
    return result
  })

  // startAutoGain removed - 焰灵恢复统一由 playerStore.startSpiritRegen() 处理

  // 强制黑色主题
  document.documentElement.removeAttribute('data-theme')
  document.documentElement.classList.add('dark')

  const renderIcon = icon => {
    return () => h(NIcon, null, { default: () => h(icon) })
  }

  const getCurrentMenuKey = () => {
    const path = route.path.slice(1)
    return path
  }

  const handleMenuClick = key => {
    router.push(`/${key}`)
  }

  const handleGameNavigate = (key) => {
    router.push(`/${key}`)
  }

  const isHome = computed(() => route.path === '/' || route.path === '')

  const pageTitles = {
    cultivation: '修炼', inventory: '背包', gacha: '焰运阁', alchemy: '焰炼',
    exploration: '探索', dungeon: '焚天塔', 'daily-dungeon': '焰境',
    pk: '焰武', boss: '黑焰入侵', sect: '焰盟', 'sect-war': '焰盟战',
    friends: '焰友', auction: '焰市', shop: '焰晶商铺', events: '活动',
    'mount-title': '焰骑焰号', ascension: '涅槃飞升', recharge: '充值',
    vip: '焰阶', achievements: '焰功', rank: '焰榜', mail: '邮件',
      settings: '设置',
    'admin': '后台管理', 'admin/events': '活动管理', gm: 'GM调试', profile: '角色信息'
  }

  const currentPageTitle = computed(() => {
    const path = route.path.slice(1)
    return pageTitles[path] || ''
  })

  const goBack = () => {
    router.push('/')
  }

  const loginParticleStyle = (i) => ({
    left: `${(i * 13 + 7) % 100}%`,
    top: `${(i * 17 + 3) % 100}%`,
    animationDelay: `${(i * 0.7) % 5}s`,
    animationDuration: `${3 + (i % 4) * 1.5}s`,
    width: `${2 + (i % 3)}px`,
    height: `${2 + (i % 3)}px`,
  })

  // 页面关闭/切后台时紧急存档（sendBeacon）
  // spirit/cultivation/level/realm 由后端管理，不在此发送
  const emergencySave = () => {
    playerStore.updateOnlineTime()
    if (authStore.isLoggedIn && window.__cloudLoaded) {
      // 只发非权威字段（装备、背包等前端管理的数据）
      const gameData = { ...playerStore.$state }
      // 删除后端权威字段，防止覆盖
      delete gameData.spirit
      delete gameData.cultivation
      delete gameData.level
      delete gameData.realm
      delete gameData.maxCultivation
      delete gameData.maxSpirit
      delete gameData.spiritRegenRate
      delete gameData.cultivationCost
      delete gameData.cultivationGain
      delete gameData.lastTickTime
      delete gameData._spiritRegenTimer
      delete gameData._autoCultTimer
      delete gameData._syncTimer
      const body = JSON.stringify({
        gameData,
        combatPower: (typeof playerStore.getCombatPower === 'function' ? playerStore.getCombatPower() : 0),
        level: playerStore.level,
        realm: playerStore.realm,
        spiritStones: playerStore.spiritStones,
        name: playerStore.name
      })
      navigator.sendBeacon('/api/game/save-beacon?token=' + authStore.token, new Blob([body], { type: 'application/json' }))
    }
  }

  // beforeunload: 未保存数据 >5秒 时弹确认框 + sendBeacon 紧急存档
  window.addEventListener('beforeunload', (e) => {
    emergencySave()
    const lastSave = playerStore.getLastSaveTime()
    if (lastSave && (Date.now() - lastSave > 5000)) {
      e.preventDefault()
      e.returnValue = '你有未保存的游戏数据，确定要离开吗？'
    }
  })
// 登录后公告弹窗（每天弹一次）
const unreadMail = ref(0)
const fetchUnreadMail = async () => {
  const token = localStorage.getItem('xx_token')
  if (!token) return
  try {
    const res = await fetch('/api/mail/unread', { headers: { Authorization: 'Bearer ' + token } })
    const d = await res.json()
    unreadMail.value = d.unread || 0
  } catch (e) {}
}
window.addEventListener('mail-read', fetchUnreadMail)
// 每60秒刷新未读数
setInterval(fetchUnreadMail, 60000)

const showAnnouncementPopup = ref(false)
const popupAnnouncements = ref([])

const checkAnnouncementPopup = async () => {
  const today = new Date().toISOString().split('T')[0]
  const lastShown = localStorage.getItem('xx_announce_date')
  if (lastShown === today) return
  try {
    const res = await fetch('/api/announcements')
    const data = await res.json()
    const list = Array.isArray(data) ? data : (data?.announcements || data?.data || [])
    if (list.length > 0) {
      popupAnnouncements.value = list.slice(0, 5)
      showAnnouncementPopup.value = true
      localStorage.setItem('xx_announce_date', today)
    }
  } catch (e) {}
}

// 登录成功后检查公告
watch(() => authStore.wallet, (w) => { if (w) { setTimeout(checkAnnouncementPopup, 1500); setTimeout(fetchUnreadMail, 500) } }, { immediate: true })

</script>

<style>
  /* ===== App Header ===== */
  .app-header.n-layout-header {
    height: 50px !important;
    min-height: 50px !important;
    max-height: 50px !important;
    background: rgba(8,8,16,0.95) !important;
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(212,168,67,0.15) !important;
    box-shadow: 0 1px 12px rgba(0,0,0,0.4);
    display: flex;
    align-items: center;
    padding: 0 !important;
  }  .header-content {
    max-width: 1200px;
    width: 100%;
    margin: 0 auto;
    padding: 0 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 50px;
  }
  .header-title {
    font-size: 18px;
    font-weight: 900;
    font-family: 'Noto Serif SC', serif;
    background: linear-gradient(180deg, #f5e6c8 0%, #d4a843 50%, #b8860b 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: 3px;
    white-space: nowrap;
  }  .header-actions {
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .header-icon-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: none;
    background: transparent;
    color: var(--gold);
    cursor: pointer;
    transition: all 0.25s;
  }
  .header-icon-btn:hover {
    color: var(--gold-light);
    background: rgba(212,168,67,0.1);
  }
  .mail-btn {
    position: relative;
  }
  .mail-dot {
    position: absolute;
    top: 4px;
    right: 4px;
    width: 8px;
    height: 8px;
    background: #e74c3c;
    border-radius: 50%;
    animation: mail-pulse 1.5s infinite;
  }
  @keyframes mail-pulse {
    0%, 100% { transform: scale(1); opacity: 1; }
    50% { transform: scale(1.3); opacity: 0.8; }
    text-shadow: 0 0 8px rgba(212,168,67,0.4);
  }  .header-vip-tag {
    display: inline-flex;
    align-items: center;
    height: 22px;
    padding: 0 10px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 1px;
    color: #0a0a0f;
    background: linear-gradient(135deg, #f0d68a 0%, #d4a843 50%, #b8860b 100%);
    border-radius: 11px;
    white-space: nowrap;
  }  .header-wallet-btn {
    display: inline-flex;
    align-items: center;
    height: 28px;
    padding: 0 12px;
    font-size: 12px;
    font-family: 'SF Mono', 'Fira Code', monospace;
    color: var(--gold);
    background: transparent;
    border: 1px solid rgba(212,168,67,0.3);
    border-radius: 14px;
    cursor: pointer;
    transition: all 0.25s;
    white-space: nowrap;
  }
  .header-wallet-btn:hover {
    border-color: var(--gold);
    background: rgba(212,168,67,0.08);
    box-shadow: 0 0 12px rgba(212,168,67,0.15);
  }
  /* ===== Sub-page Header ===== */
  .sub-page-header {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
    padding: 8px 0;
    position: relative;
  }
  .back-btn {
    background: none;
    border: none;
    color: var(--gold);
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 6px;
    transition: all 0.25s;
    white-space: nowrap;
    z-index: 1;
  }
  .back-btn:hover {
    color: var(--gold-light);
    background: rgba(212,168,67,0.08);
    text-shadow: 0 0 8px rgba(212,168,67,0.3);
  }  .sub-page-title {
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    font-size: 16px;
    font-weight: 900;
    font-family: 'Noto Serif SC', serif;
    background: linear-gradient(180deg, #f5e6c8 0%, #d4a843 50%, #b8860b 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    white-space: nowrap;
  }
  .sub-page-level {
    font-size: 0.75rem;
    color: #d4a843;
    opacity: 0.85;
    white-space: nowrap;
  }
  .sub-page-spacer {
    flex: 1;
  }

  /* 登录页 */
  .login-gate {
    position: fixed;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(rgba(2,2,8,0.4), rgba(5,5,16,0.7) 70%, rgba(0,0,0,0.9)), url('/assets/images/bg-main.png') center/cover no-repeat;
    z-index: 9999;
  }  .login-bg {
    position: absolute;
    inset: 0;
    pointer-events: none;
    overflow: hidden;
  }
  .login-particle {
    position: absolute;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(255,180,50,0.8), transparent);
    filter: blur(1px);
    animation: login-float ease-in-out infinite;
  }  @keyframes login-float {
    0%, 100% { transform: translateY(0) scale(1); opacity: 0.15; }
    50% { transform: translateY(-40px) scale(1.5); opacity: 0.8; }
  }
  .login-box {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 50px 50px 40px;
    border-radius: 20px;
    background: rgba(10,10,18,0.6);
    border: 1px solid rgba(212,168,67,0.15);
    box-shadow: 0 0 80px rgba(212,168,67,0.06), 0 30px 80px rgba(0,0,0,0.6);
    backdrop-filter: blur(20px);
    max-width: 400px;
    width: 90%;
  }  .login-logo {
    width: 280px;
    margin-bottom: 20px;
    display: block;
    margin-left: auto;
    margin-right: auto;
    filter: drop-shadow(0 0 30px rgba(212,168,67,0.5)) drop-shadow(0 0 60px rgba(212,168,67,0.2));
  }
  .login-title {
    font-size: 40px;
    font-weight: 900;
    font-family: 'Noto Serif SC', serif;
    background: linear-gradient(180deg, #f5e6c8 0%, #d4a843 50%, #b8860b 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: 6px;
    line-height: 1.2;
  }
  .login-title-sub {
    font-size: 22px;
    font-weight: 700;
    font-family: 'Noto Serif SC', serif;
    background: linear-gradient(180deg, #e8d5a8 0%, #c4a04a 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: 8px;
    margin-top: 4px;
  }
  .login-divider {
    width: 60px;
    height: 2px;
    background: linear-gradient(90deg, transparent, #d4a843, transparent);
    margin: 20px auto;
  }  .login-subtitle {
    font-size: 14px;
    color: rgba(200,185,155,0.7);
    margin-bottom: 32px;
    letter-spacing: 2px;
  }
  .login-btn-custom {
    display: inline-block;
    width: 240px;
    height: 50px;
    font-size: 18px;
    font-weight: 700;
    font-family: 'Noto Serif SC', serif;
    color: #0a0a0f;
    background: linear-gradient(135deg, #f0d68a 0%, #d4a843 50%, #b8860b 100%);
    border: 2px solid rgba(240,214,138,0.6);
    border-radius: 30px;
    cursor: pointer;
    letter-spacing: 3px;
    transition: all 0.3s ease;
    box-shadow: 0 4px 20px rgba(212,168,67,0.3);
  }
  .login-btn-custom:hover {
    box-shadow: 0 4px 30px rgba(212,168,67,0.6), 0 0 60px rgba(212,168,67,0.2);
    transform: translateY(-2px);
  }
  .login-btn-custom:active {
    transform: translateY(0);
  }
  .login-btn-custom:disabled {
    opacity: 0.6;
    cursor: wait;
  }
  .login-footer {
    margin-top: 24px;
    font-size: 11px;
    color: rgba(160,152,128,0.4);
    letter-spacing: 1px;
  }
  .login-version {
    position: fixed;
    bottom: 16px;
    right: 20px;
    font-size: 11px;
    color: rgba(160,152,128,0.3);
    z-index: 10000;
  }
  @media (max-width: 480px) {
    .login-logo { width: 200px; }
    .login-title { font-size: 28px; letter-spacing: 4px; }
    .login-title-sub { font-size: 16px; letter-spacing: 5px; }
    .login-box { padding: 40px 30px 30px; }
    .login-btn-custom { width: 200px; height: 46px; font-size: 16px; }
  }

  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  :root {
    --gold: #d4a843;
    --gold-light: #f0d68a;
    --gold-dark: #b8860b;
    --purple-glow: #7c5cbf;
    --bg-dark: #0a0a0f;
    --bg-card: #12121a;
    --bg-header: #0d0d15;
    --text-primary: #e8e0d0;
    --text-secondary: #a09880;
    --border-gold: rgba(212, 168, 67, 0.3);
  }
  html, body {
    background: var(--bg-dark) !important;
    color: var(--text-primary);
    font-family: 'Noto Serif SC', 'PingFang SC', 'Microsoft YaHei', -apple-system, sans-serif;
  }

  .n-config-provider, .n-layout {
    height: 100%;
    background: var(--bg-dark) !important;
  }
  /* 头部 — now handled by .app-header */
  .n-layout-header.app-header {
    /* styles defined above in App Header section */
  }

  /* header-content — now handled by App Header section */

  .n-page-header__title {
    color: var(--gold) !important;
    font-family: 'Noto Serif SC', serif;
    font-weight: 900;
  }

  /* 菜单 */
  .n-menu .n-menu-item-content {
    color: var(--text-secondary) !important;
    transition: color 0.3s, text-shadow 0.3s;
  }
  .n-menu .n-menu-item-content:hover {
    color: var(--gold-light) !important;
    text-shadow: 0 0 8px rgba(212,168,67,0.3);
  }
  .n-menu .n-menu-item-content--selected {
    color: var(--gold) !important;
    text-shadow: 0 0 12px rgba(212,168,67,0.4);
  }
  .n-menu-item--selected::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 20%;
    right: 20%;
    height: 2px;
    background: linear-gradient(90deg, transparent, var(--gold), transparent);
  }

  /* 卡片 */
  .content-wrapper {
    max-width: 1200px;
    margin: 0 auto;
    padding: 16px;
    padding-bottom: 70px;
  }

  .n-card {
    margin-bottom: 16px;
    background: var(--bg-card) !important;
    border: 1px solid var(--border-gold) !important;
    border-radius: 8px;
    box-shadow: inset 0 0 30px rgba(212,168,67,0.02), 0 4px 20px rgba(0,0,0,0.3);
    transition: border-color 0.3s, box-shadow 0.3s;
  }
  .n-card:hover {
    border-color: rgba(212,168,67,0.5) !important;
    box-shadow: inset 0 0 30px rgba(212,168,67,0.04), 0 4px 25px rgba(0,0,0,0.4), 0 0 15px rgba(212,168,67,0.05);
  }
  .n-card-header__main {
    color: var(--gold-light) !important;
    font-family: 'Noto Serif SC', serif;
  }

  /* 描述列表 */
  .n-descriptions {
    background: transparent !important;
  }
  .n-descriptions-table-header {
    color: var(--text-secondary) !important;
  }
  .n-descriptions-table-content {
    color: var(--gold-light) !important;
  }

  /* 进度条 — 紫金渐变 */
  .n-progress .n-progress-graph-line-fill {
    background: linear-gradient(90deg, var(--purple-glow), var(--gold-dark), var(--gold), var(--gold-light)) !important;
    box-shadow: 0 0 8px rgba(212,168,67,0.3);
  }

  /* 按钮 */
  .n-button--primary-type {
    background: linear-gradient(135deg, var(--gold-dark), var(--gold)) !important;
    border-color: var(--gold) !important;
    color: #000 !important;
    font-weight: bold;
    transition: all 0.3s;
  }
  .n-button--primary-type:hover {
    background: linear-gradient(135deg, var(--gold), var(--gold-light)) !important;
    box-shadow: 0 0 20px rgba(212,168,67,0.4), 0 0 40px rgba(212,168,67,0.15);
    transform: translateY(-1px);
  }

  .n-button--success-type {
    background: linear-gradient(135deg, #2d5a1e, #4caf50) !important;
    border-color: #4caf50 !important;
  }

  .n-button--warning-type {
    background: linear-gradient(135deg, var(--gold-dark), var(--gold)) !important;
    border-color: var(--gold) !important;
    color: #1a1000 !important;
    font-weight: bold;
  }

  /* 标签 */
  .n-tag--warning-type {
    background: rgba(212,168,67,0.15) !important;
    color: var(--gold) !important;
    border-color: var(--border-gold) !important;
  }

  /* 分割线 */
  .n-divider__title {
    color: var(--gold) !important;
    font-family: 'Noto Serif SC', serif;
  }
  .n-divider .n-divider__line {
    background-color: var(--border-gold) !important;
  }

  /* 滚动条 */
  ::-webkit-scrollbar { width: 6px; height: 6px; }
  ::-webkit-scrollbar-track { background: var(--bg-dark); }
  ::-webkit-scrollbar-thumb { background: var(--border-gold); border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: var(--gold-dark); }

  /* 表格 */
  .n-data-table { background: transparent !important; }

  /* 输入框 */
  .n-input, .n-input-number {
    background: rgba(255,255,255,0.05) !important;
    border-color: var(--border-gold) !important;
  }
  .n-input:focus-within, .n-input-number:focus-within {
    border-color: var(--gold) !important;
    box-shadow: 0 0 8px rgba(212,168,67,0.2) !important;
  }
  /* 弹窗 */
  .n-modal, .n-dialog {
    background: var(--bg-card) !important;
    border: 1px solid var(--border-gold) !important;
    box-shadow: 0 0 40px rgba(0,0,0,0.6), 0 0 20px rgba(212,168,67,0.1) !important;
  }
  /* 折叠面板 */
  .n-collapse-item__header-main {
    color: var(--text-secondary) !important;
  }

  /* Radio 按钮 */
  .n-radio-button--checked {
    color: var(--gold) !important;
  }

  /* Alert 样式 */
  .n-alert {
    background: rgba(212,168,67,0.05) !important;
    border-color: var(--border-gold) !important;
  }

  /* Tab 样式 */
  .n-tabs .n-tab--active {
    color: var(--gold) !important;
    text-shadow: 0 0 8px rgba(212,168,67,0.3);
  }

  /* 白色主题下的 sub-page — handled in App Header section */

  /* ===== Header Mobile ===== */
  @media (max-width: 480px) {
    .header-title {
      font-size: 15px;
      letter-spacing: 2px;
    }
    .header-actions {
      gap: 4px;
    }
    .header-icon-btn {
      width: 28px;
      height: 28px;
    }
    .header-wallet-btn {
      font-size: 11px;
      padding: 0 8px;
      height: 26px;
    }
    .header-vip-tag {
      font-size: 10px;
      padding: 0 7px;
      height: 20px;
    }
    .sub-page-title {
      font-size: 14px;
    }
  }

  /* 底部导航栏 */
  .bottom-nav {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 100;
    height: 60px;
    background: rgba(8,8,16,0.95);
    border-top: 1px solid rgba(212,168,67,0.2);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    padding-bottom: env(safe-area-inset-bottom);
  }
  .bottom-nav-inner {
    display: flex;
    justify-content: space-around;
    align-items: center;
    height: 60px;
    max-width: 100%;
    overflow-x: auto;
    overflow-y: hidden;
    -webkit-overflow-scrolling: touch;
    scrollbar-width: none;
  }
  .bottom-nav-inner::-webkit-scrollbar { display: none; }
  .nav-tab {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 2px;
    cursor: pointer;
    padding: 6px 12px;
    min-width: 56px;
    flex-shrink: 0;
    transition: transform 0.15s ease;
    -webkit-tap-highlight-color: transparent;
    user-select: none;
  }
  .nav-tab:active {
    transform: scale(0.95);
  }
  .nav-icon {
    font-size: 22px;
    line-height: 1;
    filter: grayscale(0.6) brightness(0.7);
    transition: filter 0.25s ease;
  }
  .nav-indicator {
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: transparent;
    margin: 1px 0;
    transition: background 0.25s ease, box-shadow 0.25s ease;
  }
  .nav-label {
    font-size: 10px;
    line-height: 1;
    color: var(--text-secondary);
    transition: color 0.25s ease;
    white-space: nowrap;
  }
  /* 选中态 */
  .nav-tab.active .nav-icon {
    filter: grayscale(0) brightness(1) drop-shadow(0 0 6px rgba(212,168,67,0.4));
  }
  .nav-tab.active .nav-indicator {
    background: var(--gold);
    box-shadow: 0 0 6px rgba(212,168,67,0.5);
  }
  .nav-tab.active .nav-label {
    color: var(--gold);
    text-shadow: 0 0 8px rgba(212,168,67,0.3);
  }
  /* light theme */
  /* ========================================
     品质颜色发光系统 (Quality Rarity System)
     ======================================== */

  :root {
    --quality-common: #9e9e9e;
    --quality-uncommon: #4caf50;
    --quality-rare: #2196f3;
    --quality-epic: #9c27b0;
    --quality-legendary: #ff9800;
    --quality-mythic: #f44336;
    --quality-common-glow: rgba(158,158,158,0.3);
    --quality-uncommon-glow: rgba(76,175,80,0.4);
    --quality-rare-glow: rgba(33,150,243,0.4);
    --quality-epic-glow: rgba(156,39,176,0.4);
    --quality-legendary-glow: rgba(255,152,0,0.5);
    --quality-mythic-glow: rgba(244,67,54,0.5);
  }
  /* 1. 基础品质类 — border-color + box-shadow */
  .quality-common { border-color: var(--quality-common); box-shadow: 0 0 8px var(--quality-common-glow); }
  .quality-uncommon { border-color: var(--quality-uncommon); box-shadow: 0 0 8px var(--quality-uncommon-glow); }
  .quality-rare { border-color: var(--quality-rare); box-shadow: 0 0 8px var(--quality-rare-glow); }
  .quality-epic { border-color: var(--quality-epic); box-shadow: 0 0 8px var(--quality-epic-glow); }
  .quality-legendary { border-color: var(--quality-legendary); box-shadow: 0 0 8px var(--quality-legendary-glow); animation: legendary-shimmer 3s ease-in-out infinite; }
  .quality-mythic { border-color: var(--quality-mythic); box-shadow: 0 0 8px var(--quality-mythic-glow); animation: mythic-pulse 2s ease-in-out infinite; }

  /* 2. 品质边框类 — border + border-radius */
  .quality-border-common { border: 2px solid var(--quality-common); border-radius: 8px; }
  .quality-border-uncommon { border: 2px solid var(--quality-uncommon); border-radius: 8px; }
  .quality-border-rare { border: 2px solid var(--quality-rare); border-radius: 8px; }
  .quality-border-epic { border: 2px solid var(--quality-epic); border-radius: 8px; }
  .quality-border-legendary { border: 2px solid var(--quality-legendary); border-radius: 8px; }
  .quality-border-mythic { border: 2px solid var(--quality-mythic); border-radius: 8px; }

  /* 3. 品质发光类 — 双层 box-shadow */
  .quality-glow-common { box-shadow: 0 0 10px var(--quality-common-glow), 0 0 20px rgba(158,158,158,0.15); }
  .quality-glow-uncommon { box-shadow: 0 0 10px var(--quality-uncommon-glow), 0 0 20px rgba(76,175,80,0.2); }
  .quality-glow-rare { box-shadow: 0 0 10px var(--quality-rare-glow), 0 0 20px rgba(33,150,243,0.2); }
  .quality-glow-epic { box-shadow: 0 0 10px var(--quality-epic-glow), 0 0 20px rgba(156,39,176,0.2); }
  .quality-glow-legendary { box-shadow: 0 0 10px var(--quality-legendary-glow), 0 0 20px rgba(255,152,0,0.25); }
  .quality-glow-mythic { box-shadow: 0 0 10px var(--quality-mythic-glow), 0 0 20px rgba(244,67,54,0.25); }

  /* 4. 品质文字颜色类 */
  .quality-text-common { color: var(--quality-common); }
  .quality-text-uncommon { color: var(--quality-uncommon); }
  .quality-text-rare { color: var(--quality-rare); }
  .quality-text-epic { color: var(--quality-epic); }
  .quality-text-legendary { color: var(--quality-legendary); }
  .quality-text-mythic { color: var(--quality-mythic); }

  /* 5. 品质背景类 — 淡色底 */
  .quality-bg-common { background: rgba(158,158,158,0.1); }
  .quality-bg-uncommon { background: rgba(76,175,80,0.1); }
  .quality-bg-rare { background: rgba(33,150,243,0.1); }
  .quality-bg-epic { background: rgba(156,39,176,0.1); }
  .quality-bg-legendary { background: rgba(255,152,0,0.1); }
  .quality-bg-mythic { background: rgba(244,67,54,0.1); }

  /* 6. 源火(mythic) 呼吸动画 */
  @keyframes mythic-pulse {
    0%, 100% {
      box-shadow: 0 0 8px rgba(244,67,54,0.5), 0 0 20px rgba(244,67,54,0.25);
    }
    50% {
      box-shadow: 0 0 16px rgba(244,67,54,0.7), 0 0 36px rgba(244,67,54,0.4), 0 0 60px rgba(244,67,54,0.15);
    }
  }

  /* 7. 传说(legendary) 微光动画 */
  @keyframes legendary-shimmer {
    0%, 100% {
      border-color: #ff9800;
      box-shadow: 0 0 8px rgba(255,152,0,0.5);
    }
    50% {
      border-color: #ffd54f;
      box-shadow: 0 0 14px rgba(255,213,79,0.6), 0 0 28px rgba(255,152,0,0.2);
    }
  }
  /* === 强制黑色主题覆盖 naive-ui 白色背景 === */
  .n-layout,
  .n-layout-content,
  .n-layout-scroll-container,
  .n-config-provider,
  .n-spin-container,
  .n-spin-content,
  .n-dialog,
  .n-modal,
  .n-drawer,
  .n-drawer-body-content-wrapper {
    background-color: #0a0a0f !important;
    color: #e8e0d0 !important;
  }
  .n-layout-header {
    background-color: rgba(8,8,16,0.95) !important;
  }
  .n-card {
    background-color: #12121a !important;
    color: #e8e0d0 !important;
  }
  .n-button--default-type {
    color: #e8e0d0 !important;
  }
  .n-tabs-tab {
    color: #a09880 !important;
  }
  .n-tabs-tab--active {
    color: #f0d68a !important;
  }
  .n-tag {
    background-color: rgba(212,168,67,0.15) !important;
  }
  .n-data-table-th,
  .n-data-table-td {
    background-color: #12121a !important;
    color: #e8e0d0 !important;
  }
  .n-input,
  .n-input__input-el,
  .n-select {
    background-color: #1a1a24 !important;
    color: #e8e0d0 !important;
  }
  .n-popover,
  .n-dropdown-menu {
    background-color: #1a1a24 !important;
    color: #e8e0d0 !important;
  }
.buff-bar { display:flex; flex-wrap:wrap; gap:6px; padding:6px 12px; background:rgba(26,26,46,0.9); border-bottom:1px solid rgba(212,168,67,0.15); }
.buff-tag { font-size:11px; padding:2px 8px; border-radius:12px; background:rgba(212,168,67,0.15); color:#d4a843; white-space:nowrap; cursor:default; }

/* 页面切换过渡 */
.page-fade-enter-active { transition: opacity 0.2s ease, transform 0.2s ease; }
.page-fade-leave-active { transition: opacity 0.15s ease, transform 0.15s ease; }
.page-fade-enter-from { opacity: 0; transform: translateY(8px); }
.page-fade-leave-to { opacity: 0; transform: translateY(-4px); }

/* 子页面统一美化 */
.sub-page-header {
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}
.back-btn {
  transition: all 0.15s;
}
.back-btn:active {
  transform: scale(0.95);
  opacity: 0.8;
}

/* 全局 n-card 美化 */
:deep(.n-card) {
  background: rgba(10,8,18,0.6) !important;
  border: 1px solid rgba(212,168,67,0.12) !important;
  border-radius: 12px !important;
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}
:deep(.n-card-header) {
  padding: 12px 16px !important;
}
:deep(.n-card__content) {
  padding: 12px 16px !important;
}

/* 全局 n-alert 美化 */
:deep(.n-alert) {
  border-radius: 10px !important;
}

/* 全局 n-tabs segment 美化 */
:deep(.n-tabs .n-tabs-tab) {
  transition: all 0.2s;
}

/* 全局滚动条美化 */
::-webkit-scrollbar { width: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: rgba(212,168,67,0.2); border-radius: 2px; }
::-webkit-scrollbar-thumb:hover { background: rgba(212,168,67,0.4); }

/* 首页↔子页面切换动画 */
.page-slide-enter-active { transition: opacity 0.3s ease, transform 0.3s ease; }
.page-slide-leave-active { transition: opacity 0.2s ease, transform 0.2s ease; }
.page-slide-enter-from { opacity: 0; transform: translateX(30px); }
.page-slide-leave-to { opacity: 0; transform: translateX(-30px); }

/* 开场 Loading */
.splash-screen {
  position: fixed; inset: 0; z-index: 9999;
  background: radial-gradient(ellipse at 50% 40%, #1a1020 0%, #0a0810 100%);
  display: flex; align-items: center; justify-content: center;
}
.splash-particles { position: absolute; inset: 0; overflow: hidden; }
.splash-particle {
  position: absolute; bottom: -10px; border-radius: 50%;
  background: radial-gradient(circle, rgba(212,168,67,0.8), rgba(255,100,20,0.4), transparent);
  animation: splash-float linear infinite;
}
@keyframes splash-float {
  0% { transform: translateY(0) scale(1); opacity: 0; }
  15% { opacity: 0.8; }
  85% { opacity: 0.6; }
  100% { transform: translateY(-100vh) scale(0.2); opacity: 0; }
}
.splash-content { position: relative; z-index: 2; text-align: center; }
.splash-logo {
  font-size: 64px;
  animation: splash-logo-pulse 2s ease-in-out infinite;
  filter: drop-shadow(0 0 20px rgba(255,120,20,0.6));
}
@keyframes splash-logo-pulse {
  0%, 100% { transform: scale(1); filter: drop-shadow(0 0 20px rgba(255,120,20,0.6)); }
  50% { transform: scale(1.08); filter: drop-shadow(0 0 32px rgba(255,120,20,0.9)); }
}
.splash-title {
  font-size: 28px; font-weight: 900; letter-spacing: 6px; margin-top: 12px;
  font-family: 'Noto Serif SC', serif;
  background: linear-gradient(180deg, #f5e6c8, #d4a843, #b8860b);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
}
.splash-sub {
  font-size: 13px; color: #8a7a60; letter-spacing: 4px; margin-top: 4px;
}
.splash-bar-track {
  width: 180px; height: 4px; margin: 24px auto 0;
  background: rgba(212,168,67,0.15); border-radius: 2px; overflow: hidden;
}
.splash-bar-fill {
  height: 100%; border-radius: 2px;
  background: linear-gradient(90deg, #b8860b, #d4a843, #f0d68a);
  transition: width 0.2s ease;
  box-shadow: 0 0 8px rgba(212,168,67,0.5);
}
.splash-hint {
  font-size: 11px; color: #6a5a40; margin-top: 10px; letter-spacing: 1px;
}
.splash-fade-leave-active { transition: opacity 0.5s ease; }
.splash-fade-leave-to { opacity: 0; }

/* 底部导航增强 */
.nav-tab .nav-icon {
  transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.nav-tab.active .nav-icon {
  animation: nav-bounce 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}
@keyframes nav-bounce {
  0% { transform: scale(1); }
  40% { transform: scale(1.3); }
  70% { transform: scale(0.95); }
  100% { transform: scale(1.15); }
}
.nav-indicator {
  width: 4px; height: 4px; border-radius: 50%;
  background: transparent; transition: all 0.3s;
  margin-top: 1px;
}
.nav-tab.active .nav-indicator {
  background: #d4a843;
  box-shadow: 0 0 6px rgba(212,168,67,0.6);
}

/* 战斗屏幕震动 */
@keyframes battle-shake {
  0%, 100% { transform: translateX(0); }
  10% { transform: translateX(-4px) translateY(2px); }
  20% { transform: translateX(4px) translateY(-2px); }
  30% { transform: translateX(-3px) translateY(1px); }
  40% { transform: translateX(3px) translateY(-1px); }
  50% { transform: translateX(-2px); }
  60% { transform: translateX(2px); }
  70% { transform: translateX(-1px); }
  80% { transform: translateX(1px); }
}
.screen-shake {
  animation: battle-shake 0.4s ease-out;
}
</style>
