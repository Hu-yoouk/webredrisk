# 赤潮风险可视化网站服务器部署包

本目录是“海洋赤潮发生风险评估模型分析系统”的独立部署包，已包含源码、静态构建产物、真实 JSON 数据、Docker/Nginx 配置和部署脚本。默认部署方式不需要在服务器上重新执行 `npm install`，直接用已有 `dist` 产物启动 Nginx 容器即可。

## 目录说明

| 路径 | 作用 |
|---|---|
| `dist/` | 已构建好的生产静态文件，可直接由 Nginx 托管 |
| `public/data/` | 前端加载的赤潮项目 JSON 数据源 |
| `src/` | React + TypeScript 源码 |
| `scripts/export-data.cjs` | 从 SQLite 导出前端 JSON 数据的脚本 |
| `Dockerfile` | 默认部署镜像，直接使用现有 `dist` |
| `Dockerfile.build` | 源码构建镜像，会在容器中执行 `npm ci && npm run build` |
| `docker-compose.yml` | 一键启动配置，默认映射服务器 `8080` 端口 |
| `nginx/default.conf` | Nginx 静态站配置，支持 `/red-tide-risk/` 子路径 |
| `scripts/deploy.sh` | Linux 一键部署脚本 |
| `scripts/deploy.ps1` | Windows PowerShell 一键部署脚本 |

## 推荐部署方式：Docker Compose

服务器需安装 Docker 与 Docker Compose 插件。

```bash
cd red-tide-risk-server-deploy
docker compose up -d --build
```

启动后访问：

```text
http://服务器IP:8080/red-tide-risk/
```

健康检查地址：

```text
http://服务器IP:8080/healthz
```

停止服务：

```bash
docker compose down
```

查看日志：

```bash
docker compose logs -f
```

## 使用部署脚本

Linux 服务器：

```bash
chmod +x scripts/deploy.sh scripts/stop.sh
./scripts/deploy.sh
```

Windows 服务器：

```powershell
.\scripts\deploy.ps1
```

## 如果服务器已有 Nginx

可以不使用 Docker，直接上传 `dist` 目录，并将其中内容放到 Nginx 静态目录的 `red-tide-risk` 子目录下，例如：

```text
/usr/share/nginx/html/red-tide-risk/index.html
/usr/share/nginx/html/red-tide-risk/assets/
/usr/share/nginx/html/red-tide-risk/data/
```

Nginx 站点配置可参考：

```nginx
location = / {
    return 302 /red-tide-risk/;
}

location ^~ /red-tide-risk/ {
    root /usr/share/nginx/html;
    try_files $uri $uri/ /red-tide-risk/index.html;
}
```

访问地址：

```text
http://服务器IP/red-tide-risk/
```

## 重新构建前端

如果修改了源码，在本机或服务器执行：

```bash
npm ci
npm run build
```

构建产物会输出到 `dist/`。注意本项目的 `vite.config.ts` 中配置了：

```ts
base: '/red-tide-risk/'
```

因此部署访问路径应包含 `/red-tide-risk/`。如果要部署在域名根路径，需要将 `base` 改为 `/` 后重新构建。

## 数据说明

网站数据已经预处理为 JSON 文件并随部署包提供，主要位于：

```text
public/data/
dist/data/
```

其中包含 46,800 条海洋环境样本、195 个监测网格、2004--2023 年逐月时间序列、相关性矩阵、特征重要性和优势种信息。若只部署静态网站，不需要 SQLite 数据库；只有重新导出数据时才需要使用 `scripts/export-data.cjs`。

## 端口调整

默认 `docker-compose.yml` 将容器 80 端口映射到服务器 8080 端口：

```yaml
ports:
  - "8080:80"
```

如需使用 80 端口，改为：

```yaml
ports:
  - "80:80"
```

## 交付检查

部署前确认以下内容存在：

- `dist/index.html`
- `dist/assets/`
- `dist/data/samples_index.json`
- `public/data/`
- `Dockerfile`
- `docker-compose.yml`
- `nginx/default.conf`

若页面能打开但图表为空，优先检查浏览器控制台是否有 `data/*.json` 加载失败；通常是访问路径未包含 `/red-tide-risk/` 或 Nginx 未正确托管 `data` 目录。
