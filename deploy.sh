#!/bin/bash
# === 火之文明 多环境部署脚本 ===
# 用法: ./deploy.sh [test|beta|production]
# 默认: production

set -e

GAME_ENV="${1:-production}"
PROJECT_DIR="/opt/xiuxian"
SERVER_DIR="$PROJECT_DIR/server"

# 环境配置映射
case "$GAME_ENV" in
  test)
    DB_NAME="xiuxian_test"
    PORT=3017
    NGINX_PORT=8445
    PM2_NAME="xiuxian-test"
    DOCS_DIR="/opt/xiuxian/docs-test"
    echo "🧪 部署环境: 测试 (test)"
    ;;
  beta)
    DB_NAME="xiuxian_beta"
    PORT=3027
    NGINX_PORT=8444
    PM2_NAME="xiuxian-beta"
    DOCS_DIR="/opt/xiuxian/docs-beta"
    echo "🔶 部署环境: 公测 (beta)"
    ;;
  production)
    DB_NAME="xiuxian"
    PORT=3007
    NGINX_PORT=8443
    PM2_NAME="xiuxian-server"
    DOCS_DIR="/opt/xiuxian/docs"
    echo "🟢 部署环境: 线上 (production)"
    ;;
  *)
    echo "❌ 无效环境: $GAME_ENV"
    echo "用法: ./deploy.sh [test|beta|production]"
    exit 1
    ;;
esac

DB_USER="roon_user"
DB_PASS="RoonG@ming2026!"
DB_HOST="127.0.0.1"
DB_PORT=5432
DATABASE_URL="postgresql://${DB_USER}:$(echo $DB_PASS | sed 's/@/%40/g')@${DB_HOST}:${DB_PORT}/${DB_NAME}"
JWT_SECRET="xiuxian_secret_2026_${GAME_ENV}"

echo ""
echo "📋 配置:"
echo "  数据库: $DB_NAME"
echo "  后端端口: $PORT"
echo "  Nginx端口: $NGINX_PORT"
echo "  PM2进程: $PM2_NAME"
echo "  前端目录: $DOCS_DIR"
echo ""

# === 1. 创建数据库（如果不存在）===
echo "📦 检查数据库 $DB_NAME ..."
DB_EXISTS=$(PGPASSWORD="$DB_PASS" psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" 2>/dev/null || echo "")

if [ "$DB_EXISTS" != "1" ]; then
  echo "  创建数据库 $DB_NAME ..."
  # Need superuser for createdb, try with roon_user first
  PGPASSWORD="$DB_PASS" createdb -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" "$DB_NAME" 2>/dev/null || \
    sudo -u postgres createdb "$DB_NAME" -O "$DB_USER" 2>/dev/null || \
    PGPASSWORD="$DB_PASS" psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d postgres -c "CREATE DATABASE $DB_NAME" 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo "  ✅ 数据库 $DB_NAME 创建成功"
    
    # 从 production 复制表结构（不复制数据）
    if [ "$GAME_ENV" != "production" ]; then
      echo "  📋 从 production 复制表结构..."
      PGPASSWORD="$DB_PASS" pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d xiuxian --schema-only | \
        PGPASSWORD="$DB_PASS" psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" > /dev/null 2>&1
      echo "  ✅ 表结构复制完成"
    fi
  else
    echo "  ❌ 数据库创建失败"
    exit 1
  fi
else
  echo "  ✅ 数据库 $DB_NAME 已存在"
fi

# === 2. 生成 .env 文件 ===
echo "📝 生成 .env.$GAME_ENV ..."
cat > "$SERVER_DIR/.env.$GAME_ENV" << EOF
# === 火之文明 - $GAME_ENV 环境 ===
# 自动生成于 $(date '+%Y-%m-%d %H:%M:%S')
GAME_ENV=$GAME_ENV
NODE_ENV=$( [ "$GAME_ENV" = "production" ] && echo "production" || echo "development" )
PORT=$PORT
DATABASE_URL=$DATABASE_URL
DB_PASSWORD=$DB_PASS
JWT_SECRET=$JWT_SECRET
ADMIN_WALLET=0xfad7eb0814b6838b05191a07fb987957d50c4ca9
ADMIN_WALLETS=0xfad7eb0814b6838b05191a07fb987957d50c4ca9,0x82e402b05f3e936b63a874788c73e1552657c4f7
EOF
echo "  ✅ $SERVER_DIR/.env.$GAME_ENV"

# === 3. 构建前端（非 production 需要不同 API 地址）===
if [ "$GAME_ENV" != "production" ]; then
  echo "📁 创建前端输出目录 $DOCS_DIR ..."
  mkdir -p "$DOCS_DIR"
fi

echo "🔨 构建前端 (GAME_ENV=$GAME_ENV) ..."
cd "$PROJECT_DIR"
VITE_GAME_ENV="$GAME_ENV" npm run build -- --outDir "$DOCS_DIR" 2>&1 | tail -5
echo "  ✅ 前端构建完成 → $DOCS_DIR"

# === 4. 生成 Nginx 配置 ===
if [ "$GAME_ENV" != "production" ]; then
  NGINX_CONF="/etc/nginx/conf.d/xiuxian-${GAME_ENV}.conf"
  echo "🌐 生成 Nginx 配置 $NGINX_CONF ..."
  cat > "$NGINX_CONF" << NGINX
# 火之文明 - $GAME_ENV 环境
# 自动生成于 $(date '+%Y-%m-%d %H:%M:%S')
server {
    listen $NGINX_PORT ssl;
    server_name _;

    ssl_certificate /etc/nginx/ssl/selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/selfsigned.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    root $DOCS_DIR;
    index index.html;

    location /ws {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_read_timeout 86400;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location ~* \.(js|css|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|webp|png)\$ {
        expires 7d;
        add_header Cache-Control "public";
    }
}
NGINX
  echo "  ✅ Nginx 配置生成完成"
  nginx -t 2>&1 && nginx -s reload
  echo "  ✅ Nginx 重载完成"
fi

# === 5. 启动/重启 PM2 进程 ===
echo "🚀 启动 PM2 进程 $PM2_NAME ..."
cd "$SERVER_DIR"

# 检查进程是否已存在
PM2_EXISTS=$(pm2 list 2>/dev/null | grep "$PM2_NAME" | grep -v grep || echo "")

if [ -n "$PM2_EXISTS" ]; then
  # 更新环境变量并重启
  GAME_ENV="$GAME_ENV" PORT="$PORT" DATABASE_URL="$DATABASE_URL" DB_PASSWORD="$DB_PASS" \
    JWT_SECRET="$JWT_SECRET" NODE_ENV="$( [ "$GAME_ENV" = "production" ] && echo "production" || echo "development" )" \
    pm2 restart "$PM2_NAME" --update-env 2>&1 | tail -3
else
  # 首次启动
  GAME_ENV="$GAME_ENV" PORT="$PORT" DATABASE_URL="$DATABASE_URL" DB_PASSWORD="$DB_PASS" \
    JWT_SECRET="$JWT_SECRET" NODE_ENV="$( [ "$GAME_ENV" = "production" ] && echo "production" || echo "development" )" \
    pm2 start index.js --name "$PM2_NAME" --node-args="--experimental-modules" 2>&1 | tail -3
fi

pm2 save 2>/dev/null
echo "  ✅ PM2 进程 $PM2_NAME 已启动"

# === 6. 验证 ===
echo ""
echo "🔍 验证服务..."
sleep 2
HEALTH=$(curl -sk "https://127.0.0.1:$NGINX_PORT/api/health" 2>/dev/null || echo "failed")
if echo "$HEALTH" | grep -q "ok\|status\|version"; then
  echo "  ✅ 服务正常运行"
else
  # 尝试直接访问后端
  HEALTH2=$(curl -s "http://127.0.0.1:$PORT/api/health" 2>/dev/null || echo "failed")
  if echo "$HEALTH2" | grep -q "ok\|status\|version"; then
    echo "  ✅ 后端正常 (Nginx 可能需要检查)"
  else
    echo "  ⚠️  服务可能未完全启动，请检查: pm2 logs $PM2_NAME"
  fi
fi

echo ""
echo "========================================="
echo "🎮 火之文明 [$GAME_ENV] 部署完成!"
echo "========================================="
echo "  访问地址: https://23.95.222.209:$NGINX_PORT"
echo "  后端端口: $PORT"
echo "  数据库:   $DB_NAME"
echo "  PM2进程:  $PM2_NAME"
echo "  前端目录: $DOCS_DIR"
echo "  .env文件: $SERVER_DIR/.env.$GAME_ENV"
echo "========================================="
