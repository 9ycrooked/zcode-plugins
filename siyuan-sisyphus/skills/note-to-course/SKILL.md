---
name: note-to-course
description: >
  把思源笔记转化成交互式学习网站的内容包。当用户提到"做学习网站"、"生成课程"、
  "教学动画"、"代码 trace"、"知识点 DAG"、"把笔记变成教程"、"出练习题"、
  "记忆卡片"、"间隔重复"、"学习内容包"、"content.json"时触发。
  读取思源笔记 → 分阶段生成 → 产出符合 schema.json 的 content.json。
---

# Note-to-Course

把思源笔记里的技术笔记,转化成一个交互式学习网站的**内容包**(content.json)。

> **规则：当需要确认用户对 DAG 结构、内容范围、教学方式等偏好时，使用 `AskUserQuestion` 工具提问，不要自己猜测。**

**职责边界**:本技能只负责"生产内容"(文档第五节那条 LLM 管线)。
渲染引擎(动画播放器、Trace 播放器、SM-2 运行时)是独立项目,不在本技能范围。
两者通过 content.json 的 schema 解耦。

## 核心数据流

```
思源笔记(按主题分章的笔记)
    ↓ [阶段 1] 萃取 → 知识点 DAG
    ↓ [人工审核 DAG]
    ↓ [阶段 2-4 可并行] 代码 → trace → 讲解/练习/卡片
    ↓ [阶段 5] 动画引用分配
    ↓ [阶段 6] 组装 content.json → schema 校验
    ↓
content.json(交付给渲染引擎)
```

## 工作契约

- **输出格式**:严格遵循 `assets/schema.json`(schema_version 1.0.0)
- **学习方法**:Zettelkasten 式原子知识点 + DAG 依赖排序(参考 `note-curator` 技能的理念,但本技能产出的是教学包而非笔记)
- **质量门**:每个阶段都有验证(见 `references/validation.md`),不通过不放行

## 路由:根据当前进度选择阶段

技能被触发后,先判断用户处于哪个阶段,**只读取对应阶段的 reference 执行**。
不要预加载所有阶段。

### 起点:确定主题与笔记

任何生成任务的第一步。先和用户确认:
1. 要做哪个主题?(如"Rust 所有权")
2. 对应的思源笔记在哪个笔记本/文档?(用 `document.search_docs` / `document.get_doc` 找)

确认后进入阶段 1。

### 六个阶段

| 阶段 | 做什么 | reference | 可并行 | 必须审核 |
|------|--------|-----------|--------|----------|
| 1 | 萃取知识点 DAG | `references/stage1-dag.md` | 否(后续全靠它) | ✅ 人工审核 |
| 2 | 生成代码示例 | `references/stage2-code.md` | 是(按知识点) | 自动验证 |
| 3 | 生成 trace | `references/stage3-trace.md` | 是(按知识点) | 自动+人工 |
| 4 | 生成讲解/练习/卡片 | `references/stage4-teaching.md` | 是(按知识点) | 抽查 |
| 5 | 动画引用分配 | `references/stage5-animation.md` | 否 | 抽查 |
| 6 | 组装+校验 content.json | `references/stage6-assemble.md` | 否 | schema 校验 |

### 阶段间的推进规则

1. **阶段 1 必须人工审核通过**,才能进入 2-4。它是地基——`objective` 字段错了,后面全错。
2. **阶段 2、3、4 对每个知识点独立**,可并行。但单个知识点内部有顺序:代码 → trace → 讲解。
3. **阶段 5 在 2-4 全部完成后**统一分配动画。
4. **阶段 6 最后执行**,组装完做 schema 校验,失败则定位错误字段回到对应阶段修。

## 思源 MCP 工具速查

| 工具 | 用途 |
|------|------|
| `document.search_docs` | 按关键词找主题笔记 |
| `document.get_doc` | 读取笔记全文(markdown) |
| `document.list_tree` | 看笔记本目录结构(辅助 DAG 标注跨章依赖) |
| `search.fulltext` | 在笔记里搜相关知识点 |
| `file.write` | 把生成的 content.json 写回思源文档(可选) |

## 思维框架:这个技能不是什么

- ❌ **不是教程生成器**:不直接产出"给人读的教程",而是产出结构化数据给渲染引擎消费
- ❌ **不是笔记整理器**:那是 `note-curator` 的活。本技能消费整理好的笔记,产出教学包
- ❌ **不做渲染**:动画/播放器/网站是独立项目。本技能最多产出 `animations` 引用字段

## 通用原则

- 每个阶段开始前,告知用户这个阶段要做什么、产出什么
- 每个阶段结束后,展示产出摘要 + 验证结果,获确认后进下一阶段
- 严格遵循 schema.json 的字段约束(尤其 `verifiable` / `error_type` 的组合规则)
- 生成的代码必须能运行(用于 trace 验证);不可验证的代码按 schema 的 `verifiable: false` 规则处理
