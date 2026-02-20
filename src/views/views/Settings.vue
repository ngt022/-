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

  // 修改焰名
  const handleChangeName = () => {
    if (!newName.value.trim()) {
      message.warning('焰名不能为空！')
      return
    }
    if (newName.value.trim().length > maxLength) {
      message.warning(`焰名长度不能超过${maxLength}个字符！`)
      return
    }
    // 计算修改焰名所需焰晶
    const spiritStoneCost = playerStore.nameChangeCount === 0 ? 0 : Math.pow(2, playerStore.nameChangeCount) * 100
    // 第一次修改免费，之后需要消耗焰晶
    if (playerStore.nameChangeCount > 0) {
      if (playerStore.spiritStones < spiritStoneCost) {
        message.error(`焰晶不足！修改焰名需要${spiritStoneCost}颗焰晶`)
        return
      }
      playerStore.spiritStones -= spiritStoneCost
    }
    playerStore.name = newName.value.trim()
    playerStore.nameChangeCount++
    playerStore.saveData()
    message.success(
      playerStore.nameChangeCount === 1 ? '焰名修改成功！首次修改免费' : `焰名修改成功！消耗${spiritStoneCost}颗焰晶`
    )
    newName.value = ''
  }
</script>

<style scoped></style>
