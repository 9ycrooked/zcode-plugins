# siyuan-sisyphus

ZCode 插件：将 [思源笔记 (SiYuan Note)](https://b3log.org/siyuan/) 的 MCP server 注入到 ZCode 会话中，提供完整的文档操作能力。

## 功能

- **MCP Server** — 通过 HTTP 连接思源笔记的 Sisyphus MCP 插件（`127.0.0.1:36806`），自动注入 `mcp__siyuan-sisyphus__*` 系列工具
- **会话钩子** — 每次启动/清空/压缩会话时，自动检测思源 MCP 是否可达，给出状态提示
- **技能目录** — 预留 `skills/` 目录，后续可添加思源相关的自定义技能

## 提供的 MCP 工具

| 工具前缀 | 能力 |
|---------|------|
| `block` | 块的 CRUD、移动、折叠、属性操作 |
| `document` | 文档创建/查找/移动/重命名/树结构 |
| `av` | 属性视图（数据库）的完整 CRUD |
| `search` | 全文搜索、SQL 查询、反向链接、引用搜索、替换 |
| `fs` | 文件系统读写、搜索、移动 |
| `file` | 资源上传、模板管理、导出、OCR |
| `flashcard` | 闪卡复习系统 |
| `notebook` | 笔记本管理 |
| `tag` | 标签管理 |
| `system` | 系统配置、通知、同步 |
| `feedback` | 插件反馈 |

## 配置

在 `plugin.json` 的 `userConfig` 中可配置：

| 配置项 | 默认值 | 说明 |
|-------|--------|------|
| `siyuan_host` | `127.0.0.1` | 思源服务地址 |
| `siyuan_port` | `36806` | MCP 端口 |
| `siyuan_token` | *(内置默认)* | API Token |

## 安装

1. 确保思源笔记已安装并启用 **Sisyphus** 插件
2. 将本插件目录注册到 zCode 的 marketplace（`source: "filesystem"`）
3. 重启 zCode 会话

## 前置依赖

- [思源笔记](https://b3log.org/siyuan/) ≥ 3.1.0
- [Sisyphus 插件](https://github.com/siyuan-note/siyuan/blob/master/API.md) 已启用
