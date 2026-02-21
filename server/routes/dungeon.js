import { CombatManager, CombatEntity, CombatType, generateEnemy } from '../utils/combat.js'

// 活跃副本状态存储 (内存)
const activeDungeons = new Map()

// 难度倍率配置
const DIFFICULTY_MULTIPLIERS = {
  1: { name: '简单', multiplier: 1 },
  2: { name: '普通', multiplier: 2 },
  5: { name: '困难', multiplier: 5 },
  10: { name: '地狱', multiplier: 10 },
  100: { name: '通天', multiplier: 100 }
}

// 增益选项池
const roguelikeOptions = {
  common: [
    { id: 'heal', name: '气血增加', description: '增加10%血量', effect: (stats) => { stats.maxHealth *= 1.1; stats.health = stats.maxHealth } },
    { id: 'small_buff', name: '小幅强化', description: '增加10%伤害', effect: (stats) => { stats.finalDamageBoost += 0.1 } },
    { id: 'defense_boost', name: '铁壁', description: '提升20%防御力', effect: (stats) => { stats.defense *= 1.2 } },
    { id: 'speed_boost', name: '疾风', description: '提升15%速度', effect: (stats) => { stats.speed *= 1.15 } },
    { id: 'crit_boost', name: '会心', description: '提升15%暴击率', effect: (stats) => { stats.critRate += 0.15 } },
    { id: 'dodge_boost', name: '轻身', description: '提升15%闪避率', effect: (stats) => { stats.dodgeRate += 0.15 } },
    { id: 'vampire_boost', name: '吸血', description: '提升10%吸血率', effect: (stats) => { stats.vampireRate += 0.1 } },
    { id: 'combat_boost', name: '战意', description: '提升10%战斗属性', effect: (stats) => { stats.combatBoost += 0.1 } }
  ],
  rare: [
    { id: 'crit_mastery', name: '会心精通', description: '暴击率提升10%，暴击伤害提升20%', effect: (stats) => { stats.critRate += 0.1; stats.critDamageBoost += 0.2 } },
    { id: 'dodge_master', name: '无影', description: '闪避率提升10%', effect: (stats) => { stats.dodgeRate += 0.1 } },
    { id: 'combo_master', name: '连击精通', description: '连击率提升10%', effect: (stats) => { stats.comboRate += 0.1 } },
    { id: 'vampire_master', name: '血魔', description: '吸血率提升5%', effect: (stats) => { stats.vampireRate += 0.05 } },
    { id: 'stun_master', name: '震慑', description: '眩晕率提升5%', effect: (stats) => { stats.stunRate += 0.05 } }
  ],
  epic: [
    { id: 'ultimate_power', name: '极限突破', description: '所有战斗属性提升50%', effect: (stats) => { stats.combatBoost += 0.5; stats.finalDamageBoost += 0.5 } },
    { id: 'divine_protection', name: '天道庇护', description: '最终减伤提升30%', effect: (stats) => { stats.finalDamageReduce += 0.3 } },
    { id: 'combat_master', name: '战斗大师', description: '所有战斗属性和抗性提升25%', effect: (stats) => { stats.combatBoost += 0.25; stats.resistanceBoost += 0.25 } },
    { id: 'immortal_body', name: '不朽之躯', description: '生命上限提升100%，最终减伤提升20%', effect: (stats) => { stats.maxHealth *= 2; stats.health = stats.maxHealth; stats.finalDamageReduce += 0.2 } },
    { id: 'celestial_might', name: '天人合一', description: '所有战斗属性提升40%，生命值增加50%', effect: (stats) => { stats.combatBoost += 0.4; stats.maxHealth *= 1.5; stats.health = Math.min(stats.maxHealth, stats.health + stats.maxHealth * 0.5) } },
    { id: 'battle_sage_supreme', name: '战圣至尊', description: '暴击率提升40%，暴击伤害提升80%，最终伤害提升20%', effect: (stats) => { stats.critRate += 0.4; stats.critDamageBoost += 0.8; stats.finalDamageBoost += 0.2 } }
  ]
}

// 获取随机选项
function getRandomOptions(floor) {
  let commonChance = 0.7
  let rareChance = 0.25
  let epicChance = 0.05
  
  if (floor % 10 === 0) {
    commonChance = 0.5
    rareChance = 0.3
    epicChance = 0.2
  } else if (floor % 5 === 0) {
    commonChance = 0.5
    rareChance = 0.35
    epicChance = 0.15
  }

  const count = 3
  const selected = []
  const usedIds = new Set()

  while (selected.length < count) {
    const rand = Math.random()
    let pool = 'common'
    if (rand < epicChance) pool = 'epic'
    else if (rand < epicChance + rareChance) pool = 'rare'

    const options = roguelikeOptions[pool].filter(opt => !usedIds.has(opt.id))
    if (options.length > 0) {
      const index = Math.floor(Math.random() * options.length)
      const option = { ...options[index], type: pool }
      selected.push(option)
      usedIds.add(option.id)
    } else {
      const allOptions = [...roguelikeOptions.common, ...roguelikeOptions.rare, ...roguelikeOptions.epic]
        .filter(opt => !usedIds.has(opt.id))
      if (allOptions.length > 0) {
        const index = Math.floor(Math.random() * allOptions.length)
        const option = { ...allOptions[index], type: pool }
        selected.push(option)
        usedIds.add(option.id)
      }
    }
  }
  return selected
}

// 从玩家数据构建战斗属性
function buildPlayerCombatStats(gameData) {
  const base = gameData.baseAttributes || {}
  const combat = gameData.combatAttributes || {}
  const resist = gameData.combatResistance || {}
  const special = gameData.specialAttributes || {}
  
  // 计算装备加成
  const equipped = gameData.equippedArtifacts || {}
  let equipBonus = {
    attack: 0, health: 0, defense: 0, speed: 0,
    critRate: 0, comboRate: 0, counterRate: 0, stunRate: 0, dodgeRate: 0, vampireRate: 0,
    critResist: 0, comboResist: 0, counterResist: 0, stunResist: 0, dodgeResist: 0, vampireResist: 0,
    healBoost: 0, critDamageBoost: 0, critDamageReduce: 0, finalDamageBoost: 0, finalDamageReduce: 0,
    combatBoost: 0, resistanceBoost: 0
  }
  
  Object.values(equipped).forEach(artifact => {
    if (!artifact || !artifact.stats) return
    Object.entries(artifact.stats).forEach(([key, value]) => {
      if (equipBonus[key] !== undefined) {
        equipBonus[key] += value
      }
    })
  })
  
  // 计算焰兽加成
  let petBonus = {}
  if (gameData.activePet) {
    const pet = gameData.activePet
    const qualityBonusMap = { divine: 0.15, celestial: 0.12, mystic: 0.09, spiritual: 0.06, mortal: 0.03 }
    const baseBonus = qualityBonusMap[pet.rarity] || 0
    const starBonus = (pet.star || 0) * 0.01
    const levelBonus = ((pet.level || 1) - 1) * (baseBonus * 0.1)
    const phase = Math.floor((pet.star || 0) / 5)
    const phaseBonus = phase * (baseBonus * 0.5)
    const finalBonus = baseBonus + starBonus + levelBonus + phaseBonus
    const combatBonus = finalBonus * 0.5
    
    petBonus = {
      attack: finalBonus, defense: finalBonus, health: finalBonus,
      critRate: combatBonus, comboRate: combatBonus, counterRate: combatBonus,
      stunRate: combatBonus, dodgeRate: combatBonus, vampireRate: combatBonus,
      critResist: combatBonus, comboResist: combatBonus, counterResist: combatBonus,
      stunResist: combatBonus, dodgeResist: combatBonus, vampireResist: combatBonus,
      healBoost: combatBonus, critDamageBoost: combatBonus, critDamageReduce: combatBonus,
      finalDamageBoost: combatBonus, finalDamageReduce: combatBonus,
      combatBoost: combatBonus, resistanceBoost: combatBonus
    }
  }

  return {
    health: (base.health || 100) + equipBonus.health + (petBonus.health || 0),
    damage: (base.attack || 10) + equipBonus.attack + (petBonus.attack || 0),
    defense: (base.defense || 5) + equipBonus.defense + (petBonus.defense || 0),
    speed: (base.speed || 10) + equipBonus.speed + (petBonus.speed || 0),
    critRate: (combat.critRate || 0) + equipBonus.critRate + (petBonus.critRate || 0),
    comboRate: (combat.comboRate || 0) + equipBonus.comboRate + (petBonus.comboRate || 0),
    counterRate: (combat.counterRate || 0) + equipBonus.counterRate + (petBonus.counterRate || 0),
    stunRate: (combat.stunRate || 0) + equipBonus.stunRate + (petBonus.stunRate || 0),
    dodgeRate: (combat.dodgeRate || 0) + equipBonus.dodgeRate + (petBonus.dodgeRate || 0),
    vampireRate: (combat.vampireRate || 0) + equipBonus.vampireRate + (petBonus.vampireRate || 0),
    critResist: (resist.critResist || 0) + equipBonus.critResist + (petBonus.critResist || 0),
    comboResist: (resist.comboResist || 0) + equipBonus.comboResist + (petBonus.comboResist || 0),
    counterResist: (resist.counterResist || 0) + equipBonus.counterResist + (petBonus.counterResist || 0),
    stunResist: (resist.stunResist || 0) + equipBonus.stunResist + (petBonus.stunResist || 0),
    dodgeResist: (resist.dodgeResist || 0) + equipBonus.dodgeResist + (petBonus.dodgeResist || 0),
    vampireResist: (resist.vampireResist || 0) + equipBonus.vampireResist + (petBonus.vampireResist || 0),
    healBoost: (special.healBoost || 0) + equipBonus.healBoost + (petBonus.healBoost || 0),
    critDamageBoost: (special.critDamageBoost || 0.5) + equipBonus.critDamageBoost + (petBonus.critDamageBoost || 0),
    critDamageReduce: (special.critDamageReduce || 0) + equipBonus.critDamageReduce + (petBonus.critDamageReduce || 0),
    finalDamageBoost: (special.finalDamageBoost || 0) + equipBonus.finalDamageBoost + (petBonus.finalDamageBoost || 0),
    finalDamageReduce: (special.finalDamageReduce || 0) + equipBonus.finalDamageReduce + (petBonus.finalDamageReduce || 0),
    combatBoost: (special.combatBoost || 0) + equipBonus.combatBoost + (petBonus.combatBoost || 0),
    resistanceBoost: (special.resistanceBoost || 0) + equipBonus.resistanceBoost + (petBonus.resistanceBoost || 0)
  }
}

// 注册路由
function registerDungeonRoutes(app, pool, auth) {
  
  // 开始副本
  app.post('/api/dungeon/start', auth, async (req, res) => {
    try {
      const { difficulty = 1 } = req.body
      const wallet = req.user.wallet
      
      if (!DIFFICULTY_MULTIPLIERS[difficulty]) {
        return res.status(400).json({ error: '无效的难度' })
      }
      
      const playerResult = await pool.query('SELECT * FROM players WHERE wallet = $1', [wallet])
      if (playerResult.rows.length === 0) {
        return res.status(404).json({ error: '玩家不存在' })
      }
      
      const player = playerResult.rows[0]
      const gameData = typeof player.game_data === 'string' ? JSON.parse(player.game_data) : (player.game_data || {})
      
      // 获取该难度的起始层数
      let startingFloor = 0
      switch (difficulty) {
        case 2: startingFloor = gameData.dungeonHighestFloor_2 || 0; break
        case 5: startingFloor = gameData.dungeonHighestFloor_5 || 0; break
        case 10: startingFloor = gameData.dungeonHighestFloor_10 || 0; break
        case 100: startingFloor = gameData.dungeonHighestFloor_100 || 0; break
        default: startingFloor = gameData.dungeonHighestFloor || 0
      }
      
      // 创建副本状态
      const dungeonState = {
        wallet,
        difficulty,
        floor: startingFloor + 1,
        playerStats: buildPlayerCombatStats(gameData),
        originalPlayerStats: buildPlayerCombatStats(gameData),
        buffs: [],
        inCombat: false,
        currentEnemy: null,
        playerHealth: 0,
        createdAt: Date.now()
      }
      
      // 初始化玩家血量
      dungeonState.playerHealth = dungeonState.playerStats.health
      
      // 生成第一层敌人
      const isBossFloor = dungeonState.floor % 10 === 0
      const isEliteFloor = dungeonState.floor % 5 === 0
      const enemyType = isBossFloor ? CombatType.BOSS : isEliteFloor ? CombatType.ELITE : CombatType.NORMAL
      const enemy = generateEnemy(dungeonState.floor, enemyType, difficulty)
      
      dungeonState.currentEnemy = {
        name: enemy.name,
        level: enemy.level,
        type: enemyType,
        stats: {
          health: enemy.stats.maxHealth,
          maxHealth: enemy.stats.maxHealth,
          damage: enemy.stats.damage,
          defense: enemy.stats.defense,
          speed: enemy.stats.speed,
          critRate: enemy.stats.critRate,
          comboRate: enemy.stats.comboRate,
          counterRate: enemy.stats.counterRate,
          stunRate: enemy.stats.stunRate,
          dodgeRate: enemy.stats.dodgeRate,
          vampireRate: enemy.stats.vampireRate
        }
      }
      
      // 保存副本状态
      activeDungeons.set(wallet, dungeonState)
      
      res.json({
        floor: dungeonState.floor,
        enemy: dungeonState.currentEnemy,
        playerStats: dungeonState.playerStats,
        isElite: isEliteFloor,
        isBoss: isBossFloor
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // 执行战斗
  app.post('/api/dungeon/fight', auth, async (req, res) => {
    try {
      const { floor } = req.body
      const wallet = req.user.wallet
      
      const dungeon = activeDungeons.get(wallet)
      if (!dungeon) {
        return res.status(400).json({ error: '没有进行中的副本' })
      }
      
      if (dungeon.floor !== floor) {
        return res.status(400).json({ error: '层数不匹配' })
      }
      
      // 创建战斗实体
      const playerStats = { ...dungeon.playerStats, health: dungeon.playerHealth }
      const player = new CombatEntity(dungeon.playerName || '修士', dungeon.floor, playerStats, dungeon.playerRealm || '燃火期一层')
      player.currentHealth = dungeon.playerHealth
      
      const isBossFloor = dungeon.floor % 10 === 0
      const isEliteFloor = dungeon.floor % 5 === 0
      const enemyType = isBossFloor ? CombatType.BOSS : isEliteFloor ? CombatType.ELITE : CombatType.NORMAL
      const enemy = generateEnemy(dungeon.floor, enemyType, dungeon.difficulty)
      
      // 执行完整战斗
      const combatManager = new CombatManager(player, enemy, enemyType)
      const combatResult = combatManager.executeFullCombat()
      
      // 更新副本状态
      dungeon.playerHealth = combatResult.finalPlayerHealth
      dungeon.inCombat = false
      
      // 计算奖励（仅计算，不发放）
      let rewards = {}
      if (combatResult.result === 'victory') {
        const diffMult = DIFFICULTY_MULTIPLIERS[dungeon.difficulty].multiplier
        let spiritStones = (10 * dungeon.floor) * diffMult
        if (isBossFloor) spiritStones = Math.floor(spiritStones * 2)
        else if (isEliteFloor) spiritStones = Math.floor(spiritStones * 1.5)
        rewards = { spiritStones }
        
        // 精英怪额外奖励洗练石
        if (isEliteFloor && !isBossFloor) {
          rewards.refinementStones = dungeon.difficulty
        }
      }
      
      res.json({
        rounds: combatResult.rounds,
        result: combatResult.result,
        rewards,
        playerHealth: combatResult.finalPlayerHealth,
        enemyHealth: combatResult.finalEnemyHealth,
        floor: dungeon.floor
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // ========== 新增：领取奖励接口（防作弊）==========
  app.post('/api/dungeon/claim', auth, async (req, res) => {
    try {
      const { floor, result, difficulty } = req.body
      const wallet = req.user.wallet
      
      if (!floor || !result || !difficulty) {
        return res.status(400).json({ error: '参数缺失' })
      }
      
      if (result !== 'victory') {
        return res.status(400).json({ error: '只有胜利才能领取奖励' })
      }
      
      if (!DIFFICULTY_MULTIPLIERS[difficulty]) {
        return res.status(400).json({ error: '无效的难度' })
      }
      
      // 服务端重新计算奖励（防止前端作弊）
      const isBossFloor = floor % 10 === 0
      const isEliteFloor = floor % 5 === 0
      const diffMult = DIFFICULTY_MULTIPLIERS[difficulty].multiplier
      
      // 焰晶奖励公式：10 * floor * difficulty
      let spiritStones = (10 * floor) * diffMult
      if (isBossFloor) spiritStones = Math.floor(spiritStones * 2)
      else if (isEliteFloor) spiritStones = Math.floor(spiritStones * 1.5)
      
      const rewards = {
        spiritStones,
        refinementStones: 0
      }
      
      // 精英楼层额外奖励洗练石
      if (isEliteFloor && !isBossFloor) {
        rewards.refinementStones = difficulty
      }
      
      // 获取玩家当前数据
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      if (playerResult.rows.length === 0) {
        return res.status(404).json({ error: '玩家不存在' })
      }
      
      const gameData = typeof playerResult.rows[0].game_data === 'string' 
        ? JSON.parse(playerResult.rows[0].game_data) 
        : (playerResult.rows[0].game_data || {})
      
      // 发放奖励到数据库
      const currentStones = gameData.spiritStones || 0
      const currentRefinement = gameData.refinementStones || 0
      
      gameData.spiritStones = currentStones + rewards.spiritStones
      if (rewards.refinementStones > 0) {
        gameData.refinementStones = currentRefinement + rewards.refinementStones
      }
      
      // 更新统计数据
      gameData.dungeonTotalKills = (gameData.dungeonTotalKills || 0) + 1
      gameData.dungeonTotalRewards = (gameData.dungeonTotalRewards || 0) + rewards.spiritStones
      
      if (isBossFloor) {
        gameData.dungeonBossKills = (gameData.dungeonBossKills || 0) + 1
      } else if (isEliteFloor) {
        gameData.dungeonEliteKills = (gameData.dungeonEliteKills || 0) + 1
      }
      
      // 更新最高层数记录
      const floorKeyMap = {
        1: 'dungeonHighestFloor',
        2: 'dungeonHighestFloor_2',
        5: 'dungeonHighestFloor_5',
        10: 'dungeonHighestFloor_10',
        100: 'dungeonHighestFloor_100'
      }
      const floorKey = floorKeyMap[difficulty] || 'dungeonHighestFloor'
      const currentHighest = gameData[floorKey] || 0
      if (floor > currentHighest) {
        gameData[floorKey] = floor
      }
      
      // 保存到数据库
      await pool.query(
        `UPDATE players SET 
         game_data = $1,
         spirit_stones = $2
         WHERE wallet = $3`,
        [JSON.stringify(gameData), gameData.spiritStones, wallet]
      )
      
      res.json({
        ok: true,
        rewards: {
          spiritStones: rewards.spiritStones,
          refinementStones: rewards.refinementStones
        },
        newTotal: {
          spiritStones: gameData.spiritStones,
          refinementStones: gameData.refinementStones
        }
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // 选择增益
  app.post('/api/dungeon/select-buff', auth, async (req, res) => {
    try {
      const { buffId } = req.body
      const wallet = req.user.wallet
      
      const dungeon = activeDungeons.get(wallet)
      if (!dungeon) {
        return res.status(400).json({ error: '没有进行中的副本' })
      }
      
      // 查找增益选项
      let selectedBuff = null
      for (const pool of Object.values(roguelikeOptions)) {
        const found = pool.find(b => b.id === buffId)
        if (found) {
          selectedBuff = found
          break
        }
      }
      
      if (!selectedBuff) {
        return res.status(400).json({ error: '无效的增益选项' })
      }
      
      // 应用增益效果到玩家属性
      selectedBuff.effect(dungeon.playerStats)
      dungeon.buffs.push({
        id: selectedBuff.id,
        name: selectedBuff.name,
        description: selectedBuff.description,
        type: selectedBuff.type
      })
      
      // 更新血量
      if (dungeon.playerStats.health > dungeon.playerHealth) {
        dungeon.playerHealth = dungeon.playerStats.health
      }
      
      res.json({
        success: true,
        buffs: dungeon.buffs,
        playerStats: dungeon.playerStats
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // 进入下一层
  app.post('/api/dungeon/next-floor', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      
      const dungeon = activeDungeons.get(wallet)
      if (!dungeon) {
        return res.status(400).json({ error: '没有进行中的副本' })
      }
      
      // 增加层数
      dungeon.floor++
      
      // 检查是否需要显示增益选项
      const showOptions = dungeon.floor === 1 || dungeon.floor % 5 === 0
      let options = []
      if (showOptions) {
        options = getRandomOptions(dungeon.floor)
      }
      
      // 生成新敌人
      const isBossFloor = dungeon.floor % 10 === 0
      const isEliteFloor = dungeon.floor % 5 === 0
      const enemyType = isBossFloor ? CombatType.BOSS : isEliteFloor ? CombatType.ELITE : CombatType.NORMAL
      const enemy = generateEnemy(dungeon.floor, enemyType, dungeon.difficulty)
      
      dungeon.currentEnemy = {
        name: enemy.name,
        level: enemy.level,
        type: enemyType,
        stats: {
          health: enemy.stats.maxHealth,
          maxHealth: enemy.stats.maxHealth,
          damage: enemy.stats.damage,
          defense: enemy.stats.defense,
          speed: enemy.stats.speed,
          critRate: enemy.stats.critRate,
          comboRate: enemy.stats.comboRate,
          counterRate: enemy.stats.counterRate,
          stunRate: enemy.stats.stunRate,
          dodgeRate: enemy.stats.dodgeRate,
          vampireRate: enemy.stats.vampireRate
        }
      }
      
      res.json({
        floor: dungeon.floor,
        enemy: dungeon.currentEnemy,
        showOptions,
        options: options.map(o => ({ id: o.id, name: o.name, description: o.description, type: o.type })),
        isElite: isEliteFloor,
        isBoss: isBossFloor
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // 退出副本
  app.post('/api/dungeon/exit', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const { reachedFloor, result } = req.body
      
      const dungeon = activeDungeons.get(wallet)
      if (!dungeon) {
        return res.status(400).json({ error: '没有进行中的副本' })
      }
      
      // 更新最高层数记录
      const playerResult = await pool.query('SELECT game_data FROM players WHERE wallet = $1', [wallet])
      const gameData = typeof playerResult.rows[0].game_data === 'string' 
        ? JSON.parse(playerResult.rows[0].game_data) 
        : (playerResult.rows[0].game_data || {})
      
      const floorKeyMap = {
        1: 'dungeonHighestFloor',
        2: 'dungeonHighestFloor_2',
        5: 'dungeonHighestFloor_5',
        10: 'dungeonHighestFloor_10',
        100: 'dungeonHighestFloor_100'
      }
      const floorKey = floorKeyMap[dungeon.difficulty] || 'dungeonHighestFloor'
      const currentHighest = gameData[floorKey] || 0
      
      if (reachedFloor > currentHighest) {
        gameData[floorKey] = reachedFloor
        await pool.query(
          'UPDATE players SET game_data = $1 WHERE wallet = $2',
          [JSON.stringify(gameData), wallet]
        )
      }
      
      // 失败惩罚
      if (result === 'defeat') {
        if (dungeon.difficulty === 100) {
          // 通天难度跌落境界
          const randomGradeLoss = Math.floor(Math.random() * 3) + 1
          const newLevel = Math.max(1, (gameData.level || 1) - randomGradeLoss)
          gameData.level = newLevel
          gameData.cultivation = 0
          // 这里简化处理，实际应该根据境界系统重新计算
        } else {
          // 其他难度损失修为
          const cultivationLossRate = Math.random() * 0.4 + 0.1
          const cultivationLoss = Math.floor((gameData.cultivation || 0) * cultivationLossRate)
          gameData.cultivation = Math.max(0, (gameData.cultivation || 0) - cultivationLoss)
        }
        
        await pool.query(
          'UPDATE players SET game_data = $1 WHERE wallet = $2',
          [JSON.stringify(gameData), wallet]
        )
      }
      
      // 清除副本状态
      activeDungeons.delete(wallet)
      
      res.json({ success: true, saved: true })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })

  // 获取副本状态
  app.get('/api/dungeon/status', auth, async (req, res) => {
    try {
      const wallet = req.user.wallet
      const dungeon = activeDungeons.get(wallet)
      
      if (!dungeon) {
        return res.json({ active: false })
      }
      
      res.json({
        active: true,
        floor: dungeon.floor,
        difficulty: dungeon.difficulty,
        playerHealth: dungeon.playerHealth,
        buffs: dungeon.buffs,
        enemy: dungeon.currentEnemy
      })
    } catch (e) {
      res.status(500).json({ error: e.message })
    }
  })
}

export { registerDungeonRoutes }
