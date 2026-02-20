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
                  <button class="header-icon-btn" @click="router.push('/settings')">
                    <n-icon :size="15"><SettingOutlined /></n-icon>
                  </button>
                  <n-dropdown :options="walletMenuOptions" @select="handleWalletMenu">
                    <button class="header-wallet-btn">{{ authStore.shortWallet }}</button>
                  </n-dropdown>
                </div>
              </div>
            </n-layout-header>
            <n-layout-content>
              <div class="content-wrapper">
                <!-- 主城：只在首页显示 -->
                <GameScene
                  v-if="isHome"
                  :playerName="playerStore.name"
                  :playerRealm="getRealmName(playerStore.level).name"
                  :activeTab="activeTab"
                  @navigate="handleGameNavigate"
                />
                <!-- 子页面：返回按钮 + 内容 -->
                <div v-else>
                  <div class="sub-page-header">
                    <button class="back-btn" @click="goBack">← 返回</button>
                    <span class="sub-page-title">{{ currentPageTitle }}</span>
                    <span class="sub-page-spacer"></span>
                  </div>
                  <router-view />
                </div>
              </div>
            </n-layout-content>
            <WorldChat />
            <div class="bottom-nav">
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
      </n-dialog-provider>
    </n-message-provider>
  </n-config-provider>
</template>

<script setup>
  import { useRouter, useRoute } from 'vue-router'
  import { usePlayerStore } from './stores/player'
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

  const router = useRouter()
  const route = useRoute()
  const playerStore = usePlayerStore()
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

  const routeTabMap = {
    cultivation: 'adventure', dungeon: 'adventure', 'daily-dungeon': 'adventure',
    exploration: 'adventure', boss: 'adventure',
    profile: 'character', inventory: 'character', alchemy: 'character',
    'mount-title': 'character', ascension: 'character', achievements: 'character',
    sect: 'social', 'sect-war': 'social', friends: 'social',
    pk: 'social', auction: 'social', rank: 'social',
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
    { label: '云存档', key: 'save' },
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
    if (key === 'save') {
      try {
        await authStore.saveToCloud(playerStore)
        alert('云存档保存成功！')
      } catch (e) { alert('保存失败：' + e.message) }
    } else if (key === 'logout') {
      authStore.logout()
    }
  }

  const initGame = async () => {
    isLoading.value = true
    await playerStore.initializePlayer()
    isLoading.value = false
    getMenuOptions()
    startAutoGain()
    // 离线收益
    const reward = playerStore.calculateOfflineReward()
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
      ...(authStore.wallet?.toLowerCase() === "0xfad7eb0814b6838b05191a07fb987957d50c4ca9" ? [{ label: "活动管理", key: "admin/events", icon: renderIcon(SettingOutlined) }] : []),
      ...(playerStore.isGMMode
        ? [{ label: 'GM调试', key: 'gm', icon: renderIcon(SmileOutlined) }]
        : [])
    ]
  }

  const startAutoGain = () => {
    if (spiritWorker.value) return
    spiritWorker.value = new Worker(new URL('./workers/spirit.js', import.meta.url))
    spiritWorker.value.onmessage = e => {
      if (e.data.type === 'gain') {
        playerStore.totalCultivationTime += 1
        playerStore.gainSpirit(baseGainRate)
      }
    }
    spiritWorker.value.postMessage({ type: 'start' })
  }

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
    vip: '焰阶', achievements: '焰功', rank: '焰榜', settings: '设置',
    'admin/events': '活动管理', gm: 'GM调试', profile: '角色信息'
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
  const emergencySave = () => {
    playerStore.updateOnlineTime()
    if (authStore.isLoggedIn) {
      const gameData = playerStore.$state
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
  }  .sub-page-spacer {
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
</style>
