import { defineStore } from 'pinia'

export const useGameConfigStore = defineStore('gameConfig', {
  state: () => ({
    loaded: false,
    realms: [],
    locations: [],
    equipment: { slots: [], slotNames: {}, qualities: [] },
    herbs: { qualities: {}, types: [], tiers: {} },
    pills: [],
    dungeonBuffs: [],
    vipConfig: [],
    formulas: {},
    version: 0
  }),
  actions: {
    async loadConfig() {
      if (this.loaded) return
      try {
        const res = await fetch('/api/game/config')
        if (!res.ok) throw new Error('HTTP ' + res.status)
        const data = await res.json()
        this.realms = data.realms || []
        this.locations = data.locations || []
        this.equipment = data.equipment || this.equipment
        this.herbs = data.herbs || this.herbs
        this.pills = data.pills || []
        this.dungeonBuffs = data.dungeonBuffs || []
        this.vipConfig = data.vipConfig || []
        this.formulas = data.formulas || {}
        this.version = data.version || 0
        this.loaded = true
      } catch (e) {
        console.error('加载游戏配置失败:', e)
      }
    },
    // 根据等级获取境界信息
    getRealmByLevel(level) {
      if (level < 1) return this.realms[0] || { name: '燃火一重', maxCultivation: 100 }
      if (level > this.realms.length) return this.realms[this.realms.length - 1]
      return this.realms[level - 1]
    },
    // 根据等级计算数值
    getMaxSpirit(level) { return 200 + level * 100 },
    getSpiritRegen(level) { return 2 + level * 0.5 },
    getCultivationCost(level) { return 5 + level * 3 },
    getCultivationGain(level) { return Math.max(1, Math.floor(level * 2)) },
    getBreakthroughReward(level) { return 100 * level },
    // 获取VIP配置
    getVipBoost(vipLevel) {
      return this.vipConfig[Math.min(vipLevel, this.vipConfig.length - 1)] || this.vipConfig[0]
    }
  }
})
