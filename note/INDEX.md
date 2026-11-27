# Go 问答笔记索引

本目录按天归档问答：一个 `= 主题`（一级标题）= 一个独立问题。`.typ` 是源码，同名 `.pdf` 是编译结果。

## 高频主题速查

| 想查什么 | 去哪一节 |
|---|---|
| **0101 当前作业还有哪些问题（契约 / 实现 / 规格 / 测试 / 工程卫生五类）** | `2026-11-07.typ` → `0101 当前作业的问题清单：规格 / 测试 / 实现三层的缺口` |
| **AF/RI/表示暴露的概念重讲 + Go 表达手段（ADT 形状 / 存在性 / 所有权 / 错误 / 测试）** | `2026-10-24.typ` → `重讲与 Go 落地：从概念到语言手段` |
| **map 类 rep 的 AF 怎么写（映射构造式 / 函数式 / 条目集合）** | `2026-10-24.typ` → `map 类表示的抽象函数怎么写` |
| **RI 怎么写、记录成什么样式（字段旁注释 / 与 `checkRep` 对应）** | `2026-10-25.typ` → `RI 的写法与记录样式` |
| **思考 RI 的六个层面（值 / 结构 / 生命周期 / 边界 / 规格 / 工程）** | `2026-10-26.typ` → `思考 RI 的六个层面` |
| **TDD 怎么在 `kv.go` 里做（红-绿-重构 / `go test` 命令与缓存）** | `2026-10-15.typ` → `在 kv.go 里落地 TDD：红-绿-重构的完整一轮` |
| **0101 步骤 0 评估：AF / RI / Safety 三段与测试分区（只给判定，不给答案）** | `2026-10-31.typ` → `0101 步骤 0 评估：AF / RI / Safety 与测试分区` |
| **ADT 测试怎么组织：operation 与 partition 是两层（Counter 完整示例）** | `2026-10-31.typ` → `ADT 测试怎么组织：operation 是外层，partition 是内层` |
| **做项目时怎么积累面试素材（考研并行：决策日志 / 故障档案 / 与 408 绑定）** | `2026-10-16.typ` → `考研并行下做项目：动手之外的"证据工程"` |
| **Go 项目的构建流程（规格 → 测试 → 实现 / ADT 配方）** | `2026-10-17.typ` → `用 Go 走一遍构建流程：规格 → 测试 → 实现` |
| **实验代码放哪 / 怎么让它不被 `go build ./...` 带上** | `2026-10-11.typ` → `学习实验用的 scratch/ 目录怎么设计` |
| **Go 有没有 assert / 防御性编程该怎么做** | `2026-10-13.typ` → `Go 有没有 assert？防御性编程在 Go 里怎么做` |
| **Go 关键字怎么查 / `gokw` 怎么用（四条命令 · 四种判定）** | `2026-10-11.typ` → `有什么方法可以方便查阅 Go 的关键字`、`gokw 怎么用` |
| **内置类型（map / slice / chan）的文档怎么查** | `2026-10-04.typ` → `怎么用 go doc 查 map 相关的内容` |
| `m[k]` 运行时到底做了什么（哈希 / 指纹 / Swiss table） | `2026-10-07.typ` → `` `m[k]` 在运行时到底做了什么 `` |
| `defer` 的执行时机 / 三个常见坑 | `2026-10-07.typ` → `` `defer kv.Close()` 是什么意思 `` |
| go doc 的基本用法与四档粒度 | `2026-10-01.typ` → `怎么用 go doc 查标准库的用法与实现` |
| 该调用哪个 API、怎么读懂返回值 | `2026-10-04.typ` → `该查哪个 API，以及怎么读懂它的返回值` |
| 泛型签名怎么读 | `2026-10-04.typ` → `逐段读懂一个泛型函数声明` |
| 泛型有什么用 | `2026-10-04.typ` → `类型参数（泛型）到底是做什么用的` |
| `:=` 与 `=` 的区别（查语言规范） | `2026-10-04.typ` → `` 怎么查 `:=` 与 `=` 的区别 `` |
| `m[k]` 返回几个值 / comma-ok 规则 | `2026-10-04.typ` → `` `kv.mem[string(key)]` 到底返回什么 `` |
| go.mod 每一行是什么意思 | `2026-09-30.typ` → `go.mod 逐行讲解` |
| 目录/包怎么组织 | `2026-09-30.typ` → `想分成 test 和 db 两部分…`、`用测试驱动开发…` |
| 报错排查方法论 | `2026-09-30.typ` 后三节 + `2026-10-01.typ` → `回顾：undefined: KV…` |

## 按日期

### 2026-09-30（9 节，51 页）
- 为什么 `testify/assert` 报 BrokenImport，以及怎么修
- go.mod 逐行讲解
- 为什么 `test/kv_test.go` 报 undefined: KV
- 为什么不能 import "db/KV"
- 为什么 kv.go 会报 missing function body
- 想分成 test 和 db 两部分，Go 社区怎么组织目录
- 用测试驱动开发，Go 的目录结构怎么摆
- 官方仓库里的 test/ 目录是怎么回事
- go vet 通过 ≠ 能编译

### 2026-10-01（4 节，20 页）
- 为什么包名改成 db 了，还是报 undefined: KV
- 补全 KV 的三个方法：先确认语义，再动手
- 回顾：undefined: KV 到底是在哪里修好的
- 怎么用 go doc 查标准库的用法与实现

### 2026-10-03（1 节，9 页）
- 给 go doc 配上一组 fish 函数（bat 高亮 + godochelp 自述）

### 2026-10-04（8 节，43 页）
- 当日起点：项目与工具状态
- `map[string][]byte{}` 背后调用了哪些 API
- 该查哪个 API，以及怎么读懂它的返回值
- 怎么用 go doc 查 map 相关的内容
- 逐段读懂一个泛型函数声明
- 类型参数（泛型）到底是做什么用的
- `kv.mem[string(key)]` 到底返回什么
- 怎么查 `:=` 与 `=` 的区别

### 2026-10-07（3 节，15 页）
- 当日起点：项目状态与一处待修的语义
- `m[k]` 在运行时到底做了什么
- `defer kv.Close()` 是什么意思

### 2026-10-11（4 节，19 页）
- 当日起点：项目状态与工具状态
- 有什么方法可以方便查阅 Go 的关键字（含新装的 `gokw`：分组速查 / 单词判定 / 规范原文）
- 学习实验用的 scratch/ 目录怎么设计（一个实验一个子目录；`_` 前缀可隐身，出处 `go help packages`）
- gokw 怎么用（四条命令、四种判定结论、fish autoload 机制；本轮修了 `_` 特例与大小写提示两处判定瑕疵）

### 2026-10-13（3 节，12 页）
- 当日起点：项目状态与工具状态（两天没动代码；待办仍是补 `Del` + 定 `Get` 未命中语义）
- Go 有没有 assert？防御性编程在 Go 里怎么做（FAQ 原文 + 各语言断言对照 + 三层防御 + 三条实测）
- 把 defer 探针代码放进 scratch/defer/（截图被截断的 ⑤ panic 情形按笔记补写；输出与 10-07 逐字一致）

### 2026-10-15（2 节，16 页）
- 当日起点：项目状态与工具状态（两天没动代码；待办仍是补 `Del` + 定 `Get` 未命中语义）
- 在 `kv.go` 里落地 TDD：红-绿-重构的完整一轮（沙盒三阶段实测：编译型红 → 断言型红 `kv_test.go:22`/`:31` → 绿；`(cached)`/`-count=1`/本目录模式三态对照；`go vet` 对 `missing function body` 静默的最小对照；给出“补 `Del`、改 `Get` 未命中”两步与 `Set` 语义的下一轮考卷）

### 2026-10-16（2 节，12 页）
- 当日起点：项目状态与工具状态（`kv.go` 的 `Del` 仍未补，`go build` 报 `missing function body`；10-15 的两条待办照旧）
- 考研并行下做项目：动手之外的"证据工程"（八个顺手动作：①决策日志 ②量化数字 ③故障档案 ④破坏实验 ⑤生产对照 ⑥叙事卡 ⑦公开痕迹 ⑧408 绑定；含 benchmark 模板、失效模式表、"复试 vs 求职"对照表；策略：初试前每周时间盒 + 每次收尾 15 分钟"蒸馏"）

### 2026-10-17（3 节，15 页）
- 当日起点：项目状态与工具状态（`Del` 仍缺函数体；`Get` 未命中契约与 `kv_test.go` 冲突；`go vet` 静默通过，`gofmt -l` 无输出）
- 用 Go 走一遍构建流程：规格 → 测试 → 实现（6.102 R07 · 6.031 R19）：方法/ADT/程序三层配方，KV 的操作分类、规格契约、AF/RI/表示暴露、8 分区测试四张表，三个待拍板决策，五步执行顺序与六条验收命令；不代写实现
- 交互式练习：KV 构建的第一批题目（练习 0/1/2；只加脚手架与注释，不改出题人断言；`go test` 保持红，等用户填写）

### 2026-10-24（2 节，15 页）
- 重讲与 Go 落地：从概念到语言手段（当前步骤对齐）：从零重建 ADT 三问、AF/RI/表示暴露的关系；Go 侧讲 ADT 形状、注释与 `checkRep` 的位置、存在性五手段、所有权三策略、错误两契约、表驱动测试与当前步骤工具箱；只列手段与取舍，不含项目答案或具体步骤；文件已按用户要求精简为仅保留本节
- map 类表示的抽象函数怎么写（AF for Map-shaped Reps）：三种标准写法（映射构造式、lambda、条目集合）、空 map/nil map 与定义域、非映射抽象值的例子、常见错误与自检三问；对 `mem` 只给结构模板与三个待答问题，不填内容

---

### 2026-10-25（1 节，10 页）
- RI 的写法与记录样式（Rep Invariant: How to Write and Record It）：RI 是 rep 上的布尔谓词、与 AF 定义域的关系、生命周期三条义务、五条判据（只谈 rep / 可判真假 / 精确 / 不过强 / 不过弱）、记录样式（字段旁注释、逐条条件、与 `checkRep` 一一对应）、三类子句、`mem` 的四行占位骨架与常见错误；补充「所有 key 的长度 > 0」的数学写法、RI 注释样式、Go 检查模式与过强/过弱的判断

---

### 2026-10-26（3 节，31 页）
- 思考 RI 的六个层面（Six Layers for Reasoning About Rep Invariants）：值层、结构层、生命周期层、边界层、规格层、工程层的核心问题、典型子句、Go 检查方式与失败后果；汇总表；对 `mem` 只列六行问题，不填答案；子节「单键谓词与键集合的全称量化」：谓词层 / 量化层 / 检查层三层分离、带背景的用户索引表示例、前置条件与 RI 的分工、RI 子句分类法；其下「谓词、量化与三层含义」：命题/谓词/代入的区分、全称与存在量化、空集合上全称量化恒真、常见混淆
- 讲解偏好：例子要带背景（独立问题）：场景 / 约束来源 / 反例 / 与项目关系四要素，附 `RatNum` 与 map 空键两个示范；同时写入 `AGENTS.md` 的「讲解偏好」与标题层级规则（最多三级）
- 测试分区的顺序：先 subdomain，后 cartesian product：subdomain / partition / cartesian product 的定义、推荐顺序（分区 → 组合 → 裁剪）、裁剪策略（全组合 / 单维基线 + 交叉 / pairwise / 等价类合并）、转账函数的带背景示例、与 RI 的类比、对当前项目的问题清单；子节「边界属于哪个阶段」：边界属于分区阶段的细化（单元素子域），不是列维度；分页函数示例与边界组合的裁剪；子节「Using multiple partitions 与 cartesian product 的关系」：两者不互斥（前者是后者的替代方案，也可混合）、材料三个关键句、阶段归属（multiple partitions 属分区设计，cartesian product 属组合）、乘法示例与操作建议；子节「操作分类在哪个阶段」：creator / producer / observer / mutator 是五步的外层循环，操作序列才是输入维度；Counter 示例与与 RI 的对应；子节「Testing an abstract data type 与五步的区别和联系」：ADT 测试是外层框架（操作分类 + 夹具 + 验证链 + 来源维度），五步是内层流程；MyString 测试策略与 `KV` 骨架

---

### 2026-10-31（2 节，18 页）
- 0101 步骤 0 评估：AF / RI / Safety 与测试分区：逐项判定（AF 的 `legal key` 未定义、RI 五条中两条无效 / 两条无维护者、Safety 空白、测试分区不完整）、与练习 1/2 的关系、优先级与自检清单、变式检验、Go 机制补充；只给评估不给答案；实测 `TestKVBasic` 失败于第 37 行断言、第 39 行 panic，`go vet` 通过
- ADT 测试怎么组织：operation 是外层，partition 是内层：三层（suite / strategy / case）的分工、`partition on operation` 是覆盖清单而非输入维度、ADT 的隐式输入（接收者状态 + 调用历史）、测试树与 `t.Run` 子测试、Counter 的完整可编译示例（状态分区 × 参数边界 + 序列组）、覆盖矩阵、序列测试、常见误区、Go 测试机制（`t.Helper` / `t.Cleanup` / `-run` 子测试）；未改 `KV` 代码或测试

---

### 2026-11-02（2 节，16 页）
- 0101 重置：红基线分类与 AF/RI/Safety 三问（KV Interface Spec）：红基线的四种分类（编译红 / panic 红 / 断言红 / 环境红）与本次实测（多余 `package` 行的编译红 → 修掉后 `Open` 处 panic 红）、AF 是全函数且定义域由 RI 决定、RI 生命周期三条义务（构造建立 / 入口可假设 / 出口恢复）、rep exposure 的三条路径（导出字段 / 返回值 / 外部可达结构）、AF 与 RI 与 Safety 同前置条件后置条件的四行分界表、`TestKVBasic` 七条断言与三份文档的对应关系、7 条断言与分区缺失（删除路径与时序子域）、IntSet 带背景变式、Go 切片头三元组与 `go doc reflect.SliceHeader`；含本次清空与备份、多余 `package` 行修复、两次红基线命令输出、P1–P6 待办卡

- db-go 全量题单（44 步，作者顺序）｜课程大纲：解锁与验收规则（贴出测试才解锁、按编号顺序推进、强度与测试一致）、44 步总表（任务 / 文件 / 验收口径）、章 → 概念 → 验收对照表、当前状态（仅 0101 已解锁）

---

### 2026-11-03（1 节，7 页）
- 0101 规格评审：AF / RI / Safety 三处修正（Spec Review）：AF 的抽象值形状（映射 vs 对的集合）与空 map 覆盖、RI 的三类子句（类型保证 / 表示性质 / 前置条件）与「写了 RI 却没维护者」的失效、防御性拷贝的双向性（入向 `Set` 存引用、出向 `Get` 返引用）、零值 nil map 与空 map 的区别；本次交卷判定 AF 🟨「键唯一」属类型保证、RI 🟨「键不重复」不是 RI 且空键缺维护者、Safety 🟩 方向对但漏入向；附 IntSet 变式与下一步修改清单

---

### 2026-11-05（10 节，36 页）
- 0101 评审对照：真实项目怎么处理 AF / RI / Safety（Real-world Cases）：映射型 AF 的工业写法（6.031 `CharSet` 的集合型 AF 不适用、groupcache `ByteView` 用自然语言写表示与 `b`/`s` 二选一）、RI 与维护者成对（UWCSE 331 `IntSet` 的 `add` 反例与 `contains` 修法、`net/http.Header` 不写「key 不重复」）、Safety 的三条合法路线（`bytes.Buffer.Bytes` 声明别名、`ByteView.ByteSlice` 出向拷贝、`Sink.SetBytes` 的 caller retains ownership 入向声明、`MIMEHeader.Set` 新建 `[]string` 免拷贝）；附 `go doc -src` 四处出处、`IntSet` 变式与本人的三条修改待办
- 0101 第二轮评审：三处改对（AF 换成映射写法、RI 删掉类型保证、Safety 补上入向），剩 AF 条件与 RI 维护者两处收尾
- 0101 真实项目怎么用：四个判断点的工业样本（Real-world Usage）：`sync.Map.Load` 的 ok bool、bbolt `Bucket.Get` 返回 nil、Set 返回值三方对照（map 无返回值 / `Put` 只报 error / 本项目的 `updated bool`）、三条拷贝路线、GOROOT 的 `Invariant:` 注释
- 题 5 升级：testing strategy（6.102 R02）：test-first 的两半、原文格式（partition / cartesian product / subdomains）、用例标注子域、Go 的 `t.Run` 与表驱动、本项目要写的四项、脚手架位置（`kv_test.go` 顶部块注释 + `kv.go` 分步 TODO）
- 维度与子域：从 6.102 R02 到 KV（Partitions and Subdomains）：partition 的三个硬条件（非空、不重叠、覆盖全部合法输入）、abs 与 max 的原文例子、KV 的三维交叉（operation / key state / history）与组合子域、标准库 `strconv/number_test.go` 表驱动的真实样本
- 第二处填写的评测（partition on operation）：`use key state` 式引用的合法性与判定
- 今日 token 用量异常诊断（2026-11-05）：`~/.reasonix/stats` 与 `wire.jsonl` 归因，由此定下「禁止轮询等待」的成本纪律
- 0101 第三轮评审：Set 分叉点改成提示，三块仍未落子（Round 3）：Set 的三个子域（新键 / 旧值不等于新值 / 旧值等于新值）、history 的两种写法、断言到子域的映射表、未覆盖清单与「现在补还是阶段末补」的判据
- 用 Delve 调试 kv_test.go 里的测试（dlv test 实战）：`dlv test` 自动关优化、命令速查、在失败断言行读变量、条件断点、DAP 与 headless、五条实测陷阱

---

### 2026-11-07（6 节，46 页）
- 0101 当前作业的问题清单：规格 / 测试 / 实现三层的缺口（Spec / Test / Impl Gaps）：契约三处不一致（Get 未命中、Del 未命中、Set 同键同值的三种说法）、实现三处红（`Set` 先写后比、`make` 无 `copy`、未命中返回 error）、规格四处缺口（AF 缺 `[]byte` 到 `string` 的映射、RI 缺 `mem` 非 nil、Safety 未分入向与出向、方法 doc 全缺）、断言粒度（三合一断言 vs `strconv` 表驱动）、工程卫生（无提交 / `scratch/` 未忽略 / INDEX 未同步）；附 `sync.Map.Load`、`bytes.Buffer.Bytes`、`net/http.Header.Set`、`runtime/map.go` 第 21 行四处出处，以及 `$TMPDIR` 里 nil map panic 与包级未使用变量的探针
- 用 Delve 调试 kv_test.go 的完整工作流（Debug Workflow）：六步循环（红点分类、断言行取样、进实现分辨 `args` / `locals` / `print`、条件断点过滤重复调用、`next` 走顺序类 bug、`bt` 与 `display` 与 `restart`），全部输出为本机实跑；含命名返回值入口是垃圾值、`display` 要 `-a` 且只在断点命中时求值、`restart` 后回到入口两条实测陷阱；结束时按当前三个红点（36 / 39 / 48）给出逐个追查的顺序

- 在 Neovim 里调试 kv_test.go（nvim-dap + nvim-dap-go）：本机 LazyVim 的 `dap.core` / `lang.go` / `test.core` 三个 extra 已接好 Delve，`nvim-dap-go` 的 adapter 就是 `dlv dap -l 127.0.0.1:PORT`、`debug_test` 等价于 `dlv test -- -test.run ^名字$`；CLI 命令与 `<leader>db` / `<leader>dB` / `<leader>td` / `<leader>dO` / `<leader>de` / `<leader>du` / `<leader>dt` 的完整对照表、九步会话流程、五种配置入口、六条实测陷阱；headless 实跑停在 `kv_test.go:36` 并 evaluate 出 `updated=false`
- dlv test 命令的参数归谁解析（分界符与测试标志）：`--` 两侧分别由 dlv 与测试二进制解析、`-test.` 前缀来自 `testing.Init()` 注册的 flag（源码 `testing/testing.go` 第 438 至 470 行）、`[package]` 三种写法与「只支持单包」、`-test.run` 的正则与 `/` 切分子测试、`-other-argument` 是占位；含六条实测（`-test.run TestKV.*` 出 `=== RUN`、漏 `--` 报 `with multiple packages`、`-v` 报 `flag provided but not defined`、`dlv test ./...` 报同一条错）
- 为什么 `list` 显示 `no source available`（PC 没有行表）：三个前提（PC / DWARF 行表 / 源文件）与「地图上没有这个坐标」的读法；启动瞬间停在 `ld.so`（本机实测 `0x7f2c9e22e400`、`??? at ?:-1`，`file` 证明测试二进制动态链接、`CGO_ENABLED=1`）、断点命中后 `list` 恢复、Go 的 `.s` 汇编仍有源码（`runtime.futex` 显示 `sys_linux_amd64.s:568`）；排查六步（`bt` / `goroutines` / `continue` / `break main.main` / `frame 1` / `disassemble -l`）与真病态两种（strip、`substitute-path`）
- 怎么按函数名设断点（`break` 的 locspec 与函数名参数化）：`help break` 原文的位置描述符清单、函数名的五种写法（`db.(*KV).Set` / 完整导入路径 / `db.KV.Set` / 只写 `Set` 报 ambiguous / 正则）、`:N` 是函数内行偏移（`Set:2` 落在 `bytes.Equal` 那行）、命名断点 `break setbp ...` 与 `on setbp <条件>`、`/Set/` 一次 288 个断点 vs 精确正则 1 个；附 fish 与 bash 的 `dset` 包装函数，以及 Neovim 侧「DAP 只认行号」的处理（`vim.fn.search` + `dap.set_breakpoint` 实测 line 48 带条件）

---

共 18 份文件、57 个主题。
