# OPCxCity 爱创社官网

全国 AI+OPC 社群联盟 OPCxCity 的官网单页：交互城市地图、城市榜、2026 年五个里程碑、标杆社区、OPC 学习平台入口、两个公益与加入方式。

纯静态页面：没有后端和数据库，也不需要 npm。本机只要有 `python3`、`ssh`、`curl`（macOS 和 Linux 自带）。

## 一键发布

### 第一次使用（做一次就行）

1. 在仓库根目录新建 `.deploy.env`，写上服务器地址。这个文件已加入 `.gitignore`，不会被提交：

   ```
   DEPLOY_HOST=root@服务器IP
   DEPLOY_ROOT=/var/www/opcxcity
   ```

2. 把本机 SSH 公钥装到服务器，以后发布就不用再输密码。这一步会要求输入一次服务器密码：

   ```bash
   sh publish.sh --setup-key
   ```

3. 服务器上要有 nginx，并有一个站点指向 `DEPLOY_ROOT`。参考配置（CentOS 放在 `/etc/nginx/conf.d/opcxcity.conf`）：

   ```nginx
   server {
       listen 80;
       server_name 服务器IP opcxcity.com www.opcxcity.com;
       root /var/www/opcxcity;
       index index.html;
   }
   ```

   改完运行 `nginx -t && systemctl reload nginx`。

### 每次发布

```bash
sh publish.sh
```

脚本会做三件事：

1. 重新生成 `index.html`；
2. 把 `index.html`、`mark.png` 和页面用到的照片打包上传到服务器；
3. 打开线上首页检查，返回 200 时显示「发布成功」。

只会覆盖同名文件，不会删除服务器上的其他文件。

## 本地预览

```bash
python3 -m http.server 8791
```

然后打开 http://localhost:8791 。

## 文件

| 文件 | 说明 |
|---|---|
| `src.html` | 页面源码，样式、结构、脚本都在这里 |
| `geo.json` | 中国省界路径（已投影、简化），由 DataV 行政区划数据生成 |
| `cities2.json` | 城市数据：坐标、主理人、社群人数、OPC 社区数 |
| `cities.json` | 从原官网「全国各大城市 OPC 社群概况」抓取的原始名录 |
| `build.py` | 把 `geo.json`、`cities2.json` 内联进 `src.html`，生成 `index.html` |
| `index.html` | 生成的成品页 |
| `img/` | 厦门、杭州、温州、澄迈会场的现场照片 |
| `publish.sh` | 一键发布脚本 |
| `pack.sh` | 生成部署压缩包，给不用脚本、手动部署的人 |

改页面只改 `src.html`；改城市数据只改 `cities2.json`。`index.html` 不要手改，`publish.sh` 会重新生成它。

## 数据来源

- 主理人与社群人数：OPCxCity 官网「全国各大城市 OPC 社群概况」
- OPC 社区数：爱创社飞书知识库「全国社区」名录（江西按全省计）
- 里程碑与标杆社区：各条目下附的媒体报道链接
- 学习平台：https://study.opcxcity.com
