
# 工具类

## 定时器与延时

### Timer

```kotlin
import com.tencent.kuikly.core.timer.Timer
```

类似 Android Timer，用于周期性定时任务。

```kotlin
val timer = Timer()

// 启动定时器：延迟 1000ms 后每隔 2000ms 执行一次
timer.schedule(delay = 1000, period = 2000) {
    // 定时任务逻辑
}

// 取消定时器
timer.cancel()
```

---

### setTimeout / clearTimeout

```kotlin
import com.tencent.kuikly.core.timer.setTimeout
import com.tencent.kuikly.core.timer.clearTimeout
```

延时执行一次性任务。**推荐使用 `PagerScope` 扩展方法。**

```kotlin
// 在 Pager 中使用（推荐）
val ref = setTimeout(timeout = 1000) {
    // 1 秒后执行
}

// 取消延时任务
clearTimeout(ref)
```

---

## 协程

### LifecycleScope / GlobalScope

```kotlin
import com.tencent.kuikly.core.coroutines.LifecycleScope
import com.tencent.kuikly.core.coroutines.GlobalScope
```

Kuikly 自定义轻量级协程，支持 `launch`、`async`、`delay`。

```kotlin
// 在 Pager 中使用 lifecycleScope（推荐，与页面生命周期绑定）
lifecycleScope.launch {
    delay(1000)           // 延时 1 秒
    title = "Updated!"    // 更新 UI
}

// async + await
lifecycleScope.launch {
    val deferred = lifecycleScope.async {
        // 异步计算
        "result"
    }
    val result = deferred.await()
}

// 全局协程（不与页面生命周期绑定，谨慎使用）
GlobalScope.launch {
    delay(500)
}
```

> **注意：** 协程内的异常统一由框架处理，不需要手动捕获。

---

## 日志

### KLog

```kotlin
import com.tencent.kuikly.core.log.KLog
```

日志模块，支持宿主自定义实现打印接口。

```kotlin
KLog.i("TAG", "info 级别日志")
KLog.d("TAG", "debug 级别日志")
KLog.e("TAG", "error 级别日志")
```

---

## 时间

### DateTime

```kotlin
import com.tencent.kuikly.core.datetime.DateTime
```

```kotlin
// 获取当前时间戳（毫秒）
val timestamp = DateTime.currentTimestamp()

// 获取纳秒级时间戳
val nanoTime = DateTime.nanoTime()
```

---

## 无障碍

### AccessibilityRole

```kotlin
import com.tencent.kuikly.core.base.attr.AccessibilityRole
```

| 枚举值 | 说明 |
|--------|------|
| `AccessibilityRole.NONE` | 无角色 |
| `AccessibilityRole.BUTTON` | 按钮 |
| `AccessibilityRole.SEARCH` | 搜索框 |
| `AccessibilityRole.TEXT` | 文本 |
| `AccessibilityRole.IMAGE` | 图片 |
| `AccessibilityRole.CHECKBOX` | 复选框 |

```kotlin
attr {
    accessibility("登录按钮")
    accessibilityRole(AccessibilityRole.BUTTON)
    accessibilityInfo(clickable = true, longClickable = false)
}
```
