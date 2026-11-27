#import "@preview/ilm:2.1.1": *

#show: ilm.with(
  raw-text: (font: "DejaVu Sans Mono"),
  title: [db-go 学习记录],
  date: datetime(year: 2026, month: 11, day: 27),
  cover-page: none,
  table-of-contents: none,
  chapter-pagebreak: false,
  bibliography: none,
)

= 0103 写入失败的结构化日志

`Log.Write` 追加供数据库重放的记录。`slog.Error` 把运行时诊断交给当前日志处理器。`KV.Set` 和 `KV.Del` 在写入失败时使用固定消息 `failed to append database log record`，并附上操作 `op`、文件路径 `path` 和原始错误 `error`。可按 `op` 或 `path` 筛选。诊断只取这些字段，避免把数据库键值带进日志。

```go
if err := kv.log.Write(&ent); err != nil {
    slog.Error("failed to append database log record",
        "op", "set", "path", kv.log.FileName, "error", err)
}
```

== Go 语言机制补充

`slog.Error` 使用默认 `Logger`。消息之后的实参按「字段名、字段值」成对出现。应用入口可以通过 `slog.SetDefault` 设置统一的输出方式。以下一行让日志以 JSON 写到标准错误。

```go
slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stderr, nil)))
```

对于 `Open` 和 `Close` 这样的可返回错误，通常在调用方决定重试、退出或统一记录，避免同一错误沿调用链重复输出。本次为 0103 调试显示了原来被丢弃的写入错误。调用方目前仍可能收到成功结果，0103 的目标是先成功追加，再更新内存状态，并把写入失败返回给调用方。#link("https://go.dev/blog/slog")[Go 官方 slog 指南]

== 本次操作与当前状态

`go build ./...`、`go vet ./...` 通过。临时测试对比了打开和已关闭的文件。打开的文件写入时没有诊断，关闭后 `Set` 和 `Del` 各产生一条含对应 `op` 的 `ERROR`。

`TestKVBasic` 在改动前后都无法在重开后读到 `k2`。新增输出给出 `write .test_db: file already closed`，对应 `KV.Open` 在返回前调用 `kv.log.Close()`。测试在临时目录运行以保留工作树里的 `.test_db`。0103 仍在实现阶段。

#pagebreak()

= 0103 交卷检查 · 追加日志与重放

== 本次操作与当前状态

`TestKVBasic` 和 `TestEntryEncode` 的函数体与 `db-web/db_project/0103/kv_test.go` 一致，定点执行都通过。`go test -count=1 ./...`、`go build ./...` 和 `go vet ./...` 也通过。测试进程使用临时工作目录，隔离作者测试固定使用的 `.test_db`。

隔离实验用一个新的 `KV` 打开同一文件，确认同键写入两次后恢复最后的值。修改传给 `Set` 的键和值、修改 `Get` 返回的切片，都没有改变库里的值。空值可存储，重开后仍能查到。成功路径已符合所观察的行为，以下三项仍待复验。

1. `Open` 与 `Log.Read`。完整头部之后缺整个键或整个值时，`Open` 返回 `nil`。头部只剩一部分或值只剩一部分时，`Open` 返回读取错误，文件句柄还开着。先把「记录边界遇到 EOF」与「记录中途截断」写进契约，再检查失败分支是否关闭已打开的文件。重放可用一个循环不变式检查，每读完一条完整记录，当前键值等于重放该日志前缀后的结果。
2. `Set` 和 `Del` 写失败。用只读文件句柄触发写失败，两处都执行 `panic("log write failed")`，实验确认旧值仍在。现有的先写后改顺序正确。按本步规格检查是否返回 `false` 和 I/O 错误，再通过 `Get` 验证旧值。把断言用于内部表示不变式，文件写入失败通过 `error` 交给调用方。
3. `Set` 同键同值。第二次返回 `true, nil`，日志从 11 字节增长到 22 字节。按键缺失、已存在且值相同、已存在且值不同划分状态。相同值用返回值和文件长度联合验证。缺失键写入空值也应建立新映射。

== 用 6.102 检查规格和测试

- T05 / R04 规格。`Open` 的注释写清空即成功，需描述重放后可查询的状态和 I/O 错误。`Get(nil)` 的注释承诺错误，当前实现对一般打开的空库返回 `nil, false, nil`。用 `require` 说明可调用的状态，用 `effects` 写清返回值、错误与可观察变化。#link("https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure")[R04 · Specification structure]
- T09 / R07 抽象函数与表示不变式。`KV` 表示从键字节序列到值字节序列的映射。当前 `len(value) >= 1` 与已验证的空值行为矛盾。说明 `string(key)` 按字节保存键，`Set` 和 `Get` 分别复制进入和离开表示的值。再逐条核对 `Open`、`Set`、`Del` 是否建立或保持选定的不变式。#link("https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#documenting_the_af_ri_and_safety_from_rep_exposure")[R07 · AF、RI 与防止表示暴露]
- T02 / R02 测试。在 `kv_test.go` 用 `t.TempDir()` 建独立数据库，按分区命名子测试。重放可区分空日志、同键最后写入、同键最后删除和截断记录。用 `require.NoError` 确认打开成功，再观察后续行为。`TestEntryRecordFormat` 已有独立字节样本和明确分区，可以沿用这个写法。#link("https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy")[R02 · Documenting your testing strategy]

== Go 语言机制补充

`io.ReadFull` 完全没读到字节时可返回 `io.EOF`。读完记录头之后遇到这种 EOF 已属于记录截断。`bytes.Equal` 把 `nil` 和空切片视为相等，比较前要用 `ok` 确认键存在。下次先用「头部完整、键缺失」的固定样本复验 `Open` 返回错误且关闭句柄。
