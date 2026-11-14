#!/bin/sh
# 生成交给部署人的压缩包：opcxcity-site-部署包.zip
set -e
cd "$(dirname "$0")"
python3 build.py
NAME=opcxcity-site
ZIP=opcxcity-site-部署包.zip
rm -rf "$NAME" "$ZIP"
mkdir -p "$NAME/img"
cp index.html mark.png deploy-pack/README.md "$NAME/"
cp img/hz-share.jpg img/shirt.jpg img/stage.jpg img/wz-sign.jpg img/xm-screen.jpg "$NAME/img/"
zip -qrX "$ZIP" "$NAME" -x '*.DS_Store'
rm -rf "$NAME"
echo "已生成 $ZIP"
