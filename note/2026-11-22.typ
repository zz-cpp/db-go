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
  date: datetime(year: 2026, month: 11, day: 22),
  abstract: [按日记录项目学习和验证结果。],
  bibliography: none,
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= 0102 Decode 交卷检查

本步通过。仓库的 `TestEntryEncode` 函数体与 0102 starter 一致。本次定点运行确实执行并通过该用例，同包回归中的 `TestEntryEncode` 和 `TestKVBasic` 均通过。全仓 `go build ./...`、`go vet ./...` 和 `go test -count=1 ./...` 也通过。

`kv_entry.go:63-88` 先读满 8 字节头部，按小端解释两个长度，然后分别读满键和值。这个顺序符合 `Encode` 的字节布局。对每段使用 `io.ReadFull`，允许读取源分多次交付字节。先读到局部切片，直到两段成功才更新 `ent.key` 和 `ent.val`，因此中途返回读取错误时旧记录仍可用。标准库的 `encoding/binary.Read` 也先读满再写入目标值，可查 `/usr/lib/go/src/encoding/binary/binary.go:258`。

在临时 Go 包中复制当前实现做了五个检查。逐字节读取成功。头部、键和值分别截断时返回 `io.ErrUnexpectedEOF`，已有的键和值保持原样。两条记录相连时一次只读一条，并能在下一次调用读到第二条。这些是对当前实现的观察。原样例验收的是完整输入和解码结果。

小建议是把第 64 行的 `headLen` 改名为 `header`。它存的是头部字节。顺手可写成 `var header [8]byte`，读取时传 `header[:]`，让 8 字节的长度体现在类型里。

阶段末待确认的是读取损坏文件时如何处理声明的长度。第 73–74 行在读键和值前就按头部长度分配内存。当前代表性样例长度很小。如果将来支持损坏输入，先决定接受的记录大小，再考虑在分配前拒绝超出范围的长度。当前 0102 验收已通过。

格式检查无输出，针对 `kv_entry.go` 的 `git diff --check` 通过。评测结果保存在本日笔记。额外检查在临时目录运行。


= TestEntryEncode 的测试策略注释

按 MIT 6.102 R02 的测试策略格式，记录输入怎样划分，以及每个用例覆盖哪个子域。这里把课程的写法移到 Go 的测试函数上方，首句直接写测试目的。db-go 的 `Domain`、`Partition on` 和 `Coverage` 用来标识这三层信息。#link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[MIT 6.102 R02 · Documenting your testing strategy]

```go
// TestEntryEncode checks the 0102 record format in both directions.
//
// Domain: A complete 0102 record with a nonempty key and value, decoded into
// a zero-value Entry.
//
// Partition on key length versus value length:
//   - Key shorter than value.
//   - Key and value of equal length.
//   - Key longer than value.
//
// Coverage: Key shorter than value (2-byte key, 3-byte value). Encode must
// match the fixed little-endian bytes. Decode reads those fixed bytes and
// must return nil and recover the original key and value.
//
// TODO(阶段末): Revisit partitions for empty fields, truncation, and
// storage sharing once their behavior is specified.
```

`Domain` 写本组用例的输入范围和初始状态。`Partition on` 写选择代表值的理由。键和值的长度可以分成键较短、等长和键较长三类；等长的例子单靠长度无法发现两个长度字段被写反。`Coverage` 写现有用例实际选中的子域和预期。本例只覆盖键较短，键 2 字节、值 3 字节。编码的预期是固定小端字节。解码直接读这份固定字节，并检查错误值与最终记录。两边各自有独立的预期，因而能检出编码和解码同时采用相同错误格式的情形。

Go 标准库的 `encoding/binary` 也用一个固定字节样本核对两个方向。 `TestLittleEndianWrite` 把写出的字节与样本比较，`TestLittleEndianRead` 把样本交给读取函数。可核对 `/usr/lib/go/src/encoding/binary/binary_test.go:187-209`。

已把注释写进 `internal/db/kv_entry_test.go`，清掉填空提示。测试函数与 0102 starter 的同名函数一致。`gofmt -d` 无差异，定点测试 `TestEntryEncode` 和同包回归均通过。笔记已编译。


== 源码中的精简版本

把输入范围、划分和实际覆盖合在一段，再说明测试使用的固定字节和预期结果。字节布局由 `Encode` 的公开规格说明。阶段末待办保存在上面的评审记录中。

```go
// TestEntryEncode checks the 0102 record format in both directions.
//
// Testing strategy: For complete records with nonempty fields, classify the
// key as shorter than, equal in length to, or longer than the value. This
// case covers a 2-byte key and a 3-byte value.
//
// Encode must match the fixed little-endian bytes. Decoding those bytes into
// a zero-value Entry must return nil and recover the original key and value.
```

本次修改了测试注释。函数体与 0102 starter 一致。格式检查与 `TestEntryEncode` 定点测试通过。


= 0102 记录格式的完整测试组

在 `internal/db/kv_entry_test.go` 保留作者的 `TestEntryEncode`，增加按 6.102 R02 组织的 `TestEntryRecordFormat`。注释先写输入域、长度分区、边界和实际覆盖。每行测试数据命名一个场景，使用 `t.Run` 把编码和解码各自放进子测试。#link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[6.102 R02 · Documenting your testing strategy]

八个格式用例覆盖双方为空、仅键为空、仅值为空、双方非空时的三种长度关系，以及两种 255 与 256 字节的组合。长度跨过 255 时会用到头部的第二个长度字节。短键用例还包含 `0x00` 和 `0xff`，验证字段按原始字节保存。每行直接写出预期头部，与已知键值拼成固定样本。 `Encode` 对比该样本，`Decode` 读取同一样本并覆盖已有记录。空字段按字节内容比较，空切片和 `nil` 切片都表示零个字节。

另外两个测试分别检查完整输入按单字节到达时仍能解码，以及改写 `Encode` 的返回字节后原记录仍保持原样。后者来自 `Entry` 已有的独立副本说明。 `TODO(阶段末)` 跟踪截断时的错误与输入位置、超长记录的处理，以及解码数据的共享规则。

下面的命令会按场景列出 `Encode` 和 `Decode` 的结果。

```bash
go test -count=1 -v -run '^TestEntry' ./internal/db/
```

原作者测试的函数体与 0102 starter 一致。八组格式样本的 16 个子测试与两个专项测试均通过。全仓 `go test -count=1 ./...`、`go vet ./...`、`go build ./...` 通过。在临时覆盖文件中分别引入「长度字段只写一个字节」和「头部只读一次」两种错误。作者样例仍通过，而新增的 256 字节编码用例和逐字节读取用例分别捕获了对应错误。


== 为什么出现 Domain 标签

6.102 R02 的示例在 Testing strategy 下列出分区和子域，再在各用例名里标明覆盖的类别。它的示例没有单独的 `Domain:` 标签。该标签来自仓库 `docs/go-construction-templates.md` 的扩展模板，我把它带进了要求按课程风格呈现的测试注释。#link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[6.102 R02 原例]

已把 `TestEntryRecordFormat` 的输入范围合进 `Partition complete 0102 records by key and value lengths`，用正文简述边界与解码初始状态。定点用例重新运行通过。

== 在 LazyVim 里按当前 Go 声明生成规格

在 Go 文件中按空格、`c`、`g` 打开 `Go specs`。光标可以放在声明或函数体内。接下来的一个键决定写入位置。

- `f` 生成函数或方法的 Go 文档注释，首句以名称开头，接着用 `require:` 和 `effects:` 写调用条件与可观察结果。
- `a` 生成类型说明。结构体的 `Rep invariant:`、`Abstraction function:` 和 `Safety from rep exposure:` 写在字段旁。
- `t` 为光标所在的 Go 测试生成 `Testing strategy`，放在函数体开头。分区根据当前测试表、子测试与断言归纳。

生成时，本机 Codex CLI 会把当前 Go 缓冲区（含未保存的修改）交给配置的模型。结果写回缓冲区，可以先阅读，再保存，也可以用 `u` 撤销。如果等待期间编辑了文件，再按一次快捷键即可用新的内容生成。

`internal/db/kv_entry_test.go` 中的 `TestEntryRecordFormat` 是可运行的例子。键的空与非空、值的空与非空组成四种组合，策略将它们列为笛卡尔积。键值长度关系、255 与 256 的边界按子域覆盖。表格里的每行都有一个以 `covers` 开头的场景名。运行 `go test -v -run TestEntryRecordFormat ./internal/db`，输出会在每个场景下分别列出 `Encode` 与 `Decode`。

== 本次操作与当前状态

在 `~/.config/nvim/after/ftplugin/go.lua` 注册 Go 专用菜单，在 `~/.config/nvim/lua/config/go_specs.lua` 实现生成器，并同步更新项目测试策略模板。用临时 Go 文件通过三个快捷键生成了实际注释，另行检查了菜单名称、重复生成和编辑期间返回旧结果的情形。项目已通过 `go test -count=1 ./...`、`go vet ./...` 和 `go build ./...`。重新打开 Neovim 即可使用。
