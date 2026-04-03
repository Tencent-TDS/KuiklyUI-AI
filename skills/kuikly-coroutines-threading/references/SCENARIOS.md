# 异步编程场景与示例

## Contents
- [方式1：Kuikly 内建协程](#方式1kuikly-内建协程)
- [方式2：Module 机制](#方式2module-机制)
- [方式3：kotlinx 协程 + kuiklyx 协程](#方式3kotlinx-协程--kuiklyx-协程)
- [方式4：Compose DSL 协程](#方式4compose-dsl-协程)

---

## 方式1：Kuikly 内建协程

**适用场景：** 需要协程语法代替回调，提升代码可读性，没有多线程诉求。

### 示例1：串行异步调用

```kotlin
import com.tencent.kuikly.core.coroutines.launch
import com.tencent.kuikly.core.reactive.handler.observable
import kotlin.coroutines.suspendCoroutine

@Page("AsyncDemoPage")
internal class AsyncDemoPage : BasePager() {

    var dataObservable by observable("")

    // 将回调式 API 转换为挂起函数
    private suspend fun fetchLocal(): Int {
        return suspendCoroutine { continuation ->
            // 模拟异步回调
            acquireModule<SomeModule>("someModule").fetchLocal { result ->
                continuation.resumeWith(Result.success(result))
            }
        }
    }

    private suspend fun fetchRemote(type: Int): String {
        return suspendCoroutine { continuation ->
            acquireModule<NetworkModule>(NetworkModule.MODULE_NAME).requestGet(
                "https://example.com/api/data?type=$type",
                JSONObject()
            ) { data, success, _, _ ->
                if (success) {
                    continuation.resumeWith(Result.success(data.optString("result")))
                } else {
                    continuation.resumeWith(Result.success(""))
                }
            }
        }
    }

    override fun created() {
        super.created()
        val ctx = this
        // 通过 Pager.lifecycleScope 启动协程（绑定页面生命周期）
        lifecycleScope.launch {
            val type = fetchLocal()           // 串行调用1
            val data = fetchRemote(type)      // 串行调用2
            ctx.dataObservable = data         // 更新响应式字段
        }
    }
}
```

### 示例2：并发异步调用

```kotlin
import com.tencent.kuikly.core.coroutines.GlobalScope
import com.tencent.kuikly.core.coroutines.launch
import com.tencent.kuikly.core.coroutines.async
import com.tencent.kuikly.core.coroutines.delay

override fun created() {
    super.created()
    val ctx = this
    GlobalScope.launch {
        // 并发发起两个请求
        val deferred1 = async { fetchUserInfo() }
        val deferred2 = async { fetchUserPosts() }
        // 等待两个结果
        val userInfo = deferred1.await()
        val posts = deferred2.await()
        // 更新 UI
        ctx.userInfoObservable = userInfo
        ctx.postsObservable = posts
    }
}
```

### 示例3：延迟执行

```kotlin
import com.tencent.kuikly.core.coroutines.GlobalScope
import com.tencent.kuikly.core.coroutines.launch
import com.tencent.kuikly.core.coroutines.delay

GlobalScope.launch {
    delay(2000)  // 延迟 2 秒（参数单位为毫秒）
    // 执行后续逻辑
}
```

---

## 方式2：Module 机制

**适用场景：** 需要执行耗时任务，同时需要支持动态化。将耗时任务放到平台侧通过原生能力实现。

### 示例：通过 Module 执行耗时任务

```kotlin
@Page("ModuleAsyncPage")
internal class ModuleAsyncPage : BasePager() {

    var dataObservable by observable("")
    var loadingObservable by observable(false)

    override fun created() {
        super.created()
        val ctx = this
        ctx.loadingObservable = true
        // FetchDataModule 是通过 Module 机制预先实现的原生扩展 API
        val module = acquireModule<FetchDataModule>(FetchDataModule.MODULE_NAME)
        module.fetchData { result ->
            // Module 回调自动在 Kuikly 线程执行，可直接更新 UI
            ctx.dataObservable = result
            ctx.loadingObservable = false
        }
    }
}
```

### Module + 内建协程组合

```kotlin
override fun created() {
    super.created()
    val ctx = this
    lifecycleScope.launch {
        ctx.loadingObservable = true
        // 将 Module 回调包装为挂起函数
        val data = suspendCoroutine<String> { continuation ->
            val module = acquireModule<FetchDataModule>(FetchDataModule.MODULE_NAME)
            module.fetchData { result ->
                continuation.resumeWith(Result.success(result))
            }
        }
        ctx.dataObservable = data
        ctx.loadingObservable = false
    }
}
```

---

## 方式3：kotlinx 协程 + kuiklyx 协程

**适用场景：** 需要多线程能力，不考虑动态化，同时需要协程语法提升代码可读性。

### 依赖配置

```gradle
val commonMain by getting {
    dependencies {
        implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$KOTLINX_COROUTINES_VERSION")
        implementation("com.tencent.kuiklyx:coroutines:$KUIKLYX_COROUTINES_VERSION")
    }
}
```

### 示例：kotlinx 协程 + Dispatchers.Kuikly

```kotlin
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers

@Page("KotlinxCoroutinePage")
internal class KotlinxCoroutinePage : BasePager() {

    var dataObservable by observable("")
    var loadingObservable by observable(false)

    override fun created() {
        super.created()
        val ctx = this
        // 使用 kotlinx 协程，通过 Dispatchers.Kuikly 绑定 Kuikly 线程
        GlobalScope.launch(Dispatchers.Kuikly[ctx]) {
            ctx.loadingObservable = true
            // 在 IO 线程执行耗时任务
            val data = withContext(Dispatchers.IO) {
                fetchData()  // 耗时操作
            }
            // 自动回到 Kuikly 线程
            ctx.dataObservable = data
            ctx.loadingObservable = false
        }
    }
}
```

**关键点：**
- `Dispatchers.Kuikly` 需要通过 Pager 上下文获取：`Dispatchers.Kuikly[ctx]`
- `Dispatchers.IO` 是通过 KMP expect/actual 实现的自定义调度器
- 从 `withContext` 返回后自动回到 `Dispatchers.Kuikly` 所在的 Kuikly 线程

---

## 方式4：Compose DSL 协程

**适用场景：** Compose DSL 页面中的异步操作。

### 示例1：LaunchedEffect 基本用法

```kotlin
import androidx.compose.runtime.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers

@Page("ComposeDemoPage")
internal class ComposeDemoPage : ComposeContainer() {
    override fun willInit() {
        super.willInit()
        setContent {
            MyContent()
        }
    }
}

@Composable
private fun MyContent() {
    var count by remember { mutableStateOf(0) }
    // LaunchedEffect 默认在 Kuikly 线程执行
    LaunchedEffect(Unit) {
        while (true) {
            delay(1000)
            count++
        }
    }
    Text(text = "Count: $count", fontSize = 24.sp)
}
```

### 示例2：IO 线程执行耗时任务

```kotlin
@Composable
private fun DataContent() {
    var data by remember { mutableStateOf("Loading...") }
    LaunchedEffect(Unit) {
        // 切换到 IO 线程执行耗时任务
        val result = withContext(Dispatchers.IO) {
            fetchDataFromNetwork()  // 耗时操作
        }
        // 自动回到 Kuikly 线程，安全更新 State
        data = result
    }
    Text(text = data)
}
```

### 示例3：ViewModel + viewModelScope

```kotlin
import com.tencent.kuikly.lifecycle.ViewModel
import com.tencent.kuikly.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay

class TimerViewModel : ViewModel() {
    private val _seconds = MutableStateFlow(0)
    val seconds: StateFlow<Int> = _seconds.asStateFlow()

    fun start() {
        // viewModelScope 绑定 Kuikly 线程，ViewModel 销毁时自动取消
        viewModelScope.launch {
            while (true) {
                delay(1000)
                _seconds.value++
            }
        }
    }

    override fun onCleared() {
        super.onCleared()
        // viewModelScope 中的协程会自动取消
    }
}