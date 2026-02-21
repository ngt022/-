module.exports = {
  apps: [{
    name: 'xiuxian-server',
    script: 'server/index.js',
    cwd: '/opt/xiuxian',
    node_args: '--max-old-space-size=512',
    max_memory_restart: '400M',
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    env: {
      NODE_ENV: 'production',
      PORT: 3007
    },
    error_file: '/root/.pm2/logs/xiuxian-server-error.log',
    out_file: '/root/.pm2/logs/xiuxian-server-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    merge_logs: true
  }]
}
