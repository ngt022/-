<template>
  <div class="home-wrapper">
    <!-- 浮动光点 -->
    <div class="particles">
      <span v-for="i in 12" :key="i" class="particle" :style="particleStyle(i)"></span>
    </div>

    <div class="home-content">
      <div class="logo-section">
        <div class="logo-glow"></div>
        <h1 class="game-title">我的放置焰途</h1>
        <p class="game-subtitle">踏入修焰之路，逆天改命</p>
        <div class="title-divider">
          <span class="divider-wing">✦</span>
          <span class="divider-line"></span>
          <span class="divider-gem">◆</span>
          <span class="divider-line"></span>
          <span class="divider-wing">✦</span>
        </div>
      </div>

      <!-- 公告区域预留 -->
      <div class="announcement-area" v-if="false">
        <!-- 后续公告系统用 -->
      </div>

      <div class="action-section">
        <n-space vertical align="center" :size="16">
          <n-button
            v-if="playerStore.isNewPlayer"
            class="gift-btn"
            type="warning"
            size="large"
            @click="receiveNewPlayerGift"
          >
            🎁 领取新手礼包
          </n-button>
          <n-button
            v-else
            class="enter-btn"
            type="primary"
            size="large"
            @click="router.push('/cultivation')"
          >
            ⚔️ 开始冥想
          </n-button>
        </n-space>
      </div>

      <div class="home-footer">
        <span class="version">v1.0.5</span>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { usePlayerStore } from '../stores/player'
  import { useMessage } from 'naive-ui'
  import { useRouter } from 'vue-router'
  const router = useRouter()
  const playerStore = usePlayerStore()
  const message = useMessage()

  const receiveNewPlayerGift = () => {
    playerStore.spiritStones += 20000
    playerStore.isNewPlayer = false
    router.push('/cultivation')
    message.success('获得20000焰晶')
    message.success('新手礼包领取成功')
  }

  const particleStyle = (i) => ({
    left: `${(i * 17 + 5) % 100}%`,
    animationDelay: `${(i * 0.7) % 5}s`,
    animationDuration: `${4 + (i % 4) * 2}s`,
    width: `${3 + (i % 3) * 2}px`,
    height: `${3 + (i % 3) * 2}px`,
    opacity: 0.3 + (i % 4) * 0.15,
  })
</script>

<style scoped>
  .home-wrapper {
    position: relative;
    min-height: 70vh;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    background:
      radial-gradient(ellipse at 50% 0%, rgba(212,168,67,0.08) 0%, transparent 60%),
      radial-gradient(ellipse at 20% 80%, rgba(120,80,200,0.05) 0%, transparent 50%),
      radial-gradient(ellipse at 80% 80%, rgba(212,168,67,0.04) 0%, transparent 50%);
  }

  /* 浮动光点 */
  .particles {
    position: absolute;
    inset: 0;
    pointer-events: none;
  }
  .particle {
    position: absolute;
    bottom: -10px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(212,168,67,0.8), rgba(212,168,67,0));
    animation: float-up linear infinite;
  }
  @keyframes float-up {
    0% { transform: translateY(0) scale(1); opacity: 0; }
    10% { opacity: var(--particle-opacity, 0.5); }
    90% { opacity: var(--particle-opacity, 0.5); }
    100% { transform: translateY(-70vh) scale(0.3); opacity: 0; }
  }

  /* Logo 区域 */
  .home-content {
    position: relative;
    z-index: 1;
    text-align: center;
    padding: 2rem;
  }

  .logo-section {
    position: relative;
    margin-bottom: 2rem;
  }

  .logo-glow {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 300px;
    height: 300px;
    border-radius: 50%;
    background: radial-gradient(circle, rgba(212,168,67,0.12) 0%, transparent 70%);
    animation: pulse-glow 4s ease-in-out infinite;
  }
  @keyframes pulse-glow {
    0%, 100% { transform: translate(-50%, -50%) scale(1); opacity: 0.6; }
    50% { transform: translate(-50%, -50%) scale(1.2); opacity: 1; }
  }

  .game-title {
    font-family: 'Noto Serif SC', serif;
    font-size: 2.8rem;
    font-weight: 900;
    background: linear-gradient(180deg, #f0d68a 0%, #d4a843 40%, #b8860b 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    text-shadow: none;
    filter: drop-shadow(0 0 20px rgba(212,168,67,0.4)) drop-shadow(0 0 40px rgba(212,168,67,0.2));
    margin: 0;
    position: relative;
  }

  .game-subtitle {
    font-family: 'Noto Serif SC', serif;
    font-size: 1.1rem;
    color: #a09880;
    margin-top: 0.5rem;
    letter-spacing: 0.3em;
  }

  /* 分割线装饰 */
  .title-divider {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    margin-top: 1.2rem;
    color: rgba(212,168,67,0.4);
    font-size: 0.7rem;
  }
  .divider-line {
    width: 60px;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(212,168,67,0.4), transparent);
  }
  .divider-gem {
    color: rgba(212,168,67,0.6);
    font-size: 0.6rem;
    animation: gem-pulse 3s ease-in-out infinite;
  }
  @keyframes gem-pulse {
    0%, 100% { opacity: 0.4; }
    50% { opacity: 1; color: #d4a843; }
  }

  /* 按钮区域 */
  .action-section {
    margin-top: 2rem;
  }

  .gift-btn :deep(.n-button__content) {
    font-size: 1.1rem;
    font-weight: bold;
  }
  .gift-btn {
    padding: 0 2.5rem !important;
    height: 48px !important;
    background: linear-gradient(135deg, #b8860b, #d4a843, #f0d68a, #d4a843) !important;
    border: none !important;
    color: #1a1000 !important;
    box-shadow: 0 0 20px rgba(212,168,67,0.3), inset 0 1px 0 rgba(255,255,255,0.2) !important;
    animation: gift-glow 2s ease-in-out infinite;
  }
  @keyframes gift-glow {
    0%, 100% { box-shadow: 0 0 20px rgba(212,168,67,0.3); }
    50% { box-shadow: 0 0 30px rgba(212,168,67,0.6), 0 0 60px rgba(212,168,67,0.2); }
  }

  .enter-btn {
    padding: 0 2.5rem !important;
    height: 48px !important;
  }

  /* 底部 */
  .home-footer {
    margin-top: 3rem;
  }
  .version {
    color: rgba(160,152,128,0.3);
    font-size: 0.75rem;
  }
</style>
