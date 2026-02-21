<template>
  <div class="settings-container">
    <n-card>
      <n-space justify="end" style="margin-bottom: 8px">
        <n-text depth="3">游戏版本{{ version }}</n-text>
      </n-space>
      <n-space vertical>
        <n-input-group>
          <n-input v-model:value="newName" placeholder="输入新的焰名" clearable :maxlength="maxLength" show-count />
          <n-button type="primary" @click="handleChangeName" :disabled="!newName">修改焰名</n-button>
        </n-input-group>
        <n-space>
          <n-button type="warning" @click="handleReincarnation">涅槃重修</n-button>
          <n-button @click="handleExportSave" type="info">导出存档</n-button>
          <n-upload :show-file-list="false" @change="handleImportSave">
            <n-button>导入存档</n-button>
          </n-upload>
        </n-space>
        <n-divider />
        <n-space>
          <n-button @click="toggleDarkMode">{{ playerStore.isDarkMode ? '☀️ 亮色模式' : '🌙 暗色模式' }}</n-button>
          <n-button @click="resetGuides" type="info">🔄 重置新手引导</n-button>
          <n-button @click="clearCache" type="warning">🗑️ 清理缓存</n-button>
        </n-space>
      </n-space>
    </n-card>
  </div>
</template>

<script setup>
  import { usePlayerStore } from '../stores/player'
  import { ref } from 'vue'
  import { useDialog, useMessage } from 'naive-ui'
  import { saveAs } from 'file-saver'

  const clickCount = ref(0)
  const newName = ref('')
  const message = useMessage()
  const maxLength = 6 // 定义道号最大长度常量
  const playerStore = usePlayerStore()
  const dialog = useDialog()
  const version = __APP_VERSION__

  // 导出存档
  const handleExportSave = async () => {
    try {
      const saveData = await playerStore.exportData()
      if (!saveData) {
        message.error('没有可导出的存档数据！')
        return
      }
      // 导出加密后的存档数据
      saveAs(
        new Blob([saveData], { type: 'application/json;charset=utf-8' }),
        `我的放置焰途${version}版本存档数据-${new Date().toISOString().slice(0, 10)}-${Date.now()}.json`
      )
      message.success('存档导出成功！')
    } catch (error) {
      message.error('导出失败：' + error.message)
    }
  }

  // 导入存档
  const handleImportSave = data => {
    const reader = new FileReader()
    reader.onload = async e => {
      try {
        const encryptedData = e.target.result
        await playerStore.importData(encryptedData)
        message.success('存档导入成功！')
      } catch (error) {
        message.error('导入失败：' + error.message)
      }
    }
    reader.readAsText(data.file.file)
  }

  // 涅槃重修确认
  const handleReincarnation = () => {
    clickCount.value++
    if (clickCount.value >= 10) {
      dialog.warning({
        title: '提示',
        content: 'GM模式已开启！',
        positiveText: '确定',
        negativeText: '取消',
        onPositiveClick: () => {
          playerStore.isGMMode = true
          playerStore.saveData()
        }
      })
      return
    }
    dialog.warning({
      title: '涅槃重修确认',
      content: '确定要涅槃重修吗？这将清空所有数据重新开始！',
      positiveText: '确定',
      negativeText: '取消',
      onPositiveClick: async () => {
        // 二次确认
        dialog.warning({
          title: '最终确认',
          content: '这是最后的确认，转世后将无法恢复！确定继续吗？',
          positiveText: '确定转世',
          negativeText: '再想想',
          onPositiveClick: async () => {
            await playerStore.clearData()
            location.href = location.origin
          }
        })
      }
    })
  }

  // 修改焰名（服务端验证）
  const handleChangeName = async () => {
    if (!newName.value.trim()) {
      message.warning('焰名不能为空！')
      return
    }
    if (newName.value.trim().length > maxLength) {
      message.warning(`焰名长度不能超过${maxLength}个字符！`)
      return
    }
    try {
      const res = await fetch('/api/player/rename', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + localStorage.getItem('xx_token')
        },
        body: JSON.stringify({ newName: newName.value.trim() })
      })
      const data = await res.json()
      if (data.success) {
        playerStore.spiritStones = data.spiritStones
        playerStore.name = newName.value.trim()
        playerStore.nameChangeCount = data.nameChangeCount
        message.success(
          data.nameChangeCount === 1 ? '焰名修改成功！首次修改免费' : `焰名修改成功！`
        )
        newName.value = ''
      } else {
        message.error(data.error || '修改失败')
      }
    } catch (e) {
      message.error('修改失败')
    }
  }
  // 暗色模式切换
  const toggleDarkMode = () => {
    playerStore.toggle()
    message.success(playerStore.isDarkMode ? '已切换到暗色模式' : '已切换到亮色模式')
  }

  // 重置新手引导
  const resetGuides = () => {
    localStorage.removeItem('xx_guide_seen')
    message.success('新手引导已重置，下次进入各页面会重新显示')
  }

  // 清理缓存
  const clearCache = () => {
    dialog.warning({
      title: '清理缓存',
      content: '将清理 Service Worker 缓存和浏览器缓存，不会影响游戏数据。',
      positiveText: '确定',
      negativeText: '取消',
      onPositiveClick: async () => {
        try {
          if ('caches' in window) {
            const keys = await caches.keys()
            await Promise.all(keys.map(k => caches.delete(k)))
          }
          if ('serviceWorker' in navigator) {
            const regs = await navigator.serviceWorker.getRegistrations()
            await Promise.all(regs.map(r => r.unregister()))
          }
          message.success('缓存已清理！')
        } catch (e) { message.error('清理失败') }
      }
    })
  }
</script>

<style scoped></style>
