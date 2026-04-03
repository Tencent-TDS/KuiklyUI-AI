
# JSON 序列化

## JSONObject

```kotlin
import com.tencent.kuikly.core.nvi.serialization.json.JSONObject
```

JSON 对象，用于数据传输和序列化。

```kotlin
// 创建
val json = JSONObject()
json.put("name", "Kuikly")
json.put("version", 1)
json.put("enabled", true)
json.put("score", 98.5)

// 从字符串解析
val json2 = JSONObject("{\"key\": \"value\"}")

// 读取（带默认值）
val name = json.optString("name")            // 默认返回 ""
val name2 = json.optString("name", "默认值")
val version = json.optInt("version")          // 默认返回 0
val price = json.optDouble("price", 0.0)
val count = json.optLong("count")             // 默认返回 0L
val enabled = json.optBoolean("enabled")      // 默认返回 false
val subObj = json.optJSONObject("nested")     // 返回 JSONObject?
val arr = json.optJSONArray("list")           // 返回 JSONArray?

// 判断字段是否存在
val hasKey = json.has("name")

// 遍历
val keys = json.keys()      // Iterator<String>
val keySet = json.keySet()   // Set<String>

// 转 Map
val map = json.toMap()       // MutableMap<String, Any>

// 转字符串
val str = json.toString()

// 链式 put
val data = JSONObject()
    .put("key1", "value1")
    .put("key2", 42)
```

---

## JSONArray

```kotlin
import com.tencent.kuikly.core.nvi.serialization.json.JSONArray
```

JSON 数组。

```kotlin
// 创建
val arr = JSONArray()
arr.put("hello")
arr.put(42)
arr.put(true)
arr.put(3.14)

// 从字符串解析
val arr2 = JSONArray("[1, 2, 3]")

// 读取
val str = arr.optString(0)
val num = arr.optInt(1)
val bool = arr.optBoolean(2)
val dbl = arr.optDouble(3)
val obj = arr.optJSONObject(0)
val subArr = arr.optJSONArray(0)

// 长度
val len = arr.length()

// 删除
arr.remove(0)

// 转 List
val list = arr.toList()     // MutableList<Any>

// 转字符串
val jsonStr = arr.toString()
```
