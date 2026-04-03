---
name: kuikly-coroutines-threading
description: "Kuikly 协程与多线程编程助手。指导如何在 Kuikly 中进行异步编程，包括 Kuikly 内建协程、kotlinx 协程、kuiklyx 协程库。当用户在 Kuikly 中需要执行异步任务、切换线程、使用协程、回到 Kuikly 线程更新 UI、排查线程安全问题时使用。"
---

# Kuikly 协程与多线程编程

## 核心规则

- **Kuikly 线程约束**：所有 Kuikly UI 操作（View、Attr、Event、observable、Module 方法、setTimeout 等）**只能在 Kuikly 线程调用**，Kuikly UI 相关类非线程安全。
- **异步任务完成后必须回到 Kuikly 线程**才能更新 UI 或访问响应式属性。
- **动态化场景**不支持 kotlinx 协程（js 目标平台不支持多线程），只能使用 Module 机制或 Kuikly 内建协程。

## 协程实现方式对比

| 特性 | 回调（无协程） | Kuikly 内建协程 | kotlinx 协程 |
|------|-------------|---------------|-------------|
| 动态化支持 | ✅ 支持 | ✅ 支持 | ❌ 不支持 |
| 依赖库包增量 | 无 | 无 | kotlinx 协程库 |
| 线程安全 | 不涉及 | 自动保障 | 需要考虑 |

---

## 三种协程 API

### 1. Kuikly 内建协程（推荐用于简单异步）

框架自带，始终在 Kuikly 线程执行，无线程切换开销，**支持动态化**。

**API 入口：**
- `GlobalScope.launch { ... }` — 全局作用域
- `lifecycleScope.launch { ... }` — 绑定 Pager 生命周期（推荐）
- `async { ... }` / `await()` — 并发获取结果

**import：**
```kotlin
import com.tencent.kuikly.core.coroutines.GlobalScope
import com.tencent.kuikly.core.coroutines.launch
import com.tencent.kuikly.core.coroutines.async
import com.tencent.kuikly.core.coroutines.delay
```

**注意：** Kuikly 内建协程 API 本身非线程安全，不能在 Kuikly 线程外调用。

### 2. kotlinx.coroutines 库

Kotlin 官方协程库，支持多线程调度器（Dispatchers.Default/IO/Main 等），**不支持动态化**。

**接入方式：**
```gradle
// iOS & Android
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$KOTLINX_COROUTINES_VERSION")
// 鸿蒙
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$KOTLINX_COROUTINES_OHOS_VERSION")
```

### 3. kuiklyx.coroutines 库（切换到 Kuikly 线程）

提供 `Dispatchers.Kuikly` 调度器和 `KuiklyContextScheduler` 回调 API，用于从非 Kuikly 线程切回 Kuikly 线程。

**接入方式：**
```gradle
// iOS & Android
implementation("com.tencent.kuiklyx:coroutines:$KUIKLYX_COROUTINES_VERSION")
// 鸿蒙
implementation("com.tencent.kuiklyx:coroutines:$KUIKLYX_COROUTINES_OHOS_VERSION")
```

**协程方式 API：**
```kotlin
// 启动协程，在 Kuikly 线程执行
GlobalScope.launch(Dispatchers.Kuikly[ctx]) { ... }
// 在协程中切换到 Kuikly 线程
withContext(Dispatchers.Kuikly[ctx]) { ... }
```

**回调方式 API：**
```kotlin
KuiklyContextScheduler.runOnKuiklyThread(pagerId) { cancel ->
    if (cancel) return  // pager 已销毁
    // 在 Kuikly 线程执行
}
```

---

## 场景选择决策树

根据需求选择合适的异步编程方式：

```
需要异步编程？
├── 只需简化回调，无多线程诉求？
│   └── → 方式1：Kuikly 内建协程
├── 需要执行耗时任务 + 支持动态化？
│   └── → 方式2：Module 机制（可配合内建协程）
├── 需要多线程 + 不需要动态化？
│   └── → 方式3：kotlinx 协程 + kuiklyx 协程
└── Compose DSL 页面？
    └── → 方式4：LaunchedEffect + withContext
```

> **⚠️ 一致性原则**：选择方案时，还需关注当前项目或模块中已有的异步编程方式，应优先保持一致，避免在同一模块中混用多套异步方案。

**详细场景示例和代码**：见 [SCENARIOS.md](references/SCENARIOS.md)

---

## Compose DSL 中的协程

Compose DSL 页面（继承 `ComposeContainer`）使用 kotlinx 协程体系：

```kotlin
@Composable
fun MyContent() {
    var data by remember { mutableStateOf("") }
    LaunchedEffect(Unit) {
        // 默认在 Kuikly 线程执行（ComposeDispatcher）
        val result = withContext(Dispatchers.IO) {
            // 在 IO 线程执行耗时任务
            fetchData()
        }
        // 自动回到 Kuikly 线程
        data = result
    }
    Text(text = data)
}
```

**关键点：**
- `LaunchedEffect` 默认运行在 Kuikly 线程（通过 `ComposeDispatcher` 调度）
- 使用 `withContext(Dispatchers.IO)` 切换到 IO 线程执行耗时任务
- `withContext` 返回后自动回到 Kuikly 线程
- `viewModelScope` 也绑定到 Kuikly 线程，ViewModel 销毁时自动取消

**Dispatchers.IO 跨平台定义：**
```kotlin
// commonMain 中声明 expect
internal expect val Dispatchers.IO: CoroutineDispatcher

// androidMain / appleMain / ohosArm64Main
internal actual val Dispatchers.IO: CoroutineDispatcher
    get() = Dispatchers.IO  // 使用平台原生 IO 调度器

// jsMain（不支持多线程）
internal actual val Dispatchers.IO: CoroutineDispatcher
    get() = Dispatchers.Default
```

---

## 线程安全

### 线程安全规则

- Kuikly UI 相关类（View、Attr、Event、ObservableProperties、GlobalFunctions、Module 方法、Layout 等）**非线程安全**，只能在 Kuikly 线程访问

### 线程安全验证机制

**详细用法和示例**：见 [THREAD_SAFETY.md](references/THREAD_SAFETY.md)

```kotlin
override fun willInit() {
    super.willInit()
    Pager.VERIFY_THREAD = true              // 开启线程校验
    Pager.VERIFY_REACTIVE_OBSERVER = true   // 开启 observable 校验
    Pager.verifyFailed { exception ->       // 自定义验证失败处理
        println("线程安全验证失败: ${exception.message}")
        throw exception
    }
}
```

---

## 常见陷阱与正确做法

| ❌ 错误做法 | ✅ 正确做法 |
|------------|-----------|
| 在非 Kuikly 线程直接更新 observable | 通过 `Dispatchers.Kuikly` 或 `KuiklyContextScheduler` 切回 Kuikly 线程 |
| 在非 Kuikly 线程调用 Module 方法 | Module 的 acquireModule / toNative 等方法需在 Kuikly 线程调用 |
| 在动态化场景使用 kotlinx 协程 | 使用 Kuikly 内建协程或 Module 机制 |
| 在 Kuikly 线程外调用内建协程 API | 内建协程 API 只能在 Kuikly 线程调用 |
| 忘记处理 Pager 销毁后的回调 | `KuiklyContextScheduler` 回调检查 `cancel` 参数 |
| 在 `verifyFailed` 回调中操作 UI | 验证失败通常发生在非 Kuikly 线程，不能调用 UI API |
| Compose 中在 IO 线程更新 State | 使用 `withContext` 回到默认调度器后再更新 State |

---
