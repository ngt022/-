import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
window.__pinia = pinia
app.use(router)
// 全局错误处理
app.config.errorHandler = (err, vm, info) => {
  if (err.message?.includes('登录已过期')) return
}

app.mount('#app')
