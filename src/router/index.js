import { createRouter, createWebHashHistory } from "vue-router"
import { usePlayerStore } from "../stores/player"

// 路由懒加载
const Home = () => import("../views/Home.vue")
const Cultivation = () => import("../views/Cultivation.vue")
const Inventory = () => import("../views/Inventory.vue")
const Exploration = () => import("../views/Exploration.vue")
const Achievements = () => import("../views/Achievements.vue")
const Settings = () => import("../views/Settings.vue")
const GM = () => import("../views/GM.vue")
const Alchemy = () => import("../views/Alchemy.vue")
const Dungeon = () => import("../views/Dungeon.vue")
const Gacha = () => import("../views/Gacha.vue")
const Recharge = () => import("../views/Recharge.vue")
const Vip = () => import("../views/Vip.vue")
const Rank = () => import("../views/Rank.vue")
const Shop = () => import("../views/Shop.vue")
const Events = () => import("../views/Events.vue")
const PK = () => import("../views/PK.vue")
const Sect = () => import("../views/Sect.vue")
const AdminEvents = () => import("../views/AdminEvents.vue")
const Admin = () => import("../views/Admin.vue")
const WorldBoss = () => import("../views/WorldBoss.vue")
const Friends = () => import("../views/Friends.vue")
const SectWar = () => import("../views/SectWar.vue")
const Auction = () => import("../views/Auction.vue")
const DailyDungeon = () => import("../views/DailyDungeon.vue")
const MountTitle = () => import("../views/MountTitle.vue")
const Ascension = () => import("../views/Ascension.vue")
const Profile = () => import("../views/Profile.vue")

const routes = [
  { path: "/", name: "Home", component: Home },
  { path: "/cultivation", name: "Cultivation", component: Cultivation },
  { path: "/inventory", name: "Inventory", component: Inventory },
  { path: "/exploration", name: "Exploration", component: Exploration },
  { path: "/achievements", name: "Achievements", component: Achievements },
  { path: "/settings", name: "Settings", component: Settings },
  {
    path: "/gm", name: "gm", component: GM,
    beforeEnter: (to, from, next) => {
      const playerStore = usePlayerStore()
      if (!playerStore.isGMMode) { next("/cultivation") } else { next() }
    }
  },
  { path: "/alchemy", name: "alchemy", component: Alchemy },
  { path: "/dungeon", name: "Dungeon", component: Dungeon },
  { path: "/gacha", name: "Gacha", component: Gacha },
  { path: "/recharge", name: "Recharge", component: Recharge },
  { path: "/vip", name: "Vip", component: Vip },
  { path: "/rank", name: "Rank", component: Rank },
  { path: "/shop", name: "Shop", component: Shop },
  { path: "/events", name: "Events", component: Events },
  { path: "/pk", name: "PK", component: PK },
  { path: "/sect", name: "Sect", component: Sect },
  { path: "/admin/events", name: "AdminEvents", component: AdminEvents },
  { path: "/admin", name: "Admin", component: Admin },
  { path: "/boss", name: "WorldBoss", component: WorldBoss },
  { path: "/friends", name: "Friends", component: Friends },
  { path: "/sect-war", name: "SectWar", component: SectWar },
  { path: "/auction", name: "Auction", component: Auction },
  { path: "/daily-dungeon", name: "DailyDungeon", component: DailyDungeon },
  { path: "/mount-title", name: "MountTitle", component: MountTitle },
  { path: "/ascension", name: "Ascension", component: Ascension },
  { path: "/profile", name: "Profile", component: Profile },
  { path: "/:pathMatch(.*)*", name: "NotFound", redirect: "/" },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

// 切页面自动云存档
let lastSaveTime = 0
router.beforeEach(async (to, from, next) => {
  const now = Date.now()
  // 至少间隔10秒，避免频繁保存
  if (now - lastSaveTime > 10000) {
    try {
      const { useAuthStore } = await import('../stores/auth')
      const { usePlayerStore } = await import('../stores/player')
      const authStore = useAuthStore()
      const playerStore = usePlayerStore()
      if (authStore.isLoggedIn) {
        authStore.saveToCloud(playerStore).catch(() => {})
        lastSaveTime = now
      }
    } catch {}
  }
  next()
})

export default router
