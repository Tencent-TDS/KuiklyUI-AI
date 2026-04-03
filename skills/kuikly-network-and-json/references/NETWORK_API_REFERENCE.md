# NetworkModule API 参考

## 方法列表

### requestGet

发送 HTTP GET 请求。

```kotlin
fun requestGet(url: String, param: JSONObject, responseCallback: NMAllResponse)
```

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| url | String | ✅ | 请求 URL |
| param | JSONObject | ✅ | 请求参数 |
| responseCallback | NMAllResponse | ✅ | 请求回调 |

---

### requestPost

发送 HTTP POST 请求。

```kotlin
fun requestPost(url: String, param: JSONObject, responseCallback: NMAllResponse)
```

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| url | String | ✅ | 请求 URL |
| param | JSONObject | ✅ | 请求参数 |
| responseCallback | NMAllResponse | ✅ | 请求回调 |

---

### httpRequest

发送 HTTP 通用请求，支持自定义请求头、Cookie、超时时间。

```kotlin
fun httpRequest(
    url: String,
    isPost: Boolean,
    param: JSONObject,
    headers: JSONObject? = null,
    cookie: String? = null,
    timeout: Int = 30,
    responseCallback: NMAllResponse
)
```

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| url | String | ✅ | 请求 URL |
| isPost | Boolean | ✅ | 是否为 POST 请求 |
| param | JSONObject | ✅ | 请求参数 |
| headers | JSONObject? | ❌ | 请求头参数 |
| cookie | String? | ❌ | 请求 Cookie |
| timeout | Int | ❌ | 超时时间（秒），默认 30 |
| responseCallback | NMAllResponse | ✅ | 请求回调 |

**注意事项：**
1. `headers` 中可添加 `"Content-Type": "application/json"`
2. 如果接口回包数据类型为非 JSON 格式，回包数据字符串会以 `{data: xxxx}` 被包装一层，其中 `xxxx` 为接口实际回包内容

---

### requestGetBinary

发送二进制 HTTP GET 请求，返回 ByteArray。

```kotlin
fun requestGetBinary(url: String, param: JSONObject, responseCallback: NMDataResponse)
```

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| url | String | ✅ | 请求 URL |
| param | JSONObject | ✅ | 请求参数 |
| responseCallback | NMDataResponse | ✅ | 二进制数据回调 |

---

### requestPostBinary

发送二进制 HTTP POST 请求，携带 ByteArray 数据。

```kotlin
fun requestPostBinary(url: String, bytes: ByteArray, responseCallback: NMDataResponse)
```

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| url | String | ✅ | 请求 URL |
| bytes | ByteArray | ✅ | 请求二进制数据 |
| responseCallback | NMDataResponse | ✅ | 二进制数据回调 |

---

### httpRequestBinary

发送二进制 HTTP 通用请求。

```kotlin
fun httpRequestBinary(
    url: String,
    isPost: Boolean,
    bytes: ByteArray,
    param: JSONObject? = null,
    headers: JSONObject? = null,
    cookie: String? = null,
    timeout: Int = 30,
    responseCallback: NMDataResponse
)
```

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| url | String | ✅ | 请求 URL |
| isPost | Boolean | ✅ | 是否为 POST 请求 |
| bytes | ByteArray | ✅ | 请求二进制数据 |
| param | JSONObject? | ❌ | 请求参数 |
| headers | JSONObject? | ❌ | 请求头参数 |
| cookie | String? | ❌ | 请求 Cookie |
| timeout | Int | ❌ | 超时时间（秒），默认 30 |
| responseCallback | NMDataResponse | ✅ | 二进制数据回调 |

---

## 回调类型

### NMAllResponse

标准请求回调，返回 JSON 数据。

```kotlin
typealias NMAllResponse = (data: JSONObject, success: Boolean, errorMsg: String, response: NetworkResponse) -> Unit
```

| 参数 | 类型 | 说明 |
|------|------|------|
| data | JSONObject | 返回数据 |
| success | Boolean | 请求是否成功 |
| errorMsg | String | 错误信息（成功时为空字符串） |
| response | NetworkResponse | 响应包信息 |

### NMDataResponse

二进制请求回调，返回 ByteArray 数据。

```kotlin
typealias NMDataResponse = (data: ByteArray, success: Boolean, errorMsg: String, response: NetworkResponse) -> Unit
```

| 参数 | 类型 | 说明 |
|------|------|------|
| data | ByteArray | 返回的二进制数据 |
| success | Boolean | 请求是否成功 |
| errorMsg | String | 错误信息 |
| response | NetworkResponse | 响应包信息 |

### NetworkResponse

网络响应信息。

```kotlin
data class NetworkResponse(val headerFields: JSONObject, val statusCode: Int? = null)
```

| 参数 | 类型 | 说明 |
|------|------|------|
| headerFields | JSONObject | 响应头参数 |
| statusCode | Int? | HTTP 响应状态码（低版本端可能为 null） |

---

## 必需 import 语句

```kotlin
import com.tencent.kuikly.core.module.NetworkModule
```
