import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import lazyImg from './directives/lazyImg.js'
import router from './router'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
window.__pinia = pinia
app.use(router)
app.directive("lazy-img", lazyImg)
// 全局错误处理
app.config.errorHandler = (err, vm, info) => {
  if (err.message?.includes('登录已过期')) return
  console.error('[Vue Error]', info, err)
}
app.config.warnHandler = (msg) => {
  if (msg.includes('Failed to resolve')) console.warn('[Vue Warn]', msg)
}
// 全局 Promise 错误捕获
window.addEventListener('unhandledrejection', (e) => {
  if (e.reason?.message?.includes('登录已过期')) { e.preventDefault(); return }
  console.error('[Unhandled Promise]', e.reason)
})

app.mount('#app')


// 注册 Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js').catch(() => {})
  })
}
