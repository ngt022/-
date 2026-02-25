<template>
  <teleport to="body">
    <transition name="guide-fade">
      <div v-if="visible" class="newbie-overlay" @click.self="skip">
        <div class="newbie-box">
          <div class="newbie-step-indicator">
            <span v-for="i in totalSteps" :key="i" class="step-dot" :class="{ active: i === currentStep, done: i < currentStep }"></span>
          </div>
          <div class="newbie-icon">{{ steps[currentStep - 1]?.icon }}</div>
          <div class="newbie-title">{{ steps[currentStep - 1]?.title }}</div>
          <div class="newbie-desc">{{ steps[currentStep - 1]?.desc }}</div>
          <div class="newbie-actions">
            <button v-if="currentStep < totalSteps" class="btn-skip" @click="skip">跳过</button>
            <button v-if="currentStep < totalSteps" class="btn-next" @click="next">
              {{ steps[currentStep - 1]?.btnText || '下一步' }} →
            </button>
            <button v-else class="btn-next btn-start" @click="finish">
              🔥 开始冒险！
            </button>
          </div>
        </div>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
import { ref, inject } from 'vue'
import { markGuideSeen } from '../utils/guide.js'

const navigateTo = inject('navigateTo')
const emit = defineEmits(['complete'])
const visible = ref(true)
const currentStep = ref(1)

const steps = [
  {
    icon: '🔥',
    title: '欢迎来到火之文明',
    desc: '远古时代，焰灵是万物之源。你将踏上修炼之路，从凡人修炼至飞升成神。准备好了吗？',
    btnText: '继续'
  },
  {
    icon: '⚔️',
    title: '修炼是根基',
    desc: '点击「冥想」消耗焰灵积累焰修，焰修满后突破境界。境界越高，属性越强。记得每天修炼！',
    btnText: '了解'
  },
  {
    icon: '🎒',
    title: '装备让你更强',
    desc: '装备分7个品质：凡品→下品→中品→上品→极品→仙品→神品。神品全服限量50件，自带唯一编号！',
    btnText: '了解'
  },
  {
    icon: '🎰',
    title: '焰运阁抽卡',
    desc: '消耗焰晶在焰运阁抽取装备和焰兽。十连抽有保底机制，运气好能出神品！',
    btnText: '了解'
  },
  {
    icon: '🗺️',
    title: '探索获取资源',
    desc: '探索不同地图获取焰晶、焰草和装备。等级越高解锁越多地图，奖励也越丰厚。',
    btnText: '了解'
  },
  {
    icon: '🏟️',
    title: '竞技场一决高下',
    desc: '在竞技场挑战其他玩家，提升段位。每日5次免费挑战，赛季结算还有丰厚奖励！',
    btnText: '了解'
  },
  {
    icon: '🎁',
    title: '领取新手礼包',
    desc: '主城有新手礼包等你领取，包含20000焰晶助你快速起步。记得去商城看看新手礼包哦！',
    btnText: '开始冒险'
  }
]

const totalSteps = steps.length

const next = () => {
  if (currentStep.value < totalSteps) currentStep.value++
}

const skip = () => {
  markGuideSeen('newbie_tutorial')
  visible.value = false
  emit('complete')
}

const finish = () => {
  markGuideSeen('newbie_tutorial')
  visible.value = false
  emit('complete')
}
</script>

<style scoped>
.newbie-overlay {
  position: fixed; inset: 0; z-index: 10000;
  background: rgba(0,0,0,0.75);
  display: flex; align-items: center; justify-content: center;
}
.newbie-box {
  max-width: 340px; width: 90%;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #1a1a2e 100%);
  border: 1.5px solid rgba(212,168,67,0.5);
  border-radius: 16px; padding: 28px 24px;
  box-shadow: 0 12px 48px rgba(0,0,0,0.6), 0 0 20px rgba(212,168,67,0.15);
  text-align: center;
}
.newbie-step-indicator {
  display: flex; justify-content: center; gap: 6px; margin-bottom: 20px;
}
.step-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: rgba(255,255,255,0.15); transition: all 0.3s;
}
.step-dot.active { background: #d4a843; transform: scale(1.3); box-shadow: 0 0 8px rgba(212,168,67,0.5); }
.step-dot.done { background: rgba(212,168,67,0.5); }
.newbie-icon { font-size: 48px; margin-bottom: 12px; }
.newbie-title {
  font-size: 18px; font-weight: bold; color: #d4a843;
  margin-bottom: 12px; letter-spacing: 1px;
}
.newbie-desc {
  font-size: 14px; color: #c0b090; line-height: 1.7;
  margin-bottom: 24px;
}
.newbie-actions {
  display: flex; justify-content: center; gap: 12px;
}
.btn-skip {
  background: transparent; border: 1px solid rgba(255,255,255,0.2);
  color: #888; padding: 8px 20px; border-radius: 8px;
  font-size: 13px; cursor: pointer; transition: all 0.2s;
}
.btn-skip:hover { border-color: rgba(255,255,255,0.4); color: #aaa; }
.btn-next {
  background: linear-gradient(135deg, #d4a843, #b8860b);
  border: none; color: #1a1a2e; padding: 8px 24px;
  border-radius: 8px; font-size: 14px; font-weight: bold;
  cursor: pointer; transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(212,168,67,0.3);
}
.btn-next:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(212,168,67,0.4); }
.btn-start { padding: 10px 28px; font-size: 15px; }
.guide-fade-enter-active, .guide-fade-leave-active { transition: opacity 0.3s; }
.guide-fade-enter-from, .guide-fade-leave-to { opacity: 0; }
</style>
