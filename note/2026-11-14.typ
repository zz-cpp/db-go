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
  title: [数学与 CS 问答笔记],
  authors: ("answer-note",),
  date: datetime.today(),
  abstract: [按日归档的问答笔记：三问反思法（关键点/变式/同类归类）+ 讲课叙事流 + CeTZ 图示，结构与课程笔记同构。],
  bibliography: none,
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= `kv_entry.go` 的 `Entry` 是 ADT 吗（Is Entry an ADT?）

// 轨道：CS 轨

== 费曼直觉

先给结论：

#importantbox[
`Entry` *有 ADT 的外壳，但按 6.102 R06 / 6.031 R10 的判据还不是一个完整的 ADT*。
它把表示（`key` 和 `val`）藏在包外，却只暴露 `Encode` 和 `Decode` 两个操作：
没有构造器、没有能读回 key/val 的观察器、没有写 AF/RI 和错误语义。
对包外客户端，它是一台只能「字节进、字节出」的机器；对同包的日志层，它只是一个内部记录。
]

打个比方：ADT 像一台自动售货机。你不需要知道里面怎么摆货（表示），
只通过投币、选货、取货（操作）来使用；机器自己保证「选货前必须投币」（表示不变式）。
`Entry` 现在像一台只有两个按钮的机器：一个把内部状态打印成字节，一个从字节流恢复内部状态；
没有投币口（构造器），也没有显示屏（观察器）。它能用，但只能完成「字节与对象互转」这一件事。

这个问题的价值不在「贴标签」，而在判断*下一步该不该补操作*。0102 现在只要求编码格式，
所以「不完整」不是错误；但如果 0103 的日志层需要读 key/val，这个缺口就会变成设计决策。

== 硬核机制

=== 课程判据：ADT 由操作与契约定义

6.102 R06 与 6.031 R10 对 ADT（抽象数据类型，abstract data type）的定义大意是：
一个类型由*一组操作*以及这些操作的*规格（契约）*刻画；客户端只需要知道抽象值能做什么，
不需要知道它在内存里怎么表示。

把它拆成四条可检查的判据：

+ *表示独立*（representation independence）：实现的表示改变后，客户端代码不需要改；
+ *操作可分类*：creators、producers、observers、mutators 四类，且对客户端够用；
+ *每个操作有规格*：前置条件、后置条件、错误语义，客户端只读规格就能用；
+ *不变量由实现维持*：客户端不需要、也不能检查表示是否合法。

四个操作术语各给一句话定义：

+ *creator*：从无到有造出抽象值，例如 `bytes.NewBuffer`；
+ *producer*：从旧抽象值造出新抽象值，例如 `time.Time.Add`；
+ *observer*：观察抽象值但不改变它，例如 `bytes.Buffer.Len`；
+ *mutator*：改变抽象值，例如 `bytes.Buffer.Write`。

还有两个配套概念：

+ *AF*（abstraction function，抽象函数）：把内存表示映射成抽象值；
+ *RI*（representation invariant，表示不变式）：哪些内存表示是合法的。

=== 先看 Entry 对包外暴露了什么

`kv_entry.go` 目前的全部内容：

#codelisting(
  "type Entry struct {\n    key []byte\n    val []byte\n}\n\nfunc (ent *Entry) Encode() []byte\n\nfunc (ent *Entry) Decode(r io.Reader) error",
  lang: "go",
  caption: [`kv_entry.go`：两个未导出字段，两个导出方法，没有 doc comment],
)

`go doc` 是看「包外客户端视角」最快的工具，它的输出比读源码更接近客户端看到的东西：

#codelisting(
  "$ go doc -all ./internal/db\ntype Entry struct {\n    // Has unexported fields.\n}\n\nfunc (ent *Entry) Decode(r io.Reader) error\n\nfunc (ent *Entry) Encode() []byte",
  lang: "text",
  caption: [`go doc` 只列导出标识符；`Entry` 的字段全部不可见],
)

这条输出同时说明两件事：包外确实看不到 `key` 和 `val`（表示隐藏）；
但包外能用的操作也只剩 `Encode` 和 `Decode`（操作集很薄）。

=== 四条判据逐条对照

#booktabs-table(
  columns: (1.2fr, 1.7fr, 2.1fr),
  [*判据*], [*Entry 的现状*], [*合格 ADT 的要求*],
  [表示独立], [包外通过：字段未导出；包内不成立], [对所有客户端都隐藏表示],
  [操作完整], [只有 `Encode` 与 `Decode`], [按需具备 creator、producer、observer、mutator],
  [契约], [没有 doc comment，没有错误语义], [每个方法有前置条件、后置条件、错误],
  [AF 与 RI], [没有写], [AF 是全函数，RI 可检查],
)

*第一，表示独立：只在包边界上成立。*

Go 的封装边界是*包*，不是*类型*。包外写 `e.key` 编译不过；
但 `package db` 里的任何文件（包括 `kv_entry_test.go`）都能直接读写这两个字段。
所以「表示隐藏」对包外为真，对包内为假。这与 Java 的 `private` 不同：
Java 的 `private` 是类级可见性，Go 的未导出标识符是包级可见性。
课程材料默认 Java/TypeScript 的类边界；在 Go 里要把它翻译成「包边界」。

*第二，操作不完整。*

+ 没有 creator：包外无法从一对 key/val 造出非空 `Entry`，只能先 `var e Entry` 再 `Decode`；
+ 没有观察器：包外拿不到 `key` 和 `val`，只能把整个对象再 `Encode` 回字节；
+ `Decode` 是 mutator（它修改 receiver 的抽象值），对零值 receiver 才兼作 creator；
+ `Encode` 是 observer（返回基于抽象值的信息），它观察的是「编码后的字节」，不是 key/val 本身；
+ 没有 producer（没有「从旧 Entry 派生新 Entry」的操作）。

*第三，契约缺失。*

6.031 有一句话：ADT 的规格就是它的方法契约。现在两个方法都没有 doc comment：

+ `Encode` 没有 `error`：编码真的不会失败吗？长度超过 `math.MaxUint32` 怎么办？
+ `Decode` 失败后 receiver 保持原状，还是被写了一半？
+ `Decode` 失败后 reader 消费到哪里？调用方还能继续读吗？
+ receiver 为 nil 时能不能调用？

这些不是实现细节，而是客户端必须知道的合同。没有写，就只剩签名。

*第四，AF 与 RI 没有文档化。*

`Entry` 的抽象值可以写成一对字节串，但文件里没有任何注释说明。
这带来两个后果：实现者不知道哪些表示是合法的；评审者也看不出编码格式和表示的区别。

#importantbox[
当前最自然的写法是：AF 把表示映射成一对字节串，RI 暂时为真（任何 key/val 都合法），
而 0102 的 8 字节头格式属于 `Encode` 的后置条件，不属于 RI。这个区分是本题最容易混的地方。
]

=== 关键区分：编码格式不是 rep，而是抽象值的外部契约

学生常见的写法是把编码格式写进 RI：「编码必须是 8 字节头 + 数据」。这是错的。

+ *RI 约束的是内存表示*：`key` 和 `val` 两个切片怎么摆、能不能为 nil、长度是否一致；
+ *编码格式是 `Encode` 的后置条件*：客户端（日志文件、逐字节测试）依赖它，所以它是规格的一部分。

用三行注释写清它们的关系：

#codelisting(
  "Abstraction function:\n    AF(ent) = (ent.key, ent.val)\nRep invariant:\n    true\n    （若规定 key 非空，则改为 len(ent.key) >= 1）\nEncode 的后置条件:\n    前 4 字节为 key 长度（little-endian uint32），接着 4 字节为 val 长度，\n    随后是 key 数据与 val 数据",
  lang: "text",
  caption: [AF、RI 与编码契约各归各的位置],
)

这个区分有实际后果：把 `key` 和 `val` 合成一个 `data []byte` 是*改表示*，编码格式可以不变；
把 little-endian 改成 big-endian 是*改契约*，不是重构，测试必须跟着变。

=== 真正的判据：客户端是谁

ADT 的性质是相对于客户端边界说的，不是绝对的。同一个 `Entry`，对不同客户端有不同身份：

#booktabs-table(
  columns: (1.4fr, 1.8fr, 1.8fr),
  [*客户端*], [*能看到什么*], [*Entry 对它是 ADT 吗*],
  [包外代码], [只有 `Encode` 与 `Decode`；不能构造，也不能读字段], [形式上是（表示隐藏），但操作集只够字节往返],
  [同包日志层（0103）], [直接读写 `key` 与 `val`], [不是：它就是内部记录],
  [同包测试], [直接写 `Entry{key: ..., val: ...}`], [不是：测试依赖表示，属于白盒],
)

这张表解释了一个常见困惑：既然「ADT 应该隐藏表示」，为什么 `kv_entry_test.go` 可以写
`Entry{key: ..., val: ...}`？因为 Go 的封装边界是包，测试和实现同包，测试天然是白盒。
课程把测试看成实现者的工具，测试了解表示是正常的；表示独立约束的是*生产客户端*，不是测试。

#warningbox[
不要把「测试能构造 `Entry`」当成「表示没藏好」。真正的表示暴露是*导出字段*，
或者*把内部切片/指针交给客户端*。前者你现在没有；后者取决于 `Encode` 的实现。
]

=== 一个可执行的判据：能不能写黑盒测试

6.031 的表示独立有一个很实用的检验：把测试包换成 `package db_test`，只依赖导出 API。

+ 能写：`var e db.Entry`，然后 `e.Decode(reader)`，再比较 `e.Encode()` 的字节；
+ 不能写：构造「key 非空、val 为空」的输入（除非手写字节流），也不能断言 key/val 的内容；
+ 不能写：`db.Entry{key: ...}`，因为字段在包外不可见。

所以黑盒测试能覆盖「编码往返」，覆盖不了「抽象值的内容」。
这不是测试技巧问题，而是操作集不完整的直接证据：客户端没有足够的操作去*观察*抽象值。

#knowledgebox[
ADT 的操作集不需要「暴露所有字段」，但必须让客户端能完成它的规格所承诺的事。
如果 `Entry` 的唯一承诺就是「能把一条记录编码再解回来」，那么 `Encode` 与 `Decode` 已经够了，
它就是一个*受限但自洽*的序列化 ADT；如果承诺还包括「读日志时能拿到 key/val」，
那就必须补观察器。判据是承诺，不是方法数量。
]

=== 真实项目样本：同一问题的四条路线

`Entry` 不是孤例。标准库对「藏不藏表示、藏到什么程度」有四种做法，正好构成一条光谱：

*（1）完整 ADT：`bytes.Buffer`*

#codelisting(
  "type Buffer struct {\n    buf      []byte\n    off      int\n    lastRead readOp\n}\n\nfunc (b *Buffer) Bytes() []byte { return b.buf[b.off:] }",
  lang: "go",
  caption: [`/usr/lib/go/src/bytes/buffer.go:20-30` 与 `:55-60`：字段全未导出，操作四类齐全],
)

`Buffer` 有 creator（`NewBuffer`）、mutator（`Write`、`Read`）、observer（`Len`、`Bytes`）、
producer（`Clone` 一类），AF/RI 用注释写清。
更值得注意的是 `Bytes` 的文档：它明确说返回的切片在下次修改前有效，并且与内部缓冲共享内存。
这是*受控暴露*：把别名规则写进契约，而不是假装没有别名。
对照 `Entry`：如果 `Encode` 返回的切片与 `key` 共享底层数组，就必须做同样的声明。

*（2）不可变 ADT：`time.Time`*

#codelisting(
  "type Time struct {\n    wall uint64\n    ext  int64\n    loc  *Location\n}\n\nfunc Date(year int, month Month, day, hour, min, sec, nsec int, loc *Location) Time\nfunc (t Time) Add(d Duration) Time\nfunc (t Time) Year() int",
  lang: "go",
  caption: [`/usr/lib/go/src/time/time.go:140`：字段未导出，没有 mutator，`Add` 是 producer],
)

客户端只能用 `Date` 或 `Now` 构造、用 `Year` 或 `Format` 观察、用 `Add` 派生新值。
没有 `SetYear` 之类的 mutator。这表明 ADT 不一定可变；`Entry` 因为有 `Decode`，属于可变类型。

*（3）不是 ADT：`net/http.Request`*

#codelisting(
  "type Request struct {\n    Method string\n    URL    *url.URL\n    Proto  string\n}",
  lang: "go",
  caption: [`/usr/lib/go/src/net/http/request.go:114`：字段全部导出，是透明记录],
)

这是有意的设计：用户要构造请求，JSON 解码器要填字段，框架要读字段。
透明记录适合「数据载体」；ADT 适合「有不变量的行为」。`Request` 不是 ADT，但它是好用的类型。
这反过来说明：*字段导出不等于设计错误*，要看类型承担的是「数据」还是「行为」。

*（4）最严格：`hash/crc32` 的 `digest`*

#codelisting(
  "type digest struct {\n    crc uint32\n    tab *Table\n}\n\nfunc New(tab *Table) hash.Hash32",
  lang: "go",
  caption: [`/usr/lib/go/src/hash/crc32/crc32.go:136`：类型本身不导出，客户端只拿到接口],
)

连类型名都看不见，客户端只能通过 `New` 得到 `hash.Hash32` 接口，再调 `Write` 和 `Sum32`。
这是「表示独立」最强的形态：客户端甚至不知道具体类型是什么。

对照之下，`Entry` 处在第 1 和第 2 之间：字段藏了，操作集却没补齐。
它不是错误，而是「还没决定要做成哪一类」。

=== 如果要做成完整 ADT，缺什么

两条合法路线，取决于 0103 的真实需要：

#booktabs-table(
  columns: (1.2fr, 1.9fr, 1.5fr, 1.6fr),
  [*路线*], [*做法*], [*代价*], [*什么时候选*],
  [包内记录], [改成未导出 `entry`，只给日志层用], [外部无法复用；测试仍同包], [0103 的日志层是唯一客户],
  [对外 ADT], [补 `NewEntry`、`Key`/`Val`、AF/RI、`Encode` 的 error], [多写规格与防御性拷贝], [外部要读日志或做工具],
)

我的建议：0102 先走「包内记录 + 最小契约」——保持现有签名，但补上 AF/RI 和 `Decode` 的失败语义；
等 0103 真的出现第二个客户端，再决定是否补观察器。不要为了「看起来像 ADT」提前加方法，
那是 L1 阶段冻结的扩展。

== 陷阱与易错

#warningbox[
*误概念一：字段未导出就是 ADT。* 字段隐藏只是表示独立的必要条件。
没有构造器和观察器，客户端根本用不了抽象值。对照 `http.Request`：字段全导出，
但它有完整操作，仍然是一个好用的类型，只是它不是 ADT。
]

#warningbox[
*误概念二：测试同包就是表示暴露。* Go 的封装边界是包；同包测试能看 rep 是语言事实，
课程也允许白盒测试。真正的暴露路径是导出字段、返回内部切片、把内部指针交给客户端。
]

#warningbox[
*误概念三：把编码格式写进 RI。* RI 管内存表示，编码格式是 `Encode` 的后置条件。
混在一起，改表示时会误以为破坏了不变量，改格式时又以为只是重构。
]

#warningbox[
*误概念四：`Decode` 是纯构造器。* 它修改 receiver，是 mutator；对零值 receiver 才兼作 creator。
receiver 已有值时，失败后是否保持原状，必须写进规格。
]

#warningbox[
*误概念五：`Encode` 返回 `[]byte` 就等于安全。* 如果返回值与 `ent.key` 共享底层数组，
客户端改返回值就改了 rep。要么新分配，要么像 `bytes.Buffer.Bytes` 那样把别名规则写进文档。
]

== 关键点

#importantbox[
`Entry` 对*包外*是一个「不完整的 ADT」：表示藏住了，但只有 `Encode` 与 `Decode`，
缺构造器、观察器和契约；对*同包的日志层*它只是内部记录。
判断 ADT 不要看有没有 struct、方法或未导出字段，要看客户端能否只靠操作与规格使用抽象值。
]

#booktabs-table(
  columns: (1.2fr, 1.8fr, 2fr),
  [*问题*], [*答案*], [*依据*],
  [是 ADT 吗], [形式上有外壳，判据上不完整], [四条判据逐条对照],
  [为什么字段藏了还不够], [操作集不完整，客户端无法观察抽象值], [黑盒测试写不出来],
  [那它是什么], [包内记录，对外是受限的序列化类型], [客户端是 0103 日志层],
  [下一步], [先补 AF/RI 与失败语义，不急着加方法], [0102 的承诺只有编码往返],
)

== 变式检验

*变式 1：加一个 `func NewEntry(key, val []byte) *Entry`，它就是 ADT 了吗？*

还不够。构造器只补了 creator；还需要观察器（`Key` 与 `Val`）和契约，
否则客户端依然只能编码，不能读取。操作集的完整性是按承诺判的，不是按方法数量判的。

*变式 2：把 `Encode` 改成 `MarshalBinary() ([]byte, error)`，
`Decode` 改成 `UnmarshalBinary([]byte) error`，有什么变化？*

它就成了标准库 `encoding.BinaryMarshaler` 与 `BinaryUnmarshaler` 的实现：
契约由标准接口规定（出错要返回 error，返回的字节不能与内部状态共享），
操作集从自定义方法变成协议。代价是参数从 `io.Reader` 变成 `[]byte`，
0103 的流式读取要自己缓冲。这是「复用标准契约」与「保持流式接口」的取舍。

*变式 3：如果把 `key` 和 `val` 合成一个 `data []byte`，AF 与 RI 怎么变？*

AF 要从 `data` 里切出两段（先读长度头），RI 要保证长度头与数据一致、总长度够。
这是更强的 RI，也更像 0103 的日志记录。编码格式不变，只是表示变了——
这正是表示独立要保护的东西：客户端代码不因这次重构而改。

*变式 4：如果 `KV` 也像 `Entry` 一样只有 `Encode` 与 `Decode`，`KV` 还是 ADT 吗？*

不是。`KV` 的抽象值是键值映射，它必须有 `Get`、`Set`、`Del` 这些操作才能被使用；
`Encode` 与 `Decode` 只是它的持久化表示。这反过来说明：`Entry` 的抽象值太薄
（就是一对字节串），薄到「只有序列化」也能近似完整。

*变式 5：用 `package db_test` 写黑盒测试，能测什么、不能测什么？*

能测：`Decode` 后 `Encode` 的字节等于输入；错误输入返回 error。
不能测：key 和 val 的内容；也无法从 key/val 直接构造输入。
这就是操作集不完整的可执行证据，也是判断「要不要补观察器」的起点。

== 同类归类

#booktabs-table(
  columns: (1.3fr, 1.8fr, 2.1fr),
  [*概念*], [*本项目落点*], [*关键差别*],
  [ADT], [`Entry` 与 `KV`], [`KV` 有完整操作与 AF/RI；`Entry` 只有序列化外壳],
  [表示独立], [`Entry` 的未导出字段], [只对包外成立，同包可见],
  [AF 与 RI], [`KV` 的注释与 `Entry` 的空白], [`KV` 写了 AF/RI（还有 TODO）；`Entry` 没有],
  [表示暴露], [`Encode` 的返回值], [是否与 `key`、`val` 共享底层数组，待实现决定],
  [值对象], [`Entry`], [靠值相等；`assert.Equal` 比较的是结构体表示],
)

6.031 对照：R10 讲 ADT 的操作分类与表示独立，R11 讲 AF/RI 与表示暴露；
6.102 对应 R06 与 R07。本题落在「ADT 的判定」，不是「实现一个新的 ADT」，
所以只做分类与契约判断，不写实现代码。

== Go 语言机制补充

*可见性规则。* Go 没有 `private`；标识符首字母大写表示导出（包外可见），小写表示包内可见。
`go doc` 只列导出标识符；对 `Entry` 它显示 `Has unexported fields`，这就是包外看不见字段的文档证据。
`internal/` 目录控制的是*包能不能被导入*，不是字段可见性，两者不要混。

*同包测试。* `kv_entry_test.go` 声明 `package db`，所以它能写 `Entry{key: ..., val: ...}`。
这是 Go 的惯例，标准库大量如此；代价是测试与表示耦合，改字段名测试就编译失败。
若想强制黑盒，把测试包改成 `db_test`，但那样就无法构造非空 `Entry`——这正好暴露操作集不完整。

*`assert.Equal` 与未导出字段。* testify 的 `assert.Equal` 对 `[]byte` 用 `bytes.Equal`，
其余类型最终用 `reflect.DeepEqual`。`Entry` 是结构体，所以它比较的是*表示*，不是抽象值。
如果以后给 `Entry` 增加一个缓存字段，这条断言会失败，即使编码行为没变。

*指针 receiver 与可变性。* `Encode` 与 `Decode` 都用 `*Entry`。`Entry` 是可变类型（`Decode` 改字段）；
结构体赋值是浅拷贝，两个 `Entry` 会共享 `key` 与 `val` 的底层数组。
要么在构造与返回处拷贝，要么在文档里写清所有权。

*标准接口对照。*

#codelisting(
  "type BinaryMarshaler interface {\n    MarshalBinary() (data []byte, err error)\n}\n\ntype BinaryUnmarshaler interface {\n    UnmarshalBinary(data []byte) error\n}",
  lang: "go",
  caption: [`/usr/lib/go/src/encoding/encoding.go`：标准库的序列化契约],
)

`Entry` 现在的 `Encode() []byte` 不满足 `MarshalBinary() ([]byte, error)`（少 error），
`Decode(io.Reader)` 不满足 `UnmarshalBinary([]byte) error`（参数类型不同）。
所以它不是标准意义上的序列化 ADT，只是项目自定义的流式编解码。

*`go doc` 的用法。* `go doc -all ./internal/db` 列出包的全部导出 API；
不写 `-all` 只看顶层。看一个类型「对外是什么」时，`go doc` 比读源码更接近客户端视角。

== 动手：spec 框架（你来填）

本轮只加*骨架*，核心内容全部留成 `TODO(user)`；这是项目「规格、测试、实现至少由你写一项」的落点。
改动只有一个文件：`internal/db/kv_entry.go`。

=== 加了什么

#booktabs-table(
  columns: (1.5fr, 1.6fr, 2.1fr),
  [*位置*], [*骨架*], [*你要填的内容*],
  [类型注释], [`Abstraction function`], [一条把 `key` 与 `val` 映射到抽象值的公式],
  [类型注释], [`Rep invariant`], [可判定的谓词：nil 与空值是否合法、长度上限],
  [类型注释], [`Safety from rep exposure`], [逐条列出客户端能碰到 rep 的路径与封堵方式],
  [方法注释], [`Encode` 的 Pre/Post/Errors], [字节格式、端序、返回值所有权、能否失败],
  [方法注释], [`Decode` 的 Pre/Post/Errors], [成功后的字段、失败是否原子、reader 位置、错误值],
)

=== 建议的填写顺序

+ *先定 RI*：空 key 与空 val 合不合法？`nil` 与 `len == 0` 算不算同一种？长度上限（uint32）？
  这三问决定后面所有测试的边界。
+ *再定 AF*：客户端认为一个 `Entry` 是什么？用一句话写成一个映射。
+ *再写 `Encode` 的后置条件*：字节布局、端序、空值情形、返回切片与 `ent.key` 是否共享。
+ *再写 `Decode` 的失败语义*：失败后 `ent` 保持不变（原子）、被写一半、还是未定义？三选一。
+ *最后写 rep exposure*：`Encode` 的返回值、`Decode` 的读入缓冲、结构体浅拷贝，逐条封堵。

#importantbox[
不要先写实现再补 spec。spec 是你判断「实现对不对」的唯一依据：先写 RI 与后置条件，
再让测试去卡它们；否则测试只能验证「代码和代码自己一致」。
]

=== 每处要回答的判别问题

#booktabs-table(
  columns: (1.3fr, 2.4fr),
  [*位置*], [*判别问题*],
  [RI], [`nil` key 与 `len(key) == 0` 的行为要不要区分？长度超过 `math.MaxUint32` 算非法表示还是前置条件？],
  [AF], [AF 是不是全函数？每个合法表示都有抽象值吗？],
  [Encode 后置], [返回的 `[]byte` 归谁？调用方修改它会不会改到 `ent`？],
  [Encode 错误], [签名没有 `error`：你是在规格里写「不会失败」，还是改签名？],
  [Decode 原子性], [失败后 `ent` 原状、半成品、还是未定义？选一个并让测试锁定它],
  [Decode reader], [失败后 reader 消费到哪里？调用方还能继续读吗？],
  [Decode 错误值], [`io.EOF` 与 `io.ErrUnexpectedEOF` 分别表示什么？要不要包装？],
)

=== 与当前测试的对应

现有 `kv_entry_test.go` 只覆盖 `key = k1`、`val = xxx` 的逐字节编码与一次往返；
空 key、空 val、短头、短数据、分块读都还没有测试。
所以你的 RI 选择会直接决定下一批测试：如果 RI 允许空 key，就必须补空 key 的编码测试；
如果 RI 禁止，就要在 `Encode` 的前置条件里写清「调用者责任」。

#warningbox[
*规格强度跟随测试。* 测试没明确的维度，先不要写成强断言；用 `TODO(阶段末)` 标记，
等 0102 整体完成后再决定是否加强。不要把「未来可能需要的契约」现在写成硬性规格。
]

=== 验收判据

填完后逐条自查：

+ `grep -n TODO internal/db/kv_entry.go` 只剩你*有意*保留的阶段末 TODO；
+ `go doc -all ./internal/db` 能读出一段完整的规格，而不是一串问句；
+ `gofmt -l internal/db/kv_entry.go` 无输出；
+ 每一条测试都能指向规格里的一行（前置条件、后置条件或错误）；
+ `go test` 从编译红变成断言红，且失败信息能看出是哪条契约没满足。

== 本次操作与当前状态

*已做的文件操作*：

+ 读取 `note/2026-11-13.typ` 的 0102 节（TDD：Encode 与 Decode），确认昨天停在「写第一条测试 + 补最小桩」；
+ 读取 `internal/db/kv_entry.go`、`kv_entry_test.go`、`kv.go`、`kv_test.go`；
+ 读取 `db-web/docs/ch01-storage-basics.md` 的 0102 节（格式、长度前缀、`io.Reader`）；
+ 读取标准库样本：`/usr/lib/go/src/bytes/buffer.go`、`/usr/lib/go/src/time/time.go`、
  `/usr/lib/go/src/net/http/request.go`、`/usr/lib/go/src/hash/crc32/crc32.go`；
+ 新建 `note/2026-11-14.typ`（本文件）；
+ 修改 `internal/db/kv_entry.go`：加入 `Entry` 的 AF/RI/rep exposure 与 `Encode`/`Decode` 的规格骨架，
  核心内容全部留 `TODO(user)`，未改实现、未改测试。

*验证结果*：

#codelisting(
  "$ go test ./internal/db/ -run TestEntry -count=1\n# github.com/zz-cpp/db-go/internal/db [github.com/zz-cpp/db-go/internal/db.test]\ninternal/db/kv_entry.go:64:6: missing function body\ninternal/db/kv_entry.go:93:6: missing function body\nFAIL\tgithub.com/zz-cpp/db-go/internal/db [build failed]\nFAIL",
  lang: "text",
  caption: [当前仍是编译红：骨架缺函数体],
)

+ `go test ./internal/db/ -run TestEntry -count=1`：`FAIL [build failed]`，两处 `missing function body`
  （*加注释不改变红基线，这是预期*）；
+ `go vet ./internal/db/`：*无输出、退出码 0*——这是假绿，vet 不检查函数体缺失，不能替代 `go test`；
+ `go doc -all ./internal/db`：能读出 `Entry` 的 AF/RI/rep exposure 骨架与两个方法的规格骨架；
+ `gofmt -l internal/db/kv_entry.go`：无输出；
+ `go build ./...`：同样因 `missing function body` 失败；
+ `XDG_CACHE_HOME=/home/zz/.cache typst compile 2026-11-14.typ`：成功生成 `2026-11-14.pdf`，
  只有 `iosevka` 字体缺失警告（主题的代码字体，不影响正文与表格）；

*需要你自己动手的*：

+ 按 `== 动手：spec 框架` 的五步顺序，把 `kv_entry.go` 里的 `TODO(user)` 填成你的规格；
+ 每填一处，用 `go doc -all ./internal/db` 读一遍，确认它读起来像合同而不是问句；
+ 填完先不要动实现：把 `kv_entry_test.go` 的第一条测试补成能跑的断言红；
+ 回答判别题：0103 的日志层要拿 key/val，走同包字段访问还是要求 `Entry` 提供 `Key` 与 `Val`？

= AF/RI 的统一书写格式（A Uniform Template for AF/RI）

// 轨道：CS 轨

== 费曼直觉

写 AF/RI 的纠结，通常来自一个错误假设：以为它们只有一种「正确文体」。
其实三件东西的任务不同：

+ AF 回答「这个表示代表什么抽象值」——它是一条*映射规则*；
+ RI 回答「哪些表示是合法的」——它是一条*可判定的谓词*；
+ rep exposure 回答「客户端能不能绕过操作改到表示」——它是一张*路径清单*。

所以统一格式不是「全数学」或「全文字」，而是*固定三段结构，每段固定文体*：
AF 一行映射，RI 一列谓词，rep exposure 一张路径表。
形式服务于检查：能被 `checkRep` 或测试检查的，才算 RI；不能检查的，写成文字契约。

#importantbox[
默认格式：AF 用「数学主体 + 文字修饰」一行；RI 每行一个可编译谓词；
rep exposure 每条路径一行。30 秒内决定不了形式，就用这个默认值，不要继续纠结。
]

== 硬核机制

=== 先分工：三种东西不要混

#booktabs-table(
  columns: (1.5fr, 1.8fr, 2.2fr),
  [*部分*], [*回答的问题*], [*合格形式*],
  [AF], [表示到抽象值的映射], [一行 `AF(r) = ...`，合法 rep 都有定义],
  [RI], [哪些表示合法], [谓词清单，每条能翻译成代码],
  [Safety from rep exposure], [客户端能否绕过操作改 rep], [路径清单，每条写封堵方式],
  [Contract / 使用约束], [不能检查的约束（严格弱序、并发协议）], [文字，明确标注不可检查],
)

=== 统一模板（直接复制）

#codelisting(
  "//\tAbstraction function:\n//\t\tAF(r) = <一行：右侧是抽象值；每个满足 RI 的 r 都有定义>\n//\n//\tRep invariant:\n//\t\tRI(r) = <谓词 1>\n//\t\t     && <谓词 2>\n//\t\t（每条都能被 checkRep 检查）\n//\n//\tSafety from rep exposure:\n//\t\t- <路径 1>：<是否共享>；<如何防>\n//\t\t- <路径 2>：<是否共享>；<如何防>\n//\n//\tRI 维护:\n//\t\t<构造器/变值器> 在 <何时> 建立或恢复 RI；observer 不修改 rep。",
  lang: "text",
  caption: [四段式模板：AF 一行、RI 谓词清单、Safety 路径表、RI 维护说明],
)

四段的分工：

+ AF 一行：写不出来就说明抽象值没选好；
+ RI 1–3 行：每行一个 `&&`；超过 3 行就把约束拆成命名谓词；
+ Safety 1–3 行：路径 = 导出字段、返回切片/指针、保存参数、全局变量、闭包；
+ RI 维护：谁在什么时候保证 RI（构造器建立、mutator 恢复、observer 不动）。

=== 形式决策树：数学还是文字

按顺序问三个问题：

+ *抽象值是数学对象吗？*（集合、映射、序列、元组、数值）
  是，AF 用数学主体；RI 用谓词。
+ *抽象值是状态、资源或文本吗？*（连接、事务、解析结果）
  是，AF 用一句自然语言加状态表；RI 仍然用「状态属于允许集合」加转移表。
+ *约束能写成运行时检查吗？*
  能，放进 RI；不能，放进 `Contract`，并写明「不可检查，靠测试或证明」。

#booktabs-table(
  columns: (1.2fr, 1.9fr, 1.9fr, 1.4fr),
  [*抽象值*], [*AF 写法*], [*RI 写法*], [*例子*],
  [集合/映射], [`AF(m) = { k -> m[k] | k ∈ dom(m) }`], [键/值约束加一致性谓词], [KV、Cache],
  [序列], [依次排列第 0 到第 n−1 个元素], [长度、游标范围、非 nil], [Stack、Buffer],
  [元组/数值], [`AF(r) = 分子/分母`], [规范化：分母大于 0、最简分数], [RatNum、Time],
  [状态/资源], [一句自然语言加状态表], [状态属于集合加转移表], [Conn、Tx、Rows],
  [文本/协议], [一句自然语言], [格式谓词加文字契约], [Parser、Entry],
)

关键技巧：*数学主体 + 文字修饰*。
例如 `AF(t) = 自 1970-01-01 UTC 起经过的秒数（含小数）`：
主体是数值，修饰说明单位和语义。纯数学写不清语义，纯文字写不清结构；
混合式不是妥协，而是默认。

=== 四种常见类型的完整模板

*（1）映射型：KV、Cache*

#codelisting(
  "AF(mem) = { k -> mem[k] | k ∈ dom(mem) }\nRI(mem) = (∀ k ∈ dom(mem): len(k) >= 1)\n       && (∀ k ∈ dom(mem): mem[k] != nil)\nSafety: mem 未导出；Get 返回拷贝；Set 保存拷贝。",
  lang: "text",
  caption: [映射型：AF 是集合映射，RI 是键值谓词，Safety 指出入向拷贝],
)

*（2）序列型：Stack、Buffer、Entry*

#codelisting(
  "AF(s) = 依次排列 s.data[0] 到 s.data[len(s.data)-1] 的序列\nRI(s) = s.data != nil\n     && 0 <= s.size && s.size <= len(s.data)\nSafety: data 未导出；Snapshot 返回拷贝；Push 不保存调用方切片。",
  lang: "text",
  caption: [序列型：AF 是序列，RI 管长度与游标范围],
)

*（3）不可变值型：Time、RatNum*

#codelisting(
  "AF(r) = r.num / r.den（最简有理数）\nRI(r) = r.den > 0\n     && gcd(abs(r.num), r.den) == 1\n     && (r.num != 0 || r.den == 1)\nSafety: 字段未导出且不可变；构造器返回新值；不暴露内部切片。",
  lang: "text",
  caption: [不可变值型：AF 是数学值，RI 是规范化条件],
)

*（4）状态机型：Conn、Tx、Rows*

#codelisting(
  "AF(c) = 处于 c.state 状态、指向 c.addr 的连接\nRI(c) = c.state ∈ {Open, Closed}\n     && (c.state == Open => c.conn != nil)\nSafety: 字段未导出；Close 幂等；不返回底层 net.Conn。\nContract: 状态只能 Open -> Closed，不能反向；并发调用由 mutex 保护。",
  lang: "text",
  caption: [状态机型：AF 用状态，RI 用状态集合，转移规则放 Contract],
)

=== 真实项目样本：标准库怎么处理形式

标准库不写课程的 AF/RI，但它把同样的信息放在字段注释和接口契约里。
四种样本正好覆盖四种形式：

*（1）数学式 RI：`time.Time`*

#codelisting(
  "type Time struct {\n    // wall and ext encode wall seconds, nanoseconds,\n    // and an optional monotonic reading.\n    //\n    // wall bit layout (high to low):\n    //   hasMonotonic (1 bit), seconds (33 bits), nanos (30 bits).\n    // Constraints:\n    //   nanos in [0, 999999999].\n    //   hasMonotonic == 0 => 33-bit field == 0; full seconds in ext.\n    wall uint64\n    ext  int64\n    loc  *Location\n}",
  lang: "go",
  caption: [`/usr/lib/go/src/time/time.go:140-160`：位级谓词就是 RI],
)

`Time` 的抽象值是「一个时间点」，表示是位编码，所以 RI 必须是位级谓词：
纳秒字段范围、hasMonotonic 位为 0 时 33 位字段必须为 0、loc 为 nil 表示 UTC。
这是「抽象值有数学结构时，RI 天然是数学式」的样本。

*（2）文字式字段说明：`bytes.Buffer`*

#codelisting(
  "type Buffer struct {\n    buf      []byte // contents are buf[off : len(buf)]\n    off      int    // read at &buf[off], write at &buf[len(buf)]\n    lastRead readOp // last read op, for Unread*\n\n    // Copying or modifying a non-zero Buffer is error-prone.\n}",
  lang: "go",
  caption: [`/usr/lib/go/src/bytes/buffer.go:20-30`：字段注释写表示，使用约束另写],
)

`buf` 的注释 `contents are the bytes buf[off : len(buf)]` 是 AF 的雏形；
`Copying and modifying a non-zero Buffer is prone to error` 是使用约束，不是 RI。
标准库用文字，因为它的读者是客户端，不是实现者。

*（3）不可检查的文字契约：`sort.Interface.Less`*

#codelisting(
  "type Interface interface {\n    Len() int\n    // Less must describe a Strict Weak Ordering:\n    //  - Less(i,j) && Less(j,k) => Less(i,k)\n    //  - !Less(i,j) && !Less(j,k) => !Less(i,k)\n    Less(i, j int) bool\n    Swap(i, j int)\n}",
  lang: "go",
  caption: [`/usr/lib/go/src/sort/sort.go:17-38`：严格弱序只能写成文字契约],
)

严格弱序是规格，但没法用一行谓词低成本检查，所以标准库用文字加例子加反例（NaN）。
这对应模板里的 `Contract` 段。

*（4）使用约束：`sync.Mutex`*

#codelisting(
  "// A Mutex is a mutual exclusion lock.\n// The zero value for a Mutex is an unlocked mutex.\n//\n// A Mutex must not be copied after first use.\ntype Mutex struct {\n    state int32\n    sema  uint32\n}",
  lang: "go",
  caption: [`/usr/lib/go/src/sync/mutex.go:17-20`：这是调用者责任，不是 RI],
)

`A Mutex must not be copied after first use` 是客户端责任，不是 RI；
课程里它属于「前置条件/所有权」，不要塞进 RI。

#importantbox[
真实项目的共同点：*形式服从可检查性*。能检查的写成谓词或位约束；
不能检查的写成文字契约，并明确说「这是调用者责任」还是「实现者责任」。
]

=== 用模板诊断项目里的 KV 与 Entry

*KV 的现状*：

#codelisting(
  "//\tAbstraction function:\n//\t\tAF(mem) = { k -> mem[k] | all k in mem }\n//\n//\tRep invariant:\n//\t\tlen( each of mem.keys) >= 1\n//\t\tlen( each of mem.values) >= 1",
  lang: "text",
  caption: [`internal/db/kv.go` 的 AF 是集合式，RI 是英文伪代码],
)

问题：AF 是集合式（方向对），RI 是英文伪代码 `len( each of mem.keys) >= 1`，
不能直接翻译成 `checkRep`。套模板后应写成谓词：

#codelisting(
  "AF(mem) = { k -> mem[k] | k ∈ dom(mem) }\nRI(mem) = (∀ k ∈ dom(mem): len(k) >= 1)\n       && (∀ k ∈ dom(mem): mem[k] != nil)\nSafety: mem 未导出；Get/Set 入向与出向都拷贝；Del 只删键。",
  lang: "text",
  caption: [KV 的套模板结果：结构示例，具体约束以你的规格为准],
)

注意：`mem[k] != nil` 这一行是否成立，取决于你是否允许 `Set` 保存 nil 值；
如果允许，就删掉这一行，并在 `Contract` 里说明「nil 值与缺失键的区别」。
规格要跟着你的实现选择走，不要照抄示例。

*Entry 的现状*：AF/RI 还是 TODO。套模板时只填三行：

+ AF：`AF(ent) = 一对字节串 (ent.key, ent.val)`（或你选的其他抽象值）；
+ RI：至少决定 nil、空值、长度上限三件事；
+ Safety：`Encode` 的返回值是否与 `key`、`val` 共享底层数组。

#warningbox[
不要在 AF 里写合法性约束（如「key 非空」），那是 RI 的事；
也不要在 RI 里写实现细节（如「用两个切片存」），那是 rep 本身。
]

=== 30 秒规则与字数上限

#booktabs-table(
  columns: (1.6fr, 2.4fr),
  [*规则*], [*做法*],
  [30 秒规则], [决定不了数学还是文字，就用「数学主体 + 文字修饰」的默认式],
  [1-3-3 上限], [AF 1 行、RI 3 行、Safety 3 行；超了拆类型或移到实现注释],
  [`RI = true`], [没有不变量就写 `RI(r) = true`，并注明为什么不需要],
  [先客户端后字段], [先用一句话说客户端看到什么，再写 AF；不要从字段反推],
  [三问验收], [AF 全函数？RI 可判定？rep exposure 每条路径都封了？],
  [停止条件], [三问通过就停；不追求「看起来像论文」],
)

=== trivially true 是什么意思

*字面意思*：trivially true = 平凡地为真，指「不需要论证、按定义或逻辑结构直接成立」的命题。
它不是「大概对」「显然对」，而是一个可以明确指出的真值来源。

#booktabs-table(
  columns: (1.3fr, 2.2fr, 2.1fr),
  [*说法*], [*为什么为真*], [*RI 里的例子*],
  [trivially true], [命题没有实质内容，或按定义直接成立], [`RI(r) = true`；`x == x`],
  [vacuously true], [全称量词没有实例（空集）], [空 map 上 `∀ k ∈ dom(mem): len(k) >= 1` 为真],
  [non-trivial], [需要逐个实例论证或检查], [每个 key 都非空；游标在范围内],
)

=== RI 写成 true 的三种合法场景

+ *纯数据载体*：所有字段组合都合法，如 `type Pair struct { A, B int }`；
+ *类型系统已保证*：字段是 `uint`，天然非负；字段是定长数组，长度固定；
+ *构造后不可变，且构造器只接受合法值*：`NewT` 校验一次，之后没有 mutator 能破坏。

#codelisting(
  "// Duration 的表示就是一个 int64 纳秒数；\n// 所有 int64 都对应一个合法时长，没有额外不变量。\ntype Duration int64\n\n// RI(d) = true\n// checkRep 可以是空函数：没有需要检查的表示约束。",
  lang: "go",
  caption: [`time.Duration`（`/usr/lib/go/src/time/time.go:912-915`）是 trivially true 的真实样本],
)

=== 但「空真」不等于「没有约束」

#importantbox[
`∀ k ∈ dom(mem): len(k) >= 1` 在空 map 上为真，是因为没有反例，不是因为「所有 key 都非空」这件事被检查过。
这就是 vacuous truth。RI 在初始状态下成立，不代表它在所有状态下都成立；
变值器必须维持它，测试要覆盖非空状态。
]

#warningbox[
不要把「我的 RI 在零值上成立」当成「RI 是 trivially true」。
零值是 RI 的一个实例；trivially true 是「所有表示都合法」。两者不是一回事。
]

=== 什么时候不能写 true

出现下面任一情况，RI 就不是 trivially true：

+ 有 nil、空值、长度或游标范围约束；
+ 多个字段之间有联动（缓存与源数据一致、状态与字段匹配）；
+ 有顺序约束（有序切片、堆）；
+ 有所有权或别名约束（返回的切片不能与内部共享）；
+ 有并发约束（锁保护哪个不变量）。

#warningbox[
`RI = true` 必须配一句「为什么」：是纯数据载体、类型系统保证，还是构造器保证。
只写 true 不写理由，评审者无法区分「真的没有不变量」和「忘了写」。
]

== 陷阱与易错

#warningbox[
*把 RI 写成前置条件。* RI 是实现者必须保证的；前置条件是调用者必须满足的。
`key != nil` 如果是客户端责任，就写进前置条件，不要写进 RI。
]

#warningbox[
*AF 不是全函数。* `AF(s) = s.data[0]` 对空切片无定义。
要么 AF 处理空情况，要么 RI 排除空切片——两者必须配套。
]

#warningbox[
*用不可判定的词。* 「key 合理」「顺序正确」「线程安全」都不是 RI。
改成可检查的谓词；不能检查的移进 `Contract`。
]

#warningbox[
*把 rep 描述当 AF。* `AF(ent) = ent.key, ent.val` 只说了字段，没有说抽象值。
AF 的右侧应该是客户端看到的东西（一对字节串、一个记录、一个时间点）。
]

#warningbox[
*完美主义：给每个字段都写不变量。* RI 只写「客户端可依赖、实现必须保证」的约束。
字段的内部细节放字段注释；RI 越长，越没人检查。
]

== 关键点

#importantbox[
统一格式 = 四段结构 + 每段固定文体：
AF 一行映射（数学主体 + 文字修饰），RI 一列可判定谓词，Safety 一张路径表，
RI 维护一句说明。形式选择只看两个变量：抽象值有没有数学结构、约束能不能检查。
]

#booktabs-table(
  columns: (1.3fr, 1.8fr, 1.8fr),
  [*情况*], [*选什么*], [*为什么*],
  [抽象值是集合/映射/序列/数值], [数学式 AF 加谓词 RI], [结构清楚，检查方便],
  [抽象值是状态/资源/文本], [文字 AF 加状态谓词 RI], [数学式写不清语义],
  [约束可运行时检查], [放进 RI 和 `checkRep`], [可执行才有约束力],
  [约束不可检查], [放进 `Contract` 文字], [不要伪装成 RI],
)

== 变式检验

*变式 1：不可变类型（Time、RatNum）的 AF/RI 有什么不同？*

RI 在构造后不变，`checkRep` 只在构造器调用；AF 通常是数学值；
rep exposure 只需检查构造器是否保存了外部可变引用。

*变式 2：带缓存或惰性求值的类型怎么写？*

AF 只描述抽象值；缓存与源数据的一致性放进 RI
（例如缓存为 nil，或缓存等于从源数据算出的值）。
缓存是实现细节，但一致性是客户端可依赖的（性能语义除外），所以它属于 RI。

*变式 3：状态机类型（Open/Closed）怎么写？*

AF 用「当前状态加状态对应的抽象值」；RI 用「状态属于允许集合」加「状态与字段的联动」；
转移规则放 `Contract`（或单独的状态转移表），不要塞进 AF。

*变式 4：并发类型怎么写？*

RI 只描述「单线程下什么表示合法」；并发安全是另一条契约
（锁保护哪个不变量、哪些操作原子）。
不要把「线程安全」写成 RI 的一行——它不可由 `checkRep` 检查。

*变式 5：如果抽象值需要两行才能说清，怎么办？*

说明抽象值选大了。拆成两个类型，或把次要信息降为实现注释。
AF 一行是纪律，不是审美。

== 同类归类

#booktabs-table(
  columns: (1.3fr, 1.8fr, 2fr),
  [*概念*], [*回答的问题*], [*与 AF/RI 的边界*],
  [AF], [表示代表什么抽象值], [映射；不负责合法性],
  [RI], [哪些表示合法], [谓词；实现者责任],
  [前置条件], [调用者必须满足什么], [不是 RI；写进方法规格],
  [`Contract`], [不可检查的约束], [文字；不要混进 RI],
  [rep exposure], [客户端能否绕过操作改 rep], [路径清单；不是数学命题],
  [数据约束], [字段或数据库层面的约束], [可能由 RI 或外部系统保证],
)

6.031 对照：R11（AF/RI）讲不变量、表示暴露与不变量替代前置条件；
6.102 对应 R07。R10/R06 讲 ADT 的操作分类与表示独立。
本题是「书写格式」，不是「新概念」，所以落点是模板与判据。

== 为什么 Go 不默认关闭 RI 检查

先澄清一个前提：Go 并不会*自动*把 RI 检查塞进运行时。`checkRep` 只是一个普通函数，
调用不调用、在哪里调用，完全由你决定。所以「很多性能拿去跑 RI」通常不是语言造成的，
而是把 `O(n)` 的检查放进了热路径。

#booktabs-table(
  columns: (1.4fr, 1.6fr, 2.2fr),
  [*检查类型*], [*典型成本*], [*放哪*],
  [`O(1)` 字段谓词], [纳秒级], [构造器、mutator 末尾],
  [`O(n)` 遍历（map、树）], [微秒到毫秒], [构造器、测试、周期性校验],
  [全量一致性（缓存、索引）], [毫秒到秒], [测试、离线校验、debug 构建],
  [与磁盘 I/O、网络相比], [通常可忽略], [不要为省它牺牲正确性],
)

判断标准不是「检查贵不贵」，而是「它的成本相对于所在操作是否显著」。
一次 `Get` 是 `O(1)`，在 `Get` 里遍历整个 map 当然贵；一次 `Open` 要读日志、建索引，
同样的遍历就不显著。

== 为什么「默认关、遇 bug 再开」不划算

+ *观测点太晚。* RI 违反的最佳观测点是它发生的那一刻；等到线上出问题再开，
  数据可能已经写坏，错误可能已经传播到很远的地方。
+ *不可复现。* 生产 bug 往往依赖时序、数据分布或并发交错；检查关着的时候没有证据链，
  重新开启后也未必能复现。
+ *环境差异。* debug 构建和 release 构建行为不同，测试绿不代表生产绿；
  build tags 忘记带 tag 还会制造假绿（上一节讲过）。
+ *切换成本。* 重新部署、重启、加配置都要时间；如果做成动态开关，
  又引入分支、数据竞争和不可预测性。
+ *fail-fast 更便宜。* 一次检查的成本，通常远低于数据损坏后的回滚、修复和排查。

#importantbox[
「默认关、遇 bug 再开」听起来省性能，实际把*可观测性*关掉了。
RI 检查的价值不是「平时多跑几行代码」，而是「违反发生时立刻失败」；
如果把检查默认关掉，你就失去了触发开启的那个信号。
]

== Go 里的「按需开启」其实已经存在

只是它按*工具和场景*开启，而不是把所有 RI 默认关掉：

+ `go test -race`：开发/测试时开启竞态检测，生产二进制不带；常见说法是 5-10 倍开销，
  但它只查数据竞争，不查 RI；
+ `GODEBUG`：运行时调试开关（`go help environment` 说它「Enable various debugging facilities」），
  按需开启 `gctrace` 等，不是用户 RI 的开关；
+ `_test.go` 或 build tags：RI 检查的按需开启，代价是测试必须带同一 tag；
+ `go vet`、`staticcheck`：编译期检查，零运行时成本；
+ `go test -bench`、`pprof`：先测量再决定检查放哪，而不是凭感觉优化。

== Rust 的 debug_assert!：用户想要的模式，为什么 Go 没有

Rust 有明确的 debug/release 构建模式，`debug_assert!` 在 debug 构建开启、release 关闭：

```rust
debug_assert!(self.mem.is_some(), "RI violated: nil mem");
```

本机可以验证这个开关：

#codelisting(
  "$ rustc --print cfg | grep debug_assertions\ndebug_assertions\n\n$ rustc -O --print cfg | grep debug_assertions\n（无输出）",
  lang: "text",
  caption: [`-O` 关闭 debug assertions：这是 Rust 的编译模式开关],
)

Go 没有 `cfg!(debug_assertions)` 的等价物，因为 Go 没有「debug/release 构建模式」这个概念：
`go build` 的默认产物就是发布产物，没有隐式的调试开关。
要用类似机制，只能用 build tags 显式模拟；这也是 Go 选择「显式优于隐式」的代价。

#warningbox[
Rust 的 `debug_assert!` 适合「代价高、release 下可以接受不检查」的断言；
它不适合「违反后会写坏数据」的 RI。后者即使慢一点，也应该始终开启。
]

== 标准库的取舍：panic 在边界被恢复

标准库不是「从不检查」，也不是「到处检查」：

+ `sync/waitgroup.go:118`、`bytes/buffer.go:116`、`database/sql/sql.go:58`：
  内部不变量或 API 误用，直接 `panic`；
+ `net/http/request.go:872`、`encoding/json/decode.go:103`：可预期的输入错误，返回 `error`；
+ `net/http/server.go:1960`：HTTP server 在请求边界 `recover` handler 的 panic，
  返回 500。这是*最后防线*，不是让 RI 违反变成正常错误。

所以 Go 的模型是：*检查默认开启，但在边界恢复 panic*，而不是*默认关闭检查*。
恢复发生在请求/任务边界，日志里留下堆栈；不变量本身仍然 fail fast。

== 对你项目的建议

+ `KV`：`checkRep` 放在 `Open`、`Set`、`Del` 之后；不要在 `Get` 里遍历整个 `mem`；
+ `Entry`：`Decode` 的短头、短数据返回 `error`（可恢复输入），不要 panic；
  `checkRep` 放测试；`Encode` 的别名检查放构造器或测试；
+ 如果某个检查确实是 `O(n)` 且调用频繁，先写 benchmark，再决定移到 `_test.go` 或 build tags；
+ 不要为了「上线快一点」默认关掉 RI：线上 panic 日志比静默写坏数据便宜得多。

#importantbox[
性能优化的顺序是：测量热点，移走重检查，保留轻检查；而不是把整类检查静默关闭。
Go 没有 assert 开关，但给了你 `-race`、`GODEBUG`、build tags、benchmark 和 pprof——
按场景开启，而不是按心情关闭。
]

== Go 语言机制补充

*`checkRep` 的写法。*

#codelisting(
  "func (kv *KV) checkRep() {\n    for k, v := range kv.mem {\n        if len(k) == 0 {\n            panic(`RI violated: empty key`)\n        }\n        if v == nil {\n            panic(`RI violated: nil value`)\n        }\n    }\n}",
  lang: "go",
  caption: [RI 的每一行都应该能变成 checkRep 的一行；放在测试里调用],
)

Go 没有 `assert`；用 `panic`（生产构造器）或 `t.Fatalf`（测试）。
`checkRep` 不导出；只在构造器、mutator 之后、测试里调用。

*AF/RI 的注释格式。* 用 tab 缩进的注释块，`go doc` 会把它渲染成 preformatted；
项目里的 `KV` 已经是这个格式。`go doc` 不解析 Markdown，注释里的符号会原样显示。

*未导出字段与包级可见性。* RI 的检查函数必须同包；包外客户端看不到 rep，
所以 AF/RI 是给实现者和同包测试看的，不是 API 文档。

*零值可用性。* 在 RI 或类型注释里明确 `var t T` 是否合法；
如果零值不合法，写「必须用 `NewT` 构造」，并让构造器建立 RI。

*值类型与指针 receiver。* `checkRep` 用指针 receiver，避免拷贝；
含 `sync.Mutex` 的类型更不能拷贝（标准库明确写「must not be copied after first use」）。

=== assert 开关与 checkRep：Go 的替代方案

先澄清一个课程细节：6.102（TypeScript）里的 `assert` 通常是普通函数
（`node:assert` 或课程自带的 `assert`），不会因为构建模式被自动移除；
真正“可开关”的是 6.031 里的 Java `assert` 语句——默认关闭，`-ea` 开启。
所以“assert 可以关掉”是 Java 机制的副作用，不是课程的核心设计目标。

课程真正要的是：把 RI 从注释变成*可执行检查*。Go 没有 `assert` 语句，
但有三条正交的替代路径：

#booktabs-table(
  columns: (1.5fr, 2fr, 2fr),
  [*场景*], [*Go 做法*], [*是否可关闭*],
  [用户输入错误], [返回 `error`], [否；由调用方处理],
  [内部不变量被破坏], [`panic` 与 `checkRep`], [否；始终开启],
  [测试中的期望], [`t.Fatalf` 或 `require`], [只在测试构建中存在],
  [性能敏感检查], [build tags 或 `_test.go`], [是；构建开关],
)

=== 为什么标准库用 panic 而不是可关闭的 assert

#booktabs-table(
  columns: (1.6fr, 2.1fr, 1.8fr),
  [*位置*], [*代码*], [*说明*],
  [`sync/waitgroup.go:118`], [`panic` 计数器为负], [内部不变量被破坏，属于 bug],
  [`bytes/buffer.go:116`], [`panic` 截断越界], [API 误用，契约是调用者责任],
  [`net/http/request.go:872`], [`NewRequest` 返回 `error`], [URL 或方法错误是可预期输入],
  [`encoding/json/decode.go:103`], [`Unmarshal` 返回 `error`], [输入错误可恢复],
)

分界线不是“严重程度”，而是*谁的责任、能否恢复*：

+ 调用者传了坏输入：返回 `error`，让调用方决定重试、报错还是忽略；
+ 实现者自己的不变量破了：`panic`，因为继续运行只会产生更远的错误；
+ 测试里的期望不成立：`t.Fatalf` 或 `require`，失败即停。

#importantbox[
Go 社区的主流做法是*默认开启* RI 检查：`checkRep` 在构造器和 mutator 末尾调用，
违反就 `panic`。这比 Java 的 assert 更“硬”，但也更符合 Go 的 fail-fast 风格：
不变量破了就不要带着坏状态继续跑。
]

=== 如果确实需要“开关”：三种 Go 方案

*方案 A：`_test.go` 专用检查（最轻）*

把 `checkRep` 定义在 `*_test.go` 里，只让测试调用。生产构建不包含它，
零运行时开销；代价是生产路径不检查。

```go
// checkrep_test.go
package db

import "testing"

func checkRep(t *testing.T, kv *KV) {
    t.Helper()
    if kv.mem == nil {
        t.Fatal(`RI violated: nil mem`)
    }
}
```

*方案 B：build tags（最接近 Java assert 的 `-ea`）*

两个文件，构建时二选一：

```go
//go:build debug

// checkrep_debug.go
package db

func (kv *KV) checkRep() {
    if kv.mem == nil {
        panic(`RI violated: nil mem`)
    }
}
```

```go
//go:build !debug

// checkrep_release.go
package db

func (kv *KV) checkRep() {}
```

构建：`go build -tags debug`；测试：`go test -tags debug`。
`go help buildconstraint` 可查 `//go:build` 的语法。

#warningbox[
用 build tags 做开关时，*测试必须带同一个 tag*；否则测试编译的是空实现，
`checkRep` 永远通过，测试给你假绿。这是社区不常推荐用 build tags 做 RI 检查的主要原因。
]

*方案 C：`const debug` 加编译器优化（不推荐）*

```go
const debug = false

func (kv *KV) checkRep() {
    if debug && kv.mem == nil {
        panic(`RI violated: nil mem`)
    }
}
```

Go 编译器通常会消除常量分支，但*不保证*跨函数或接口场景；而且改常量要重新编译。
可读性和可验证性都不如 build tags。

=== 社区推荐的分层

#booktabs-table(
  columns: (1.4fr, 2.2fr, 1.8fr),
  [*层级*], [*做法*], [*理由*],
  [公开 API 边界], [输入校验返回 `error`], [调用者可恢复],
  [构造器], [校验参数，建立 RI；失败返回 `error` 或 panic], [RI 的起点],
  [mutator], [维护 RI；内部 bug 用 panic], [不变量不能被破坏],
  [测试], [`checkRep` 加 `require` 或 `t.Fatal`], [失败即停，定位清楚],
  [性能敏感], [只在 debug 构建开启], [用 build tags，测试带 tag],
  [线上], [不依赖 assert 开关], [panic 日志加监控，而不是静默关闭检查],
)

#importantbox[
Go 没有 Java 式的 assert 开关，但这不是缺陷：它逼你明确*哪类失败用 error、哪类用 panic*。
RI 违反属于“实现者 bug”，默认应该 panic；如果检查太贵，把它移到构造器或测试，
而不是把整类检查静默关掉。
]

=== 真实项目样本：标准库的 fail-fast

```go
// sync/waitgroup.go:118
if v < 0 {
    panic("sync: negative WaitGroup counter")
}

// bytes/buffer.go:116
if n < 0 || n > b.Len() {
    panic("bytes.Buffer: truncation out of range")
}
```

```go
// net/http/request.go:872
func NewRequest(method, url string, body io.Reader) (*Request, error)

// encoding/json/decode.go:103
func Unmarshal(data []byte, v any) error
```

前者是“实现者自己的不变量/契约被破坏”，后者是“调用者输入可预期地不合法”。
标准库没有用可关闭的 assert，而是用 `panic` 与 `error` 两种返回值把两类失败分开。

== 本次操作与当前状态

*已做的文件操作*：

+ 读取今天的 `note/2026-11-14.typ`，确认没有同主题一级标题；
+ 读取 `internal/db/kv.go` 的 AF/RI 注释，作为项目内诊断样本；
+ 读取标准库样本：`time/time.go`、`bytes/buffer.go`、`sort/sort.go`、`sync/mutex.go`、
  `sync/waitgroup.go`、`net/http/request.go`、`encoding/json/decode.go`、
  `database/sql/sql.go`、`net/http/server.go`；
+ 运行 `rustc --print cfg`、`rustc -O --print cfg`、`go help testflag`、`go help environment`；
+ 追加本一级标题到 `note/2026-11-14.typ`，并新增 `=== assert 开关与 checkRep：Go 的替代方案`
  与 `== 为什么 Go 不默认关闭 RI 检查`；未修改 `internal/db` 下任何代码。

*验证结果*：

+ `XDG_CACHE_HOME=/home/zz/.cache typst compile 2026-11-14.typ`：成功（30 页，仅 `iosevka` 字体警告）；
+ `rustc --print cfg` 输出 `debug_assertions`；`rustc -O --print cfg` 无该输出；
+ 本轮没有改代码，`go test` 状态不变（仍是 `kv_entry.go` 缺函数体的编译红）。

*需要你自己动手的*：

+ 用四段模板重写 `KV` 的 RI（把 `len( each of mem.keys)` 改成可编译谓词）；
+ 用四段模板给 `Entry` 填 AF、RI、Safety，先写一行 AF，再写 1–3 行 RI；
+ 给 `checkRep` 选定位置：`KV` 放 `Open`、`Set`、`Del` 之后，`Entry` 放测试；
  不要在 `Get` 里做 `O(n)` 检查；
+ 填完跑 `go doc -all ./internal/db`，确认读起来像合同而不是问句。
