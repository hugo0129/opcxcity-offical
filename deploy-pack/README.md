# OPCxCity 官网部署说明

域名：**opcxcity.com**（同时绑定 www.opcxcity.com）

这是一个纯静态网页：没有后端、数据库，也不需要 npm 或构建。上传文件、绑定域名、配上 HTTPS 就能上线。

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

## 二、部署步骤（以宝塔面板为例）

### 1. 新建站点

宝塔 → 网站 → 添加站点
- 域名填两行：`opcxcity.com` 和 `www.opcxcity.com`
- 根目录：例如 `/www/wwwroot/opcxcity.com`
- PHP 版本：**纯静态**
- 数据库：不创建

如果服务器上已经有 opcxcity.com 的站点，就直接用它的根目录，不用新建。

### 2. 上传文件

1. 进入站点根目录，先把里面原有的文件**下载备份**一份。
2. 删掉宝塔自动生成的默认 `index.html`、`404.html`（如有）。
3. 上传本包里的 `index.html`、`mark.png` 和整个 `img/` 文件夹。

上传后目录应该是：

```
/www/wwwroot/opcxcity.com/
├── index.html
├── mark.png
└── img/
    ├── hz-share.jpg
    ├── shirt.jpg
    ├── stage.jpg
    ├── wz-sign.jpg
    └── xm-screen.jpg
```

### 3. 配置 HTTPS（必须做）

目前 opcxcity.com 的 HTTPS 证书和域名不匹配，浏览器会提示「不安全」。

宝塔 → 网站 → opcxcity.com → 设置 → SSL
1. 选 **Let's Encrypt**，勾选 `opcxcity.com` 和 `www.opcxcity.com`，申请。
2. 申请成功后，打开 **强制 HTTPS**。

申请失败一般是两个原因：
- 域名解析还没指向这台服务器 → 到域名服务商把 `@` 和 `www` 两条 A 记录指向服务器 IP，等几分钟再申请。
- 服务器安全组 / 防火墙没放行 80、443 端口 → 在云服务商控制台和宝塔「安全」里都放行。

### 4. 确认域名解析

在域名服务商后台，确认有这两条记录：

| 主机记录 | 类型 | 记录值 |
|---|---|---|
| `@` | A | 服务器公网 IP |
| `www` | A | 服务器公网 IP |

> 服务器在中国大陆时，域名需要先完成 ICP 备案，否则访问会被拦截。

---

## 三、不用宝塔，直接用 Nginx

把文件放到 `/var/www/opcxcity.com/`，站点配置参考：

```nginx
server {
    listen 80;
    server_name opcxcity.com www.opcxcity.com;
    return 301 https://opcxcity.com$request_uri;
}

server {
    listen 443 ssl http2;
    server_name opcxcity.com www.opcxcity.com;

    ssl_certificate     /etc/letsencrypt/live/opcxcity.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/opcxcity.com/privkey.pem;

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

证书可以用 certbot 申请：`certbot --nginx -d opcxcity.com -d www.opcxcity.com`

改完配置后执行 `nginx -t && nginx -s reload`。

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
| 打开显示 403 | 根目录里没有 `index.html`，或者域名绑错了站点目录 |
| 打开显示 404 | 文件上传到了子文件夹里，`index.html` 要直接放在根目录 |
| 照片裂图 | `img/` 文件夹没传，或者文件夹名被改了（必须是小写 `img`） |
| 提示「不安全」 | 证书没配，或证书不包含当前访问的域名，回到第二节第 3 步 |
| 微信里打不开 / 被拦截 | 域名未备案，或被微信标记，需在微信公众平台申诉 |
