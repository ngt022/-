<template>
  <div class="world-chat-wrapper" :class="{ minimized: isMinimized }" :style="posStyle">
    <!-- 最小化状态 -->
    <div v-if="isMinimized" class="chat-toggle" @mousedown="startDragToggle" @touchstart.passive="startDragToggle">
      <span class="toggle-icon">💬</span>
      <span v-if="unreadCount > 0" class="unread-badge">{{ unreadCount > 99 ? '99+' : unreadCount }}</span>
      <span class="online-dot"></span>
      <span class="online-num">{{ onlineCount }}</span>
    </div>

    <!-- 展开状态 -->
    <div v-else class="chat-panel">
      <div class="chat-header" @mousedown="startDrag" @touchstart.passive="startDrag" style="cursor:move;user-select:none">
        <span class="header-title">🌍 焰域频道</span>
        <span class="header-online">在线 {{ onlineCount }}</span>
        <span class="header-close" @click="isMinimized = true">✕</span>
      </div>

      <!-- Tab 切换 -->
      <div class="chat-tabs">
        <span class="tab" :class="{ active: activeTab === 'chat' }" @click="activeTab = 'chat'">聊天</span>
        <span class="tab" :class="{ active: activeTab === 'events' }" @click="activeTab = 'events'">焰域动态</span>
      </div>

      <!-- 聊天消息 -->
      <div v-show="activeTab === 'chat'" class="chat-messages" ref="chatBox">
        <div v-for="(msg, i) in messages" :key="i" class="chat-msg">
          <span class="msg-name">{{ msg.name }}</span>
          <span class="msg-text">{{ msg.text }}</span>
        </div>
        <div v-if="messages.length === 0" class="empty-hint">暂无消息，说点什么吧~</div>
      </div>

      <!-- 全服动态 -->
      <div v-show="activeTab === 'events'" class="chat-messages" ref="eventBox">
        <div v-for="(evt, i) in events" :key="i" class="event-msg" :class="'event-' + evt.eventType">
          {{ evt.text }}
        </div>
        <div v-if="events.length === 0" class="empty-hint">暂无动态</div>
      </div>

      <!-- 输入框 -->
      <div v-show="activeTab === 'chat'" class="chat-input">
        <input
          v-model="inputText"
          @keydown.enter="sendMessage"
          placeholder="说点什么..."
          maxlength="200"
          :disabled="!isConnected"
        />
        <button @click="sendMessage" :disabled="!isConnected || !inputText.trim()">发送</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useAuthStore } from '../stores/auth'
import { usePlayerStore } from '../stores/player'

const authStore = useAuthStore()
const playerStore = usePlayerStore()

const isMinimized = ref(true)
const activeTab = ref('chat')
const messages = ref([])
const events = ref([])
const inputText = ref('')
const onlineCount = ref(0)
const unreadCount = ref(0)
const isConnected = ref(false)
const chatBox = ref(null)
const eventBox = ref(null)

let ws = null
let reconnectTimer = null

const getWsUrl = () => {
  const proto = location.protocol === 'https:' ? 'wss:' : 'ws:'
  return `${proto}//${location.host}/ws`
}

const connect = () => {
  if (ws && ws.readyState <= 1) return
  try {
    ws = new WebSocket(getWsUrl())
    
    // 连接超时处理
    const connectionTimeout = setTimeout(() => {
      if (ws && ws.readyState !== 1) {
        ws.close()
      }
    }, 5000)

    ws.onopen = () => {
      clearTimeout(connectionTimeout)
      isConnected.value = true
      // 暴露到全局供其他组件使用
      window.__gameWs = ws
      // 心跳保活
      if (ws._heartbeat) clearInterval(ws._heartbeat)
      ws._heartbeat = setInterval(() => {
        if (ws.readyState === 1) ws.send(JSON.stringify({ type: 'ping' }))
      }, 30000)
      // 如果已登录，发送认证
      if (authStore.isLoggedIn) {
        ws.send(JSON.stringify({
          type: 'auth',
          token: authStore.token,
          name: playerStore.name || '无名焰修'
        }))
      }
    }

    ws.onmessage = (e) => {
      try {
        const data = JSON.parse(e.data)

        if (data.type === 'init') {
          messages.value = data.messages || []
          events.value = data.events || []
          onlineCount.value = data.online || 0
          scrollToBottom()
          return
        }

        if (data.type === 'chat') {
          messages.value.push(data)
          if (messages.value.length > 100) messages.value.shift()
          if (isMinimized.value) unreadCount.value++
          scrollToBottom()
        }

        if (data.type === 'event') {
          events.value.push(data)
          if (events.value.length > 50) events.value.shift()
          scrollToBottom()
        }

        if (data.type === 'online') {
          onlineCount.value = data.count
        }

        // Dispatch private chat events for Friends.vue
        if (data.type === 'private_chat') {
          window.dispatchEvent(new CustomEvent('private_chat', { detail: data }))
        }

        // Dispatch friend online/offline events
        if (data.type === 'friend_online') {
          window.dispatchEvent(new CustomEvent('friend_online', { detail: data }))
        }
        if (data.type === 'friend_offline') {
          window.dispatchEvent(new CustomEvent('friend_offline', { detail: data }))
        }
      } catch {}
    }

    ws.onclose = () => {
      isConnected.value = false
      if (ws._heartbeat) { clearInterval(ws._heartbeat); ws._heartbeat = null }
      reconnectTimer = setTimeout(connect, 5000)
    }

    ws.onerror = (e) => {
      // 静默处理错误，不输出到控制台
      clearTimeout(connectionTimeout)
      ws.close()
    }
  } catch (e) {
    // 静默处理异常
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (chatBox.value) chatBox.value.scrollTop = chatBox.value.scrollHeight
    if (eventBox.value) eventBox.value.scrollTop = eventBox.value.scrollHeight
  })
}

const sendMessage = () => {
  const text = inputText.value.trim()
  if (!text || !ws || ws.readyState !== 1) return
  if (!authStore.isLoggedIn) return
  ws.send(JSON.stringify({ type: 'chat', text }))
  inputText.value = ''
}

watch(isMinimized, (val) => {
  if (!val) {
    unreadCount.value = 0
    scrollToBottom()
  }
})

// 登录状态变化时重新认证
watch(() => authStore.isLoggedIn, (loggedIn) => {
  if (loggedIn && ws && ws.readyState === 1) {
    ws.send(JSON.stringify({
      type: 'auth',
      token: authStore.token,
      name: playerStore.name || '无名焰修'
    }))
  }
})


// === 拖拽逻辑 ===
const posX = ref(null)
const posY = ref(null)
const posStyle = computed(() => {
  if (posX.value === null) return {}
  return { left: posX.value + 'px', bottom: posY.value + 'px' }
})

let dragging = false
let dragStartX = 0, dragStartY = 0
let startPosX = 0, startPosY = 0
let dragMoved = false

function getPos() {
  const el = document.querySelector('.world-chat-wrapper')
  if (!el) return { x: 16, y: 72 }
  const rect = el.getBoundingClientRect()
  return { x: rect.left, y: window.innerHeight - rect.bottom }
}

function startDrag(e) {
  const ev = e.touches ? e.touches[0] : e
  dragging = true
  dragMoved = false
  const pos = getPos()
  startPosX = posX.value ?? pos.x
  startPosY = posY.value ?? pos.y
  dragStartX = ev.clientX
  dragStartY = ev.clientY
  document.addEventListener('mousemove', onDrag)
  document.addEventListener('mouseup', stopDrag)
  document.addEventListener('touchmove', onDrag, { passive: false })
  document.addEventListener('touchend', stopDrag)
}

function startDragToggle(e) {
  startDrag(e)
  // 如果没拖动就当点击
}

function onDrag(e) {
  if (!dragging) return
  const ev = e.touches ? e.touches[0] : e
  const dx = ev.clientX - dragStartX
  const dy = ev.clientY - dragStartY
  if (Math.abs(dx) > 3 || Math.abs(dy) > 3) dragMoved = true
  posX.value = Math.max(0, Math.min(window.innerWidth - 60, startPosX + dx))
  posY.value = Math.max(0, Math.min(window.innerHeight - 60, startPosY - dy))
  if (e.cancelable) e.preventDefault()
}

function stopDrag() {
  dragging = false
  document.removeEventListener('mousemove', onDrag)
  document.removeEventListener('mouseup', stopDrag)
  document.removeEventListener('touchmove', onDrag)
  document.removeEventListener('touchend', stopDrag)
  // toggle 点击：没拖动就展开
  if (!dragMoved && isMinimized.value) {
    isMinimized.value = false
  }
}

onMounted(() => { connect() })
onUnmounted(() => {
  if (ws) ws.close()
  if (reconnectTimer) clearTimeout(reconnectTimer)
})
</script>

<style scoped>
.world-chat-wrapper {
  position: fixed;
  bottom: 72px;
  left: 16px;
  z-index: 9999;
  transition: none;
}

.chat-toggle {
  display: flex;
  align-items: center;
  gap: 6px;
  background: linear-gradient(135deg, #1a1a2e, #12121a);
  border: 1px solid rgba(212,168,67,0.4);
  border-radius: 24px;
  padding: 8px 16px;
  cursor: pointer;
  box-shadow: 0 0 15px rgba(212,168,67,0.15);
  transition: all 0.3s;
}
.chat-toggle:hover {
  border-color: rgba(212,168,67,0.7);
  box-shadow: 0 0 25px rgba(212,168,67,0.25);
}
.toggle-icon { font-size: 1.2rem; }
.unread-badge {
  background: #e74c3c;
  color: #fff;
  font-size: 0.7rem;
  padding: 1px 6px;
  border-radius: 10px;
  font-weight: bold;
}
.online-dot {
  width: 6px; height: 6px;
  background: #4caf50;
  border-radius: 50%;
}
.online-num {
  color: #a09880;
  font-size: 0.8rem;
}

.chat-panel {
  width: 320px;
  height: 420px;
  background: linear-gradient(180deg, #12121a 0%, #0a0a0f 100%);
  border: 1px solid rgba(212,168,67,0.3);
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  box-shadow: 0 8px 32px rgba(0,0,0,0.6), 0 0 20px rgba(212,168,67,0.08);
  overflow: hidden;
}

.chat-header {
  display: flex;
  align-items: center;
  padding: 10px 14px;
  background: linear-gradient(90deg, rgba(212,168,67,0.1), transparent);
  border-bottom: 1px solid rgba(212,168,67,0.2);
}
.header-title {
  color: #d4a843;
  font-weight: bold;
  font-size: 0.9rem;
  flex: 1;
}
.header-online {
  color: #a09880;
  font-size: 0.75rem;
  margin-right: 12px;
}
.header-close {
  color: #a09880;
  cursor: pointer;
  font-size: 1rem;
  padding: 0 4px;
}
.header-close:hover { color: #e74c3c; }

.chat-tabs {
  display: flex;
  border-bottom: 1px solid rgba(212,168,67,0.15);
}
.tab {
  flex: 1;
  text-align: center;
  padding: 8px 0;
  font-size: 0.8rem;
  color: #a09880;
  cursor: pointer;
  transition: all 0.3s;
  border-bottom: 2px solid transparent;
}
.tab.active {
  color: #d4a843;
  border-bottom-color: #d4a843;
}
.tab:hover { color: #f0d68a; }

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 8px 12px;
  scroll-behavior: smooth;
}
.chat-messages::-webkit-scrollbar { width: 4px; }
.chat-messages::-webkit-scrollbar-thumb { background: rgba(212,168,67,0.2); border-radius: 2px; }

.chat-msg {
  margin-bottom: 6px;
  font-size: 0.82rem;
  line-height: 1.4;
  word-break: break-all;
}
.msg-name {
  color: #d4a843;
  font-weight: bold;
  margin-right: 6px;
}
.msg-name::after { content: '：'; }
.msg-text { color: #e8e0d0; }

.event-msg {
  margin-bottom: 6px;
  font-size: 0.8rem;
  padding: 4px 8px;
  border-radius: 4px;
  background: rgba(212,168,67,0.06);
  color: #a09880;
  border-left: 2px solid rgba(212,168,67,0.3);
}
.event-breakthrough { color: #f0d68a; border-left-color: #f0d68a; background: rgba(240,214,138,0.08); }
.event-vip { color: #e6a8ff; border-left-color: #e6a8ff; background: rgba(230,168,255,0.08); }
.event-recharge { color: #7de2d6; border-left-color: #7de2d6; background: rgba(125,226,214,0.08); }
.event-join { color: #666; border-left-color: #444; background: transparent; font-size: 0.75rem; }

.empty-hint {
  text-align: center;
  color: #555;
  font-size: 0.8rem;
  margin-top: 40px;
}

.chat-input {
  display: flex;
  padding: 8px;
  border-top: 1px solid rgba(212,168,67,0.15);
  gap: 6px;
}
.chat-input input {
  flex: 1;
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(212,168,67,0.2);
  border-radius: 6px;
  padding: 6px 10px;
  color: #e8e0d0;
  font-size: 0.82rem;
  outline: none;
}
.chat-input input:focus {
  border-color: rgba(212,168,67,0.5);
  box-shadow: 0 0 6px rgba(212,168,67,0.15);
}
.chat-input input::placeholder { color: #555; }
.chat-input button {
  background: linear-gradient(135deg, #b8860b, #d4a843);
  border: none;
  color: #1a1000;
  font-weight: bold;
  padding: 6px 14px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  transition: all 0.3s;
}
.chat-input button:hover { box-shadow: 0 0 10px rgba(212,168,67,0.3); }
.chat-input button:disabled { opacity: 0.4; cursor: not-allowed; }

@media (max-width: 480px) {
  .chat-panel { width: calc(100vw - 32px); height: 360px; }
}
</style>
