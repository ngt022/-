// 战斗状态
const CombatState = {
  READY: 'ready',
  IN_PROGRESS: 'in_progress',
  VICTORY: 'victory',
  DEFEAT: 'defeat'
}

// 战斗类型
const CombatType = {
  NORMAL: 'normal',
  BOSS: 'boss',
  ELITE: 'elite'
}

// 基础战斗属性
class CombatStats {
  constructor(base = {}) {
    this.health = base.health || 100
    this.maxHealth = base.maxHealth || 100
    this.damage = base.damage || 10
    this.defense = base.defense || 5
    this.speed = base.speed || 10
    this.critRate = base.critRate || 0.05
    this.comboRate = base.comboRate || 0
    this.counterRate = base.counterRate || 0
    this.stunRate = base.stunRate || 0
    this.dodgeRate = base.dodgeRate || 0.05
    this.vampireRate = base.vampireRate || 0
    this.critResist = base.critResist || 0
    this.comboResist = base.comboResist || 0
    this.counterResist = base.counterResist || 0
    this.stunResist = base.stunResist || 0
    this.dodgeResist = base.dodgeResist || 0
    this.vampireResist = base.vampireResist || 0
    this.healBoost = base.healBoost || 0
    this.critDamageBoost = base.critDamageBoost || 0.5
    this.critDamageReduce = base.critDamageReduce || 0
    this.finalDamageBoost = base.finalDamageBoost || 0
    this.finalDamageReduce = base.finalDamageReduce || 0
    this.combatBoost = base.combatBoost || 0
    this.resistanceBoost = base.resistanceBoost || 0
  }

  calculateDamage(target) {
    let damage = Math.abs(this.damage * (1 + this.combatBoost))
    let isCrit = false
    let isCombo = false
    let isVampire = false
    let isStun = false

    const finalCritRate = Math.max(
      0,
      this.critRate * (1 + this.combatBoost) -
        (target ? target.stats.critResist * (1 + target.stats.resistanceBoost) : 0)
    )
    if (Math.random() < finalCritRate) {
      damage *= 1.5 + this.critDamageBoost
      isCrit = true
    }

    const finalComboRate = Math.max(
      0,
      this.comboRate * (1 + this.combatBoost) - (target ? target.stats.comboResist : 0)
    )
    if (Math.random() < finalComboRate) {
      damage *= 1.3
      isCombo = true
    }

    const finalVampireRate = Math.max(
      0,
      this.vampireRate * (1 + this.combatBoost) - (target ? target.stats.vampireResist : 0)
    )
    if (Math.random() < finalVampireRate) {
      isVampire = true
    }

    const finalStunRate = Math.max(0, this.stunRate * (1 + this.combatBoost) - (target ? target.stats.stunResist : 0))
    if (Math.random() < finalStunRate) {
      isStun = true
    }

    damage *= 1 + this.finalDamageBoost
    return { damage: Math.abs(damage), isCrit, isCombo, isVampire, isStun }
  }

  calculateDamageReduction(incomingDamage, attackerStats) {
    let damage = Math.abs(incomingDamage)
    const effectiveDefense = this.defense * (1 + this.combatBoost)
    damage *= 100 / (100 + effectiveDefense)
    if (attackerStats && attackerStats.isCrit) {
      damage *= 1 - this.critDamageReduce
    }
    damage *= 1 - this.finalDamageReduce
    return Math.abs(damage)
  }
}

class CombatEntity {
  constructor(name, level, baseStats = {}, realm = '燃火期一层') {
    const stats = { ...baseStats }
    this.name = name
    this.level = level
    this.realm = realm
    if (stats.health && !stats.maxHealth) {
      stats.maxHealth = stats.health
    }
    this.stats = new CombatStats(stats)
    this.currentHealth = this.stats.maxHealth
    this.effects = []
  }

  takeDamage(amount, source) {
    const actualDodgeRate = Math.max(0, Math.min(1, this.stats.dodgeRate - (source ? source.stats.dodgeResist : 0)))
    if (Math.random() < actualDodgeRate) {
      return { dodged: true, damage: 0 }
    }
    const reducedDamage = this.stats.calculateDamageReduction(amount)
    this.currentHealth = Math.max(0, this.currentHealth - reducedDamage)
    let isCounter = false
    if (source) {
      const finalCounterRate = Math.max(0, this.stats.counterRate - source.stats.counterResist)
      if (Math.random() < finalCounterRate) {
        isCounter = true
      }
    }
    return {
      dodged: false,
      damage: reducedDamage,
      currentHealth: this.currentHealth,
      isDead: this.currentHealth <= 0,
      isCounter: isCounter
    }
  }

  heal(amount) {
    const oldHealth = this.currentHealth
    this.currentHealth = Math.min(this.stats.maxHealth, this.currentHealth + amount)
    return this.currentHealth - oldHealth
  }
}

class CombatManager {
  constructor(player, enemy, type = CombatType.NORMAL) {
    this.player = player
    this.enemy = enemy
    this.type = type
    this.state = CombatState.READY
    this.round = 0
    this.maxRounds = 10
    this.roundsData = []
  }

  start() {
    this.state = CombatState.IN_PROGRESS
    return this.state
  }

  executeFullCombat() {
    this.start()
    while (this.state === CombatState.IN_PROGRESS && this.round < this.maxRounds) {
      this.executeTurn()
    }
    if (this.state === CombatState.IN_PROGRESS) {
      this.state = CombatState.DEFEAT
    }
    return {
      rounds: this.roundsData,
      result: this.state,
      finalPlayerHealth: this.player.currentHealth,
      finalEnemyHealth: this.enemy.currentHealth
    }
  }

  executeTurn() {
    if (this.state !== CombatState.IN_PROGRESS) return null
    this.round++
    if (this.round > this.maxRounds) {
      this.state = CombatState.DEFEAT
      return { results: [], state: this.state }
    }

    const roundData = {
      round: this.round,
      actions: []
    }

    const playerSpeed = this.player.stats.speed * (1 + this.player.stats.combatBoost)
    const enemySpeed = this.enemy.stats.speed * (1 + this.enemy.stats.combatBoost)
    const firstAttacker = playerSpeed >= enemySpeed ? this.player : this.enemy
    const secondAttacker = playerSpeed >= enemySpeed ? this.enemy : this.player

    // First attack
    const firstAttack = firstAttacker.stats.calculateDamage(secondAttacker)
    const firstResult = secondAttacker.takeDamage(firstAttack.damage, firstAttacker)

    const firstAction = {
      attacker: firstAttacker === this.player ? 'player' : 'enemy',
      defender: secondAttacker === this.player ? 'player' : 'enemy',
      damage: firstResult.dodged ? 0 : firstResult.damage,
      isCrit: firstAttack.isCrit,
      isCombo: firstAttack.isCombo,
      isDodged: firstResult.dodged,
      isVampire: firstAttack.isVampire,
      isStun: firstAttack.isStun,
      isCounter: false,
      attackerHealth: firstAttacker.currentHealth,
      defenderHealth: secondAttacker.currentHealth,
      healAmount: 0
    }

    if (firstAttack.isVampire && !firstResult.dodged) {
      const healAmount = firstResult.damage * 0.3
      firstAttacker.heal(healAmount)
      firstAction.healAmount = healAmount
      firstAction.attackerHealth = firstAttacker.currentHealth
    }

    roundData.actions.push(firstAction)

    if (firstResult.isDead) {
      this.state = firstAttacker === this.player ? CombatState.VICTORY : CombatState.DEFEAT
      this.roundsData.push(roundData)
      return { results: roundData.actions, state: this.state }
    }

    // Second attack (if not stunned)
    if (!firstAttack.isStun) {
      const secondAttack = secondAttacker.stats.calculateDamage(firstAttacker)
      const secondResult = firstAttacker.takeDamage(secondAttack.damage, secondAttacker)

      const secondAction = {
        attacker: secondAttacker === this.player ? 'player' : 'enemy',
        defender: firstAttacker === this.player ? 'player' : 'enemy',
        damage: secondResult.dodged ? 0 : secondResult.damage,
        isCrit: secondAttack.isCrit,
        isCombo: secondAttack.isCombo,
        isDodged: secondResult.dodged,
        isVampire: secondAttack.isVampire,
        isStun: secondAttack.isStun,
        isCounter: firstResult.isCounter,
        attackerHealth: secondAttacker.currentHealth,
        defenderHealth: firstAttacker.currentHealth,
        healAmount: 0
      }

      if (secondAttack.isVampire && !secondResult.dodged) {
        const healAmount = secondResult.damage * 0.3
        secondAttacker.heal(healAmount)
        secondAction.healAmount = healAmount
        secondAction.attackerHealth = secondAttacker.currentHealth
      }

      roundData.actions.push(secondAction)

      if (secondResult.isDead) {
        this.state = secondAttacker === this.player ? CombatState.VICTORY : CombatState.DEFEAT
      }
    }

    this.roundsData.push(roundData)
    return { results: roundData.actions, state: this.state }
  }
}

function generateEnemy(level, type = CombatType.NORMAL, difficulty = 1) {
  const baseStats = {
    health: 100 + difficulty * level * 200,
    damage: 8 + difficulty * level * 2,
    defense: 3 + difficulty * level * 2,
    speed: 5 + difficulty * level * 2,
    critRate: 0.05 + difficulty * level * 0.02,
    comboRate: 0.03 + difficulty * level * 0.02,
    counterRate: 0.03 + difficulty * level * 0.02,
    stunRate: 0.02 + difficulty * level * 0.01,
    dodgeRate: 0.05 + difficulty * level * 0.02,
    vampireRate: 0.02 + difficulty * level * 0.01,
    critResist: 0.02 + difficulty * level * 0.01,
    comboResist: 0.02 + difficulty * level * 0.01,
    counterResist: 0.02 + difficulty * level * 0.01,
    stunResist: 0.02 + difficulty * level * 0.01,
    dodgeResist: 0.02 + difficulty * level * 0.01,
    vampireResist: 0.02 + difficulty * level * 0.01,
    healBoost: 0.05 + difficulty * level * 0.02,
    critDamageBoost: 0.2 + difficulty * level * 0.1,
    critDamageReduce: 0.1 + difficulty * level * 0.05,
    finalDamageBoost: 0.05 + difficulty * level * 0.02,
    finalDamageReduce: 0.05 + difficulty * level * 0.02,
    combatBoost: 0.03 + difficulty * level * 0.02,
    resistanceBoost: 0.03 + difficulty * level * 0.02
  }

  switch (type) {
    case CombatType.ELITE:
      Object.keys(baseStats).forEach(key => {
        if (typeof baseStats[key] === 'number') {
          if (key.includes('Rate') || key.includes('Resist') || key.includes('Boost') || key.includes('Reduce')) {
            baseStats[key] = Math.min(0.8, baseStats[key] * 1.3)
          } else {
            baseStats[key] *= 1.5
          }
        }
      })
      break
    case CombatType.BOSS:
      Object.keys(baseStats).forEach(key => {
        if (typeof baseStats[key] === 'number') {
          if (key.includes('Rate') || key.includes('Resist') || key.includes('Boost') || key.includes('Reduce')) {
            baseStats[key] = Math.min(0.9, baseStats[key] * 1.5)
          } else {
            baseStats[key] *= 2
          }
        }
      })
      break
  }

  let enemyName = ''
  const normalNames = ['野狼', '山猪', '毒蛇', '黑熊', '猛虎', '恶狼', '巨蟒', '狂狮']
  const eliteNames = ['赤焰虎', '玄冰蟒', '紫电豹', '金刚猿', '幽冥狼', '碧水蛟', '雷霆鹰', '烈风豹']
  const bossNames = ['九尾天狐', '万年龙蟒', '太古神虎', '玄天冰凤', '幽冥魔龙', '混沌巨兽', '远古天蟒', '不死火凤']
  
  switch (type) {
    case CombatType.BOSS:
      enemyName = bossNames[Math.floor(level / 10) % bossNames.length]
      break
    case CombatType.ELITE:
      enemyName = eliteNames[Math.floor(level / 5) % eliteNames.length]
      break
    default:
      enemyName = normalNames[level % normalNames.length]
  }

  return new CombatEntity(enemyName, level, baseStats, '燃火期一层')
}

export {
  CombatState,
  CombatType,
  CombatStats,
  CombatEntity,
  CombatManager,
  generateEnemy
}
