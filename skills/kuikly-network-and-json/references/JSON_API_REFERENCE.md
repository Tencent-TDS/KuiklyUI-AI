# JSONObject / JSONArray API 参考

## JSONObject API

```kotlin
import com.tencent.kuikly.core.nvi.serialization.json.JSONObject
```

### 构造

| 方式 | 说明 |
|------|------|
| `JSONObject()` | 创建空对象 |
| `JSONObject(jsonString)` | 从 JSON 字符串解析 |

### 安全读取（opt 系列，不抛异常）

| 方法 | 返回类型 | 默认值 |
|------|----------|--------|
| `optString("key")` | String | `""` |
| `optString("key", "fallback")` | String | `"fallback"` |
| `optInt("key")` | Int | `0` |
| `optInt("key", -1)` | Int | `-1` |
| `optLong("key")` | Long | `0L` |
| `optDouble("key")` | Double | `0.0` |
| `optBoolean("key")` | Boolean | `false` |
| `opt("key")` | Any? | `null`（获取原始值，不做类型转换） |
| `optJSONObject("key")` | JSONObject? | `null` |
| `optJSONArray("key")` | JSONArray? | `null` |

### 写入与查询

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `put("key", value)` | JSONObject | 写入键值对（支持 String/Int/Long/Double/Boolean/JSONObject/JSONArray） |
| `has("key")` | Boolean | 是否包含指定 key |
| `length()` | Int | 键值对数量 |
| `keys()` | Iterator\<String\> | 遍历所有 key |
| `keySet()` | Set\<String\> | 获取所有 key 的集合 |
| `toMap()` | MutableMap\<String, Any\> | 转为 Map |
| `toString()` | String | 转为 JSON 字符串 |

---

## JSONArray API

```kotlin
import com.tencent.kuikly.core.nvi.serialization.json.JSONArray
```

### 构造

| 方式 | 说明 |
|------|------|
| `JSONArray()` | 创建空数组 |
| `JSONArray(jsonString)` | 从 JSON 字符串解析 |

### 安全读取（opt 系列，按索引）

| 方法 | 返回类型 | 默认值 |
|------|----------|--------|
| `optString(index)` | String | `""` |
| `optInt(index)` | Int | `0` |
| `optLong(index)` | Long | `0L` |
| `optDouble(index)` | Double | `0.0` |
| `optBoolean(index)` | Boolean | `false` |
| `optJSONObject(index)` | JSONObject? | `null` |
| `optJSONArray(index)` | JSONArray? | `null` |

### 写入、删除与查询

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `put(value)` | JSONArray | 追加元素（支持 String/Int/Long/Double/Boolean/JSONObject/JSONArray） |
| `remove(index)` | Any? | 按索引移除元素，返回被移除的值 |
| `length()` | Int | 数组长度 |
| `toList()` | MutableList\<Any\> | 转为 List |
| `toString()` | String | 转为 JSON 字符串 |

### 遍历模式

```kotlin
for (i in 0 until jsonArr.length()) {
    val item = jsonArr.optJSONObject(i) ?: continue
    val name = item.optString("name")
}
```

---

## 必需 import 语句

```kotlin
import com.tencent.kuikly.core.nvi.serialization.json.JSONObject
import com.tencent.kuikly.core.nvi.serialization.json.JSONArray
```
