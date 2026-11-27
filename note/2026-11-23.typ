#import "@preview/ilm:2.1.1": *

#show: ilm.with(
  raw-text: (font: "DejaVu Sans Mono"),
  title: [数学与 CS 问答笔记],
  authors: ("answer-note",),
  date: datetime(year: 2026, month: 11, day: 23),
  cover-page: none,
  table-of-contents: none,
  chapter-pagebreak: false,
  bibliography: none,
)

#align(center)[
  #text(size: 17pt, weight: "bold")[db-go 学习记录] \
  2026-11-23
]

= 0102 进度

接续 `2026-11-22.typ` 的交卷记录。已在 `log-based-kv` 保存 Entry 编解码、固定字节样本和学习记录，远端 `origin/log-based-kv` 已核对到 `4103056`。`go build ./...`、`go vet ./...` 和 `go test -count=1 ./...` 均通过。

= 0103 预习 · 追加日志与重放

对照 `db-web/docs/ch01-storage-basics.md` 的 0103 小节和上游 `db_project/0103/`。作者的 `TestEntryEncode` 用两组固定字节检查普通记录和删除记录。`TestKVBasic` 在关闭并重开后，检查曾删掉的 `k1` 仍查不到，保留的 `k2` 仍是 `v2`。同一键被多次写入后的重放顺序来自讲义，可用 Q6 的用例补证。

1. 从 `kv_test.go` 的 Q1 起步，先写下操作序列中每一步的状态以及重开后的 `Get` 结果，再标出作者测试覆盖到的部分。
2. 到 `kv_entry.go` 和 `kv_entry_test.go` 做 Q2。写清记录的抽象含义和字节格式，推导固定预期，再用空值和删除记录检查两种操作是否仍可区分。
3. 到 `log.go` 做 Q3，追踪文件偏移和 `Log.Read` 的三个结果。回到 `kv.go` 完成 Q4–Q5，写出打开、重放、关闭与更新的可观察效果。把「日志写入返回错误后，此刻还能从 `Get` 看到什么」写成一句可核对的契约。
4. 按 Q6 把 Q1 中缺失的观察变成用例。关闭写入者，用同一路径和新 `KV` 检验恢复结果。

规格用 6.102 R04 的 `require` 与 `effects` 写法，测试按 R02 记录分区及用例覆盖的子域。#link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[6.102 R04 · Specification structure] · #link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[6.102 R02 · Documenting your testing strategy]

== 验收入口

源码已写入 `TODO(learning)` 题面。仓库里的 `TestEntryEncode` 和 `TestKVBasic` 仍是现有步骤的版本。引入或迁移 0103 测试后，先核对详细输出确实运行了对应的新断言，再跑同包和全仓检查。

```bash
go test -count=1 -v -run '^Test(KVBasic|EntryEncode)$' ./internal/db/
go test ./internal/db/
go vet ./...
go build ./...
go test ./...
```

Go 语言机制补充。`io.ReadFull` 在一个读取段刚开始且一个字节也没读到时可返回 `io.EOF`，读到部分字节后遇到结尾则返回 `io.ErrUnexpectedEOF`。用一条完整记录之后的空读，与只剩半个头部的读取比较，写出 Q3 的预期。可查本机 `go doc io.ReadFull`。

#pagebreak(weak: true)

= 0102 为什么补这些 Entry 测试

*规格决定什么行为算对，测试设计决定选什么输入才看得出实现写错了。* `Testing strategy` 列出了覆盖的分区。选择这些分区的理由，可以用每组数据能暴露的错误来说明。

原作者的 `TestEntryEncode` 选了 2 字节键和 3 字节值。它用手写的固定字节检查 `Encode`，再把同一份固定字节交给 `Decode`。这样两个方向各有独立的预期，即使两边碰巧使用了同一个错误格式，仍可用固定样本发现错误。

== `TestEntryRecordFormat` 为什么选这些数据

#table(
  columns: (1fr, 2.6fr),
  table.header([*测试数据*], [*能观察到的错误*]),
  [空键、空值、两者都空],
  [规格允许字段长度为 0。解码前故意放入旧键和旧值，能抓住「长度为 0 就跳过赋值，导致旧内容留下来」。],
  [键比值短、等长、比值长],
  [值的起点是 `8 + K`。误写成 `8 + V` 时，等长用例会碰巧通过，不等长的用例会暴露错误。原作者样例已覆盖键较短，另外两种关系由补充用例覆盖。],
  [`255` 和 `256` 字节，键和值各跨一次],
  [小端长度从 `ff 00 00 00` 变为 `00 01 00 00`。只写最低一字节时，原例的 `2`、`3` 和这里的 `255` 都能通过，到了 `256` 就会失败。两个字段各测一次，可发现只写错其中一个字段的情况。],
  [键中包含 `0x00` 和 `0xff`],
  [规格要求保存原始字节。这组数据能抓住遇到 `0x00` 就截断，或把 `0xff` 当作无效文本替换掉的实现。],
)

每行的预期头部按规格手写，再拼上已知的键和值。`Encode` 比较整条记录，`Decode` 从这份独立样本读取，并分别比较键和值的内容。见 `internal/db/kv_entry_test.go` 的 `TestEntryRecordFormat`。

== 两个专项测试

- *`TestEntryDecodeShortReads`* 检查读取方式。`Decode` 的规格说，只要 `r` 提供完整记录，就应成功。Go 的 `io.Reader` 允许一次 `Read` 只返回一部分字节，`OneByteReader` 就让每次读取只交付一个字节。一个只调用一次 `Read` 就开始解释 8 字节头部的实现，可能通过原作者的内存缓冲区样例，却会在这里失败。
- *`TestEntryEncodeIndependentBytes`* 检查调用者改写结果的影响。`Encode` 承诺返回 `fresh byte slice`。测试把第一次返回的 `k/v` 改成 `K/V`，再编码一次，期望仍得到 `k/v`。现有断言还有一个缺口。如果实现复用同一块输出缓冲区，每次调用都重填正确字节，测试仍会通过。要直接验证两次返回的切片彼此独立，可同时保留两份结果，修改其中一份，再检查另一份。

本次重跑 `go test -count=1 -v -run '^TestEntry' ./internal/db/`，相关用例全部通过。这组补测主要覆盖 0102 的成功路径。`Decode` 的「读取失败时保留旧键值」规格在 11 月 22 日用临时检查验证过，仓库中的这组测试尚未覆盖它。

#pagebreak(weak: true)

= 从一个反例写出 Go 的 Entry 测试

写测试时可以先问：一个写错的实现，为什么还能通过现有测试？想到一种具体错误后，再倒推输入、接收者的初始状态和断言。下面用 `TestEntryRecordFormat` 里的「键非空、值为空」走一遍。

== 选输入，也选接收者的初始状态

假设有人写 `Decode` 时觉得，新值长度是 0 就可以省掉赋值。

```go
if len(val) > 0 {
    ent.val = val
}
```

原作者样例的新值是 `"xxx"`，所以条件成立。即使把输入换成空值，接收者若是 `Entry{}`，原本就没有值，检查结果时仍可能通过。为区分这两种实现，我让输入记录的值为空，并让接收者原先存着 `"previous value"`。规格说成功解码后，键和值都应与输入记录一致，所以预期是旧值被清掉。

用临时编译覆盖引入这个错误后，原作者样例仍然通过。空值子测试则在 `internal/db/kv_entry_test.go:114` 报出预期 `""`，实际 `"previous value"`。恢复使用工作树里的原实现时，定点子测试通过。

== 先把一个用例写直

下面的独立示例与仓库里那一行的 `Decode` 子测试表达相同的行为。示例使用测试文件已有的 `bytes`、`testing`、`assert` 和 `require`。

```go
func TestDecodeClearsPreviousValue(t *testing.T) {
    wire := []byte{
        1, 0, 0, 0, // 键长为 1
        0, 0, 0, 0, // 值长为 0
        'k',       // 键的内容
    }
    ent := Entry{key: []byte("old"), val: []byte("previous value")}

    err := ent.Decode(bytes.NewReader(wire))

    require.NoError(t, err)
    assert.Equal(t, "k", string(ent.key))
    assert.Equal(t, "", string(ent.val))
}
```

1. *准备。* `wire` 是按规格手写的 9 个字节，`ent` 是已有旧内容的接收者。测试和实现都在 `package db`，所以可以直接用小写字段 `key`、`val`。
2. *调用。* `wire` 是 `[]byte`，`Decode` 接受 `io.Reader`。`bytes.NewReader(wire)` 把内存字节包装成能依次读取的数据源。
3. *检查。* `require.NoError` 失败时结束当前测试。`assert.Equal` 先传预期，再传实际。一个字段的比较失败后，另一个仍能继续检查。将 `[]byte` 转成 `string` 会保留原始字节内容，并让 `nil` 和空切片都按零字节比较。

#pagebreak(weak: true)

== 从规格取得预期字节

`wire` 的预期直接来自规格。如果用 `ent.Encode()` 生成输入，编码和解码可能一起把两个长度字段写反又读反，往返结果仍会正确。固定样本让两边各有可核对的预期。

Go 标准库的 `encoding/binary` 也用预先定义的小端字节分别检查读和写。可查 `binary_test.go` 的 `TestLittleEndianRead` 与 `TestLittleEndianWrite`。

== 数据有变化时再提炼成表

各个格式用例重复的是「准备记录、调用、比较」，变化的是名字、键、值和预期头部。仓库把变化项放在 `cases := []struct { ... }` 中。这个类型可以读作「一个切片，其中每个元素是一行用例数据」。

```go
{
    name:       "covers nonempty key and empty value",
    key:        []byte("k"),
    wantHeader: [8]byte{1, 0, 0, 0, 0, 0, 0, 0},
},
```

省略的 `value` 取 `[]byte` 的零值 `nil`，表示空值。`[8]byte` 是长度固定为 8 的数组。`tc.wantHeader[:]` 把数组变成可传给 `slices.Concat` 的切片，拼接出头部、键和值组成的记录。

循环每取一行，就用 `t.Run(tc.name, ...)` 创建一个有名字的子测试，里面再分 `Encode` 和 `Decode`。失败时可以从名字看到是哪组数据、哪个方向出了错。编码前用 `bytes.Clone` 复制测试表里的键和值，防止被测代码意外改写用例数据，影响后续检查。表格与循环见 `internal/db/kv_entry_test.go:49` 和第 101 行。

下面的命令已实际运行，输出只包含空值用例下的 `Decode` 子测试及其父级。

```bash
case_pattern='^covers_nonempty_key_and_empty_value$'
go test -count=1 -v \
  -run "^TestEntryRecordFormat$/$case_pattern/^Decode$" \
  ./internal/db/
```

== 用同样的推理设计失败用例

先填一句话：「如果实现犯了某个错误，我要让调用前处于什么状态，给它什么输入，然后检查什么？」以 `Decode` 的另一条规格为例，读取失败时应保留旧键和值。想观察有没有过早更新键，可以提供完整头部和完整新键，但在值中途截断。这样实现已经读到新键，之后才发现失败。接下来分别检查返回了错误、旧键仍在、旧值仍在。把失败安排在读到新键之后，才能从结果中观察到是否发生了部分更新。

#pagebreak(weak: true)

= 两个 Entry 专项测试的设计理由

== 逐字节读取检验 `Decode` 接受的数据源

`Decode` 接受 `io.Reader`。一次 `Read(p)` 可以只填一部分 `p`，同时返回 `err == nil`。所以即使完整记录最终会到达，解码器也要判断当前字段是否已读满。

测试把同一条完整记录包在 `iotest.OneByteReader` 里。请求读取 8 字节头部时，第一次只能拿到第一个 `02`，后面的 7 字节仍要继续读。键 `k1` 和值 `v2` 也各有两个字节，所以三个字段都会遇到短读。一个直接使用 `Read` 返回的缓冲区、假定每段都已读满的实现，会在这里解析错长度或内容。断言同时检查返回值和键值内容，能抓住报错以及错误地返回成功这两种结果。可查 `go doc io.Reader`、`go doc testing/iotest.OneByteReader`。

== 改写编码结果检验 `Encode` 的副本承诺

Go 的切片可以指向同一块底层数组。`Encode` 承诺返回一份新的字节切片，所以调用者可以改写结果，同时原 `Entry` 的键和值应该保持原样。测试故意修改 `encoded[8]` 和 `encoded[9]`。在这个样例中，它们正好是 `k` 和 `v` 的位置，改动会直接检验键和值是否受到影响。

第二次编码与独立的 `want` 比较。如果改写结果也把原 `Entry` 改成了 `K`、`V`，再次编码就会暴露这个变化。这里检查的是通过返回结果改写 `Entry` 的情形。如果实现复用输出缓冲区、且每次编码都重填正确字节，该测试仍能通过。要进一步检查两次返回的切片彼此独立，可以把两份结果同时留在手里，然后修改其中一份，并检查另一份。

测试动机已写到 `internal/db/kv_entry_test.go` 中各自的函数上方。分别从 `io.Reader` 的读取契约和 `Encode` 的独立副本承诺推导预期。

= 旧题记录 · 0103 日志重放 Q1

在 `log-based-kv` 从 `internal/db/kv_test.go:33` 的 Q1 接着做。先手推 `set a=old → set a=new → set b=gone → delete b`，写出每一步的键值状态，再预测关闭并重开后的 `Get(a)` 和 `Get(b)`，分别写下 `val`、`ok`、`err`。

对照 0103 starter 的 `TestKVBasic` 中 `reopen` 段，用一句话写清作者的断言覆盖了哪个结果、遗漏了哪个情形。Q1 的产物是一份预测和对应的测试证据。完成后接 Q2，将 0103 普通记录和删除记录的格式变化写成规格与固定字节用例。

工作区已有 `Log.Open`、`Close`、`Read`、`Write`。`Entry` 和 `KV` 仍处在重放改动之前。本次定点重跑的 `TestEntryEncode` 和 `TestKVBasic` 均通过，使用的是 0102 基线测试。

#pagebreak(weak: true)

= 0103 starter 已迁入

迁入来源是 `../db-web/db_project/0103/`，与同一步上游 starter 逐文件一致。迁入前，全仓构建、静态检查和测试均通过。

- `internal/db/kv_entry.go` 接入 0103 的删除标志和 9 字节头部。保留原来的表示检查、输出独立存储和读取失败时不更新字段的行为。合并时让删除记录只输出键，并在成功解码删除记录时清空旧值，避免复用 `Entry` 时将上一次的值夹带到删除记录中。
- `internal/db/kv_entry_test.go` 中的 `TestEntryEncode` 函数体与 0103 starter 一致。保留原字节格式、短读和独立存储测试，并把样本头部及载荷偏移迁到 0103。
- `internal/db/kv_test.go` 中保留一份 `TestKVBasic`。从第一次 `Open` 开始，测试体与 starter 一致。日志路径用 `t.TempDir()` 隔离，由 Go 在测试结束后清理。`KV` 已接入 `log Log` 和关闭方法。工作区现有的 `log.go` 已与 starter 核对。

迁入后，`go build ./...`、`go vet ./...` 和 `TestEntry*` 均通过。`go test -count=1 ./...` 在 `TestKVBasic` 重开后要求 `Get(k2)` 返回 `v2` 的断言处失败。当前 `Open` 仍只初始化内存，`Set` 和 `Del` 仍按原来的内存路径运行。这个失败是 0103 写日志与重放练习的验收入口。

练习范围核对。作者的 0103 starter 已经提供 `Log`、`Entry` 编解码和 `KV.Close`。迁入时的 `Entry` 调整还包括清空删除记录的旧值，因此 Q2 的格式和部分字段效果已有代码可以核对。Q1 的重放预测、Q2.4 的空值断言，以及 `KV.Open` 的重放和 `KV.Set`、`KV.Del` 的日志更新仍由学习者完成。

== Q1 作答区

- 每一步执行后的键值状态：
- 重开后 `Get(a)` 的 `val`、`ok`、`err`：
- 重开后 `Get(b)` 的 `val`、`ok`、`err`：
- 0103 作者测试的对应断言与遗漏情形：

== Q2.4 落点

在 `internal/db/kv_entry_test.go` 找到 `covers nonempty key and empty value` 这一行。把答案写成 `TestEntryRecordFormat` 的 `Decode` 子测试中的断言，放在现有键和值的比较之后。这个子测试会对格式表里的每一行运行。

#pagebreak(weak: true)

= 当前任务 · 0103 追加日志与重放

本清单按更新后的 `software-construction` 生成，接替前面的编号题。把实现和对应的规格写在 `internal/db/kv.go`。工作区已提供 `Log`、`Entry` 编解码和 `KV.Close`。

- *TODO:* 实现 `KV.Open`。通过 `Log.Open` 打开 `kv.log.FileName` 指定的日志，从空表开始按文件顺序应用记录。同一个键以后出现的操作为准，删除记录移除该键。空日志打开后得到可写的空表。正常读到结尾时打开成功，文件留给后续写入。打开或重放失败时返回错误，重放失败时关闭已打开的文件。
- *TODO:* 实现 `KV.Set` 的追加写入。新键或值发生变化时，先写普通 `Entry`，写入成功后更新内存并返回 `true, nil`。已有键的值字节相同，返回 `false, nil`。写入失败时返回 `false` 和该错误，内存值保持原样。沿用现有的键校验与值的防御性拷贝。
- *TODO:* 实现 `KV.Del` 的追加写入。对存在的键，先写标为删除的 `Entry`，写入成功后移除键并返回 `true, nil`。键不存在时返回 `false, nil`。写入失败时返回 `false` 和该错误，并保留原键值。沿用现有键校验。

== 实现时核对

`KV.Open` 对照 `Log.Read` 的两个返回值。读到记录是 `false, nil`，正常到末尾是 `true, nil`，读取出错是 `false, err`。注意重放和随后的写入共用同一个文件句柄，它的当前位置随读取前进。`KV.Set` 先看键是否存在，再比较值字节，避免把「缺失的键」当作「已有键存着空值」。`Set` 和 `Del` 都在日志写入成功后才改变内存。

== 验收

当前 `TestEntryEncode` 通过。`TestKVBasic` 已运行，失败在重开后的 `Get(k2)`。实现后运行下面的命令，核对 `k1` 已删除、`k2` 仍为 `v2`。

```bash
go test -count=1 -v -run '^Test(KVBasic|EntryEncode)$' ./internal/db/
go test ./internal/db/
go build ./...
go vet ./...
go test ./...
```

相同值不追加以及写日志失败时保留内存值，需对照 0103 讲义检查实现路径。作者测试提供关闭并重开的行为证据。

#pagebreak(weak: true)

== 补测同一键的重放顺序

按查询键在日志中的最后一条记录划分情况：从未出现、最后是写入、最后是删除。`TestKVBasic` 先写入再删除 `k1`，重开后断言 `ok` 为 `false`，因此覆盖了「最后是删除」。`k2` 覆盖「最后是写入」，但只写了一次，无法区分保留第一次的值和恢复最后一次的值。#link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#choosing_test_cases_by_partitioning")[MIT 6.102 Spring 2026 · Reading 2]

- *TODO:* 在 `internal/db/kv_test.go` 补一条重放测试。自己选一段最短的同键写入历史，使保留第一次和恢复最后一次产生不同结果。关闭写入者后，用一个新的 `KV` 打开同一临时文件，通过 `Get` 检查按规格推导的结果，并在测试策略里写明该用例覆盖的情形。调试 `Open` 时可用已有 `Log` 准备记录，以便单独观察重放路径。

验收时运行 `go test -count=1 ./internal/db/`。补测应能发现只保留某键第一次写入的实现，正确按顺序重放时应通过。检查循环时，将刚读完的日志前缀与内存表对照，两者应反映同一组键值。

== 日志文件名由谁决定

0103 的文件路径由调用者在 `Open` 前配置。作者的 `TestKVBasic` 把 `kv.log.FileName` 设为 `".test_db"`。当前项目改用 `filepath.Join(t.TempDir(), "test_db")` 隔离各次测试。`Log.Open` 把这个路径传给 `os.OpenFile`，文件不存在时创建，存在时打开供重放。

补测时先用一次 `t.TempDir()` 算出 `path`，再让写入者和重开的新 `KV` 都把 `log.FileName` 设为该路径。分别调用 `t.TempDir()` 会得到两个不同目录，即使基本文件名相同，也会打开两个文件。

公开接口通常由调用者传入完整文件路径，或传入数据目录，由数据库在其中固定命名内部文件。0103 的同包测试可以直接设置未导出的 `kv.log`。包外接口可以以后再设计。本步的 `KV.Open` 沿用调用者预先配置的路径。
