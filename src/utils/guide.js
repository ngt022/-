const GUIDE_KEY = 'xx_guide_seen'

export function hasSeenGuide(page) {
  try {
    const seen = JSON.parse(localStorage.getItem(GUIDE_KEY) || '{}')
    return !!seen[page]
  } catch { return false }
}

export function markGuideSeen(page) {
  try {
    const seen = JSON.parse(localStorage.getItem(GUIDE_KEY) || '{}')
    seen[page] = Date.now()
    localStorage.setItem(GUIDE_KEY, JSON.stringify(seen))
  } catch {}
}

export function resetGuides() {
  localStorage.removeItem(GUIDE_KEY)
}

// 各页面引导文案
export const guideTexts = {
  home: { title: '🏠 欢迎来到主城', text: '这里是你的大本营。可以查看资源、快捷进入各功能，底部导航切换不同分类。' },
  cultivation: { title: '⚔️ 修炼系统', text: '点击"开始冥想"积累焰力，焰力满后自动突破境界。VIP等级越高，修炼速度越快！' },
  inventory: { title: '🎒 背包管理', text: '装备、丹药、焰草都在这里。长按装备可查看详情，点击穿戴/使用。支持一键卖出低品质装备。' },
  dungeon: { title: '🏔️ 焚天塔', text: '挑战层层怪物，越高层奖励越丰厚。选择难度倍率可获得更多奖励，但怪物也更强！' },
  gacha: { title: '🎰 焰运阁', text: '消耗焰晶抽取装备和焰兽。十连抽保底出紫色品质以上！VIP等级提升概率。' },
  exploration: { title: '🗺️ 探索系统', text: '消耗焰灵探索不同区域，可获得焰晶、焰草和随机事件奖励。等级越高解锁越多区域。' },
  sect: { title: '🏛️ 焰盟', text: '加入或创建焰盟，与盟友一起成长。捐献焰晶提升焰盟等级，解锁更多福利。' },
  alchemy: { title: '🧪 焰炼', text: '收集焰草和丹方碎片，炼制各种丹药。丹药可提升属性、加速修炼。品级越高效果越强。' },
}
