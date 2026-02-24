import { createRouter, createWebHashHistory } from "vue-router"

// App化改造：所有页面由 App.vue 的 currentPage 控制
// router 只保留一个 catch-all 路由，不做页面切换
const routes = [
  { path: "/:pathMatch(.*)*", name: "App", component: () => import("../views/Home.vue") },
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

// 拦截所有导航，始终停在 /
router.beforeEach((to, from, next) => {
  if (to.path !== '/') {
    next('/')
  } else {
    next()
  }
})

export default router
