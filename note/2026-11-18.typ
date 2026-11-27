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
= 重构软件构造导师：让每一讲从本步测试出发

== 费曼直觉

数据库作者决定今天做哪一步，MIT 课程帮助解释这一步为什么值得这样设计。先读当前测试能看到什么，再请学习者自己写出承诺，导师就能评判一条规格究竟有多少依据。新版保留原调用名 `software-construction`，主入口从 247 行缩为 32 行。

#importantbox[恢复进度时，把最近笔记里的步骤、今天的函数签名和当前测试放在一起看。三者能帮导师找回学习现场；是否通过还要看该版本的运行结果。]

== 硬核机制

#booktabs-table(
  columns: (1fr, 2.5fr, 2.5fr),
  [要做的判断], [依据], [导师的动作],
  [从哪步接], [11 月 13 日笔记已进入 0102，14 日笔记继续讨论 Entry 的抽象函数与表示不变式；项目里有对应测试。], [用日期笔记、函数和测试恢复停点。删去 skill 中写死的 0101 状态。],
  [给哪些题], [学习者贴出的本步测试规定可观察的行为。], [未贴时给骨架。贴出后一次给完整的本步题目与依赖，交卷后逐题评。其余维度记 `TODO(阶段末)`。],
  [查哪门课], [6.102 sp26 提供结构和术语，6.031 sp21 补充推导、反例与习题。], [查对应小节，用有出处的 Go 样本映射回项目。只有明确系统通读才更新通读进度。],
  [何时算会], [真实的命令结果和学习者自己的解释。], [分别记录工程验收和独立迁移。层末用一次真实故障、对应测试和数据流复盘。],
)

== 陷阱与易错

#warningbox[0102 讲义展示的编码混入了 0103 的删除标志。核对项目的 `TestEntryEncode` 与 starter 的同名测试，两者期望的字节均无这个标志。把后续字段加进作业会使按当前契约编写的实现偏离测试。]

上游 starter 和步号索引有相同的 44 个 ID，项目约定用「45 步」描述整体目标。新版保留这两种口径，用具体步号追踪工作。没有根据这个差异增加练习。

== 关键点

已安装的入口负责续课、出题、提示、评测和查课。出题手册给出题目依赖及验收依据，项目指南集中记录材料位置与项目命令。项目现场与可复用的教学方法各自保存在适合更新的地方。保留「读材料 → 规格 → 测试 → 实现 → 验证 → 落盘 → 进度」七动作，以及本人完成核心实现的约定。

== 变式检验

继续 0102 时，如已给出本步测试，导师可让学习者判断「哪条断言能区分两个不同编码」。如只说「继续」且尚未贴出该步测试，导师可以恢复到相应文件并给骨架；磁盘上存在测试只能用于核对进度。

== 同类归类

这也是读取课程材料时会遇到的证据问题。读取器以前在全文中删除空括号，函数调用的原文会失真。新版保留括号，支持按目录中列出的三级标题取节，并明确报告标题或讲次匹配失败。6.102 R04 的 Missing Map keys 和 6.031 R06 的 Checked and unchecked exceptions 均已从本地镜像取到。后者首次按近似标题查询未匹配，查看目录后用实际节名验证成功。

== 本次操作与当前状态

在临时目录完成编辑和补丁预演，经授权将 11 个变更文件应用到已安装的 skill，随后逐文件对比一致。变更涉及主入口、Reading 提取器、导师手册、诊断和通读指南、语言与 Reading 对照资料以及数据库项目索引。独立于 skill 的旧学习档案保留其历史日期。项目内新增本日问答的 Typst 源文件及同级 PDF。

已在安装位置运行 skill 校验器，结果为通过。离线验证覆盖 6.102 的 19 讲和 6.031 的 30 讲目录、分节与结束边界、代码空括号、错误查询、17 处本地引用，以及 44 个 starter 步骤编号。以下命令可在本机复核入口与两个章节。

#codelisting("cd ~/.codex/skills/software-construction\npython3 ../.system/skill-creator/scripts/quick_validate.py .\npython3 assets/fetch_reading.py 6.102 4 --section 'Missing Map keys'\npython3 assets/fetch_reading.py 6.031 6 --section 'Checked and unchecked exceptions'", lang: "bash", caption: [复核安装和本地 Reading 读取])

本轮验证的是导师 skill。数据库实现、作业及进度未变动，本轮未运行 Go 验收。用户无需手动安装。下次提交 0102 的测试并要求出题，即可从本步开始。首次编译提示模板默认字体 Iosevka 未安装，改用本机 DejaVu Sans Mono。机械自检后用本机包缓存重新编译，零错误、零警告。

// 轨道：CS 轨
= Go 软件构造模板：从规格和测试分区到实现

== 费曼直觉

规格说明调用者要先满足什么、实现要保证什么。测试分区则把一份承诺拆成几类有代表性的调用。写规格时先考虑如果内部换一种写法，调用者仍应观察到什么；写测试时再把这些观察变成断言。

#importantbox[把函数规格放在声明上方，把 AF、RI 和表示暴露的论证放在字段旁，把测试分区写在测试函数上方。新增用例时抄一行表，填实际输入和独立推得的期望。]

== 硬核机制

#booktabs-table(
  columns: (1.25fr, 1.65fr, 2.4fr),
  [概念], [回答的问题], [Go 里的位置],
  [前置条件与后置条件], [谁负责什么], [签名表达类型；注释表达调用条件、返回结果与状态变化],
  [抽象函数（AF）], [每个合法的表示是哪个抽象值], [结构体字段旁的映射],
  [表示不变式（RI）与表示暴露], [字段是否合法，外部是否能改到字段或其数据], [结构体内的约束和论证；API 公开所有权与生命周期要求],
  [测试分区与用例], [哪些类别有不同结果，哪个输入能检验承诺], [测试函数上方的策略注释、表中的期望与子测试断言],
)

#codelisting(
  "// Foo <调用者可依赖的行为>。\n// Requires: <调用者必须先满足的条件>。\n// Effects: <按条件写结果、错误与可观察状态变化>。",
  lang: "go",
  caption: [函数规格模板，放在声明正上方],
)

#codelisting(
  "// AF: <把合法字段状态映射成唯一抽象值>。\n// RI: <能直接用字段值判真的约束>。\n// Safety from rep exposure: <输入是否保留、输出是否共享及其有效期>。",
  lang: "go",
  caption: [抽象数据类型的表示模板，放在字段旁],
)

#codelisting(
  "// Testing strategy for Foo:\n// Domain: <合法参数、初始状态和必要的调用历史>。\n// Partition on <维度>: <列出互斥、完整且非空的子域>。\n// Boundaries: <哪些边界值得选作代表>。\n// TODO(阶段末): <当前验收尚未确定的维度>。",
  lang: "go",
  caption: [测试策略模板，放在测试函数上方],
)

课程主线来自 6.102 R04 的 Specification structure、R05 的 Designing Specifications、R07 的 AF/RI 和 Recipes for programming，以及 R02 的 Documenting your testing strategy。6.031 R07 补前置条件与失败保证的取舍，R08 补可变对象共享及其契约，R03 补多维分区，R11 补为什么合法表示由类型守住，R19 用矩阵表达式演示同一方法如何扩展到完整程序。项目指南保留对应原文链接。

== 陷阱与易错

#warningbox[如果规格保证非法输入返回某种错误，这个输入在承诺覆盖的范围内。把返回错误和失败后的状态写到 Effects。把输入单纯列为 Requires 时，规格并未保证违反后的结果。]

测试只能给出实际断言的证据。当前 0102 的固定样例检查精确字节和解码结果；它没有定义空输入、截断和所有权等维度的完整行为。暂按项目规则记作 `TODO(阶段末)`。多个测试维度可以各自划分；同一条用例同时覆盖各维度的一个子域。先测行为变化的边界及确实有相互作用的组合。

== 关键点

课程的 Spec → Test → Implement 用在方法、抽象数据类型或模块上。db-go 的七动作是读材料 → 规格 → 测试 → 实现 → 验证 → 落盘 → 进度。当前步骤先找验收断言并回推可覆盖的行为，再写规格和分区；实现后执行项目命令，记录命令结果、待补维度和下次入口。

同一方法也适用于后续 Reading。评审先找可能被改坏的承诺；可变性先追踪两处是否共享同一份可修改数据；接口到相应步骤再按调用方所需的方法选取；语法解析列合法、非法和边界输入；并发步骤在规格中交代共享状态的同步责任，并给相应证据。

== 变式检验

用项目外的发料台演示。仓库的一次申请须全量满足；否则申请者重试时可能重复扣库存。若仓库有 2 件，申请 3 件后收到失败，仍应能查询到 2 件。和 db-go 一样，这要求观察调用前后的状态；例子的布尔结果与扣减规则只属于发料台。在合法域中，先把库存为零的输入单独列出。库存为正时，按申请量与库存三种大小关系继续划分。

#booktabs-table(
  columns: (1.6fr, 1.12fr, 1.17fr),
  [分区], [初始库存，申请], [结果，剩余],
  [E：没有库存], [0，1], [false，0],
  [L：申请少于库存], [2，1], [true，1],
  [B：申请等于库存], [2，2], [true，0],
  [S：库存非空且不足], [2，3], [false，2],
)

测试表的一行含名字、输入和期望。准备阶段新建独立库存并核对初始值，执行阶段调用一次领用，断言阶段检查布尔结果和剩余库存。独立修改示例为「相等时拒绝」与「拒绝时仍扣库存」，两种修改都被相应用例抓到。

== 同类归类

Go 标准库中的两个真实案例对比了数据不足时的合法契约。缓冲消费者可以先用现有字节，协议解析器需要识别固定长度字段是否完整。若把接受短读的约定照搬到定长字段，解析程序可能处理未读完整的记录。可迁移的是描述结果和状态的方法，具体错误和状态变化仍以 db-go 本步为准。

+ `bytes.Buffer.Next` 返回可用字节并推进位置，结果共享内部数据，到下次读写方法调用前有效。实现取出 `b.buf[b.off : b.off+n]`，再做 `b.off += n`。本机 `/usr/lib/go/src/bytes/buffer.go` 有实现；同目录 `buffer_test.go` 的 `TestNext` 枚举小范围的可用字节数和请求量。
+ `io.ReadFull` 用 `ReadAtLeast(r, buf, len(buf))` 读取满目标缓冲区。读到一部分后遇到 EOF，已读字节数和 `io.ErrUnexpectedEOF` 都会返回，目标缓冲区可能已变。本机源码在 `/usr/lib/go/src/io/io.go`。

== Go 语言机制补充

结构体是带名字字段的组合类型。库存示例中的 `Stock` 只有一个未导出的整数字段，零值表示空库存。零值是未显式初始化时 Go 为该类型赋予的值。接收者是方法作用的对象，`Take` 的指针接收者定位到同一个库存，因而能修改它。观察方法返回整数值，外部变量不会和整数字段共享储存。切片则描述一段序列，多个切片可能共享底层数据，所以缓冲区的有效期需要单独说明。完整可运行的例子在 `examples/construction/stock.go` 与 `examples/construction/stock_test.go`。

`t.Run` 给测试中的某个场景命名，便于定位失败并单独运行。表驱动测试把各场景的差异放进一组记录，再统一执行。Go 的签名检查与测试运行是语言工具提供的机制；`Requires` 和 `Effects` 则是模板书写约定。用 `go doc testing.T.Run`、`go help testflag`、`go doc -src bytes.Buffer.Next` 和 `go doc -src io.ReadFull` 可复核。

== 本次操作与当前状态

在项目中新增 `docs/go-construction-templates.md`，统一收录函数规格、表示、测试策略和用例行。新增独立的 `examples/construction` 示例包。模板可按需复制到自己的步骤，示例用来参照如何落笔。用户可先从 0102 的一条已知断言出发，写对应的规格和分区；数据库作业验收沿用项目规则。

`go test -count=1 -v ./examples/construction` 通过全部场景，按名称单跑「库存恰好够」的子测试也通过。`go vet ./examples/construction` 通过，`gofmt -l examples/construction` 无输出。两个临时错误实现分别在目标子测试上如预期失败，示例文件保留正确实现。检查了模板里的本地路径及 MIT 镜像章节锚点。验证范围是独立示例包。当天笔记已追加本节，机械自检后编译同级 PDF。

全局 `git diff --check` 对已有的 11 月 13 日 PDF 改动报行尾空白。本轮新增文本和附加笔记另做空白及结构检查，均通过。

// 轨道：CS 轨
= 0102 源码练习框架：Entry 的编码与解码

== 费曼直觉

把一条记录写进字节流后，读取者要能从这些字节找回键和值的分界。先抄出测试真正观察到的结果，再把它写成调用者看得懂的规格，最后依照规格实现。这一讲接续本日的通用模板和 11 月 14 日的 `Entry` 规格草稿。

#importantbox[从 `internal/db/kv_entry.go` 文件头的 Q1 起步。打开 `internal/db/kv_entry_test.go`，把你从固定 `data` 读出的证据填到 Q3 的 `Evidence (Q1)`，然后回到 `Entry` 写 Q2。]

== 硬核机制

#booktabs-table(
  columns: (0.85fr, 1.3fr, 2.8fr),
  [顺序], [源码位置], [本人填写的内容和核对依据],
  [Q1 读材料], [`kv_entry.go` 文件头], [对照讲义和目标测试，写出固定字节样例的四段边界、端序依据和首个键字节的位置。],
  [Q2 写规格], [`Entry`、`checkRep`、`Encode`、`Decode`], [核对抽象函数（AF，字段代表哪条记录）、表示不变式（RI，什么字段状态合法）与表示暴露（外部通过哪些路径能改到字段数据）。为两个方法填写调用者的条件 `Requires` 和实现的保证 `Effects`。],
  [Q3 写测试策略], [`TestEntryEncode` 上方], [从现有样例记录输入与初始状态、样例代表的输入类别，以及字节、错误、解码结果三条断言分别检验的保证。],
  [Q4 实现], [`kv_entry.go` 文件末尾], [设计编码的记录边界和解码读入、赋值的时机，再完成两个函数体。],
  [Q5 验证], [`kv_entry_test.go` 测试之后], [单跑 `TestEntryEncode` 确认确实执行，再跑同包测试，把命令结果和规格问题一并交卷。],
)

后一个动作使用前一个动作的交付物。Q1 的发现先记在 `Evidence`，Q2 才有依据区分调用条件与保证，Q3 才能逐条把保证对应到断言。阅读采用 MIT 6.102 sp26 的 T02（R02，Documenting your testing strategy）、T05（R04，Specification structure）、T09（R07，Documenting the AF, RI, and safety from rep exposure）。MIT 6.031 sp21 R03 的 Using multiple partitions 补充了按多个维度挑代表用例的理由。

== 陷阱与易错

#warningbox[讲义的示例混入了 0103 的删除标志。项目测试与 0102 starter 的 `TestEntryEncode` 对此给出同一份固定数据。拿这份数据核对第一个键字节的位置。]

把 RI 草稿中的 `len` 上限作为证据题保留在源码，连同原有的 `checkRep` 函数体。长度字段的宽度和被编码的键值长度是两个问题。`Entry{}` 也要分清测试在哪个时刻使用它，以及什么状态适用草稿中的检查。空键值、长度上限、所有权、分块读取、截断和尾随字节等仍记为 `TODO(阶段末)`。

== 关键点

用同一组字节分别对齐两条因果链。编码从给定记录推得字节，解码从测试给定的字节还原记录。测试里的解码输入来自固定的 `data`，所以两步各有直接的比较依据。

== 变式检验

Q3 留了一个反例。假设编码和解码一起换了端序，指出现有测试里最早能发现问题的断言，再解释只保留编码接解码的往返比较时，为什么可能出现不同结果。

== 同类归类

PNG 解码器读图像块时，以大端解释开头的 4 个长度字节。ZIP 目录读取器用小端解释 32 位字段，并向后推进 4 字节。读错端序，长度或尺寸就可能变成另一个数字，随后会从错误的位置取数据。0102 也要按规定解释字节，具体端序要从本步自己的格式与断言取得。

+ PNG 的关键行是 `length := binary.BigEndian.Uint32(d.tmp[:4])`。出处为本机 `/usr/lib/go/src/image/png/reader.go:870` 的 `parseChunk`。
+ ZIP 的 `readBuf.uint32` 中先做 `v := binary.LittleEndian.Uint32(*b)`，再做 `*b = (*b)[4:]`。出处为本机 `/usr/lib/go/src/archive/zip/reader.go:705`。

== Go 语言机制补充

假设一个监测程序接收设备的四字节计数。计数可能从文件或内存来，所以读取函数只要求数据源能提供字节。字段宽度固定，如果误把未读满的缓冲区当作完整字段，计数就可能错。0102 也需要分别判断字节是否够用、字节如何解释。下面只演示监测程序的单个计数。

`io.Reader` 是接口，也就是由方法描述的能力，这里是提供 `Read` 方法。`bytes.NewReader` 让一串内存字节拥有这项能力。`field[:]` 是字节切片，给出对 `field` 数组中这些字节的访问，`io.ReadFull` 能通过它写回数组。`uint32` 是 32 位无符号整数，端序规定哪个字节放在整数的低位。端序的选择是格式约定。记忆锚点是小端先放低位，大端先放高位。确定端序后，具体数值可以用移位推导，详见 `go doc encoding/binary.ByteOrder`、`go doc io.Reader`、`go doc -src io.ReadFull` 和 `/usr/lib/go/src/encoding/binary/binary.go:90`。

#codelisting(
  (```go
  package main

  import (
      "bytes"
      "encoding/binary"
      "fmt"
      "io"
  )

  func main() {
      var input io.Reader = bytes.NewReader([]byte{1, 2, 3, 4})
      var field [4]byte
      n, err := io.ReadFull(input, field[:])
      if err != nil {
          panic(err)
      }
      fmt.Println(n, binary.BigEndian.Uint32(field[:]),
          binary.LittleEndian.Uint32(field[:]))
  }
  ```).text,
  lang: "go",
  caption: [保存为临时 `telemetry.go` 后运行 `go run telemetry.go`],
)

先确认收到 4 字节，再解释字段。实际输出 `4 16909060 67305985`，三项依次是字节数、大端数值和小端数值。同一输入可以按两条规则解释，程序要选格式所规定的一条。

== 本次操作与当前状态

读取本日笔记的导师接续规则和通用模板、11 月 14 日的 `Entry` 规格草稿、0102 讲义及 starter 测试。使用 `software-construction` 改写 `internal/db/kv_entry.go` 的练习注释，并在 `internal/db/kv_entry_test.go` 加入测试策略和验证框架。本轮从磁盘核对已有测试，按项目约定提供可填写的骨架。与修改前的快照比较，两份 Go 文件的非注释内容一致。

`gofmt -l internal/db/kv_entry.go internal/db/kv_entry_test.go` 无输出，`go doc -all ./internal/db` 能读到新规格框架，临时 Go 示例运行成功。改前改后运行目标测试都以 `missing function body` 编译失败。改后报告 `kv_entry.go` 的 `Encode` 与 `Decode` 声明处，测试断言尚未执行。0102 仍在规格和测试策略阶段。先填写 Q1 至 Q3，再依据规格完成 Q4 和 Q5；贴出本步测试与作答后可逐项评测。

#codelisting(
  "go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/\ngo test ./internal/db/",
  lang: "bash",
  caption: [完成 Q4 后在项目根目录执行的 Q5 命令],
)

当日 Typst 文件追加本节，机械自检后用本机包缓存编译出同级 PDF。

=== Q2 与 Q3 的源码填空模板

沿用 `docs/go-construction-templates.md`，把上一轮的判别题和可填的格式放在一起。尖括号内是本人填写的空格。每条规格和每条用例都可以用题号对照。

#booktabs-table(
  columns: (1fr, 1.45fr, 2.45fr),
  [题号], [模板位置], [待填内容],
  [Q2.1], [`Entry` 上方], [AF 的映射、RI 的适用时机与字段条件、表示暴露的路径和依据。保留之前的 AF/RI 草稿供核对。],
  [Q2.2–Q2.3], [`Encode` 与 `Decode` 上方], [调用条件和成功时的效果。编码填写四段的范围、内容和编码约定，解码填写返回值与字段的最终状态。],
  [Q3.1], [`TestEntryEncode` 上方], [Q1 的依据、输入域、分区、边界和已覆盖的子域。],
  [Q3.2], [同一测试上方的 Go 注释], [为 Encode 与 Decode 填用例名、对应子域与 `Effects`、准备（Arrange）、执行（Act）与断言（Assert）。待填的预期为 `wantBytes`、`wantErr` 和 `wantEntry`。],
)

#importantbox[先填写 Q2 的 `Effects`，再引用对应条目填写 Q3.2 的期望。通过同一条现有样例核对规格、用例和断言能否连起来。]

#warningbox[期望值应由规格和固定测试输入独立推得。若把 `input.Encode()` 的结果填为 `wantBytes`，即使编码字节偏离规格，实际和期望也可能相等。已有样例未确定的边界继续记 `TODO(阶段末)`。]

Go 标准库的 `encoding/binary` 为固定格式读取和写入各准备一份对照。写入测试调用 `buf, err := enc.fn(order, s1)`，随后以单独传入的 `b` 比较实际字节。标准库用 `t.Run` 为共享同一预期的不同实现命名。0102 只有当前固定样例，因此用注释里的单条用例骨架即可。出处为 `/usr/lib/go/src/encoding/binary/binary_test.go:198` 的 `testWrite` 和紧随其后的 `TestLittleEndianWrite`。

仓库内可运行的填表示例在 `examples/construction/stock_test.go`。发料时库存恰好够用应成功，且剩余库存为零，以防实现把相等情形错误地拒绝。该行同时准备初值与独立的期望，和 0102 的组织方式相同，具体库存承诺归发料台。`t.Run` 是给用例命名的标准库方法，单跑该用例可用 `go test -count=1 -v -run '^TestStockTake$/^B_exact_stock$' ./examples/construction`。

=== 本轮补充的操作与验证

补写 `internal/db/kv_entry.go` 和 `internal/db/kv_entry_test.go` 的注释模板。用快照比对通过，两份 Go 文件的非注释行一致。`gofmt -l` 无输出，`go doc -all ./internal/db` 读出模板，发料台指定用例通过。`go test -count=1 -v -run '^TestEntryEncode$' ./internal/db/` 仍因 `Encode` 与 `Decode` 缺少函数体而编译失败，尚未进入断言。当天笔记追加本节，机械自检后编译同级 PDF。下一步由本人填写 Q2 和 Q3 的尖括号，再继续原有的 Q4 实现和 Q5 验证。

// 轨道：CS 轨
= Go 中 `checkRep` 的常用机制

== 费曼直觉

表示不变式（RI）描述内部字段在指定时刻必须满足的条件。`checkRep` 是实现者写的普通方法，把这些条件转成可以执行的检查。有了检查，就能在产生坏状态的操作附近看到失败，避免它被传给后面的代码。

#importantbox[先问「此刻为什么应当满足 RI」。如果内部已经承诺维护的条件被破坏，可以用 `if` 加 `panic` 尽早暴露缺陷。]

== 硬核机制

#booktabs-table(
  columns: (1.25fr, 1.4fr, 2.35fr),
  [场景], [Go 机制], [结果],
  [在正常运行中发现内部状态违反已定的 RI], [`if` 加 `panic`], [到达 `checkRep` 时执行条件判断，失败时中断当前正常执行路径。],
  [在测试中检查内部状态], [`t.Helper()` 加 `t.Fatalf(...)`], [将辅助函数标记为测试帮手，使失败位置指向调用点。`Fatalf` 报告失败并停止当前测试。还可用 `t.Errorf` 标记失败后自行决定是否继续。],
  [检查调用者传来的数据，失败是接口允许的结果], [`if` 加 `return` 一个 `error`], [`error` 是调用者可以接收和处理的错误值，通常由调用者决定如何应对。],
)

Go 的 `assert` 是普通名字。项目中的 `assert.Equal` 来自 `github.com/stretchr/testify/assert`。Go 保留字可查看 `/usr/lib/go/doc/go_spec.html` 的 Keywords。Java 的 `assert` 是可启用或停用的语句。TypeScript 的 `asserts condition` 是函数签名的一部分，让编译器在调用正常返回后按条件缩小类型范围。真正运行的检查由函数体提供。#link("https://docs.oracle.com/en/java/javase/26/docs/specs/jls/jls-14.html#jls-14.10")[Java 语言规范 §14.10] · #link("https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#assertion-functions")[TypeScript · Assertion Functions]

== 陷阱与易错

#warningbox[检查点要和 RI 的适用时机对齐。`TestEntryEncode` 先创建 `Entry{}` 再调用 `Decode`。若把只适用于解码完成状态的条件在入口就检查，会把测试允许的初始状态判成错误。]

当前 `Entry.checkRep` 已有 `if` 加 `panic` 的写法。它的条件要等 Q2.1 核对依据。检查该条件是否适用时，可以先比较 `Decode` 写入字段之前和成功完成之后的状态，再决定调用点。

== 关键点

用于诊断的检查信息应能指出哪项字段约束失效。方法由代码显式调用，到达调用点就会执行条件判断。MIT 6.102 sp26 T09（R07，Checking the rep invariant）在创建或修改表示的操作结束前检查 RI。测试里的 `Entry{}` 正好说明，要先弄清哪一步建立了 RI。

== 变式检验

假设发料台收到比库存更多的申请，调用者应能收到拒绝并决定如何处理。如果库存已经在合法扣减后变成负数，内部条件被破坏，应由检查指出负数来自哪项字段。这两个场景分别适用可返回的错误和内部状态检查。迁回 0102，只按当前规格判定哪些结果已经有测试依据。

== 同类归类

+ `strings.Builder` 的 `copyCheck` 在 `b.addr != b` 时调用 `panic`，诊断已使用的 Builder 被值拷贝后的非法用法。它在 `Write`、`WriteString` 等操作中执行。出处为 `/usr/lib/go/src/strings/builder.go:32`。
+ `container/heap` 的测试辅助方法 `verify` 先调用 `t.Helper()`，发现 `h.Less(j1, i)` 所示的堆顺序违例时通过 `t.Errorf(...)` 报告失败。检查在测试中由 `h.verify(t, 0)` 发起。出处为 `/usr/lib/go/src/container/heap/heap_test.go:35`，可运行 `go test -count=1 -v -run '^TestInit0$' container/heap`。

== Go 语言机制补充

发料台管理剩余件数。合法申请只能在库存足够时扣减，所以完成后剩余件数应当非负。若程序漏掉库存判断，负数可能悄悄传给下一次申请。和 `Entry` 一样，可以在操作应当建立或保持 RI 的位置检查。库存的非负条件只用于这个例子，`Entry` 的具体条件由它的规格和测试决定。

`(s *Stock)` 是指针接收者，表示方法作用在 `s` 指向的那个库存对象。`panic` 是内建函数。调用它时，Go 停止当前执行流的正常调用，沿调用链执行已登记的 `defer` 清理函数。若未被 `recover` 停止，程序以非零状态退出。`error` 则能像其他返回值一样交给调用者，例里的 `nil` 表示无错误。可查 `go doc builtin.panic`、`go doc builtin.recover`、`go doc testing.T.Helper`、`go doc testing.T.FailNow` 和 `/usr/lib/go/src/runtime/panic.go:809`。

#codelisting(
  (```go
  package main

  import "fmt"

  type Stock struct{ remaining int }

  func (s *Stock) checkRep() {
      if s.remaining < 0 {
          panic(fmt.Sprintf("stock: remaining = %d", s.remaining))
      }
  }

  func (s *Stock) take(n int) error {
      if n <= 0 || n > s.remaining {
          return fmt.Errorf("cannot take %d items", n)
      }
      s.remaining -= n
      s.checkRep()
      return nil
  }

  func main() {
      s := Stock{remaining: 2}
      fmt.Println(s.take(1))
      fmt.Println(s.take(2))
      s.remaining = -1 // 模拟一个内部缺陷
      s.checkRep()
  }
  ```).text,
  lang: "go",
  caption: [保存为 `stock.go` 后运行 `go run stock.go`],
)

第一次申请成功，得到 `nil`。第二次库存不足，返回 `cannot take 2 items`，调用者继续运行。最后刻意把字段设为负值，`checkRep` 按预期触发 `panic`，调用栈定位到这个检查。

== 本次操作与当前状态

读取当前 `Entry.checkRep`、`TestEntryEncode`、11 月 14 日的 RI 记录、MIT R07 与本机 Go 文档和标准库实现，核对了 Java 和 TypeScript 的官方资料。在临时目录运行 `go run stock.go`，确认成功分支、普通错误分支与最后的预期 `panic`。`go test -count=1 -v -run '^TestInit0$' container/heap` 通过。当天 `.typ` 追加本节并机械自检，编译生成同级 PDF。本轮只更新问答记录。继续 0102 时，先填写 Q2.1 的 RI 与适用时机，再据此选择检查点。
