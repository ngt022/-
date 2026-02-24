import { defineStore } from 'pinia'
import { useGameConfigStore } from './gameConfig'
import { GameDB } from './db'
import { pillRecipes, tryCreatePill, calculatePillEffect } from '../plugins/pills'
import { encryptData, decryptData, validateData } from '../plugins/crypto'
import { getRealmName, getRealmLength } from '../plugins/realm'

export const usePlayerStore = defineStore('player', {
  state: () => ({
    // 是否新玩家
    isNewPlayer: true,
    // GM模式开关
    isGMMode: false,
    // 主题设置
    isDarkMode: localStorage.getItem('darkMode') === 'true',
    // 焰兽系统
    activePet: null, // 当前出战的焰兽
    petEssence: 0, // 焰兽精华
    petConfig: {
      rarityMap: {
        divine: { name: '神品', color: '#FF0000', probability: 0.02, essenceBonus: 50 },
        celestial: { name: '仙品', color: '#FFD700', probability: 0.08, essenceBonus: 30 },
        mystic: { name: '玄品', color: '#9932CC', probability: 0.15, essenceBonus: 20 },
        spiritual: { name: '灵品', color: '#1E90FF', probability: 0.25, essenceBonus: 10 },
        mortal: { name: '凡品', color: '#32CD32', probability: 0.5, essenceBonus: 5 }
      }
    },
    // 基础属性
    name: '无名焰修',
    nameChangeCount: 0, // 道号修改次数
    level: 1, // 境界等级
    realm: '燃火期一层', // 当前境界名称
    cultivation: 0, // 当前修为值
    maxCultivation: 100, // 当前境界最大修为值
    spirit: 0, // 灵力值
    spiritRate: 1, // 灵力获取倍率
    maxSpirit: 0, // 服务端下发焰灵上限
    spiritRegenRate: 0, // 服务端下发恢复速率
    cultivationCost: 0, // 服务端下发冥想消耗
    cultivationGain: 0, // 服务端下发冥想收益
    _spiritRegenTimer: null, // 焰灵恢复定时器
    luck: 1, // 幸运值
    cultivationRate: 1, // 修炼速率
    herbRate: 1, // 灵草获取倍率
    alchemyRate: 1, // 炼丹成功率加成
    // 丹药系统
    pills: [], // 丹药库存
    pillFragments: {}, // 丹方残页（key为丹方ID，value为数量）
    pillRecipes: [], // 已获得的完整丹方
    activeEffects: [], // 当前生效的丹药效果列表
    pillsCrafted: 0, // 炼制丹药次数
    pillsConsumed: 0, // 服用丹药次数
    // 基础战斗属性
    baseAttributes: {
      attack: 10, // 攻击
      health: 100, // 生命
      defense: 5, // 防御
      speed: 10 // 速度
    },
    // 战斗属性
    combatAttributes: {
      critRate: 0, // 暴击率
      comboRate: 0, // 连击率
      counterRate: 0, // 反击率
      stunRate: 0, // 眩晕率
      dodgeRate: 0, // 闪避率
      vampireRate: 0 // 吸血率
    },
    // 战斗抗性
    combatResistance: {
      critResist: 0, // 抗暴击
      comboResist: 0, // 抗连击
      counterResist: 0, // 抗反击
      stunResist: 0, // 抗眩晕
      dodgeResist: 0, // 抗闪避
      vampireResist: 0 // 抗吸血
    },
    // 特殊属性
    specialAttributes: {
      healBoost: 0, // 强化治疗
      critDamageBoost: 0, // 强化爆伤
      critDamageReduce: 0, // 弱化爆伤
      finalDamageBoost: 0, // 最终增伤
      finalDamageReduce: 0, // 最终减伤
      combatBoost: 0, // 战斗属性提升
      resistanceBoost: 0 // 战斗抗性提升
    },
    // 资源
    spiritStones: 0, // 焰晶数量
    reinforceStones: 0, // 强化石数量
    refinementStones: 0, // 洗练石数量
    herbs: [], // 灵草库存
    items: [], // 物品库存
    artifacts: [], // 法宝装备
    // 装备栏位
    equippedArtifacts: {
      weapon: null, // 武器
      head: null, // 头部
      body: null, // 衣服
      legs: null, // 裤子
      feet: null, // 鞋子
      shoulder: null, // 肩甲
      hands: null, // 手套
      wrist: null, // 护腕
      necklace: null, // 项链
      ring1: null, // 戒指1
      ring2: null, // 戒指2
      belt: null, // 腰带
      artifact: null // 法宝
    },
    // 装备加成属性
    artifactBonuses: {
      // 基础属性加成
      attack: 0,
      health: 0,
      defense: 0,
      speed: 0,
      // 战斗属性加成
      critRate: 0,
      comboRate: 0,
      counterRate: 0,
      stunRate: 0,
      dodgeRate: 0,
      vampireRate: 0,
      // 抗性加成
      critResist: 0,
      comboResist: 0,
      counterResist: 0,
      stunResist: 0,
      dodgeResist: 0,
      vampireResist: 0,
      // 特殊属性加成
      healBoost: 0,
      critDamageBoost: 0,
      critDamageReduce: 0,
      finalDamageBoost: 0,
      finalDamageReduce: 0,
      combatBoost: 0,
      resistanceBoost: 0,
      // 修炼相关加成
      cultivationRate: 1,
      spiritRate: 1
    },
    // 统计数据
    totalCultivationTime: 0, // 总修炼时间
    breakthroughCount: 0, // 突破次数
    explorationCount: 0, // 探索次数
    itemsFound: 0, // 获得物品数量
    eventTriggered: 0, // 触发事件次数
    unlockedPillRecipes: 0, // 解锁丹方数量
    // 秘境相关数据
    dungeonDifficulty: 1, // 难度选择
    dungeonHighestFloor: 0, // 最高通关层数
    dungeonHighestFloor_2: 0, // 最高通关层数
    dungeonHighestFloor_5: 0, // 最高通关层数
    dungeonHighestFloor_10: 0, // 最高通关层数
    dungeonHighestFloor_100: 0, // 最高通关层数
    dungeonLastFailedFloor: 0, // 最后失败层数
    dungeonTotalRuns: 0, // 总探索次数
    dungeonBossKills: 0, // Boss击杀数
    dungeonEliteKills: 0, // 精英击杀数
    dungeonTotalKills: 0, // 总击杀数
    dungeonDeathCount: 0, // 死亡次数
    dungeonTotalRewards: 0, // 获得奖励次数
    // 离线收益
    lastOnlineTime: 0,
    // 坐骑加成（百分比）
    activeMountBonus: { attack_bonus: 0, defense_bonus: 0, health_bonus: 0, speed_bonus: 0 },
    // 称号加成（百分比）
    activeTitleBonus: { attack_bonus: 0, defense_bonus: 0, health_bonus: 0, speed_bonus: 0 },
    // 自动出售相关设置
    autoSellQualities: [], // 选中的装备品质
    autoReleaseRarities: [], // 选中的焰兽品质
    // 心愿单相关设置
    wishlistEnabled: false, // 心愿单开关
    selectedWishEquipQuality: null,
    selectedWishPetRarity: null,
    // 成就与解锁项
    unlockedRealms: ['燃火一层'], // 已解锁境界
    unlockedLocations: ['新手村'], // 已解锁地点
    unlockedSkills: [], // 已解锁功法
    completedAchievements: JSON.parse(localStorage.getItem("xx_completed_achievements") || "[]"), // 已完成成就(持久化)
    isAutoCultivating: false, // 自动冥想状态
    storageExpand: {}, // 背包扩容等级
    buffs: {} // 商城buff（doubleCrystal/cultivationBoost/luckyCharm）
  }),
  getters: {
    // 获取焰兽的属性加成
    getPetBonus() {
      if (!this.activePet)
        return {
          attack: 0,
          defense: 0,
          health: 0,
          critRate: 0,
          comboRate: 0,
          counterRate: 0,
          stunRate: 0,
          dodgeRate: 0,
          vampireRate: 0,
          critResist: 0,
          comboResist: 0,
          counterResist: 0,
          stunResist: 0,
          dodgeResist: 0,
          vampireResist: 0,
          healBoost: 0,
          critDamageBoost: 0,
          critDamageReduce: 0,
          finalDamageBoost: 0,
          finalDamageReduce: 0,
          combatBoost: 0,
          resistanceBoost: 0
        }
      const qualityBonusMap = {
        divine: 0.15, // 神品基础加成15%
        celestial: 0.12, // 仙品基础加成12%
        mystic: 0.09, // 玄品基础加成9%
        spiritual: 0.06, // 灵品基础加成6%
        mortal: 0.03 // 凡品基础加成3%
      }
      const starBonusPerQuality = {
        divine: 0.02, // 神品每星+2%
        celestial: 0.01, // 仙品每星+1%
        mystic: 0.01, // 玄品每星+1%
        spiritual: 0.01, // 灵品每星+1%
        mortal: 0.01 // 凡品每星+1%
      }
      const baseBonus = qualityBonusMap[this.activePet.rarity] || 0
      const starBonus = (this.activePet.star || 0) * (starBonusPerQuality[this.activePet.rarity] || 0)
      const levelBonus = ((this.activePet.level || 1) - 1) * (baseBonus * 0.1)
      const totalBonus = baseBonus + starBonus + levelBonus
      const phase = Math.floor((this.activePet.star || 0) / 5)
      const phaseBonus = phase * (baseBonus * 0.5)
      const finalBonus = totalBonus + phaseBonus
      const combatBonus = finalBonus * 0.5
      return {
        attack: finalBonus,
        defense: finalBonus,
        health: finalBonus,
        critRate: combatBonus,
        comboRate: combatBonus,
        counterRate: combatBonus,
        stunRate: combatBonus,
        dodgeRate: combatBonus,
        vampireRate: combatBonus,
        critResist: combatBonus,
        comboResist: combatBonus,
        counterResist: combatBonus,
        stunResist: combatBonus,
        dodgeResist: combatBonus,
        vampireResist: combatBonus,
        healBoost: combatBonus,
        critDamageBoost: combatBonus,
        critDamageReduce: combatBonus,
        finalDamageBoost: combatBonus,
        finalDamageReduce: combatBonus,
        combatBoost: combatBonus,
        resistanceBoost: combatBonus
      }
    },
  },
  actions: {
    async stopAutoCultivation() {
      this.isAutoCultivating = false
      if (this._autoCultTimer) {
        clearInterval(this._autoCultTimer)
        this._autoCultTimer = null
      }
      // 已登录：通知后端结算自动冥想
      const token = localStorage.getItem('xx_token')
      if (token) {
        try {
          const res = await fetch('/api/game/cultivate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
            body: JSON.stringify({ mode: 'auto_stop' })
          })
          if (res.ok) {
            const data = await res.json()
            this.spirit = data.spirit
            this.cultivation = data.cultivation
            this.level = data.level
            this.realm = data.realm
            this.maxCultivation = data.maxCultivation
            if (data.broke) {
              this.breakthroughCount = (this.breakthroughCount || 0) + 1
            }
          }
        } catch (e) { console.warn('[CULTIVATE] auto_stop failed:', e.message) }
      }
    },
    // 焰灵上限
    getMaxSpirit() {
      const cfg = useGameConfigStore()
      return cfg.loaded ? cfg.getMaxSpirit(this.level) : (this.maxSpirit || (200 + this.level * 100))
    },
    // 焰灵每秒恢复量
    getSpiritRegen() {
      const cfg = useGameConfigStore()
      return cfg.loaded ? cfg.getSpiritRegen(this.level) : (this.spiritRegenRate || (2 + this.level * 0.5))
    },
    // 启动焰灵展示层（本地预测 + 后端同步）
    startSpiritRegen() {
      if (this._spiritRegenTimer) return
      // 启动时立即同步一次，拿到离线恢复后的权威值
      this.syncFromServer()
      // 本地预测：每秒更新展示值
      this._spiritRegenTimer = setInterval(() => {
        if (this.isAutoCultivating) return
        const max = this.getMaxSpirit()
        if (this.spirit < max) {
          this.spirit = Math.min(max, this.spirit + this.getSpiritRegen())
        }
      }, 1000)
      // 后端同步：每10秒从服务端获取权威值校正
      this._syncTimer = setInterval(() => {
        this.syncFromServer()
      }, 10000)
    },
    stopSpiritRegen() {
      if (this._spiritRegenTimer) {
        clearInterval(this._spiritRegenTimer)
        this._spiritRegenTimer = null
      }
      if (this._syncTimer) {
        clearInterval(this._syncTimer)
        this._syncTimer = null
      }
    },
    // 从后端同步权威数据
    async syncFromServer() {
      const token = localStorage.getItem('xx_token')
      if (!token) return
      try {
        const res = await fetch('/api/game/tick', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
        })
        if (!res.ok) return
        const data = await res.json()
        // 用服务端权威值校正本地展示
        this.spirit = data.spirit
        this.maxSpirit = data.maxSpirit
        this.spiritRegenRate = data.regenRate
        this.cultivation = data.cultivation
        this.maxCultivation = data.maxCultivation
        this.level = data.level
        this.realm = data.realm
        this.cultivationCost = data.cultCost
        this.cultivationGain = data.cultGain
        this.isAutoCultivating = data.isAutoCultivating
        if (data.totalCultivationTime !== undefined) this.totalCultivationTime = data.totalCultivationTime
        // 属性同步
        if (data.baseAttributes) this.baseAttributes = data.baseAttributes
        if (data.combatAttributes) this.combatAttributes = data.combatAttributes
        if (data.combatResistance) this.combatResistance = data.combatResistance
        if (data.specialAttributes) this.specialAttributes = data.specialAttributes
        if (data._nakedBase) this._nakedBase = data._nakedBase
      } catch (e) {
        console.warn('[SYNC] tick failed:', e.message)
      }
    },
    async startAutoCultivation() {
      if (this.isAutoCultivating) return
      const token = localStorage.getItem('xx_token')
      if (token) {
        // 已登录：通知后端开始自动冥想
        try {
          await fetch('/api/game/cultivate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
            body: JSON.stringify({ mode: 'auto_start' })
          })
        } catch (e) { console.warn('[CULTIVATE] auto_start failed:', e.message) }
      }
      this.isAutoCultivating = true
      // 本地展示预测：每秒扣spirit加cultivation
      this._autoCultTimer = setInterval(() => {
        if (!this.isAutoCultivating) {
          clearInterval(this._autoCultTimer)
          this._autoCultTimer = null
          return
        }
        const cost = useGameConfigStore().getCultivationCost(this.level)
        if (this.spirit < cost) {
          this.stopAutoCultivation()
          return
        }
        const gain = useGameConfigStore().getCultivationGain(this.level)
        this.spirit -= cost
        this.cultivation += gain
      }, 1000)
    },
    toggleAutoCultivation() {
      if (this.isAutoCultivating) {
        this.stopAutoCultivation()
      } else {
        this.startAutoCultivation()
      }
    },
    // 获取合并后的总属性（base + 装备 + buff）
    getTotalStats() {
      // baseAttributes 已包含 naked + 装备 + 宠物（后端 recalcAndPatch 计算）
      // combatAttributes/combatResistance/specialAttributes 也已包含装备加成
      // 这里只需加 buff + 坐骑/称号百分比
      
      // 计算 buff 加成
      const now = Date.now()
      const activeBuffs = (this.activeEffects || []).filter(e => e.endTime > now)
      let buffAttack = 0, buffHealth = 0, buffDefense = 0, buffSpeed = 0
      let buffCritRate = 0, buffComboRate = 0, buffDodgeRate = 0
      activeBuffs.forEach(buff => {
        if (buff.attack) buffAttack += buff.attack
        if (buff.health) buffHealth += buff.health
        if (buff.defense) buffDefense += buff.defense
        if (buff.speed) buffSpeed += buff.speed
        if (buff.critRate) buffCritRate += buff.critRate
        if (buff.comboRate) buffComboRate += buff.comboRate
        if (buff.dodgeRate) buffDodgeRate += buff.dodgeRate
      })
      
      // 坐骑+称号百分比加成
      const mb = this.activeMountBonus || {}
      const tb = this.activeTitleBonus || {}
      const pctAtk = (mb.attack_bonus || 0) + (tb.attack_bonus || 0)
      const pctDef = (mb.defense_bonus || 0) + (tb.defense_bonus || 0)
      const pctHp = (mb.health_bonus || 0) + (tb.health_bonus || 0)
      const pctSpd = (mb.speed_bonus || 0) + (tb.speed_bonus || 0)
      
      // 基础四维（baseAttributes 已含装备，只加 buff）
      const rawHealth = (this.baseAttributes.health || 0) + buffHealth
      const rawAttack = (this.baseAttributes.attack || 0) + buffAttack
      const rawDefense = (this.baseAttributes.defense || 0) + buffDefense
      const rawSpeed = (this.baseAttributes.speed || 0) + buffSpeed
      
      return {
        health: Math.floor(rawHealth * (1 + pctHp)),
        attack: Math.floor(rawAttack * (1 + pctAtk)),
        defense: Math.floor(rawDefense * (1 + pctDef)),
        speed: Math.floor(rawSpeed * (1 + pctSpd)),
        // 战斗百分比（已含装备，只加 buff）
        critRate: Math.min(1, (this.combatAttributes.critRate || 0) + buffCritRate),
        comboRate: Math.min(1, (this.combatAttributes.comboRate || 0) + buffComboRate),
        counterRate: Math.min(1, (this.combatAttributes.counterRate || 0)),
        stunRate: Math.min(1, (this.combatAttributes.stunRate || 0)),
        dodgeRate: Math.min(1, (this.combatAttributes.dodgeRate || 0) + buffDodgeRate),
        vampireRate: Math.min(1, (this.combatAttributes.vampireRate || 0)),
        // 抗性
        critResist: Math.min(1, (this.combatResistance.critResist || 0)),
        comboResist: Math.min(1, (this.combatResistance.comboResist || 0)),
        counterResist: Math.min(1, (this.combatResistance.counterResist || 0)),
        stunResist: Math.min(1, (this.combatResistance.stunResist || 0)),
        dodgeResist: Math.min(1, (this.combatResistance.dodgeResist || 0)),
        vampireResist: Math.min(1, (this.combatResistance.vampireResist || 0)),
        // 特殊属性
        healBoost: (this.specialAttributes.healBoost || 0),
        critDamageBoost: (this.specialAttributes.critDamageBoost || 0),
        critDamageReduce: (this.specialAttributes.critDamageReduce || 0),
        finalDamageBoost: (this.specialAttributes.finalDamageBoost || 0),
        finalDamageReduce: (this.specialAttributes.finalDamageReduce || 0),
        combatBoost: (this.specialAttributes.combatBoost || 0),
        resistanceBoost: (this.specialAttributes.resistanceBoost || 0),
      }
    },
    // 计算离线收益（已登录走后端，未登录本地算）
    async calculateOfflineReward() {
      const token = localStorage.getItem('xx_token')
      if (token) {
        // 已登录：后端 tick 已经自动补发了离线 spirit，这里只需获取结果
        try {
          const res = await fetch('/api/game/offline-reward', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
          })
          if (res.ok) {
            const data = await res.json()
            if (data.offlineMin < 5) return null
            // 用后端返回值更新 store
            this.spirit = data.spirit
            this.cultivation = data.cultivation
            this.spiritStones = data.spiritStones
            this.level = data.level
            this.realm = data.realm
            this.maxCultivation = data.maxCultivation
            return { offlineMin: data.offlineMin, cultivation: data.cultGained, stones: data.stonesGained, spirit: data.spiritGained, vipBoost: data.vipBoost }
          }
        } catch (e) { console.warn('[OFFLINE] failed:', e.message) }
      }
      // 未登录：本地计算
      if (!this.lastOnlineTime || this.lastOnlineTime <= 0) {
        this.lastOnlineTime = Date.now()
        this.saveData()
        return null
      }
      const now = Date.now()
      const offlineMs = now - this.lastOnlineTime
      const offlineMin = Math.floor(offlineMs / 60000)
      if (offlineMin < 5) return null
      const cappedMin = Math.min(offlineMin, 720)
      const baseCultPerMin = Math.max(1, Math.floor(this.level * 2))
      const baseStonesPerMin = Math.floor(this.level * 2 + 5)
      const baseSpiritPerMin = Math.floor(this.level * 3 + 10)
      let vipBoost = 1
      try {
        const pinia = window.__pinia
        if (pinia) {
          const authState = pinia.state.value.auth
          if (authState) {
            const boosts = [1, 1.1, 1.2, 1.5, 1.8, 2.0]
            vipBoost = boosts[authState.vipLevel] || 1
          }
        }
      } catch {}
      const cultivation = Math.floor(baseCultPerMin * cappedMin * vipBoost)
      const stones = Math.floor(baseStonesPerMin * cappedMin * vipBoost)
      const spirit = Math.floor(baseSpiritPerMin * cappedMin * vipBoost)
      this.cultivation += cultivation
      this.spiritStones += stones
      this.spirit += spirit
      if (this.cultivation >= this.maxCultivation) {
        await this.tryBreakthrough()
      }
      this.lastOnlineTime = now
      this.saveData()
      return { offlineMin: cappedMin, cultivation, stones, spirit, vipBoost }
    },
    // 计算战力
    getCombatPower() {
      const s = this.getTotalStats()
      const base = (s.attack || 0) * 4 + (s.health || 0) * 0.5 + (s.defense || 0) * 3 + (s.speed || 0) * 2
      const combat = ((s.critRate || 0) + (s.comboRate || 0) + (s.counterRate || 0) + (s.dodgeRate || 0) + (s.vampireRate || 0)) * 500
      const special = ((s.critDamageBoost || 0) + (s.finalDamageBoost || 0) + (s.healBoost || 0) + (s.combatBoost || 0)) * 300
      const levelBonus = this.level * 100
      return Math.floor(base + combat + special + levelBonus)
    },
    // 更新HTML暗黑模式类
    updateHtmlDarkMode(isDarkMode) {
      const htmlEl = document.documentElement
      if (isDarkMode) {
        htmlEl.classList.add('dark')
      } else {
        htmlEl.classList.remove('dark')
      }
    },
    // 初始化玩家数据
    async initializePlayer() {
      try {
        const savedData = await GameDB.getData('playerData')
        if (savedData) {
          const decryptedData = decryptData(savedData)
          if (decryptedData && validateData(decryptedData)) {
            Object.assign(this.$state, decryptedData)
          } else {
            console.error('存档数据验证失败，使用初始数据')
          }
        }
      } catch (error) {
        console.error('加载存档失败:', error)
      }
      // 初始化主题设置
      this.isDarkMode = localStorage.getItem('darkMode') === 'true'
      // 同步暗黑模式状态到HTML标签
      this.updateHtmlDarkMode(this.isDarkMode)
    },
    // 切换暗黑模式
    toggle() {
      this.isDarkMode = !this.isDarkMode
      localStorage.setItem('darkMode', this.isDarkMode)
      // 更新html标签的class
      this.updateHtmlDarkMode(this.isDarkMode)
      this.saveData()
    },
    // 保存数据到IndexedDB
    async saveData() {
      // 已登录用户：2秒防抖立即云存档；未登录：不做任何事
      const token = localStorage.getItem('xx_token')
      if (!token) return
      if (this._saveDebounceTimer) clearTimeout(this._saveDebounceTimer)
      this._saveDebounceTimer = setTimeout(async () => {
        this._saveDebounceTimer = null
        try {
          const { useAuthStore } = await import('./auth')
          const authStore = useAuthStore()
          if (authStore.isLoggedIn) {
            authStore.saveToCloud(this).catch(e => console.warn('[SAVE] failed:', e.message))
          }
        } catch (e) { console.warn('[SAVE] error:', e.message) }
      }, 2000)
    },
    // 导出存档数据
    async exportData() {
      try {
        const data = await GameDB.getData('playerData')
        return data
      } catch (error) {
        console.error('导出存档失败:', error)
        throw error
      }
    },
    // 导入存档数据
    async importData(encryptedData) {
      try {
        await GameDB.setData('playerData', encryptedData)
        this.$reset()
        await this.initializePlayer()
      } catch (error) {
        console.error('导入存档失败:', error)
        throw error
      }
    },
    // 清除存档数据
    async clearData() {
      try {
        await GameDB.setData('playerData', null)
      } catch (error) {
        console.error('清除存档失败:', error)
        throw error
      }
    },
    // 获取灵力
    gainSpirit(amount) {
      this.spirit += amount * this.spiritRate
    },
    // 修炼增加修为
    async cultivate(amount) {
      const token = localStorage.getItem('xx_token')
      if (token) {
        // 已登录：走后端冥想 API
        try {
          const res = await fetch('/api/game/cultivate', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
            body: JSON.stringify({ times: 1 })
          })
          if (res.ok) {
            const data = await res.json()
            this.spirit = data.spirit
            this.maxSpirit = data.maxSpirit
            this.cultivation = data.cultivation
            this.maxCultivation = data.maxCultivation
            this.level = data.level
            this.realm = data.realm
            this.cultivationCost = data.cultCost
            this.cultivationGain = data.cultGain
            this.totalCultivationTime += data.actualTimes
            if (data.broke) {
              this.breakthroughCount = (this.breakthroughCount || 0) + 1
            }
            return data
          }
        } catch (e) { console.warn('[CULTIVATE] failed:', e.message) }
      }
      // 未登录：本地计算
      const numAmount = Number(String(amount).replace(/[^0-9.-]/g, '')) || 0
      this.cultivation = Number(String(this.cultivation).replace(/[^0-9.-]/g, '')) || 0
      this.cultivation += numAmount
      this.totalCultivationTime += 1
      if (this.cultivation >= this.maxCultivation) {
        await this.tryBreakthrough()
      }
      this.saveData()
    },
    // 尝试突破
    async tryBreakthrough() {
      // 未登录时用本地逻辑
      const token = localStorage.getItem('xx_token')
      if (!token) {
        const cfg = useGameConfigStore()
        const realmsLength = cfg.loaded ? cfg.realms.length : getRealmLength()
        if (this.level < realmsLength && this.cultivation >= this.maxCultivation) {
          const nextRealm = cfg.loaded ? cfg.getRealmByLevel(this.level) : getRealmName(this.level)
          this.level += 1
          this.realm = nextRealm.name
          this.maxCultivation = nextRealm.maxCultivation
          this.cultivation = 0
          this.breakthroughCount += 1
          this.spirit += 100 * this.level
          this.saveData()
          return true
        }
        return false
      }
      // 已登录走后端 API
      try {
        const res = await fetch('/api/game/breakthrough', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token }
        })
        const data = await res.json()
        if (data.success) {
          this.level = data.level
          this.realm = data.realm
          this.maxCultivation = data.maxCultivation
          this.cultivation = 0
          this.spirit = data.spirit
          this.maxSpirit = data.maxSpirit
          this.spiritRegenRate = data.spiritRegenRate
          this.cultivationCost = data.cultivationCost
          this.cultivationGain = data.cultivationGain
          this.breakthroughCount += 1
          if (!this.unlockedRealms.includes(data.realm)) {
            this.unlockedRealms.push(data.realm)
          }
          this.saveData()
          return true
        }
        return false
      } catch (e) {
        console.error('突破API失败:', e)
        return false
      }
    },
    // 获得物品
    gainItem(item) {
      this.items.push(item)
      this.itemsFound++ // 增加获得物品统计
      this.saveData()
    },
    // 使用物品（焰丹或焰兽）
    useItem(item) {
      if (item.type === 'pill') {
        return this.usePill(item)
      } else if (item.type === 'pet') {
        return this.usePet(item)
      }
      return { success: false, message: '无法使用该物品' }
    },
    // 卖出装备
    async sellEquipment(equipment) {
      const index = this.items.findIndex(i => i.id === equipment.id)
      if (index === -1) {
        return { success: false, message: '装备不存在' }
      }
      return new Promise(resolve => {
        const worker = new Worker(new URL('../workers/equipment.js', import.meta.url))
        worker.onmessage = e => {
          const { stoneAmount, itemId } = e.data
          this.reinforceStones += stoneAmount
          const index = this.items.findIndex(i => i.id === itemId)
          if (index > -1) {
            this.items.splice(index, 1)
          }
          this.saveData()
          worker.terminate()
          resolve({ success: true, message: `成功卖出装备，获得${stoneAmount}个强化石` })
        }
        // 只传递必要的数据
        worker.postMessage({
          type: 'single',
          equipment: {
            id: equipment.id,
            quality: equipment.quality
          }
        })
      })
    },
    // 批量卖出装备
    async batchSellEquipments(quality = null, equipmentType = null) {
      return new Promise(resolve => {
        const worker = new Worker(new URL('../workers/equipment.js', import.meta.url))
        worker.onmessage = e => {
          const { totalStones, itemsToRemove, count } = e.data
          this.reinforceStones += totalStones
          this.items = this.items.filter(item => !itemsToRemove.includes(item.id))
          this.saveData()
          worker.terminate()
          resolve({
            success: true,
            message: `成功卖出${count}件装备，获得${totalStones}个强化石`
          })
        }
        // 将数据转换为纯对象数组
        const itemsToSell = this.items
          .filter(item => {
            if (!item || !item.type || item.type === 'pill' || item.type === 'pet') return false
            if (equipmentType && item.type !== equipmentType) return false
            if (quality && item.quality !== quality) return false
            return true
          })
          .map(item => ({
            id: item.id,
            type: item.type,
            quality: item.quality
          }))
        // 发送简化后的数据
        worker.postMessage({
          type: 'batch',
          items: JSON.parse(JSON.stringify(itemsToSell)),
          quality,
          equipmentType
        })
      })
    },
    // 使用丹药
    usePill(pill) {
      const now = Date.now()
      // 添加效果
      this.activeEffects.push({
        ...pill.effect,
        startTime: now,
        endTime: now + pill.effect.duration * 1000
      })
      // 移除已使用的丹药
      const index = this.items.findIndex(i => i.id === pill.id)
      if (index > -1) {
        this.items.splice(index, 1)
        this.pillsConsumed++
      }
      // 清理过期效果
      this.activeEffects = this.activeEffects.filter(effect => effect.endTime > now)
      this.saveData()
      return { success: true, message: '使用丹药成功' }
    },
    // 炼制丹药
    craftPill(recipeId) {
      const recipe = pillRecipes.find(r => r.id === recipeId)
      if (!recipe) return { success: false, message: '丹方不存在' }
      // 尝试炼制丹药
      const result = tryCreatePill(
        recipe,
        this.herbs,
        this,
        this.pillFragments[recipe.id] || 0,
        this.luck * this.alchemyRate
      )
      if (result.success) {
        // 消耗材料
        for (const material of recipe.materials) {
          for (let i = 0; i < material.count; i++) {
            const index = this.herbs.findIndex(h => (h.herbId || h.herb_id || h.id) === material.herb)
            if (index > -1) {
              this.herbs.splice(index, 1)
            }
          }
        }
        // 计算丹药效果
        const effect = calculatePillEffect(recipe, this.level)
        // 添加到物品栏
        this.items.push({
          id: `${recipe.id}_${Date.now()}`,
          name: recipe.name,
          type: 'pill',
          description: recipe.description,
          effect: effect
        })
        this.pillsCrafted++
        // 消耗焰方（一次性使用）
        const recipeIdx = this.pillRecipes.indexOf(recipeId)
        if (recipeIdx > -1) this.pillRecipes.splice(recipeIdx, 1)
        this.saveData()
      }
      return result
    },
    // 使用焰兽（出战/召回）
    usePet(pet) {
      // 如果当前没有出战焰兽，直接出战新焰兽
      if (!this.activePet) {
        return this.deployPet(pet)
      }
      // 如果点击的是当前出战焰兽，则召回
      if (this.activePet.id === pet.id) {
        return this.recallPet()
      }
      // 如果点击的是其他焰兽，先召回当前焰兽，再出战新焰兽
      this.recallPet()
      return this.deployPet(pet)
    },
    // 召回焰兽
    recallPet() {
      if (!this.activePet) {
        return { success: false, message: '当前没有出战的焰兽' }
      }
      // 重置所有属性加成
      this.resetPetBonuses()
      this.activePet = null
      this.saveData()
      return { success: true, message: '召回成功' }
    },
    // 出战焰兽
    deployPet(pet) {
      // 如果已有焰兽出战，先召回
      if (this.activePet) {
        this.recallPet()
      }
      // 出战新焰兽
      this.activePet = pet
      // 应用焰兽属性加成
      this.applyPetBonuses()
      this.saveData()
      return { success: true, message: '出战成功' }
    },
    // 重置焰兽属性加成
    resetPetBonuses() {
      const petBonus = this.activePet.combatAttributes
      // 保存原始属性值
      const originalBaseAttributes = { ...this.baseAttributes }
      const originalCombatAttributes = { ...this.combatAttributes }
      const originalCombatResistance = { ...this.combatResistance }
      const originalSpecialAttributes = { ...this.specialAttributes }
      // 更新基础属性
      this.baseAttributes.attack = originalBaseAttributes.attack - petBonus.attack
      this.baseAttributes.defense = originalBaseAttributes.defense - petBonus.defense
      this.baseAttributes.health = originalBaseAttributes.health - petBonus.health
      this.baseAttributes.speed = originalBaseAttributes.speed - petBonus.speed
      // 更新战斗属性
      Object.keys(this.combatAttributes).forEach(key => {
        this.combatAttributes[key] = originalCombatAttributes[key] - (petBonus[key] || 0)
      })
      // 更新战斗抗性
      Object.keys(this.combatResistance).forEach(key => {
        this.combatResistance[key] = originalCombatResistance[key] - (petBonus[key] || 0)
      })
      // 更新特殊属性
      Object.keys(this.specialAttributes).forEach(key => {
        this.specialAttributes[key] = originalSpecialAttributes[key] - (petBonus[key] || 0)
      })
    },
    // 应用焰兽属性加成
    applyPetBonuses() {
      if (!this.activePet) return
      const petBonus = this.activePet.combatAttributes
      // 保存原始属性值
      const originalBaseAttributes = { ...this.baseAttributes }
      const originalCombatAttributes = { ...this.combatAttributes }
      const originalCombatResistance = { ...this.combatResistance }
      const originalSpecialAttributes = { ...this.specialAttributes }
      // 更新基础属性
      this.baseAttributes.attack = originalBaseAttributes.attack + petBonus.attack
      this.baseAttributes.defense = originalBaseAttributes.defense + petBonus.defense
      this.baseAttributes.health = originalBaseAttributes.health + petBonus.health
      this.baseAttributes.speed = originalBaseAttributes.speed + petBonus.speed
      // 更新战斗属性
      Object.keys(this.combatAttributes).forEach(key => {
        this.combatAttributes[key] = originalCombatAttributes[key] + (petBonus[key] || 0)
      })
      // 更新战斗抗性
      Object.keys(this.combatResistance).forEach(key => {
        this.combatResistance[key] = originalCombatResistance[key] + (petBonus[key] || 0)
      })
      // 更新特殊属性
      Object.keys(this.specialAttributes).forEach(key => {
        this.specialAttributes[key] = originalSpecialAttributes[key] + (petBonus[key] || 0)
      })
    },
    // 穿上装备
    equipArtifact(artifact, slot) {
      // 检查境界要求
      if (artifact.requiredRealm && this.level < artifact.requiredRealm) {
        return { success: false, message: '境界不足，无法装备此装备' }
      }
      // 先卸下当前装备
      if (this.equippedArtifacts[slot]) {
        this.unequipArtifact(slot)
      }
      // 从背包中移除装备
      const index = this.items.findIndex(item => item.id === artifact.id)
      if (index !== -1) {
        this.items.splice(index, 1)
      }
      // 穿上新装备
      this.equippedArtifacts[slot] = artifact
      // 应用装备加成
      if (artifact.stats) {
        Object.entries(artifact.stats).forEach(([key, value]) => {
          // 先更新artifactBonuses
          if (this.artifactBonuses[key] !== undefined) {
            this.artifactBonuses[key] += value
            // 根据属性类型应用到对应的属性组
            if (key in this.baseAttributes) {
              this.baseAttributes[key] += value
            } else if (key in this.combatAttributes) {
              this.combatAttributes[key] = Math.min(1, this.combatAttributes[key] + value)
            } else if (key in this.combatResistance) {
              this.combatResistance[key] = Math.min(1, this.combatResistance[key] + value)
            } else if (key in this.specialAttributes) {
              this.specialAttributes[key] += value
            }
          }
        })
      }
      this.saveData()
      return { success: true, message: '装备成功' }
    },
    // 卸下装备
    unequipArtifact(slot) {
      const artifact = this.equippedArtifacts[slot]
      if (artifact) {
        // 移除装备加成
        if (artifact.stats) {
          Object.entries(artifact.stats).forEach(([key, value]) => {
            if (this.artifactBonuses[key] !== undefined) {
              this.artifactBonuses[key] -= value
              // 从对应的属性组中移除加成
              if (key in this.baseAttributes) {
                this.baseAttributes[key] -= value
              } else if (key in this.combatAttributes) {
                this.combatAttributes[key] = Math.max(0, this.combatAttributes[key] - value)
              } else if (key in this.combatResistance) {
                this.combatResistance[key] = Math.max(0, this.combatResistance[key] - value)
              } else if (key in this.specialAttributes) {
                this.specialAttributes[key] -= value
              }
            }
          })
        }
        // 将装备返回到背包
        this.items.push(artifact)
        this.equippedArtifacts[slot] = null
        this.saveData()
        return true
      }
      return false
    },
    // 获取装备总加成
    getArtifactBonus(type) {
      return this.artifactBonuses[type] || 1
    },
    getStorageLimit(type) {
      const config = { equip: { base: 100, perLevel: 20 }, pet: { base: 30, perLevel: 5 } }
      const expand = this.storageExpand || {}
      const level = expand[type] || 0
      const c = config[type] || { base: 100, perLevel: 20 }
      return c.base + c.perLevel * level
    },
    // 获得丹方残页
    gainPillFragment(recipeId) {
      if (!this.pillFragments[recipeId]) {
        this.pillFragments[recipeId] = 0
      }
      this.pillFragments[recipeId]++
      // 检查是否可以合成完整丹方
      const recipe = pillRecipes.find(r => r.id === recipeId)
      if (recipe && this.pillFragments[recipeId] >= recipe.fragmentsNeeded) {
        this.pillFragments[recipeId] -= recipe.fragmentsNeeded
        if (!this.pillRecipes.includes(recipeId)) {
          this.pillRecipes.push(recipeId)
          this.unlockedPillRecipes++
        }
      }
      this.saveData()
    },
    // 炼制丹药
    craftPill(recipeId) {
      const recipe = pillRecipes.find(r => r.id === recipeId)
      if (!recipe || !this.pillRecipes.includes(recipeId)) {
        return { success: false, message: '未掌握丹方' }
      }
      const fragments = this.pillFragments[recipeId] || 0
      const result = tryCreatePill(recipe, this.herbs, this, fragments, this.luck * this.alchemyRate)
      if (result.success) {
        // 消耗材料
        recipe.materials.forEach(material => {
          for (let i = 0; i < material.count; i++) {
            const index = this.herbs.findIndex(h => (h.herbId || h.herb_id || h.id) === material.herb)
            if (index > -1) {
              this.herbs.splice(index, 1)
            }
          }
        })
        // 创建丹药
        const effect = calculatePillEffect(recipe, this.level)
        const pill = {
          id: `${recipe.id}_${Date.now()}`,
          name: recipe.name,
          description: recipe.description,
          type: 'pill',
          effect
        }
        this.items.push(pill)
        this.pillsCrafted++
        // 消耗焰方（一次性使用）
        const recipeIdx = this.pillRecipes.indexOf(recipeId)
        if (recipeIdx > -1) this.pillRecipes.splice(recipeIdx, 1)
        this.saveData()
      }
      return result
    },
    // 使用丹药
    useItem(item) {
      if (item.type === 'pill') {
        const now = Date.now()
        // 添加效果
        this.activeEffects.push({
          ...item.effect,
          startTime: now,
          endTime: now + item.effect.duration * 1000
        })
        // 移除已使用的丹药
        const index = this.items.findIndex(i => i.id === item.id)
        if (index > -1) {
          this.items.splice(index, 1)
          this.pillsConsumed++
        }
        // 清理过期效果
        this.activeEffects = this.activeEffects.filter(effect => effect.endTime > now)
        this.saveData()
        return true
      }
      return false
    },
    // 获取当前有效的丹药效果
    getActiveEffects() {
      const now = Date.now()
      return this.activeEffects.filter(effect => effect.endTime > now)
    },
    // 添加装备到背包
    addEquipment(equipment) {
      if (!this.items) {
        this.items = []
      }
      this.items.push(equipment)
      this.saveData()
    },
    // 升级焰兽
    async upgradePet(pet, essenceCount) {
      if (this.petEssence < essenceCount) {
        return { success: false, message: '焰兽精华不足' }
      }
      // 消耗精华并提升等级
      this.petEssence -= essenceCount
      const petIndex = this.items.findIndex(item => item.id === pet.id)
      if (petIndex > -1) {
        const currentPet = this.items[petIndex]
        currentPet.level = (currentPet.level || 1) + 1
        // 根据品质和等级提升战斗属性
        const qualityMultiplier =
          {
            divine: 2.0,
            celestial: 1.8,
            mystic: 1.6,
            spiritual: 1.4,
            mortal: 1.2
          }[currentPet.rarity] || 1.2
        // 更新战斗属性
        currentPet.combatAttributes = {
          attack: Math.floor(currentPet.combatAttributes.attack * (1 + 0.01 * qualityMultiplier)),
          health: Math.floor(currentPet.combatAttributes.health * (1 + 0.01 * qualityMultiplier)),
          defense: Math.floor(currentPet.combatAttributes.defense * (1 + 0.01 * qualityMultiplier)),
          speed: Math.floor(currentPet.combatAttributes.speed * (1 + 0.01 * qualityMultiplier)),

          critRate: currentPet.combatAttributes.critRate + 0.01 * qualityMultiplier,
          comboRate: currentPet.combatAttributes.comboRate + 0.01 * qualityMultiplier,
          counterRate: currentPet.combatAttributes.counterRate + 0.01 * qualityMultiplier,
          stunRate: currentPet.combatAttributes.stunRate + 0.01 * qualityMultiplier,
          dodgeRate: currentPet.combatAttributes.dodgeRate + 0.01 * qualityMultiplier,
          vampireRate: currentPet.combatAttributes.vampireRate + 0.01 * qualityMultiplier,

          critResist: currentPet.combatAttributes.critResist + 0.01 * qualityMultiplier, // 抗暴击
          comboResist: currentPet.combatAttributes.comboResist + 0.01 * qualityMultiplier, // 抗连击
          counterResist: currentPet.combatAttributes.counterResist + 0.01 * qualityMultiplier, // 抗反击
          stunResist: currentPet.combatAttributes.stunResist + 0.01 * qualityMultiplier, // 抗眩晕
          dodgeResist: currentPet.combatAttributes.dodgeResist + 0.01 * qualityMultiplier, // 抗闪避
          vampireResist: currentPet.combatAttributes.vampireResist + 0.01 * qualityMultiplier, // 抗吸血

          healBoost: currentPet.combatAttributes.healBoost + 0.01 * qualityMultiplier,
          critDamageBoost: currentPet.combatAttributes.critDamageBoost + 0.01 * qualityMultiplier,
          critDamageReduce: currentPet.combatAttributes.critDamageReduce + 0.01 * qualityMultiplier,
          finalDamageBoost: currentPet.combatAttributes.finalDamageBoost + 0.01 * qualityMultiplier,
          finalDamageReduce: currentPet.combatAttributes.finalDamageReduce + 0.01 * qualityMultiplier,
          combatBoost: currentPet.combatAttributes.combatBoost + 0.01 * qualityMultiplier,
          resistanceBoost: currentPet.combatAttributes.resistanceBoost + 0.01 * qualityMultiplier
        }
        // 如果是当前出战的焰兽，重新应用属性加成
        if (this.activePet && this.activePet.id === pet.id) {
          this.applyPetBonuses()
        }
      }
      // 直接写服务器，避免 serverManagedFields 覆盖
      const token = localStorage.getItem('xx_token')
      if (token) {
        try {
          await fetch('/api/game/save', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token },
            body: JSON.stringify({ gameData: this.$state, level: this.level, realm: this.realm, name: this.name })
          })
        } catch(e) { console.error('pet upgrade save failed', e) }
      }
      this._dirty = false
      return { success: true, message: '升级成功' }
    },
    // 升星焰兽
    evolvePet(pet, foodPet) {
      // 检查是否是相同品质和名字的焰兽
      if (pet.rarity != foodPet.rarity || pet.name != foodPet.name) {
        return { success: false, message: '只能使用相同品质和名字的焰兽进行升星' }
      }
      const petIndex = this.items.findIndex(item => item.id === pet.id)
      const foodPetIndex = this.items.findIndex(item => item.id === foodPet.id)
      if (petIndex > -1 && foodPetIndex > -1) {
        // 返还作为升星材料的焰兽已消耗的精华
        const returnEssence = (foodPet.level - 1) * 10 // 假设每级消耗10精华
        this.petEssence += returnEssence
        // 移除作为材料的焰兽
        this.items.splice(foodPetIndex, 1)
        // 提升目标焰兽星级
        this.items[petIndex].star = (this.items[petIndex].star || 0) + 1
        this.saveData()
        return { success: true, message: '升星成功' }
      }
      return { success: false, message: '升星失败' }
    },
    // 从服务器加载装备数据
    async loadEquipmentFromServer() {
      try {
        const pinia = window.__pinia
        if (!pinia) return
        const authStore = pinia.state.value.auth
        if (!authStore || !authStore.isLoggedIn) return
        const data = await authStore.loadFromCloud()
        if (data && data.game_data) {
          const gd = data.game_data
          if (gd.items) {
            // 只更新装备类型物品（非丹药、非焰兽）
            const serverEquipItems = gd.items.filter(i => i.type && i.type !== 'pill' && i.type !== 'pet')
            // 保留本地非装备物品（丹药、焰兽）
            const localNonEquipItems = this.items.filter(i => i.type === 'pill' || i.type === 'pet')
            this.items = [...localNonEquipItems, ...serverEquipItems]
          }
          if (gd.equippedArtifacts) {
            this.equippedArtifacts = gd.equippedArtifacts
          }
        }
      } catch (error) {
        console.error('从服务器加载装备失败:', error)
      }
    },
    // 从服务器加载焰兽数据
    async loadPetsFromServer() {
      try {
        const pinia = window.__pinia
        if (!pinia) return
        const authStore = pinia.state.value.auth
        if (!authStore || !authStore.isLoggedIn) return
        const data = await authStore.loadFromCloud()
        if (data && data.game_data) {
          const gd = data.game_data
          if (gd.items) {
            // 只更新焰兽类型物品
            const serverPetItems = gd.items.filter(i => i.type === 'pet')
            // 保留本地非焰兽物品
            const localNonPetItems = this.items.filter(i => i.type !== 'pet')
            this.items = [...localNonPetItems, ...serverPetItems]
          }
          if (gd.activePet !== undefined) {
            this.activePet = gd.activePet
          }
          if (gd.petEssence !== undefined) {
            this.petEssence = gd.petEssence
          }
        }
      } catch (error) {
        console.error('从服务器加载焰兽失败:', error)
      }
    },
    // 从服务器加载焰草数据
    async loadHerbsFromServer() {
      try {
        const pinia = window.__pinia
        if (!pinia) return
        const authStore = pinia.state.value.auth
        if (!authStore || !authStore.isLoggedIn) return
        const data = await authStore.loadFromCloud()
        if (data && data.game_data && data.game_data.herbs) {
          this.herbs = data.game_data.herbs
        }
      } catch (error) {
        console.error('从服务器加载焰草失败:', error)
      }
    },
    // 从服务器加载丹药数据
    async loadPillsFromServer() {
      try {
        const pinia = window.__pinia
        if (!pinia) return
        const authStore = pinia.state.value.auth
        if (!authStore || !authStore.isLoggedIn) return
        const data = await authStore.loadFromCloud()
        if (data && data.game_data) {
          const gd = data.game_data
          if (gd.items) {
            // 只更新丹药类型物品
            const serverPillItems = gd.items.filter(i => i.type === 'pill')
            // 保留本地非丹药物品
            const localNonPillItems = this.items.filter(i => i.type !== 'pill')
            this.items = [...localNonPillItems, ...serverPillItems]
          }
          if (gd.pillFragments) {
            this.pillFragments = gd.pillFragments
          }
          if (gd.pillRecipes) {
            this.pillRecipes = gd.pillRecipes
          }
        }
      } catch (error) {
        console.error('从服务器加载丹药失败:', error)
      }
    }
  }
})
