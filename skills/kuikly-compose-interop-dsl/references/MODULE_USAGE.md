# 在 Compose 中使用 Kuikly Module

## 获取 Pager 与 Module

```kotlin
import com.tencent.kuikly.compose.ui.platform.LocalActivity
import com.tencent.kuikly.core.pager.Pager

val pager = LocalActivity.current.getPager() as Pager

// acquireModule: 找不到则抛异常
val router = pager.acquireModule<RouterModule>(RouterModule.MODULE_NAME)
// getModule: 找不到则返回 null
val sp = pager.getModule<SharedPreferencesModule>(SharedPreferencesModule.MODULE_NAME)
```

## 自定义 Module 注册

在 `ComposeContainer` 中重写 `createExternalModules()`：

```kotlin
@Page("myPage")
class MyPage : ComposeContainer() {
    override fun createExternalModules(): Map<String, Module>? {
        val modules = (super.createExternalModules() as? HashMap) ?: hashMapOf()
        modules[MyBusinessModule.MODULE_NAME] = MyBusinessModule()
        return modules
    }
    override fun willInit() {
        super.willInit()
        setContent { MyScreen() }
    }
}
```

## 注意事项

- 监听类 Module（如 NotifyModule）需用 `DisposableEffect` + `onDispose` 管理生命周期
- 耗时 Module 调用应放在 `LaunchedEffect` 或协程中，避免阻塞 Composable