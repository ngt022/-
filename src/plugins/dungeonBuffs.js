// 副本增益效果管理器
const dungeonBuffs = {
  // 存储当前应用的增益效果
  activeBuffs: [],
  // 应用增益效果
  apply(player, option) {
    // 添加到活跃增益列表
    this.activeBuffs.push({
      id: option.id,
      name: option.name,
      effect: option.effect
    })
    // 应用效果
    if (typeof option.effect === 'function') {
      option.effect(player)
    }
  },
  // 清除所有增益效果
  clear(player) {
    // 只清空活跃增益列表，不修改玩家属性
    // buff 是应用在战斗实体上的临时效果，不应该重置玩家 store 的属性
    this.activeBuffs = []
  },
  // 获取当前活跃的增益效果
  getActiveBuffs() {
    return this.activeBuffs
  }
}

export default dungeonBuffs
