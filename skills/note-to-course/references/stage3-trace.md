# 阶段 3:生成 trace

本文件在 SKILL.md 路由到阶段 3 时按需加载。对每个知识点独立生成,可并行。

## 目标

为阶段 2 的代码示例,生成逐行执行的帧序列(trace)。
trace 是渲染引擎 Trace 播放器的数据源,必须精确反映代码语义。

## 输入

- 阶段 2 的代码示例(含 `lines` 和 `expected_output`)
- 知识点 `objective`

## Prompt 核心设计

你是一个代码执行模拟器。严格按以下规则逐行执行:

1. **每一行代码对应恰好一帧**(不多不少)
2. **空行和注释行不产生帧**
3. **变量值必须通过计算得出**,不要猜测
4. **描述必须准确反映当前行的语义操作**
5. **首行执行后**,variables 里要有该行产生的变量
6. **变量状态持续**:某变量在后续帧若未改变,仍保留在 variables 中

## 输出格式(trace 数组)

```json
[
  {
    "line": 1,
    "variables": { "a": "[1, 2, 3]" },
    "output": [],
    "description": "创建向量 a,持有 [1,2,3] 的所有权"
  },
  {
    "line": 2,
    "variables": { "a": "<invalid>", "b": "[1, 2, 3]" },
    "output": [],
    "description": "把 a 赋值给 b,所有权转移,a 失效"
  },
  {
    "line": 3,
    "variables": { "a": "<invalid>", "b": "[1, 2, 3]" },
    "output": ["error: borrow of moved value: `a`"],
    "description": "访问已失效的 a,触发编译错误"
  }
]
```

关键约定:
- 失效/未定义变量用 `"<invalid>"` 或 `"<undefined>"` 标记(渲染时特殊显示)
- `output` 是该行产生的 stdout,每行一个数组元素
- `description` 一句话,人话描述,不是复述代码

## 三层验证机制

trace 容易出错(LLM 算变量值可能失误),用三层防御:

### 第一层:LLM 自我验证(prompt 内 chain-of-verification)

生成后,在 prompt 里要求:"从头检查每帧变量值是否与上一帧一致,如有矛盾请修正"。

### 第二层:自动验证(运行代码比对)

verifiable=true 的代码,实际运行,比对 trace 末帧的 output 累加值与代码实际 stdout:
- 一致 → 标记"已验证"
- 不一致 → 标记"需审核",人工抽查

### 第三层:人工抽查

只看标记"需审核"的。常见问题:
- 变量值算错(LLM 数学失误)
- 帧数与代码行数不对应
- 描述与实际语义不符

## 对 compile_error 代码的 trace

verifiable=false, error_type=compile_error 的代码无法运行,trace 怎么办?

- trace 仍正常生成(模拟"如果编译过了会怎样")
- 但末帧的 output 必须包含 expected_error 对应的错误信息
- 第二层验证改为:编译代码,比对实际错误信息是否包含 expected_error

## 完成判定

- 每个知识点都有 trace
- 帧数与有效代码行数对应(空行/注释除外)
- verifiable=true 的 trace 通过自动验证
- compile_error 的 trace 末帧包含预期错误
