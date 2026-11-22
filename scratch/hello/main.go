// 最小的实验模板：go run ./scratch/hello
//
// 用途：确认"改代码 → 跑起来"这条链路是通的。
// 复制这个目录当作新实验的起点。
package main

import (
	"fmt"
	"runtime"
)

func main() {
	fmt.Println("环境通了；Go", runtime.Version())
}
