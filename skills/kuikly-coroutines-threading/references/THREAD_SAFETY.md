# 线程安全指南

## Contents
- [线程安全规则](#线程安全规则)
- [验证机制 API](#验证机制-api)
- [使用示例](#使用示例)
- [常见线程安全问题](#常见线程安全问题)

---

## 线程安全规则

### Kuikly 线程约束

以下类和 API **只能在 Kuikly 线程访问**，非线程安全：

| 类/API | 说明 |
|--------|------|
| View / DeclarativeBaseView | 所有视图组件（创建、销毁） |
| Attr | 视图属性（设置） |
| Event | 事件（注册、注销） |
| ObservableProperties | 响应式属性（observable 读写） |
| GlobalFunctions | 全局回调函数（创建） |
| Module 方法 | toNative / syncToNativeMethod / asyncToNativeMethod / acquireModule |
| Layout (FlexNode) | 布局标脏（markDirty，由 attr 变更触发） |
| setTimeout | 定时器 |

---

## 验证机制 API

Kuikly 提供三个验证 API，帮助在开发阶段发现线程安全问题：

### Pager.VERIFY_THREAD

开启后，在非 Kuikly 线程访问 UI 相关 API 时触发验证失败。

```kotlin
import com.tencent.kuikly.core.pager.Pager

Pager.VERIFY_THREAD = true  // 开启线程校验
```

**检查范围：** View 创建/销毁、Attr 设置、Event 注册、GlobalFunctions 操作等。

### Pager.VERIFY_REACTIVE_OBSERVER

开启后，响应式属性在错误上下文中访问时触发验证失败。

```kotlin
Pager.VERIFY_REACTIVE_OBSERVER = true  // 开启 observable 校验
```

**检查范围：** observable 属性的读写、observableList/observableSet 的操作。

### Pager.verifyFailed

自定义验证失败时的处理逻辑，默认抛出异常。

```kotlin
Pager.verifyFailed { exception ->
    // 自定义处理：记录日志、上报等
    println("线程安全验证失败: ${exception.message}")
}
```

**注意：** `verifyFailed` 回调可能在非 Kuikly 线程执行，不能在回调中调用 UI API。

---

## 使用示例

### 开发阶段开启全部验证

```kotlin
@Page("DebugPage")
internal class DebugPage : BasePager() {

    override fun willInit() {
        super.willInit()
        if (pageData.params.optBoolean("debug")) {
            Pager.VERIFY_THREAD = true
            Pager.VERIFY_REACTIVE_OBSERVER = true
            Pager.verifyFailed { exception ->
                println("线程安全验证失败: ${exception.message}")
                throw exception  // 开发阶段抛出异常以便发现问题
            }
        }
    }
}
```

### 生产环境记录日志

```kotlin
override fun willInit() {
    super.willInit()
    Pager.VERIFY_THREAD = true
    Pager.VERIFY_REACTIVE_OBSERVER = true
    Pager.verifyFailed { exception ->
        // 生产环境只记录日志，不抛异常
        Logger.error("ThreadSafety", exception.message ?: "unknown")
    }
}
```

---

## 常见线程安全问题

### 问题1：在异步回调中直接更新 observable

```kotlin
// ❌ 错误：异步回调可能在非 Kuikly 线程
someAsyncApi { result ->
    dataObservable = result  // 可能崩溃或数据不一致
}

// ✅ 正确：切回 Kuikly 线程
someAsyncApi { result ->
    KuiklyContextScheduler.runOnKuiklyThread(pagerId) { cancel ->
        if (!cancel) {
            dataObservable = result
        }
    }
}
```

### 问题2：Pager 销毁后仍然执行回调

```kotlin
// ❌ 错误：未检查 Pager 是否已销毁
KuiklyContextScheduler.runOnKuiklyThread(pagerId) { cancel ->
    dataObservable = "data"  // Pager 可能已销毁
}

// ✅ 正确：检查 cancel 参数
KuiklyContextScheduler.runOnKuiklyThread(pagerId) { cancel ->
    if (cancel) return@runOnKuiklyThread  // Pager 已销毁，跳过
    dataObservable = "data"
}
```

---

## 最佳实践

1. **开发和测试阶段**建议开启 `VERIFY_THREAD` 和 `VERIFY_REACTIVE_OBSERVER`
2. **生产环境**可关闭验证以避免性能开销，或改为只记录日志
3. 验证机制用于**问题排查**，不应依赖它们来解决线程安全问题
4. 优先使用 Kuikly 内建协程或 Module 机制，避免手动管理线程安全
5. 使用 `lifecycleScope` 而非 `GlobalScope`，确保协程随页面销毁自动取消
