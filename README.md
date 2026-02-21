# 火之文明：焰修传说

一款基于 Vue.js 的修仙放置网页游戏。

## 技术栈

- **前端**: Vue 3 + Vite + Pinia + Naive UI
- **后端**: Node.js + Express + PostgreSQL
- **实时通信**: WebSocket (世界聊天/PK/私聊)
- **部署**: PM2 + Nginx + SSL

## 功能

- 修炼突破 / 焚天塔(Roguelike) / 每日副本
- 探索 / 世界Boss / PK对战
- 抽卡(装备+焰兽) / 炼丹 / 装备强化洗练
- 宗门系统 / 宗门战 / 好友私聊
- 拍卖行 / 商城 / VIP月卡
- 坐骑称号 / 涅槃飞升(转生)
- 成就 / 排行榜 / 限时活动

## 部署

```bash
# 前端
npm install
npx vite build --outDir docs

# 后端
cd server
npm install
cp .env.example .env  # 配置数据库密码
node index.js
```

## License

MIT
