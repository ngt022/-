<template>
  <teleport to="body">
    <transition name="guide-fade">
      <div v-if="visible" class="guide-overlay" @click.self="dismiss">
        <div class="guide-box" :style="boxStyle">
          <div class="guide-arrow" :class="arrowDir"></div>
          <div class="guide-title">{{ title }}</div>
          <div class="guide-text">{{ text }}</div>
          <div class="guide-actions">
            <span v-if="step && total" class="guide-step">{{ step }}/{{ total }}</span>
            <button class="guide-btn" @click="dismiss">{{ btnText || '知道了' }}</button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  title: String,
  text: String,
  btnText: String,
  step: Number,
  total: Number,
  position: { type: String, default: 'center' }, // center, top, bottom
  arrowDir: { type: String, default: '' }
})

const emit = defineEmits(['dismiss'])
const visible = ref(true)

const boxStyle = computed(() => {
  if (props.position === 'top') return { top: '80px', left: '50%', transform: 'translateX(-50%)' }
  if (props.position === 'bottom') return { bottom: '120px', left: '50%', transform: 'translateX(-50%)' }
  return { top: '50%', left: '50%', transform: 'translate(-50%, -50%)' }
})

const dismiss = () => {
  visible.value = false
  emit('dismiss')
}
</script>

<style scoped>
.guide-overlay {
  position: fixed; inset: 0; z-index: 9999;
  background: rgba(0,0,0,0.6);
  display: flex; align-items: center; justify-content: center;
}
.guide-box {
  position: fixed; max-width: 320px; width: 90%;
  background: linear-gradient(135deg, #1a1a2e, #16213e);
  border: 1px solid rgba(212,168,67,0.4);
  border-radius: 12px; padding: 20px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.5);
}
.guide-title {
  font-size: 16px; font-weight: bold; color: #d4a843;
  margin-bottom: 8px;
}
.guide-text {
  font-size: 13px; color: #c0b090; line-height: 1.6;
  margin-bottom: 16px;
}
.guide-actions {
  display: flex; justify-content: space-between; align-items: center;
}
.guide-step { font-size: 12px; color: #666; }
.guide-btn {
  background: linear-gradient(135deg, #d4a843, #b8860b);
  border: none; color: #1a1a2e; padding: 6px 20px;
  border-radius: 6px; font-size: 13px; font-weight: bold;
  cursor: pointer;
}
.guide-fade-enter-active, .guide-fade-leave-active { transition: opacity 0.3s; }
.guide-fade-enter-from, .guide-fade-leave-to { opacity: 0; }
</style>
