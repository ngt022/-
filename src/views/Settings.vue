<template>
  <div class="settings-container">
    <!-- 账号信息 -->
    <n-card title="📋 账号信息" size="small" style="margin-bottom: 12px">
      <n-descriptions :column="1" label-placement="left" bordered size="small">
        <n-descriptions-item label="钱包地址">
          <n-text code>{{ authStore.wallet || '未连接' }}</n-text>
        </n-descriptions-item>
        <n-descriptions-item label="焰名">{{ playerStore.name || '无名焰修' }}</n-descriptions-item>
        <n-descriptions-item label="境界">{{ playerStore.realm || '燃火期一层' }}</n-descriptions-item>
        <n-descriptions-item label="等级">Lv.{{ playerStore.level || 1 }}</n-descriptions-item>
        <n-descriptions-item label="VIP等级">
          <n-tag :type="playerStore.vipLevel > 0 ? 'warning' : 'default'" size="small">
            VIP{{ playerStore.vipLevel || 0 }}
          </n-tag>
        </n-descriptions-item>
        <n-descriptions-item label="注册时间">{{ registerTime }}</n-descriptions-item>
      </n-descriptions>
    </n-card>

    <!-- 游戏设置 -->
    <n-card title="⚙️ 游戏设置" size="small" style="margin-bottom: 12px">
      <n-space vertical>
        <n-input-group>
          <n-input v-model:value="newName" placeholder="输入新的焰名" clearable :maxlength="maxLength" show-count />
          <n-button type="primary" @click="handleChangeName" :disabled="!newName">修改焰名</n-button>
        </n-input-group>
        <n-space align="center">
          <n-text>🔊 音效</n-text>
          <n-switch v-model:value="soundEnabled" @update:value="toggleSound" />
        </n-space>
      </n-space>
    </n-card>

    <!-- 系统工具 -->
    <n-card title="🔧 系统工具" size="small" style="margin-bottom: 12px">
      <n-space>
        <n-button @click="resetGuides" type="info" size="small">🔄 重置新手引导</n-button>
        <n-button @click="clearCache" type="warning" size="small">🗑️ 清理缓存</n-button>
      </n-space>
    </n-card>

    <!-- 危险操作 -->
    <n-card title="⚠️ 危险操作" size="small" style="margin-bottom: 12px">
      <n-button type="error" @click="handleReincarnation" ghost>涅槃重修</n-button>
    </n-card>

    <!-- 版本日志 -->
    <n-card title="📜 版本日志" size="small">
      <n-timeline>
        <n-timeline-item v-for="log in changeLogs" :key="log.version" :title="log.version" :time="log.date" :type="log.type || 'default'">
          <ul style="margin:0;padding-left:16px">
            <li v-for="(item, i) in log.items" :key="i" style="font-size:13px">{{ item }}</li>
          </ul>
        </n-timeline-item>
      </n-timeline>
    </n-card>
  </div>
</template>
<script setup>
  import { usePlayerStore } from '../stores/player'
  import { useAuthStore } from '../stores/auth'
  import { ref, onMounted } from 'vue'
  import { useDialog, useMessage } from 'naive-ui'
  import { sfxMute } from '../plugins/sfx'

  const clickCount = ref(0)
  const newName = ref('')
  const message = useMessage()
  const maxLength = 6
  const playerStore = usePlayerStore()
  const authStore = useAuthStore()
  const dialog = useDialog()
  const version = __APP_VERSION__
  const registerTime = ref('加载中...')
  const soundEnabled = ref(!sfxMute.muted)

  const changeLogs = [
    {
      version: 'v' + version, date: '当前版本', type: 'success',
      items: ['云存档系统', '宗门系统', '拍卖行', '世界Boss', '每日副本', '好友私信', '坐骑称号', '转生飞升', '限时活动']
    }
  ]

  onMounted(async () => {
    if (authStore.isLoggedIn) {
      try {
        const res = await fetch('/api/player/profile', {
          headers: { 'Authorization': 'Bearer ' + localStorage.getItem('xx_token') }
        })
        const data = await res.json()
        if (data.success && data.createdAt) {
          registerTime.value = new Date(data.createdAt).toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric' })
        }
      } catch { registerTime.value = '未知' }
    }
  })

  const toggleSound = (val) => {
    sfxMute.muted = !val
    message.success(val ? '音效已开启' : '音效已关闭')
  }

  const handleReincarnation = () => {
    clickCount.value++
    if (clickCount.value >= 10) {
      dialog.warning({
        title: '提示', content: 'GM模式已开启！',
        positiveText: '确定', negativeText: '取消',
        onPositiveClick: () => { playerStore.isGMMode = true; playerStore.saveData() }
      })
      return
    }
    dialog.warning({
      title: '涅槃重修确认', content: '确定要涅槃重修吗？这将清空所有数据重新开始！',
      positiveText: '确定', negativeText: '取消',
      onPositiveClick: async () => {
        dialog.warning({
          title: '最终确认', content: '这是最后的确认，转世后将无法恢复！确定继续吗？',
          positiveText: '确定转世', negativeText: '再想想',
          onPositiveClick: async () => { await playerStore.clearData(); location.href = location.origin }
        })
      }
    })
  }

  const handleChangeName = async () => {
    if (!newName.value.trim()) { message.warning('焰名不能为空！'); return }
    if (newName.value.trim().length > maxLength) { message.warning(`焰名长度不能超过${maxLength}个字符！`); return }
    try {
      const res = await fetch('/api/player/rename', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + localStorage.getItem('xx_token') },
        body: JSON.stringify({ newName: newName.value.trim() })
      })
      const data = await res.json()
      if (data.success) {
        playerStore.spiritStones = data.spiritStones
        playerStore.name = newName.value.trim()
        playerStore.nameChangeCount = data.nameChangeCount
        message.success(data.nameChangeCount === 1 ? '焰名修改成功！首次修改免费' : '焰名修改成功！')
        newName.value = ''
      } else { message.error(data.error || '修改失败') }
    } catch { message.error('修改失败') }
  }

  const resetGuides = () => {
    localStorage.removeItem('xx_guide_seen')
    message.success('新手引导已重置，下次进入各页面会重新显示')
  }

  const clearCache = () => {
    dialog.warning({
      title: '清理缓存', content: '将清理 Service Worker 缓存和浏览器缓存，不会影响游戏数据。',
      positiveText: '确定', negativeText: '取消',
      onPositiveClick: async () => {
        try {
          if ('caches' in window) { const keys = await caches.keys(); await Promise.all(keys.map(k => caches.delete(k))) }
          if ('serviceWorker' in navigator) { const regs = await navigator.serviceWorker.getRegistrations(); await Promise.all(regs.map(r => r.unregister())) }
          message.success('缓存已清理！')
        } catch { message.error('清理失败') }
      }
    })
  }
</script>

<style scoped></style>
