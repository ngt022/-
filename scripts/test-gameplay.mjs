#!/usr/bin/env node
/**
 * 火之文明 - 深度游戏流程测试
 * 用 Tracy 的账号测试所有功能模块的联通性
 */
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0'

const BASE = process.env.TEST_URL || 'https://23.95.222.209:8443'
const TOKEN = process.env.TOKEN // 从环境变量传入

if (!TOKEN) {
  console.error('❌ 请设置 TOKEN 环境变量')
  process.exit(1)
}

const results = { pass: 0, fail: 0, warn: 0, tests: [] }

function log(icon, msg) { console.log(`  ${icon} ${msg}`) }

function record(name, status, detail = '') {
  results.tests.push({ name, status, detail })
  if (status === 'pass') results.pass++
  else if (status === 'fail') results.fail++
  else results.warn++
}

async function api(method, path, body = null) {
  const opts = {
    method,
    headers: { 'Authorization': `Bearer ${TOKEN}`, 'Content-Type': 'application/json' }
  }
  if (body) opts.body = JSON.stringify(body)
  const res = await fetch(`${BASE}${path}`, opts)
  const text = await res.text()
  let data
  try { data = JSON.parse(text) } catch { data = { raw: text } }
  return { status: res.status, data, ok: res.ok }
}

async function testModule(name, fn) {
  console.log(`\n📋 ${name}`)
  try {
    await fn()
  } catch (e) {
    log('💥', `模块异常: ${e.message}`)
    record(`${name} - 模块级异常`, 'fail', e.message)
  }
}

// ============================================================
console.log('🔥 火之文明 深度游戏流程测试')
console.log('========================')
console.log(`🌐 ${BASE}`)
console.log(`👤 Tracy (0xfad7eb...)`)
console.log(`⏰ ${new Date().toLocaleString('zh-CN')}\n`)

// === 1. 游戏存档 ===
await testModule('游戏存档', async () => {
  // 加载存档
  const load = await api('GET', '/api/game/load')
  if (load.ok) {
    const gd = load.data?.gameData || load.data?.game_data
    log('✅', `加载存档 - 等级:${gd?.level || '?'} 灵石:${gd?.spiritStones || 0}`)
    record('加载存档', 'pass')
  } else {
    log('❌', `加载存档失败: ${JSON.stringify(load.data)}`)
    record('加载存档', 'fail', JSON.stringify(load.data))
  }

  // 保存存档
  const save = await api('POST', '/api/game/save', {
    gameData: { level: 1, spiritStones: 100, spirit: 50, cultivation: 0, maxCultivation: 100 }
  })
  if (save.status < 500) {
    log('✅', `保存存档 - ${save.status}`)
    record('保存存档', 'pass')
  } else {
    log('❌', `保存存档 500: ${JSON.stringify(save.data)}`)
    record('保存存档', 'fail')
  }
})

// === 2. VIP/签到/月卡 ===
await testModule('VIP/签到/月卡', async () => {
  const vip = await api('GET', '/api/vip/info')
  log(vip.ok ? '✅' : '❌', `VIP信息 - ${vip.status} ${JSON.stringify(vip.data).slice(0, 80)}`)
  record('VIP信息', vip.status < 500 ? 'pass' : 'fail')

  const sign = await api('POST', '/api/sign/daily')
  log(sign.status < 500 ? '✅' : '❌', `每日签到 - ${sign.status} ${sign.data?.message || sign.data?.error || 'OK'}`)
  record('每日签到', sign.status < 500 ? 'pass' : 'fail')

  const mc = await api('GET', '/api/monthly-card/status')
  log(mc.ok ? '✅' : '❌', `月卡状态 - ${mc.status}`)
  record('月卡状态', mc.status < 500 ? 'pass' : 'fail')

  const claim = await api('POST', '/api/monthly-card/claim')
  log(claim.status < 500 ? '✅' : '⚠️', `月卡领取 - ${claim.status} ${claim.data?.error || 'OK'}`)
  record('月卡领取', claim.status < 500 ? 'pass' : 'fail')
})

// === 3. 排行榜 ===
await testModule('排行榜', async () => {
  for (const type of ['level', 'combat', 'spirit_stones', 'realm']) {
    const r = await api('GET', `/api/leaderboard/${type}`)
    log(r.status < 500 ? '✅' : '❌', `排行榜[${type}] - ${r.status} 条目:${Array.isArray(r.data) ? r.data.length : r.data?.data?.length || '?'}`)
    record(`排行榜[${type}]`, r.status < 500 ? 'pass' : 'fail')
  }
})

// === 4. 活动 ===
await testModule('活动系统', async () => {
  const active = await api('GET', '/api/events/active')
  log(active.ok ? '✅' : '❌', `活动列表 - ${active.status} 数量:${Array.isArray(active.data) ? active.data.length : '?'}`)
  record('活动列表', active.status < 500 ? 'pass' : 'fail')

  const effects = await api('GET', '/api/events/effects')
  log(effects.ok ? '✅' : '❌', `活动效果 - ${effects.status}`)
  record('活动效果', effects.status < 500 ? 'pass' : 'fail')
})

// === 5. PK ===
await testModule('PK系统', async () => {
  const hist = await api('GET', '/api/pk/history')
  log(hist.ok ? '✅' : '❌', `PK历史 - ${hist.status}`)
  record('PK历史', hist.status < 500 ? 'pass' : 'fail')

  const stats = await api('GET', '/api/pk/stats')
  log(stats.ok ? '✅' : '❌', `PK统计 - ${stats.status}`)
  record('PK统计', stats.status < 500 ? 'pass' : 'fail')
})

// === 6. 宗门 ===
await testModule('宗门系统', async () => {
  const my = await api('GET', '/api/sect/my')
  log(my.status < 500 ? '✅' : '❌', `我的宗门 - ${my.status} ${my.data?.sect?.name || '未加入'}`)
  record('我的宗门', my.status < 500 ? 'pass' : 'fail')

  const list = await api('GET', '/api/sect/list')
  const sects = list.data?.data || list.data || []
  log(list.ok ? '✅' : '❌', `宗门列表 - ${list.status} 数量:${Array.isArray(sects) ? sects.length : '?'}`)
  record('宗门列表', list.status < 500 ? 'pass' : 'fail')

  const members = await api('GET', '/api/sect/members?sectId=1')
  log(members.status < 500 ? '✅' : '❌', `宗门成员 - ${members.status}`)
  record('宗门成员', members.status < 500 ? 'pass' : 'fail')

  const tasks = await api('GET', '/api/sect/tasks')
  log(tasks.status < 500 ? '✅' : '❌', `宗门任务 - ${tasks.status} ${tasks.data?.error || 'OK'}`)
  record('宗门任务', tasks.status < 500 ? 'pass' : 'fail')
})

// === 7. 世界Boss ===
await testModule('世界Boss', async () => {
  const current = await api('GET', '/api/boss/current')
  log(current.ok ? '✅' : '❌', `当前Boss - ${current.status} ${current.data?.boss?.name || '无Boss'}`)
  record('当前Boss', current.status < 500 ? 'pass' : 'fail')

  const ranking = await api('GET', '/api/boss/ranking')
  log(ranking.ok ? '✅' : '❌', `Boss排名 - ${ranking.status}`)
  record('Boss排名', ranking.status < 500 ? 'pass' : 'fail')

  const rewards = await api('GET', '/api/boss/rewards')
  log(rewards.ok ? '✅' : '❌', `Boss奖励 - ${rewards.status}`)
  record('Boss奖励', rewards.status < 500 ? 'pass' : 'fail')

  const history = await api('GET', '/api/boss/history')
  log(history.ok ? '✅' : '❌', `Boss历史 - ${history.status}`)
  record('Boss历史', history.status < 500 ? 'pass' : 'fail')

  // 尝试攻击
  const attack = await api('POST', '/api/boss/attack')
  log(attack.status < 500 ? '✅' : '❌', `攻击Boss - ${attack.status} ${attack.data?.error || attack.data?.message || 'OK'}`)
  record('攻击Boss', attack.status < 500 ? 'pass' : 'fail')
})

// === 8. 好友 ===
await testModule('好友系统', async () => {
  const list = await api('GET', '/api/friend/list')
  log(list.ok ? '✅' : '❌', `好友列表 - ${list.status} 数量:${list.data?.data?.length || 0}`)
  record('好友列表', list.status < 500 ? 'pass' : 'fail')

  const requests = await api('GET', '/api/friend/requests')
  log(requests.ok ? '✅' : '❌', `好友请求 - ${requests.status}`)
  record('好友请求', requests.status < 500 ? 'pass' : 'fail')

  const search = await api('POST', '/api/friend/search', { keyword: '无名' })
  log(search.ok ? '✅' : '❌', `搜索好友 - ${search.status} 结果:${search.data?.data?.length || 0}`)
  record('搜索好友', search.status < 500 ? 'pass' : 'fail')

  const gifts = await api('GET', '/api/friend/gifts')
  log(gifts.ok ? '✅' : '❌', `礼物列表 - ${gifts.status}`)
  record('礼物列表', gifts.status < 500 ? 'pass' : 'fail')
})

// === 9. 拍卖 ===
await testModule('拍卖系统', async () => {
  const browse = await api('GET', '/api/auction/browse')
  log(browse.ok ? '✅' : '❌', `拍卖浏览 - ${browse.status} 数量:${browse.data?.data?.length || 0}`)
  record('拍卖浏览', browse.status < 500 ? 'pass' : 'fail')

  const myList = await api('GET', '/api/auction/my-listings')
  log(myList.ok ? '✅' : '❌', `我的上架 - ${myList.status}`)
  record('我的上架', myList.status < 500 ? 'pass' : 'fail')

  const myBids = await api('GET', '/api/auction/my-bids')
  log(myBids.ok ? '✅' : '❌', `我的出价 - ${myBids.status}`)
  record('我的出价', myBids.status < 500 ? 'pass' : 'fail')

  const history = await api('GET', '/api/auction/history')
  log(history.ok ? '✅' : '❌', `拍卖历史 - ${history.status}`)
  record('拍卖历史', history.status < 500 ? 'pass' : 'fail')
})

// === 10. 每日副本 ===
await testModule('每日副本', async () => {
  const list = await api('GET', '/api/dungeon-daily/list')
  log(list.ok ? '✅' : '❌', `副本列表 - ${list.status} 数量:${list.data?.data?.length || list.data?.length || '?'}`)
  record('副本列表', list.status < 500 ? 'pass' : 'fail')

  // 尝试进入第一个副本
  const enter = await api('POST', '/api/dungeon-daily/enter', { dungeonId: 1 })
  log(enter.status < 500 ? '✅' : '❌', `进入副本 - ${enter.status} ${enter.data?.error || enter.data?.message || 'OK'}`)
  record('进入副本', enter.status < 500 ? 'pass' : 'fail')

  const history = await api('GET', '/api/dungeon-daily/history')
  log(history.ok ? '✅' : '❌', `副本历史 - ${history.status}`)
  record('副本历史', history.status < 500 ? 'pass' : 'fail')
})

// === 11. 坐骑 ===
await testModule('坐骑系统', async () => {
  const list = await api('GET', '/api/mount/list')
  log(list.ok ? '✅' : '❌', `坐骑商店 - ${list.status} 数量:${list.data?.data?.length || list.data?.length || '?'}`)
  record('坐骑商店', list.status < 500 ? 'pass' : 'fail')

  const my = await api('GET', '/api/mount/my')
  log(my.ok ? '✅' : '❌', `我的坐骑 - ${my.status} 数量:${my.data?.data?.length || 0}`)
  record('我的坐骑', my.status < 500 ? 'pass' : 'fail')

  const active = await api('GET', '/api/mount/active')
  log(active.ok ? '✅' : '❌', `当前坐骑 - ${active.status} ${active.data?.mount?.name || '无'}`)
  record('当前坐骑', active.status < 500 ? 'pass' : 'fail')
})

// === 12. 称号 ===
await testModule('称号系统', async () => {
  const list = await api('GET', '/api/title/list')
  log(list.ok ? '✅' : '❌', `称号列表 - ${list.status} 数量:${list.data?.data?.length || list.data?.length || '?'}`)
  record('称号列表', list.status < 500 ? 'pass' : 'fail')

  const my = await api('GET', '/api/title/my')
  log(my.ok ? '✅' : '❌', `我的称号 - ${my.status}`)
  record('我的称号', my.status < 500 ? 'pass' : 'fail')

  const check = await api('POST', '/api/title/check')
  log(check.ok ? '✅' : '❌', `检查称号 - ${check.status} 新获得:${check.data?.newTitles?.length || 0}`)
  record('检查称号', check.status < 500 ? 'pass' : 'fail')
})

// === 13. 飞升 ===
await testModule('飞升系统', async () => {
  const info = await api('GET', '/api/ascension/info')
  log(info.ok ? '✅' : '❌', `飞升信息 - ${info.status} ${JSON.stringify(info.data).slice(0, 100)}`)
  record('飞升信息', info.status < 500 ? 'pass' : 'fail')

  const perks = await api('GET', '/api/ascension/perks')
  log(perks.ok ? '✅' : '❌', `飞升特权 - ${perks.status}`)
  record('飞升特权', perks.status < 500 ? 'pass' : 'fail')

  const ranking = await api('GET', '/api/ascension/ranking')
  log(ranking.ok ? '✅' : '❌', `飞升排名 - ${ranking.status}`)
  record('飞升排名', ranking.status < 500 ? 'pass' : 'fail')

  const ascend = await api('POST', '/api/ascension/ascend')
  log(ascend.status < 500 ? '✅' : '❌', `尝试飞升 - ${ascend.status} ${ascend.data?.error || 'OK'}`)
  record('尝试飞升', ascend.status < 500 ? 'pass' : 'fail')
})

// === 14. 充值 ===
await testModule('充值系统', async () => {
  const history = await api('GET', '/api/recharge/history')
  log(history.ok ? '✅' : '❌', `充值历史 - ${history.status}`)
  record('充值历史', history.status < 500 ? 'pass' : 'fail')
})

// === 15. 公告 ===
await testModule('公告系统', async () => {
  const ann = await api('GET', '/api/announcements')
  log(ann.ok ? '✅' : '❌', `公告列表 - ${ann.status} 数量:${Array.isArray(ann.data) ? ann.data.length : ann.data?.data?.length || '?'}`)
  record('公告列表', ann.status < 500 ? 'pass' : 'fail')
})

// === 16. 宗门战 ===
await testModule('宗门战', async () => {
  const pending = await api('GET', '/api/sect-war/pending')
  log(pending.ok ? '✅' : '❌', `待处理战争 - ${pending.status}`)
  record('待处理战争', pending.status < 500 ? 'pass' : 'fail')

  const current = await api('GET', '/api/sect-war/current')
  log(current.ok ? '✅' : '❌', `当前战争 - ${current.status}`)
  record('当前战争', current.status < 500 ? 'pass' : 'fail')

  const history = await api('GET', '/api/sect-war/history')
  log(history.ok ? '✅' : '❌', `战争历史 - ${history.status}`)
  record('战争历史', history.status < 500 ? 'pass' : 'fail')

  const ranking = await api('GET', '/api/sect-war/ranking')
  log(ranking.ok ? '✅' : '❌', `战争排名 - ${ranking.status}`)
  record('战争排名', ranking.status < 500 ? 'pass' : 'fail')
})

// === 汇总 ===
console.log('\n========================')
console.log('📊 测试报告')
console.log(`  ✅ 通过: ${results.pass}`)
console.log(`  ❌ 失败: ${results.fail}`)
console.log(`  ⚠️  警告: ${results.warn}`)
console.log(`  📝 总计: ${results.tests.length}`)
console.log(`  🎯 通过率: ${(results.pass / results.tests.length * 100).toFixed(1)}%`)
console.log('========================')

if (results.fail > 0) {
  console.log('\n❌ 失败详情:')
  results.tests.filter(t => t.status === 'fail').forEach((t, i) => {
    console.log(`  ${i + 1}. ${t.name}: ${t.detail}`)
  })
}
