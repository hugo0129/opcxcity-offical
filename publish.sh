#!/bin/sh
# 一键发布官网：重新生成 index.html，打包上传到服务器，再检查线上是否能打开。
#
# 用法：
#   sh publish.sh              发布
#   sh publish.sh --setup-key  第一次用：把本机 SSH 公钥装到服务器，以后发布不用输密码
#
# 服务器地址写在同目录的 .deploy.env（已加入 .gitignore，不进仓库），内容例如：
#   DEPLOY_HOST=root@服务器IP
#   DEPLOY_ROOT=/var/www/opcxcity
set -e
cd "$(dirname "$0")"
[ -f .deploy.env ] && . ./.deploy.env
: "${DEPLOY_HOST:?缺少 DEPLOY_HOST，请在 .deploy.env 里写 DEPLOY_HOST=root@服务器IP}"
DEPLOY_ROOT=${DEPLOY_ROOT:-/var/www/opcxcity}

if [ "$1" = "--setup-key" ]; then
  [ -f "$HOME/.ssh/id_ed25519.pub" ] || ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
  ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" "$DEPLOY_HOST"
  echo "公钥已装好，以后运行 sh publish.sh 不用再输密码。"
  exit 0
fi

echo "1/3 生成 index.html"
python3 build.py

FILES="index.html mark.png $(grep -o 'img/[A-Za-z0-9_-]*\.\(jpg\|png\|webp\)' index.html | sort -u | tr '\n' ' ')"
for f in $FILES; do [ -f "$f" ] || { echo "缺少文件：$f"; exit 1; }; done

echo "2/3 上传到 $DEPLOY_HOST:$DEPLOY_ROOT"
tar czf - $FILES | ssh "$DEPLOY_HOST" "mkdir -p '$DEPLOY_ROOT' && tar xzf - -C '$DEPLOY_ROOT'"

HOST=${DEPLOY_HOST#*@}
echo "3/3 检查 http://$HOST/"
CODE=$(curl -s --noproxy '*' -m 15 -o /dev/null -w "%{http_code}" "http://$HOST/" || true)
if [ "$CODE" = "200" ]; then
  echo "发布成功：http://$HOST/"
else
  echo "上传完成，但线上返回 $CODE，请检查服务器上的 nginx。"
  exit 1
fi
