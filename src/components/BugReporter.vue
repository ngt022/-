<template>
  <div class="bug-reporter">
    <!-- 浮动按钮 -->
    <div class="bug-fab" @click="showModal=true" title="反馈Bug">🐛</div>

    <!-- 自动错误通知 -->
    <Transition name="slide">
      <div v-if="autoError" class="bug-toast">
        <div class="bug-toast-text">⚠️ 检测到异常</div>
        <div class="bug-toast-msg">{{ autoError.message?.substring(0,60) }}</div>
        <div class="bug-toast-actions">
          <button class="bug-btn-report" @click="submitAuto">上报</button>
          <button class="bug-btn-ignore" @click="dismissAuto">忽略</button>
        </div>
      </div>
    </Transition>

    <!-- 手动反馈 Modal -->
    <n-modal v-model:show="showModal" preset="card" title="🐛 Bug 反馈" 
      style="width:90%;max-width:420px" :bordered="false" size="small">
      <n-space vertical>
        <n-input v-model:value="desc" type="textarea" placeholder="请描述你遇到的问题..."
          :rows="3" maxlength="500" show-count />
        <n-space>
          <n-button @click="takeScreenshot" :loading="capturing" size="small">
            📸 截图
          </n-button>
          <span v-if="screenshotData" style="color:#4caf50;font-size:12px">✅ 已截图</span>
        </n-space>
        <img v-if="screenshotData" :src="screenshotData" 
          style="max-height:120px;border-radius:4px;border:1px solid #333" />
        <n-button type="primary" @click="submitManual" :loading="submitting"
          :disabled="!desc.trim()">提交反馈</n-button>
      </n-space>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { NModal, NInput, NButton, NSpace, useMessage } from 'naive-ui'
import { usePlayerStore } from '@/stores/player'
import { useAuthStore } from '@/stores/auth'

const playerStore = usePlayerStore()
const authStore = useAuthStore()
const message = useMessage()

const showModal = ref(false)
const desc = ref('')
const screenshotData = ref(null)
const capturing = ref(false)
const submitting = ref(false)
const autoError = ref(null)

const recentErrors = new Map()
const DEDUP_MS = 300000 // 5分钟去重

function getPlayerInfo() {
  const token = localStorage.getItem('xx_token')
  return {
    wallet: authStore.wallet || null,
    name: playerStore.name || null,
    level: playerStore.level || null,
    token
  }
}

async function sendReport(data) {
  const info = getPlayerInfo()
  const headers = { 'Content-Type': 'application/json' }
  if (info.token) headers['Authorization'] = 'Bearer ' + info.token
  try {
    const r = await fetch('/api/bug-report', {
      method: 'POST', headers,
      body: JSON.stringify({
        ...data,
        browserInfo: navigator.userAgent,
        pageUrl: location.href,
        extraData: { playerLevel: info.level, playerName: info.name }
      })
    })
    return await r.json()
  } catch { return { success: false } }
}

function handleError(event) {
  const msg = event.message || event.error?.message || String(event)
  const source = event.filename || ''
  const line = event.lineno || 0
  const col = event.colno || 0
  const err = event.error
  const key = msg + source
  const now = Date.now()
  if (recentErrors.has(key) && now - recentErrors.get(key) < DEDUP_MS) return
  recentErrors.set(key, now)
  autoError.value = {
    message: msg,
    stack: err?.stack || `${source}:${line}:${col}`,
  }
}

function handleRejection(e) {
  const msg = e.reason?.message || String(e.reason)
  const key = 'unhandled:' + msg
  const now = Date.now()
  if (recentErrors.has(key) && now - recentErrors.get(key) < DEDUP_MS) return
  recentErrors.set(key, now)
  autoError.value = {
    message: msg,
    stack: e.reason?.stack || '',
  }
}

async function submitAuto() {
  if (!autoError.value) return
  await sendReport({
    type: 'auto',
    errorMessage: autoError.value.message,
    errorStack: autoError.value.stack,
  })
  message.success('已上报，感谢！')
  autoError.value = null
}

function dismissAuto() {
  autoError.value = null
}

async function takeScreenshot() {
  capturing.value = true
  try {
    const html2canvas = (await import('html2canvas')).default
    const canvas = await html2canvas(document.body, {
      scale: 0.5, useCORS: true, logging: false,
      ignoreElements: el => el.classList?.contains('bug-reporter')
    })
    screenshotData.value = canvas.toDataURL('image/jpeg', 0.6)
  } catch { message.error('截图失败') }
  capturing.value = false
}

async function submitManual() {
  if (!desc.value.trim()) return
  submitting.value = true
  const res = await sendReport({
    type: 'manual',
    description: desc.value.trim(),
    screenshot: screenshotData.value || '',
  })
  submitting.value = false
  if (res.success) {
    message.success('感谢反馈！')
    desc.value = ''
    screenshotData.value = null
    showModal.value = false
  } else {
    message.error('提交失败，请重试')
  }
}

onMounted(() => {
  window.addEventListener('error', handleError)
  window.addEventListener('unhandledrejection', handleRejection)
})
onUnmounted(() => {
  window.removeEventListener('error', handleError)
  window.removeEventListener('unhandledrejection', handleRejection)
})
</script>

<style scoped>
.bug-fab {
  position: fixed;
  bottom: 80px;
  right: 16px;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(30,30,30,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  cursor: pointer;
  z-index: 9999;
  transition: all 0.2s;
  border: 1px solid rgba(255,255,255,0.1);
}
.bug-fab:hover {
  background: rgba(60,60,60,0.9);
  transform: scale(1.1);
}
.bug-toast {
  position: fixed;
  bottom: 130px;
  right: 16px;
  background: rgba(30,30,30,0.95);
  border: 1px solid #ff9800;
  border-radius: 8px;
  padding: 10px 14px;
  z-index: 9999;
  max-width: 280px;
  backdrop-filter: blur(8px);
}
.bug-toast-text {
  font-size: 13px;
  font-weight: bold;
  color: #ff9800;
  margin-bottom: 4px;
}
.bug-toast-msg {
  font-size: 11px;
  color: #aaa;
  margin-bottom: 8px;
  word-break: break-all;
}
.bug-toast-actions {
  display: flex;
  gap: 8px;
}
.bug-btn-report {
  background: #ff9800;
  color: #000;
  border: none;
  border-radius: 4px;
  padding: 4px 12px;
  font-size: 12px;
  cursor: pointer;
}
.bug-btn-ignore {
  background: transparent;
  color: #888;
  border: 1px solid #555;
  border-radius: 4px;
  padding: 4px 12px;
  font-size: 12px;
  cursor: pointer;
}
.slide-enter-active, .slide-leave-active {
  transition: all 0.3s ease;
}
.slide-enter-from, .slide-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>
