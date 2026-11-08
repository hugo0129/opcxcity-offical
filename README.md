# OPCxCity 爱创社官网

全国 AI+OPC 社群联盟 OPCxCity 的官网单页：交互城市地图、城市榜、2026 年五个里程碑、标杆社区、两个公益与加入方式。

纯静态页面，无依赖、无构建工具链。

## 本地预览

```bash
python3 -m http.server 8791
```

然后打开 http://localhost:8791 。

## 文件

| 文件 | 说明 |
|---|---|
| `src.html` | 页面源码（样式、结构、脚本都在这里） |
| `geo.json` | 中国省界路径（已投影、简化），由 DataV 行政区划数据生成 |
| `cities2.json` | 城市数据：坐标、主理人、社群人数、OPC 社区数 |
| `cities.json` | 从现官网「全国各大城市 OPC 社群概况」抓取的原始名录 |
| `build.py` | 把 `geo.json`、`cities2.json` 内联进 `src.html`，生成 `index.html` |
| `index.html` | 生成的成品页，直接部署这个文件和 `img/`、`mark.png` |
| `img/` | 厦门、杭州、温州、澄迈会场现场照片 |

改完 `src.html` 或数据后运行：

```bash
python3 build.py
```

## 数据来源

- 主理人与社群人数：OPCxCity 官网「全国各大城市 OPC 社群概况」
- OPC 社区数：爱创社飞书知识库「全国社区」名录（江西按全省计）
- 里程碑与标杆社区：各条目下附的媒体报道链接

两份名录持续更新，更新后改 `cities2.json` 再运行 `build.py`。
