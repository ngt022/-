#!/bin/bash
# Build and deploy to test server ONLY (不影响正式服)
cd /opt/xiuxian

# 自动更新 SW 版本号
SW_VER="huozhiwenming-v$(date +%Y%m%d%H%M%S)"
sed -i "s/huozhiwenming-v[^']*/${SW_VER}/" public/sw.js

# Build 直接输出到 docs-test/
npx vite build --outDir docs-test

# 复制 sw.js
cp public/sw.js docs-test/sw.js

docker restart xiuxian-test
echo "✅ Test server deployed (SW: ${SW_VER})"
