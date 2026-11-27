# MIT 6.102 规格与测试原例

项目以 6.102 的课程原例为模板。以下节选用于快速定位，完整格式见各节链接。遇到 6.102 未覆盖的内容，再查 6.031 的对应 Reading。

## 函数与方法规格

采用 Reading 4 的 `find`。签名提供类型，`@param` 说明参数与调用条件，`@returns` 说明结果。下面节选原例中数组参数和返回值的说明。[6.102 R04 · Specifications in TypeScript](https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specifications_in_typescript)

```typescript
/**
 * @param arr array to search, requires that val occurs exactly once
 *            in arr
 * @returns index i such that arr[i] = val
 */
```

在 Go 源码中，首句用函数或方法名起笔，直接在正文引用参数名。用 `require:` 写调用者要保证的条件，用 `effects:` 写返回值、错误和相关状态变化。两个标签都用小写并带冒号。跨声明引用用 `[Entry.Encode]` 这样的文档链接。[6.102 R04 · Specification structure](https://web.mit.edu/6.102/www/sp26/classes/04-specifications/#specification_structure) · [Go Doc Comments · Funcs](https://go.dev/doc/comment#funcs)

## ADT 的规格与表示说明

类型和各操作的公开规格使用抽象值来描述。表示字段旁采用 Reading 7 的 `RatNum` 和 `Post` 原例，按 `Rep invariant`、`Abstraction function`、`Safety from rep exposure` 的顺序写。需要处理可变输入和输出时，查同节 `Post` 的完整说明。[6.102 R07 · Documenting the AF, RI, and safety from rep exposure](https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#documenting_the_af_ri_and_safety_from_rep_exposure) · [6.102 R07 · What an ADT specification may talk about](https://web.mit.edu/6.102/www/sp26/classes/07-abstraction-functions-rep-invariants/#what_an_adt_specification_may_talk_about)

```typescript
// Rep invariant:
//   denominator > 0
// Abstraction function:
//   AF(numerator, denominator) = numerator/denominator
```

## 测试策略

采用 Reading 2 的乘法示例。Go 的 `func TestXxx(t *testing.T)` 对应示例的 `describe`，策略写在函数体开头。独立分区的所有组合都有用例时写 `cover the cartesian product of these partitions:`。只要求每个子域至少出现一次时写 `cover the subdomains of these partitions:`。每个分区单独一行。单个 `it("covers …")` 对应 `t.Run("covers …", ...)`，表驱动测试把同样的描述写在每行的 `name` 里，交给 `t.Run(tc.name, ...)`。[6.102 R02 · Documenting your testing strategy](https://web.mit.edu/6.102/www/sp26/classes/02-testing/#documenting_your_testing_strategy) · [Go testing.T.Run](https://pkg.go.dev/testing#T.Run)

本项目的完整可运行示例见 [TestEntryRecordFormat](../internal/db/kv_entry_test.go)。键和值各有空、非空两种状态，四种组合都有样本。长度的 255 和 256 两侧分别取样。

原例来自 Rob Miller、Max Goldman 等人编写的 MIT 6.102 Software Construction，Spring 2026。课程材料采用 [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)。
