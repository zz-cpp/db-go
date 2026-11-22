# 项目指令

## 项目本体（骨架阶段）

- 模块 `github.com/zz-cpp/db-go`；`internal/db/*.go` 多数文件目前只有一行 `package db`，实现是自己按讲义写的。
- 测试在 `internal/db/` 下，与实现**同包**（文件声明 `package db`，白盒）：直接写 `KV{}`、`kv.Open()`，不需要 import；原来的独立测试目录 `test/` 已于 2026-10-09 整体迁入此处，现已不存在。
- 测试依赖 `github.com/stretchr/testify`；`go build ./...` 不编译 `_test.go`，验证测试要跑 `go vet ./internal/db/` 或 `go test ./internal/db/`（或 `./...`）。

## 推进模式：先完整 45 步，后优化（2026-10-31 用户要求）

- 每步按 `software-construction` 的课程流程推进：读材料 → 规格 → 测试 → 实现 → 验证 → 落盘 → 进度。
- **L3 扩展冻结**：Buffer Pool / B+Tree / 锁 / ARIES 等扩展，等 45 步全部通过官方测试后再评估；L1 阶段不为“未来扩展”改接口（规格要求除外）。
- **完成定义**：无 `panic("TODO")` / `missing function body`；`go build ./...`、`go vet ./...`、`go test ./...` 全绿；每步有落盘记录；每层有证据包；09 章后至少一次 `go test -race ./...`。
- **验证命令用项目自己的**：`go test ./internal/db/`、`go vet ./...`、`go build ./...`；不要照搬讲义里的 `make test-layer`（那是 `db-web/code` 的命令）。
- 课程进度采用 6.102 的 T01–T24 主线编号，6.031 用作补充材料。

## 源码规格与测试

- 项目源码中的规格注释和测试策略采用 [MIT 6.102 的课程原例](docs/go-construction-templates.md)。6.102 未覆盖的内容参考 6.031 对应 Reading。
- 当前步骤的测试划定验收范围。测试尚未确定的规格和测试分区标记 `TODO(阶段末)`，待本阶段结束后核对。
- 项目核心实现是练习的一部分，由本人完成规格、测试、实现中的至少一项。

## 会话成本纪律（2026-11-05 用户要求）

- **禁止轮询等待**：等本人修改文件时，禁止反复检查文件的修改时间或内容。
- **上下文上限**：单个会话上下文接近 200K token 就新开会话继续，不要跨天沿用同一个会话。
- **成本自查**：怀疑用量异常时，先看 `~/.reasonix/stats/<日期>.jsonl` 的 `prompt`/`requests`，再按 `wire.jsonl` 的 `tool_result` → `usage` 顺序归因到具体工具。
