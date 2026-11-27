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
= 0102 续作：收尾 Decode 成功规格

昨天最后一节停在 A2b。当前源码已补上「来源提供一条符合 `Encode` 格式的完整记录」这一成功条件。昨天已通过 A2a 的字段访问判断。

#importantbox[现在先收尾 A2b。把键和值的区间写成从本条记录起点计算的字节范围，成功返回写成 `returns nil`。然后在规格上方的 `Answer` 处回答：测试里从 `decoded := Entry{}` 开始，能否据此要求每次解码前记录都为空？写一句理由。]

== 余下的任务与填写位置

#booktabs-table(
  columns: (0.75fr, 1.15fr, 2.4fr),
  [顺序], [位置], [待办],
  [A2b], [`kv_entry.go:55-71`], [修订成功效果的区间表述，回答初始状态小问。],
  [A1 收尾], [`kv_entry_test.go:18-19`], [给小端补讲义依据，补全额外字节的用途与所属步骤。讲义第 153 行规定端序，第 161 行说明额外字节是 0103 的删除标志。],
  [A3], [`kv_entry_test.go:24-34`], [填写现有样例的初始状态，以及固定编码字节、解码错误值和解码后记录这三处断言的预期。],
  [A4], [`kv_entry.go:53,75`], [完成 `Encode` 和 `Decode` 的函数体，先跑定点测试，再跑同包测试和项目级检查。],
)

== 0102 的字节布局与测试范围

#warningbox[当前 0102 测试的固定字节使用四段布局。讲义示例多出 0103 的删除标志。截断后的记录状态、返回结果是否共享存储等细节继续留在 `TODO(阶段末)`。]

A2b 的成功条件已有草稿。定位时从 `kv_entry.go:67` 的 `Effects` 开始，再回到第 57 行的 `Answer`。A1 的四段范围已填写，待补的是端序的出处和额外字节说明。

回答 A2b 时，想一想：如果解码前记录已经有键和值，现有测试能否观察到这次调用的结果？用测试准备的对象说明你的理由。

== 标准库如何从读取源取得字节

昨天的标准库样本是 `encoding/binary.Read`，用 `io.ReadFull(r, bs)` 从来源读出字节。可在 `/usr/lib/go/src/encoding/binary/binary.go:262` 核对。它处理定长数据。0102 的键和值按记录中的长度字段确定区间，两处都可以把读取来源与读出的字节分别写清楚。

`r` 的类型为 `io.Reader`，通过 `Read` 提供字节。写规格时把下标附在读出的记录上。可用 `go doc io.Reader` 核对读取约定，昨天的日记也保留了可运行的读取示例。

== 本次操作与当前状态

用昨天最后一节和当前两个源码文件恢复 0102 进度，核对了讲义第 153、161 行。`go doc ./internal/db.Entry.Decode` 和针对 `kv_entry.go` 的 `git diff --check` 通过。全仓 `git diff --check` 报告已有的 11 月 13 日 PDF 尾随空白。重新运行定点测试时，两个方法分别在第 53、75 行因缺少函数体停在编译阶段，尚未执行断言。

本轮创建本日 Typst 笔记并编译同级 PDF。下一次提交时，贴出修订的 A2b 注释、A1 补充说明及 `TestEntryEncode` 的函数体。


== Decode 规格完整示例

数据库从存储读出一条记录时，`Decode` 的规格要回答三个问题：字节从哪来，成功时返回什么，调用结束后记录里有什么。调用方法作用的对象叫接收者。签名里的 `ent` 是接收者，测试把它命名为 `decoded`。

#importantbox[先从测试的两条检查读出结果：第一条检查错误值为 `nil`，第二条检查解码后的记录等于原记录。把这两件事放进同一个成功分支，然后用记录格式说明键和值分别是哪一段字节。]

=== 源码注释与测试依据

下面是写进 `internal/db/kv_entry.go` 的方法注释。完整记录是成功分支的条件。对读取失败时的详细行为，当前项目规格用阶段末待办标出。

#codelisting(
  (```go
// Decode loads one encoded key-value record into the receiver.
//
// Parameters:
//   - r is the source of the encoded record.
//
// Effects:
//   - If r provides a complete record in the format described by [Entry.Encode],
//     returns nil and sets the key and value to the corresponding record bytes.
//
// K and V are the key and value lengths from the record header. Offsets are
// relative to the start of the record. Each range includes its start and
// excludes its end.
//
//	Key    [8, 8+K)
//	Value  [8+K, 8+K+V)
//
// TODO(阶段末): Specify nil inputs, fragmented reads, errors and receiver
// state on truncated input, reader position, and trailing bytes.
  ```).text,
  lang: "go",
  caption: [0102 的 Decode 规格注释],
)

#booktabs-table(
  columns: (0.9fr, 1.45fr, 2.3fr),
  [位置], [依据], [写什么],
  [`Parameters`], [`Decode(bytes.NewBuffer(data))`], [`r` 提供编码记录的字节。],
  [`Effects` 的返回值], [`assert.Nil(t, err)`], [成功时返回 `nil`，表示该次调用成功。],
  [`Effects` 的状态], [`assert.Equal(t, ent, decoded)`], [用对应字节设置接收者的键和值。样例中得到 `k1` 和 `xxx`。],
  [是否要写 `Requires`], [测试从 `decoded := Entry{}` 开始], [这一例提供空记录的证据。要求所有调用都从空记录开始，需要独立依据。当前省略该项。],
)

=== 如何确定记录内的字节区间

#warningbox[偏移量从本条记录的第一个字节算起。把下标附在记录的字节上。测试只用了一条完整输入，错误类型、截断后的接收者状态、读取位置等细节继续留到阶段末。]

前 8 字节是两个长度字段。把它们读出的值称为 `K` 和 `V`。因此键从第 8 个下标开始，占 `K` 字节。值紧跟在键后面，占 `V` 字节。区间包含起点、排除终点。样例中 `K=2`、`V=3`，所以键是 `[8, 10)`，值是 `[10, 13)`。这些范围描述最终应得到的数据，可以直接拿来核对测试预期。

=== 从已有记录开始解码会覆盖什么

如果测试把 `decoded` 改成一条已有键和值的记录，再调用 `Decode` 并比较得到的新记录，这条用例会增加哪一种初始状态的证据？用类似问题检查你准备写进 `Requires` 的每一个限制。

=== 标准库的两种解码来源

Go 标准库的 `encoding/binary.Read` 从读取源取定长数据，源码先调用 `io.ReadFull(r, bs)`。`encoding/binary.Decode` 接受已有的字节序列，先检查 `len(buf) < n`，成功还报告使用的字节数。0102 的方法接收读取源，与 `Read` 的形状相近。0102 项目用记录头描述变长键值的边界，标准库这两项操作的定长大小由目标值类型决定。可用 `go doc -src encoding/binary.Read` 和 `go doc -src encoding/binary.Decode` 核对，分别见 `/usr/lib/go/src/encoding/binary/binary.go:258` 和 `/usr/lib/go/src/encoding/binary/binary.go:297`。

=== 可运行的标准库例子

`io.Reader` 是读取接口，要求一个值提供 `Read(p []byte) (n int, err error)` 方法。调用者交给它一段可写的字节空间，`n` 报告实际读到的字节数。Go 通过这个方法约定，让测试可用内存中的数据模拟读取来源。可查 `go doc io.Reader` 和 `/usr/lib/go/src/io/io.go:86`。

假设传感器在消息前两个字节发送包计数，按约定用小端，即最低位字节在先。计数类型 `uint16` 能容纳 16 位无符号整数。程序可能从读取源拿到计数，也可能分析一帧已保存的字节。若把帧里的第三个字节也算成计数，就会把下一字段混进来。例子展示两种来源如何得到同一个计数。传给标准库的 `&count` 提供变量的地址，方法可以写回这个变量。映射回 0102，读取源也是 `io.Reader`，长度字段之后还有按记录编码解释的键和值。

#codelisting(
  (```go
package main

import (
	"encoding/binary"
	"fmt"
	"io"
	"strings"
)

func main() {
	var src io.Reader = strings.NewReader("\x02\x00")
	var count uint16
	err := binary.Read(src, binary.LittleEndian, &count)
	fmt.Println("stream:", count, err)

	frame := []byte{2, 0, 99}
	n, err := binary.Decode(frame, binary.LittleEndian, &count)
	fmt.Println("buffer:", n, count, err)
}
  ```).text,
  lang: "go",
  caption: [分别从读取源和已保存的字节解码设备计数],
)

将示例保存为 `main.go`，可运行 `go run main.go` 和 `go vet main.go`。第一行输出 `stream: 2 <nil>`。第二行输出 `buffer: 2 2 <nil>`，两个数字分别是使用的字节数和计数。

=== 本次操作与当前状态

在 `internal/db/kv_entry.go:55` 填写 A2b 的初始状态回答，在第 62 行开始补全方法规格。失败分支的旧草稿合入阶段末待办，当前规格承诺成功结果。A2b 示例已写好，后续按上一节的顺序收尾 A1，再继续 A3。

`go doc ./internal/db.Entry.Decode` 正常显示注释和区间表。`gofmt -d internal/db/kv_entry.go` 无差异，针对该文件的 `git diff --check` 通过。独立示例的 `go run` 和 `go vet` 通过。`go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/` 在第 53、80 行因两个方法缺少函数体停在编译阶段。日记已通过机械自检并编译同级 PDF。


== Decode 的精简规格

#importantbox[这份规格贴在方法声明上方，按「用途、参数、成功结果」阅读。读取一条完整记录时，结果由返回值和写入的键值共同描述。]

=== 方法声明上方的规格

#codelisting(
  (```go
// Decode loads one encoded key-value record into the receiver.
//
// Parameters:
//   - r is the source of the encoded record.
//
// Effects:
//   - If r provides a complete record in the format described by [Entry.Encode],
//     returns nil and sets the key and value to the corresponding record bytes.
func (ent *Entry) Decode(r io.Reader) error
  ```).text,
  lang: "go",
  caption: [Decode 源码中的完整规格块],
)

=== 0102 已确定和待定的行为

#warningbox[当前只确定了完整记录的成功分支。TODO(阶段末) 跟踪 `nil` 输入、分段读取、截断时的错误和接收者状态、读取位置以及尾随字节。]

`Encode` 的规格定义字节布局，`Decode` 用 `[Entry.Encode]` 引用它。练习回答与实现提示保存在本日上一节，可在开始实现时回看。

测试从空记录开始。如果拟添加 `Requires`，先检查现有依据能支持该限制覆盖哪些调用。

=== 标准库的注释写法

标准库的 `encoding/binary.Read` 同样把读取源和写入目标写在首句，并在注释中说明具体错误。可查 `go doc encoding/binary.Read` 或 `/usr/lib/go/src/encoding/binary/binary.go:258`。

紧贴方法声明的注释由 `go doc` 展示。`[Entry.Encode]` 是 Go 文档中的符号引用。块中的 `Parameters` 和 `Effects` 来自项目模板。

=== 本次操作与当前状态

从 `internal/db/kv_entry.go` 的 `Decode` 周围移除练习提示、重复的字节图和阶段末说明，把待定项保存在本节。`go doc ./internal/db.Entry.Decode` 正常显示规格。`gofmt -d internal/db/kv_entry.go` 无差异，针对该文件的 `git diff --check` 通过。定点测试仍在第 53、63 行因两个方法缺少函数体停在编译。日记已通过机械自检并编译同级 PDF。

// 轨道：CS 轨
= 函数与 ADT 的完整规格怎样写

规格是调用者与实现者之间的约定。调用者要知道什么情况下可以调用，以及调用结束后能依赖什么。实现者据此判断哪些行为必须保留，哪些实现细节可以调整。抽象数据类型（ADT）是用一组操作及其行为来定义的一类值。一个函数回答「这次调用会怎样」。一个 ADT 还回答「这些操作作用于什么样的值」以及「实现怎样维持这些值的合法性」。

#importantbox[函数规格由签名、前置条件与后置条件组成。ADT 的公开规格由抽象值的定义和各项操作的契约组成。具体实现还要在字段旁说明抽象函数、表示不变式与防止表示暴露的理由。]


== 函数规格的内容与顺序

6.102 R04 将规格写成一个条件关系。调用前满足前置条件，调用结束时就必须满足后置条件。签名已经规定了输入和输出的类型。db-go 用下表中的英文标签补足类型无法表达的语义。#link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[6.102 R04 · Specification structure]

#booktabs-table(
  columns: (1fr, 1.55fr, 2.5fr),
  [内容], [在 Go 里怎么放], [写到什么程度],
  [签名], [`func` 声明], [名称、参数与返回值的类型。方法的接收者也在这里声明。],
  [一句话用途], [紧贴声明的首行注释], [从函数或方法名起笔，写调用者能用它完成什么。],
  [参数含义], [`Parameters:`，按需], [每个有必要解释的参数的角色、单位或坐标起点。签名和首句足以解释时可省。],
  [前置条件], [`Requires:`，按需], [调用者必须在调用前保证的额外条件，例如数量为正、两个参数等长。没有额外条件时可省。],
  [后置条件], [`Effects:`], [为每个已确定分支写返回值、错误和可观察状态。需要约定时也写部分结果、资源状态、共享数据的有效期或约定触发的 `panic`。简单操作可用一句首注释表达完整结果。],
)

用边界问题判断条件写在哪。若 `n > 0` 是调用者的义务，放在 `Requires`。若 API 接受 `n <= 0` 并承诺返回某个错误，就写进 `Effects` 的失败分支。满足前置条件后，某种业务失败仍可能是一次合约内的调用，例如库存不足。把每种已确定分支下的返回值、错误和状态变化一起写清。6.102 R05 建议用声明式结果表述，例如「失败后原库存保持原数」。更换内部变量、循环或辅助函数后，这句仍可核对。#link("https://web.mit.edu/6.102/www/sp26/classes/05-designing-specs/#designing_good_specifications")[6.102 R05 · Designing good specifications]

== ADT 的公开规格与实现说明

类型注释写抽象值是什么、是否可变，以及影响所有调用者的初始化、零值或共用限制。每个公开操作按函数契约写清自身的行为。6.102 R06 按操作对抽象值的作用区分创建器（creator，创建一个新值）、生产器（producer，以已有同类值产生新值）、观察器（observer，读取抽象信息）和变值器（mutator，可能改变已有值）。这些是设计操作集合的分类，类型可以按需求选用其中几类。#link("https://web.mit.edu/6.102/www/sp26/classes/06-abstract-data-types/#classifying_types_and_operations")[6.102 R06 · Classifying types and operations]

#booktabs-table(
  columns: (1.45fr, 1.2fr, 2.55fr),
  [内容], [Go 中的位置], [写完怎样检查],
  [抽象值与共用规则], [`type` 上方], [调用者能否理解值代表什么、怎样初始化、哪些行为允许？],
  [各操作的契约], [函数与方法上方], [面对任意合法调用，能否从签名和注释判断承诺的结果与变化？],
  [抽象函数（AF）], [具体 `struct` 的字段旁], [代入一组合法字段值，能否算出它们唯一代表的抽象值？多组字段可以代表同一个抽象值。],
  [表示不变式（RI）], [具体 `struct` 的字段旁], [拿到任意一组字段值，能否只根据字段判断这个表示合法吗？],
  [防止表示暴露], [具体 `struct` 的字段旁], [调用者能否经参数或结果接触并改写内部数据？逐条交代字段访问、共享、复制和生命周期。公开承诺写在相应操作旁。],
)

表示是类型用于存放数据的具体字段。RI 先筛出合法的表示，AF 再把合法表示解释成抽象值。创建器和生产器建立新值的 RI，支持的零值也要满足 RI。操作需要让已有值在可观察的边界维持 RI，输入和输出也应防住绕过操作直接破坏它的路径。内部的 `checkRep` 可把 RI 变成运行时检查。它的判定依据仍来自字段旁的 RI。#link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#documenting_the_af_ri_and_safety_from_rep_exposure")[6.102 R07 · AF、RI 与表示暴露] · #link("https://web.mit.edu/6.031/www/sp21/classes/11-abstraction-functions-rep-invariants/#how_to_establish_invariants")[6.031 R11 · How to establish invariants]

== 可运行的 Go 布局示例

发料台需要记录可领件数，一次申请必须全量发放。库存为 2 时若收到领取 3 件的申请，先扣再拒绝会留下负数，也让调用者无法按原库存重试。这个例子用 `NewStock` 展示普通函数形式的创建器，用 `Remaining` 展示一句话观察器，用 `Take` 展示有额外调用条件和两个结果分支的变值器。它沿用项目已有的 `examples/construction/stock.go`，再加一个可直接运行的入口。与 `Entry` 同样用操作说明可见变化，发料台的失败处理和整数存储只适用于这份库存契约。

#codelisting(
  (```go
package main

import "fmt"

// Stock tracks the number of units available at a supply desk.
// The zero value represents empty stock. Methods require a non-nil *Stock.
// Callers must serialize access to a shared Stock if any call can change it.
type Stock struct {
	// AF: units is the number of units available for withdrawal.
	// RI: units >= 0.
	// Safety from rep exposure: units is unexported and Remaining returns
	// an int by value. No operation gives callers access to the field itself.
	units int
}

// NewStock sets up a stock for withdrawals.
//
// Requires:
//   - initial >= 0.
//
// Effects:
//   - Returns a stock with initial units available.
func NewStock(initial int) *Stock {
	return &Stock{units: initial}
}

// Remaining returns the available units without changing the stock.
func (s *Stock) Remaining() int {
	return s.units
}

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
func (s *Stock) Take(n int) bool {
	if n > s.units {
		return false
	}
	s.units -= n
	return true
}

func main() {
	var empty Stock
	fmt.Println(empty.Remaining())

	stock := NewStock(2)
	fmt.Println(stock.Take(3), stock.Remaining())
	fmt.Println(stock.Take(2), stock.Remaining())
}
  ```).text,
  lang: "go",
  caption: [库存类型、表示说明、创建器与方法契约],
)

把示例保存为 `main.go` 后运行 `go run main.go`。三行输出依次是 `0`、`false 2`、`true 0`。创建器用非负的初始值建立 RI。成功扣减时，原数量至少为 `n`，因此新数量仍然非负。库存不足时数量保持原值，RI 同样成立。

== 怎样判断条件该写在哪

#warningbox[把外部承诺和内部论证写在各自对应的声明旁。诸如「需要有效参数」应落实成精确的合法范围或明确的错误分支。字段关系由 RI 表达，合法对象的字段关系可由维护该类型的实现提供。调用者必须满足的输入限制才需要列进 Requires。]

小写字段限制包外直接访问。表示仍可能经共享数据暴露，例如把内部字节切片直接交给调用者。切片可以引用一段已有的字节，因此其他代码可能通过它改动同一份数据。只有经过实际检查的所有权政策才能写成公开承诺。

== 对应到 Entry

回到 `internal/db/kv_entry.go`。类型首句解释 `Entry` 表示一条可变键值记录。字段旁的 AF 解释键和值如何组成这条记录，RI 解释两段长度的上界。 `Encode` 的固定字节布局属于调用者可观察的结果，放在方法契约的 `Effects`。 `Decode` 引用该格式，说明完整记录的成功返回值与解码后的键值。截断和共享存储的详细承诺仍待确认。

== 接受零件申请会改变哪些承诺

假设发料台决定接受零件申请并保证成功，立刻写出修改后的合法调用范围和零件分支的返回值与状态。再判断 `units >= 0` 是否需要随这个决定修改。这个检验把调用约定和内部表示条件放回它们各自的层次。

== 标准库如何描述读取与借用

- 标准库的 `io.ReadFull` 适用于需要填满目标字节空间的读取。若读到一部分后就到末尾，调用者需要区分截断与读满，否则可能把半条数据当成完整内容。文档说明字节数和错误类型，源码将目标长度交给 `ReadAtLeast(r, buf, len(buf))`。它展示了函数如何约定失败和部分结果。0102 的 `Decode` 要处理的是一条变长记录，它的失败细节目前留待项目规格确认。可查 `go doc -src io.ReadFull` 和 `/usr/lib/go/src/io/io.go:353`。
- 标准库的 `bytes.Buffer.Bytes` 适用于要直接查看缓冲区未读部分的调用者。实现返回 `b.buf[b.off:]`，结果引用缓冲区数据，直接改动会影响后续读取。它的公开文档约定结果的有效期到下一次修改缓冲区。与只返回一个整数的 `Stock.Remaining` 相比，这种返回值需要额外的共享规则。对 `Entry`，是否共享同样属于公开 API 的所有权判断。可查 `go doc -src bytes.Buffer.Bytes` 和 `/usr/lib/go/src/bytes/buffer.go:60`。

== Stock 示例里的 Go 语法

结构体（`struct`）把多个有名字的字段组织为一个值。接收者就是方法作用的值，例如 `(s *Stock)`。这里的 `*Stock` 是指向库存对象的指针，所以 `Take` 能更新调用者所持有的库存。零值指变量没有显式初始化时 Go 提供的初值。示例的 `var empty Stock` 包含一个初值为 0 的整数字段，因而代表空库存。空库存也能使用 `Remaining`；类型说明里要求的非 `nil` 指针则是能定位实例的条件。

`go doc` 向调用者展示紧贴声明的注释。公开类型与操作的注释首句用声明名起笔。 `Parameters:`、`Requires:`、`Effects:` 和内部三条标签是 db-go 的项目约定。具体布局见 `docs/go-construction-templates.md`。#link("https://go.dev/doc/comment")[Go Doc Comments]

== 本次操作与当前状态

按 `software-construction` 本地镜像核对了 6.102 sp26 R04–R07，并用 6.031 sp21 R11 补充不变式维持的推导。追加到本日笔记，机械自检后编译同级 PDF。独立示例的 `go run main.go` 和 `go vet main.go` 通过。项目已有示例的 `go test -count=1 -v ./examples/construction`、`go vet ./examples/construction` 和 `go doc ./examples/construction.Stock.Take` 均通过。此次操作集中在笔记，项目本步仍按已有题单推进。


= 为什么笔记出现旧的固定标题

当前的 `answer-note/SKILL.md` 只要求用 Typst 按本地日期归档，同一天追加。上一轮用了项目 `AGENTS.md` 第 10 行仍列着的旧 CS 轨标题，所以笔记出现了固定的教学栏目。

== 本次操作与当前状态

按本次反馈调整当天四节问答。正文直接跟在主题下，需要分节的位置用能说明内容的标题，例如「函数规格的内容与顺序」和「ADT 的公开规格与实现说明」。核对了正文、代码、表格和验证记录，并重新编译了同级 PDF。


= 函数契约与 ADT 表示的 Go 写法

函数的规格由*签名、前置条件、后置条件*组成。签名给出可由类型系统检查的部分。前置条件是调用者在调用前要保证的事。后置条件是实现者在这些条件成立时必须兑现的结果。它可以约定返回值、错误以及对象或外部资源的状态变化。对于允许的失败情况，把错误和失败后的状态写在同一个分支里。#link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[MIT 6.102 R04]

在 db-go，函数或方法声明正上方先用声明名写一句用途。用 `Parameters` 说明参数的含义或单位，用 `Requires` 声明额外的调用条件，用 `Effects` 描述结果。前两项按需填写。简单函数也可以用一句话写全承诺。这些标签是项目的注释约定，Go 工具会展示紧贴声明的文档。

ADT 是由一组操作及其行为定义的类型。它的公开规格分布在类型和各操作的注释里。类型注释定义值代表什么、怎样取得初始值，以及共用规则。课程按用途把操作分为创建、从已有值生成新值、观察和修改。各项操作的注释分别写清调用条件与效果。具体实现则在 `struct` 的字段旁记录三件事：

- *AF（抽象函数）*把一组合法字段值解释成一个抽象值。例如 `units = 2` 代表还可以领 2 件。
- *RI（表示不变式）*判断一组字段值是否合法。例如 `units >= 0`。
- *Safety from rep exposure（防止表示暴露）*说明外部代码如何接触字段以及能否改动同一份数据。若 API 允许共享，还要在相应操作说明改动和有效期。

创建新值的操作负责建立 RI，更新操作负责维持 RI。构造函数参数的限制和某类字段状态的限制可以数值相同，它们分别约束调用和表示。#link("https://web.mit.edu/6.102/www/sp26/classes/06-abstract-data-types/")[MIT 6.102 R06] · #link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#documenting_the_af_ri_and_safety_from_rep_exposure")[MIT 6.102 R07]

从仓库的发料台示例里摘出类型和一个方法，位置关系如下。完整样本的普通函数 `NewStock` 使用同样的函数规格布局。

```go
// Stock tracksthe number of units available at a supply desk.
// The zero value represents empty stock. Methods require a non-nil *Stock.
// Callers must serialize access to a shared Stock if any call can change it.
type Stock struct {
	// AF: units is the number of units available for withdrawal.
	// RI: units >= 0.
	// Safety from rep exposure: units is unexported and Remaining returns
	// an int by value. No operation gives callers access to the field itself.
	units int
}

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
func (s *Stock) Take(n int) bool {
	if n > s.units {
		return false
	}
	s.units -= n
	return true
}
```

假设库存为 2，申请领 3 件。它满足 `n > 0`，所以这是一次合法调用，`Effects` 承诺返回 `false` 并保留 2 件。 `units >= 0` 则是库存始终要维护的内部条件。这个例子分别展示了调用者负责的事、实现者承诺的行为和实现内部必须维持的状态。

本次删除了 `AGENTS.md` 里对答题方式、固定标题和问答归档格式的规定。项目实现、验证与源码规格仍按项目规则执行。本节按 `answer-note` 追加到今天。Typst 编译成功，已有 `Stock` 示例通过 `go test -count=1 ./examples/construction` 和 `go vet ./examples/construction`，`go doc ./examples/construction.Stock.Take` 显示了方法规格。


== Encode 的字节布局放在哪

放在 `Effects:` 下。总长度、端序、各段的范围和内容都是调用者可以逐字节核对的返回结果，因此都属于后置条件。先用一条 `Returns` 说明长度，再用独立的排版块列布局。用空的 `//` 行把缩进的布局和上方的引导句分开。

```go
// Encode returns the record's binary encoding for storage.
//
// Effects:
//   - Returns 8 + K + V bytes, where K and V are the key and value lengths in
//     bytes.
//
// The returned bytes have the layout below. Each range includes its start
// and excludes its end.
//
//	[0, 4)          K as a little-endian uint32
//	[4, 8)          V as a little-endian uint32
//	[8, 8+K)        Key bytes in order
//	[8+K, 8+K+V)    Value bytes in order
func (ent *Entry) Encode() []byte
```

用临时 Go 包核对了上述布局，`gofmt -d` 无输出，`go doc . Entry.Encode` 按预期显示返回值和对齐的字段表。


= Decode 规格写完后做什么

0102 现在从写规格进入核对测试。先在 `internal/db/kv_entry_test.go:18-19` 收尾 A1。给小端补上讲义第 153 行的出处，并记下讲义多出的字节是 0103 的删除标志，见第 161 行。

接下来做 A3。在测试上方第 24–34 行填写原有策略注释。看第 44 行说明解码开始时的记录状态，再读第 42、46、47 行，分别写出编码结果应匹配哪组字节、解码应返回什么错误值、解码后应得到什么记录。用现有测试的三个断言作为证据，这一步填写策略注释。

A3 做完后进入 A4，按规格实现 `Encode` 和 `Decode`，然后在项目根目录跑定点测试，再跑同包测试。

```bash
go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/
go test ./internal/db/
```

本次核对了当前规格、测试注释和题单。两个方法目前仍是声明，测试留到 A4 实现后运行。笔记已更新并编译。


== 从现有测试继续

直接进入测试和实现。此前把已经理解的字节格式出处当成了交付项。根据本次反馈，今后的验收聚焦会影响规格、测试预期或实现的判断。

核对 `TestEntryEncode` 的三条断言即可进入实现。它们分别验证编码是否匹配固定字节、解码是否成功，以及解码后是否得到预期记录。然后按规格写 `Encode` 和 `Decode`，先跑定点测试。

源码已移除追溯出处的练习提示，保留已有字节布局说明和测试函数。笔记已编译。
