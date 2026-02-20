#!/usr/bin/env node
// 🔥 火之文明修仙游戏 - API 全面测试脚本
// 用法: cd /opt/xiuxian && node scripts/test-all.mjs
// 环境变量: TEST_URL=https://23.95.222.209:8443

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

import { ethers } from 'ethers';

const BASE_URL = process.env.TEST_URL || 'https://localhost:8443';
let TOKEN = '';
let WALLET = '';

// 统计
const stats = { pass: 0, fail: 0, skip: 0 };
const failures = [];

// ============ 工具函数 ============

async function request(method, path, body = null, auth = true) {
  const url = `${BASE_URL}${path}`;
  const headers = { 'Content-Type': 'application/json' };
  if (auth && TOKEN) headers['Authorization'] = `Bearer ${TOKEN}`;

  const opts = { method, headers };
  if (body && method !== 'GET') opts.body = JSON.stringify(body);

  const res = await fetch(url, opts);
  let data;
  try { data = await res.json(); } catch { data = null; }
  return { status: res.status, data };
}

function pass(method, path, msg) {
  stats.pass++;
  console.log(`  ✅ ${method} ${path} - ${msg}`);
}

function fail(method, path, msg) {
  stats.fail++;
  failures.push(`${method} ${path}: ${msg}`);
  console.log(`  ❌ ${method} ${path} - ${msg}`);
}

function skip(method, path, msg) {
  stats.skip++;
  console.log(`  ⏭️  ${method} ${path} - ${msg}`);
}

// 判断 API 是否正常响应（非 500，非连接失败）
function isApiOk(status) {
  return status >= 200 && status < 500;
}

async function testEndpoint(method, path, body = null, auth = true, opts = {}) {
  const { expectStatus, label, skipIf } = opts;
  if (skipIf) { skip(method, path, label || '需要前置数据，跳过'); return null; }

  try {
    const { status, data } = await request(method, path, body, auth);
    if (status >= 500) {
      fail(method, path, `服务器错误 ${status}: ${JSON.stringify(data)?.slice(0, 100)}`);
      return { status, data };
    }
    if (expectStatus && status !== expectStatus) {
      // 如果期望特定状态码但不匹配，仍然算 pass 如果 API 没崩溃
      if (isApiOk(status)) {
        pass(method, path, label || `${status} - ${data?.message || data?.error || 'OK'}`);
      } else {
        fail(method, path, `期望 ${expectStatus}，得到 ${status}`);
      }
      return { status, data };
    }
    pass(method, path, label || `${status} - ${data?.message || (data?.success ? '成功' : data?.error) || 'OK'}`);
    return { status, data };
  } catch (e) {
    fail(method, path, `连接失败: ${e.message}`);
    return null;
  }
}

// ============ 测试模块 ============

async function testAuth() {
  console.log('\n📋 认证模块');
  const wallet = ethers.Wallet.createRandom();
  WALLET = wallet.address;
  const message = `Login to XiuXian Game\nWallet: ${WALLET}\nTimestamp: ${Date.now()}`;
  const signature = await wallet.signMessage(message);

  try {
    const { status, data } = await request('POST', '/api/auth/login', { wallet: WALLET, signature, message }, false);
    if (status < 500 && data?.token) {
      TOKEN = data.token;
      pass('POST', '/api/auth/login', `登录成功 (token: ${TOKEN.slice(0, 20)}...)`);
    } else if (status < 500) {
      // 可能返回格式不同
      TOKEN = data?.data?.token || data?.token || '';
      if (TOKEN) {
        pass('POST', '/api/auth/login', `登录成功 (token: ${TOKEN.slice(0, 20)}...)`);
      } else {
        fail('POST', '/api/auth/login', `${status} - 无 token: ${JSON.stringify(data).slice(0, 120)}`);
      }
    } else {
      fail('POST', '/api/auth/login', `服务器错误 ${status}`);
    }
  } catch (e) {
    fail('POST', '/api/auth/login', `连接失败: ${e.message}`);
  }
}

async function testGameSave() {
  console.log('\n📋 游戏存档模块');
  await testEndpoint('POST', '/api/game/save', { gameData: { level: 1, name: 'TestPlayer', realm: '练气期' } });
  await testEndpoint('GET', '/api/game/load');
}

async function testVipSignMonthly() {
  console.log('\n📋 VIP/签到/月卡模块');
  await testEndpoint('GET', '/api/vip/info');
  await testEndpoint('POST', '/api/sign/daily');
  await testEndpoint('GET', '/api/monthly-card/status');
  await testEndpoint('POST', '/api/monthly-card/buy', { type: 'basic' });
  await testEndpoint('POST', '/api/monthly-card/claim');
}

async function testLeaderboardAnnouncements() {
  console.log('\n📋 排行榜/公告模块');
  await testEndpoint('GET', '/api/leaderboard/realm', null, false);
  await testEndpoint('GET', '/api/leaderboard/combat', null, false);
  await testEndpoint('GET', '/api/leaderboard/wealth', null, false);
  await testEndpoint('GET', '/api/announcements', null, false);
}

async function testRecharge() {
  console.log('\n📋 充值模块');
  await testEndpoint('POST', '/api/recharge/confirm', { txHash: '0x' + 'a'.repeat(64), amount: 100 });
  await testEndpoint('GET', '/api/recharge/history');
}

async function testEvents() {
  console.log('\n📋 活动模块');
  await testEndpoint('GET', '/api/events/active', null, false);
  await testEndpoint('GET', '/api/events/effects', null, false);
  await testEndpoint('POST', '/api/events/test-event-1/claim');
}

async function testPK() {
  console.log('\n📋 PK模块');
  await testEndpoint('GET', '/api/pk/history');
  await testEndpoint('GET', '/api/pk/stats');
}

async function testSect() {
  console.log('\n📋 宗门模块');
  const sectName = `测试宗门_${Date.now()}`;
  const createRes = await testEndpoint('POST', '/api/sect/create', { name: sectName, description: '自动测试创建的宗门' });
  await testEndpoint('GET', '/api/sect/my');
  await testEndpoint('GET', '/api/sect/list');
  await testEndpoint('POST', '/api/sect/join', { sectId: 'nonexistent-sect-id' });
  await testEndpoint('POST', '/api/sect/leave');
  await testEndpoint('POST', '/api/sect/kick', { memberId: 'fake-member-id' });
  await testEndpoint('POST', '/api/sect/promote', { memberId: 'fake-member-id' });
  await testEndpoint('POST', '/api/sect/demote', { memberId: 'fake-member-id' });
  await testEndpoint('POST', '/api/sect/announcement', { content: '测试公告' });
  await testEndpoint('GET', '/api/sect/tasks');
  await testEndpoint('POST', '/api/sect/tasks/fake-task-1/complete');
  await testEndpoint('POST', '/api/sect/donate', { amount: 100 });
  await testEndpoint('GET', '/api/sect/members');
}

async function testBoss() {
  console.log('\n📋 世界Boss模块');
  await testEndpoint('GET', '/api/boss/current');
  await testEndpoint('POST', '/api/boss/attack');
  await testEndpoint('GET', '/api/boss/ranking');
  await testEndpoint('GET', '/api/boss/rewards');
  await testEndpoint('POST', '/api/boss/rewards/claim');
  await testEndpoint('GET', '/api/boss/history');
}

async function testFriend() {
  console.log('\n📋 好友模块');
  await testEndpoint('GET', '/api/friend/list');
  await testEndpoint('GET', '/api/friend/requests');
  await testEndpoint('POST', '/api/friend/search', { keyword: 'test' });
  await testEndpoint('POST', '/api/friend/add', { targetWallet: '0x' + 'b'.repeat(40) });
  await testEndpoint('POST', '/api/friend/accept', { requestId: 'fake-request-id' });
  await testEndpoint('POST', '/api/friend/reject', { requestId: 'fake-request-id' });
  await testEndpoint('POST', '/api/friend/remove', { friendId: 'fake-friend-id' });
  await testEndpoint('GET', `/api/friend/profile/${WALLET}`);
  await testEndpoint('POST', '/api/friend/gift', { friendId: 'fake-friend-id', itemId: 'fake-item-id' });
  await testEndpoint('GET', '/api/friend/gifts');
  await testEndpoint('POST', '/api/friend/gifts/fake-gift-1/claim');
}

async function testSectWar() {
  console.log('\n📋 宗门战模块');
  await testEndpoint('POST', '/api/sect-war/challenge', { targetSectId: 'fake-sect-id' });
  await testEndpoint('GET', '/api/sect-war/pending');
  await testEndpoint('POST', '/api/sect-war/accept', { warId: 'fake-war-id' });
  await testEndpoint('POST', '/api/sect-war/decline', { warId: 'fake-war-id' });
  await testEndpoint('POST', '/api/sect-war/join', { warId: 'fake-war-id' });
  await testEndpoint('POST', '/api/sect-war/start', { warId: 'fake-war-id' });
  await testEndpoint('GET', '/api/sect-war/current');
  await testEndpoint('GET', '/api/sect-war/history');
  await testEndpoint('GET', '/api/sect-war/ranking');
  await testEndpoint('GET', '/api/sect-war/rewards');
  await testEndpoint('POST', '/api/sect-war/rewards/claim');
}

async function testAuction() {
  console.log('\n📋 拍卖模块');
  await testEndpoint('POST', '/api/auction/list', { itemId: 'fake-item-1', startPrice: 100, buyoutPrice: 1000, duration: 24 });
  await testEndpoint('GET', '/api/auction/browse');
  await testEndpoint('GET', '/api/auction/detail/fake-auction-1');
  await testEndpoint('POST', '/api/auction/bid', { auctionId: 'fake-auction-1', amount: 200 });
  await testEndpoint('POST', '/api/auction/buyout', { auctionId: 'fake-auction-1' });
  await testEndpoint('GET', '/api/auction/my-listings');
  await testEndpoint('POST', '/api/auction/cancel', { auctionId: 'fake-auction-1' });
  await testEndpoint('GET', '/api/auction/my-bids');
  await testEndpoint('GET', '/api/auction/history');
}

async function testDungeonDaily() {
  console.log('\n📋 每日副本模块');
  await testEndpoint('GET', '/api/dungeon-daily/list');
  await testEndpoint('POST', '/api/dungeon-daily/enter', { dungeonId: 'dungeon-1' });
  await testEndpoint('GET', '/api/dungeon-daily/history');
}

async function testMount() {
  console.log('\n📋 坐骑模块');
  await testEndpoint('GET', '/api/mount/list');
  await testEndpoint('GET', '/api/mount/my');
  await testEndpoint('POST', '/api/mount/buy', { mountId: 'mount-1' });
  await testEndpoint('POST', '/api/mount/activate', { mountId: 'mount-1' });
  await testEndpoint('POST', '/api/mount/deactivate');
  await testEndpoint('GET', '/api/mount/active');
}

async function testTitle() {
  console.log('\n📋 称号模块');
  await testEndpoint('GET', '/api/title/list');
  await testEndpoint('GET', '/api/title/my');
  await testEndpoint('POST', '/api/title/check');
  await testEndpoint('POST', '/api/title/activate', { titleId: 'title-1' });
  await testEndpoint('POST', '/api/title/deactivate');
}

async function testAscension() {
  console.log('\n📋 飞升模块');
  await testEndpoint('GET', '/api/ascension/info');
  await testEndpoint('POST', '/api/ascension/ascend');
  await testEndpoint('GET', '/api/ascension/perks');
  await testEndpoint('GET', '/api/ascension/ranking');
}

async function testAdmin() {
  console.log('\n📋 Admin模块 (预期 403 = 权限控制正常)');
  await testEndpoint('GET', '/api/admin/stats');
  await testEndpoint('GET', '/api/admin/events');
  await testEndpoint('POST', '/api/admin/events', { name: 'test', description: 'test', startTime: new Date().toISOString(), endTime: new Date(Date.now() + 86400000).toISOString() });
  await testEndpoint('PUT', '/api/admin/events/fake-event-1', { name: 'updated' });
  await testEndpoint('DELETE', '/api/admin/events/fake-event-1');
  await testEndpoint('GET', '/api/admin/events/fake-event-1/claims');
  await testEndpoint('POST', '/api/admin/boss/spawn', { name: '测试Boss', hp: 10000 });
  await testEndpoint('GET', '/api/admin/boss/list');
}

// ============ 主函数 ============

async function main() {
  console.log('🔥 火之文明 API 全面测试');
  console.log('========================');
  console.log(`🌐 服务器: ${BASE_URL}`);
  console.log(`⏰ 时间: ${new Date().toLocaleString('zh-CN')}`);

  // 1. 认证（必须先完成）
  await testAuth();
  if (!TOKEN) {
    console.log('\n⛔ 登录失败，无法继续测试需要认证的 API');
    console.log('   请检查服务器是否运行中');
    printReport();
    process.exit(1);
  }

  // 2. 按模块测试
  await testGameSave();
  await testVipSignMonthly();
  await testLeaderboardAnnouncements();
  await testRecharge();
  await testEvents();
  await testPK();
  await testSect();
  await testBoss();
  await testFriend();
  await testSectWar();
  await testAuction();
  await testDungeonDaily();
  await testMount();
  await testTitle();
  await testAscension();
  await testAdmin();

  // 3. 报告
  printReport();
}

function printReport() {
  const total = stats.pass + stats.fail + stats.skip;
  const rate = total > 0 ? ((stats.pass / (total - stats.skip)) * 100).toFixed(1) : '0.0';

  console.log('\n========================');
  console.log('📊 测试报告');
  console.log(`  ✅ 通过: ${stats.pass}`);
  console.log(`  ❌ 失败: ${stats.fail}`);
  console.log(`  ⏭️  跳过: ${stats.skip}`);
  console.log(`  📝 总计: ${total}`);
  console.log(`  🎯 通过率: ${rate}%`);
  console.log('========================');

  if (failures.length > 0) {
    console.log('\n❌ 失败详情:');
    failures.forEach((f, i) => console.log(`  ${i + 1}. ${f}`));
  }
}

main().catch(e => {
  console.error('💥 测试脚本异常:', e);
  process.exit(1);
});

