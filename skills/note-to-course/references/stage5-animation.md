# 阶段 5:动画引用分配

本文件在 SKILL.md 路由到阶段 5 时按需加载。在阶段 2-4 全部完成后统一执行。

## 目标

为每个知识点的 trace 帧分配概念动画引用。
动画是在 trace 基础层上叠加的 Overlay 层,辅助直觉理解。

**重要**:本技能只产出"动画引用"(指向模板/组件 + 参数),不实现动画本身。
动画的视觉实现是渲染引擎的职责。

## 双层动画架构回顾

- **Base 层(trace 驱动)**:代码高亮 + 变量值面板 + 输出面板。始终存在,提供精确信息
- **Overlay 层(本阶段产出)**:在 trace 某帧叠加的 2D/3D 动画,辅助直觉

## 模板库(80% 场景)

优先用预制模板,匹配不到再考虑 custom:

| template | 视觉形式 | 适用场景 | 典型代码模式 |
|----------|---------|---------|-------------|
| `move` | 方块从 A 飞到 B | 所有权转移、变量赋值 | `let b = a;` |
| `copy` | 方块复制一份 | 值类型拷贝、Clone | `let b = a.clone();` |
| `reference` | 箭头连线 | 引用、指针、借用 | `let r = &v;` |
| `stack` | 栈帧推入弹出 | 函数调用、作用域 | `fn foo() {...}` |
| `lifetime` | 时间轴上的区间 | 生命周期、作用域范围 | `'a` |

## 分配策略:规则匹配优先,LLM 兜底

### 规则匹配(快速、确定)

对每帧,检测其代码行模式:

- `let X = Y;` (非引用) → `move` 模板
- `let X = Y.clone();` → `copy` 模板
- `let X = &Y;` 或 `&mut` → `reference` 模板
- `fn ...` 调用/定义 → `stack` 模板
- `'a` 生命周期标注 → `lifetime` 模板

### LLM 兜底

规则匹配不到的帧,根据 `description` 字段语义判断:
- 有明确视觉意义 → 选最接近的模板
- 纯声明/打印等无视觉价值 → 不分配(`animations` 数组不含该帧)

## 输出格式(animations 数组)

每个知识点一个 animations 数组,元素指向 trace 某帧:

```json
[
  {
    "trace_frame": 2,
    "template": "move",
    "params": { "from": "a", "to": "b", "value": "vec![1,2,3]" }
  },
  {
    "trace_frame": 3,
    "template": "reference",
    "params": { "from": "r1", "to": "v", "mutable": false }
  }
]
```

字段约束(见 schema.json):
- `trace_frame`:对应 trace 数组的索引+1
- `template`:必须是模板库之一,或 `custom`
- `params`:模板参数,结构因模板而异
- `component`:仅当 template=custom 时填,指向渲染引擎的定制组件名

## custom 的使用(20% 场景)

当模板库覆盖不了时(如排序算法的柱状图、链表节点),用 `custom`:

```json
{
  "trace_frame": 5,
  "template": "custom",
  "component": "bar-chart-sort",
  "params": { "array": "[3,1,2]", "highlight": [0,1] }
}
```

**前提**:该定制组件必须在渲染引擎的组件库中已实现。
本阶段分配 custom 前,应告知用户"此帧需要定制组件 X,渲染引擎需实现"。
如果渲染引擎还没这个组件,要么换模板,要么标记为待实现。

## 不要过度分配

不是每帧都要动画。原则:
- trace 帧数 5-8 帧,动画 1-3 个为宜
- 只在"概念发生转变"的帧分配(变量失效、所有权转移、引用建立)
- 纯打印、声明的帧不需要动画

## 完成判定

- 每个知识点都有 animations 数组(可为空)
- 所有 template 引用合法(模板库内或 custom+component)
- custom 引用都已告知用户需实现的组件
- 没有过度分配(动画帧占比合理)
