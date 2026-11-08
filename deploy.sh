#!/bin/sh
# 把官网上传到服务器网站目录。用法：
#   SERVER=用户名@服务器地址 WEBROOT=/网站根目录 sh deploy.sh
# 服务器地址和路径不要写进仓库。只覆盖同名文件，不删除服务器上已有的其他文件。
set -e
: "${SERVER:?请设置 SERVER，例如 SERVER=root@你的服务器}"
: "${WEBROOT:?请设置 WEBROOT，例如 WEBROOT=/www/wwwroot/opcxcity.cn}"
cd "$(dirname "$0")"
python3 build.py
rsync -avz --exclude '.git' --exclude 'ref' --exclude '*.py' --exclude '*.json' --exclude 'src.html' --exclude 'README.md' --exclude 'deploy.sh' --exclude '.gitignore' \
  --include 'img/hz-share.jpg' --include 'img/shirt.jpg' --include 'img/stage.jpg' --include 'img/wz-sign.jpg' --include 'img/xm-screen.jpg' --exclude 'img/*' \
  ./ "$SERVER:$WEBROOT/"
