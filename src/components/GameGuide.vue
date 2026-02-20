<template>
  <n-collapse class="game-guide" style="margin-bottom:12px">
    <n-collapse-item title="📖 玩法说明" name="guide">
      <div class="guide-content">
        <slot />
      </div>
    </n-collapse-item>
  </n-collapse>
</template>

<script setup>
</script>

<style scoped>
.game-guide {
  --n-title-text-color: #d4a843 !important;
  --n-font-size: 14px;
}
.game-guide :deep(.n-collapse-item__header) {
  background: linear-gradient(90deg, rgba(30,25,18,0.95), rgba(40,32,20,0.8));
  border: 1px solid rgba(212,168,67,0.3);
  border-radius: 6px;
  padding: 8px 14px !important;
}
.game-guide :deep(.n-collapse-item__content-inner) {
  background: rgba(20,18,14,0.9);
  border: 1px solid rgba(212,168,67,0.15);
  border-top: none;
  border-radius: 0 0 6px 6px;
  padding: 12px 14px !important;
}
.guide-content {
  font-size: 13px;
  color: #b8a888;
  line-height: 1.8;
}
.guide-content :deep(p) {
  margin: 4px 0;
}
.guide-content :deep(strong) {
  color: #d4a843;
}
</style>
