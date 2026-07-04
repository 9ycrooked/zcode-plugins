# 阶段 6:组装 + 校验 content.json

本文件在 SKILL.md 路由到阶段 6 时按需加载。最后执行,纯代码逻辑,不需要 LLM 推理。

## 目标

把前 5 个阶段的产出拼装成一个完整的 content.json,做 schema 校验。

## 输入

前面各阶段的产出:
- 阶段 1:dag.json(topic, prerequisites, knowledge_points 的 id/title/objective/depends_on/estimated_minutes)
- 阶段 2:每个知识点的 code 对象
- 阶段 3:每个知识点的 trace 数组
- 阶段 4:每个知识点的 teaching 对象(explanation/exercises/flashcards)
- 阶段 5:每个知识点的 animations 数组

## 组装逻辑

按 schema.json 的结构拼装,知识点按 DAG 拓扑序排列:

```json
{
  "schema_version": "1.0.0",
  "topic": "Rust 所有权",
  "prerequisites": ["变量与类型", "函数基础"],
  "knowledge_points": [
    {
      "id": "move_semantics",
      "title": "Move 语义",
      "objective": "理解值的所有权只能有一个持有者,赋值后原变量失效",
      "depends_on": [],
      "estimated_minutes": 20,
      "code": { /* 阶段 2 产出 */ },
      "trace": [ /* 阶段 3 产出 */ ],
      "teaching": { /* 阶段 4 产出 */ },
      "animations": [ /* 阶段 5 产出 */ ]
    }
    /* ... 其他知识点,按拓扑序 ... */
  ]
}
```

## 组装检查清单

拼装前确认每个知识点的 6 个字段齐全:

- [ ] id / title / objective / depends_on / estimated_minutes(来自 dag)
- [ ] code(来自阶段 2)
- [ ] trace(来自阶段 3)
- [ ] teaching(来自阶段 4)
- [ ] animations(来自阶段 5)

缺任何一个字段,回到对应阶段补。

## schema 校验

组装完后,用 `assets/schema.json` 做严格校验。校验方式:

```bash
# 用 ajv CLI 或 node 脚本
ajv validate -s assets/schema.json -d content.json --strict
```

或在本会话里直接用 node 验证(如果环境有 ajv):

```javascript
const Ajv = require("ajv");
const addFormats = require("ajv-formats");
const schema = require("./assets/schema.json");
const data = require("./content.json");
const ajv = new Ajv({strict: true});
addFormats(ajv);
const validate = ajv.compile(schema);
const valid = validate(data);
if (!valid) console.log(validate.errors);
```

## 常见校验失败 & 修复

| 错误 | 原因 | 回到哪个阶段 |
|------|------|-------------|
| `required` 缺失 | 某知识点缺字段 | 对应阶段补 |
| `pattern` 不匹配 | id 不符合 snake_case | 阶段 1 改 id |
| `minItems` 练习题 < 2 | 练习不够 | 阶段 4 补题 |
| `additionalProperties` | 多了 schema 没定义的字段 | 组装时删除多余字段 |
| `estimated_minutes` 超界 | 时长不在 5-60 | 阶段 1 调整 |
| trace 帧的 line 超界 | line > code.lines.length | 阶段 3 修 trace |
| depends_on 引用不存在的 id | 拓扑引用错误 | 阶段 1 检查 DAG |

## 拓扑序验证(额外检查)

schema 不强制拓扑序,但 content.json 的 knowledge_points 应按拓扑序排列(被依赖的在前)。
组装后额外验证:

1. 构建依赖图,检查无环
2. 检查每个知识点的 depends_on 引用的 id 都在它**之前**出现
3. 不满足则重排数组

## 完成判定

- content.json 通过 schema 校验(零错误)
- 拓扑序验证通过(无环,依赖在前)
- 所有 knowledge_points 字段齐全

## 交付

校验通过后,content.json 即为最终交付物。
告知用户:
- 文件位置
- 知识点数量
- 总预估学习时长(sum of estimated_minutes)
- 这个文件可直接交给渲染引擎消费
