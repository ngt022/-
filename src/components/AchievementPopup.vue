<template>
  <teleport to="body">
    <transition name="ach-fade">
      <div v-if="show" class="ach-overlay" @click="dismiss">
        <div class="ach-card" @click.stop>
          <div class="ach-glow"></div>
          <div class="ach-icon">🏆</div>
          <div class="ach-label">成就达成</div>
          <div class="ach-name">{{ achievement?.name }}</div>
          <div class="ach-desc">{{ achievement?.description }}</div>
          <div v-if="achievement?.reward" class="ach-reward">
            奖励：💎 {{ achievement.reward.spiritStones || 0 }} 焰晶
          </div>
          <div class="ach-hint">点击关闭</div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({ achievement: Object, show: Boolean })
const emit = defineEmits(['close'])
const dismiss = () => emit('close')

watch(() => props.show, (v) => {
  if (v) setTimeout(() => emit('close'), 6000)
})
</script>

<style scoped>
.ach-overlay {
  position: fixed; top: 0; left: 0; right: 0; bottom: 0;
  z-index: 10000; display: flex; align-items: center; justify-content: center;
  background: rgba(0,0,0,0.7); cursor: pointer;
}
.ach-card {
  position: relative; text-align: center; padding: 32px 24px;
  background: rgba(15,15,30,0.95); border: 1px solid rgba(212,168,67,0.3);
  border-radius: 16px; max-width: 320px; width: 85%;
  animation: ach-pop 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
}
@keyframes ach-pop {
  from { transform: scale(0.5); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
.ach-glow {
  position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%);
  width: 250px; height: 250px;
  background: radial-gradient(circle, rgba(255,215,0,0.15) 0%, transparent 70%);
  animation: ach-glow-pulse 2s ease-in-out infinite;
  pointer-events: none;
}
@keyframes ach-glow-pulse {
  0%,100% { transform: translate(-50%,-50%) scale(1); opacity: 0.5; }
  50% { transform: translate(-50%,-50%) scale(1.2); opacity: 1; }
}
.ach-icon { font-size: 48px; margin-bottom: 8px; position: relative; z-index: 1; }
.ach-label {
  font-size: 12px; color: rgba(212,168,67,0.5); letter-spacing: 4px;
  text-transform: uppercase; margin-bottom: 8px; position: relative; z-index: 1;
}
.ach-name {
  font-size: 22px; font-weight: 900; color: #ffd700;
  text-shadow: 0 0 16px rgba(255,215,0,0.4);
  margin-bottom: 8px; position: relative; z-index: 1;
}
.ach-desc {
  font-size: 13px; color: rgba(240,214,138,0.6);
  margin-bottom: 16px; position: relative; z-index: 1;
}
.ach-reward {
  background: rgba(212,168,67,0.08); border: 1px solid rgba(212,168,67,0.15);
  border-radius: 8px; padding: 8px 16px; display: inline-block;
  color: #d4a843; font-size: 14px; font-weight: 600;
  position: relative; z-index: 1;
}
.ach-hint {
  font-size: 11px; color: rgba(212,168,67,0.3); margin-top: 16px;
  position: relative; z-index: 1;
}
.ach-fade-enter-active { transition: opacity 0.3s; }
.ach-fade-leave-active { transition: opacity 0.3s; }
.ach-fade-enter-from, .ach-fade-leave-to { opacity: 0; }
</style>
