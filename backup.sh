#!/bin/bash

# 数据库备份脚本
# 每天凌晨3点运行，保留最近7天备份

DB_NAME="xiuxian"
DB_USER="roon_user"
DB_PASS="RoonG@ming2026!"
BACKUP_DIR="/opt/xiuxian/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql"

# 创建备份目录（如果不存在）
mkdir -p ${BACKUP_DIR}

# 执行备份
export PGPASSWORD="${DB_PASS}"
pg_dump -h localhost -U ${DB_USER} -d ${DB_NAME} > ${BACKUP_FILE}

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup successful: ${BACKUP_FILE}"
    
    # 压缩备份文件
gzip ${BACKUP_FILE}
    
    # 删除7天前的备份
    find ${BACKUP_DIR} -name "${DB_NAME}_*.sql.gz" -mtime +7 -delete
    
    echo "[$(date)] Old backups cleaned up"
else
    echo "[$(date)] Backup failed!"
    exit 1
fi
