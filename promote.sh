#!/bin/bash
# === promote.sh — 测试版确认上线到正式版 ===
# 只有你明确执行这个脚本，正式版才会更新
#
# 流程:
# 1. 快照当前正式版（回滚用）
# 2. 停止正式版容器
# 3. 用测试版的代码+构建产物覆盖正式版
# 4. 重建并启动正式版容器
# 5. 健康检查

set -e

PROJECT_DIR="/opt/xiuxian"
cd "$PROJECT_DIR"

echo "🔄 准备将测试版推送到正式版..."
echo ""

# 安全确认
read -p "⚠️  确认将测试版代码部署到正式版？(输入 yes): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "❌ 已取消"
  exit 1
fi

# 1. 备份当前正式版
BACKUP_DIR="/opt/xiuxian/backups/prod-$(date +%Y%m%d-%H%M%S)"
echo "📦 备份当前正式版到 $BACKUP_DIR ..."
mkdir -p "$BACKUP_DIR"
cp -r "$PROJECT_DIR/server" "$BACKUP_DIR/server"
cp -r "$PROJECT_DIR/docs" "$BACKUP_DIR/docs"
echo "  ✅ 备份完成"

# 2. 数据库备份
echo "💾 备份正式版数据库..."
PGPASSWORD='RoonG@ming2026!' pg_dump -U roon_user -h 127.0.0.1 -d xiuxian > "$BACKUP_DIR/xiuxian.sql"
echo "  ✅ 数据库备份完成 ($(du -h "$BACKUP_DIR/xiuxian.sql" | cut -f1))"

# 3. 构建正式版前端
echo "🔨 构建正式版前端..."
cd "$PROJECT_DIR"
VITE_GAME_ENV=production npm run build 2>&1 | tail -3
echo "  ✅ 前端构建完成"

# 4. 重建正式版容器
echo "🐳 重建正式版容器..."
docker-compose stop xiuxian-prod 2>/dev/null || true
docker-compose build xiuxian-prod
docker-compose up -d xiuxian-prod
echo "  ✅ 正式版容器已启动"

# 5. 健康检查
echo "🔍 健康检查..."
sleep 3
HEALTH=$(curl -s http://127.0.0.1:3007/api/health 2>/dev/null || echo "failed")
if echo "$HEALTH" | grep -q "ok"; then
  echo "  ✅ 正式版运行正常"
else
  echo "  ⚠️  健康检查未通过，检查日志: docker logs xiuxian-prod"
  echo "  回滚命令: ./rollback.sh $BACKUP_DIR"
fi

echo ""
echo "========================================="
echo "✅ 正式版更新完成!"
echo "  备份位置: $BACKUP_DIR"
echo "  回滚命令: ./rollback.sh $BACKUP_DIR"
echo "========================================="
