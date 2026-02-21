<template>
  <div class="mail-page">
    <div class="mail-header">
      <span class="mail-title">📬 邮件 <span v-if="unread" class="unread-count">{{ unread }}</span></span>
      <button class="mail-refresh" @click="loadMails" :disabled="loading">🔄</button>
    </div>

    <div v-if="loading" class="mail-loading">加载中...</div>

    <div v-else-if="mails.length === 0" class="mail-empty">
      <div class="empty-icon">📭</div>
      <div class="empty-text">暂无邮件</div>
    </div>

    <div v-else class="mail-list">
      <div v-for="mail in mails" :key="mail.id"
        class="mail-item" :class="{ unread: !mail.is_read }"
        @click="openMail(mail)">
        <div class="mail-item-left">
          <span class="mail-icon">{{ mail.from_type === 'admin' ? '👑' : mail.from_type === 'system' ? '🔔' : '💌' }}</span>
          <div class="mail-info">
            <div class="mail-item-title">{{ mail.title }}</div>
            <div class="mail-item-from">{{ mail.from_name }} · {{ formatTime(mail.created_at) }}</div>
          </div>
        </div>
        <div class="mail-item-right">
          <span v-if="hasRewards(mail) && !mail.is_claimed" class="reward-badge">🎁</span>
          <span v-if="mail.is_claimed" class="claimed-badge">✅</span>
        </div>
      </div>
    </div>

    <!-- 邮件详情弹窗 -->
    <n-modal v-model:show="showDetail" preset="card" :title="currentMail?.title || ''" style="max-width:400px">
      <div class="mail-detail" v-if="currentMail">
        <div class="detail-from">{{ currentMail.from_name }} · {{ formatTime(currentMail.created_at) }}</div>
        <div class="detail-content">{{ currentMail.content }}</div>
        <div v-if="hasRewards(currentMail)" class="detail-rewards">
          <div class="rewards-title">📦 附件奖励</div>
          <div class="rewards-list">
            <span v-if="currentMail.rewards.spiritStones" class="reward-item">💎 焰晶 ×{{ currentMail.rewards.spiritStones }}</span>
            <span v-if="currentMail.rewards.reinforceStones" class="reward-item">🔨 淬火石 ×{{ currentMail.rewards.reinforceStones }}</span>
            <span v-if="currentMail.rewards.petEssence" class="reward-item">🐾 精华 ×{{ currentMail.rewards.petEssence }}</span>
          </div>
          <button v-if="!currentMail.is_claimed" class="claim-btn" @click="claimReward" :disabled="claiming">
            {{ claiming ? '领取中...' : '领取奖励' }}
          </button>
          <div v-else class="claimed-text">✅ 已领取</div>
        </div>
        <div class="detail-actions">
          <button class="delete-btn" @click="deleteMail">🗑️ 删除</button>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const mails = ref([])
const unread = ref(0)
const loading = ref(false)
const showDetail = ref(false)
const currentMail = ref(null)
const claiming = ref(false)

const loadMails = async () => {
  loading.value = true
  try {
    const data = await authStore.apiGet('/mail/list')
    mails.value = data.mails || []
    unread.value = data.unread || 0
  } catch (e) { console.error('加载邮件失败:', e) }
  loading.value = false
}

const openMail = async (mail) => {
  currentMail.value = mail
  showDetail.value = true
  if (!mail.is_read) {
    try {
      await authStore.apiPost('/mail/read', { mailId: mail.id })
      mail.is_read = true
      unread.value = Math.max(0, unread.value - 1)
    } catch {}
  }
}

const claimReward = async () => {
  if (!currentMail.value || claiming.value) return
  claiming.value = true
  try {
    await authStore.apiPost('/mail/claim', { mailId: currentMail.value.id })
    currentMail.value.is_claimed = true
    window.$message?.success('奖励已领取！')
  } catch (e) { window.$message?.error(e.message) }
  claiming.value = false
}

const deleteMail = async () => {
  if (!currentMail.value) return
  try {
    await authStore.apiPost('/mail/delete', { mailId: currentMail.value.id })
    mails.value = mails.value.filter(m => m.id !== currentMail.value.id)
    showDetail.value = false
    currentMail.value = null
  } catch (e) { window.$message?.error(e.message) }
}

const hasRewards = (mail) => {
  const r = mail.rewards
  return r && (r.spiritStones || r.reinforceStones || r.petEssence)
}

const formatTime = (t) => {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const diff = now - d
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  return d.toLocaleDateString('zh-CN', { month: 'short', day: 'numeric' })
}

onMounted(loadMails)
</script>

<style scoped>
.mail-page { padding: 12px; max-width: 500px; margin: 0 auto; }
.mail-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.mail-title { font-size: 18px; font-weight: bold; color: #d4a843; }
.unread-count { background: #e74c3c; color: #fff; font-size: 12px; padding: 2px 8px; border-radius: 10px; margin-left: 6px; }
.mail-refresh { background: none; border: 1px solid rgba(212,168,67,0.3); color: #d4a843; padding: 4px 10px; border-radius: 6px; cursor: pointer; }
.mail-loading, .mail-empty { text-align: center; padding: 40px 0; color: #666; }
.empty-icon { font-size: 48px; margin-bottom: 8px; }
.mail-list { display: flex; flex-direction: column; gap: 8px; }
.mail-item { display: flex; justify-content: space-between; align-items: center; padding: 12px; background: rgba(26,26,46,0.8); border: 1px solid rgba(255,255,255,0.05); border-radius: 8px; cursor: pointer; transition: all 0.2s; }
.mail-item:hover { border-color: rgba(212,168,67,0.3); }
.mail-item.unread { border-left: 3px solid #d4a843; }
.mail-item-left { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }
.mail-icon { font-size: 24px; }
.mail-info { min-width: 0; }
.mail-item-title { font-size: 14px; color: #e0d0b0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.mail-item-from { font-size: 11px; color: #666; margin-top: 2px; }
.reward-badge { font-size: 16px; animation: pulse 1.5s infinite; }
.claimed-badge { font-size: 14px; opacity: 0.5; }
@keyframes pulse { 0%,100% { transform: scale(1); } 50% { transform: scale(1.2); } }
.detail-from { font-size: 12px; color: #888; margin-bottom: 12px; }
.detail-content { font-size: 14px; color: #c0b090; line-height: 1.6; margin-bottom: 16px; white-space: pre-wrap; }
.detail-rewards { background: rgba(212,168,67,0.1); border: 1px solid rgba(212,168,67,0.2); border-radius: 8px; padding: 12px; margin-bottom: 12px; }
.rewards-title { font-size: 13px; color: #d4a843; margin-bottom: 8px; }
.rewards-list { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 10px; }
.reward-item { font-size: 13px; color: #e0d0b0; background: rgba(0,0,0,0.3); padding: 4px 10px; border-radius: 4px; }
.claim-btn { width: 100%; padding: 8px; background: linear-gradient(135deg, #d4a843, #b8860b); border: none; color: #1a1a2e; font-weight: bold; border-radius: 6px; cursor: pointer; }
.claimed-text { text-align: center; color: #4caf50; font-size: 13px; }
.detail-actions { display: flex; justify-content: flex-end; }
.delete-btn { background: none; border: 1px solid rgba(231,76,60,0.3); color: #e74c3c; padding: 6px 16px; border-radius: 6px; cursor: pointer; font-size: 13px; }
</style>
