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
        <n-button @click="goToHelp" type="success" size="small">📖 游戏帮助</n-button>
        <n-button @click="showSuggestion = true" type="info" size="small">💡 游戏建议</n-button>
        <n-button @click="resetGuides" type="info" size="small">🔄 重置新手引导</n-button>
        <n-button @click="clearCache" type="warning" size="small">🗑️ 清理缓存</n-button>
      </n-space>
    </n-card>

    <!-- 管理员工具 (仅管理员可见) -->
    <n-card v-if="isAdmin" title="🛡️ 管理员工具" size="small" style="margin-bottom: 12px">
      <n-space>
        <n-button @click="navigateTo('admin')" type="warning" size="small">📊 后台管理</n-button>
        <n-button @click="navigateTo('admin-events')" type="warning" size="small">🎉 活动管理</n-button>
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
    <!-- 游戏建议弹窗 -->
    <n-modal v-model:show="showSuggestion" preset="card" title="💡 游戏建议" style="max-width: 90vw; width: 400px" :bordered="false">
      <n-space vertical>
        <n-select v-model:value="suggestionType" :options="suggestionTypes" placeholder="选择建议类型" />
        <n-input v-model:value="suggestionText" type="textarea" placeholder="请描述你的建议或想法..." :rows="5" maxlength="500" show-count />
        <n-button type="primary" block @click="submitSuggestion" :loading="submitting" :disabled="!suggestionText.trim()">
          提交建议
        </n-button>
      </n-space>
    </n-modal>
  </div>
</template>
<script setup>
  import { usePlayerStore } from '../stores/player'
  import { useAuthStore } from '../stores/auth'
  import { ref, computed, onMounted, inject } from 'vue'
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
      version: 'beta v1.0', date: '2026-02-25', type: 'success',
      items: [
        '公测正式开启，全新起航',
        '云存档系统 - 数据安全上云',
        '修炼/探索/秘境/每日副本',
        '焰运阁抽卡 - 7品质装备+5品质焰兽',
        '竞技场 - 异步PvP对战+天梯排位',
        '焰盟系统 - 创建/加入/焰盟战',
        '拍卖行 - 自由交易装备',
        '世界Boss - 全服协力击杀',
        '焰灵游坊 - 6款趣味小游戏',
        '好友系统 - 私信/送礼',
        '坐骑称号 - 个性化展示',
        '月卡(薪火令) - 每日福利',
        '后台管理系统 - 全面数据监控'
      ]
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
        playerStore.spiritStones = Number(data.spiritStones) || 0
        playerStore.name = newName.value.trim()
        playerStore.nameChangeCount = data.nameChangeCount
        message.success(data.nameChangeCount === 1 ? '焰名修改成功！首次修改免费' : '焰名修改成功！')
        newName.value = ''
      } else { message.error(data.error || '修改失败') }
    } catch { message.error('修改失败') }
  }

  const navigateTo = inject('navigateTo')
  const ADMIN_WALLETS = ['0xfad7eb0814b6838b05191a07fb987957d50c4ca9', '0x82e402b05f3e936b63a874788c73e1552657c4f7']
  const isAdmin = computed(() => ADMIN_WALLETS.includes(authStore.wallet?.toLowerCase()))

  const goToHelp = () => navigateTo('game-help')

  // 游戏建议
  const showSuggestion = ref(false)
  const suggestionText = ref('')
  const suggestionType = ref('feature')
  const submitting = ref(false)
  const suggestionTypes = [
    { label: '\u{1F195} 新功能建议', value: 'feature' },
    { label: '\u2696\uFE0F 数值平衡', value: 'balance' },
    { label: '\u{1F3A8} 界面优化', value: 'ui' },
    { label: '\u{1F3AE} 玩法建议', value: 'gameplay' },
    { label: '\u{1F4AC} 其他', value: 'other' }
  ]
  const submitSuggestion = async () => {
    if (!suggestionText.value.trim()) return
    submitting.value = true
    try {
      const res = await authStore.apiPost('/bug-report', {
        type: 'suggestion',
        description: '[' + (suggestionTypes.find(t => t.value === suggestionType.value)?.label || suggestionType.value) + '] ' + suggestionText.value
      })
      if (res.success !== false) {
        window.$message?.success('感谢你的建议！')
        suggestionText.value = ''
        showSuggestion.value = false
      } else {
        window.$message?.error(res.message || '提交失败')
      }
    } catch (e) {
      window.$message?.error('提交失败: ' + e.message)
    } finally {
      submitting.value = false
    }
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
