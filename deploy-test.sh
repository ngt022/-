#!/bin/bash
# Build and deploy to test server
cd /opt/xiuxian
npm run build
rm -rf docs-test/assets
cp -r docs/assets docs-test/assets
cp docs/index.html docs-test/index.html
cp docs/sw.js docs-test/sw.js
docker restart xiuxian-test
echo '✅ Test server deployed'
