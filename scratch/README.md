# scratch/ —— Go 学习实验区

一个**实验** = 一个**子目录** = 一个 `package main`。写完就跑，跑完可留可删。
正式代码在 `internal/db/` 与 `cmd/dbshell/`，`scratch/` 里的东西**随时可以整个删掉**。

## 怎么跑

```bash
cd /home/zz/project/db-go
go run ./scratch/hello        # 跑某一个实验
go vet ./scratch/...          # 只检查实验区（所有子目录）
go build ./...                # 连正式代码一起检查（实验区也在内）
```

`go run` 的参数是**包的路径**，不是文件名 —— 目录里所有 `.go` 文件会被一起编译。

## 加一个新实验

```bash
mkdir -p scratch/slice-basics          # 目录名 = 实验名，小写就行
$EDITOR scratch/slice-basics/main.go   # 写进去（模板见下）
go run ./scratch/slice-basics          # 跑
```

`main.go` 的最小内容：

```go
package main

import "fmt"

func main() {
	fmt.Println("hello")
}
```

想用**测试**的方式实验也行：在同目录写 `xxx_test.go`（`package main`），然后 `go test ./scratch/<名字>`。

## 三条硬规则（go 工具链定的，不是习惯）

1. **一个目录只能有一个 `package main`，也只能有一个 `func main()`。**
   同目录再放一个含 `main()` 的文件，直接编译失败：

   ```
   scratch/hello/second.go:3:6: main redeclared in this block
       scratch/hello/main.go:5:6: other declaration of main
   ```

   所以是"一个实验一个**目录**"，不是"一个实验一个**文件**"。

2. **目录名只影响导入路径，不影响包名。** 对 `package main` 来说目录名随便起（`slice-basics` 带连字符也能 `go run`），但为了少踩坑，建议**纯小写单词**。多词就写成 `slicebasics` 或用连字符都行 —— 反正这个包不会被别人 import。

3. **目录名以 `_` 或 `.` 开头，或叫 `testdata`，就会被 go 工具"隐身"。**
   出处：`go help packages` 原文 ——

   > File system patterns expanded with the "..." wildcard exclude the following:
   > - Directories named "vendor"
   > - Directories named "testdata"
   > - Files and directories with names beginning with "_" or "."
   > - Directories that contain a go.mod file
   > - Directories matching an ignore directive in a module's go.mod file
   > ...
   > For example, "./..." won't match a "./testdata/foo" package, but "./testdata/..." will.

   **实测**：把实验放进 `_scratch/hi/`，`go list ./...` 看不见它（不会被 `go build ./...` 拖累），但显式路径照样能跑：`go run ./_scratch/hi`。
   什么时候用：写一个半成品、故意让它编译不过时。

## 为什么实验区放在模块里，而不是家目录另开一个

因为 `internal/` 的导入规则：**只有 `github.com/zz-cpp/db-go` 模块内的包**才能 import `.../internal/db`。
模块外就算用 `replace` 把本项目指过去，也会被拦下（实测输出）：

```
package sbout
	main.go:6:2: use of internal package github.com/zz-cpp/db-go/internal/db not allowed
```

放在 `scratch/` 就是为了让实验能直接用你正在写的 `KV`：改一行 `kv.go`，跑一下 `go run ./scratch/kvprobe`，立刻看到行为变化。

## 现有实验

| 目录 | 内容 | 现在能跑吗 |
|---|---|---|
| `hello/` | 最小模板：打印当前 Go 版本，确认环境是通的 | ✅ `go run ./scratch/hello` |
| `defer/` | `defer` 的四种行为 + panic 情形，一次跑齐（出处：`note/2026-10-07.typ` 的实测） | ✅ `go run ./scratch/defer` |
| `kvprobe/` | 直接用 `internal/db.KV`：`Open → Set → Get → Del` 全流程 | ⛔ **暂时跑不了**：`internal/db/kv.go` 的 `Del` 还只有签名（`missing function body`）。补完 `Del`、顺手定好 `Get` 未命中的语义，这里就绿了 |

## 清理

- 删一个实验：`rm -rf scratch/<名字>`
- 整个实验区不想进 git：`echo 'scratch/' >> .gitignore`（目前它跟着仓库走，你的学习过程也算记录）
