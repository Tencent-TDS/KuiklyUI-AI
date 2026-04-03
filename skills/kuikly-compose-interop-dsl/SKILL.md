---
name: kuikly-compose-interop-dsl
description: "Compose DSL 混用 Kuikly DSL 完整开发助手。指导如何在 Compose DSL 页面中嵌入 Kuikly DSL 组件（DeclarativeBaseView / ViewContainer)及在 Compose 中调用 Kuikly Module。当用户需要在 Compose 页面中复用 Kuikly DSL 组件、封装原生 View 为 Composable、在 Compose 中调用 Kuikly Module时使用。"
---

# Compose DSL 混用 Kuikly DSL 组件

> ⚠️ **注意**：本 skill 仅适用于 **Compose DSL 中混用 Kuikly DSL**（即在 Compose 页面中嵌入 Kuikly DSL 组件），**不支持**反向在 Kuikly DSL 中混用 Compose DSL。

## Contents

- ComposeContainer 页面搭建
- MakeKuiklyComposeNode API（原子 / 容器）
- 关键约束与常见错误
- Compose 中使用 Kuikly Module
- 详细参考文档

## ComposeContainer 页面搭建

Compose 页面继承 `ComposeContainer`（即 `Pager`），在 `willInit()` 中调用 `setContent {}`：

```kotlin
import com.tencent.kuikly.compose.ComposeContainer
import com.tencent.kuikly.compose.setContent
import com.tencent.kuikly.core.annotations.Page

@Page("myPage")
class MyPage : ComposeContainer() {
    override fun willInit() {
        super.willInit()
        setContent { MyScreen() }
    }
}
```

`ComposeContainer` 继承自 Kuikly Core 的 `Pager`，拥有统一的跨端页面生命周期（`willInit` / `created` / `pageDidAppear` / `pageDidDisappear` / `pageWillDestroy`）。

## MakeKuiklyComposeNode API

桥接入口，将 Kuikly DSL 组件嵌入 Compose 渲染树。两个重载：

### 原子组件（无子节点）

适用于 `DeclarativeBaseView` 子类（Video、地图等自渲染组件）：

```kotlin
@Composable
fun <T : DeclarativeBaseView<*, *>> MakeKuiklyComposeNode(
    factory: () -> T,
    modifier: Modifier,
    viewInit: T.() -> Unit = {},       // 创建时调用一次
    viewUpdate: (T) -> Unit = {},      // 每次重组时调用
    measurePolicy: MeasurePolicy = KuiklyDefaultMeasurePolicy
)
```

**最小示例**（封装 VideoView）：

```kotlin
import androidx.compose.runtime.Composable
import com.tencent.kuikly.compose.extension.MakeKuiklyComposeNode
import com.tencent.kuikly.compose.ui.Modifier
import com.tencent.kuikly.core.views.VideoPlayControl
import com.tencent.kuikly.core.views.VideoView

@Composable
fun Video(src: String, playControl: VideoPlayControl, modifier: Modifier = Modifier) {
    MakeKuiklyComposeNode<VideoView>(
        factory = { VideoView() },
        modifier = modifier,
        viewInit = { getViewAttr().run { src(src); playControl(playControl) } },
        viewUpdate = { it.getViewAttr().run { src(src); playControl(playControl) } },
    )
}
```

### 容器组件（有子节点）

适用于 `ViewContainer` 子类，可挂载 Compose 子节点：

```kotlin
@Composable
fun <T : DeclarativeBaseView<*, *>> MakeKuiklyComposeNode(
    factory: () -> T,
    modifier: Modifier,
    content: @Composable () -> Unit,   // 子内容插槽
    viewInit: T.() -> Unit = {},
    viewUpdate: (T) -> Unit = {},
    measurePolicy: MeasurePolicy = DefaultColumnMeasurePolicy
)
```

**最小示例**（封装容器卡片）：

```kotlin
import com.tencent.kuikly.core.base.ViewContainer
import com.tencent.kuikly.core.base.ContainerAttr
import com.tencent.kuikly.core.base.Event
import com.tencent.kuikly.core.base.ViewConst

class KuiklyCard : ViewContainer<ContainerAttr, Event>() {
    override fun createAttr() = ContainerAttr()
    override fun createEvent() = Event()
    override fun viewName() = ViewConst.TYPE_VIEW

    fun setup(cornerRadius: Float = 12f, onClick: (() -> Unit)? = null) {
        attr { borderRadius(cornerRadius) }
        onClick?.let { event { click { onClick() } } }
    }
}

@Composable
fun KuiklyCard(
    modifier: Modifier = Modifier,
    cornerRadius: Float = 12f,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    MakeKuiklyComposeNode<KuiklyCard>(
        factory = { KuiklyCard() },
        modifier = modifier,
        viewInit = { setup(cornerRadius, onClick) },
        viewUpdate = { it.setup(cornerRadius, onClick) },
        content = content,
    )
}
```

## 关键约束与常见错误

### factory 基类选择

| 场景 | 基类 |
|------|------|
| 原子组件（无子节点） | `DeclarativeBaseView` |
| 容器组件（有子节点） | `ViewContainer` |
| ❌ 禁止 | `ComposeView` |

### ❌ 禁止将 ComposeView 子类传入 factory

`ComposeView` 的扁平化优化导致布局 frame 丢失，视图不可见：

```kotlin
// ❌ 编译通过但运行时不可见
class MyView : ComposeView<ComposeAttr, ComposeEvent>() { ... }
MakeKuiklyComposeNode<MyView>(factory = { MyView() }, ...)

// ✅ 原子组件用 DeclarativeBaseView
// ✅ 容器组件用 ViewContainer
```

### viewUpdate 必须同步更新

`viewInit` 只在创建时调用一次；随 Compose 状态变化的属性和事件回调**必须**在 `viewUpdate` 中也设置，否则重组后不更新。

## Compose 中使用 Kuikly Module

通过 `LocalActivity.current.getPager()` 获取 Pager 实例，再调用 `acquireModule`：

```kotlin
import com.tencent.kuikly.compose.ui.platform.LocalActivity
import com.tencent.kuikly.core.pager.Pager
import com.tencent.kuikly.core.module.RouterModule

@Composable
fun MyScreen() {
    val pager = LocalActivity.current.getPager() as Pager
    val router = pager.acquireModule<RouterModule>(RouterModule.MODULE_NAME)
    // 使用 router.openPage("targetPage", params) / router.closePage() 等
}
```

> `acquireModule` 找不到时抛异常；`getModule` 找不到时返回 null。

## 详细参考

- **组件封装详解**（原子/容器、viewInit vs viewUpdate、错误排查）：[COMPONENT_WRAPPING.md](references/COMPONENT_WRAPPING.md)
- **Module 使用详情**（Router / Notify / SP / PageData / 自定义 Module）：[MODULE_USAGE.md](references/MODULE_USAGE.md)