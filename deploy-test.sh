#!/bin/bash
# Build and deploy to test server
cd /opt/xiuxian

# 自动更新 SW 版本号（每次 build 强制刷新缓存）
SW_VER="huozhiwenming-v$(date +%Y%m%d%H%M%S)"
sed -i "s/huozhiwenming-v[^']*/${SW_VER}/" public/sw.js

npm run build
rm -rf docs-test/assets
cp -r docs/assets docs-test/assets
cp docs/index.html docs-test/index.html
cp docs/sw.js docs-test/sw.js
docker restart xiuxian-test
echo "✅ Test server deployed (SW: ${SW_VER})"
