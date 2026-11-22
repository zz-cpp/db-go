// defer 的四种常规行为 + panic 情形，一次跑齐。
//
// 出处：note/2026-10-07.typ →「defer kv.Close() 是什么意思」→ 实测：五种行为一次看清。
// 跑法：go run ./scratch/defer
package main

import "fmt"

// ① 执行顺序：后进先出（LIFO）
func order() {
	defer fmt.Println("  defer 1")
	defer fmt.Println("  defer 2")
	defer fmt.Println("  defer 3")
	fmt.Println("  函数体结束")
}

// ② 参数在 defer 语句执行时就求值了
func argTiming() {
	i := 0
	defer fmt.Println("  defer 捕获 i =", i)
	i = 100
	fmt.Println("  函数体里 i =", i)
}

// ③ 闭包形式：真正执行时才读变量
func closureTiming() {
	i := 0
	defer func() { fmt.Println("  闭包读 i =", i) }()
	i = 100
}

// ④ 命名返回值可以被 defer 改写
func namedReturn() (n int) {
	defer func() { n++ }()
	return 10
}

// ⑤ panic 情形：panic 前注册的 defer 照样执行，recover 能把 panic 接住
//
// 顺序要点：后注册的先执行（LIFO）—— 所以 recover 那个 defer 要*先*注册，
// 才会排在"打印一行"的后面执行。
func panicCase() {
	defer func() { fmt.Println("  recover 到:", recover()) }()
	defer fmt.Println("  panic 前注册的 defer 仍然执行")
	panic("出事了")
}

func main() {
	fmt.Println("① LIFO 顺序:")
	order()

	fmt.Println("② 参数求值时机:")
	argTiming()

	fmt.Println("③ 闭包 vs 参数:")
	closureTiming()

	fmt.Println("④ 命名返回值:", namedReturn())

	fmt.Println("⑤ panic 情形:")
	panicCase()
}
