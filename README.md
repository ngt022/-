# 🔥 火之文明：焰修传说

Web3 焰修放置网页游戏，基于 Vue 3 + Node.js + PostgreSQL。

## 技术栈

- **前端**: Vue 3 + Vite + Pinia + Naive UI
- **后端**: Node.js + Express + PostgreSQL
- **日志**: pino (JSON 格式, request-id 全链路追踪)
- **实时通信**: WebSocket (世界聊天/PK/私聊)
- **部署**: Docker Compose + Nginx + SSL (acme.sh)
- **CI**: GitHub Actions (语法检查 + 回归测试)
- **链上**: RoonChain (充值/钱包登录)

## 架构

```
┌─────────────┐     ┌──────────────┐     ┌────────────┐
│  Vue 3 SPA  │────▶│  Express API │────▶│ PostgreSQL │
│  Naive UI   │     │  WebSocket   │     │  JSONB +   │
│  Pinia      │     │  pino logger │     │  关系表    │
└─────────────┘     └──────────────┘     └────────────┘
```

### 后端核心模块

| 模块 | 路径 | 职责 |
|------|------|------|
| stats-service | `server/services/stats-service.js` | 统一属性计算 (SSOT)、stats_snapshot 缓存 |
| lock-service | `server/services/lock-service.js` | 幂等性保护 (idempotency cache) |
| logger | `server/services/logger.js` | pino 日志、request-id 中间件 |
| combat | `server/utils/combat.js` | 战斗引擎 |
| dungeon | `server/routes/dungeon.js` | 焚天塔 Roguelike |
| gacha | `server/routes/gacha.js` | 抽卡系统 |

### 数据库表

| 表 | 用途 |
|----|------|
| `players` | 玩家主表 (game_data JSONB + state_version) |
| `inventory_items` | 装备实例 (独立存储，双写模式) |
| `equip_slots` | 穿戴关系 |
| `player_stats_snapshot` | 最终属性缓存 |
| `battle_trace_log` | 战斗审计日志 |
| `idempotency_cache` | 幂等性缓存 (10min TTL) |

## 功能

- 修炼突破 / 焚天塔(Roguelike) / 焰境(每日副本)
- 探索 / 黑焰入侵(世界Boss) / 焰武(PK对战)
- 焰运阁(抽卡) / 焰炼(炼丹) / 装备淬火/铭符
- 焰盟系统 / 焰盟战 / 焰友(好友私聊)
- 焰市(拍卖行) / 焰晶商铺 / 焰阶(VIP)/月卡
- 焰骑焰号(坐骑称号) / 涅槃飞升(转生)
- 焰功(成就) / 焰榜(排行榜) / 限时活动
- 后台管理(Admin) / 公告系统

## 安全特性

- 统一属性计算 — 单一来源 (stats-service)，杜绝前端伪造
- state_version 版本控制 — 每次写操作递增，可追溯
- 事务保护 — 装备穿脱/强化使用 BEGIN/FOR UPDATE/COMMIT
- 幂等性 — Idempotency-Key 防重复提交
- PK 从 DB 读属性 — 不信任前端上报的战斗数据
- JWT 认证 + 401 自动登出
- Rate Limit (全局 + 敏感操作)
- WebSocket 连接数限制 (200)
- Helmet + Nginx 安全头
- CORS 收紧 + Body Size 限制
- Fail2ban + UFW 防火墙
- 数据库每日自动备份 (7天保留)

## 部署

```bash
# Docker 部署 (推荐)
docker-compose up -d xiuxian-test    # 测试服 :3017
docker-compose up -d xiuxian-prod    # 正式服 :3007
docker-compose up -d --build xiuxian-test  # 重新构建

# 数据库迁移
PGPASSWORD='xxx' psql -h 127.0.0.1 -U roon_user -d xiuxian_test \
  -f server/migrations/001_state_version.sql \
  -f server/migrations/002_idempotency.sql \
  -f server/migrations/003_equip_split.sql

# 装备数据迁移
GAME_ENV=test node server/migrations/migrate-equipment.mjs

# 测试服一键部署 (build + sync + restart)
./deploy-test.sh

# 正式服部署
./promote.sh

# 回归测试
npx vitest run server/tests/regression.test.mjs
```

## 测试

回归测试覆盖：
- Load 接口返回 stateVersion + gameData
- 穿脱装备 state_version 递增
- 20 次穿脱无属性漂移
- 幂等性重放返回缓存
- Save 递增 state_version
- 5 次连续读取属性一致
n战斗系统测试：
- combatBoost 增伤验证
- finalDamageReduce 70% 上限
- resistanceBoost 30% 上限
- dodgeResist 抵消闪避
- critDamageBoost 暴伤倍率
- Boss/副本/PK 端点可用性

```bash
npx vitest run
```

## 作者

Tracy (ngt022)
