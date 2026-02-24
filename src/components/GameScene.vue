<template>
  <div class="main-city">
    <!-- 背景层 -->
    <div class="city-bg">
      <div class="stars">
        <span v-for="i in 30" :key="i" class="star" :style="starStyle(i)"></span>
      </div>
      <div class="moon"></div>
      <div class="mountain mountain-far"></div>
      <div class="mountain mountain-mid"></div>
      <div class="mountain mountain-near"></div>
      <div class="clouds">
        <span v-for="i in 4" :key="i" class="cloud" :style="cloudStyle(i)"></span>
      </div>
      <div class="spirit-particles">
        <span v-for="i in 15" :key="i" class="sp" :style="spStyle(i)"></span>
      </div>
      <!-- 火焰粒子 -->
      <div class="flame-particles">
        <span v-for="i in 12" :key="i" class="flame" :style="flameStyle(i)"></span>
      </div>
      <!-- 萤火虫 -->
      <div class="fireflies">
        <span v-for="i in 8" :key="i" class="firefly" :style="fireflyStyle(i)"></span>
      </div>
    </div>

    <!-- 公告栏 -->
    <div class="announcement-bar" v-if="announcements.length > 0">
      <span class="ann-icon">📢</span>
      <div class="ann-scroll">
        <div class="ann-track" :style="{ animationDuration: announcements.length * 6 + 's' }">
          <span v-for="(a, i) in announcements" :key="i" class="ann-item">{{ a.content }}</span>
          <span v-for="(a, i) in announcements" :key="'d' + i" class="ann-item">{{ a.content }}</span>
        </div>
      </div>
    </div>

    <!-- 限时活动 -->
    <div class="events-bar" v-if="events.length > 0">
      <div v-for="evt in events" :key="evt.id" class="event-badge" :class="'evt-' + evt.type">
        <span class="evt-icon">{{ evtIcon(evt.type) }}</span>
        <span class="evt-name">{{ evt.name }}</span>
        <span class="evt-time">{{ evtTimeLeft(evt.ends_at) }}</span>
      </div>
    </div>

    <!-- 角色区域 -->
    <div class="player-area">
      <div class="aura"></div>
      <div class="aura aura2"></div>
      <img :src="charImage" class="char-img" />
      <div class="player-info">
        <span class="p-name">{{ playerName }}</span>
        <span class="p-realm">{{ playerRealm }}</span>
      </div>
    </div>

    <!-- 主城信息面板（home tab） -->
    <div class="home-panel" v-if="activeTab === 'home'">
      <!-- 资源栏 -->
      <div class="hp-resources">
        <div class="hp-res" v-for="r in resources" :key="r.label">
          <span class="hp-res-icon">{{ r.icon }}</span>
          <span class="hp-res-val">{{ (r.value || 0).toLocaleString() }}</span>
          <span class="hp-res-label">{{ r.label }}</span>
        </div>
      </div>
      <!-- 账号概况 -->
      <div class="hp-card">
        <div class="hp-card-title">📊 账号概况</div>
        <div class="hp-stats-grid">
          <div class="hp-stat">
            <span class="hp-stat-label">修炼进度</span>
            <div class="hp-progress"><div class="hp-progress-fill" :style="{ width: cultivationPct + '%' }"></div></div>
            <span class="hp-stat-val">{{ playerStore.cultivation || 0 }}/{{ playerStore.maxCultivation || 100 }}</span>
          </div>
          <div class="hp-stat">
            <span class="hp-stat-label">突破次数</span>
            <span class="hp-stat-big">{{ playerStore.breakthroughCount || 0 }}</span>
          </div>
          <div class="hp-stat">
            <span class="hp-stat-label">修炼时长</span>
            <span class="hp-stat-big">{{ fmtTime(playerStore.totalCultivationTime || 0) }}</span>
          </div>
          <div class="hp-stat">
            <span class="hp-stat-label">探索次数</span>
            <span class="hp-stat-big">{{ playerStore.explorationCount || 0 }}</span>
          </div>
        </div>
        <div class="hp-rows">
          <div class="hp-row">
            <span>🏅 VIP等级</span>
            <span class="hp-row-val">VIP{{ authStore.vipLevel || 0 }}</span>
          </div>
          <div class="hp-row">
            <span>⚔️ 战力</span>
            <span class="hp-row-val hp-gold">{{ (playerStore.getCombatPower() || 0).toLocaleString() }}</span>
          </div>
          <div class="hp-row">
            <span>🐾 焰兽</span>
            <span class="hp-row-val" v-if="playerStore.activePet">{{ playerStore.activePet.name }}</span>
            <span class="hp-row-val hp-dim" v-else>未出战</span>
          </div>
          <div class="hp-row">
            <span>🏔️ 焚天塔</span>
            <span class="hp-row-val">最高 {{ playerStore.dungeonHighestFloor || 0 }}层</span>
          </div>
          <div class="hp-row">
            <span>🎒 背包</span>
            <span class="hp-row-val">{{ itemCount }}件物品</span>
          </div>
        </div>
      </div>
      <!-- 快捷入口 -->
      <div class="hp-card">
        <div class="hp-card-title">🚀 快捷入口</div>
        <div class="hp-shortcuts">
          <div v-for="sc in quickLinks" :key="sc.key" class="hp-sc" @click="$emit('navigate', sc.key)">
            <span class="hp-sc-icon">{{ sc.icon }}</span>
            <span class="hp-sc-text">{{ sc.label }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部功能网格（按分类显示） -->
    <div class="menu-grid" v-if="activeTab !== 'home' && currentMenus.length > 0">
      <div
        v-for="b in currentMenus"
        :key="b.key"
        class="menu-card"
        :class="'menu-' + b.theme"
        @click="$emit('navigate', b.key)"
      >
        <div class="m-icon-wrap">
          <div class="m-icon-glow"></div>
          <img :src="b.icon" class="m-icon-img" />
        </div>
        <div class="m-name">{{ b.label }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'

const playerStore = usePlayerStore()
const authStore = useAuthStore()

const props = defineProps({
  playerName: { type: String, default: '无名焰修' },
  playerRealm: { type: String, default: '燃火期' },
  activeTab: { type: String, default: 'home' },
})

defineEmits(['navigate'])

// 根据境界阶段返回对应角色图片
const charImage = computed(() => {
  const realm = props.playerRealm
  // 仙人/至高阶段
  if (/焰帝|永焰/.test(realm)) return '/assets/images/char-emperor.png'
  if (/焰仙|真焰|圣焰/.test(realm)) return '/assets/images/char-immortal.png'
  // 强者阶段
  if (/焰合|大焰|渡焰/.test(realm)) return '/assets/images/char-warrior.png'
  // 修士阶段
  if (/焰婴|化焰|焰虚/.test(realm)) return '/assets/images/char-cultivator.png'
  // 凡人阶段
  return '/assets/images/char-mortal.png'
})

const announcements = ref([])
const events = ref([])

onMounted(async () => {
  try {
    const res = await fetch('/api/announcements')
    const data = await res.json()
    announcements.value = data.announcements || []
  } catch {}
  try {
    const res = await fetch('/api/events/active')
    const data = await res.json()
    events.value = data.events || []
  } catch {}
})

const evtIcon = (type) => {
  const icons = { double_cultivation: '⚡', gacha_rate_up: '🎴', double_drop: '💎', discount: '🏷️' }
  return icons[type] || '🎉'
}

const evtTimeLeft = (endsAt) => {
  const diff = new Date(endsAt).getTime() - Date.now()
  if (diff <= 0) return '已结束'
  const h = Math.floor(diff / 3600000)
  const m = Math.floor((diff % 3600000) / 60000)
  if (h >= 24) return `${Math.floor(h / 24)}天${h % 24}时`
  return `${h}时${m}分`
}

const menusByTab = {
  adventure: [
    { key: 'cultivation', label: '修炼', icon: '/assets/images/menu/menu_cultivation.png', theme: 'purple' },
    { key: 'dungeon', label: '焚天塔', icon: '/assets/images/menu/menu_dungeon.png', theme: 'purple' },
    { key: 'daily-dungeon', label: '焰境', icon: '/assets/images/menu/menu_daily_dungeon.png', theme: 'blue' },
    { key: 'exploration', label: '探索', icon: '/assets/images/menu/menu_exploration.png', theme: 'blue' },
    { key: 'boss', label: '黑焰入侵', icon: '/assets/images/menu/menu_boss.png', theme: 'red' },
  ],
  character: [
    { key: 'profile', label: '角色信息', icon: '/assets/images/menu/menu_profile.png', theme: 'gold' },
    { key: 'inventory', label: '背包', icon: '/assets/images/menu/menu_inventory.png', theme: 'gold' },
    { key: 'alchemy', label: '焰炼', icon: '/assets/images/menu/menu_alchemy.png', theme: 'red' },
    { key: 'mount-title', label: '焰骑焰号', icon: '/assets/images/menu/menu_mount.png', theme: 'green' },
    { key: 'ascension', label: '涅槃飞升', icon: '/assets/images/menu/menu_ascension.png', theme: 'purple' },
    { key: 'achievements', label: '焰功', icon: '/assets/images/menu/menu_achievements.png', theme: 'blue' },
  ],
  social: [
    { key: 'sect', label: '焰盟', icon: '/assets/images/menu/menu_sect.png', theme: 'purple' },
    { key: 'sect-war', label: '焰盟战', icon: '/assets/images/menu/menu_sect_war.png', theme: 'red' },
    { key: 'friends', label: '焰友', icon: '/assets/images/menu/menu_friends.png', theme: 'green' },
    { key: 'pk', label: '焰武', icon: '/assets/images/menu/menu_pk.png', theme: 'red' },
    { key: 'auction', label: '焰市', icon: '/assets/images/menu/menu_auction.png', theme: 'gold' },
    { key: 'rank', label: '焰榜', icon: '/assets/images/menu/menu_rank.png', theme: 'blue' },
  ],
  market: [
    { key: 'shop', label: '焰晶商铺', icon: '/assets/images/menu/menu_shop.png', theme: 'gold' },
    { key: 'recharge', label: '充值', icon: '/assets/images/menu/menu_recharge.png', theme: 'gold' },
    { key: 'vip', label: '焰阶', icon: '/assets/images/menu/menu_vip.png', theme: 'gold' },
    { key: 'gacha', label: '焰运阁', icon: '/assets/images/menu/menu_gacha.png', theme: 'green' },
    { key: 'events', label: '活动', icon: '/assets/images/menu/menu_events.png', theme: 'red' },
  ],
}

const currentMenus = computed(() => {
  return menusByTab[props.activeTab] || []
})

// === Home panel data ===
const resources = computed(() => [
  { icon: '💎', label: '焰晶', value: playerStore.spiritStones || 0 },
  { icon: '💠', label: '焰灵', value: Math.floor(playerStore.spirit || 0) },
  { icon: '🔨', label: '淬火石', value: playerStore.reinforceStones || 0 },
  { icon: '🔮', label: '符文石', value: playerStore.refinementStones || 0 },
  { icon: '🐾', label: '精华', value: playerStore.petEssence || 0 },
])

const cultivationPct = computed(() => {
  if (!playerStore.maxCultivation) return 0
  return Math.min(100, Math.round((playerStore.cultivation || 0) / playerStore.maxCultivation * 100))
})

const itemCount = computed(() => {
  return (playerStore.items?.length || 0) + (playerStore.herbs?.length || 0)
})

const fmtTime = (s) => {
  if (s < 60) return `${s}秒`
  if (s < 3600) return `${Math.floor(s / 60)}分钟`
  const h = Math.floor(s / 3600)
  return h >= 24 ? `${Math.floor(h / 24)}天${h % 24}时` : `${h}小时`
}

const quickLinks = [
  { key: 'cultivation', icon: '⚔️', label: '修炼' },
  { key: 'inventory', icon: '🎒', label: '背包' },
  { key: 'gacha', icon: '🎰', label: '抽卡' },
  { key: 'dungeon', icon: '🏔️', label: '焚天塔' },
  { key: 'alchemy', icon: '🧪', label: '炼丹' },
  { key: 'exploration', icon: '🗺️', label: '探索' },
  { key: 'shop', icon: '🏪', label: '商店' },
  { key: 'profile', icon: '👤', label: '个人' },
]

const starStyle = (i) => ({
  left: `${(i * 13 + 7) % 100}%`,
  top: `${(i * 7 + 3) % 35}%`,
  animationDelay: `${(i * 0.5) % 4}s`,
  width: `${1 + (i % 3)}px`,
  height: `${1 + (i % 3)}px`,
})

const cloudStyle = (i) => ({
  left: `${-20 + i * 28}%`,
  top: `${25 + (i % 3) * 8}%`,
  animationDelay: `${i * 8}s`,
  animationDuration: `${40 + i * 10}s`,
  opacity: 0.03 + (i % 3) * 0.02,
})

const flameStyle = (i) => ({
    left: (i * 8.3 + Math.sin(i) * 5) % 100 + '%',
    bottom: '-10px',
    animationDelay: (i * 0.7) + 's',
    animationDuration: (3 + Math.random() * 4) + 's',
    opacity: 0.3 + Math.random() * 0.4,
    '--size': (4 + Math.random() * 6) + 'px',
  })

  const fireflyStyle = (i) => ({
    left: (i * 12.5 + Math.sin(i * 2) * 10) % 100 + '%',
    top: (20 + Math.random() * 60) + '%',
    animationDelay: (i * 1.2) + 's',
    animationDuration: (4 + Math.random() * 6) + 's',
  })

  const spStyle = (i) => ({
  left: `${(i * 11 + 5) % 90 + 5}%`,
  bottom: `${(i * 7) % 30 + 10}%`,
  animationDelay: `${(i * 0.8) % 5}s`,
  animationDuration: `${3 + (i % 4) * 1.5}s`,
})
</script>

<style scoped>
.main-city {
  position: relative;
  width: 100%;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(212,168,67,0.25);
  box-shadow: 0 4px 40px rgba(0,0,0,0.6), 0 0 30px rgba(212,168,67,0.06);
  user-select: none;
}

/* === 背景 === */
.city-bg {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(rgba(5,5,16,0.3), rgba(10,10,26,0.5)),
    url('/assets/images/bg-main.png') center/cover no-repeat;
}

/* 星星 */
.star {
  position: absolute;
  border-radius: 50%;
  background: #f0d68a;
  animation: twinkle 3s ease-in-out infinite;
}
@keyframes twinkle {
  0%, 100% { opacity: 0.2; }
  50% { opacity: 0.8; }
}

/* 月亮 */
.moon {
  position: absolute;
  right: 12%;
  top: 6%;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: radial-gradient(circle at 35% 35%, #fff8e0 0%, #f0d68a 40%, rgba(212,168,67,0.3) 70%, transparent 100%);
  box-shadow: 0 0 40px rgba(240,214,138,0.3), 0 0 80px rgba(212,168,67,0.15);
}

/* 远山 */
.mountain {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
}
.mountain-far {
  height: 55%;
  background:
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 300'%3E%3Cpath d='M0,300 L0,180 Q100,80 200,160 Q280,60 400,140 Q500,40 600,120 Q700,30 800,130 Q900,50 1000,150 Q1100,70 1200,160 L1200,300Z' fill='%230d0d1a' opacity='0.7'/%3E%3C/svg%3E") bottom/cover no-repeat;
}
.mountain-mid {
  height: 45%;
  background:
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 250'%3E%3Cpath d='M0,250 L0,150 Q150,50 300,130 Q400,30 550,110 Q650,20 800,100 Q950,40 1050,120 Q1150,60 1200,140 L1200,250Z' fill='%23111125' opacity='0.8'/%3E%3C/svg%3E") bottom/cover no-repeat;
}
.mountain-near {
  height: 35%;
  background:
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 200'%3E%3Cpath d='M0,200 L0,120 Q100,60 250,100 Q350,40 500,90 Q600,30 750,80 Q900,50 1000,100 Q1100,60 1200,110 L1200,200Z' fill='%23151530' opacity='0.9'/%3E%3C/svg%3E") bottom/cover no-repeat;
}

/* 云 */
.cloud {
  position: absolute;
  width: 200px;
  height: 30px;
  border-radius: 50%;
  background: radial-gradient(ellipse, rgba(212,168,67,0.06) 0%, transparent 70%);
  filter: blur(10px);
  animation: drift linear infinite;
}
@keyframes drift {
  0% { transform: translateX(0); }
  100% { transform: translateX(120vw); }
}

/* 焰灵粒子 */
.sp {
  position: absolute;
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(212,168,67,0.7), transparent);
  animation: rise ease-out infinite;
}
@keyframes rise {
  0% { transform: translateY(0) scale(1); opacity: 0; }
  15% { opacity: 0.6; }
  85% { opacity: 0.3; }
  100% { transform: translateY(-120px) scale(0.2); opacity: 0; }
}

.spirit-particles { position: absolute; inset: 0; pointer-events: none; }

/* === 公告栏 === */
.announcement-bar {
  position: relative;
  z-index: 3;
  display: flex;
  align-items: center;
  margin: 8px 12px 0;
  padding: 6px 10px;
  background: rgba(212,168,67,0.08);
  border: 1px solid rgba(212,168,67,0.15);
  border-radius: 8px;
  overflow: hidden;
}
.ann-icon {
  font-size: 14px;
  margin-right: 8px;
  flex-shrink: 0;
}
.ann-scroll {
  flex: 1;
  overflow: hidden;
  mask-image: linear-gradient(90deg, transparent, #000 8%, #000 92%, transparent);
}
.ann-track {
  display: flex;
  gap: 60px;
  white-space: nowrap;
  animation: scroll-left linear infinite;
}
.ann-item {
  font-size: 12px;
  color: #f0d68a;
  flex-shrink: 0;
}
@keyframes scroll-left {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}

/* === 限时活动 === */
.events-bar {
  position: relative;
  z-index: 3;
  display: flex;
  gap: 8px;
  padding: 6px 12px 0;
  flex-wrap: wrap;
}
.event-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  animation: evt-pulse 2s ease-in-out infinite;
}
.evt-double_cultivation {
  background: linear-gradient(135deg, rgba(124,92,191,0.25), rgba(124,92,191,0.1));
  border: 1px solid rgba(124,92,191,0.4);
  color: #c4a8ff;
}
.evt-gacha_rate_up {
  background: linear-gradient(135deg, rgba(76,175,80,0.25), rgba(76,175,80,0.1));
  border: 1px solid rgba(76,175,80,0.4);
  color: #a5d6a7;
}
.evt-double_drop {
  background: linear-gradient(135deg, rgba(66,165,245,0.25), rgba(66,165,245,0.1));
  border: 1px solid rgba(66,165,245,0.4);
  color: #90caf9;
}
.evt-discount {
  background: linear-gradient(135deg, rgba(229,57,53,0.25), rgba(229,57,53,0.1));
  border: 1px solid rgba(229,57,53,0.4);
  color: #ef9a9a;
}
.evt-icon { font-size: 14px; }
.evt-name { font-weight: bold; }
.evt-time { opacity: 0.7; font-size: 11px; }
@keyframes evt-pulse {
  0%, 100% { opacity: 0.85; }
  50% { opacity: 1; }
}

/* === 角色区域 === */
.player-area {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 80px;
  z-index: 2;
}

.aura {
  position: absolute;
  top: 70px;
  width: 120px;
  height: 120px;
  border-radius: 50%;
  border: 1px solid rgba(212,168,67,0.15);
  background: radial-gradient(circle, rgba(212,168,67,0.08) 0%, transparent 70%);
  animation: aura-pulse 3s ease-in-out infinite;
}
.aura2 {
  width: 160px;
  height: 160px;
  top: 50px;
  border-color: rgba(124,92,191,0.1);
  background: radial-gradient(circle, rgba(124,92,191,0.05) 0%, transparent 70%);
  animation-delay: 1s;
  animation-duration: 4s;
}
@keyframes aura-pulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.15); opacity: 1; }
}

.char-img {
  width: 120px;
  border-radius: 16px;
  border: 2px solid rgba(212,168,67,0.4);
  box-shadow: 0 0 20px rgba(212,168,67,0.3), 0 4px 12px rgba(0,0,0,0.5);
  position: relative;
  z-index: 1;
}

.player-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 8px;
  gap: 2px;
}
.p-name {
  font-size: 14px;
  font-weight: bold;
  color: #f0d68a;
  text-shadow: 0 0 10px rgba(212,168,67,0.4);
  font-family: 'Noto Serif SC', serif;
}
.p-realm {
  font-size: 11px;
  color: #a09880;
  background: rgba(212,168,67,0.1);
  padding: 1px 10px;
  border-radius: 10px;
  border: 1px solid rgba(212,168,67,0.2);
}

/* === 底部功能网格 === */
.menu-grid {
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  padding: 16px 12px 16px;
  background: rgba(10,10,15,0.6);
  backdrop-filter: blur(8px);
  border-top: 1px solid rgba(212,168,67,0.1);
}

.menu-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 12px 4px 10px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid rgba(212,168,67,0.15);
  background: rgba(15,15,25,0.8);
}
.menu-card:hover {
  transform: translateY(-2px);
  border-color: rgba(212,168,67,0.4);
  box-shadow: 0 4px 16px rgba(212,168,67,0.15);
}
.menu-card:active {
  transform: scale(0.97);
}

/* 主题边框色 */
.menu-purple { border-color: rgba(124,92,191,0.15); }
.menu-gold   { border-color: rgba(212,168,67,0.15); }
.menu-green  { border-color: rgba(76,175,80,0.15); }
.menu-red    { border-color: rgba(229,57,53,0.15); }
.menu-blue   { border-color: rgba(66,165,245,0.15); }

.menu-purple:hover { border-color: rgba(124,92,191,0.4); box-shadow: 0 4px 16px rgba(124,92,191,0.2); }
.menu-gold:hover   { border-color: rgba(212,168,67,0.4); box-shadow: 0 4px 16px rgba(212,168,67,0.2); }
.menu-green:hover  { border-color: rgba(76,175,80,0.4); box-shadow: 0 4px 16px rgba(76,175,80,0.2); }
.menu-red:hover    { border-color: rgba(229,57,53,0.4); box-shadow: 0 4px 16px rgba(229,57,53,0.2); }
.menu-blue:hover   { border-color: rgba(66,165,245,0.4); box-shadow: 0 4px 16px rgba(66,165,245,0.2); }

/* 图标容器 */
.m-icon-wrap {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  margin-bottom: 4px;
}
.m-icon-glow {
  position: absolute;
  bottom: 0;
  width: 36px;
  height: 18px;
  border-radius: 50%;
  background: radial-gradient(ellipse, rgba(212,168,67,0.2) 0%, transparent 70%);
  pointer-events: none;
}
.menu-purple .m-icon-glow { background: radial-gradient(ellipse, rgba(124,92,191,0.2) 0%, transparent 70%); }
.menu-green .m-icon-glow  { background: radial-gradient(ellipse, rgba(76,175,80,0.2) 0%, transparent 70%); }
.menu-red .m-icon-glow    { background: radial-gradient(ellipse, rgba(229,57,53,0.2) 0%, transparent 70%); }
.menu-blue .m-icon-glow   { background: radial-gradient(ellipse, rgba(66,165,245,0.2) 0%, transparent 70%); }

.m-icon-img {
  width: 36px;
  height: 36px;
  object-fit: contain;
  position: relative;
  z-index: 1;
  filter: drop-shadow(0 0 4px rgba(212,168,67,0.3));
}
.m-name {
  font-size: 12px;
  color: var(--gold-light, #f0d68a);
  font-weight: bold;
  letter-spacing: 1px;
  white-space: nowrap;
}

/* 响应式 */
@media (max-width: 480px) {
  .menu-grid { grid-template-columns: repeat(3, 1fr); gap: 8px; padding: 12px 8px; }
  .menu-card { padding: 10px 2px 8px; }
  .m-icon-img { width: 28px; height: 28px; }
  .m-icon-wrap { width: 38px; height: 38px; }
  .m-name { font-size: 11px; letter-spacing: 0.5px; }
  .player-area { padding-top: 60px; }
}

/* === Home Panel === */
.home-panel { padding: 0 12px 12px; position: relative; z-index: 2; }
.hp-resources { display: flex; gap: 4px; margin-bottom: 10px; }
.hp-res { flex: 1; display: flex; flex-direction: column; align-items: center; background: rgba(10,8,18,0.7); border: 1px solid rgba(212,168,67,0.15); border-radius: 8px; padding: 6px 2px; gap: 1px; }
.hp-res-icon { font-size: 1rem; }
.hp-res-val { font-size: 0.8rem; font-weight: 700; color: #d4a843; }
.hp-res-label { font-size: 0.55rem; color: #6a6560; }
.hp-card { background: rgba(10,8,18,0.7); border: 1px solid rgba(212,168,67,0.18); border-radius: 10px; padding: 10px 12px; margin-bottom: 8px; }
.hp-card-title { font-size: 0.82rem; font-weight: 600; color: #d4a843; margin-bottom: 8px; }
.hp-stats-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 6px; margin-bottom: 8px; }
.hp-stat { display: flex; flex-direction: column; align-items: center; gap: 3px; background: rgba(20,18,30,0.5); border-radius: 6px; padding: 6px 4px; border: 1px solid rgba(212,168,67,0.08); }
.hp-stat-label { font-size: 0.65rem; color: #6a6560; }
.hp-stat-val { font-size: 0.7rem; color: #a09880; }
.hp-stat-big { font-size: 0.95rem; font-weight: 700; color: #d4a843; }
.hp-progress { width: 100%; height: 3px; background: #2a2520; border-radius: 2px; overflow: hidden; }
.hp-progress-fill { height: 100%; background: linear-gradient(90deg, #b8860b, #ffd700); border-radius: 2px; }
.hp-rows { display: flex; flex-direction: column; }
.hp-row { display: flex; justify-content: space-between; align-items: center; padding: 5px 0; border-bottom: 1px solid rgba(212,168,67,0.06); font-size: 0.78rem; color: #8a8070; }
.hp-row:last-child { border-bottom: none; }
.hp-row-val { font-weight: 600; color: #d4a843; }
.hp-gold { color: #ff9800 !important; }
.hp-dim { color: #5a5550 !important; font-weight: 400 !important; }
.hp-shortcuts { display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px; }
.hp-sc { display: flex; flex-direction: column; align-items: center; gap: 3px; background: rgba(20,18,30,0.5); border: 1px solid rgba(212,168,67,0.1); border-radius: 8px; padding: 8px 2px; cursor: pointer; transition: all 0.2s; }
.hp-sc:active { background: rgba(212,168,67,0.12); transform: scale(0.95); }
.hp-sc-icon { font-size: 1.2rem; }
.hp-sc-text { font-size: 0.7rem; color: #a09880; }
/* === 白色主题 === */
/* 火焰粒子 */
.flame-particles {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
  z-index: 1;
}
.flame {
  position: absolute;
  width: var(--size, 5px);
  height: var(--size, 5px);
  background: radial-gradient(circle, #ffa500, #ff6b35, transparent);
  border-radius: 50%;
  filter: blur(1px);
  animation: flame-rise linear infinite;
}
@keyframes flame-rise {
  0% { transform: translateY(0) translateX(0) scale(1); opacity: 0; }
  10% { opacity: 0.6; }
  50% { transform: translateY(-40vh) translateX(20px) scale(0.8); opacity: 0.4; }
  100% { transform: translateY(-80vh) translateX(-10px) scale(0.2); opacity: 0; }
}

/* 萤火虫 */
.fireflies {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
  z-index: 1;
}
.firefly {
  position: absolute;
  width: 4px;
  height: 4px;
  background: #ffd700;
  border-radius: 50%;
  box-shadow: 0 0 6px 2px rgba(255, 215, 0, 0.6), 0 0 12px 4px rgba(255, 165, 0, 0.3);
  animation: firefly-float ease-in-out infinite;
}
@keyframes firefly-float {
  0%, 100% { transform: translate(0, 0) scale(1); opacity: 0.2; }
  25% { transform: translate(15px, -20px) scale(1.2); opacity: 0.8; }
  50% { transform: translate(-10px, -10px) scale(0.8); opacity: 0.4; }
  75% { transform: translate(20px, 10px) scale(1.1); opacity: 0.9; }
}
</style>
