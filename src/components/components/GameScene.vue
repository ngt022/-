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
      <div class="player-figure">
        <div class="player-head"></div>
        <div class="player-body"></div>
        <div class="player-lotus"></div>
      </div>
      <div class="player-info">
        <span class="p-name">{{ playerName }}</span>
        <span class="p-realm">{{ playerRealm }}</span>
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
        <div class="m-icon">{{ b.icon }}</div>
        <div class="m-name">{{ b.label }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  playerName: { type: String, default: '无名焰修' },
  playerRealm: { type: String, default: '燃火期' },
  activeTab: { type: String, default: 'home' },
})

defineEmits(['navigate'])

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
    { key: 'cultivation', label: '修炼', icon: '🧘', theme: 'purple' },
    { key: 'dungeon', label: '焚天塔', icon: '⚔️', theme: 'purple' },
    { key: 'daily-dungeon', label: '焰境', icon: '🏯', theme: 'blue' },
    { key: 'exploration', label: '探索', icon: '🗺️', theme: 'blue' },
    { key: 'boss', label: '黑焰入侵', icon: '🐉', theme: 'red' },
  ],
  character: [
    { key: 'profile', label: '角色信息', icon: '👤', theme: 'gold' },
    { key: 'inventory', label: '背包', icon: '💎', theme: 'gold' },
    { key: 'alchemy', label: '焰炼', icon: '🔥', theme: 'red' },
    { key: 'mount-title', label: '焰骑焰号', icon: '🐎', theme: 'green' },
    { key: 'ascension', label: '涅槃飞升', icon: '✨', theme: 'purple' },
    { key: 'achievements', label: '焰功', icon: '🏆', theme: 'blue' },
  ],
  social: [
    { key: 'sect', label: '焰盟', icon: '🏛️', theme: 'purple' },
    { key: 'sect-war', label: '焰盟战', icon: '⚔️', theme: 'red' },
    { key: 'friends', label: '焰友', icon: '🤝', theme: 'green' },
    { key: 'pk', label: '焰武', icon: '🥊', theme: 'red' },
    { key: 'auction', label: '焰市', icon: '🏷️', theme: 'gold' },
    { key: 'rank', label: '焰榜', icon: '📊', theme: 'blue' },
  ],
  market: [
    { key: 'shop', label: '焰晶商铺', icon: '🏪', theme: 'gold' },
    { key: 'recharge', label: '充值', icon: '💰', theme: 'gold' },
    { key: 'vip', label: '焰阶', icon: '👑', theme: 'gold' },
    { key: 'gacha', label: '焰运阁', icon: '🎴', theme: 'green' },
    { key: 'events', label: '活动', icon: '🎉', theme: 'red' },
  ],
}

const currentMenus = computed(() => {
  return menusByTab[props.activeTab] || []
})

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
    linear-gradient(180deg,
      #050510 0%,
      #0a0a1a 20%,
      #0f0f25 40%,
      #12102a 55%,
      #1a1535 70%,
      #0d0d18 100%
    );
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

.player-figure {
  position: relative;
  width: 60px;
  height: 80px;
}
.player-head {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: linear-gradient(135deg, #f5e6c8, #e8d5a8);
  margin: 0 auto 2px;
  box-shadow: 0 0 10px rgba(212,168,67,0.3);
}
.player-body {
  width: 0;
  height: 0;
  border-left: 22px solid transparent;
  border-right: 22px solid transparent;
  border-bottom: 40px solid #2a1f6e;
  margin: 0 auto;
  filter: drop-shadow(0 0 8px rgba(42,31,110,0.5));
  position: relative;
}
.player-body::after {
  content: '';
  position: absolute;
  top: 10px;
  left: -8px;
  width: 16px;
  height: 2px;
  background: #d4a843;
  box-shadow: 0 0 6px rgba(212,168,67,0.5);
  border-radius: 1px;
}
.player-lotus {
  width: 50px;
  height: 12px;
  margin: -2px auto 0;
  background: radial-gradient(ellipse, rgba(212,168,67,0.3) 0%, transparent 70%);
  border-radius: 50%;
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
  gap: 8px;
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
  padding: 10px 4px 8px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.25s;
  border: 1px solid rgba(212,168,67,0.12);
  background: rgba(18,18,26,0.7);
}
.menu-card:hover {
  transform: translateY(-2px);
  border-color: rgba(212,168,67,0.4);
}
.menu-card:active {
  transform: scale(0.94);
}

.menu-purple { background: linear-gradient(135deg, rgba(42,31,78,0.6), rgba(18,18,26,0.7)); }
.menu-gold { background: linear-gradient(135deg, rgba(61,43,31,0.6), rgba(18,18,26,0.7)); }
.menu-green { background: linear-gradient(135deg, rgba(31,61,43,0.6), rgba(18,18,26,0.7)); }
.menu-red { background: linear-gradient(135deg, rgba(61,31,31,0.6), rgba(18,18,26,0.7)); }
.menu-blue { background: linear-gradient(135deg, rgba(31,43,61,0.6), rgba(18,18,26,0.7)); }

.menu-purple:hover { box-shadow: 0 0 15px rgba(124,92,191,0.2); }
.menu-gold:hover { box-shadow: 0 0 15px rgba(212,168,67,0.2); }
.menu-green:hover { box-shadow: 0 0 15px rgba(76,175,80,0.2); }
.menu-red:hover { box-shadow: 0 0 15px rgba(229,57,53,0.2); }
.menu-blue:hover { box-shadow: 0 0 15px rgba(66,165,245,0.2); }

.m-icon {
  font-size: 24px;
  margin-bottom: 3px;
  filter: drop-shadow(0 0 4px rgba(212,168,67,0.25));
}
.m-name {
  font-size: 11px;
  color: #e8e0d0;
  font-weight: bold;
  letter-spacing: 0.03em;
  white-space: nowrap;
}

/* 响应式 */
@media (max-width: 480px) {
  .menu-grid { gap: 6px; padding: 12px 8px; }
  .menu-card { padding: 8px 2px 6px; }
  .m-icon { font-size: 20px; }
  .m-name { font-size: 10px; }
  .player-area { padding-top: 60px; }
}

/* === 白色主题 === */
[data-theme="light"] .main-city {
  border-color: rgba(139,105,20,0.2);
  box-shadow: 0 4px 30px rgba(0,0,0,0.1), 0 0 20px rgba(139,105,20,0.05);
}

[data-theme="light"] .city-bg {
  background: linear-gradient(180deg, #e8f4fd 0%, #d4ecf9 20%, #c5e3f0 40%, #b8dce8 55%, #d4e8d0 70%, #f0ead8 100%);
}

[data-theme="light"] .star { background: rgba(255,255,255,0.8); }

[data-theme="light"] .moon {
  background: radial-gradient(circle at 35% 35%, #fff8b0 0%, #ffd700 40%, rgba(255,200,0,0.3) 70%, transparent 100%);
  box-shadow: 0 0 40px rgba(255,200,0,0.4), 0 0 80px rgba(255,200,0,0.2);
}

[data-theme="light"] .mountain-far {
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 300'%3E%3Cpath d='M0,300 L0,180 Q100,80 200,160 Q280,60 400,140 Q500,40 600,120 Q700,30 800,130 Q900,50 1000,150 Q1100,70 1200,160 L1200,300Z' fill='%23a8c8a0' opacity='0.4'/%3E%3C/svg%3E") bottom/cover no-repeat;
}
[data-theme="light"] .mountain-mid {
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 250'%3E%3Cpath d='M0,250 L0,150 Q150,50 300,130 Q400,30 550,110 Q650,20 800,100 Q950,40 1050,120 Q1150,60 1200,140 L1200,250Z' fill='%2390b888' opacity='0.5'/%3E%3C/svg%3E") bottom/cover no-repeat;
}
[data-theme="light"] .mountain-near {
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1200 200'%3E%3Cpath d='M0,200 L0,120 Q100,60 250,100 Q350,40 500,90 Q600,30 750,80 Q900,50 1000,100 Q1100,60 1200,110 L1200,200Z' fill='%2378a870' opacity='0.6'/%3E%3C/svg%3E") bottom/cover no-repeat;
}

[data-theme="light"] .cloud {
  background: radial-gradient(ellipse, rgba(255,255,255,0.6) 0%, transparent 70%);
}

[data-theme="light"] .sp {
  background: radial-gradient(circle, rgba(139,105,20,0.5), transparent);
}

[data-theme="light"] .announcement-bar {
  background: rgba(139,105,20,0.06);
  border-color: rgba(139,105,20,0.15);
}
[data-theme="light"] .ann-item { color: #8b6914; }

[data-theme="light"] .evt-double_cultivation {
  background: linear-gradient(135deg, rgba(106,79,176,0.15), rgba(106,79,176,0.05));
  border-color: rgba(106,79,176,0.3);
  color: #6a4fb0;
}
[data-theme="light"] .evt-gacha_rate_up {
  background: linear-gradient(135deg, rgba(56,142,60,0.15), rgba(56,142,60,0.05));
  border-color: rgba(56,142,60,0.3);
  color: #388e3c;
}

[data-theme="light"] .aura {
  border-color: rgba(139,105,20,0.15);
  background: radial-gradient(circle, rgba(139,105,20,0.08) 0%, transparent 70%);
}
[data-theme="light"] .aura2 {
  border-color: rgba(106,79,176,0.1);
  background: radial-gradient(circle, rgba(106,79,176,0.05) 0%, transparent 70%);
}

[data-theme="light"] .player-head {
  background: linear-gradient(135deg, #f5e6c8, #e8d5a8);
  box-shadow: 0 0 10px rgba(139,105,20,0.2);
}
[data-theme="light"] .player-body {
  border-bottom-color: #4a6fa5;
  filter: drop-shadow(0 0 8px rgba(74,111,165,0.3));
}
[data-theme="light"] .p-name {
  color: #8b6914;
  text-shadow: 0 0 10px rgba(139,105,20,0.2);
}
[data-theme="light"] .p-realm {
  color: #7a6b52;
  background: rgba(139,105,20,0.08);
  border-color: rgba(139,105,20,0.15);
}

[data-theme="light"] .menu-grid {
  background: rgba(255,255,255,0.6);
  border-top-color: rgba(139,105,20,0.1);
}
[data-theme="light"] .menu-card {
  border-color: rgba(139,105,20,0.1);
  background: rgba(255,255,255,0.8);
}
[data-theme="light"] .menu-card:hover {
  border-color: rgba(139,105,20,0.35);
}
[data-theme="light"] .menu-purple { background: linear-gradient(135deg, rgba(106,79,176,0.1), rgba(255,255,255,0.8)); }
[data-theme="light"] .menu-gold { background: linear-gradient(135deg, rgba(139,105,20,0.1), rgba(255,255,255,0.8)); }
[data-theme="light"] .menu-green { background: linear-gradient(135deg, rgba(56,142,60,0.1), rgba(255,255,255,0.8)); }
[data-theme="light"] .menu-red { background: linear-gradient(135deg, rgba(198,40,40,0.1), rgba(255,255,255,0.8)); }
[data-theme="light"] .menu-blue { background: linear-gradient(135deg, rgba(30,90,170,0.1), rgba(255,255,255,0.8)); }

[data-theme="light"] .m-name { color: #2c2416; }
[data-theme="light"] .m-icon { filter: none; }
</style>
