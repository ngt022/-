<template>
  <div class="skeleton-loader" :class="`skeleton-${type}`">
    <!-- List 类型: 4-5行条目骨架 -->
    <template v-if="type === 'list'">
      <div v-for="i in 5" :key="i" class="skeleton-list-item">
        <div class="skeleton-block skeleton-icon"></div>
        <div class="skeleton-list-content">
          <div class="skeleton-block skeleton-title"></div>
          <div class="skeleton-block skeleton-text"></div>
        </div>
        <div class="skeleton-block skeleton-action"></div>
      </div>
    </template>

    <!-- Grid 类型: 3x3 方格骨架 -->
    <template v-if="type === 'grid'">
      <div class="skeleton-grid">
        <div v-for="i in 9" :key="i" class="skeleton-grid-item">
          <div class="skeleton-block skeleton-grid-icon"></div>
          <div class="skeleton-block skeleton-grid-title"></div>
          <div class="skeleton-block skeleton-grid-text"></div>
        </div>
      </div>
    </template>

    <!-- Detail 类型: 头像+标题+段落骨架 -->
    <template v-if="type === 'detail'">
      <div class="skeleton-detail">
        <div class="skeleton-detail-header">
          <div class="skeleton-block skeleton-avatar"></div>
          <div class="skeleton-detail-info">
            <div class="skeleton-block skeleton-detail-title"></div>
            <div class="skeleton-block skeleton-detail-subtitle"></div>
          </div>
        </div>
        <div class="skeleton-detail-body">
          <div v-for="i in 4" :key="i" class="skeleton-block skeleton-paragraph"></div>
        </div>
      </div>
    </template>

    <!-- Cultivation 类型: 圆形进度+数值骨架 -->
    <template v-if="type === 'cultivation'">
      <div class="skeleton-cultivation">
        <div class="skeleton-cultivation-main">
          <div class="skeleton-block skeleton-circle"></div>
          <div class="skeleton-cultivation-stats">
            <div class="skeleton-block skeleton-stat-title"></div>
            <div class="skeleton-block skeleton-stat-value"></div>
            <div class="skeleton-block skeleton-stat-bar"></div>
          </div>
        </div>
        <div class="skeleton-cultivation-row">
          <div v-for="i in 3" :key="i" class="skeleton-cultivation-card">
            <div class="skeleton-block skeleton-card-icon"></div>
            <div class="skeleton-block skeleton-card-value"></div>
            <div class="skeleton-block skeleton-card-label"></div>
          </div>
        </div>
      </div>
    </template>

    <!-- Shop 类型: 3列商品卡片骨架 -->
    <template v-if="type === 'shop'">
      <div class="skeleton-shop">
        <div class="skeleton-shop-header">
          <div class="skeleton-block skeleton-shop-title"></div>
          <div class="skeleton-block skeleton-shop-filter"></div>
        </div>
        <div class="skeleton-shop-grid">
          <div v-for="i in 6" :key="i" class="skeleton-shop-card">
            <div class="skeleton-block skeleton-shop-image"></div>
            <div class="skeleton-shop-info">
              <div class="skeleton-block skeleton-shop-name"></div>
              <div class="skeleton-block skeleton-shop-desc"></div>
              <div class="skeleton-shop-footer">
                <div class="skeleton-block skeleton-shop-price"></div>
                <div class="skeleton-block skeleton-shop-btn"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
defineProps({
  type: {
    type: String,
    default: 'list',
    validator: (value) => ['list', 'grid', 'detail', 'cultivation', 'shop'].includes(value)
  }
})
</script>

<style scoped>
.skeleton-loader {
  width: 100%;
  padding: 16px;
  background: #1a1a2e;
  min-height: 300px;
}

/* 基础 shimmer 效果 */
.skeleton-block {
  background: linear-gradient(
    90deg,
    rgba(45, 45, 70, 0.8) 0%,
    rgba(45, 45, 70, 0.8) 40%,
    rgba(212, 168, 67, 0.15) 50%,
    rgba(45, 45, 70, 0.8) 60%,
    rgba(45, 45, 70, 0.8) 100%
  );
  background-size: 200% 100%;
  border-radius: 8px;
  animation: shimmer 1.5s ease-in-out infinite;
}

@keyframes shimmer {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

/* ===== List 类型 ===== */
.skeleton-list-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 0;
  border-bottom: 1px solid rgba(212, 168, 67, 0.1);
}

.skeleton-list-item:last-child {
  border-bottom: none;
}

.skeleton-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  flex-shrink: 0;
}

.skeleton-list-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.skeleton-title {
  height: 16px;
  width: 60%;
  border-radius: 4px;
}

.skeleton-text {
  height: 12px;
  width: 40%;
  border-radius: 4px;
}

.skeleton-action {
  width: 60px;
  height: 28px;
  border-radius: 14px;
  flex-shrink: 0;
}

/* ===== Grid 类型 ===== */
.skeleton-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.skeleton-grid-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px 12px;
  background: rgba(45, 45, 70, 0.3);
  border-radius: 12px;
  border: 1px solid rgba(212, 168, 67, 0.1);
}

.skeleton-grid-icon {
  width: 48px;
  height: 48px;
  border-radius: 50%;
}

.skeleton-grid-title {
  height: 14px;
  width: 70%;
  border-radius: 4px;
}

.skeleton-grid-text {
  height: 10px;
  width: 50%;
  border-radius: 4px;
}

/* ===== Detail 类型 ===== */
.skeleton-detail {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.skeleton-detail-header {
  display: flex;
  gap: 16px;
  align-items: center;
}

.skeleton-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  flex-shrink: 0;
}

.skeleton-detail-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.skeleton-detail-title {
  height: 20px;
  width: 50%;
  border-radius: 4px;
}

.skeleton-detail-subtitle {
  height: 14px;
  width: 30%;
  border-radius: 4px;
}

.skeleton-detail-body {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.skeleton-paragraph {
  height: 12px;
  width: 100%;
  border-radius: 4px;
}

.skeleton-paragraph:nth-child(2) {
  width: 85%;
}

.skeleton-paragraph:nth-child(3) {
  width: 70%;
}

.skeleton-paragraph:nth-child(4) {
  width: 90%;
}

/* ===== Cultivation 类型 ===== */
.skeleton-cultivation {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.skeleton-cultivation-main {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: rgba(45, 45, 70, 0.3);
  border-radius: 16px;
  border: 1px solid rgba(212, 168, 67, 0.15);
}

.skeleton-circle {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  flex-shrink: 0;
}

.skeleton-cultivation-stats {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.skeleton-stat-title {
  height: 16px;
  width: 40%;
  border-radius: 4px;
}

.skeleton-stat-value {
  height: 24px;
  width: 60%;
  border-radius: 4px;
}

.skeleton-stat-bar {
  height: 8px;
  width: 100%;
  border-radius: 4px;
}

.skeleton-cultivation-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.skeleton-cultivation-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: rgba(45, 45, 70, 0.3);
  border-radius: 12px;
  border: 1px solid rgba(212, 168, 67, 0.1);
}

.skeleton-card-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
}

.skeleton-card-value {
  height: 18px;
  width: 70%;
  border-radius: 4px;
}

.skeleton-card-label {
  height: 10px;
  width: 50%;
  border-radius: 4px;
}

/* ===== Shop 类型 ===== */
.skeleton-shop {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.skeleton-shop-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 4px;
}

.skeleton-shop-title {
  height: 20px;
  width: 100px;
  border-radius: 4px;
}

.skeleton-shop-filter {
  height: 28px;
  width: 80px;
  border-radius: 14px;
}

.skeleton-shop-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.skeleton-shop-card {
  display: flex;
  flex-direction: column;
  background: rgba(45, 45, 70, 0.3);
  border-radius: 12px;
  border: 1px solid rgba(212, 168, 67, 0.1);
  overflow: hidden;
}

.skeleton-shop-image {
  width: 100%;
  height: 80px;
  border-radius: 0;
}

.skeleton-shop-info {
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.skeleton-shop-name {
  height: 14px;
  width: 80%;
  border-radius: 4px;
}

.skeleton-shop-desc {
  height: 10px;
  width: 60%;
  border-radius: 4px;
}

.skeleton-shop-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 4px;
}

.skeleton-shop-price {
  height: 16px;
  width: 50px;
  border-radius: 4px;
}

.skeleton-shop-btn {
  height: 24px;
  width: 40px;
  border-radius: 12px;
}

/* 响应式适配 */
@media (max-width: 480px) {
  .skeleton-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .skeleton-shop-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .skeleton-cultivation-row {
    grid-template-columns: repeat(3, 1fr);
  }
  
  .skeleton-cultivation-main {
    flex-direction: column;
    text-align: center;
  }
  
  .skeleton-circle {
    width: 80px;
    height: 80px;
  }
}
</style>
