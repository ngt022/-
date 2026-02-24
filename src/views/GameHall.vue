<template>
  <div class="game-hall">
    <h2 class="hall-title">🎮 焰灵游坊</h2>
    <p class="hall-desc">每日挑战小游戏，赢取焰晶奖励！</p>
    <div class="game-grid">
      <div v-for="game in games" :key="game.key" class="game-card" @click="navigateTo(game.key)">
        <div class="game-icon">{{ game.icon }}</div>
        <div class="game-name">{{ game.name }}</div>
        <div class="game-desc">{{ game.desc }}</div>
        <div class="game-reward">💎 {{ game.reward }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { inject } from 'vue'

const navigateTo = inject('navigateTo')

const games = [
  { key: 'minigame', icon: '🔥', name: '焰灵试炼', desc: '限时点击火焰符文', reward: '50-500焰晶' },
  { key: 'match-game', icon: '🎯', name: '焰符连连看', desc: '翻牌配对消除符文', reward: '50-500焰晶' },
  { key: 'snake-game', icon: '🐍', name: '焰蛇吞噬', desc: '控制焰蛇吃焰灵', reward: '50-500焰晶' },
  { key: 'puzzle-game', icon: '🧩', name: '五行拼图', desc: '滑动还原五行阵法', reward: '50-500焰晶' },
  { key: 'wheel-game', icon: '🎰', name: '焰灵转盘', desc: '每日免费转一次', reward: '50-1000焰晶' },
  { key: 'catch-game', icon: '⚡', name: '焰灵接龙', desc: '接住掉落的焰灵', reward: '50-500焰晶' },
]
</script>

<style scoped>
.game-hall { max-width: 500px; margin: 0 auto; padding: 16px; }
.hall-title { text-align: center; color: #ffd700; font-size: 24px; margin-bottom: 4px; }
.hall-desc { text-align: center; color: #a08030; font-size: 14px; margin-bottom: 20px; }
.game-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
.game-card {
  background: linear-gradient(145deg, rgba(212,168,67,0.1), rgba(139,32,0,0.1));
  border: 1px solid rgba(212,168,67,0.3);
  border-radius: 14px;
  padding: 16px 12px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
}
.game-card:active { transform: scale(0.96); background: rgba(212,168,67,0.15); }
.game-icon { font-size: 40px; margin-bottom: 8px; }
.game-name { color: #ffd700; font-size: 16px; font-weight: bold; margin-bottom: 4px; }
.game-desc { color: #a08030; font-size: 12px; margin-bottom: 8px; }
.game-reward { color: #d4a843; font-size: 13px; font-weight: bold; }
@media (max-width: 360px) {
  .game-grid { grid-template-columns: repeat(2, 1fr); gap: 8px; }
  .game-card { padding: 12px 8px; }
  .game-icon { font-size: 32px; }
}
</style>
