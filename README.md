# db-go

跟着 [trialofcode.org 的课程](https://trialofcode.org/database/) 用 Go 从零实现一个关系型数据库。
44 步，每步一个主题——从内存 map 起步，一路长到带二级索引、事务和 LSM-Tree 的存储引擎。

## 结构

```
.
├── go.mod                  模块 github.com/zz-cpp/db-go
├── cmd/dbshell/main.go     命令行入口
├── internal/db/            数据库实现
│   ├── kv.go               KV 接口与存储引擎
│   ├── kv_entry.go         日志条目的编解码
│   ├── log.go              append-only 日志
│   ├── cell.go             数据类型（用 tag 模拟 union）
│   ├── row.go              行与 schema 的编码
│   ├── sorted_array.go     有序数组
│   ├── sorted_file.go      SSTable
│   ├── metadata.go         元数据（双槽 + 校验和）
│   ├── merge.go            多路归并迭代器
│   ├── sql_parser.go       SQL 词法与语法分析
│   ├── eval.go             表达式求值
│   ├── table.go            关系层：CRUD、索引、迭代
│   ├── utils.go            基础设施
│   ├── assert.go           断言辅助
│   ├── os_unix.go          平台相关（类 Unix）
│   └── os_other.go         平台相关（其他）
└── test/                   测试
    ├── kv_test.go  cell_test.go  row_test.go
    ├── table_test.go  sorted_file_test.go  merge_test.go
    └── metadata_test.go  sql_parser_test.go  eval_test.go
```

## 现状

骨架。每个文件只有一行 `package` 声明，实现留给你写。

```bash
go build ./...   # 通过
go vet ./...     # 通过
```

## 配套材料

讲义和课程离线镜像在仓库之外：`../db-web/`。
那里不是 git 仓库，只是本地素材——本仓库只跟踪你自己的代码。
