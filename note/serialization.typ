#set document(
  title: "Serialization：为什么不能直接使用程序的二进制表示？",
  author: "系统编程笔记",
)

#set page(
  paper: "a4",
  margin: (x: 2.3cm, y: 2cm),
)

#set text(
  font: ("New Computer Modern", "Noto Sans CJK SC"),
  size: 10pt,
)

#set par(
  justify: true,
  leading: 0.75em,
)

#set heading(numbering: none)

#show heading.where(level: 1): set block(above: 1.5em, below: 0.8em)
#show heading.where(level: 2): set block(above: 1em, below: 0.5em)

= Serialization：为什么不能直接使用程序的二进制表示？

序列化（Serialization）是指将程序运行时的数据结构转换为字节序列（Byte Sequence），以便将数据存储到磁盘或通过网络传输。

一个自然的问题是：

*既然编程语言最终可以编译成二进制，为什么不直接使用编译后的二进制文件，而需要额外设计序列化格式？*

答案是：编译产生的二进制文件与序列化产生的字节序列，虽然本质上都是 bytes，但它们解决的是完全不同的问题。

== 1. 编译后的二进制文件不等于运行时数据

考虑一个简单的 C++ 结构体：

```cpp
struct User {
    int id;
    double score;
};

User user{
    100,
    98.5
};
```

假设当前系统中：

- `int` 占用 4 bytes；
- `double` 占用 8 bytes。

那么 `user` 在内存中的布局可能是：

#align(center)[
  #table(
    columns: (1fr, 2fr),
    stroke: 0.5pt,
    inset: 10pt,
    [*id*#linebreak()4 bytes#linebreak()100],
    [*score*#linebreak()8 bytes#linebreak()98.5],
  )
]

我们完全可以直接将对象的内存写入文件：

```cpp
std::ofstream file("user.bin", std::ios::binary);

file.write(
    reinterpret_cast<const char*>(&user),
    sizeof(user)
);
```

这种方式在特定场景下完全可行。

但问题是：

*这些 bytes 能否被其他程序、其他平台正确理解？*

这就引出了直接使用内存表示所面临的几个问题。

== 2. 为什么不能直接传输内存中的二进制表示？

=== 2.1 不同平台的内存表示可能不同

不同 CPU 架构可能采用不同的字节序（Endianness）。

例如，整数 `100` 的 32-bit 十六进制表示为：

```text
0x00000064
```

Little Endian 和 Big Endian 的内存排列方式不同：

#table(
  columns: (1fr, 4fr),
  stroke: 0.5pt,
  inset: 8pt,
  [*Little Endian*],
  [`64` `00` `00` `00`],
  [*Big Endian*],
  [`00` `00` `00` `64`],
)

如果将 Little Endian 系统上的原始内存数据直接传输给 Big Endian 系统，接收方可能会错误地解释数据。

序列化格式可以明确规定字节序，从而解决这个问题。

=== 2.2 不同编程语言的数据类型不同

考虑：

```cpp
struct User {
    int id;
    std::string name;
};
```

假设我们需要将这个 C++ 对象发送给 Python 程序。

问题包括：

- C++ 的 `std::string` 是什么内存结构？
- Python 的 `str` 又是什么内存结构？
- Python 如何知道 C++ 对象中哪个位置是 `name`？
- Python 如何知道字符串的长度？

不同编程语言对数据类型的内部实现可能完全不同。

但是，如果将对象序列化为 JSON：

```json
{
    "id": 100,
    "name": "Alice"
}
```

那么 C++、Python、Java、JavaScript 等语言都可以通过各自的 JSON 库解析它。

它们不需要知道对方的内存布局。

因此，序列化的一个重要价值是：

*建立一种与具体编程语言的内存表示无关的数据交换格式。*

=== 2.3 内存中可能包含指针

考虑：

```cpp
struct User {
    int id;
    char* name;
};
```

假设：

```cpp
User user;
user.id = 100;
user.name = new char[6];
```

`user.name` 保存的实际上是一个内存地址，例如：

```text
0x7FFE12345678
```

如果直接将整个 `User` 对象写入文件，那么保存的只是这个地址，而不是地址所指向的字符串。

当程序重新启动时：

- 原来的内存地址可能已经不存在；
- 新程序的虚拟地址空间可能完全不同；
- 这个指针可能指向无效内存。

因此，序列化需要将指针指向的实际数据也转换为可持久化的表示，而不是简单地保存内存地址。

=== 2.4 数据结构可能随着程序版本发生变化

假设第一版程序定义了：

```cpp
struct User {
    int id;
    std::string name;
};
```

第二版程序增加了一个字段：

```cpp
struct User {
    int id;
    std::string name;
    int age;
};
```

如果直接保存原始内存布局，那么旧版本写入的数据和新版本读取数据的方式可能不兼容。

成熟的序列化格式通常支持：

- 字段标识（Field Identifier）；
- 字段类型（Field Type）；
- 可选字段（Optional Fields）；
- 默认值（Default Values）；
- 模式演进（Schema Evolution）。

这样，即使程序的数据结构发生变化，也可以在一定程度上保持数据兼容性。

== 3. 序列化到底做了什么？

序列化可以理解为：

*将程序中的数据结构转换为一种具有明确编码规则、可以被其他程序独立解释的字节表示。*

其基本过程如下：

#align(center)[
  #box(
    width: 85%,
    fill: rgb("#EAF2FF"),
    radius: 5pt,
    inset: 12pt,
  )[
    #align(center)[*内存中的对象*]
    #align(center)[`User { id: 100, name: "Alice" }`]
  ]

  #v(0.4em)
  #text(fill: blue)[↓ Serialization]

  #v(0.4em)
  #box(
    width: 85%,
    fill: rgb("#EAF7EE"),
    radius: 5pt,
    inset: 12pt,
  )[
    #align(center)[*字节序列（Bytes）*]
    #align(center)[按照某种格式编码的数据]
  ]

  #v(0.4em)
  #text(fill: blue)[↓ Disk / Network]

  #v(0.4em)
  #box(
    width: 85%,
    fill: rgb("#EAF2FF"),
    radius: 5pt,
    inset: 12pt,
  )[
    #align(center)[*另一个程序*]
    #align(center)[Deserialization：根据相同规则还原数据]
  ]
]

这里涉及两个重要概念：

- Serialization：将数据结构编码为字节序列。
- Deserialization：根据编码规则将字节序列还原为数据结构。

=== 3.1 常见的序列化格式

#table(
  columns: (1.3fr, 3fr),
  stroke: 0.5pt,
  inset: 8pt,
  [*格式*], [*特点*],
  [JSON], [可读性好，跨语言],
  [XML], [结构化文本格式],
  [Protocol Buffers], [高效、紧凑、支持 Schema],
  [MessagePack], [二进制格式，类似 JSON],
  [CBOR], [通用二进制数据格式],
  [FlatBuffers], [支持直接访问序列化数据，减少反序列化开销],
)

需要注意：

*序列化并不意味着一定要转换为文本。*

JSON 属于文本格式，而 Protocol Buffers、MessagePack 等可以使用二进制编码。

== 4. Serialization vs. Compilation

这两个过程解决的是不同的问题。

#table(
  columns: (1.1fr, 1.7fr, 2.2fr),
  stroke: 0.5pt,
  inset: 8pt,
  [*对比*], [*Compilation*], [*Serialization*],
  [输入], [源代码], [运行时数据],
  [输出], [机器代码、目标文件等], [字节序列],
  [目的], [让机器执行程序], [存储或传输数据],
  [关注点], [指令、ABI、执行环境], [数据结构、编码规则、兼容性],
  [典型产物], [ELF、PE、Mach-O], [JSON、Protobuf、MessagePack],
)

例如：

```cpp
int main() {
    int x = 100;
}
```

编译器将这段代码转换为机器指令。

而：

```cpp
User user{100, "Alice"};
```

序列化器将运行时的 `user` 对象编码为一组字节。

虽然最终都表现为二进制，但它们的语义完全不同。

== 5. 什么时候可以直接使用原始二进制？

在某些场景下，直接使用原始内存表示是合理的，例如：

- 同一程序内部的临时数据交换；
- 明确控制 ABI 和内存布局的系统；
- 特定硬件平台上的共享内存；
- 高性能计算中的特定数据传输；
- 受控环境下的二进制文件格式。

例如，Linux ELF 文件本身就是一种结构化的二进制文件格式。

它并不是简单地将某个 C++ 对象的内存直接 dump 到磁盘，而是按照明确的文件格式规范组织数据。

因此，直接使用原始二进制并非不可能，而是需要自行承担以下约定和兼容性问题：

- 数据布局；
- 字节序；
- 类型大小；
- 对齐规则；
- 指针与引用的处理；
- 数据版本兼容性。

== 6. 核心思想

#quote(block: true)[
  编译是把程序变成机器能够执行的形式；序列化是把数据变成不同程序、不同时间、不同环境都能够理解的形式。
]

对于系统编程而言，这个概念还会进一步引出：

- ABI（Application Binary Interface）
- Endianness（字节序）
- Memory Layout（内存布局）
- Binary File Format（二进制文件格式）
- Network Protocol（网络协议）
- Schema Evolution（模式演进）

这些知识共同构成了理解系统之间如何交换和持久化数据的重要基础。

== 7. 思考与练习

=== 问题一

假设 A 程序使用 C++，B 程序使用 Python。

A 将一个包含 `int`、`string` 和指针的 C++ `struct` 直接写入文件，B 能否直接读取并还原这个对象？

- A. 可以，只要两个程序都运行在 Linux 上。
- B. 不可以，因为内存布局、指针和类型表示不一定兼容。
- C. 可以，因为它们最终都是二进制。

*参考答案：B。*

操作系统相同不意味着编程语言的对象布局相同，尤其是指针、字符串等复杂类型。

=== 问题二

JSON 和 Protocol Buffers 都属于序列化格式，它们的核心区别是什么？

- A. JSON 是序列化，Protocol Buffers 是编译。
- B. JSON 是文本编码，Protocol Buffers 通常采用二进制编码。
- C. JSON 只能用于 Python，Protocol Buffers 只能用于 C++。

*参考答案：B。*

两者都能够序列化数据，主要区别在编码方式、Schema、性能和使用特性。
