# 阶段 2:生成代码示例

本文件在 SKILL.md 路由到阶段 2 时按需加载。对每个知识点独立生成,可并行。

## 目标

为 DAG 中每个知识点的 `objective`,生成一段为教学目的定制的代码示例。

## 核心原则:知识点先行,代码后生成

先定义"这个知识点要教会什么"(objective),再生成**最适合教学的**代码。
不要直接拿笔记里的代码——笔记代码可能太复杂、焦点不明确。

## 输入

阶段 1 产出的 dag.json 中,每个知识点的:
- `objective` — 教学目标(最重要的依据)
- `title` — 知识点标题

## Prompt 指引

为每个知识点生成代码时:

1. **焦点单一**:这段代码只演示这一个知识点,不掺杂其他概念
2. **变量名有教学意义**:用 `a`/`b`/`result` 这类直白的名字,不要 `x1`/`tmp`
3. **不超过 10 行**:超了说明焦点不够单一,考虑是否 objective 该拆
4. **能运行**:verifiable=true 的代码必须可执行(用于阶段 3 的 trace 自动验证)

## verifiable 字段决策

这是 schema 的关键字段,决定验证策略:

| 场景 | verifiable | error_type | 验证方式 |
|------|-----------|------------|---------|
| 正常可运行代码 | `true` | *(无)* | 运行比对 stdout |
| 故意展示编译错误(Rust 借用教学) | `false` | `compile_error` | 编译比对错误信息 |
| 纯概念性代码(无法运行) | `false` | *(无)* | 跳过自动验证,人工审核 |

**Rust 借用排他性是典型场景**:核心教学内容就是"这段代码为什么编译不过"。
此时必须设 `verifiable: false, error_type: "compile_error"`,并填 `expected_error`。

## 输出格式

```json
{
  "language": "rust",
  "lines": [
    "let a = vec![1, 2, 3];",
    "let b = a;",
    "println!(\"{}\", a[0]);"
  ],
  "verifiable": true,
  "expected_output": ["error: borrow of moved value: `a`"]
}
```

注意:`expected_output` 在 verifiable=true 时是**预期 stdout**;
compile_error 场景下不需要 expected_output,而是用 `expected_error`。

## 验证(自动)

对 verifiable=true 的代码,实际运行后:
- 输出 == expected_output → 标记"已验证"
- 输出 != expected_output → 标记"需审核",人工看一眼(可能代码有 bug,或预期输出写错)

对 verifiable=false, compile_error 的代码,实际编译后:
- 错误信息包含 expected_error 子串 → 标记"已验证"
- 否则 → 标记"需审核"

## 完成判定

- 每个知识点都有一份代码示例
- verifiable 字段设置正确
- 所有 verifiable=true 的代码通过运行验证
