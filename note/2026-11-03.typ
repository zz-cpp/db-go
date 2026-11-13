// answer-note · 按日归档问答记录
#import "@preview/ilm:2.1.1": *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node
#import "@preview/cetz-plot:0.1.4": chart, plot

// ═══ 三色判断框体系（与课程笔记同构；无自测框）═══
#let importantbox(body) = block(
  width: 100%,
  breakable: true,
  fill: rgb("#eef3fb"),
  stroke: (left: 3pt + rgb("#2f6fd0")),
  inset: (x: 11pt, y: 8pt),
  radius: 4pt,
)[*📌 核心要点*  #body]
#let knowledgebox(body) = block(
  width: 100%,
  breakable: true,
  fill: rgb("#eefaf1"),
  stroke: (left: 3pt + rgb("#2e9e5b")),
  inset: (x: 11pt, y: 8pt),
  radius: 4pt,
)[*💡 背景与类比*  #body]
#let warningbox(body) = block(
  width: 100%,
  breakable: true,
  fill: rgb("#fdf1ef"),
  stroke: (left: 3pt + rgb("#d64541")),
  inset: (x: 11pt, y: 8pt),
  radius: 4pt,
)[*⚠️ 陷阱预警*  #body]

// ═══ 标题栏版判断框（对应 lecture-to-notes 的 tcolorbox attach boxed title 样式）═══
#let titledbox(
  title,
  body,
  bg: rgb("#eefaf1"),
  title-bg: rgb("#2e9e5b"),
  title-fg: white,
  stroke: 1pt + luma(70),
) = block(
  width: 100%,
  breakable: true,
  radius: 0pt,
  fill: bg,
  stroke: stroke,
  inset: 0pt,
)[
  #block(width: 100%, fill: title-bg, inset: (x: 8pt, y: 3pt), radius: 0pt)[
    #text(fill: title-fg, weight: "bold")[#title]
  ]
  #block(width: 100%, inset: (x: 9pt, y: 7pt))[#body]
]

// ═══ 行内 raw（机器符号 `...`）样式：等宽 + 淡底、保持内联 ═══
// 注意：不要用全局 #show raw.line —— 它会把行内反引号也渲染成带行号的整行方块
#show raw.where(block: false): it => box(
  fill: luma(243),
  inset: (x: 1.6pt, y: 0.3pt),
  radius: 1.5pt,
)[#text(font: "DejaVu Sans Mono", size: 0.88em)[#it.text]]

// ═══ codelisting（CS 轨用）═══
#let codelisting(code, lang: "typst", caption: none) = figure(caption: caption, block(
  width: 100%,
  breakable: true,
  stroke: 0.8pt + luma(200),
  inset: 8pt,
)[
  // 行号规则只在 codelisting 内部局部生效
  #show raw.line: line => box(width: 100%)[
    #box(width: 2.4em)[#text(fill: luma(150), size: 0.72em)[#str(line.number)]]
    #line.body
  ]
  #set text(size: 0.9em)   // 对应 listings 的 \small；raw 无自动折行，长行手动折
  #raw(code, lang: lang, block: true)
])

// ═══ booktabs-table ═══
#let booktabs-table(columns: (), ..rows) = block(width: 100%, breakable: true)[#table(columns: columns, stroke: (
    top: 1.2pt + black,
    bottom: 1.2pt + black,
    x: none,
    y: 0.5pt + luma(160),
  ), fill: none, inset: (x: 8pt, y: 5pt), ..rows)]

// ═══ 子图助手（对应 lecture-to-notes 的 subcaption）═══
#let subfigure(items, caption: none, columns: (1fr, 1fr), gutter: 0.6cm) = figure(
  grid(
    columns: columns, gutter: gutter,
    ..(
      for i in range(items.len()) {
        let item = items.at(i)
        let body = item.at(0)
        let label = item.at(1, default: none)
        let letters = ("a", "b", "c", "d", "e", "f", "g", "h")
        (
          [
            #align(center)[#body]
            #if label != none [
              #align(center)[*（#letters.at(calc.min(i, letters.len() - 1))）#label*]
            ]
          ],
        )
      }
    ),
  ),
  caption: caption,
)

// ═══ 折线助手（CeTZ 0.5.2 无 plot）═══
#let plotline(points, stroke: 1pt + black) = cetz.draw.line(..points, stroke: stroke)

// ═══ 图内公式编号助手（ilm 编号影响绘图内容时的解法）═══
#let unnumbered(body) = {
  set math.equation(numbering: none)
  body
}

#show: ilm.with(
  title: [数学与 CS 问答笔记],
  authors: ("answer-note",),
  date: datetime.today(),
  abstract: [0101 规格评审：AF 的抽象值形状、RI 里哪条其实由类型保证、RI 没有维护者时会变成空话、防御性拷贝为什么是双向的。],
  bibliography: none,
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

// 轨道：CS 轨

= 0101 规格评审：AF / RI / Safety 三处修正（Spec Review）｜问题 0101

== 费曼直觉

学生交上来的三句话，每一句都踩在一个典型的边界上：

- *AF* 把「映射」写成了「对的集合」——听起来差不多，但抽象值的形状决定了你能不能用它推出 `Get` 的语义。
- *RI* 写了一条「键不重复」——这是 Go map 的类型保证，不是这份表示的性质。
- *Safety* 只写了出向拷贝，漏了入向——别名是双向的。

#importantbox[
评审不是找错别字。每一处要问的都是同一个问题：*这句话约束的是谁、靠什么维持*。答不上来，就说明它放错位置了。
]

== 硬核机制

=== AF 的形状：映射 vs 对的集合

抽象值必须是「键到值的映射」，理由很直接：`Get(k)` 的规格要求「返回 k 对应的值」。如果 AF 说抽象值是「键值对的集合」，那么「k 对应的值」这个概念在抽象层根本不存在——你只能回答「这对在不在集合里」。

#booktabs-table(
  columns: (1fr, 2fr, 2fr),
  [*AF 的写法*], [*能推出 `Get` 吗*], [*问题*],
  [\`AF(mem) = { k -> mem[k] | ... }\`], [能：k 对应的值就是 mem[k]], [需要覆盖空 map],
  [\`AF(mem)\` = 键值对的集合], [不能：没有「对应」这个概念], [抽象值与客户端看到的行为不一致],
)

=== RI 里的三类子句

#booktabs-table(
  columns: (1.4fr, 2fr, 2.4fr),
  [*子句类型*], [*例子*], [*靠什么维持*],
  [类型保证], [map 的键不重复], [Go 运行时与编译器，不需要你写],
  [表示性质（真 RI）], [键非空、值非空], [实现自己：构造器与变值器],
  [前置条件], [调用者不能传空 key], [调用者；实现可以不检查],
)

#warningbox[
最危险的状态不是「RI 写多了」，而是*写了 RI 却没有任何代码维持它*。比如写了「键非空」，但 `Set` 直接存，那这条 RI 在第一次调用时就被破坏了——后续所有推理都失效。
]

=== 防御性拷贝是双向的

#codelisting(
  "// 入向：调用者的切片被存进 mem\nfunc (kv *KV) Set(key, val []byte) (bool, error) {\n\tkv.mem[string(key)] = val\n\treturn true, nil\n}\n\n// 调用者之后改自己的切片：\nval[0] = 0x78   // mem 里存的值跟着变\n\n// 出向：mem 里的切片被交给调用者\nfunc (kv *KV) Get(key []byte) ([]byte, bool, error) {\n\treturn kv.mem[string(key)], true, nil\n}\n\n// 调用者改返回的切片：mem 内部被改",
  lang: "go",
  caption: [两条别名路径：入向（Set 存引用）与出向（Get 返引用）],
)

== 落到项目

本次交上来的三句与本项目的判定：

#booktabs-table(
  columns: (0.8fr, 2.2fr, 1fr, 2fr),
  [*项*], [*原文要点*], [*判定*], [*原因*],
  [AF], [键唯一、值成对], [🟨], [抽象值应为映射；「键唯一」是类型保证；空 map 未覆盖],
  [RI], [键非空、键不重复、值非空], [🟨], [「键不重复」不是 RI；「键非空」缺维护者],
  [Safety], [mem 私有，Get 做防御性拷贝], [🟩], [方向对；漏 Set 的入向拷贝],
)

#importantbox[
按本人 2026-11-02 的约定：*强度跟随当前测试*。当前 `TestKVBasic` 没有空键、没有别名用例，所以这三处都可以先按「标注 + TODO(阶段末)」处理；但*写着却不实现*是不允许的——那会让规格与实现脱节。
]

== 陷阱与易错

- *把类型保证写进 RI*：map 的键唯一、切片的长度可查——这些不是你的表示不变式。
- *AF 写成集合*：抽象值形状不对，`Get` 的语义就推不出来。
- *只防出向别名*：`Set` 存了调用者的切片，调用者之后改动会穿透进 `mem`。
- *RI 没有维护者*：写了「键非空」，`Set` 却不检查，等于没写。

#warningbox[
零值 `KV{}` 的 `mem` 是 nil。`Open()` 之后才非 nil，所以「`mem != nil`」如果不写进 RI，就要接受 `KV{}` 直接 `Set` 会 panic（`assignment to entry in nil map`）。这是 Go 零值可用性的经典取舍。
]

== 关键点

1. AF 的抽象值是*映射*，且必须覆盖空表示。
2. RI 里先剔除「类型保证」，剩下的才是你要维持的。
3. 每条 RI 都要回答「谁维持它」；答不上来就降级为前置条件或删掉。
4. 防御性拷贝分入向、出向两条路径。
5. 规格强度跟随测试，但规格与实现不能脱节。

== 变式检验

把同一套判断搬到 `IntSet`（`elems []int`，升序无重复）：

- 「升序无重复」是表示性质（切片本身允许重复乱序）→ 真 RI，由 `Add` 维持；
- 「元素总数不超过容量」若实现从不检查 → 它是前置条件，不是 RI；
- 出向：`Elems()` 返回 `elems` 本身会让调用者改坏有序性；
- 入向：`Add(xs ...int)` 若直接 `append(elems, xs...)`，调用者之后改 `xs` 会穿透。

== 同类归类

#booktabs-table(
  columns: (1fr, 2fr, 2fr),
  [*概念*], [*6.102*], [*6.031*],
  [C09 AF/RI], [R07 Abstraction Functions and Rep Invariants], [R11 Invariants],
  [C07 别名], [R05 散见], [R08 Mutability and Immutability],
  [C05 规格], [R04 Specifications], [R06 Specifications],
)

== Go 语言机制补充

#codelisting(
  "// 零值 map 与空 map 是两件事\nvar a map[string][]byte   // nil：读安全，写 panic\nb := map[string][]byte{} // 非 nil 空 map：读写都安全\n\n// 防御性拷贝\ngo doc bytes.Clone\ngo doc slices.Clone",
  lang: "go",
  caption: [nil map 与空 map 的区别；标准库的拷贝工具],
)

权威出处：`go doc bytes.Clone`、`go doc slices.Clone`、`go doc reflect.SliceHeader`（切片头三字段 Data / Len / Cap）。

== 本次操作与当前状态

*本次检查*

- 交卷内容：`internal/db/kv.go` 的 AF / RI / Safety 三处注释（题 2–4），`Get` / `Set` / `Del` 仍是 `panic("TODO: 0101")`。
- 未交：题 1（红基线分类）、题 5（分区表）、题 6（实现）、题 7（验证）、题 8（内化 5 问）。
- 红基线现状：`Open` / `Close` 恢复为官方实现后，`assert.Nil` 通过，第一处 panic 在 `Set`（`kv.go:29`）。

*评审结论*

- AF 🟨：抽象值应为映射；「键唯一」属类型保证；空 map 未覆盖。
- RI 🟨：「键不重复」不是 RI；「键非空」「值非空」是真 RI 但缺维护者。
- Safety 🟩：出向拷贝写对，缺入向（`Set` 存引用）。

*下一步*

1. 改 AF 为映射写法并覆盖空 map；
2. RI 决定「键非空」的维护者（Set 检查 / 前置条件 / 删除）；
3. Safety 补入向拷贝一句；
4. 做题 5 分区表、题 6 实现，然后题 7 跑测试。
