// answer-note · 当天问答文件的完整头部（新建 note/<日期>.typ 时整段复制）
// 来源：原 answer-note/SKILL.md 的「文件操作」章节，2026-10-31 拆出。

#import "@preview/ilm:2.1.1": *
#import "@preview/cetz:0.5.2"
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz-plot:0.1.4": plot, chart

// ═══ 三色判断框体系（与课程笔记同构；无自测框）═══
#let importantbox(body) = block(width: 100%, breakable: true, fill: rgb("#eef3fb"), stroke: (left: 3pt + rgb("#2f6fd0")), inset: (x: 11pt, y: 8pt), radius: 4pt)[*📌 核心要点*  #body]
#let knowledgebox(body) = block(width: 100%, breakable: true, fill: rgb("#eefaf1"), stroke: (left: 3pt + rgb("#2e9e5b")), inset: (x: 11pt, y: 8pt), radius: 4pt)[*💡 背景与类比*  #body]
#let warningbox(body) = block(width: 100%, breakable: true, fill: rgb("#fdf1ef"), stroke: (left: 3pt + rgb("#d64541")), inset: (x: 11pt, y: 8pt), radius: 4pt)[*⚠️ 陷阱预警*  #body]

// ═══ 标题栏版判断框（对应 lecture-to-notes 的 tcolorbox attach boxed title 样式）═══
#let titledbox(title, body, bg: rgb("#eefaf1"), title-bg: rgb("#2e9e5b"), title-fg: white, stroke: 1pt + luma(70)) = block(
  width: 100%, breakable: true, radius: 0pt, fill: bg, stroke: stroke, inset: 0pt,
)[
  #block(width: 100%, fill: title-bg, inset: (x: 8pt, y: 3pt), radius: 0pt)[
    #text(fill: title-fg, weight: "bold")[#title]
  ]
  #block(width: 100%, inset: (x: 9pt, y: 7pt))[#body]
]

// ═══ 行内 raw（机器符号 `...`）样式：等宽 + 淡底、保持内联 ═══
// 注意：不要用全局 #show raw.line —— 它会把行内反引号（如 `H`、`inst[11:8]`）也渲染成带行号的整行方块
#show raw.where(block: false): it => box(
  fill: luma(243),
  inset: (x: 1.6pt, y: 0.3pt),
  radius: 1.5pt,
)[#text(font: "DejaVu Sans Mono", size: 0.88em)[#it.text]]

// ═══ codelisting（CS 轨用）═══
#let codelisting(code, lang: "typst", caption: none) = figure(caption: caption, block(width: 100%, breakable: true, stroke: 0.8pt + luma(200), inset: 8pt)[
    // 行号规则只在 codelisting 内部局部生效
    #show raw.line: line => box(width: 100%)[
      #box(width: 2.4em)[#text(fill: luma(150), size: 0.72em)[#str(line.number)]]
      #line.body
    ]
    #set text(size: 0.9em)   // 对应 listings 的 \small；raw 无自动折行，长行手动折
    #raw(code, lang: lang, block: true)
  ])

// ═══ booktabs-table ═══
#let booktabs-table(columns: (), ..rows) = block(width: 100%, breakable: true)[#table(columns: columns, stroke: (top: 1.2pt + black, bottom: 1.2pt + black, x: none, y: 0.5pt + luma(160)), fill: none, inset: (x: 8pt, y: 5pt), ..rows)]

// ═══ 子图助手（对应 lecture-to-notes 的 subcaption）═══
#let subfigure(items, caption: none, columns: (1fr, 1fr), gutter: 0.6cm) = figure(
  grid(
    columns: columns, gutter: gutter,
    ..(for i in range(items.len()) {
        let item = items.at(i)
        let body = item.at(0)
        let label = item.at(1, default: none)
        let letters = ("a", "b", "c", "d", "e", "f", "g", "h")
        ( [
            #align(center)[#body]
            #if label != none [
              #align(center)[*（#letters.at(calc.min(i, letters.len() - 1))）#label*]
            ]
          ], )
      }),
  ),
  caption: caption,
)

// ═══ 折线助手（CeTZ 0.5.2 无 plot）═══
#let plotline(points, stroke: 1pt + black) = cetz.draw.line(..points, stroke: stroke)

// ═══ 图内公式编号助手（ilm 编号影响绘图内容时的解法）═══
// 用法：content((1.6, 0.4), unnumbered($ x = -t^2 $), fill: red)；正文编号照常保留。
// 整篇不需要编号时：在 #show: ilm.with(...) 之后加 #set math.equation(numbering: none)
#let unnumbered(body) = { set math.equation(numbering: none); body }

#show: ilm.with(
  raw-text: (font: "DejaVu Sans Mono"),
  title: [数学与 CS 问答笔记],
  authors: ("answer-note",),
  date: datetime.today(),
  abstract: [按日归档的问答笔记：三问反思法（关键点/变式/同类归类）+ 讲课叙事流 + CeTZ 图示，结构与课程笔记同构。],
  bibliography: none,
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

// 轨道：CS 轨
= 6.102 的默认非空引用与 0102 的 Entry

== 费曼直觉

你记得对。MIT 6.102 sp26 在 R04 的 Avoid null 规定，除非明确声明允许，函数的对象或集合参数及返回值默认排除 `null`，也包括集合里的引用元素。课程开启 TypeScript 的 `strictNullChecks`，用类型检查落实对 `null` 和 `undefined` 的限制。这样调用者拿到声明为字符串的值，就能直接读取长度，不必每次先检查引用是否存在。R04 的 Include emptiness 则默认允许空字符串或空集合。 #link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#avoid_null")[R04 · Avoid null] · #link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#include_emptiness")[R04 · Include emptiness]

== 硬核机制

#booktabs-table(
  columns: (1fr, 2.5fr),
  [判断范围], [依据与含义],
  [函数的参数和结果], [R04 的规格约定。若业务需要允许缺值，课程要求在类型里写出来，例如 `string | null`。],
  [类型的内部字段], [R07 把同样的约定延伸到表示不变式（RI），也就是规定哪些字段状态合法。它默认排除表示中引用的 `null` 和 `undefined`。],
  [Go 的字节切片], [`[]byte` 可以取 `nil`。如果规格要限制这一状态，应写明限制在哪些时刻生效。],
)

#importantbox[记忆锚点是「空集合仍是集合」。课程的默认值域属于规格约定。迁到 Go 时，先看该类型允许哪些操作，再看应用对缺值有没有额外定义。]

#link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#no_null_values_in_the_rep")[R07 · No null values in the rep]

== 陷阱与易错

#warningbox[`TestEntryEncode` 用 `Entry{}` 接收解码结果，此时 `key` 和 `val` 都是 `nil`。如果在 `Decode` 入口运行当前的 `checkRep`，它会中断这条测试所要求的调用。]

== 关键点

在 0102 中，读 `internal/db/kv_entry_test.go:45` 可以看到，`Decode` 允许从 `Entry{}` 开始，成功后字段应和样例中的键值一致。若 Q2.1 最终为已经建立的记录选用非 `nil` 约束，成功解码之后才是该约束在这条路径上的检查点。测试的键和值都有内容，无法判定长度为零时的字段应取哪种表示，留 `TODO(阶段末)`。测试里的 `assert.Nil(t, err)` 则专门检查没有错误，体现了 Go 的错误返回约定。

== 变式检验

想象一个接收设备消息的程序。消息可以只带一个心跳信号而没有负载，比较内容只需看字节，复制时却可能要求保留原来的 `nil` 状态。若把「字段非 `nil`」当作「负载有字节」，零长度值也会被误认成带内容的消息。0102 同样面对零字节与字段表示的关系，具体政策应由它自己的契约确定。

== 同类归类

Go 标准库给出了两种设计。`bytes.Equal` 对内容做比较，核心是 `return string(a) == string(b)`，所以它把 `nil` 和空切片视为相等。`bytes.Clone` 复制输入，专门用 `if b == nil { return nil }` 保留 `nil`。两处分别可查 `/usr/lib/go/src/bytes/bytes.go:20` 与 `/usr/lib/go/src/bytes/bytes.go:1391`。

== Go 语言机制补充

切片是访问一段元素的值，运行时保存数据指针、长度和容量（底层空间允许的元素数）。零值是声明变量后未赋初值时得到的值。字节切片的零值是 `nil`，长度按语言规范为零，而 `[]byte{}` 显式构造了一个长度为零的非 `nil` 切片。用 `len(payload) == 0` 问有没有字节，用 `payload == nil` 问它是不是 `nil`。可查 `go doc builtin.len`、`go doc -src bytes.Equal`、`go doc -src bytes.Clone` 与 `/usr/lib/go/src/runtime/slice.go:16`。 #link("https://go.dev/ref/spec#Length_and_capacity")[Go 语言规范 · Length and capacity]

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "fmt"
  )

  func main() {
      var absent []byte
      empty := []byte{}
      fmt.Println(absent == nil, empty == nil)
      fmt.Println(len(absent), len(empty), bytes.Equal(absent, empty))
      fmt.Println(bytes.Clone(absent) == nil, bytes.Clone(empty) == nil)
  }
  ```).text,
  lang: "go",
  caption: [保存为临时的 `payload.go`，执行 `go run payload.go`],
)

三行输出依次是 `true false`、`0 0 true`、`true false`。只比较内容时，两者都是零字节。需要保留状态时，复制操作可以保留这个差别。

== 本次操作与当前状态

核对了 MIT R04、R07 的在线原文和本地镜像、Go 文档和标准库源码，以及 0102 的现有测试与 `checkRep`。临时示例运行通过，输出与上述预测一致。本次只记录概念问答，工程验收沿用 0102 的原进度。填 Q2.1 时，先标明 RI 适用的状态，再把测试未覆盖的零长度表示留到阶段末。当天 Typst 已做机械自检并编译同级 PDF。

// 轨道：CS 轨
= ADT 除了 AF、RI 和表示暴露安全还要写什么

== 费曼直觉

*再补两项规格：抽象值域和操作契约。* 抽象数据类型（ADT）用一组操作及其契约来定义数据。例如，调用者可以把缓冲区理解成一段可读写的字节，并按承诺读取，而无需知道实现用了几个字段。抽象值域描述一个值在业务上是什么，操作契约描述调用者怎样创建、观察和改变这个值。MIT 6.102 sp26 T08（R06）从操作定义类型，T09（R07）的写作顺序是先写规格，再写测试，最后选定内部表示并实现。 #link("https://web.mit.edu/6.102/www/sp26/classes/06-abstract-data-types/#an_abstract_type_is_defined_by_its_operations")[R06 · An abstract type is defined by its operations] · #link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#writing_an_abstract_data_type")[R07 · Writing an abstract data type]

== 硬核机制

#booktabs-table(
  columns: (1.05fr, 1.25fr, 2.8fr),
  [落在哪里], [写什么], [回答的问题],
  [类型文档], [抽象值域], [一个值表示什么？如果允许修改或有特殊的创建、初始化规则，调用者需要知道什么？],
  [操作文档], [操作契约], [操作名称和参数、结果的类型是什么？调用前须满足什么（Requires）？返回值、错误和调用后可见的变化是什么（Effects）？],
  [实现注释], [AF、RI、表示暴露安全], [合法字段对应哪个抽象值？哪些字段状态合法？从输入到输出，哪些路径可能让调用者改到内部数据？],
  [实现与测试], [`checkRep` 与测试用例], [`checkRep` 在选定的位置检查内部状态。测试用具体输入和独立预期核对契约中的结果或状态变化。],
)

AF（抽象函数）给出字段到抽象值的映射。RI（表示不变式）限定映射适用的合法字段状态。实例的创建或初始化要建立 RI，之后的操作要保持 RI，表示暴露安全的论证则检查调用者是否能绕过这些操作破坏 RI。三者共同说明实现如何维持契约。 #link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#what_an_adt_specification_may_talk_about")[R07 · What an ADT specification may talk about] · #link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#how_to_establish_invariants")[R07 · How to establish invariants]

== 陷阱与易错

#warningbox[`Entry{}` 是 `TestEntryEncode` 证明 `Decode` 必须接受的一种初始状态。它单独无法推出调用前必须为空，也无法决定所有操作是否都接受 `Entry` 的零值。写 Q2.3 时，把「允许这一状态」和「调用者必须处于这一状态」区分开。]

== 关键点

#importantbox[0102 已有抽象值域的起点，`Entry` 表示一条键值记录。当前要补的是 `Encode` 和 `Decode` 的操作契约。`Encode` 的固定字节格式写进 Effects，因为测试直接比较返回字节。`Decode` 的成功结果用「记录的键和值」来描述，字段如何赋值由实现决定。]

在 `internal/db/kv_entry.go` 的 Q2.2、Q2.3 填入能由当前样例支持的契约，再在 `internal/db/kv_entry_test.go` 的 Q3 对应到具体断言。测试尚未确定的空键或空值、读取失败后的状态、返回字节的共享规则，沿用 `TODO(阶段末)`。可以用创建、观察、修改、从旧值生成新值这四类检查操作是否满足需要。相等性和额外构造方法等由实际调用需求决定。 #link("https://web.mit.edu/6.102/www/sp26/classes/06-abstract-data-types/#designing_an_abstract_type")[R06 · Designing an abstract type]

== 变式检验

设想 `Entry` 内部改用一段连续字节和一个分隔位置来保存键值。AF 和 RI 会随字段变化。如果同一条记录仍能编码为同一串字节、也能从那串字节恢复，调用者就可以继续依赖这两项行为。当前测试可借此理解 6.031 的测试方法，即通过观察到的结果检查创建或修改操作。项目的现有测试直接比较字段所在的结构体，属于能接触内部表示的测试。 #link("https://web.mit.edu/6.031/www/sp21/classes/10-abstract-data-types/#testing_an_abstract_data_type")[6.031 sp21 R10 · Testing an abstract data type]

== 同类归类

设想一个程序有两项工作：整理一段待发的字节，以及生成要交给调用者的文本。前者的调用者可能要直接改缓冲区中的字节，后者已交出的字符串必须保持原样。若把第一种结果当成独立副本，改一个字节就可能意外改掉待发内容。它们和 0102 都涉及数据交给调用者后能否影响内部状态。`Entry` 的所有权政策仍由本步规格和证据决定。

- `bytes.Buffer.Bytes` 暴露可写的字节视图，现有实现返回 `b.buf[b.off:]`。在缓冲区下次修改前，直接改这个视图会影响之后的读取。调用限制写进方法文档。出处为 `/usr/lib/go/src/bytes/buffer.go:60`，可查 `go doc -src bytes.Buffer.Bytes`。 #link("https://pkg.go.dev/bytes#Buffer.Bytes")[Go 标准库 · Buffer.Bytes]
- `strings.Builder.String` 返回已经累计的字符串。标准库实现从内部缓冲区生成 `string`，调用者拿到的是不可直接改其中字节的值。出处为 `/usr/lib/go/src/strings/builder.go:46`，可查 `go doc -src strings.Builder.String`。 #link("https://pkg.go.dev/strings#Builder.String")[Go 标准库 · Builder.String]

== Go 语言机制补充

零值是变量声明后未显式赋初值时得到的值。下面的两个 `var` 都从零值开始，能马上写入是这两个类型各自的承诺。`[]byte` 是字节切片，可以通过下标访问和改写一段底层字节。两个值访问同一段可写存储叫别名。切片可以形成别名，Go 的 `string` 值则不可原地修改。日常把零值可用性和共享限制写入调用者能读到的类型或方法注释。Go 的文档注释紧贴声明，可以用 `go doc` 查看。 #link("https://go.dev/ref/spec#The_zero_value")[Go 语言规范 · The zero value] · #link("https://go.dev/ref/spec#String_types")[Go 语言规范 · String types] · #link("https://go.dev/doc/comment")[Go Doc Comments]

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "fmt"
      "strings"
  )

  func main() {
      var buffer bytes.Buffer
      buffer.WriteString("cat")
      view := buffer.Bytes()
      view[0] = 'b'
      fmt.Println(buffer.String())

      var builder strings.Builder
      builder.WriteString("cat")
      before := builder.String()
      builder.WriteString("s")
      fmt.Println(before, builder.String())
  }
  ```).text,
  lang: "go",
  caption: [保存为 `adt_demo.go`，运行 `go run adt_demo.go` 或 `go vet adt_demo.go`],
)

第一行输出 `bat`，因为字节视图和缓冲区访问同一段数据。第二行输出 `cat cats`，因为已返回的字符串仍是拼接前的值。

== 本次操作与当前状态

从上次中断处恢复，核对了 MIT 6.102 R06、R07、6.031 R10 和 Go 官方文档、标准库源码。独立 Go 示例运行与 `go vet` 均通过。`go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/` 在 `Encode`、`Decode` 的声明处报告 `missing function body`，尚未执行断言。本次追加问答笔记并更新同级 PDF。新增结论对应 0102 的 Q2.2、Q2.3，练习按原有顺序填写 Q2.1 至 Q3。当天笔记经机械自检后编译同级 PDF。

// 轨道：CS 轨
== Encode 的 Requires 是否要重复 RI

=== 费曼直觉

#importantbox[如果 `Encode` 接受每个合法的 `Entry`，调用者就没有额外条件要满足，可以省略 `Requires`。练习模板若想显式交代这一点，可填「无额外前置条件」。保留 `Effects`，写清返回的字节格式。]

6.102 R07 的例子把排序和去重交给 `SortedCharSet` 保证，使用该类型的操作因此可以省掉关于排序和去重的前置条件。迁回 `Entry`，长度限制由建立和修改记录的代码维持。`Encode` 可以依赖这项保证。 #link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#adt_invariants_replace_preconditions")[6.102 R07 · ADT invariants replace preconditions]

=== 硬核机制

#booktabs-table(
  columns: (1.1fr, 1.3fr, 2.7fr),
  [术语], [责任], [当前例子],
  [RI（表示不变式）], [实现负责建立和维持], [`Entry` 草稿规定两个字段的长度各自最多为 `2^32 - 1`。同包中能直接写字段的代码也承担这项责任。],
  [Requires（前置条件）], [调用者须在调用前满足], [当一个操作只接受合法记录中的一部分，或对额外参数有限制时，写明这项调用限制。],
  [Effects（后置条件）], [操作对调用者承诺], [`Encode` 的结果遵循什么格式，即使没有额外前置条件也要写清楚。],
)

=== 陷阱与易错

#warningbox[RI 写在注释里，Go 编译器不会替代码检查它。`checkRep` 是执行到调用点才运行的检查。若同包代码直接给 `ent.key` 或 `ent.val` 赋值，赋值路径也要保持长度限制。]

=== 关键点

Q2.2 可以删掉 `Requires` 那一行，直接填写 `Effects`。`Entry{}` 里的两个切片字段均为 `nil`，长度都是零，所以按当前草稿满足这两条 RI。`var p *Entry` 中的 `p` 则是一个没有指向对象的指针。现有测试没有规定 `Encode` 对这种调用的行为，继续留在 `TODO(阶段末)`。 #link("https://go.dev/ref/spec#The_zero_value")[Go 语言规范 · The zero value] · #link("https://go.dev/ref/spec#Length_and_capacity")[Go 语言规范 · Length and capacity]

=== 变式检验

如果以后要对某项操作要求键非空，而空键仍属于合法记录，那么它就是那项操作独有的前置条件。还有一个实现边界可以留到阶段末核对：两个字段分别符合长度上限，只说明各自的长度字段装得下。`Encode` 返回一整个切片，仍需考虑头部加上键值的总长度能否用 Go 的 `int` 表示，尤其是在 32 位目标上。

=== 同类归类

假设发送程序先把 `abc` 放进可修改的缓冲区，再按协议裁成前两字节。直接查询剩余长度，只需缓冲区状态有效。裁剪时，协议给出的保留长度也必须落在现有数据范围内。疏忽导致请求保留四字节时，Go 的 `Truncate` 会触发 `panic`，中断正常执行。映射回 0102，`Encode` 没有像 `n` 这样的额外参数。如果将来某项操作单独限制一部分合法记录，再在那项操作上写明前置条件。

- `bytes.Buffer.Len` 实现为 `return len(b.buf) - b.off`。调用者可以查询任意有效缓冲区的未读长度，内部读到的位置由类型维护。出处为 `/usr/lib/go/src/bytes/buffer.go:97`，可用 `go doc -src bytes.Buffer.Len` 查看。 #link("https://pkg.go.dev/bytes#Buffer.Len")[Go 标准库 · Buffer.Len]
- `bytes.Buffer.Truncate` 额外接收要保留的字节数 `n`。实现用 `n < 0 || n > b.Len()` 识别越界，文档写明越界会产生 `panic`。出处为 `/usr/lib/go/src/bytes/buffer.go:109`，可用 `go doc -src bytes.Buffer.Truncate` 查看。 #link("https://pkg.go.dev/bytes#Buffer.Truncate")[Go 标准库 · Buffer.Truncate]

=== Go 语言机制补充

`(ent *Entry)` 是指针接收者，表示方法操作的是 `ent` 指向的记录。`nil` 指针可以作为接收者进入方法，但若方法通过它读取 `ent.key` 这样的字段，就会触发 `panic`。`key` 和 `val` 的首字母小写，因此其他包不能直接访问它们。同一个 Go 包中的其他代码仍能赋值。把普通调用说明放在方法注释，用 `go doc` 阅读。 #link("https://go.dev/ref/spec#Exported_identifiers")[Go 语言规范 · Exported identifiers] · #link("https://go.dev/ref/spec#Selectors")[Go 语言规范 · Selectors]

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "fmt"
  )

  func main() {
      var buffer bytes.Buffer
      var absent *bytes.Buffer
      fmt.Println(buffer.Len(), absent == nil)

      buffer.WriteString("abc")
      fmt.Println(buffer.Len())
      buffer.Truncate(2)
      fmt.Println(buffer.Len())
  }
  ```).text,
  lang: "go",
  caption: [保存为 `requires_demo.go` 后运行 `go run requires_demo.go` 与 `go vet requires_demo.go`],
)

输出依次为 `0 true`、`3`、`2`。空缓冲区这个对象可以查询长度。`absent` 是没有指向缓冲区的指针。

=== 本次操作与当前状态

核对了 `internal/db/kv_entry.go` 中当前草稿、`TestEntryEncode`、MIT 6.102 R07 和 Go 标准库文档。独立 Go 示例运行与 `go vet` 均通过。运行 `go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/`，`Encode` 和 `Decode` 仍因 `missing function body` 停在编译阶段，未进入断言。本次追加回答并重新编译日记 PDF。Q2.2 由本人填 `Effects`，`Requires` 可省略或标为无额外前置条件。

// 轨道：CS 轨
== 0102 Encode 的规格评测与注释整理

=== 费曼直觉

#importantbox[你写的四段边界和总长度 `8 + K + V` 正确。要让调用者只看注释就能独立写出预期字节，还需要明确 `K`、`V` 是键和值的实际字节数，并规定两个长度字段使用 4 字节小端无符号整数。]

=== 硬核机制

#booktabs-table(
  columns: (1.1fr, 1.5fr, 2.55fr),
  [6.102 判据], [评测], [修改与依据],
  [前置条件], [规格没有为这个操作另加条件。], [省略 `Requires: nothing`，与 R05 的无额外前置条件写法一致。],
  [可预测的结果], [四段位置正确。两行的 `max length` 容易把实际长度和长度上限混在一起，第二行对应值。], [`TestEntryEncode` 固定头部为 `02 00 00 00 03 00 00 00`，与 0102 讲义的小端 `uint32` 一致。现把 `K`、`V` 的单位、各段内容和左闭右开范围写清。],
  [承诺强度], [新副本是更强的返回值承诺。], [样例只比较字节内容。把新副本作为待确认的设计，和接收者状态、支持的尺寸一起列在 `TODO(阶段末)`。],
)

6.102 R04（T05）把返回值与调用后可见的变化纳入后置条件。R05（T06）优先写声明式规格，即先描述结果该是什么，把得到结果的步骤留给实现。这里的四段布局直接关系到测试看到的返回字节，属于规格。 #link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[R04 · Specification structure] · #link("https://web.mit.edu/6.102/www/sp26/classes/05-designing-specs/#declarative_vs_operational_specs")[R05 · Declarative vs. operational specs]

=== 陷阱与易错

#warningbox[通过字节相等断言的两个返回值，可以有不同的共享行为。若之后把「新副本」升级为契约，需要有会改变返回值并检查记录或另一次结果的用例，才能检验相应的独立性。]

=== 关键点

注释以 `Encode returns` 起句，统一用英文。用一份缩进布局说明替代重复的两张表，`go doc` 会将布局按代码块呈现。`Paramater` 小节已经折入阶段末说明，因为它描述的是返回值。运行 `go doc ./internal/db.Entry.Encode` 可预览。 #link("https://go.dev/doc/comment#code_blocks")[Go Doc Comments · Code Blocks]

=== 变式检验

如果测试只做编码后再解码，两个方法一起采用相同的另一种端序也可能通过。当前样例另外把 `Encode` 和固定字节比较，因此单独检验了输出格式。0102 本地测试也与同一步上游测试匹配。讲义示例混入的下一步删除标志在本步布局中没有对应字段，以本步测试为准。

=== 同类归类

例如发送程序要暂存一段消息，发送前允许修改缓冲区，同时保留一个独立副本供日志使用。若把共享视图交给日志，发送前的修改会顺带改掉日志要保留的内容。Go 标准库在这两种设计中明确写出返回值的关系。`bytes.Buffer.Bytes` 通过 `return b.buf[b.off:]` 返回共享视图，文档规定修改会影响缓冲区及视图何时有效。`bytes.Clone` 明确承诺复制输入。`Entry.Encode` 也需要决定是否承诺独立性，0102 当前只检验字节内容。两处可用 `go doc -src bytes.Buffer.Bytes`、`go doc -src bytes.Clone` 核对，源码分别在 `/usr/lib/go/src/bytes/buffer.go:60` 与 `/usr/lib/go/src/bytes/bytes.go:1391`。 #link("https://pkg.go.dev/bytes#Buffer.Bytes")[Go 标准库 · Buffer.Bytes] · #link("https://pkg.go.dev/bytes#Clone")[Go 标准库 · Clone]

=== Go 语言机制补充

`uint32` 是固定 32 位的无符号整数。小端是编码格式的约定，低位字节先放，所以长度 `3` 的 4 字节表示为 `03 00 00 00`。这条顺序由规格选择，字段宽度本身无法推出端序。可查 `go doc -u -src encoding/binary.littleEndian.PutUint32` 和 `/usr/lib/go/src/encoding/binary/binary.go:96`。返回 `[]byte` 只确定结果类型，是否与现有存储共享由契约约定。

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "encoding/binary"
      "fmt"
  )

  func main() {
      buffer := bytes.NewBufferString("cat")
      view := buffer.Bytes()
      snapshot := bytes.Clone(view)
      view[0] = 'b'
      fmt.Println(buffer.String(), string(snapshot))

      var size [4]byte
      binary.LittleEndian.PutUint32(size[:], uint32(len(view)))
      fmt.Println(size)
  }
  ```).text,
  lang: "go",
  caption: [保存为 `encode_spec_demo.go`，运行 `go run encode_spec_demo.go` 与 `go vet encode_spec_demo.go`],
)

运行结果依次为 `bat cat` 和 `[3 0 0 0]`。前者让共享与复制的区别可见，后者展示长度字段的端序。

=== 本次操作与当前状态

只编辑了 `internal/db/kv_entry.go` 的 `Encode` 文档注释，并将评测追加到当天的 Typst 笔记。`go doc ./internal/db.Entry.Encode` 展示了新布局，`gofmt -l internal/db/kv_entry.go` 无输出，`git diff --check -- internal/db/kv_entry.go` 通过。Go 示例的 `go run` 和 `go vet` 通过。`go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/` 因两个方法仍缺少函数体而编译失败，断言尚未执行。当天笔记经机械自检后重新编译同级 PDF。Q2.2 的格式已经整理，按练习顺序继续填写后续规格和测试策略即可。

// 轨道：CS 轨
= db-go 的规格注释统一模板

== 费曼直觉

#importantbox[函数和方法按首句、`Parameters:`、`Requires:`、`Effects:` 的顺序写。后置条件的英文是 `postcondition`，项目统一使用 `Effects:` 作为标签。一个分支的返回值、错误和可观察的状态变化写在同一项，可以用分句或另起句。]

这套标签和简写是 db-go 的约定。6.102 R04（T05）定义前置条件和后置条件，TypeDoc 使用 `@param` 与 `@returns`。6.031 R06 的 Java 文档使用 `@param` 与 `@return`。Go 用声明正上方的文档注释、自然段与列表表达同样的契约。本项目采用英文标签和正文，不套用 TypeDoc 或 Javadoc 的标签格式。 #link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[6.102 R04 · Specification structure] · #link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specifications_in_typescript")[R04 · Specifications in TypeScript] · #link("https://web.mit.edu/6.031/www/sp21/classes/06-specifications/#specifications_in_java")[6.031 R06 · Specifications in Java] · #link("https://go.dev/doc/comment")[Go Doc Comments]

== 硬核机制

#booktabs-table(
  columns: (1.05fr, 2.45fr, 1.65fr),
  [顺序], [写什么], [何时省略],
  [首句], [用声明里的名称开头，说明调用者能用它完成什么。], [保留。],
  [`Parameters:`], [按签名顺序用 `- name is ...` 描述参数语义、单位或坐标。], [签名和首句已经说清时省略。],
  [`Requires:`], [调用者必须保证的额外条件，例如合法范围和初始状态。], [没有额外条件时省略。],
  [`Effects:`], [按分支写返回值、错误或约定的 `panic`，以及可观察状态的变化。], [一句能完整描述、前两段都可省时，首句可承担这一段。],
  [`TODO(阶段末):`], [当前测试和材料尚未确定的承诺。], [已确定时省略。],
)

完整模板在 `docs/go-construction-templates.md` 中，可以直接复制。使用 `//` 空注释行分段，列表项写 `//   -`，注释贴在声明正上方。`Returns` 可以用作句子里的动词。返回值、错误和相关变化属于同一个 Effects 分支，因此无需另立 `Returns:`、`Postcondition:` 或 `Panics:`。 #link("https://go.dev/doc/comment#syntax")[Go Doc Comments · Syntax]

== 陷阱与易错

#warningbox[`Parameters:` 解释参数是什么，`Requires:` 才写调用者必须保证什么。若函数承诺对 `n <= 0` 返回错误，`n <= 0` 就是一条 `Effects:` 分支。若调用者须保证 `n > 0`，这条是 `Requires:`，契约测试应使用满足它的调用。]

== 关键点

ADT 的类型注释写一个值代表什么，按需说明零值、初始化、是否可变及一组方法共用的调用条件。在表示字段附近固定写 `AF:`、`RI:` 与 `Safety from rep exposure:`。AF 将合法字段值映到抽象含义。RI 是可对字段判真的约束。暴露论证说明可变数据从输入、输出和直接访问三条路径是否共享，以及什么能防止绕开 ADT 改动它。共享规则若影响调用者，同时写在操作契约中。`checkRep` 是检查 RI 的代码。接口列出方法及抽象契约，各具体实现的表示说明靠近自己的字段。 #link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#documenting_the_af_ri_and_safety_from_rep_exposure")[6.102 R07 · AF、RI 和表示暴露安全]

测试策略写在 `TestXxx` 上方，采用 `Testing strategy for ...:`、`Domain:`、`Partition on ...:`，按需补 `Boundaries:`、`Coverage:` 和 `TODO(阶段末):`。用例按准备、执行、断言选输入并独立写出期望。规格和测试都以本步证据为界。 #link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[6.102 R02 · Documenting your testing strategy]

== 变式检验

发料台的申请必须一次满足，因为调用者可能在失败后重试。若有 2 件，却在申请 3 件时先扣再拒绝，库存就可能为负。范例把成功的布尔值和扣减放在同一项，把失败的布尔值和库存保持原样放在另一项。`Remaining` 的一条首句就能完整表达行为。迁回 db-go，按相同方法为每个已约定的分支同时写结果和影响。数据库的字节格式、错误和失败后状态仍由该操作自己的证据决定。

#codelisting(
  (```go
  // Take handles an all-or-nothing withdrawal request.
  //
  // Parameters:
  //   - n is the requested number of units.
  //
  // Requires:
  //   - n > 0.
  //
  // Effects:
  //   - If at least n units are available, returns true and reduces stock by n.
  //   - Otherwise, returns false and leaves the stock unchanged.
  ```).text,
  lang: "go",
  caption: [完整的实现和测试在 `examples/construction/stock.go` 与 `stock_test.go`],
)

== 同类归类

Go 的 `bytes.Buffer.Next` 适合读走至多某个数量的现有字节，关键代码用 `b.off += n` 推进读取位置。`io.ReadFull` 适合一定要读足的固定长度字段，关键代码是 `return ReadAtLeast(r, buf, len(buf))`。部分读取后遇到文件末尾会同时返回已读数量和 `io.ErrUnexpectedEOF`，目标缓冲区已有这部分数据。它说明为什么错误、返回值和状态应该写在同一分支。可查 `go doc -src bytes.Buffer.Next`、`go doc -src io.ReadFull` 与 `/usr/lib/go/src/bytes/buffer.go:358`、`/usr/lib/go/src/io/io.go:353`。 #link("https://pkg.go.dev/bytes#Buffer.Next")[Go 标准库 · Buffer.Next] · #link("https://pkg.go.dev/io#ReadFull")[Go 标准库 · ReadFull]

== Go 语言机制补充

Go 的函数声明有名称和签名，签名给出参数及结果类型，编译器会检查这些类型。像 `n > 0` 或库存不足时保持原状，需要注释描述，由实现遵守并由测试核对。零值是未显式赋初值时 Go 为变量提供的值，发料台的零值在测试中代表空库存。接收者是方法所作用的对象，`(s *Stock)` 让 `Take` 能修改同一个发料台对象。可在根目录运行 `go doc ./examples/construction.Stock.Take` 查看完整注释，运行 `go test -count=1 -v ./examples/construction` 检查各分支。

== 本次操作与当前状态

更新 `docs/go-construction-templates.md`，新增 `AGENTS.md` 的规范入口，并统一 `examples/construction/stock.go` 和 `stock_test.go` 的示例注释。今后新写与评测使用这份模板。完整示例测试、恰好满足的定点用例、`go vet ./examples/construction`、`go doc`、`gofmt -l` 和所改文件的链接与空白检查均通过。全仓库 `git diff --check` 报告既有的 `note/2026-11-13.pdf`；针对本轮文本重新检查后通过。0102 定点测试仍因 `Encode`、`Decode` 缺少函数体在编译阶段失败。当天笔记完成机械自检和 PDF 编译。
