---
name: kuikly-network-and-json
description: "Kuikly NetworkModule 网络请求与 JSONObject/JSONArray 数据处理助手。在Kuikly中发起网络请求、处理 JSON 数据、上传下载二进制等场景时使用。"
---

# Kuikly 网络请求

## Contents
- [Core Guidelines](#core-guidelines)
- [Workflow: HTTP Requests](#workflow-http-requests)
- [Workflow: Binary Requests](#workflow-binary-requests)
- [Workflow: Parsing JSON](#workflow-parsing-json)
- [参考资源](#参考资源)

## Core Guidelines

- **获取 NetworkModule：**
  - **Kuikly DSL（Pager / ComposeView）：** 直接调用 `acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)` 获取（找不到时抛异常），或用 `getModule<NetworkModule>(NetworkModule.MODULE_NAME)` 安全获取（找不到返回 null）。推荐 `lazy` 缓存实例。
  - **Compose DSL（@Composable 函数中）：** 通过 `LocalActivity.current.getPager()` 获取 Pager 实例，再调用 `pager.acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)`。在 ComposeContainer 类内部（非 @Composable 上下文）可直接调用 `acquireModule`。
- **检查 success：** 回调中先判断 `success`，为 `true` 时才安全使用 `data`。失败时通过 `errorMsg` 和 `response.statusCode`（注意：`Int?` 可空）排查。
- **设置超时：** `httpRequest` / `httpRequestBinary` 可指定 `timeout`（秒），默认 30。
- **非 JSON 回包：** SDK 自动包装为 `{"data": "原始内容"}`，通过 `data.optString("data")` 获取。

---

## Workflow: HTTP Requests

**方法选择：**

| 场景 | 方法 |
|------|------|
| 简单 GET（无自定义 headers） | `requestGet(url, param, callback)` |
| 简单 POST（无自定义 headers） | `requestPost(url, param, callback)` |
| 自定义 headers / Cookie / 超时 | `httpRequest(url, isPost, param, headers, cookie, timeout, callback)` |

> 完整方法签名和参数说明见 [NetworkModule API 参考](./references/NETWORK_API_REFERENCE.md)。

### 获取 NetworkModule

**Kuikly DSL（在 Pager / ComposeView 中）：**

```kotlin
import com.tencent.kuikly.core.module.NetworkModule

// lazy 延迟初始化（推荐）
private val networkModule by lazy(LazyThreadSafetyMode.NONE) {
    acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)
}
```

**Compose DSL（在 @Composable 函数中）：**

```kotlin
import com.tencent.kuikly.core.module.NetworkModule
import com.tencent.kuikly.compose.ui.platform.LocalActivity
import com.tencent.kuikly.core.pager.Pager

@Composable
fun MyScreen() {
    val pager = LocalActivity.current.getPager() as Pager
    val networkModule = pager.acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)
    // 使用 networkModule 发起请求...
}
```

**Compose DSL（在 ComposeContainer 类内部）：**

```kotlin
@Page("MyComposePage")
class MyComposePage : ComposeContainer() {
    // ComposeContainer 继承自 Pager，可直接调用 acquireModule
    private val networkModule by lazy(LazyThreadSafetyMode.NONE) {
        acquireModule<NetworkModule>(NetworkModule.MODULE_NAME)
    }
}
```

### GET 请求

```kotlin
networkModule.requestGet(
    "https://example.com/api/data",
    JSONObject().apply { put("key", "value") }
) { data, success, errorMsg, response ->
    if (success) {
        val name = data.optString("name")
        val count = data.optInt("count")
    } else {
        val statusCode = response.statusCode // Int? 可能为 null
    }
}
```

### POST 请求

```kotlin
networkModule.requestPost(
    "https://example.com/api/submit",
    JSONObject().apply {
        put("username", "test")
        put("password", "123456")
    }
) { data, success, errorMsg, response ->
    if (success) {
        val result = data.optString("result")
    }
}
```

### 通用请求（httpRequest）

```kotlin
networkModule.httpRequest(
    url = "https://example.com/api/data",
    isPost = true,
    param = JSONObject().apply { put("id", 1) },
    headers = JSONObject().apply {
        put("Content-Type", "application/json")
        put("Authorization", "Bearer token")
    },
    cookie = "session_id=abc123",
    timeout = 30
) { data, success, errorMsg, response ->
    // response.statusCode   - HTTP 状态码（Int?）
    // response.headerFields - 响应头（JSONObject）
    if (success) { /* 处理数据 */ }
}
```

---

## Workflow: Binary Requests

**方法选择：**

| 场景 | 方法 |
|------|------|
| 下载二进制（GET） | `requestGetBinary(url, param, callback)` |
| 上传二进制（POST） | `requestPostBinary(url, bytes, callback)` |
| 自定义 headers / Cookie / 超时 | `httpRequestBinary(url, isPost, bytes, param, headers, cookie, timeout, callback)` |

> `requestPostBinary` 内部 `param` 传 null。若需同时传 binary body 和 query 参数，使用 `httpRequestBinary`。

### 下载二进制（GET）

```kotlin
networkModule.requestGetBinary(
    "https://example.com/file.png",
    JSONObject()
) { data, success, errorMsg, response ->
    if (success) {
        val fileBytes: ByteArray = data
    }
}
```

### 上传二进制（POST）

```kotlin
networkModule.requestPostBinary(
    "https://example.com/upload",
    imageBytes
) { data, success, errorMsg, response ->
    if (success) {
        val responseBytes: ByteArray = data
    }
}
```

### 通用二进制请求（httpRequestBinary）

```kotlin
networkModule.httpRequestBinary(
    url = "https://example.com/api/binary",
    isPost = true,
    bytes = uploadBytes,
    param = JSONObject().apply { put("type", "image") },
    headers = JSONObject().apply { put("Content-Type", "application/octet-stream") },
    cookie = "session_id=abc123",
    timeout = 60
) { data, success, errorMsg, response ->
    if (success) {
        val responseBytes: ByteArray = data
    }
}
```

---

## Workflow: Parsing JSON

使用 `opt*` 系列方法安全读取（不会抛异常，返回默认值）。

> 完整的 JSONObject/JSONArray API 列表见 [JSON API 参考](./references/JSON_API_REFERENCE.md)。

### 核心用法示例

```kotlin
val jsonObj = JSONObject(jsonString)

// 安全读取（不存在时返回默认值）
val str = jsonObj.optString("key")             // 默认 ""
val num = jsonObj.optInt("key")                // 默认 0
val innerObj = jsonObj.optJSONObject("nested")  // JSONObject?
val array = jsonObj.optJSONArray("list")        // JSONArray?

// 写入
jsonObj.put("key", "value")

// 遍历所有 key
for (key in jsonObj.keys()) { /* ... */ }
```

### JSONArray 遍历

```kotlin
val jsonArr = jsonObj.optJSONArray("list") ?: JSONArray()
for (i in 0 until jsonArr.length()) {
    val item = jsonArr.optJSONObject(i) ?: continue
    val name = item.optString("name")
}
```

---

## 参考资源
- [NetworkModule API 参考](./references/NETWORK_API_REFERENCE.md)
- [JSONObject/JSONArray API 参考](./references/JSON_API_REFERENCE.md)