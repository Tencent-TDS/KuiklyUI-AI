# 优化方案

## RULE-A：单次重组耗时长

**诊断**：Composable 函数体内有耗时计算，或读取了大量 State。

**优化方案**：

### 方案 1：提取计算到 `remember` / `derivedStateOf`

```kotlin
// ❌ 问题：每次重组都重新计算
@Composable
fun PriceDisplay(items: List<Item>) {
    val total = items.sumOf { it.price } // 每次重组都遍历
    Text("总计：$total")
}

// ✅ 优化：用 derivedStateOf 缓存计算结果
@Composable
fun PriceDisplay(items: List<Item>) {
    val total by remember(items) { derivedStateOf { items.sumOf { it.price } } }
    Text("总计：$total")
}
```

### 方案 2：拆分子组件，缩小重组范围

```kotlin
// ✅ 把耗时逻辑隔离到独立 Composable，其他部分不受影响
@Composable
fun ExpensiveSection(data: Data) {
    val result = remember(data) { heavyComputation(data) }
    ResultDisplay(result)
}
```

---

## RULE-B：State 广播

**诊断**：粒度过粗的 State（如一个 data class 持有多个字段），变化时触发所有订阅者重组。

**优化方案**：

### 方案 1：拆分 State，精准订阅

```kotlin
// ❌ 问题：修改任意字段触发所有组件重组
val uiState = mutableStateOf(UiState(count = 0, name = "Alice"))

// ✅ 优化：独立 State，各组件只订阅自己需要的
val count = mutableStateOf(0)
val name = mutableStateOf("Alice")
```

### 方案 2：ViewModel 多 StateFlow

```kotlin
// ✅ 每个 StateFlow 对应独立数据，组件精准订阅
class MyViewModel : ViewModel() {
    private val _count = MutableStateFlow(0)
    val count: StateFlow<Int> = _count.asStateFlow()

    private val _userName = MutableStateFlow("Alice")
    val userName: StateFlow<String> = _userName.asStateFlow()
}
```

### 方案 3：`derivedStateOf` 派生局部状态（保护下游组件）

> ⚠️ **前提**：`derivedStateOf` 只能观察 **Compose Snapshot State**（如 `mutableStateOf`、`collectAsState()` 的结果）。直接读取 `StateFlow.value` 是**不可观察的**，`derivedStateOf` 不会感知变化，结果永远是初始值。

**适用场景**：父组件需要读取 `uiState` 多个字段，但只想让部分下游组件在特定字段变化时重组。

```kotlin
// ✅ 正确：先 collectAsState，再 derivedStateOf
val uiState by viewModel.uiState.collectAsState()
// uiState 任意字段变化 → 父组件重组
// isLoggedIn 只在 userId 变化时触发下游重组（保护下游，保护不了父组件自身）
val isLoggedIn by remember { derivedStateOf { uiState.userId != null } }
```

---

### 方案 4：`LaunchedEffect + collect + distinctUntilChanged`（保护父组件自身）

**适用场景**：父组件只需要 StateFlow 中的某一个字段，不想因整个 StateFlow 的高频更新触发父组件重组。这是比方案 3 更彻底的解法——从根本上切断父组件对高频 StateFlow 的订阅。

```kotlin
// ❌ 错误写法 1：collectAsState 订阅整个 StateFlow，任意字段变化都触发父组件重组
val uiState by viewModel.uiState.collectAsState()

// ❌ 错误写法 2：StateFlow.value 不是 Compose State，derivedStateOf 观察不到
val isLoggedIn by remember { derivedStateOf { viewModel.uiState.value.userId != null } }

// ✅ 正确：LaunchedEffect + map + distinctUntilChanged
// 只有 userId 字段真正变化时才写入本地 State，父组件只因此字段触发重组
var isLoggedIn by remember { mutableStateOf(false) }
LaunchedEffect(viewModel) {
    viewModel.uiState
        .map { it.userId != null }
        .distinctUntilChanged()  // 值未变时不写入，不触发重组
        .collect { isLoggedIn = it }
}
```

**方案 3 vs 方案 4 对比：**

| | 方案 3（derivedStateOf） | 方案 4（LaunchedEffect collect） |
|---|---|---|
| 父组件是否重组 | ✗ uiState 任意字段变化都触发 | ✅ 只有目标字段变化才触发 |
| 下游组件是否重组 | ✅ 只在派生值变化时触发 | ✅ 只在派生值变化时触发 |
| 适用场景 | 父组件需要 uiState 多个字段 | 父组件只需要 uiState 中一个字段 |
| 代价 | 无 | 多一个协程 + 本地 mutableState |

---

## RULE-C：参数不稳定

**诊断**：`paramChangeFrequency` 显示某参数变化率接近 100%，父组件每次重组时该参数引用都不等，导致当前组件无法 skip。

### 前置判断：参数类型是什么？

RULE-C 的优化方案**强依赖参数类型**。必须先通过 `sourceLocation` 读源码，按函数签名中参数声明顺序找到 `#N` 对应的参数，判断属于以下哪一类：

| 参数类型 | 典型特征 | 对应方案 |
|---------|---------|---------|
| data class（含 `var` 属性或属性类型不稳定） | 有 `var` 字段，或属性含 `List`/跨模块类型 | 方案 A（修复不稳定的根因） |
| Kotlin 集合 | `List<T>`、`Map<K,V>`、`Set<T>` | 方案 B（用 ImmutableList） |
| Lambda | `() -> Unit`、`(T) -> Unit` | 方案 C（检查 Strong Skipping） |
| 第三方库类型 | 不能修改源码的类 | 方案 D（stability config） |
| 业务数据（真的在变） | 分页、Flow 更新的数据 | 合理情况，不需优化 |

---

### 方案 A：修复 data class 不稳定的根因

**Compose 编译器对 data class 的稳定性判断规则**：
- 所有属性为 `val` 且类型均稳定（基本类型、String、稳定的其他类）→ **自动稳定，无需注解**
- 含 `var` 属性 → 不稳定
- 属性中含 `List`/`Map`/`Set` 等集合接口 → 不稳定（集合接口本身不稳定）
- 属性中含跨模块类型（非 Compose 编译器处理的模块）→ 不稳定

> **识别信号**：不稳定类型的组件在 Profiler 中表现为 `scopeKey=null`（首次组合）而非有值的 scopeKey（真实重组）。若 `recompositionCount` 低但 `noScopeRecompositions` 高且 `paramChanges` 显示参数频繁变化，应判断为「不稳定类型导致 scope 重建」，性能开销比普通重组更大。

**关于 `@Stable`/`@Immutable` 注解的真实作用与限制**：

注解只是告诉编译器「信任这个类是稳定的」，让编译器生成支持 skip 的代码。但 skip 能否真正发生，还需要满足：**参数新旧值相等（`equals()` 返回 true 或引用相同）**。

注解无效的场景（不要推荐）：
- 含 `var` 属性加 `@Stable`：`var` 可以随时被外部直接赋值，承诺无法兑现，是误导性的「修复」
- 每次调用都传入新实例：无论类是否稳定，新实例引用不等，参数判定为变化，skip 不会发生
- 含 `List` 属性加 `@Immutable`：只是骗过编译器，如果调用方每次 `listOf(...)` 传新列表，仍然无法 skip

注解有效的唯一场景：
- 全 `val` 且属性类型均稳定，但含**跨模块类型**（编译器无法推断）→ 加 `@Immutable` 告诉编译器信任它，且调用方会复用同一实例或内容不变时传相同引用

**先查明不稳定的具体原因，再选修复方案**：

```kotlin
// ✅ 全 val + 稳定类型 → 编译器自动稳定，不需要任何注解
data class ContactInfo(
    val id: String,
    val name: String,
    val age: Int
)

// ❌ 含 List → 不稳定
// ✅ 修复方案 1（推荐）：把 List 换成 ImmutableList，根除不稳定根因
data class FeedsItemData(
    val id: String,
    val title: String,
    val labels: ImmutableList<Label>  // kotlinx.collections.immutable
)

// ⚠️ 修复方案 2（有条件）：加 @Immutable 仅在「无法改属性类型 + 调用方不会每次传新实例」时有效
// 如果调用方每次都 copy() 或 new，加了也无效
@Immutable
data class FeedsItemData(val id: String, val title: String, val labels: List<Label>)

// ❌ 含 var → 不稳定，且不能加 @Stable 了事
data class MutableData(var count: Int)
// ✅ 修复：改为 val + MutableState，或拆成独立 StateFlow
```

**`@Immutable` vs `@Stable`**（仅在满足上述有效条件时才考虑）：
- `@Immutable`：承诺「所有属性构造后永不改变」，适用于纯数据对象
- `@Stable`：承诺「若属性变化会通过 MutableState 通知 Compose」，适用于内部用 `mutableStateOf` 管理状态、且不通过 `var` 直接赋值的类

---

### 方案 B：集合类型用 ImmutableList

Kotlin 标准集合接口（`List`、`Map`、`Set`）被 Compose 视为**不稳定**（因为存在 `MutableList` 等可变实现）。

```kotlin
// ❌ 问题：每次父组件重组都传入新的 List 实例
@Composable
fun FeedsBottomLabel(labelList: List<IItemLabel>) { ... }

// ✅ 优化：使用 kotlinx.collections.immutable 的 ImmutableList
@Composable
fun FeedsBottomLabel(labelList: ImmutableList<IItemLabel>) { ... }

// 调用侧：
FeedsBottomLabel(labelList = persistentListOf(label1, label2))
```

依赖：
```kotlin
implementation("org.jetbrains.kotlinx:kotlinx-collections-immutable:0.3.7")
```

---

### 方案 C：Lambda 参数不稳定 — 先确认 Strong Skipping 状态

**Strong Skipping 模式**（Kotlin 2.0+ / Compose Compiler 1.5.4+ 默认开启）下，编译器**自动** `remember` 所有 lambda，手写 remember 是多余的。

**先确认项目是否开启 Strong Skipping**：

```kotlin
// build.gradle.kts 检查：
composeCompiler {
    featureFlags.add(ComposeFeatureFlag.StrongSkipping) // 显式开启
    // 或 Compose Compiler 版本 ≥ 1.5.4 默认开启
}
```

#### 情况 1：Strong Skipping 已开启

**不需要手写 `remember`**。若 lambda 参数仍显示 100% 变化率，说明 lambda 捕获了**不稳定的变量**，真正问题在捕获的变量上：

```kotlin
// ❌ 问题：捕获了不稳定的 data 对象
ChildButton(onClick = { vm.click(data) })
// 即使 lambda 自动 remember，若 data 不稳定，key 每次都变 → lambda 仍然每次重建

// ✅ 优化：让 data 稳定（回到方案 A）
@Immutable
data class Data(...)
```

#### 情况 2：Strong Skipping 未开启（旧项目）

这时手写 `remember` 或使用方法引用是有效的：

```kotlin
// ✅ 手写 remember（仅在 Strong Skipping 未开启时必要）
val onClick = remember(viewModel) { { viewModel.increment() } }

// ✅ 方法引用（任何模式都稳定）
ChildButton(onClick = viewModel::increment)
```

**推荐**：优先升级到 Compose Compiler 1.5.4+ 并开启 Strong Skipping，而不是在旧模式下手写 remember。

---

### 方案 D：第三方库类型 — 使用 Stability Config 文件

对于无法修改源码的类（第三方库的 data class），可以通过配置文件告诉 Compose 它是稳定的：

```kotlin
// build.gradle.kts
composeCompiler {
    stabilityConfigurationFile = rootProject.file("compose_stability.conf")
}
```

```
# compose_stability.conf
com.example.third_party.ItemData
java.time.LocalDate
```

---

## 重要提示：给分析者（AI）的原则

1. **不要在看到 RULE-C 时立刻推荐 `remember { { ... } }`**。先读源码确认参数类型
2. **如果参数类型是 data class / 集合，优先推荐稳定性注解**，不要推荐 remember
3. **如果参数类型是 lambda，先检查 Strong Skipping 是否开启**，开启状态下不建议手写 remember
4. **参数变化率 100% 不一定是问题**：翻页、分页加载等场景，数据本来就每次变化，属于业务合理行为

---

## 级联重组

**诊断**：同一 State 触发多个组件在同帧重组，通常与 RULE-B 同时出现。

**优化方案**：同 RULE-B（拆分 State，精准订阅）。

额外建议：
- 使用 `@Stable` / `@Immutable` 注解让 Compose 信任类的稳定性，减少不必要的重组
- 对 data class 参数使用 `@Immutable` 标注，允许编译器生成更高效的比较逻辑

---

## 帧级卡顿（单帧 > 16ms）

**诊断**：单帧内有过多重组或单次重组耗时长。

**优化方向**：
1. 减少单帧重组数量（见 RULE-B / State 拆分）
2. 降低单次重组耗时（见 RULE-A）
3. 使用 `LazyColumn` 替代 `Column` 处理长列表
4. 使用 `key()` 帮助 Compose 识别列表项，减少重组范围

---

## 一般建议

- 优先分析 `isHotspot=true` 的组件（重组最频繁）
- `noScopeRecompositions` 高不代表问题，是首次组合的正常行为
- 对于滚动列表，item 的首次组合（noScope）是预期行为，无需优化
