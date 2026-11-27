// kvprobe：拿项目自己的 KV 做实验 —— 实验区能直接 import internal/db，
// 这是它比"家目录另开一个模块"强的地方。
//
// 现状：internal/db/kv.go 的 Del 还只有签名（missing function body），
// 所以这个实验目前编译不过。补完 Del 就能跑：
//
//	go run ./scratch/kvprobe
//
// 它顺便把 Get 未命中时的语义暴露出来（当前的实现返回 error，而 kv_test.go 要求 err == nil）。
package main

import (
	"fmt"

	"github.com/zz-cpp/db-go/internal/db"
)

func main() {
	kv := db.KV{}
	if err := kv.Open(); err != nil {
		panic(err)
	}
	defer kv.Close()

	updated, err := kv.Set([]byte("k1"), []byte("v1"))
	fmt.Printf("Set(k1, v1)  -> updated=%v err=%v\n", updated, err)

	val, ok, err := kv.Get([]byte("k1"))
	fmt.Printf("Get(k1)      -> val=%q ok=%v err=%v\n", val, ok, err)

	val, ok, err = kv.Get([]byte("nope"))
	fmt.Printf("Get(nope)    -> val=%q ok=%v err=%v\n", val, ok, err)

	deleted, err := kv.Del([]byte("k1"))
	fmt.Printf("Del(k1)      -> deleted=%v err=%v\n", deleted, err)

	updated, err = kv.Del([]byte("k1"))
	fmt.Printf("Del(k1) 再来 -> deleted=%v err=%v\n", updated, err)
}
