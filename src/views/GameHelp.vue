<template>
  <div class="game-help">
    <!-- 顶部返回按钮 -->
    <div class="header">
      <n-button
        type="primary"
        class="back-btn"
        @click="navigateTo('home')"
      >
        <template #icon>
          <span class="back-icon">←</span>
        </template>
        返回
      </n-button>
      <h1 class="page-title">📖 游戏帮助</h1>
    </div>

    <!-- 折叠面板内容 -->
    <div class="content-wrapper">
      <n-collapse :accordion="false" class="help-collapse">
        
        <!-- 1. 游戏简介 -->
        <n-collapse-item name="intro">
          <template #header>
            <span class="section-title">🔥 游戏简介</span>
          </template>
          <div class="section-content">
            <p><strong>世界观：</strong>远古时代，焰灵是万物之源。修炼者通过吸收焰灵提升境界，最终飞升成神。</p>
            <p><strong>核心玩法：</strong>修炼 → 装备 → 探索 → 战斗 → 社交</p>
            <p><strong>货币系统：</strong></p>
            <ul>
              <li><span class="currency-spirit">焰灵</span> - 修炼用资源</li>
              <li><span class="currency-stone">焰晶</span> - 通用货币</li>
              <li><span class="currency-quench">淬火石</span> - 强化装备材料</li>
            </ul>
          </div>
        </n-collapse-item>

        <!-- 2. 修炼系统 -->
        <n-collapse-item name="cultivation">
          <template #header>
            <span class="section-title">⚔️ 修炼系统</span>
          </template>
          <div class="section-content">
            <p>• 点击<strong>冥想</strong>消耗焰灵积累焰修</p>
            <p>• 焰修满后可<strong>突破</strong>到下一境界</p>
            <p>• 境界提升增加基础属性：攻击 / 防御 / 生命 / 速度</p>
            <p>• <strong>VIP</strong>和<strong>月卡</strong>可加速修炼速度</p>
            <p>• 离线也有收益（<strong>离线焰灵奖励</strong>）</p>
          </div>
        </n-collapse-item>

        <!-- 3. 装备系统 -->
        <n-collapse-item name="equipment">
          <template #header>
            <span class="section-title">🎒 装备系统</span>
          </template>
          <div class="section-content">
            <p><strong>13个装备槽位：</strong></p>
            <p class="slots-list">焰杖 / 头部 / 衣服 / 裤子 / 鞋子 / 肩甲 / 手套 / 护腕 / 焰心链 / 符文戒×2 / 腰带 / 焰器</p>
            
            <p><strong>7个品质等级：</strong></p>
            <div class="quality-list">
              <span class="quality common">凡品(灰)</span> →
              <span class="quality uncommon">下品(绿)</span> →
              <span class="quality rare">中品(蓝)</span> →
              <span class="quality epic">上品(紫)</span> →
              <span class="quality legendary">极品(橙)</span> →
              <span class="quality mythic">仙品(粉)</span> →
              <span class="quality divine">神品(红)</span>
            </div>
            
            <p>• <span class="quality divine">神品装备</span>全服限量50件/槽位，带唯一编号</p>
            <p>• <strong>淬火强化：</strong>消耗淬火石提升装备属性，每次+10%</p>
            <p>• 属性类型：<strong>固定属性</strong>(攻防血速) + <strong>百分比属性</strong>(暴击/闪避/吸血等)</p>
          </div>
        </n-collapse-item>

        <!-- 4. 焰兽系统 -->
        <n-collapse-item name="pets">
          <template #header>
            <span class="section-title">🐾 焰兽系统</span>
          </template>
          <div class="section-content">
            <p><strong>5个稀有度：</strong>凡品 → 灵品 → 玄品 → 仙品 → 神品</p>
            
            <p><strong class="quality divine">神品焰兽：</strong></p>
            <p>四大神兽：青龙 / 白虎 / 朱雀 / 玄武 + 上古凶兽</p>
            
            <p><strong class="quality mythic">仙品焰兽：</strong></p>
            <p>龙生九子系列</p>
            
            <p>• 出战焰兽提供<strong>属性加成</strong></p>
            <p>• 消耗<strong>精华</strong>升级焰兽</p>
          </div>
        </n-collapse-item>

        <!-- 5. 焰运阁 -->
        <n-collapse-item name="gacha">
          <template #header>
            <span class="section-title">🎰 焰运阁（抽卡）</span>
          </template>
          <div class="section-content">
            <p><strong>抽卡类型：</strong>单抽 / 十连 / 心愿抽卡</p>
            
            <p><strong>装备概率：</strong></p>
            <div class="gacha-rates">
              <p><span class="quality common">凡品 49.8%</span></p>
              <p><span class="quality uncommon">下品 30%</span></p>
              <p><span class="quality rare">中品 12%</span></p>
              <p><span class="quality epic">上品 5%</span></p>
              <p><span class="quality legendary">极品 2%</span></p>
              <p><span class="quality mythic">仙品 1%</span></p>
              <p><span class="quality divine">神品 0.2%</span> ⭐</p>
            </div>
            
            <p>• <strong>保底机制：</strong>连续多次不出高品质会触发保底</p>
            <p>• <strong>费用递增：</strong>300→500→800→1200→1800 焰晶</p>
            <p>• 支持<strong>自动出售</strong> / <strong>自动放生</strong>设置</p>
          </div>
        </n-collapse-item>

        <!-- 6. 探索系统 -->
        <n-collapse-item name="exploration">
          <template #header>
            <span class="section-title">🗺️ 探索系统</span>
          </template>
          <div class="section-content">
            <p><strong>9张地图：</strong></p>
            <div class="maps-list">
              <p>1. 薪火村 (Lv.1)</p>
              <p>2. 赤霄峰</p>
              <p>3. 涅槃谷</p>
              <p>4. 焰渊</p>
              <p>5. 焰天圣域</p>
              <p>6. 焰虚秘境 (Lv.46)</p>
              <p>7. 焰合禁地 (Lv.55)</p>
              <p>8. 大焰天宫 (Lv.73)</p>
              <p>9. 渡焰圣殿 (Lv.91)</p>
            </div>
            <p>• 消耗<strong>焰灵</strong>探索，随机事件和奖励</p>
            <p>• 等级越高解锁越多地图</p>
          </div>
        </n-collapse-item>

        <!-- 7. 焚天塔 -->
        <n-collapse-item name="tower">
          <template #header>
            <span class="section-title">🏔️ 焚天塔（每日副本）</span>
          </template>
          <div class="section-content">
            <p>• 每日<strong>挑战次数限制</strong></p>
            <p>• <strong>难度倍率选择：</strong>高倍率 = 高奖励</p>
            <p>• 掉落：<span class="currency-stone">焰晶</span> / <span class="currency-quench">淬火石</span> / 装备</p>
          </div>
        </n-collapse-item>

        <!-- 8. 竞技场 -->
        <n-collapse-item name="arena">
          <template #header>
            <span class="section-title">🏟️ 竞技场</span>
          </template>
          <div class="section-content">
            <p>• <strong>异步PvP</strong>，挑战其他玩家</p>
            <p>• 每日<strong>5次免费</strong>，之后 200 焰晶/次</p>
            <p>• <strong>段位系统：</strong>铜 → 银 → 金 → 钻 → 皇</p>
            <p>• <strong>赛季制</strong>，每月结算发奖</p>
            <p>• 战报回放，复仇系统</p>
          </div>
        </n-collapse-item>

        <!-- 9. 焰炼 -->
        <n-collapse-item name="alchemy">
          <template #header>
            <span class="section-title">🧪 焰炼（炼丹）</span>
          </template>
          <div class="section-content">
            <p>• 收集<strong>焰草</strong>和<strong>丹方碎片</strong></p>
            <p>• 合成丹方后可<strong>炼制丹药</strong></p>
            <p>• 丹药提供<strong>临时/永久</strong>属性加成</p>
            <p>• 品级越高效果越强</p>
          </div>
        </n-collapse-item>

        <!-- 10. 焰盟 -->
        <n-collapse-item name="guild">
          <template #header>
            <span class="section-title">🏛️ 焰盟（宗门）</span>
          </template>
          <div class="section-content">
            <p>• <strong>创建</strong>或<strong>加入</strong>焰盟</p>
            <p>• <strong>捐献焰晶</strong>提升焰盟等级</p>
            <p>• <strong>宗门战：</strong>焰盟间对抗</p>
          </div>
        </n-collapse-item>

        <!-- 11. 焰灵游坊 -->
        <n-collapse-item name="minigames">
          <template #header>
            <span class="section-title">🎮 焰灵游坊</span>
          </template>
          <div class="section-content">
            <p><strong>6个小游戏：</strong></p>
            <ul>
              <li>🔥 焰灵试炼</li>
              <li>🔗 焰符连连看</li>
              <li>🐍 焰蛇吞噬</li>
              <li>🧩 五行拼图</li>
              <li>🎡 焰灵转盘</li>
              <li>🃏 焰灵接龙</li>
            </ul>
            <p>• 每日<strong>限玩次数</strong>，赢取焰晶奖励</p>
          </div>
        </n-collapse-item>

        <!-- 12. 商城与VIP -->
        <n-collapse-item name="shop">
          <template #header>
            <span class="section-title">🛒 商城与VIP</span>
          </template>
          <div class="section-content">
            <p><strong>商城：</strong>礼包 / 道具 / 改名卡</p>
            
            <p><strong>VIP等级：</strong>提升修炼速度、抽卡概率等</p>
            
            <p><strong>月卡(薪火令)：</strong></p>
            <ul>
              <li>每日 5000 <span class="currency-stone">焰晶</span></li>
              <li>冥想加速 +20%</li>
              <li>每日免费单抽</li>
            </ul>
          </div>
        </n-collapse-item>

        <!-- 13. 排行榜 -->
        <n-collapse-item name="ranking">
          <template #header>
            <span class="section-title">📊 排行榜</span>
          </template>
          <div class="section-content">
            <p><strong>实时排行：</strong>战力 / 等级 / 焰晶</p>
            
            <p><strong>月度荣耀（五榜）：</strong></p>
            <ul>
              <li>🏆 战力榜 - 奖 <strong>ROON</strong></li>
              <li>⚔️ 天梯榜 - 奖 <span class="currency-stone">焰晶</span></li>
              <li>📈 等级榜 - 奖 <span class="currency-stone">焰晶</span></li>
              <li>💰 消费榜 - 奖 <span class="currency-stone">焰晶</span></li>
              <li>🎮 游戏榜 - 奖 <span class="currency-stone">焰晶</span></li>
            </ul>
          </div>
        </n-collapse-item>

        <!-- 14. 新手FAQ -->
        <n-collapse-item name="faq">
          <template #header>
            <span class="section-title">💡 新手FAQ</span>
          </template>
          <div class="section-content">
            <div class="faq-item">
              <p class="question">Q: 怎么快速变强？</p>
              <p class="answer">A: 每日修炼 + 抽卡 + 强化装备 + 出战焰兽</p>
            </div>
            
            <div class="faq-item">
              <p class="question">Q: 焰晶怎么获取？</p>
              <p class="answer">A: 探索 / 副本 / 小游戏 / 竞技场 / 排行榜奖励</p>
            </div>
            
            <div class="faq-item">
              <p class="question">Q: 神品装备怎么获得？</p>
              <p class="answer">A: 焰运阁抽卡，0.2%概率，全服限量</p>
            </div>
            
            <div class="faq-item">
              <p class="question">Q: 怎么加入焰盟？</p>
              <p class="answer">A: 社交菜单 → 焰盟，搜索或创建</p>
            </div>
          </div>
        </n-collapse-item>

      </n-collapse>
    </div>

    <!-- 底部重置按钮 -->
    <div class="footer">
      <n-button
        type="warning"
        ghost
        class="reset-btn"
        @click="resetGuides"
      >
        🔄 重置新手引导
      </n-button>
    </div>
  </div>
</template>

<script setup>
import { inject } from 'vue'
import { NCollapse, NCollapseItem, NButton } from 'naive-ui'

// 导航函数
const navigateTo = inject('navigateTo', (route) => {
  console.log('Navigate to:', route)
})

// 重置新手引导
const resetGuides = () => {
  // 清除本地存储中的引导完成标记
  localStorage.removeItem('guideCompleted')
  localStorage.removeItem('guideStep')
  
  // 可以触发一个事件通知父组件
  window.location.reload()
}
</script>

<style scoped>
.game-help {
  min-height: 100vh;
  background: linear-gradient(180deg, #0b0b18 0%, #12101f 100%);
  padding: 16px;
  color: #b8a888;
}

/* 顶部区域 */
.header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(212, 168, 67, 0.2);
}

.back-btn {
  background: linear-gradient(135deg, #ff6b35 0%, #d4a843 100%);
  border: none;
  color: #0b0b18;
  font-weight: bold;
}

.back-btn:hover {
  opacity: 0.9;
  transform: scale(1.02);
}

.back-icon {
  font-size: 16px;
  margin-right: 4px;
}

.page-title {
  font-size: 24px;
  font-weight: bold;
  color: #d4a843;
  margin: 0;
  text-shadow: 0 0 20px rgba(212, 168, 67, 0.3);
}

/* 内容区域 */
.content-wrapper {
  margin-bottom: 20px;
}

/* 折叠面板样式 */
.help-collapse {
  background: transparent;
}

.help-collapse :deep(.n-collapse-item) {
  margin-bottom: 8px;
  background: rgba(18, 16, 31, 0.6);
  border: 1px solid rgba(212, 168, 67, 0.15);
  border-radius: 12px;
  overflow: hidden;
}

.help-collapse :deep(.n-collapse-item-header) {
  padding: 16px;
  background: linear-gradient(90deg, rgba(255, 107, 53, 0.1) 0%, rgba(212, 168, 67, 0.05) 100%);
}

.help-collapse :deep(.n-collapse-item-header__main) {
  color: #d4a843;
  font-size: 16px;
  font-weight: 600;
}

.help-collapse :deep(.n-collapse-item__content-wrapper) {
  background: rgba(11, 11, 24, 0.4);
}

.help-collapse :deep(.n-collapse-item__content-inner) {
  padding: 16px;
}

/* 章节标题 */
.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #d4a843;
}

/* 章节内容 */
.section-content {
  color: #b8a888;
  line-height: 1.8;
  font-size: 14px;
}

.section-content p {
  margin: 8px 0;
}

.section-content ul {
  margin: 8px 0;
  padding-left: 20px;
}

.section-content li {
  margin: 4px 0;
}

.section-content strong {
  color: #d4a843;
  font-weight: 600;
}

/* 货币颜色 */
.currency-spirit {
  color: #ff6b35;
  font-weight: 600;
}

.currency-stone {
  color: #d4a843;
  font-weight: 600;
}

.currency-quench {
  color: #9d7ed5;
  font-weight: 600;
}

/* 品质颜色 */
.quality {
  font-weight: 600;
}

.quality.common {
  color: #9e9e9e;
}

.quality.uncommon {
  color: #4caf50;
}

.quality.rare {
  color: #2196f3;
}

.quality.epic {
  color: #9c27b0;
}

.quality.legendary {
  color: #ff9800;
}

.quality.mythic {
  color: #e91e63;
}

.quality.divine {
  color: #f44336;
  text-shadow: 0 0 8px rgba(244, 67, 54, 0.4);
}

/* 品质列表 */
.quality-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  align-items: center;
  margin: 8px 0;
  font-size: 13px;
}

/* 装备槽位 */
.slots-list {
  font-size: 13px;
  line-height: 1.6;
  opacity: 0.9;
}

/* 抽卡概率 */
.gacha-rates {
  background: rgba(0, 0, 0, 0.2);
  padding: 12px;
  border-radius: 8px;
  margin: 8px 0;
}

.gacha-rates p {
  margin: 4px 0;
}

/* 地图列表 */
.maps-list {
  background: rgba(0, 0, 0, 0.2);
  padding: 12px;
  border-radius: 8px;
  margin: 8px 0;
}

.maps-list p {
  margin: 4px 0;
  font-size: 13px;
}

/* FAQ样式 */
.faq-item {
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(212, 168, 67, 0.1);
}

.faq-item:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.question {
  color: #ff6b35;
  font-weight: 600;
  margin-bottom: 4px;
}

.answer {
  color: #b8a888;
  padding-left: 12px;
  border-left: 2px solid #d4a843;
}

/* 底部区域 */
.footer {
  display: flex;
  justify-content: center;
  padding-top: 16px;
  border-top: 1px solid rgba(212, 168, 67, 0.2);
}

.reset-btn {
  border-color: #ff6b35;
  color: #ff6b35;
}

.reset-btn:hover {
  background: rgba(255, 107, 53, 0.1);
  border-color: #ff6b35;
  color: #ff6b35;
}

/* 响应式 */
@media (max-width: 480px) {
  .game-help {
    padding: 12px;
  }
  
  .page-title {
    font-size: 20px;
  }
  
  .section-title {
    font-size: 15px;
  }
  
  .quality-list {
    font-size: 12px;
  }
}
</style>
