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
= 0102 重出题：从固定字节写出 Decode 规格

== 费曼直觉

键和值的长度可以变化。把长度写在数据前面，读取方才能算出一段从哪里结束、下一段从哪里开始。把两个方法交给两个人写，就能看出这一步的风险：他们可能一起采用同一个错误格式，同时还可以互相读回数据。固定字节提供了一份双方都要遵守的参照。

#importantbox[继续使用原来的 Q1 到 Q5。Q1 快速核对格式，Q2 从仍有空位的 `Decode` 成功规格做起。先说明一条断言能观察到什么，再写两个方法的函数体。]

== 硬核机制

题目骨架按 Q1 → Q2 → Q3 → Q4 → Q5 的顺序完成。每题括号里指明交付位置。项目的规格标签和测试策略写法见 `docs/go-construction-templates.md`。

#booktabs-table(
  columns: (0.68fr, 1.23fr, 3.32fr),
  align: left,
  [*题号*], [*落点*], [*要交的判断或结果*],
  [Q1 阅读], [测试上方的 `Evidence`], [用固定样例画一行字节下标，标出四段范围和首个键字节。写出小端的依据，解释讲义样例多出来的那个字节适用哪一步。],
  [Q2 规格], [`kv_entry.go` 的 `Decode` 注释], [保留已写过的 `Encode` 布局。补 `Decode` 的成功 `Effects`，同时写明返回值和调用者可观察到的记录内容。`Entry{}` 在测试里出现，单凭这条调用，能把「接收者事先为空」写进 `Requires` 吗？说明理由。],
  [Q3 测试], [测试上方的 `Domain`、`Coverage` 和 Q3.2], [按准备、调用、断言拆解已有样例。逐行指出固定编码、错误返回、解码结果的断言分别观察什么，标明两处字节的来源。选一个已有样例确实命中的输入类别，并给出一条尚无覆盖的维度。],
  [Q4 实现], [两个方法的函数体], [先写两句判断：`Encode` 凭什么确定键和值的边界，`Decode` 凭什么判断当前一段已具备解释所需的字节。再自行完成方法。],
  [Q5 验证], [交卷中的命令结果], [先确认 `TestEntryEncode` 出现 `RUN` 和 `PASS`，再跑同包测试。记录首个失败的位置或最后的通过结果。交卷后按这五题评测、落盘和更新 0102 进度。],
)

课程主线用 T05（6.102 sp26 R04，Specification structure），把调用者承担的条件和函数完成时的保证分别落在 `Requires` 和 `Effects`。T02（6.102 sp26 R02，Documenting your testing strategy）要求写出如何划分输入以及样例覆盖了哪一类。6.031 sp21 R03 的 Using multiple partitions 补充了独立维度的选例方法。#link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[6.102 R04] · #link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[6.102 R02] · #link("https://web.mit.edu/6.031/www/sp21/classes/03-testing/#using_multiple_partitions")[6.031 R03]

== 陷阱与易错

#warningbox[本地 `TestEntryEncode` 和 0102 starter 的同名测试逐行一致。讲义数组多出的删除标志属于 0103。空键值的外部格式承诺、结果是否独立、截断后接收者的状态和尾随字节的行为，都由后续证据决定，当前作阶段末待定记录。]

== 关键点

`Requires` 写调用者额外要满足的条件。`Effects` 写返回值和调用后的可见变化。Q2 先研究「一条完整、符合格式的记录」，再说明你有什么依据为所有调用增加条件。Q3 的断言指测试中比较实际与期望的检查。一条用例可以命中多个输入类别，同时给出编码和解码的观察。Q3.2 只需填写现有样例的准备、调用与断言。

== 变式检验

假设两端都改用大端。分别预测两种检查会怎样。一种保留现有三处断言。另一种仅把本次 `Encode` 的结果送给配套的 `Decode`，再比较最终记录。逐项解释预期从哪里来。若担心错误长度导致读取很多数据，纸上推演即可。

另一题只用于理解读取接口。假设给读取函数 8 字节的空间，第一次拿到 3 字节并返回 `nil`。此时有几个字节可以使用，足够解释哪个完整的长度字段，还需要什么信息才能继续？随后对照下面的独立例子。

== 同类归类

设想维护一个跨程序使用的二进制协议。用同一种错误端序写完再读回来，测试可能放过兼容性故障。Go 标准库 `encoding/binary` 的 `TestLittleEndianWrite`、`TestLittleEndianRead` 将同一固定字节样例传给两个方向的测试。写入侧比较的是 `checkResult(t, enc.name, order, err, buf, b)`。迁回 0102，对照固定的 `data` 在两处的用途。出处为 `/usr/lib/go/src/encoding/binary/binary_test.go:187` 到 211。

再设想从传感器收到一串十六进制字符，串尾可能出现无效字符。调用者需要明确前半段已经读出的数据是否保留，否则可能误丢已取得的字节。Go 标准库 `encoding/hex` 的 `TestDecodeErr` 用 `string(out[:n]) != tt.out || err != tt.err` 同时比对部分输出与错误。它的失败行为有具体输入和对应期望。0102 的固定样例检验成功，截断时的状态留待阶段末核对。出处为 `/usr/lib/go/src/encoding/hex/hex_test.go:108`。

== Go 语言机制补充

`uint32` 指能表示 32 位非负整数的 Go 类型。格式选择固定宽度，读取方就能预先确定两个长度各占多少字节。小端是格式约定，低位字节放在前面。可用 `go doc encoding/binary.LittleEndian` 和已有 `Encode` 规格一起核对。

`io.Reader` 是 Go 的读取接口。接口用一组方法规定一种能力，接收 `io.Reader` 的代码可通过 `Read` 从不同来源取字节。参数 `[]byte` 是字节切片，提供一段可写空间。返回的 `n` 表示这次实际读出的字节数，`err` 是错误值，`nil` 表示该次调用没有报告错误。平常写代码时用 `n` 判断哪些字节已经到手。可查 `go doc io.Reader` 和 `/usr/lib/go/src/io/io.go:86`。

例如设备的消息以四字节标记开头，输入来自可能分批送达的连接。接收方必须等足够的字节，才能判断标记是什么。如果把接收空间的长度当作已读长度，尚未到达的位置会被当成标记的一部分。下面用内存中的四个字符模拟每次只送来一个字节。同样的接口现象适用于 `Entry.Decode`，设备标记和 0102 的长度字段有各自的格式。

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "fmt"
      "io"
      "testing/iotest"
  )

  func main() {
      var r io.Reader = iotest.OneByteReader(
          bytes.NewBufferString("ABCD"),
      )
      var header [4]byte
      n, err := r.Read(header[:])
      fmt.Printf("n=%d err=%v data=%q\n", n, err, header[:n])
  }
  ```).text,
  lang: "go",
  caption: [用内存模拟按字节到达的设备消息],
)

保存示例为 `main.go` 后可用 `go run main.go` 与 `go vet main.go` 验证。示例输出为 `n=1 err=<nil> data="A"`。`go doc testing/iotest.OneByteReader` 说明包装后每次非空读取只向底层请求一个字节。对照本地源码 `/usr/lib/go/src/testing/iotest/reader.go:17`。

== 本次操作与当前状态

对照了 0102 讲义、本地测试及 starter、原版练习、最新规格和 MIT 原文。重出题仅归档到本日笔记，保留已有的源码作答。定点命令在 `kv_entry.go:44` 和 `:58` 报 `missing function body`，断言尚未执行。按此顺序重新作答，完成后使用以下命令验收。

#codelisting(
  (```bash
  go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/
  go test ./internal/db/
  go build ./...
  go vet ./...
  go test ./...
  ```).text,
  lang: "bash",
  caption: [0102 定点、同包和全仓验收],
)

`go doc ./internal/db.Entry.Decode` 可以读取当前规格。Go 标准库的相关用例通过，独立示例也通过运行与检查。本日 Typst 完成机械自检并编译为同级 PDF。0102 仍在准备规格与测试策略的阶段。当前按磁盘测试给出题目骨架。正式题单沿用项目的测试提交约定，下次贴出 `TestEntryEncode` 的函数体即可确认本步证据。

== 第二轮正式题单：0102 的 Decode 契约与读满判断

#importantbox[上一轮 Q1–Q5 不再使用。按 A1 → A2 → A3 → B1 → B2 → C1 作答。工作树里的 `TestEntryEncode` 已与 0102 starter 核对为同一份 13 字节样例，所以本轮直接给正式题单，不再要求先贴测试。A 组交规格和测试注释，B 组交判断与设计说明，C 组交实现和命令结果。]

=== 完成顺序与交付

A1 只读材料，五分钟内应能完成。A2 是本步核心：先把 `Decode` 的成功效果写成别人能据以写出期望的句子，再做 A3。B1、B2 不要求新增仓库测试，只交预测、理由和一条 `TODO(阶段末)`；它们用来防止实现把 `io.Reader` 的短读或失败状态误当成已测事实。C1 最后写函数体。A 组没有完成前不要开始 C1。

#booktabs-table(
  columns: (0.48fr, 1.1fr, 1.8fr, 2.12fr),
  align: left,
  [*题*], [*落点*], [*要交什么*], [*核对依据*],
  [A1], [`TestEntryEncode` 上方 `Evidence`], [用 `data` 的 13 个下标写出四段 `[start, end)`、每段内容、首个键字节下标；说明讲义示例为什么多一个 `0`。], [`kv_entry_test.go:47` 的 13 字节；讲义 `ch01-storage-basics.md:157-161` 的 14 字节。],
  [A2], [`kv_entry.go:46-58` 的 `Decode` 注释], [补 `Requires` 与成功 `Effects`；回答测试里的 `Entry{}` 能否推出「调用前必须先清空」。], [`TestEntryEncode` 只给出一条初始状态；`go doc ./internal/db.Entry.Decode` 能读回注释。],
  [A3], [`kv_entry_test.go:10-44` 的策略与 AAA], [填 `Domain`、至少两个分区、`Coverage`；把 `:49`、`:53`、`:54` 三条断言各自对应到 Effects；指出哪条能抓「编码和解码一起换端序」。], [当前只有一条成功样例；未覆盖的维度写 `TODO(阶段末)`。],
  [B1], [不写仓库测试], [用 `iotest.OneByteReader` 预测：只调用一次 `r.Read(header[:])` 会看到什么？`Decode` 应依赖 `Read` 还是 `io.ReadFull` 的契约？], [`go doc io.Reader`、`go doc -src io.ReadFull`、`go doc testing/iotest.OneByteReader`。],
  [B2], [`Decode` 注释末尾的 `TODO(阶段末)`], [头部写 K=4、V=2，输入只给 2 个键字节：返回什么？`ent` 允许是什么状态？选一条政策，并说明如何用「局部变量读完再赋值」避免无意承诺部分写入。], [当前测试没有截断样例；只写设计判断，不把政策冒充成已测事实。],
  [B3 可选], [`Decode` 的长度检查], [`K=0xFFFFFFFF` 时，`8+K+V` 是否总能放进 `int`？分配前应拒绝什么？], [只作阶段末推演，不计入本轮通过条件。],
  [C1], [`Encode` 与 `Decode` 的函数体], [按 A2 实现；长度头用小端 `uint32`，读取用 `io.ReadFull`；报告 `RUN`/`PASS`、同包测试和首个失败位置。], [定点测试、同包回归和全仓命令见本节末尾。],
)

=== 判定要点

#importantbox[A2 的合格答案要同时说清两件事：测试接受 `Entry{}`，只证明零值是一条合法初始状态；它不能证明所有调用者都必须先清空。成功 `Effects` 要写调用结束后的最终记录，不要把「先读 8 字节头部」这类实现步骤写进契约。]

#warningbox[讲义 0102 的示例在 key 前多一个 `0`，那是 0103 的删除标志，所以示例有 14 字节。本项目 0102 的测试只有 13 字节，首键字节在下标 8。照 14 字节布局写，`TestEntryEncode` 会在 `:49` 的固定字节比较处失败。]

A3 要区分「测试保护了什么」和「测试没有保护什么」。固定字节比较是一条独立于实现的证据；只做 `Encode` 后接 `Decode` 的往返比较，可能让两端一起采用同一个错误端序而仍然通过。反过来，当前只有一条非空键值样例，不能据此声称空键、空值、截断或所有权已经有完整契约。

B1 和 B2 是设计推演，不是新增验收。`io.Reader` 的 `Read` 允许返回 `n < len(p)` 且 `err == nil`；`bytes.Buffer` 在当前小样例上通常一次读满，所以现有测试不能暴露只调用一次 `Read` 的实现。B2 若选择「失败时接收者保持不变」，这是比当前测试更强的承诺，必须写进规格，并留待将来用例检验；若不选择这条，也要明确失败后状态未规定，而不是让实现随手留下半条记录。

=== Go 语言机制补充

`io.Reader` 是接口：任何类型只要有 `Read(p []byte) (n int, err error)`，就能作为读取源。`bytes.NewReader` 把内存字节包装成 `io.Reader`，`testing/iotest.OneByteReader` 再把每次非空 `Read` 限制为一个字节。`Read` 的文档只说「最多读 `len(p)` 字节」，所以 `n < len(p)` 且 `err == nil` 是合法的；`io.ReadFull` 才承诺填满缓冲区，不足时返回 `io.EOF` 或 `io.ErrUnexpectedEOF`。`uint32` 是固定 32 位无符号整数；小端把低位字节放在前面，所以长度 2 编码为 `02 00 00 00`。端序是格式约定，不能由字段宽度推出。`int` 是机器字长整数；在 32 位目标上上限是 `2^31-1`，所以 `uint32` 的长度字段并不自动等于可分配的切片长度。

可用 `go doc io.Reader`、`go doc -src io.ReadFull`、`go doc testing/iotest.OneByteReader` 和 `go doc encoding/binary.LittleEndian` 核对。下面的最小程序只演示接口和端序，不替代 B1 的预测。

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "encoding/binary"
      "fmt"
      "io"
      "testing/iotest"
  )

  func main() {
      var header [4]byte
      n, err := io.ReadFull(bytes.NewReader([]byte("ABCD")), header[:])
      fmt.Printf("ReadFull: n=%d err=%v data=%q\n", n, err, header[:])

      one := iotest.OneByteReader(bytes.NewReader([]byte("ABCD")))
      copied, copyErr := io.Copy(io.Discard, one)
      fmt.Printf("OneByteReader+Copy: n=%d err=%v\n", copied, copyErr)

      var length [4]byte
      binary.LittleEndian.PutUint32(length[:], 2)
      fmt.Printf("little-endian: % x\n", length)
  }
  ```).text,
  lang: "go",
  caption: [保存为 `readfull.go` 后运行 `go run readfull.go`],
)

预期输出为三行：`ReadFull: n=4 err=<nil> data="ABCD"`、`OneByteReader+Copy: n=4 err=<nil>`、`little-endian: 02 00 00 00`。`OneByteReader` 每次只交付一个字节，但 `io.Copy` 会反复读取直到结束；这正是 B1 要你区分「一次 Read」和「读满一段」的原因。

=== 交卷格式

按 A1、A2、A3、B1、B2、C1 分节回答。A2 直接贴可放进 `kv_entry.go` 的英文注释，A3 贴测试上方的策略注释，C1 贴实现后的命令输出。不要改 `TestEntryEncode` 已有的三条断言；如果认为需要新增测试，先写成阶段末设计，不直接改仓库测试。

#codelisting(
  (```bash
  go doc ./internal/db.Entry.Decode
  go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/
  go test ./internal/db/
  go build ./...
  go vet ./...
  go test ./...
  ```).text,
  lang: "bash",
  caption: [0102 的注释核对、定点测试、同包回归和全仓验收],
)

=== 本次操作与当前状态

重新核对了 0102 讲义、starter、当前 `TestEntryEncode`、`kv_entry.go` 的规格草稿和 `docs/go-construction-templates.md`。当前定点命令在 `kv_entry.go:44` 与 `:58` 报 `missing function body`，测试断言尚未执行；`go doc ./internal/db.Entry.Decode` 读到的是待填的 `Requires` 和 `Effects`。临时 Go 程序验证了 `iotest.OneByteReader` 配合一次 `Read` 返回 `n=1`、`io.ReadFull` 返回 `n=4`，仅用于核对机制，没有写入仓库测试。

本轮只重出题并追加本笔记，没有改动实现、测试或进度。下一步按 A1 → A2 → A3 → B1 → B2 → C1 作答；交卷后逐题评测。本日 Typst 已完成机械自检并编译同级 PDF。

// 编译记录：机械自检后运行 `XDG_CACHE_HOME=/home/zz/.cache typst compile 2026-11-20.typ`，零错误，生成同目录 PDF。

== 现在从 A1 的 Evidence 开始

#importantbox[这一轮先交 A1 的一条 `Evidence (Q1)`。打开 `internal/db/kv_entry_test.go:47`，从下标 0 给 `data` 的每个字节编号。按键长度、值长度、键、值的顺序，写出四段范围、第一枚键字节的下标，以及长度字段的端序依据。把结果填到同文件第 12 行。]

第一个长度字段可以先标成 `[0, 4)`，包含下标 0 到 3。参考写法是「键长度 `[0, 4)`，值长度（填写），键（填写），值（填写）。首个键字节在（填写），端序依据是（填写）」。再用一句话说明讲义里键前多出的 `0` 属于哪一步。端序是多字节整数的字节排列约定。0102 用小端，最低位字节排在前面，依据在 `../db-web/docs/ch01-storage-basics.md:153`，可用 `go doc encoding/binary.LittleEndian` 核对 Go 的对应工具。

#warningbox[四段范围以本项目的固定 `data` 为准。对照讲义时，单独标出额外字节属于哪个步骤。]

=== 本次操作与当前状态

核对了 `data`、`Evidence (Q1)` 的位置、讲义的格式说明以及 `go doc encoding/binary.LittleEndian`。本轮追加日记，按项目脚本做机械自检并编译同级 PDF。当前在 A1 阅读材料，尚未进入规格或实现验收。上一轮笔记把从磁盘查看测试算作正式解锁，这里更正为 A1 预习。提交 `Evidence` 时一并贴出 `TestEntryEncode` 函数体，即可按项目约定继续正式题单，从 A2 的 `Decode` 成功效果入手。

== 0102 题单同步到源码

核对发现前两轮只更新了笔记，`kv_entry.go` 里还留着旧的 Q2.3 和 Q4 提示。现在用独立的 `TODO(learning)` 注释写入新版题目。A1 和 A3 指向测试文件里的作答位置，A2、B1、B2 与可选的 B3 放在 `Decode` 规格前，C1 放在两条方法声明之后。

#importantbox[从 `internal/db/kv_entry.go:32` 的 A1 开始读题，把答案填到 `internal/db/kv_entry_test.go:12` 的 `Evidence (Q1)`。]

#warningbox[`go doc` 展示紧邻方法声明的规格。练习提示用空行隔开，可以直接在源码里查看。]

=== 本次操作与当前状态

更新了 `internal/db/kv_entry.go` 的题目注释。校验和核对确认非注释代码和测试文件均保持原样。`gofmt -l internal/db/kv_entry.go` 无输出，`git diff --check` 通过，`go doc ./internal/db.Entry.Decode` 正常显示待填的规格。定点测试在 `kv_entry.go:53` 和 `kv_entry.go:77` 报 `missing function body`，断言尚未执行。当天笔记已机械自检并编译为同级 PDF。

== 0102 源码填空版

这版接替此前题单。源码里的标题、标签、缩进和句式已写好。把整段 `TODO(user: 提示)` 替换成自己的短答案，再按题号继续。 `TODO(learning)` 用来读题，`TODO(阶段末)` 记录将来要确认的行为。

#importantbox[先打开 `internal/db/kv_entry_test.go:13`。第一段键长度已写好，用它的格式填第一处空白 `Value length`。把 `data` 的下标从 0 数起，区间包含起点、排除终点。]

#booktabs-table(
  columns: (0.65fr, 1.45fr, 2.7fr),
  [顺序], [填写位置], [交付内容],
  [A1 读格式], [`internal/db/kv_entry_test.go:13`], [填值长度、键和值的下标范围，再填端序及依据、讲义多出字节的用途和所属步骤。],
  [A2 写规格], [`internal/db/kv_entry.go:15` 与 `internal/db/kv_entry.go:53`], [A2a 填谁能直接访问字段。A2b 判断测试是否支持「接收者必须为空」，再填 `Decode` 的成功条件、返回值和记录的最终键值。既有 `Encode` 布局已整理成 `Effects`。],
  [A3 读断言], [`internal/db/kv_entry_test.go:24`], [准备和调用已写好。填解码前的初始状态，以及三条断言各自期望的字节、错误值和最终记录。],
  [A4 写实现与验证], [`internal/db/kv_entry.go:34` 与 `internal/db/kv_entry.go:57`], [依照 A2 的规格完成两个函数体。先确认定点测试出现 `RUN` 和 `PASS`，再做同包和项目级验证。],
)

标准库的 `encoding/binary` 也会用固定字节分别检查读取与写入，详见本节前面的真实样本。A3 用相同的观察方法记录当前测试。 `Arrange` 是准备输入和预期，`Act` 是调用方法，`Assert` 是核对结果。这个样例只有一组输入，模板直接记录它的覆盖范围。

#warningbox[四段边界以当前测试固定的 `data` 为准。空字段、截断后状态和数据是否共享等政策留给 `TODO(阶段末)`。]

完成 A1 后，提交你的填空与 `TestEntryEncode` 函数体，按项目约定确认本步测试并继续 A2。实现写好后，在项目根目录运行以下命令。

#codelisting(
  ( ```bash
  go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/
  go test ./internal/db/
  go build ./...
  go vet ./...
  go test ./...
  ``` ).text,
  lang: "bash",
  caption: [0102 实现后的验证命令],
)

=== 本次操作与当前状态

重写了 `kv_entry.go` 和 `kv_entry_test.go` 的注释骨架，保留已有表示说明和编码契约的含义。核对非注释行与修改前一致，`TestEntryEncode` 函数也与上游 0102 starter 的同名函数完全一致。`gofmt -l` 无输出，`git diff --check` 通过，`go doc` 正常显示两条方法规格。定点测试在两处方法声明报 `missing function body`，断言尚未执行。日记完成机械自检并编译同级 PDF。进度仍在 A1。

== A2a 的提示：字段访问和字节共享

=== 费曼直觉与硬核机制

表示（representation）是对象内部用来保存数据的字段及其存储。表示暴露（rep exposure）指调用者获得一条通往内部数据的访问路径，尤其值得留意的是能通过该路径修改内部数据的情况。

#importantbox[`Access` 问 Go 编译器让哪些代码直接引用字段。共享存储问调用者手里的字节和记录内部的字节，是否是对同一块内存的两个视图。]

#booktabs-table(
  columns: (0.8fr, 1.65fr, 2.2fr),
  [注释落点], [问什么], [如何自己检查],
  [`Access`], [哪一处代码可以直接写出「对象.字段名」并被编译器接受？], [先想调用方写在 `package db` 里，再想调用方写在另一个有权导入它的包里。分别对照 Go 的包外可见性规则。],
  [共享存储 · `Encode`], [调用者拿到结果后改一个字节，记录内部是否会跟着变？], [追踪返回值中的字节存在哪里。],
  [共享存储 · `Decode`], [若调用者保留了原始输入字节，解码结束后再改其中一个字节，已解码的记录是否会跟着变？], [追踪记录最终保存的字节存在哪里。],
)

=== 陷阱与关键点

#warningbox[能否写出字段名在编译时就会检查。能否通过一个方法返回的字节改到内部数据，要看该方法的契约和实际存储关系。A2a 只填写 `Access`。共享政策在当前测试里缺少验证，留作 `TODO(阶段末)`。]

=== 变式与同类归类

想象发送程序用缓冲区准备一条消息，日志要保留发送前的文本。如果日志也持有同一块字节，发送前的修改会改掉它看到的文本。Go 标准库提供两种做法。`bytes.Buffer.Bytes` 返回缓冲区本身的一个视图，源码是 `return b.buf[b.off:]`，文档规定该视图何时有效。 `bytes.Clone` 承诺交出副本，其源码通过 `return append([]byte{}, b...)` 复制非空输入。映射到 0102，可以用同样的「改一个字节」问题检查存储关系，具体政策由项目后续确定。核对入口是 `go doc -src bytes.Buffer.Bytes` 和 `go doc -src bytes.Clone`，本机位置为 `/usr/lib/go/src/bytes/buffer.go:60` 和 `/usr/lib/go/src/bytes/bytes.go:1391`。

=== Go 语言机制补充

字段是结构体内有名字的数据项。`go doc -src bytes.Buffer` 会列出该类型的内部字段和操作。包外代码能使用哪些名字，由 Go 语言规范的 Exported identifiers 一节规定，本机在 `/usr/lib/go/doc/go_spec.html:2304`。字节切片 `[]byte` 可以访问一段底层字节。在下面的发送程序里，`view` 和缓冲区指向同一片字节，`snapshot` 保存独立的副本。

#codelisting(
  ( ```go
  package main

  import (
      "bytes"
      "fmt"
  )

  func main() {
      buffer := bytes.NewBufferString("cat")
      view := buffer.Bytes()
      snapshot := bytes.Clone(view)
      view[0] = 'b'
      fmt.Println(buffer.String(), string(snapshot))
  }
  ``` ).text,
  lang: "go",
  caption: [保存为 `main.go` 后运行 `go run main.go` 与 `go vet main.go`],
)

输出为 `bat cat`。通过 `view` 改字节影响缓冲区，日志副本继续保留原消息。

=== 本次操作与当前状态

核对了 A2a 源码、Go 规范和标准库实现。临时示例的 `go run main.go` 与 `go vet main.go` 均通过。项目源码与测试保留原样。本轮只记录解释，不代填作业，下一步由本人比较两处调用方能否直接引用字段。笔记机械自检后编译了同级 PDF。

== Encode 的阶段末待办属于哪类规格

=== 费曼直觉与硬核机制

`Requires` 是调用者必须事先满足的条件，`Effects` 是方法承诺的结果和可观察状态。RI 是每个合法对象在约定时刻都要满足的内部条件。旧注释把三项未来的设计检查写在一起。

#importantbox[如果将来承诺返回独立结果，写在 `Encode` 的 `Effects`。现在这句 `TODO(阶段末)` 只是提醒，等有证据时再定政策。]

#booktabs-table(
  columns: (1.1fr, 2fr, 1.3fr),
  [旧注释], [阶段末要问], [定下来后写在哪],
  [`fresh result`], [方法是否保证结果不与原记录共享存储？改返回的字节会影响原记录吗？], [在 `Effects` 描述返回值的保证。],
  [`record mutation`], [调用 `Encode` 的过程会改变原记录吗？这和返回后修改结果是两次不同的动作。], [在 `Effects` 描述调用后原记录的状态。],
  [`supported sizes`], [若有大小限制，是这次调用的额外义务、每条有效记录的内部条件，还是方法要处理的输入情况？], [分别对应 `Requires`、RI 或 `Effects` 中的失败行为。],
)

=== 陷阱与关键点

#warningbox[固定样例检查字节内容，没有修改返回值来验证共享关系，也没有验证尺寸边界。当前先完成已确定的字节布局。]

一个方法可以在调用期间保持原记录不变，同时让返回的数据与原记录共享。调用过程中的变化与调用者事后修改结果的影响，需要分别思考。尺寸也要区分单个字段长度能否写进长度头，以及整条记录能否装进要返回的切片。

=== 变式与同类归类

发送程序在修改消息前给日志留一份副本。若两处使用同一段内存，修改发送内容会改变日志的消息。Go 标准库的 `bytes.Clone` 用 `return append([]byte{}, b...)` 返回一个副本，这是关于结果的承诺。若同一个程序还要按指定字节数裁剪消息，`bytes.Buffer.Truncate` 对越界长度明说会触发 `panic`。源码用 `if n < 0 || n > b.Len()` 检查它。这是把越界行为写入结果承诺的一个例子，0102 的尺寸政策需由自身规格决定。

=== Go 语言机制补充

`Encode() []byte` 返回一个字节切片，也就是能访问一段字节的值。切片同样可以指向已有字节或一份新副本。Go 的签名约定返回类型，存储关系由方法文档说明。前一节有可以运行的复制示例。可用 `go doc -src bytes.Clone`、`go doc -src bytes.Buffer.Truncate` 核对真实契约，源码在 `/usr/lib/go/src/bytes/bytes.go:1391` 与 `/usr/lib/go/src/bytes/buffer.go:109`。

=== 本次操作与当前状态

核对了用户引用的旧注释、当前 `Encode` 和项目的规格模板。该段旧注释已不在当前 `kv_entry.go`，字段旁仍有共享存储的阶段末待办，无需补回旧段。保留当前 `Encode` 的布局规格，继续处理本步已有依据的填空。两条标准库文档查询通过。本次只更新了日记，机械自检后编译同级 PDF。

== 0102 阶段评测与下一步

=== 费曼直觉与硬核机制

#importantbox[已写的规格草稿评为 B−，待修订。编码布局足够具体，可作为实现依据。A2a 还欠一句能按 Go 规则核对的字段访问说明。0102 整步仍进行中。]

#booktabs-table(
  columns: (0.9fr, 1fr, 2.7fr),
  [项目], [状态], [可核对的证据],
  [A1 读格式], [待填写], [`kv_entry_test.go:13` 第一段是模板给的起步示例。其余范围、端序依据和讲义差异仍为空。],
  [已写规格], [可沿用], [AF 的映射清楚，RI 的两个长度上限与 `checkRep` 的检查一致。`Encode` 的总长度、端序和四段边界均与当前固定样例相符。],
  [A2a 字段访问], [待修订], [`kv_entry.go:23` 写了构造后应遵守的修改约束。本空需要描述 Go 实际允许哪些代码直接访问两个字段。现有样例未建立构造后禁止修改的政策。],
  [A2b 与 A3], [待填写], [`Decode` 的成功条件、返回值和最终键值，以及三条断言的预期仍在模板里。],
  [A4 实现与验证], [待实现], [两条方法声明还没有函数体，定点测试停在编译。],
)

=== 陷阱与关键点

#warningbox[「调用者应该怎样用」属于使用约束。「编译器允许哪边直接引用字段」可以从声明和 Go 的包外可见性规则核对。A2a 先回答后者，所有权仍留到阶段末。]

=== 变式与同类归类

Go 标准库的 `container/list.Element` 用 `next, prev *Element` 保存节点之间的连线，同时提供 `Value any` 给调用者存放数据。允许调用者直接改连线会影响遍历顺序，改一个节点的数据则是这个类型提供的用法。对照两组字段名，想想包外代码能写哪些访问表达式，再把同一个判断迁回 `Entry`。依据是 `go doc -src container/list.Element`、`/usr/lib/go/src/container/list/list.go:15` 和 `/usr/lib/go/doc/go_spec.html:2304`。课程对应 6.102 sp26 的 T09，R07 Abstraction Functions and Rep Invariants 中的表示暴露讨论。

=== 本次操作与当前状态

核对了源码、现有题单、0102 讲义和上游同名测试。`TestEntryEncode` 函数体与上游一致，`gofmt -d` 无差异。运行 `verify_go.py --package ./internal/db --test TestEntryEncode --regression`，定点命令在 `kv_entry.go:53` 和 `kv_entry.go:75` 报 `missing function body`，目标测试未运行，同包回归未启动。标准库 `go test -count=1 -run '^TestList$' container/list` 通过。本轮只归档评测，笔记机械自检并编译为同级 PDF。

下一步先填 `kv_entry_test.go:15` 的 `Value length`，沿第一段的半开区间写法继续标出键和值。完成 A1 后，一并贴出答案和 `TestEntryEncode` 函数体。接着把 A2a 改成一句能区分包内与包外直接访问的 `Access` 说明，再继续 A2b、A3 和 A4。

== A1 的两个空怎么填

#importantbox[每空一句话。第一行填长度字段的端序和规定它的出处。第二行填讲义多出来的字节代表什么、从哪个步骤引入。]

+ `Byte order` 是多字节整数的字节排列顺序。可用句式 `<endianness>, specified in <section or line>.`。在 0102 讲义「这一步要你做什么」里找包含 `uint32` 的一句。需要解释时，把那条约定和 `data` 中前两个长度字段对照。
+ `Extra byte in the chapter example` 可用句式 `<field or purpose>, introduced in step <step number>.`。把讲义里的数组与测试的 `data` 各找到第一个键字节，对照它前面的内容。然后读讲义数组下方的说明，分别找到额外字节的用途和步骤编号。

#warningbox[这里只是解释讲义和测试的差异。0102 样例继续用当前测试的 `data`。端序也涉及多字节的整数头，键和值本身仍按各自的字节顺序放入。]

以设备编号为例，接收方必须知道低位还是高位先到，否则同样的字节会被解释成不同的编号。十进制 `258` 等于 `1 × 256 + 2`，用四字节表示时可排成 `02 01 00 00` 或 `00 00 01 02`，取哪种由格式约定。Go 标准库的 ZIP 读取器调用 `binary.LittleEndian.Uint32`，PNG 读取器调用 `binary.BigEndian.Uint32`。它们都可以读取四字节字段，各自遵循自己的格式。0102 也要到自己的讲义找约定。源码见 `/usr/lib/go/src/archive/zip/reader.go:706` 和 `/usr/lib/go/src/image/png/reader.go:875`，接口定义可查 `go doc encoding/binary.ByteOrder`。

=== 本次操作与当前状态

核对了 `internal/db/kv_entry_test.go:18` 的两个填空、同文件的 `data`、以及 `../db-web/docs/ch01-storage-basics.md:144` 的原题说明。`go doc encoding/binary.ByteOrder` 正常返回。只归档填空提示，答案由本人完成。机械自检后编译同级 PDF。

== A1 复核与额外字节的写法

=== 费曼直觉与硬核机制

#importantbox[额外字节那行可以写 `Extra byte in the chapter example: The deleted flag, introduced in step 0103.` 讲义数组里键前的 `0` 表示这条记录不是删除记录。]

#booktabs-table(
  columns: (1fr, 1fr, 2.55fr),
  [条目], [评测], [依据或修订],
  [`Value length`], [通过], [`[4, 8)` 覆盖下标 4 到 7 的四个头部字节。],
  [`Key` 与 `Value`], [待修订], [题目要的是当前 `data` 中的下标范围。`2^32 - 1` 是字段长度上限。键从下标 8 开始且占 2 字节，因此写 `[8, 10)`。值紧接着键，按样例的值长度算终点。],
  [`Byte order`], [方向正确], [小端是低位字节在前，把 `bit` 改成 `byte`。出处是讲义 `ch01-storage-basics.md:153`。],
)

=== 陷阱与关键点

#warningbox[当前 0102 的测试数据在长度头之后直接放键。保留现有的 `data`，额外的 `0` 写在证据注释里。]

=== 变式与同类归类

讲义 `../db-web/docs/ch01-storage-basics.md:161` 说明了额外字节的来历。在上游真正的 0103 实现中，`if ent.deleted` 分支把 `data[8]` 设为 1，键从 `data[9:]` 起写。这可直接核对旗标在格式中的位置。见 `../db-web/upstream/db_project+solution/db_project/0103/kv_entry.go:14`。

=== Go 语言机制补充

端序规定整数的几个字节先后怎么摆放。标准库小端写入的开头是 `b[0] = byte(v)`，下一行才是 `b[1] = byte(v >> 8)`。所以第一项取得整个最低位字节。可用 `go doc -u -src encoding/binary.littleEndian.PutUint32` 核对。本机源码为 `/usr/lib/go/src/encoding/binary/binary.go:96`。

=== 本次操作与当前状态

核对了新填的 A1、0102 讲义与上游两步的格式。测试函数体仍与上游 0102 一致，`gofmt -l internal/db/kv_entry_test.go` 无输出。验证器报告两个方法缺函数体，`TestEntryEncode` 未运行。本轮只更新笔记，机械自检并编译同级 PDF。A1 尚待把键值两行改为下标区间，并补上端序来源与额外字节说明。

=== 再复核与下一处

#importantbox[`Key` 和 `Value` 的区间公式现在都对。把样例的 `k = 2` 与 `v = 3` 代入，可在公式后分别补上 `[8, 10)` 和 `[10, 13)`。首两个头部区间也正确。]

接下来只需修 A1 的最后两行，可以直接使用下面的写法。

#codelisting(
  ( ```go
  //   - Byte order: Little-endian (least significant byte first),
  //     as specified in ch01-storage-basics.md under step 0102.
  //   - Extra byte in the chapter example: The deleted flag, introduced in step 0103.
  ``` ).text,
  lang: "go",
  caption: [A1 最后两处注释的写法],
)

#warningbox[端序按字节排列。当前仍写成 `lowest bit`，应写 `least significant byte`。标准库小端代码 `b[0] = byte(v)` 放入整个低位字节。额外删除标志只写在证据注释中。前一节有标准库源码和 0103 上游实现出处。]

A1 补齐后贴出作答与 `TestEntryEncode` 函数体。接下来只做 A2a 的 `Access` 一句话，区分包内和包外代码能否直接访问 `key`、`val`，位置是 `internal/db/kv_entry.go:22`。

=== 本次操作与当前状态

对照固定样例复算了两个区间，核对了讲义的端序与删除标志。测试函数体与上游一致，两个 Go 文件的 `gofmt -l` 无输出。验证器仍在 `kv_entry.go:53` 和 `kv_entry.go:75` 报缺少函数体，目标测试尚未运行。源码作答保持原样，笔记完成机械自检并编译同级 PDF。

== A2a 复核导出的类型与字段

=== 费曼直觉与硬核机制

#importantbox[你判断 `Entry` 这个类型名是导出的，这部分对。Go 分别判断类型名和每个字段名。]

#booktabs-table(
  columns: (0.9fr, 1.15fr, 2.35fr),
  [名字], [是否导出], [在代码里意味着什么],
  [`Entry`], [是], [允许导入 `db` 的其他包能使用 `db.Entry` 这个类型名。],
  [`key`], [否], [`db` 包内代码可以直接写 `entry.key`。包外直接写会在编译阶段报错。],
  [`val`], [否], [同理，`db` 包内代码可以直接写 `entry.val`。],
)

=== 陷阱与关键点

#warningbox[导出规则逐个名字判断。即使持有该类型的值，包外能写哪些字段仍取决于各字段自己的名字。]

=== 变式与同类归类

标准库的 `container/list.Element` 是链表节点。它允许调用者修改节点存放的 `Value`，同时保护连接节点的 `next`、`prev` 字段。否则直接改连接会破坏遍历。这个例子用同一个类型展示了两种字段访问方式。迁回 0102，字段能否直接访问用同一条 Go 规则判断。具体的字节共享仍需看方法契约。源码见 `/usr/lib/go/src/container/list/list.go:15`，可执行 `go doc -src container/list.Element` 查看。

=== Go 语言机制补充

导出表示一个符合规则的名字可以在包外使用。Go 语言规范分别检查类型声明处与字段声明处的名字，规则见本机 `/usr/lib/go/doc/go_spec.html:2304`。在另一个包 `main` 里运行下面的程序，能读写 `Value`。

#codelisting(
  ( ```go
  package main

  import (
      "container/list"
      "fmt"
  )

  func main() {
      var element list.Element
      element.Value = "ready"
      fmt.Println(element.Value)
  }
  ``` ).text,
  lang: "go",
  caption: [在包外引用导出的类型和字段],
)

把赋值和打印换成 `_ = element.next` 后，同样能写出类型声明，但字段访问触发编译错误。这个实验把「能用类型名」和「能访问字段」分开验证。

=== 本次操作与当前状态

核对了 `Entry` 的声明、Go 语言规范和标准库源码。临时正例用 `go run visible.go` 输出 `ready`，`go vet visible.go` 通过。反例 `go run hidden.go` 预期编译失败，诊断定位到 `element.next`。项目源码保留原样，日记经机械自检编译同级 PDF。A2a 由本人用一句话记录包内与包外对两个字段的直接访问。

=== A2a 的访问限制如何生效

#importantbox[限制已经由字段声明中的小写名字建立。检查发生在编译阶段。写在 `Access` 里的文字是给维护者读的说明。]

用户写出的包内与包外方向正确。`kv_entry.go:11` 那句放在类型文档上，容易被读成整个 `Entry` 类型只能包内访问。把说明放到字段旁的 `Safety from rep exposure` 下，明确主语是 `key` 和 `val`。可写 `Access: Only code in package db can access key and val directly.` 同包的其他文件和普通函数也能访问，现有 `package db` 测试直接用字段名初始化 `Entry`。源码样例见 `internal/db/kv_entry_test.go` 的 `TestEntryEncode`。

#warningbox[Go 的这项边界是包。语言没有只让该类型的方法、或只让当前文件访问字段的修饰符。需要这种隔离时可把表示放在独立的包，让该包通过方法提供操作。0102 的字段已经限制了包外直接访问。]

想象一个系统统计请求数。把计数藏在 `Counter.total`，外部经由 `Increment` 增加。如果外部任意写入总数，统计可能突然倒退。用临时的 `example.com/counterdemo` 模块验证了两种情况。在 `counter/counter.go` 定义带小写字段 `total` 的 `Counter`，同包的另一个文件 `counter/access.go` 里，普通函数 `Increment` 用 `counter.total++` 修改，`Value` 方法返回当前数值。包外调用这两个操作能读到 `1`，尝试直接执行 `requests.total++` 会报 `cannot refer to unexported field total`。迁回 0102，机制相同，受保护的内容换成键和值。

编译器在字段查找时比较名字，遇到未导出的名字还检查是否属于同一个包。实现可看 `/usr/lib/go/src/cmd/compile/internal/types2/lookup.go:212` 的 `f.sameId(pkg, name, foldCase)`，以及 `/usr/lib/go/src/cmd/compile/internal/types2/object.go:136` 中的包检查。可见性的语言规则见本机 `/usr/lib/go/doc/go_spec.html:2304`。

标准库的 `bytes.Buffer` 给出方法层的两个例子。`String()` 用 `return string(b.buf[b.off:])` 返回字符串，调用者不能对字符串中的字节直接赋值。`Bytes()` 用 `return b.buf[b.off:]` 返回共享的字节视图，文档允许操作它影响缓冲区。两个方法都在内部读取小写字段，区别在于调用者获得什么。0102 的共享政策继续由后续规格决定。可用 `go doc -src bytes.Buffer.String` 和 `go doc -src bytes.Buffer.Bytes` 核对，源码分别在 `/usr/lib/go/src/bytes/buffer.go:72` 与 `/usr/lib/go/src/bytes/buffer.go:60`。上一小节另有可直接运行的标准库例子。

=== 本次操作与当前状态

核对了当前填写位置、Go 规范、编译器和标准库实现。临时计数器正例 `go run .` 输出 `1`，`go vet . ./counter` 通过。`go run ./outside` 按预期在尝试访问小写字段时编译失败。本轮只归档解释，源码由本人将说明移到字段旁。笔记经机械自检并编译为同级 PDF。

=== A2a 作答复验

#importantbox[A2a 的包内访问判断和注释位置通过。写成 `Access: Only code in package db can access key and val directly.` 更精确，因为 `directly` 限定的是通过字段名访问。]

#warningbox[`Encode() will return a clone` 是另一条关于返回字节的承诺，当前测试只检查字节内容。先用已有的 `TODO(阶段末)` 跟踪这项决定。]

标准库的 `bytes.Clone` 用 `append([]byte{}, b...)` 提供独立副本。`bytes.Buffer.Bytes` 用 `b.buf[b.off:]` 提供共享视图。方法文档分别说明两种承诺。在 0102，小写字段的访问限制已有 Go 语言依据，输出是否共享仍是阶段末决定。可用 `go doc -src bytes.Clone` 与 `go doc -src bytes.Buffer.Bytes` 看两者的区别。

接下来先收尾 A1。在 `internal/db/kv_entry_test.go:18` 给已写对的小端补上讲义来源，再把额外字节那行填成 `The deleted flag, introduced in step 0103.`。完成后贴出作答及 `TestEntryEncode` 函数体。下一题做 `internal/db/kv_entry.go:67` 的 A2b，从测试里找成功后可以观察到的返回值与记录内容。

=== 本次操作与当前状态

核对了已移到字段旁的 `Access`、新增的副本说法和 A1 状态。`gofmt -l` 无输出，`git diff --check -- internal/db/kv_entry.go` 通过，测试函数体与上游一致。定点验证在 `kv_entry.go:53` 和 `kv_entry.go:75` 因缺少函数体停在编译阶段。A2a 的临时题面已由本人移除，本轮只保存评测记录，笔记经机械自检编译同级 PDF。

== A2b 的 Decode 成功规格复核

=== 费曼直觉与硬核机制

#importantbox[成功结果的两部分已写对。`Decode` 返回 `nil`，并把键和值设为记录里对应的字节。还剩成功条件要填。]

#booktabs-table(
  columns: (1fr, 1.4fr, 2.25fr),
  [规格项], [当前状态], [最小修订],
  [成功条件], [仍是 `TODO(user)`], [填 `one complete record in the format described by Encode`。这里描述读到一条完整记录的成功分支。],
  [返回值], [`nil` 正确], [写 `returns nil` 就足够。它对应 `TestEntryEncode` 中检查错误值的断言。],
  [记录状态], [键和值的相对区间正确], [表述为「记录中对应区间的字节」，偏移从本条记录起点算。用长度头读出的 `K` 和 `V` 来解释区间。],
)

=== 陷阱与关键点

#warningbox[`r` 是一个 `io.Reader`。它提供读字节的操作。把区间写成 `r[8, 8+k)` 容易让人以为能用下标访问 `r`。可以沿用区间信息，把它明确归到读出的记录。]

最后还要回答「测试是否证明接收者必须为空」。观察测试准备了解码前怎样的对象，区分「一项成功样例的初始状态」与「所有合法调用都必须满足的条件」。

=== 变式与同类归类

标准库 `encoding/binary.Read` 从 `io.Reader` 读取定长数据，先用 `io.ReadFull(r, bs)` 读到字节，再将结果写入 `data`。例如读取设备的一项定长编号时，不能把到手的一半字节当作完整编号。它的接口把来源和解码后的目标分开，这与 `Decode` 区分 `r` 和记录中字节范围的写法一样。它读取定长数据，0102 使用长度头描述两个变长字段，各自的输入和失败行为由各自的契约定义。出处为 `/usr/lib/go/src/encoding/binary/binary.go:258`，可查 `go doc -src encoding/binary.Read`。

=== Go 语言机制补充

接口是一组方法规定的能力。`io.Reader` 的 `Read(p []byte) (n int, err error)` 可以把读到的字节放入 `p`。调用者用 `n` 知道有多少字节到手。前面关于短读的可运行 Go 示例区分了读的能力和实际存放字节的数组，可用 `go doc io.Reader` 核对。规范文字可以谈记录中各个位置，具体如何存储由实现决定。

=== 本次操作与当前状态

读取了当前规格、样例和项目模板。`go doc ./internal/db.Entry.Decode` 能显示草稿，格式检查和 `git diff --check` 通过。标准库 `go test -count=1 -v -run '^TestLittleEndianRead$' encoding/binary` 实际运行并通过。项目的定点验证在 `Encode` 和 `Decode` 缺少函数体处终止，断言尚未运行。未改源码作答。本轮日记经机械自检并编译同级 PDF。下一步先补完整记录条件并改 `r` 的区间表述，再回答 A2b 的初始状态小问。
