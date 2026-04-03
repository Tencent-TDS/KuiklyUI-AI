# 组件封装详解

## Contents

- 封装流程概览
- 原子组件封装（DeclarativeBaseView）
- 容器组件封装（ViewContainer）
- viewInit vs viewUpdate 最佳实践
- 完整 Demo：VideoView 封装与使用
- 常见错误排查

## 封装流程

```
已有 Kuikly DSL 组件 → MakeKuiklyComposeNode 包装 → Compose Composable
```

如果 DSL 组件尚不存在，先继承 `DeclarativeBaseView`（原子）或 `ViewContainer`（容器）创建。

---

## 原子组件封装

### DSL 侧：定义 Attr / Event / View

```kotlin
class MyPlayerAttr : Attr() {
    fun src(url: String) { "src" bindTo url }
    fun autoPlay(enable: Boolean) { "autoPlay" bindTo enable }
}

class MyPlayerEvent : Event() {
    fun onPlayStateChanged(handlerFn: (state: String) -> Unit) {
        registerEvent("playStateChanged") { eventData ->
            handlerFn(eventData.optString("state"))
        }
    }
}

class MyPlayerView : DeclarativeBaseView<MyPlayerAttr, MyPlayerEvent>() {
    override fun createAttr() = MyPlayerAttr()
    override fun createEvent() = MyPlayerEvent()
    override fun viewName() = "MyNativePlayer" // 对应原生注册的 View 类型名
}
```

### Compose 侧：MakeKuiklyComposeNode 包装

```kotlin
import androidx.compose.runtime.Composable
import com.tencent.kuikly.compose.extension.MakeKuiklyComposeNode
import com.tencent.kuikly.compose.ui.Modifier

@Composable
fun MyPlayer(
    src: String,
    autoPlay: Boolean = true,
    onPlayStateChanged: (String) -> Unit = {},
    modifier: Modifier = Modifier,
) {
    MakeKuiklyComposeNode<MyPlayerView>(
        factory = { MyPlayerView() },
        modifier = modifier,
        viewInit = {
            getViewAttr().run { src(src); autoPlay(autoPlay) }
            getViewEvent().run { onPlayStateChanged(handlerFn = onPlayStateChanged) }
        },
        viewUpdate = {
            it.getViewAttr().run { src(src); autoPlay(autoPlay) }
            it.getViewEvent().run { onPlayStateChanged(handlerFn = onPlayStateChanged) }
        }
    )
}
```

---

## 容器组件封装

### DSL 侧：继承 ViewContainer

```kotlin
import com.tencent.kuikly.core.base.ViewContainer
import com.tencent.kuikly.core.base.ContainerAttr
import com.tencent.kuikly.core.base.Event
import com.tencent.kuikly.core.base.ViewConst

class GradientCard : ViewContainer<ContainerAttr, Event>() {
    override fun createAttr() = ContainerAttr()
    override fun createEvent() = Event()
    override fun viewName() = ViewConst.TYPE_VIEW

    fun setup(cornerRadius: Float = 16f, onClick: (() -> Unit)? = null) {
        attr { borderRadius(cornerRadius) }
        onClick?.let { event { click { onClick() } } }
    }
}
```

### Compose 侧：带 content 参数的重载

```kotlin
import androidx.compose.runtime.Composable
import com.tencent.kuikly.compose.extension.MakeKuiklyComposeNode
import com.tencent.kuikly.compose.ui.Modifier

@Composable
fun GradientCard(
    modifier: Modifier = Modifier,
    cornerRadius: Float = 16f,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit,
) {
    MakeKuiklyComposeNode<GradientCard>(
        factory = { GradientCard() },
        modifier = modifier,
        viewInit = { setup(cornerRadius, onClick) },
        viewUpdate = { it.setup(cornerRadius, onClick) },
        content = content,
    )
}
```

---

## viewInit vs viewUpdate 最佳实践

| 属性类型 | viewInit | viewUpdate | 说明 |
|---------|:---:|:---:|------|
| 固定初始配置 | ✅ | ❌ | 如固定背景色、圆角 |
| 随状态变化的属性 | ✅ | ✅ | 如 src、playControl |
| 事件回调 | ✅ | ✅ | 确保回调指向最新 lambda |

**推荐模式**：将属性设置封装为 DSL 组件方法，viewInit 和 viewUpdate 统一调用：

```kotlin
// DSL 侧
class MyComponent : DeclarativeBaseView<MyAttr, MyEvent>() {
    fun configure(param1: String, onEvent: () -> Unit) {
        getViewAttr().run { prop1(param1) }
        getViewEvent().run { myEvent { onEvent() } }
    }
    // ...
}

// Compose 侧
@Composable
fun MyComponent(param1: String, onEvent: () -> Unit, modifier: Modifier = Modifier) {
    MakeKuiklyComposeNode<MyComponent>(
        factory = { MyComponent() },
        modifier = modifier,
        viewInit = { configure(param1, onEvent) },
        viewUpdate = { it.configure(param1, onEvent) },
    )
}
```

---

## 完整 Demo：VideoView 封装与使用

### 封装（VideoView.kt）

```kotlin
import androidx.compose.runtime.Composable
import com.tencent.kuikly.compose.extension.MakeKuiklyComposeNode
import com.tencent.kuikly.compose.ui.Modifier
import com.tencent.kuikly.core.views.VideoPlayControl
import com.tencent.kuikly.core.views.VideoView

@Composable
fun Video(
    src: String,
    playControl: VideoPlayControl,
    modifier: Modifier = Modifier,
) {
    MakeKuiklyComposeNode<VideoView>(
        factory = { VideoView() },
        modifier = modifier,
        viewInit = {
            getViewAttr().run {
                playControl(VideoPlayControl.PLAY)
                src(src)
            }
        },
        viewUpdate = {
            it.getViewAttr().run {
                src(src)
                playControl(playControl)
            }
        }
    )
}
```

### 使用（ComposeVideoDemo.kt）

```kotlin
import androidx.compose.runtime.*
import com.tencent.kuikly.compose.ComposeContainer
import com.tencent.kuikly.compose.foundation.background
import com.tencent.kuikly.compose.foundation.layout.*
import com.tencent.kuikly.compose.material3.Button
import com.tencent.kuikly.compose.material3.Text
import com.tencent.kuikly.compose.setContent
import com.tencent.kuikly.compose.ui.Alignment
import com.tencent.kuikly.compose.ui.Modifier
import com.tencent.kuikly.compose.ui.graphics.Color
import com.tencent.kuikly.compose.ui.unit.dp
import com.tencent.kuikly.core.annotations.Page
import com.tencent.kuikly.core.views.VideoPlayControl

@Page("ComposeVideoDemo")
internal class ComposeVideoDemo : ComposeContainer() {
    override fun willInit() {
        super.willInit()
        setContent { ComposeVideoDemoImpl() }
    }
}

@Composable
fun ComposeVideoDemoImpl() {
    var playControl by remember { mutableStateOf(VideoPlayControl.PLAY) }
    val videoUrl = "http://vjs.zencdn.net/v/oceans.mp4"

    Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {
        // 混用：Kuikly DSL VideoView 作为 Composable
        Video(
            src = videoUrl,
            playControl = playControl,
            modifier = Modifier.align(Alignment.Center).size(400.dp, 300.dp),
        )

        // 纯 Compose 控制栏
        Column(
            modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth()
                .background(Color(0x80000000)).padding(8.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Button(onClick = {
                    playControl = if (playControl != VideoPlayControl.PLAY)
                        VideoPlayControl.PLAY else VideoPlayControl.PAUSE
                }) {
                    Text(
                        text = if (playControl != VideoPlayControl.PLAY) "播放" else "暂停",
                        color = Color.White,
                    )
                }
            }
        }
    }
}
```

---

## 常见错误排查

### 1. 视图不可见

**原因**：factory 使用了 `ComposeView` 子类（扁平化优化导致 frame 丢失）。

**解决**：改用 `DeclarativeBaseView`（原子）或 `ViewContainer`（容器）。

### 2. 属性不更新

**原因**：只在 viewInit 设置属性，viewUpdate 为空。

```kotlin
// ❌ viewUpdate 为空
viewUpdate = { }

// ✅ viewUpdate 同步更新
viewUpdate = { it.getViewAttr().src(src) }
```

### 3. 事件回调不生效

**原因**：事件只在 viewInit 注册，重组后 lambda 引用过期。

**解决**：viewUpdate 中也注册事件。

### 4. 布局尺寸异常

**原因**：未通过 `modifier` 指定尺寸，默认 `KuiklyDefaultMeasurePolicy` 占满父约束。

**解决**：通过 `Modifier.size()` / `Modifier.fillMaxWidth()` 等明确指定尺寸。

### 5. Import 错误

**原因**：非 Runtime 层使用了 `androidx.compose.ui.*` 而非 `com.tencent.kuikly.compose.*`。

**解决**：检查 import，确保 UI / Foundation / Material3 使用 `com.tencent.kuikly.compose.*` 包名。
