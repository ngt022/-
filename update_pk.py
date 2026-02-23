#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PK.vue 战斗回放动态化脚本
只替换 <template v-if="battleResult"> 到 返回大厅</n-button> 之间的内容
"""

import re

# 新的战斗回放模板部分（template）
NEW_BATTLE_TEMPLATE = '''      <!-- 战斗回放 -->
      <template v-if="battleResult">
        <div class="battle-replay">
          <!-- 战斗预告 -->
          <div v-if="showCountdown" class="battle-intro">
            <div class="intro-fighters">
              <div class="intro-fighter">
                <div class="intro-avatar fa">{{ battleResult.nameA[0] }}</div>
                <n-text strong>{{ battleResult.nameA }}</n-text>
              </div>
              <div class="intro-vs">VS</div>
              <div class="intro-fighter">
                <div class="intro-avatar fb">{{ battleResult.nameB[0] }}</div>
                <n-text strong>{{ battleResult.nameB }}</n-text>
              </div>
            </div>
            <div class="countdown" :class="'count-' + countdownNum">{{ countdownText }}</div>
          </div>

          <!-- 战斗主体 -->
          <div v-else>
            <!-- 血条区域 -->
            <div class="battle-header">
              <div class="fighter" :class="{ winner: battleResult.winner === 'A' && battleEnded }">
                <div class="fighter-avatar fa">{{ battleResult.nameA[0] }}</div>
                <n-text strong>{{ battleResult.nameA }}</n-text>
                <div class="hp-wrapper">
                  <div class="fighter-hp-bar">
                    <div class="fighter-hp-fill" :class="hpColorClass(currentHpA, battleResult.maxHpA)"
                      :style="{ width: hpPercent(currentHpA, battleResult.maxHpA) }"></div>
                  </div>
                  <span class="hp-text">{{ currentHpA }}/{{ battleResult.maxHpA }}</span>
                </div>
              </div>
              <div class="vs-center">
                <span class="vs-text">VS</span>
                <span class="round-indicator" v-if="!battleEnded">第{{ currentRoundIndex + 1 }}回合</span>
              </div>
              <div class="fighter" :class="{ winner: battleResult.winner === 'B' && battleEnded }">
                <div class="fighter-avatar fb">{{ battleResult.nameB[0] }}</div>
                <n-text strong>{{ battleResult.nameB }}</n-text>
                <div class="hp-wrapper">
                  <div class="fighter-hp-bar">
                    <div class="fighter-hp-fill" :class="hpColorClass(currentHpB, battleResult.maxHpB)"
                      :style="{ width: hpPercent(currentHpB, battleResult.maxHpB) }"></div>
                  </div>
                  <span class="hp-text">{{ currentHpB }}/{{ battleResult.maxHpB }}</span>
                </div>
              </div>
            </div>

            <!-- 当前回合显示 -->
            <div class="current-round" v-if="!battleEnded && currentAction">
              <div class="action-display" :class="{ 'action-flash': actionFlash }">
                <span class="action-attacker" :class="currentAction.attacker === 'A' ? 'side-a' : 'side-b'">
                  {{ currentAction.attacker === 'A' ? battleResult.nameA : battleResult.nameB }}
                </span>
                
                <template v-if="currentAction.isDodged">
                  <span class="effect-text effect-dodge">💨 闪避!</span>
                </template>
                <template v-else>
                  <span class="damage-number" :class="{ 'crit-dmg': currentAction.isCrit }">-{{ currentAction.damage }}</span>
                  <span v-if="currentAction.isCrit" class="effect-text effect-crit">💥 暴击!</span>
                  <span v-if="currentAction.isCombo" class="effect-text effect-combo">⚡ 连击!</span>
                  <span v-if="currentAction.isCounter" class="effect-text effect-counter">🔄 反击!</span>
                  <span v-if="currentAction.isStun" class="effect-text effect-stun">💫 眩晕!</span>
                  <span v-if="currentAction.isVampire" class="effect-text effect-vampire">🩸 吸血 +{{ currentAction.vampireHeal }}!</span>
                </template>
              </div>
            </div>

            <!-- 击杀特写 -->
            <div v-if="showKillShot" class="kill-shot">
              <div class="kill-text">致命一击！</div>
            </div>

            <!-- 结果横幅 -->
            <div v-if="battleEnded" class="battle-result-banner" :class="'result-' + battleResult.winner">
              <template v-if="battleResult.winner === 'draw'">
                <span>⚖️ 平局</span>
              </template>
              <template v-else>
                <span>🏆 {{ battleResult.winnerName }} 获胜！</span>
                <n-text type="warning" style="font-size:12px">+{{ battleResult.reward }} 焰晶</n-text>
              </template>
            </div>

            <!-- 控制按钮 -->
            <div class="battle-controls">
              <n-button v-if="!battleEnded" block type="warning" @click="skipAnimation">⏭️ 跳过动画</n-button>
              <n-button v-else block @click="battleResult = null">返回大厅</n-button>
            </div>
          </div>
        </div>
      </template>'''

# 需要添加到script setup部分的代码
NEW_SCRIPT_CODE = '''// ============ 战斗回放动画控制 ============
const showCountdown = ref(false)
const countdownNum = ref(3)
const countdownText = ref('3')
const currentRoundIndex = ref(0)
const currentActionIndex = ref(0)
const currentHpA = ref(0)
const currentHpB = ref(0)
const battleEnded = ref(false)
const showKillShot = ref(false)
const actionFlash = ref(false)
const animationTimer = ref(null)

const currentRound = computed(() => {
  if (!battleResult.value || !battleResult.value.rounds) return null
  return battleResult.value.rounds[currentRoundIndex.value]
})

const currentAction = computed(() => {
  if (!currentRound.value) return null
  return currentRound.value.actions[currentActionIndex.value]
})

const hpPercent = (hp, max) => `${Math.max(0, (hp / max) * 100).toFixed(1)}%`

const hpColorClass = (hp, max) => {
  const pct = hp / max
  if (pct > 0.5) return 'hp-green'
  if (pct > 0.2) return 'hp-yellow'
  return 'hp-red'
}

const clearAnimationTimer = () => {
  if (animationTimer.value) {
    clearTimeout(animationTimer.value)
    animationTimer.value = null
  }
}

const startCountdown = () => {
  showCountdown.value = true
  countdownNum.value = 3
  countdownText.value = '3'
  
  const step = () => {
    countdownNum.value--
    if (countdownNum.value > 0) {
      countdownText.value = String(countdownNum.value)
      animationTimer.value = setTimeout(step, 1000)
    } else {
      countdownText.value = '开战！'
      animationTimer.value = setTimeout(() => {
        showCountdown.value = false
        startBattlePlayback()
      }, 800)
    }
  }
  animationTimer.value = setTimeout(step, 1000)
}

const startBattlePlayback = () => {
  // 初始化血量
  currentHpA.value = battleResult.value.maxHpA
  currentHpB.value = battleResult.value.maxHpB
  currentRoundIndex.value = 0
  currentActionIndex.value = 0
  battleEnded.value = false
  showKillShot.value = false
  
  playNextAction()
}

const playNextAction = () => {
  if (!battleResult.value) return
  
  const rounds = battleResult.value.rounds
  if (currentRoundIndex.value >= rounds.length) {
    // 所有回合播放完毕，结束战斗
    endBattle()
    return
  }
  
  const round = rounds[currentRoundIndex.value]
  if (currentActionIndex.value >= round.actions.length) {
    // 当前回合动作播放完毕，进入下一回合
    currentRoundIndex.value++
    currentActionIndex.value = 0
    animationTimer.value = setTimeout(playNextAction, 500)
    return
  }
  
  const action = round.actions[currentActionIndex.value]
  
  // 触发动作闪烁效果
  actionFlash.value = true
  setTimeout(() => { actionFlash.value = false }, 300)
  
  // 计算伤害后的血量
  if (!action.isDodged) {
    if (action.attacker === 'A') {
      currentHpB.value = Math.max(0, currentHpB.value - action.damage)
    } else {
      currentHpA.value = Math.max(0, currentHpA.value - action.damage)
    }
  }
  
  // 检查是否是最后一个动作
  const isLastRound = currentRoundIndex.value === rounds.length - 1
  const isLastAction = currentActionIndex.value === round.actions.length - 1
  
  if (isLastRound && isLastAction) {
    // 最后一击，显示击杀特写
    animationTimer.value = setTimeout(() => {
      showKillShot.value = true
      animationTimer.value = setTimeout(() => {
        showKillShot.value = false
        endBattle()
      }, 1500)
    }, 800)
  } else {
    // 继续下一个动作
    currentActionIndex.value++
    animationTimer.value = setTimeout(playNextAction, 1500)
  }
}

const endBattle = () => {
  battleEnded.value = true
  // 设置最终血量
  currentHpA.value = battleResult.value.finalHpA
  currentHpB.value = battleResult.value.finalHpB
}

const skipAnimation = () => {
  clearAnimationTimer()
  showCountdown.value = false
  showKillShot.value = false
  currentRoundIndex.value = (battleResult.value.rounds?.length || 1) - 1
  currentActionIndex.value = 0
  currentHpA.value = battleResult.value.finalHpA
  currentHpB.value = battleResult.value.finalHpB
  battleEnded.value = true
}

// 监听battleResult变化，自动开始动画
watch(() => battleResult.value, (newVal) => {
  clearAnimationTimer()
  if (newVal) {
    startCountdown()
  }
}, { immediate: false })

// 清理定时器
onUnmounted(() => {
  clearAnimationTimer()
})
// ============ 战斗回放动画控制结束 ============
'''

# 需要添加到style scoped部分的CSS
NEW_STYLE_CSS = '''
/* 战斗预告 */
.battle-intro {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  animation: fadeIn 0.3s ease;
}
.intro-fighters {
  display: flex;
  align-items: center;
  gap: 30px;
  margin-bottom: 30px;
}
.intro-fighter {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}
.intro-avatar {
  width: 60px;
  height: 60px;
  border-radius: 15px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  color: #fff;
  font-size: 24px;
}
.intro-vs {
  font-size: 28px;
  font-weight: 900;
  color: #d4a843;
  text-shadow: 0 0 20px rgba(212,168,67,0.6);
  animation: pulse 1s infinite;
}
.countdown {
  font-size: 48px;
  font-weight: 900;
  color: #ff5722;
  text-shadow: 0 0 30px rgba(255,87,34,0.8);
  animation: countdownPop 0.8s ease;
}
.countdown.count-0 {
  color: #4caf50;
}
@keyframes countdownPop {
  0% { transform: scale(0.5); opacity: 0; }
  50% { transform: scale(1.3); }
  100% { transform: scale(1); opacity: 1; }
}
@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* 血条动画 */
.hp-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}
.fighter-hp-bar {
  width: 100px;
  height: 10px;
  border-radius: 5px;
  background: rgba(255,255,255,0.1);
  overflow: hidden;
  border: 1px solid rgba(255,255,255,0.1);
}
.fighter-hp-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.5s ease, background-color 0.3s ease;
}
.fighter-hp-fill.hp-green {
  background: linear-gradient(90deg, #4caf50, #8bc34a);
  box-shadow: 0 0 8px rgba(76,175,80,0.4);
}
.fighter-hp-fill.hp-yellow {
  background: linear-gradient(90deg, #ff9800, #ffc107);
  box-shadow: 0 0 8px rgba(255,152,0,0.4);
}
.fighter-hp-fill.hp-red {
  background: linear-gradient(90deg, #f44336, #ff5722);
  box-shadow: 0 0 8px rgba(244,67,54,0.5);
}
.hp-text {
  font-size: 11px;
  color: #a09880;
}
.round-indicator {
  font-size: 12px;
  color: #d4a843;
  margin-top: 4px;
}

/* 当前回合显示 */
.current-round {
  min-height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  margin: 16px 0;
  background: rgba(10,10,15,0.6);
  border-radius: 12px;
  border: 1px solid rgba(212,168,67,0.15);
}
.action-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
}
.action-display.action-flash {
  animation: flashAction 0.3s ease;
}
@keyframes flashAction {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}
.damage-number {
  font-size: 28px;
  font-weight: 900;
  color: #fff;
  text-shadow: 0 0 15px rgba(255,255,255,0.5);
  animation: damageFloat 0.8s ease;
}
.damage-number.crit-dmg {
  color: #ff4444;
  font-size: 36px;
  text-shadow: 0 0 20px rgba(255,68,68,0.8);
}
@keyframes damageFloat {
  0% { transform: translateY(10px); opacity: 0; }
  20% { transform: translateY(-5px); opacity: 1; }
  100% { transform: translateY(0); opacity: 1; }
}

/* 特效文字 */
.effect-text {
  font-size: 14px;
  font-weight: bold;
  padding: 4px 10px;
  border-radius: 6px;
  animation: effectPop 0.5s ease;
}
@keyframes effectPop {
  0% { transform: scale(0); opacity: 0; }
  50% { transform: scale(1.3); }
  100% { transform: scale(1); opacity: 1; }
}
.effect-crit {
  color: #fff;
  background: linear-gradient(135deg, #ff4444, #cc0000);
  font-size: 18px;
  box-shadow: 0 0 15px rgba(255,68,68,0.5);
}
.effect-combo {
  color: #fff;
  background: linear-gradient(135deg, #ff9800, #f57c00);
  box-shadow: 0 0 10px rgba(255,152,0,0.4);
}
.effect-dodge {
  color: #fff;
  background: linear-gradient(135deg, #2196f3, #1976d2);
  animation: dodgeFade 1s ease;
}
@keyframes dodgeFade {
  0% { transform: translateX(0); opacity: 0; }
  30% { transform: translateX(-10px); opacity: 1; }
  70% { transform: translateX(10px); opacity: 1; }
  100% { transform: translateX(0); opacity: 0.7; }
}
.effect-counter {
  color: #fff;
  background: linear-gradient(135deg, #9c27b0, #7b1fa2);
  box-shadow: 0 0 10px rgba(156,39,176,0.4);
}
.effect-stun {
  color: #333;
  background: linear-gradient(135deg, #ffeb3b, #fbc02d);
  box-shadow: 0 0 10px rgba(255,235,59,0.4);
}
.effect-vampire {
  color: #fff;
  background: linear-gradient(135deg, #4caf50, #388e3c);
  box-shadow: 0 0 10px rgba(76,175,80,0.4);
}

/* 击杀特写 */
.kill-shot {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 100;
  pointer-events: none;
}
.kill-text {
  font-size: 48px;
  font-weight: 900;
  color: #ff2222;
  text-shadow: 
    0 0 20px rgba(255,34,34,0.8),
    0 0 40px rgba(255,34,34,0.5),
    4px 4px 0 #000;
  animation: killShot 1s ease;
  white-space: nowrap;
}
@keyframes killShot {
  0% { transform: scale(0) rotate(-10deg); opacity: 0; }
  30% { transform: scale(1.5) rotate(5deg); opacity: 1; }
  60% { transform: scale(1.2) rotate(-3deg); }
  100% { transform: scale(1) rotate(0); }
}

/* 战斗控制按钮 */
.battle-controls {
  margin-top: 16px;
}
'''

def main():
    with open('/opt/xiuxian/src/views/PK.vue', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. 替换template中的战斗回放部分
    # 找到 <template v-if="battleResult"> 开始的位置
    template_start = content.find('<template v-if="battleResult">')
    if template_start == -1:
        print("ERROR: 找不到 <template v-if=\"battleResult\">")
        return
    
    # 找到 返回大厅</n-button> 结束的位置
    end_marker = '返回大厅</n-button>'
    end_pos = content.find(end_marker, template_start)
    if end_pos == -1:
        print("ERROR: 找不到 返回大厅</n-button>")
        return
    end_pos += len(end_marker)
    
    # 找到这一行的结束位置（包含 </template>）
    template_end = content.find('</template>', end_pos)
    if template_end == -1:
        print("ERROR: 找不到 </template> 结束标签")
        return
    template_end += len('</template>')
    
    # 替换template部分
    new_content = content[:template_start] + NEW_BATTLE_TEMPLATE + content[template_end:]
    
    # 2. 在script setup中添加新的代码
    # 找到const battleResult = ref(null)之后的位置添加新代码
    script_insert_marker = 'const battleResult = ref(null)'
    script_insert_pos = new_content.find(script_insert_marker)
    if script_insert_pos == -1:
        print("ERROR: 找不到 const battleResult = ref(null)")
        return
    script_insert_pos += len(script_insert_marker)
    
    new_content = new_content[:script_insert_pos] + '\n\n' + NEW_SCRIPT_CODE + new_content[script_insert_pos:]
    
    # 3. 添加CSS样式到style scoped中
    style_end_marker = '</style>'
    style_end_pos = new_content.rfind(style_end_marker)
    if style_end_pos == -1:
        print("ERROR: 找不到 </style>")
        return
    
    new_content = new_content[:style_end_pos] + NEW_STYLE_CSS + '\n' + new_content[style_end_pos:]
    
    # 4. 添加computed和watch到import语句
    import_marker = "import { ref, onMounted, onUnmounted } from 'vue'"
    import_pos = new_content.find(import_marker)
    if import_pos != -1:
        new_content = new_content[:import_pos] + "import { ref, computed, onMounted, onUnmounted, watch } from 'vue'" + new_content[import_pos + len(import_marker):]
    
    # 写入文件
    with open('/opt/xiuxian/src/views/PK.vue', 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print("✅ PK.vue 战斗回放改造完成！")

if __name__ == '__main__':
    main()
