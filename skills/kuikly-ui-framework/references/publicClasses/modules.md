
# 内置模块

> 所有模块都通过 `acquireModule<T>(MODULE_NAME)` 获取实例。

## Module 模块基类

```kotlin
import com.tencent.kuikly.core.module.Module
```

所有自定义模块需继承 `Module`，并实现 `moduleName()` 方法。

```kotlin
class MyModule : Module() {
    override fun moduleName() = "MyModule"

    fun doSomething(data: JSONObject, callback: CallbackFn?) {
        // 异步调用 Native
        asyncToNativeMethod("doSomething", data, callback)
    }

    fun getSomething(key: String): String {
        // 同步调用 Native
        return syncToNativeMethod("getSomething", JSONObject().put("key", key), null)
    }
}
```

---

## NetworkModule

```kotlin
import com.tencent.kuikly.core.module.NetworkModule
```

Http 网络请求模块。

```kotlin
val network = acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)

// GET 请求
network.requestGet("https://api.example.com/data", JSONObject()) { data, success, errorMsg, response ->
    if (success) {
        val result = data.optString("result")
        val headers = response.headerFields   // 回包 headers
        val statusCode = response.statusCode  // HTTP 状态码（Int?）
    }
}

// POST 请求
network.requestPost("https://api.example.com/submit", JSONObject().put("key", "value")) { data, success, errorMsg, response ->
    // 处理响应
}

// 通用请求（自定义 headers / cookie / timeout）
network.httpRequest(
    url = "https://api.example.com/data",
    isPost = true,
    param = JSONObject().put("key", "value"),
    headers = JSONObject().put("Content-Type", "application/json"),
    cookie = "session=abc123",
    timeout = 30
) { data, success, errorMsg, response ->
    // 处理响应
}

// 二进制 POST 请求
network.requestPostBinary("https://api.example.com/upload", byteArray) { data, success, errorMsg, response ->
    // data 类型为 ByteArray
}

// 二进制 GET 请求
network.requestGetBinary("https://api.example.com/file", JSONObject()) { data, success, errorMsg, response ->
    // data 类型为 ByteArray
}
```

> **注意：** 如果接口回包数据类型为非 JSON 格式，回包数据会以 `{data:xxxx}` 被包装一层。

**NetworkResponse 数据类：**

```kotlin
import com.tencent.kuikly.core.module.NetworkResponse

data class NetworkResponse(
    val headerFields: JSONObject,   // 响应头
    val statusCode: Int? = null     // HTTP 状态码（null 表示端版本较低）
)
```

---

## RouterModule

```kotlin
import com.tencent.kuikly.core.module.RouterModule
```

```kotlin
val router = acquireModule<RouterModule>(RouterModule.MODULE_NAME)

// 打开 Kuikly 页面
router.openPage(
    pageName = "DetailPage",                   // @Page 注解名
    pageData = JSONObject().put("id", 123),    // 页面传参
    hotReloadIp = null                          // 热重载 IP（可选）
)

// 关闭当前页面
router.closePage()
```

---

## SharedPreferencesModule

```kotlin
import com.tencent.kuikly.core.module.SharedPreferencesModule
```

轻量级持久化存储模块。

```kotlin
val sp = acquireModule<SharedPreferencesModule>(SharedPreferencesModule.MODULE_NAME)

// 写入
sp.setString("username", "kuikly")
sp.setInt("count", 42)
sp.setFloat("score", 98.5f)
sp.setObject("config", JSONObject().put("theme", "dark"))

// 读取
val username = sp.getString("username")     // 返回 String
val count = sp.getInt("count")              // 返回 Int?
val score = sp.getFloat("score")            // 返回 Float?
val config = sp.getObject("config")         // 返回 JSONObject?
```

---

## NotifyModule

```kotlin
import com.tencent.kuikly.core.module.NotifyModule
```

Native 与 Kuikly 或 Kuikly 与 Kuikly 之间的通信模块。

```kotlin
val notify = acquireModule<NotifyModule>(NotifyModule.MODULE_NAME)

// 添加通知监听
val callbackRef = notify.addNotify("eventName", crossProcess = false) { data ->
    // data 为 JSONObject?
    val value = data?.optString("key")
}

// 发送通知
notify.postNotify(
    eventName = "eventName",
    eventData = JSONObject().put("key", "value"),
    crossProcess = false    // 安卓跨进程
)

// 移除通知
notify.removeNotify("eventName", callbackRef)
```

---

## CalendarModule

```kotlin
import com.tencent.kuikly.core.module.CalendarModule
import com.tencent.kuikly.core.module.ICalendar
```

日期计算模块。

```kotlin
val calendar = acquireModule<CalendarModule>(CalendarModule.MODULE_NAME)

// 获取当前时间的日历实例
val cal = calendar.newCalendarInstance()

// 获取指定时间戳的日历实例
val cal2 = calendar.newCalendarInstance(timeMillis = 1700000000000L)

// 读取字段
val year = cal.get(ICalendar.Field.YEAR)
val month = cal.get(ICalendar.Field.MONTH)        // 0 = 一月，11 = 十二月
val day = cal.get(ICalendar.Field.DAY_OF_MONTH)
val dayOfWeek = cal.get(ICalendar.Field.DAY_OF_WEEK) // 1=周日, 2=周一...7=周六
val hour = cal.get(ICalendar.Field.HOUR_OF_DAY)    // 24 小时制

// 设置字段 & 链式调用
val timestamp = cal.set(ICalendar.Field.YEAR, 2025)
    .set(ICalendar.Field.MONTH, 0)  // 一月
    .set(ICalendar.Field.DAY_OF_MONTH, 1)
    .timeInMillis()

// 加减时间
val fiveDaysLater = cal.add(ICalendar.Field.DAY_OF_MONTH, 5).timeInMillis()

// 格式化时间
val formatted = calendar.formatTime(1700000000000L, "yyyy-MM-dd HH:mm:ss")

// 解析格式化的时间字符串
val millis = calendar.parseFormattedTime("2025-01-01 12:00:00", "yyyy-MM-dd HH:mm:ss")
```

**ICalendar.Field 枚举：**

| 枚举值 | 说明 |
|--------|------|
| `YEAR` | 年 |
| `MONTH` | 月（0 = 一月，11 = 十二月） |
| `DAY_OF_MONTH` | 日（从 1 开始） |
| `DAY_OF_YEAR` | 一年中的第几天（从 1 开始） |
| `DAY_OF_WEEK` | 星期几（1=周日，2=周一...7=周六） |
| `HOUR_OF_DAY` | 小时（24 小时制） |
| `MINUS` | 分钟 |
| `SECOND` | 秒 |
| `MILLISECOND` | 毫秒 |

---

## CodecModule

```kotlin
import com.tencent.kuikly.core.module.CodecModule
```

字符串编解码模块。

```kotlin
val codec = acquireModule<CodecModule>(CodecModule.MODULE_NAME)

// URL 编码/解码
val encoded = codec.urlEncode("hello world")    // "hello%20world"
val decoded = codec.urlDecode("hello%20world")  // "hello world"

// Base64 编码/解码
val b64 = codec.base64Encode("hello")
val original = codec.base64Decode(b64)

// MD5
val md5_16 = codec.md5("hello")           // 16 位
val md5_32 = codec.md5With32("hello")     // 32 位

// SHA256
val sha = codec.sha256("hello")
```

---

## SnapshotModule

```kotlin
import com.tencent.kuikly.core.module.SnapshotModule
```

生成当前页面的快照，下次打开该页面时以快照作为首屏，实现 0 白屏体验。

```kotlin
val snapshot = acquireModule<SnapshotModule>(SnapshotModule.MODULE_NAME)

// 建议 key 包含：版本号 + 页面名 + 夜间模式
snapshot.snapshotPager("v1.0_HomePage_light")
```

---

## MemoryCacheModule

```kotlin
import com.tencent.kuikly.core.module.MemoryCacheModule
```

```kotlin
val cache = acquireModule<MemoryCacheModule>(MemoryCacheModule.MODULE_NAME)

// 设置缓存
cache.setObject("key", value)

// 预加载图片
val status = cache.cacheImage("https://example.com/img.png", sync = false) { status ->
    // status.state 为 ImageCacheStatus
    // status.width / status.height 为图片尺寸
}
```

---

## PerformanceModule

```kotlin
import com.tencent.kuikly.core.module.PerformanceModule
```

```kotlin
val perf = acquireModule<PerformanceModule>(PerformanceModule.MODULE_NAME)

perf.getPerformanceData { data ->
    data?.let {
        val firstPaint = it.pageLoadTime?.firstPaintCost   // 首屏耗时
        val mainFPS = it.mainFPS                           // 主线程 FPS
        val memory = it.memory?.peakIncrement              // 内存峰值增量
    }
}
```
