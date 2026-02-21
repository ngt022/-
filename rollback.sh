#!/bin/bash
# === rollback.sh — 正式版回滚 ===
# 用法: ./rollback.sh /opt/xiuxian/backups/prod-20260221-133900

set -e

BACKUP_DIR="$1"
PROJECT_DIR="/opt/xiuxian"

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
  echo "❌ 用法: ./rollback.sh <备份目录>"
  echo "可用备份:"
  ls -d /opt/xiuxian/backups/prod-* 2>/dev/null || echo "  无备份"
  exit 1
fi

echo "🔄 回滚正式版到 $BACKUP_DIR ..."

read -p "⚠️  确认回滚？(输入 yes): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "❌ 已取消"
  exit 1
fi

# 停止正式版
docker-compose -f "$PROJECT_DIR/docker-compose.yml" stop xiuxian-prod 2>/dev/null || true

# 恢复代码
cp -r "$BACKUP_DIR/server/"* "$PROJECT_DIR/server/"
cp -r "$BACKUP_DIR/docs/"* "$PROJECT_DIR/docs/"

# 恢复数据库
if [ -f "$BACKUP_DIR/xiuxian.sql" ]; then
  read -p "是否也回滚数据库？(输入 yes): " DB_CONFIRM
  if [ "$DB_CONFIRM" = "yes" ]; then
    PGPASSWORD='RoonG@ming2026!' psql -U roon_user -h 127.0.0.1 -d xiuxian -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" 2>/dev/null
    PGPASSWORD='RoonG@ming2026!' psql -U roon_user -h 127.0.0.1 -d xiuxian < "$BACKUP_DIR/xiuxian.sql" > /dev/null 2>&1
    echo "  ✅ 数据库已回滚"
  fi
fi

# 重启
docker-compose -f "$PROJECT_DIR/docker-compose.yml" build xiuxian-prod
docker-compose -f "$PROJECT_DIR/docker-compose.yml" up -d xiuxian-prod

sleep 3
HEALTH=$(curl -s http://127.0.0.1:3007/api/health 2>/dev/null || echo "failed")
if echo "$HEALTH" | grep -q "ok"; then
  echo "✅ 回滚完成，正式版运行正常"
else
  echo "⚠️  回滚后健康检查未通过: docker logs xiuxian-prod"
fi
