#set document(
  title: "Software Testing",
  author: "MIT 6.102 Study Notes",
)

#set page(
  paper: "a4",
  margin: (x: 2.3cm, y: 2cm),
)

#set text(
  font: "New Computer Modern",
  size: 10pt,
)

#set par(
  justify: true,
  leading: 0.75em,
)

#set heading(numbering: "1.1")

#show heading.where(level: 1): set block(above: 1.5em, below: 0.8em)
#show heading.where(level: 2): set block(above: 1em, below: 0.5em)

#align(center)[
  #text(size: 25pt, weight: "bold")[Software Testing]
  #v(0.4em)
  #text(size: 12pt, fill: gray)[
    Specification, Input Partitioning, Test Coverage and ADT Testing
  ]
  #v(0.5em)
  #text(size: 9pt, fill: gray)[MIT 6.102 / Go Testing]
]

#v(1em)

= 1. Specification and Test Design

== 1.1 What is a Specification?

A specification (Spec) describes the externally observable behavior of a function or operation.

It defines the contract between the caller and the implementation.

A typical specification contains:

- Description: What does the function do?
- Parameters: What do the parameters represent?
- Preconditions: What must be true before calling the function?
- Postconditions: What does the function guarantee after execution?
- Side Effects: What state can the function modify?

Example:

```go
// Find searches for val in arr.
//
// Parameters:
//   - arr: the array to search.
//   - val: the value to search for.
//
// Preconditions:
//   - val occurs exactly once in arr.
//
// Postconditions:
//   - Returns an index i such that arr[i] == val.
//   - 0 <= i && i < len(arr).
func Find(arr []int, val int) int
```

== 1.2 Why Does Specification Matter to Testing?

Testing should be derived from the specification rather than from the implementation.

The specification tells us:

- Which inputs are valid?
- Which inputs represent different situations?
- What outputs are expected?
- Which properties must remain true?
- Which side effects are allowed?

A useful testing workflow is:

#enum(
  [Read and understand the specification.],
  [Identify input dimensions and partitions.],
  [Determine coverage obligations.],
  [Select representative test cases.],
  [Implement tests.],
  [Evaluate whether important behaviors are covered.]
)

Important principle:

*Test the contract, not the implementation details.*

= 2. Input Partitioning

== 2.1 What is Input Partitioning?

Input partitioning divides the input space into categories (partitions) according to relevant properties.

The purpose is to reduce an enormous input space into a manageable number of representative categories.

Instead of testing every possible input, we select inputs from different partitions.

For example:

```go
func Find(arr []int, val int) int
```

Possible partitions:

#table(
  columns: (1fr, 2fr),
  [*Partition*], [*Description*],
  [`P1.1`], [The value exists in the array.],
  [`P1.2`], [The value does not exist in the array.],
  [`P2.1`], [The array is empty.],
  [`P2.2`], [The array contains one element.],
  [`P2.3`], [The array contains multiple elements.],
)

Each partition represents a category of inputs.

== 2.2 Partition by Different Dimensions

A function may have several independent input dimensions.

For example:

```go
func Get(key []byte, value []byte) bool
```

We might identify:

*Dimension 1: Key*

- `K1`: Empty key.
- `K2`: Non-empty key.

*Dimension 2: Value*

- `V1`: Nil value.
- `V2`: Empty value.
- `V3`: Non-empty value.

These dimensions describe different properties of the input.

== 2.3 Partitions Should Be Meaningful

A good partition distinguishes inputs that may cause different behavior.

For example, in a key-value store:

- A missing key differs from an existing key.
- A nil stored value differs semantically from a missing key.
- An empty value may have different representation from a nil value.

Partitions should be derived from the specification and the semantics of the operation.

Do not create partitions merely to increase the number of test cases.

= 3. Coverage Strategies

== 3.1 Cartesian Product Coverage

Suppose we have two partition dimensions:

- `P1`: Key existence.
- `P2`: Value state.

The Cartesian product is:

$ P_1 times P_2 $

For example:

#table(
  columns: (1.2fr, 1fr, 1fr, 1fr),
  [*Key / Value*], [*Nil*], [*Empty*], [*Non-empty*],
  [Exists], [C1], [C2], [C3],
  [Missing], [C4], [C5], [C6],
)

There are:

$ 2 times 3 = 6 $

possible combinations.

The strategy:

*Cover the Cartesian product of these partitions.*

means selecting tests that cover every combination of partition classes.

However, Cartesian product coverage assumes that the combinations being considered are meaningful.

For example, when a key does not exist, the state of its stored value is not applicable.

Therefore, we should identify invalid or meaningless combinations instead of blindly testing all six.

== 3.2 Subdomains

A subdomain is a subset of the input space characterized by a collection of conditions.

For example:

$ D_1 = "Key exists" inter "Value is nil" $

$ D_2 = "Key exists" inter "Value is empty" $

$ D_3 = "Key exists" inter "Value is non-empty" $

$ D_4 = "Key does not exist" $

Each subdomain contains potentially many concrete inputs.

For example, the following inputs may belong to the same subdomain:

```go
Get([]byte("name"))
Get([]byte("email"))
Get([]byte("username"))
```

Assuming each key exists and maps to a non-empty value, these inputs belong to the same broad behavioral category.

The strategy:

*Cover the subdomains of these partitions.*

focuses on selecting representative inputs from the relevant subdomains.

== 3.3 Relationship Between the Two Strategies

The two strategies are related, but they emphasize different things.

#table(
  columns: (1.2fr, 2fr),
  [*Strategy*], [*Main concern*],
  [Cartesian Product], [Combining partition dimensions and covering their combinations.],
  [Subdomain Coverage], [Covering relevant regions of the input space.],
)

A Cartesian product of independent partitions can construct subdomains through combinations of their classes.

However:

- Not all combinations are necessarily valid.
- Some combinations may be equivalent from the perspective of the specification.
- Some dimensions may depend on other dimensions.
- The required coverage should be determined by the intended test strategy.

These strategies are not mutually exclusive. A test plan may specify multiple coverage obligations for the same function.

== 3.4 Example: KV.Get

Consider:

```go
func (kv *KV) Get(key []byte) (val []byte, ok bool, err error)
```

Possible partitions:

```text
P1: Key existence
    P1.1: Key exists
    P1.2: Key does not exist

P2: Stored value state
    P2.1: Value is nil
    P2.2: Value is empty
    P2.3: Value is non-empty

P3: Key format
    P3.1: Normal key
    P3.2: Empty key
    P3.3: Key contains special characters
```

Relevant combinations:

#table(
  columns: (1.5fr, 1.3fr, 1.3fr, 1fr),
  [*Existence*], [*Value*], [*Key format*], [*Expected ok*],
  [Exists], [Nil], [Normal], [true],
  [Exists], [Empty], [Normal], [true],
  [Exists], [Non-empty], [Normal], [true],
  [Missing], [N/A], [Normal], [false],
)

Notice that a missing key does not have a stored value state.

This is an example of a dependent partition dimension.

= 4. ADT Testing and Receiver Provenance

== 4.1 Testing an Operation Is More Than Testing Its Parameters

For an Abstract Data Type (ADT), an operation usually receives:

- Explicit parameters.
- An implicit receiver object (`this` in Java, the receiver in Go).

The receiver has a current state and may have been created through different operations.

For example, consider:

```java
MyString s = new MyString("hello");
s.length();
```

Here, the receiver was created by the constructor.

But:

```java
MyString s = new MyString("hello");
MyString sub = s.substring(1, 3);
sub.length();
```

Here, the receiver was produced by `substring()`.

Both receivers have the same type, but their construction histories differ.

Therefore, an operation may need to be tested against objects produced by different operations.

== 4.2 Partition on this

Consider the following testing strategy:

```text
length():
    partition on string length: 0, 1, >1

    partition on this:
        produced by constructor
        produced by substring()
```

The second partition dimension is based on the provenance of the receiver.

It asks:

- Was this object created by the constructor?
- Was this object returned by another operation?

This is useful because different creation paths may produce different internal representations or states.

== 4.3 Example: substring()

Suppose the implementation contains a bug:

```java
public MyString substring(int start, int end) {
    MyString result = new MyString("");
    result.chars = chars;
    return result;
}
```

The implementation incorrectly shares the entire character array instead of representing the requested substring.

A constructor-only test might pass:

```java
MyString s = new MyString("hello");

assertEquals(5, s.length());
```

But this test should fail:

```java
MyString s = new MyString("hello");
MyString sub = s.substring(1, 3);

assertEquals(2, sub.length());
```

The second test exercises an object produced by `substring()`.

This demonstrates why receiver provenance matters.

== 4.4 Operation Composition

ADT operations are not isolated.

One operation can produce an object that becomes the receiver of another operation.

For example:

```text
constructor()
    |
    v
substring()
    |
    v
substring()
    |
    v
length()
    |
    v
charAt()
```

Testing these sequences helps detect errors that individual operation tests may miss.

Examples:

```java
MyString s = new MyString("hello");

MyString sub1 = s.substring(1, 4);
MyString sub2 = sub1.substring(1, 2);

assertEquals(2, sub1.length());
assertEquals(1, sub2.length());
```

The important idea:

*An ADT must remain correct when its operations are composed.*

== 4.5 State-Based and History-Based Considerations

These are useful conceptual distinctions when designing tests.

#table(
  columns: (1.2fr, 2fr),
  [*Perspective*], [*What it examines*],
  [State-based], [The object's current properties and state.],
  [History-based], [The operations or construction paths that produced the object.],
)

Examples:

State-based partitions:

- String length is zero.
- String length is one.
- String length is greater than one.

History-based partitions:

- Produced by constructor.
- Produced by substring.
- Produced by repeated substring operations.

These are explanatory terms for organizing test design, not necessarily separate formal coverage criteria.

= 5. Go Testing Practices

== 5.1 GoDoc and Function Contracts

Go does not require special `@param`, `@returns`, `requires`, or `ensures` annotations.

A function contract can be documented using ordinary Go comments.

Example:

```go
// Get returns the value associated with key.
//
// Parameters:
//   - key: the key to look up.
//
// Preconditions:
//   - kv is not nil.
//
// Postconditions:
//   - If key exists:
//       - val is a clone of the stored value.
//       - ok is true.
//       - err is nil.
//   - If key does not exist:
//       - val is nil.
//       - ok is false.
//       - err is nil.
//
// Side Effects:
//   - Does not modify the key-value store.
//   - Modifying val does not modify the stored value.
func (kv *KV) Get(key []byte) (val []byte, ok bool, err error)
```

The headings above are a documentation convention, not mandatory GoDoc syntax.

== 5.2 Table-Driven Tests

Go commonly uses table-driven tests to represent different test cases.

Example:

```go
func TestKVGet(t *testing.T) {
    tests := []struct {
        name    string
        key     []byte
        mem     map[string][]byte
        wantVal []byte
        wantOK  bool
    }{
        {
            name:    "existing key",
            key:     []byte("name"),
            mem:     map[string][]byte{
                "name": []byte("Alice"),
            },
            wantVal: []byte("Alice"),
            wantOK:  true,
        },
        {
            name:    "missing key",
            key:     []byte("age"),
            mem:     map[string][]byte{},
            wantVal: nil,
            wantOK:  false,
        },
        {
            name:    "existing key with nil value",
            key:     []byte("name"),
            mem:     map[string][]byte{
                "name": nil,
            },
            wantVal: nil,
            wantOK:  true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            kv := &KV{mem: tt.mem}

            gotVal, gotOK, gotErr := kv.Get(tt.key)

            if !bytes.Equal(gotVal, tt.wantVal) {
                t.Errorf("val = %v, want %v",
                    gotVal, tt.wantVal)
            }

            if gotOK != tt.wantOK {
                t.Errorf("ok = %v, want %v",
                    gotOK, tt.wantOK)
            }

            if gotErr != nil {
                t.Errorf("err = %v, want nil", gotErr)
            }
        })
    }
}
```

Important detail:

`bytes.Equal(nil, []byte{})` returns true.

If nil and empty slices are semantically different according to the specification, test nil-ness separately:

```go
if (gotVal == nil) != (tt.wantVal == nil) {
    t.Errorf("nil status mismatch")
}
```

== 5.3 Test Plan Inside kv_test.go

A separate test plan file is not necessary for a small project.

You can document the testing strategy directly above the corresponding test function.

Recommended structure:

```go
// Test Plan: KV.Get
//
// Input Partitions:
//
//  1. Key existence:
//     - P1.1: Key exists.
//     - P1.2: Key does not exist.
//
//  2. Stored value state:
//     - P2.1: Value is nil.
//     - P2.2: Value is empty.
//     - P2.3: Value is non-empty.
//
//  3. Key format:
//     - P3.1: Normal key.
//     - P3.2: Empty key.
//     - P3.3: Special-character key.
//
// Test Cases:
//
//  1. Existing key with non-empty value.
//     - Covers: P1.1, P2.3, P3.1
//
//  2. Missing key.
//     - Covers: P1.2
//
//  3. Existing key with nil value.
//     - Covers: P1.1, P2.1, P3.1
//
//  4. Existing key with empty value.
//     - Covers: P1.1, P2.2, P3.1
//
//  5. Empty key.
//     - Covers: P1.1, P2.3, P3.2
//
//  6. Special-character key.
//     - Covers: P1.1, P2.3, P3.3

func TestKVGet(t *testing.T) {
    // Test implementation
}
```

This makes `kv_test.go` both a test implementation and a test design document.

== 5.4 Testing Receiver Provenance in Go

The same idea applies to Go ADTs.

Suppose:

```go
func NewKV() *KV
func (kv *KV) Put(key, val []byte)
func (kv *KV) Get(key []byte) ([]byte, bool, error)
```

For `Get()`, we might partition the receiver according to its construction history:

```text
partition on kv:

    - Produced by NewKV().
    - Produced by NewKV() followed by one Put().
    - Produced by NewKV() followed by multiple Put() operations.
    - Produced by repeated updates to the same key.
```

Example:

```go
// Test Plan: KV.Get
//
// Partition on receiver:
//
//  1. Created by NewKV().
//  2. Created by NewKV() followed by Put().
//  3. Created by NewKV() followed by multiple Put().
//  4. Created by repeated Put() on the same key.
//
// Partition on key:
//
//  1. Existing key.
//  2. Missing key.
//
// Partition on stored value:
//
//  1. Nil.
//  2. Empty.
//  3. Non-empty.
```

When testing an ADT's public contract, prefer creating states through public operations such as `NewKV` and `Put`, rather than directly manipulating its internal map.

Directly constructing internal state can still be useful for implementation-level tests, but it tests a different aspect of the system.

= 6. Important Testing Principles

== 6.1 Partition Coverage Is Not Code Coverage

These are different measurements.

*Partition Coverage*

Checks whether the selected test cases cover the intended input categories.

*Code Coverage*

Checks which statements or branches were executed.

High code coverage does not necessarily mean good input partition coverage.

A test may execute every line without testing important boundary cases or semantically different inputs.

== 6.2 Do Not Test Every Possible Input

The purpose of partitioning is to reduce the test space.

Choose representative inputs from each relevant category.

However, a representative input must actually exercise the behavior that the partition is intended to test.

== 6.3 Consider Interactions Between Dimensions

Individual partitions may not reveal all bugs.

For example:

- Key exists + nil value.
- Key exists + empty value.
- Key missing + empty key.
- Repeated updates + subsequent Get.

Some dimensions are dependent, so not every Cartesian product combination is meaningful.

== 6.4 Test Observable Behavior

A specification describes externally observable behavior.

Tests should verify:

- Returned values.
- Returned status indicators.
- Error behavior.
- Observable state changes.
- Independence of returned mutable data, where promised.

Avoid coupling tests unnecessarily to internal representation.

= 7. Practical Workflow

For each ADT operation, use the following process:

#enum(
  [*Understand the contract.* Identify parameters, preconditions, postconditions and side effects.],
  [*Identify input dimensions.* Include explicit parameters and relevant receiver properties.],
  [*Define partitions.* Divide each dimension into meaningful categories.],
  [*Identify dependencies.* Determine which combinations are valid or meaningful.],
  [*Specify coverage obligations.* Decide whether to cover individual partitions, Cartesian products, relevant subdomains, or other combinations.],
  [*Consider receiver provenance.* Include objects produced by different constructors or operations.],
  [*Select representative test cases.* Include boundary values and meaningful operation sequences.],
  [*Implement and evaluate.* Use Go table-driven tests and assess partition coverage separately from code coverage.]
)

= 8. Quick Reference

#table(
  columns: (1.25fr, 2fr),
  [*Concept*], [*Meaning*],
  [Specification], [Defines the function's contract.],
  [Precondition], [What must be true before execution.],
  [Postcondition], [What the function guarantees.],
  [Input Partition], [A category of inputs with a relevant shared property.],
  [Cartesian Product], [Combinations of partition classes across dimensions.],
  [Subdomain], [A subset of the input space characterized by conditions.],
  [Partition Coverage], [Coverage of the intended partition categories or combinations.],
  [Receiver Provenance], [How the current receiver object was created.],
  [Operation Composition], [Combining ADT operations into sequences.],
  [Table-driven Testing], [Representing multiple test cases as Go data.],
  [Code Coverage], [Measurement of executed code.],
)

#v(1em)
#line(length: 100%, stroke: 0.5pt + gray)

#align(center)[
  #text(size: 9pt, fill: gray)[
    Core principle: Derive tests from the specification,
    partition the input space, and verify observable behavior.
  ]
]
