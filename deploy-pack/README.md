# OPCxCity 官网部署说明

域名：**opcxcity.com**（同时绑定 www.opcxcity.com）

这是一个纯静态网页：没有后端、数据库，也不需要 npm 或构建。只要把文件放到 Web 服务器的网站目录，绑上域名、配好 HTTPS 就能上线。

---

## 一、包里有什么

```
index.html        首页（样式、脚本、地图数据都在里面）
mark.png          网站图标
img/              5 张现场照片
README.md         本说明（不用上传）
```

`index.html`、`mark.png`、`img/` 三样必须放在同一层目录，相对位置不能改。

---

## 二、部署步骤（Linux + Nginx）

下面以 `/var/www/opcxcity.com` 作为网站目录，可以换成你自己的路径。

### 1. 上传文件

在本机解压后，进入 `opcxcity-site` 文件夹执行：

```bash
ssh 用户名@服务器 "mkdir -p /var/www/opcxcity.com"
scp -r index.html mark.png img 用户名@服务器:/var/www/opcxcity.com/
```

如果目录里原来有文件，先备份一份再覆盖。

上传后目录应该是：

```
/var/www/opcxcity.com/
├── index.html
├── mark.png
└── img/
    ├── hz-share.jpg
    ├── shirt.jpg
    ├── stage.jpg
    ├── wz-1111.jpg
    ├── wz-sign.jpg
    └── xm-screen.jpg
```

### 2. 配置 Nginx

新建 `/etc/nginx/conf.d/opcxcity.com.conf`：

```nginx
server {
    listen 80;
    server_name opcxcity.com www.opcxcity.com;

    root  /var/www/opcxcity.com;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # 图片缓存 30 天；首页不缓存，方便更新
    location ~* \.(jpg|jpeg|png)$ {
        expires 30d;
    }
    location = /index.html {
        add_header Cache-Control "no-cache";
    }
}
```

检查并生效：

```bash
nginx -t && systemctl reload nginx
```

此时用 http://opcxcity.com 应该已经能打开。

### 3. 配置 HTTPS（必须做）

目前 opcxcity.com 的 HTTPS 证书和域名不匹配，浏览器会提示「不安全」。用 certbot 申请免费证书：

```bash
certbot --nginx -d opcxcity.com -d www.opcxcity.com
```

按提示选择「把 HTTP 重定向到 HTTPS」。certbot 会自动改好 Nginx 配置，并自动续期。

没装 certbot：Ubuntu/Debian 用 `apt install certbot python3-certbot-nginx`，CentOS 用 `yum install certbot python3-certbot-nginx`。

如果已经有自己购买的证书，在 server 块里加 `listen 443 ssl;` 和 `ssl_certificate`、`ssl_certificate_key` 两行指向证书文件即可。

申请失败一般是两个原因：
- 域名解析还没指向这台服务器 → 见第 4 步。
- 80、443 端口没放行 → 在云服务商控制台的安全组和服务器防火墙里都放行。

### 4. 确认域名解析

在域名服务商后台，确认有这两条记录：

| 主机记录 | 类型 | 记录值 |
|---|---|---|
| `@` | A | 服务器公网 IP |
| `www` | A | 服务器公网 IP |

> 服务器在中国大陆时，域名需要先完成 ICP 备案，否则访问会被拦截。

### 5. 首页能打开、图片全部不显示？

这说明 nginx 只把首页交给了静态文件，其余路径（`/img/…`、`/mark.png`）都转给了后端程序。打开图片地址会看到类似这样的 404：

```
{"timestamp":"…","status":404,"error":"Not Found","path":"/img/stage.jpg"}
```

这是后端（Java/Spring 一类程序）返回的，不是 nginx 找不到文件。常见于同一个 server 里还配了 `location / { proxy_pass …; }`，比如和学习平台共用一套 nginx。

解决：在这个 server 块里、`proxy_pass` 那段**之前**，加上官网静态文件的路径，`root` 写成 `index.html` 所在的目录：

```nginx
    location = /mark.png { root /var/www/opcxcity.com; }
    location ^~ /img/    { root /var/www/opcxcity.com; expires 30d; }
```

然后 `nginx -t && systemctl reload nginx`。用浏览器直接打开 `https://www.opcxcity.com/img/stage.jpg`，能看到照片就对了。

更稳的做法是官网单独一个 server 块（只绑 opcxcity.com 和 www），学习平台用自己的 study.opcxcity.com，两边互不干扰。

---

## 三、其他环境

原理都一样：把三样文件放进网站根目录，首页设为 `index.html`，绑定域名，配好 HTTPS。

- **Apache**：文件放进站点的 `DocumentRoot`，默认就认 `index.html`，不需要额外配置；证书用 `certbot --apache -d opcxcity.com -d www.opcxcity.com`。
- **对象存储 / 静态托管**（阿里云 OSS、腾讯云 COS、Vercel、Netlify、Cloudflare Pages 等）：上传三样文件，开启「静态网站」，默认首页填 `index.html`，在控制台里绑定自定义域名并开启 HTTPS。
- **服务器上已经有其他网站在跑**：新建一个站点（虚拟主机）单独绑定 opcxcity.com，不要覆盖别的站点目录。

---

## 四、上线后自检

逐项打开确认：

- [ ] https://opcxcity.com 能打开，地址栏有小锁，没有「不安全」
- [ ] https://www.opcxcity.com 也能打开
- [ ] http://opcxcity.com 会自动跳转到 https
- [ ] 首屏的中国地图正常显示，鼠标移到城市上有信息
- [ ] 往下滚动，现场照片都能加载出来（没有裂图）
- [ ] 浏览器标签页上有网站图标
- [ ] 手机上打开，排版正常，没有左右晃动
- [ ] 把链接发到微信里，卡片能显示标题和图片

全部通过后，把截图发回给我们。

---

## 五、以后更新内容

内容由我们这边修改，会再发一个新的 `index.html`（有时附带新图片）。更新时：

1. 用新文件**覆盖**同名文件即可，不要删除其他文件。
2. 如果浏览器还显示旧内容，按 `Ctrl+F5`（Mac：`Cmd+Shift+R`）强制刷新；用了 CDN 的话，记得刷新 CDN 缓存。

---

## 常见问题

| 现象 | 原因与处理 |
|---|---|
| 打开显示 403 | 网站目录里没有 `index.html`；或目录权限不够，执行 `chmod -R 755 /var/www/opcxcity.com` |
| 打开显示 404 | 文件上传到了子文件夹里，`index.html` 要直接放在网站根目录 |
| 打开的是别的网站 / 默认欢迎页 | 域名没绑到这个站点，检查 Nginx 的 `server_name` 和 `root` |
| 照片裂图 | `img/` 文件夹没传，或者文件夹名被改了（必须是小写 `img`） |
| 提示「不安全」 | 证书没配，或证书不包含当前访问的域名，回到第二节第 3 步 |
| 微信里打不开 / 被拦截 | 域名未备案，或被微信标记，需在微信公众平台申诉 |
