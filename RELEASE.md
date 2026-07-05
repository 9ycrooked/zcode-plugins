# 版本发布规范

## 更新流程

本仓库所有插件统一通过 **GitHub + ZCode 市场** 进行更新分发。每次更新遵循以下流程：

```
修改代码 → commit → 打 tag → push → ZCode 市场更新
```

### 详细步骤

#### 1. 开发与提交

```bash
# 在 main 分支上开发
git checkout main

# 修改插件代码后，提交变更
git add <修改的文件>
git commit -m "feat: 简明的变更说明"
```

#### 2. 打标签

```bash
# 确定新版本号（遵循语义化版本）
git tag -a v<版本号> -m "v<版本号>: 版本说明"

# 示例
git tag -a v0.4.0 -m "v0.4.0: 新增 XX 技能"
```

#### 3. 推送

```bash
# 同时推送代码和标签
git push origin main --tags
```

#### 4. 在 ZCode 中更新

推送完成后，在 ZCode 中操作：

1. 打开 **插件市场**
2. **检查更新**
3. 安装新版本
4. 重启会话

> ZCode 会自动从 GitHub 拉取最新 `plugin.json`，同步工作区和缓存。

---

## 版本号规则

遵循 [语义化版本](https://semver.org/)：

| 版本位 | 何时递增 | 示例 |
|--------|----------|------|
| **主版本 (major)** | 不兼容的 API 变更 | `1.0.0` → `2.0.0` |
| **次版本 (minor)** | 向下兼容的功能新增 | `0.1.0` → `0.2.0` |
| **修订号 (patch)** | 向下兼容的问题修复 | `0.1.0` → `0.1.1` |

### 当前版本记录

| 版本 | Tag | 说明 |
|------|-----|------|
| v0.1.0 | `v0.1.0` | 初始发布，HTTP 直连 Sisyphus MCP |
| v0.2.0 | `v0.2.0` | 更新 MCP 配置 |
| v0.3.0 | `v0.3.0` | 移除硬编码 Token，切换 HTTP 直连 |

---

## 需要更新版本号的文件

每次发布新版本时，需更新以下 3 个文件的版本号：

| 文件 | 字段 |
|------|------|
| `siyuan-sisyphus/package.json` | `version` |
| `siyuan-sisyphus/.zcode-plugin/plugin.json` | `version` |
| `siyuan-sisyphus/.zcode-plugin-seed.json` | `pluginVersion` |

> 这三个文件必须保持一致。

---

## 不要做的事

- ❌ 不要直接修改 `~/.zcode/` 下的任何文件（缓存、工作区、配置）
- ❌ 不要跳过 tag 直接 push（无法追溯版本）
- ❌ 不要在一个 commit 中混合不相关的变更
