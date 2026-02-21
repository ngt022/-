# 🔥 火之文明：焰修传说

Web3 焰修放置网页游戏，基于 Vue 3 + Node.js + PostgreSQL。

## 技术栈

- **前端**: Vue 3 + Vite + Pinia + Naive UI
- **后端**: Node.js + Express + PostgreSQL
- **实时通信**: WebSocket (世界聊天/PK/私聊)
- **部署**: PM2 + Nginx + SSL
- **链上**: RoonChain (充值/钱包登录)

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

- 全部 16 项资源操作服务端验证
- JWT 认证 + 401 自动登出
- Rate Limit (全局 + 敏感操作)
- WebSocket 连接数限制 (200)
- Helmet 安全头 + Nginx 安全头
- 端口绑定 127.0.0.1 + iptables
- CORS 收紧 + Body Size 限制
- Fail2ban + UFW 防火墙
- 数据库每日自动备份 (7天保留)
- 生产环境 console.log 移除

## 部署

```bash
# 前端构建
npm run build

# 后端启动
cd server && npm install
pm2 start ecosystem.config.cjs
```

## 作者

Tracy (ngt022)
