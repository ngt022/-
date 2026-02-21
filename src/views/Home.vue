<template>
  <div class="home-wrapper">
    <!-- 浮动光点 -->
    <div class="particles">
      <span v-for="i in 12" :key="i" class="particle" :style="particleStyle(i)"></span>
    </div>

    <div class="home-content">

      <!-- 1. 角色信息卡 -->
      <div class="char-card">
        <div class="char-card-inner">
          <div class="char-avatar-wrap">
            <img :src="charImage" class="char-avatar" alt="角色" />
            <span class="vip-badge">VIP{{ authStore.vipLevel }}</span>
          </div>
          <div class="char-info">
            <div class="char-name">{{ playerStore.name }}</div>
            <div class="char-realm">{{ playerStore.realm }}</div>
            <div class="char-stats">
              <span>等级 <b>{{ playerStore.level }}</b></span>
              <span class="stat-sep">|</span>
              <span>战力 <b class="combat-power">{{ (playerStore.getCombatPower() || 0).toLocaleString() }}</b></span>
            </div>
            <div class="char-wallet" v-if="authStore.shortWallet">{{ authStore.shortWallet }}</div>
          </div>
        </div>
      </div>

      <!-- 2. 资源栏 -->
      <div class="resource-bar">
        <div class="res-item" v-for="r in resources" :key="r.label">
          <span class="res-icon">{{ r.icon }}</span>
          <span class="res-val">{{ (r.value || 0).toLocaleString() }}</span>
          <span class="res-label">{{ r.label }}</span>
        </div>
      </div>

      <!-- 3. 账号概况 -->
      <div class="section-card overview-card">
        <div class="section-title">📊 账号概况</div>
        <div class="overview-grid">
          <div class="ov-item">
            <span class="ov-label">修炼进度</span>
            <div class="ov-progress">
              <div class="ov-progress-fill" :style="{ width: cultivationPercent + '%' }"></div>
            </div>
            <span class="ov-val">{{ playerStore.cultivation || 0 }}/{{ playerStore.maxCultivation || 100 }}</span>
          </div>
          <div class="ov-item">
            <span class="ov-label">飞升次数</span>
            <span class="ov-val ov-big">{{ serverInfo.ascensionCount }}</span>
          </div>
          <div class="ov-item">
            <span class="ov-label">总修炼时长</span>
            <span class="ov-val ov-big">{{ formatTime(playerStore.totalCultivationTime || 0) }}</span>
          </div>
          <div class="ov-item">
            <span class="ov-label">成就完成</span>
            <span class="ov-val ov-big">{{ achievementCount }}</span>
          </div>
        </div>
        <div class="ov-row-group">
          <div class="ov-row">
            <span class="ov-row-label">🏅 VIP等级</span>
            <span class="ov-row-val" :class="'vip-lv-' + authStore.vipLevel">VIP{{ authStore.vipLevel }}</span>
          </div>
          <div class="ov-row">
            <span class="ov-row-label">🏛️ 焰盟</span>
            <span class="ov-row-val">{{ serverInfo.sectName || '未加入' }}</span>
          </div>
          <div class="ov-row">
            <span class="ov-row-label">🐾 出战焰兽</span>
            <span v-if="playerStore.activePet" class="ov-row-val" :style="{ color: petColor(playerStore.activePet.rarity) }">
              {{ playerStore.activePet.name }} · {{ petRarityName(playerStore.activePet.rarity) }} Lv.{{ playerStore.activePet.level || 1 }}
            </span>
            <span v-else class="ov-row-val ov-dim">无</span>
          </div>
          <div class="ov-row">
            <span class="ov-row-label">🏇 坐骑</span>
            <span class="ov-row-val">{{ serverInfo.mountName || '无' }}</span>
          </div>
          <div class="ov-row">
            <span class="ov-row-label">🎖️ 称号</span>
            <span class="ov-row-val">{{ serverInfo.titleName || '无' }}</span>
          </div>
          <div class="ov-row">
            <span class="ov-row-label">📅 签到天数</span>
            <span class="ov-row-val">{{ serverInfo.signDays }}天</span>
          </div>
          <div class="ov-row">
            <span class="ov-row-label">💰 月卡</span>
            <span class="ov-row-val" :class="serverInfo.monthlyCard ? 'ov-active' : 'ov-dim'">
              {{ serverInfo.monthlyCard ? '已开通' : '未开通' }}
            </span>
          </div>
        </div>
      </div>

      <!-- 4. 装备概览 -->
      <div class="section-card equip-card">
        <div class="section-title">⚔️ 装备概览</div>
        <div class="equip-grid">
          <div v-for="s in equipSlots" :key="s.key" class="equip-slot">
            <span class="equip-slot-label">{{ s.label }}</span>
            <span v-if="playerStore.equippedArtifacts[s.key]"
              class="equip-slot-name"
              :style="{ color: qualityColor(playerStore.equippedArtifacts[s.key].quality) }">
              {{ playerStore.equippedArtifacts[s.key].name }}
            </span>
            <span v-else class="equip-slot-empty">空</span>
          </div>
        </div>
      </div>

      <!-- 5. 快捷入口 -->
      <div class="section-card shortcut-card">
        <div class="section-title">🚀 快捷入口</div>
        <div class="shortcut-grid">
          <div v-for="sc in shortcuts" :key="sc.path" class="shortcut-btn" @click="router.push(sc.path)">
            <span class="sc-icon">{{ sc.icon }}</span>
            <span class="sc-text">{{ sc.label }}</span>
          </div>
        </div>
      </div>

      <!-- 6. 公告区域 -->
      <div class="section-card announce-card">
        <div class="section-title">📢 公告</div>
        <div v-if="announcements.length" class="announce-list">
          <div v-for="a in announcements" :key="a.id" class="announce-item">
            <span class="announce-dot">·</span>
            <span class="announce-text">{{ a.title || a.content }}</span>
          </div>
        </div>
        <div v-else class="announce-text">欢迎来到火之文明！焰途漫漫，愿你逆天改命。</div>
      </div>

      <!-- 新手礼包 -->
      <div v-if="playerStore.isNewPlayer" class="newbie-banner" @click="receiveNewPlayerGift">
        🎁 点击领取新手礼包
      </div>

      <div class="home-footer">
        <span class="version">v1.0.5</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import img from '@/utils/img.js'
import { computed, ref, onMounted } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useAuthStore } from '../stores/auth'
import { useMessage } from 'naive-ui'
import { useRouter } from 'vue-router'

const router = useRouter()
const playerStore = usePlayerStore()
const authStore = useAuthStore()
const message = useMessage()

// 公告
const announcements = ref([])
// 服务端数据
const serverInfo = ref({ vipLevel: 0, sectName: '', signDays: 0, monthlyCard: false, ascensionCount: 0, mountName: '', titleName: '' })

onMounted(async () => {
  // 加载公告
  try {
    const res = await fetch('/api/announcements')
    const data = await res.json()
    if (Array.isArray(data)) announcements.value = data.slice(0, 5)
    else if (data?.data) announcements.value = data.data.slice(0, 5)
  } catch {}
  // 加载 VIP 信息
  if (authStore.token) {
    const headers = { 'Authorization': 'Bearer ' + authStore.token }
    try {
      const [vipRes, sectRes, mcRes, ascRes, mountRes, titleRes] = await Promise.allSettled([
        fetch('/api/vip/info', { headers }),
        fetch('/api/sect/my', { headers }),
        fetch('/api/monthly-card/status', { headers }),
        fetch('/api/ascension/info', { headers }),
        fetch('/api/mount/active', { headers }),
        fetch('/api/title/my', { headers }),
      ])
      if (vipRes.status === 'fulfilled' && vipRes.value.ok) {
        const d = await vipRes.value.json()
        serverInfo.value.vipLevel = d.vipLevel || 0
        serverInfo.value.signDays = d.signDays || 0
      }
      if (sectRes.status === 'fulfilled' && sectRes.value.ok) {
        const d = await sectRes.value.json()
        serverInfo.value.sectName = d.sect?.name || ''
      }
      if (mcRes.status === 'fulfilled' && mcRes.value.ok) {
        const d = await mcRes.value.json()
        serverInfo.value.monthlyCard = d.active || d.hasCard || false
      }
      if (ascRes.status === 'fulfilled' && ascRes.value.ok) {
        const d = await ascRes.value.json()
        serverInfo.value.ascensionCount = d.ascensionCount || 0
      }
      if (mountRes.status === 'fulfilled' && mountRes.value.ok) {
        const d = await mountRes.value.json()
        serverInfo.value.mountName = d.mount?.name || ''
        // 同步坐骑加成到 playerStore
        const m = d.mount
        playerStore.activeMountBonus = m
          ? { attack_bonus: m.attack_bonus || 0, defense_bonus: m.defense_bonus || 0, health_bonus: m.health_bonus || 0, speed_bonus: m.speed_bonus || 0 }
          : { attack_bonus: 0, defense_bonus: 0, health_bonus: 0, speed_bonus: 0 }
      }
      if (titleRes.status === 'fulfilled' && titleRes.value.ok) {
        const d = await titleRes.value.json()
        const titles = d.titles || d.data || []
        const active = Array.isArray(titles) ? titles.find(t => t.is_active) : null
        serverInfo.value.titleName = active?.name || ''
        // 同步称号加成到 playerStore
        playerStore.activeTitleBonus = active
          ? { attack_bonus: active.attack_bonus || 0, defense_bonus: active.defense_bonus || 0, health_bonus: active.health_bonus || 0, speed_bonus: active.speed_bonus || 0 }
          : { attack_bonus: 0, defense_bonus: 0, health_bonus: 0, speed_bonus: 0 }
      }
    } catch {}
  }
})

// 修炼进度百分比
const cultivationPercent = computed(() => {
  if (!playerStore.maxCultivation) return 0
  return Math.min(100, Math.round(playerStore.cultivation / playerStore.maxCultivation * 100))
})

// 成就数量
const achievementCount = computed(() => {
  const completed = playerStore.achievements?.filter(a => a.completed || a.unlocked)?.length || 0
  const total = playerStore.achievements?.length || 0
  return total > 0 ? `${completed}/${total}` : '0'
})

// 格式化时间
const formatTime = (seconds) => {
  if (seconds < 60) return `${seconds}秒`
  if (seconds < 3600) return `${Math.floor(seconds / 60)}分钟`
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  return m > 0 ? `${h}小时${m}分` : `${h}小时`
}

// 角色图片映射
const charImage = computed(() => {
  const lv = playerStore.level
  if (lv >= 13) return img('/assets/images/char-emperor.png')
  if (lv >= 10) return img('/assets/images/char-immortal.png')
  if (lv >= 7) return img('/assets/images/char-cultivator.png')
  if (lv >= 4) return img('/assets/images/char-warrior.png')
  return img('/assets/images/char-mortal.png')
})

// 资源列表
const resources = computed(() => [
  { icon: '💎', label: '焰晶', value: playerStore.spiritStones || 0 },
  { icon: '💠', label: '焰灵', value: Math.floor(playerStore.spirit || 0) },
  { icon: '🔨', label: '淬火石', value: playerStore.reinforceStones || 0 },
  { icon: '🔮', label: '符文石', value: playerStore.refinementStones || 0 },
  { icon: '🐾', label: '焰兽精华', value: playerStore.petEssence || 0 },
])

// 装备栏位
const equipSlots = [
  { key: 'weapon', label: '武器' }, { key: 'head', label: '头部' },
  { key: 'body', label: '衣服' }, { key: 'legs', label: '裤子' },
  { key: 'feet', label: '鞋子' }, { key: 'shoulder', label: '肩甲' },
  { key: 'hands', label: '手套' }, { key: 'wrist', label: '护腕' },
  { key: 'necklace', label: '项链' }, { key: 'ring1', label: '戒指1' },
  { key: 'ring2', label: '戒指2' }, { key: 'belt', label: '腰带' },
  { key: 'artifact', label: '焰器' },
]

// 快捷入口
const shortcuts = [
  { icon: '⚔️', label: '修炼', path: '/cultivation' },
  { icon: '🎒', label: '储藏室', path: '/inventory' },
  { icon: '🎰', label: '抽卡', path: '/gacha' },
  { icon: '🏔️', label: '焚天塔', path: '/dungeon' },
  { icon: '🧪', label: '炼丹', path: '/alchemy' },
  { icon: '🗺️', label: '探索', path: '/exploration' },
  { icon: '🏪', label: '商店', path: '/shop' },
  { icon: '👤', label: '个人', path: '/profile' },
]

// 品质颜色
const qualityColorMap = {
  common: '#9e9e9e', uncommon: '#4caf50', rare: '#2196f3',
  epic: '#9c27b0', legendary: '#ff9800', mythic: '#e91e63',
}
const qualityColor = (q) => qualityColorMap[q] || '#9e9e9e'

// 焰兽品质
const petRarityMap = {
  divine: { name: '神品', color: '#FF0000' },
  celestial: { name: '仙品', color: '#FFD700' },
  mystic: { name: '玄品', color: '#9932CC' },
  spiritual: { name: '灵品', color: '#1E90FF' },
  mortal: { name: '凡品', color: '#32CD32' },
}
const petColor = (r) => (petRarityMap[r] || petRarityMap.mortal).color
const petRarityName = (r) => (petRarityMap[r] || petRarityMap.mortal).name

const receiveNewPlayerGift = async () => {
  try {
    const res = await fetch('/api/gift/newplayer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + localStorage.getItem('xx_token')
      }
    })
    const data = await res.json()
    if (data.success) {
      playerStore.spiritStones = data.spiritStones
      playerStore.isNewPlayer = false
      message.success('获得20000焰晶，新手礼包领取成功！')
    } else { message.error(data.error || '领取失败') }
  } catch (e) { message.error('领取失败') }
}

const particleStyle = (i) => ({
  left: `${(i * 17 + 5) % 100}%`,
  animationDelay: `${(i * 0.7) % 5}s`,
  animationDuration: `${4 + (i % 4) * 2}s`,
  width: `${3 + (i % 3) * 2}px`,
  height: `${3 + (i % 3) * 2}px`,
  opacity: 0.3 + (i % 4) * 0.15,
})
</script>

<style scoped>
.home-wrapper {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  padding-bottom: 2rem;
  background:
    radial-gradient(ellipse at 50% 0%, rgba(212,168,67,0.08) 0%, transparent 60%),
    radial-gradient(ellipse at 20% 80%, rgba(120,80,200,0.05) 0%, transparent 50%),
    radial-gradient(ellipse at 80% 80%, rgba(212,168,67,0.04) 0%, transparent 50%);
}
.particles { position: absolute; inset: 0; pointer-events: none; }
.particle {
  position: absolute; bottom: -10px; border-radius: 50%;
  background: radial-gradient(circle, rgba(212,168,67,0.8), rgba(212,168,67,0));
  animation: float-up linear infinite;
}
@keyframes float-up {
  0% { transform: translateY(0) scale(1); opacity: 0; }
  10% { opacity: var(--particle-opacity, 0.5); }
  90% { opacity: var(--particle-opacity, 0.5); }
  100% { transform: translateY(-100vh) scale(0.3); opacity: 0; }
}
.home-content {
  position: relative; z-index: 1;
  max-width: 480px; margin: 0 auto; padding: 1rem 0.75rem;
}

/* 角色信息卡 */
.char-card {
  border-radius: 14px; padding: 2px;
  background: linear-gradient(135deg, #d4a843 0%, #8b6914 40%, #d4a843 70%, #f0d68a 100%);
  box-shadow: 0 0 24px rgba(212,168,67,0.25), 0 0 60px rgba(212,168,67,0.08);
  margin-bottom: 1rem;
}
.char-card-inner {
  display: flex; align-items: center; gap: 1rem;
  background: rgba(10,8,18,0.88); border-radius: 12px; padding: 1rem;
}
.char-avatar-wrap {
  position: relative; flex-shrink: 0;
}
.char-avatar {
  width: 72px; height: 72px; border-radius: 50%; object-fit: cover;
  border: 2px solid #d4a843;
  box-shadow: 0 0 16px rgba(212,168,67,0.35);
}
.vip-badge {
  position: absolute; bottom: -4px; left: 50%; transform: translateX(-50%);
  background: linear-gradient(135deg, #d4a843, #b8860b); color: #1a1000;
  font-size: 0.6rem; font-weight: 700; padding: 1px 8px; border-radius: 8px;
  white-space: nowrap;
}
.char-info { flex: 1; min-width: 0; }
.char-name {
  font-size: 1.25rem; font-weight: 700;
  background: linear-gradient(180deg, #f0d68a, #d4a843);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
}
.char-realm { color: #a09880; font-size: 0.85rem; margin-top: 2px; }
.char-stats { display: flex; align-items: center; gap: 6px; margin-top: 4px; font-size: 0.8rem; color: #8a8070; }
.char-stats b { color: #d4a843; }
.stat-sep { color: #3a3530; }
.combat-power { color: #ff9800 !important; }
.char-wallet { font-size: 0.7rem; color: #5a5550; margin-top: 4px; font-family: monospace; }

/* 资源栏 */
.resource-bar {
  display: flex; gap: 4px; margin-bottom: 1rem; overflow-x: auto;
  scrollbar-width: none; -ms-overflow-style: none;
}
.resource-bar::-webkit-scrollbar { display: none; }
.res-item {
  flex: 1; min-width: 0; display: flex; flex-direction: column; align-items: center;
  background: rgba(10,8,18,0.6); border: 1px solid rgba(212,168,67,0.15);
  border-radius: 10px; padding: 8px 4px; gap: 2px;
}
.res-icon { font-size: 1.1rem; }
.res-val { font-size: 0.85rem; font-weight: 700; color: #d4a843; }
.res-label { font-size: 0.6rem; color: #6a6560; white-space: nowrap; }

/* 通用卡片 */
.section-card {
  background: rgba(10,8,18,0.6); border: 1px solid rgba(212,168,67,0.18);
  border-radius: 12px; padding: 0.75rem 1rem; margin-bottom: 0.75rem;
}
.section-title {
  font-size: 0.85rem; font-weight: 600; color: #d4a843; margin-bottom: 0.5rem;
}

/* 焰兽 */
.pet-info { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.pet-name { font-weight: 700; font-size: 0.95rem; }
.pet-detail { font-size: 0.8rem; color: #8a8070; }
.pet-empty { color: #5a5550; font-size: 0.85rem; }

/* 装备概览 */
.equip-grid {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 6px;
}
.equip-slot {
  display: flex; flex-direction: column; align-items: center;
  background: rgba(20,18,30,0.5); border-radius: 8px; padding: 6px 4px;
  border: 1px solid rgba(212,168,67,0.08);
}
.equip-slot-label { font-size: 0.6rem; color: #6a6560; margin-bottom: 2px; }
.equip-slot-name { font-size: 0.7rem; font-weight: 600; text-align: center; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 100%; }
.equip-slot-empty { font-size: 0.7rem; color: #3a3530; }

/* 快捷入口 */
.shortcut-grid {
  display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px;
}
.shortcut-btn {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  background: rgba(20,18,30,0.5); border: 1px solid rgba(212,168,67,0.12);
  border-radius: 10px; padding: 10px 4px; cursor: pointer;
  transition: all 0.2s;
}
.shortcut-btn:active {
  background: rgba(212,168,67,0.12); border-color: rgba(212,168,67,0.4);
  transform: scale(0.95);
}
.sc-icon { font-size: 1.3rem; }
.sc-text { font-size: 0.75rem; color: #a09880; }

/* 公告 */
.announce-list { display: flex; flex-direction: column; gap: 6px; }
.announce-item { display: flex; align-items: flex-start; gap: 6px; }
.announce-dot { color: #d4a843; font-size: 1.2rem; line-height: 1.2; }
.announce-text { font-size: 0.82rem; color: #8a8070; line-height: 1.5; }

/* 账号概况 */
.overview-grid {
  display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; margin-bottom: 10px;
}
.ov-item {
  display: flex; flex-direction: column; align-items: center; gap: 4px;
  background: rgba(20,18,30,0.5); border-radius: 8px; padding: 8px 6px;
  border: 1px solid rgba(212,168,67,0.08);
}
.ov-label { font-size: 0.7rem; color: #6a6560; }
.ov-val { font-size: 0.75rem; color: #a09880; }
.ov-big { font-size: 1rem; font-weight: 700; color: #d4a843; }
.ov-progress {
  width: 100%; height: 4px; background: #2a2520; border-radius: 2px; overflow: hidden;
}
.ov-progress-fill {
  height: 100%; background: linear-gradient(90deg, #b8860b, #ffd700); border-radius: 2px;
  transition: width 0.3s;
}
.ov-row-group { display: flex; flex-direction: column; gap: 0; }
.ov-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 7px 0; border-bottom: 1px solid rgba(212,168,67,0.06);
}
.ov-row:last-child { border-bottom: none; }
.ov-row-label { font-size: 0.8rem; color: #8a8070; }
.ov-row-val { font-size: 0.8rem; font-weight: 600; color: #d4a843; }
.ov-dim { color: #5a5550 !important; font-weight: 400 !important; }
.ov-active { color: #4caf50 !important; }
.vip-lv-0 { color: #6a6560 !important; }
.vip-lv-1 { color: #cd7f32 !important; }
.vip-lv-2 { color: #c0c0c0 !important; }
.vip-lv-3 { color: #ffd700 !important; }
.vip-lv-4 { color: #ff6b6b !important; }
.vip-lv-5 { color: #e91e63 !important; }

/* 新手礼包 */
.newbie-banner {
  text-align: center; padding: 12px; margin-bottom: 0.75rem;
  background: linear-gradient(135deg, rgba(184,134,11,0.2), rgba(212,168,67,0.1));
  border: 1px solid rgba(212,168,67,0.4); border-radius: 12px;
  color: #f0d68a; font-weight: 700; font-size: 1rem; cursor: pointer;
  animation: gift-glow 2s ease-in-out infinite;
}
@keyframes gift-glow {
  0%, 100% { box-shadow: 0 0 12px rgba(212,168,67,0.2); }
  50% { box-shadow: 0 0 24px rgba(212,168,67,0.5); }
}

.home-footer { text-align: center; margin-top: 1.5rem; }
.version { color: rgba(160,152,128,0.3); font-size: 0.75rem; }
</style>
