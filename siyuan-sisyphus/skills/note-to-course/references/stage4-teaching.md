# 阶段 4:生成讲解 + 练习 + 卡片

本文件在 SKILL.md 路由到阶段 4 时按需加载。对每个知识点独立生成,可并行。

## 目标

为每个知识点生成完整的教学内容:讲解、练习题、记忆卡片。
这是学习者在网站上看到的"软内容"——讲解是否透彻、练习是否有效,直接决定学习体验。

## 输入

- 知识点 `objective` + `title`
- 阶段 2 的代码示例
- **笔记原文**(用 `document.get_doc` 读取)——讲解要基于笔记,不是凭空编

## 输出结构(teaching 对象)

```json
{
  "explanation": { ... },
  "exercises": [ ... ],
  "flashcards": [ ... ]
}
```

---

## 4.1 讲解(explanation)

三件套:一句话定义 + 生活类比 + 常见误区。

```json
{
  "explanation": {
    "summary": "所有权只能有一个持有者,赋值即转移,原变量失效",
    "analogy": "就像一本书的借阅权。你把书借给别人(赋值),你手里的书就没了——书只有一本,不能两人同时拿着",
    "pitfalls": [
      "误以为赋值是复制(来自 C/Python 直觉)",
      "忘记函数传参也会转移所有权",
      "在循环里反复赋值导致所有权链断裂"
    ]
  }
}
```

要点:
- `summary`:一句话,精确,不含废话
- `analogy`:用生活经验类比,**这是直觉理解的关键**。要贴切,不要硬凑
- `pitfalls`:基于笔记里的难点 + 经验,2-4 条,每条点出"为什么会错"

## 4.2 练习题(exercises)

至少 2 道,建议混合不同类型。题型四选:

| type | 说明 | answer 类型 |
|------|------|------------|
| `choice` | 选择题 | number(选项索引) |
| `prediction` | 给代码预测输出 | number(选项索引) |
| `fill` | 补全代码空位 | string |
| `fix` | 给错误代码改对 | string |

示例:

```json
[
  {
    "id": "q_move_1",
    "type": "prediction",
    "prompt": "下面代码的输出是什么?",
    "code": "let a = vec![1,2,3];\nlet b = a;\nprintln!(\"{}\", b[0]);",
    "options": ["1", "编译错误", "运行时错误", "3"],
    "answer": 0,
    "explanation": "所有权从 a 转移到 b,b 持有值,b[0] 是 1。a 已失效但这里没访问 a。"
  },
  {
    "id": "q_move_2",
    "type": "fix",
    "prompt": "这段代码访问了失效的 a,怎么改才能正确打印?",
    "code": "let a = vec![1,2,3];\nlet b = a;\nprintln!(\"{}\", a[0]);",
    "answer": "把 println 里的 a 改成 b",
    "explanation": "所有权已转移给 b,访问 b 而非 a。或用 a.clone() 复制一份。"
  }
]
```

要点:
- 每题必须有 `explanation`(答错时展示)
- `prediction`/`choice` 题的选项要包含**有迷惑性的错误项**(基于 pitfalls)
- `fix`/`fill` 题的答案要唯一明确,不要开放式

## 4.3 记忆卡片(flashcards)

至少 1 张。混合两种形式:

| type | 适用 | 字段 |
|------|------|------|
| `qa` | 概念类 | front(问题) + back(答案) |
| `code_fill` | 技能类 | code(挖空代码) + blank(空位标记) + answer |

示例:

```json
[
  {
    "id": "c_move_1",
    "type": "qa",
    "front": "Rust 中把一个 Vec 赋值给另一个变量后,原变量还能用吗?",
    "back": "不能。所有权转移,原变量失效。需要继续使用就 clone() 或借用。"
  },
  {
    "id": "c_move_2",
    "type": "code_fill",
    "code": "let a = vec![1,2,3];\nlet b = ___;\n// 把 a 的所有权转移给 b",
    "blank": "___",
    "answer": "a"
  }
]
```

卡片用于 SM-2 间隔重复。要点:
- `qa` 卡片:front 要简洁(一秒能读完),back 要精准
- `code_fill` 卡片:挖空处是知识点的核心动作(不是无关细节)

## 质量自检

生成后自检:
- [ ] summary 是否精确(不含"基本上""大概"这类词)?
- [ ] analogy 是否贴切(没有强行类比)?
- [ ] 每道练习题的 explanation 是否讲清了"为什么"?
- [ ] 练习题选项的干扰项是否基于真实误区(而非随机凑数)?
- [ ] 卡片是否聚焦核心(一张卡只测一个点)?

## 完成判定

- 每个知识点都有 explanation + ≥2 道练习 + ≥1 张卡片
- 所有 explanation/analogy 基于笔记原文(不编造)
- 练习题答案明确、解析到位
