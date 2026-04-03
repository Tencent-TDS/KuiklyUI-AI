# 曝光事件使用案例

## 案例 1：列表项曝光上报与生命周期监听

在 Scroller 中监听列表项的完整可见性生命周期，结合 `appearPercentage` 实时展示可见百分比：

```kotlin
import com.tencent.kuikly.core.base.Color
import com.tencent.kuikly.core.base.ViewBuilder
import com.tencent.kuikly.core.base.event.willAppear
import com.tencent.kuikly.core.base.event.didAppear
import com.tencent.kuikly.core.base.event.willDisappear
import com.tencent.kuikly.core.base.event.didDisappear
import com.tencent.kuikly.core.base.event.appearPercentage
import com.tencent.kuikly.core.reactive.handler.observable

@Page("exposure_demo")
internal class ExposureDemoPage : BasePager() {

    private var itemState by observable("未触发")
    private var itemPercent by observable(0f)

    override fun body(): ViewBuilder {
        val ctx = this
        return {
            attr {
                backgroundColor(Color.WHITE)
            }

            Scroller {
                attr {
                    flex(1f)
                }

                View {
                    attr {
                        height(120f)
                        backgroundColor(Color(0xFFE3F2FD))
                        justifyContentCenter()
                    }
                    Text {
                        attr {
                            fontSize(16f)
                            text("状态: ${ctx.itemState}")
                        }
                    }
                    Text {
                        attr {
                            fontSize(14f)
                            marginTop(8f)
                            text("可见百分比: ${(ctx.itemPercent * 100).toInt()}%")
                        }
                    }
                    event {
                        willAppear {
                            ctx.itemState = "willAppear"
                        }
                        didAppear {
                            ctx.itemState = "didAppear"
                            // 在此执行曝光上报逻辑
                        }
                        willDisappear {
                            ctx.itemState = "willDisappear"
                        }
                        didDisappear {
                            ctx.itemState = "didDisappear"
                        }
                        appearPercentage { percentage ->
                            ctx.itemPercent = percentage
                        }
                    }
                }
            }
        }
    }
}
```

---

## 案例 2：配合 visibleAreaIgnoreMargin 排除遮挡区域

当列表顶部/底部有固定遮挡 UI（如悬浮导航栏、底部工具栏）时，使用 `visibleAreaIgnoreTopMargin` / `visibleAreaIgnoreBottomMargin` 从列表可见窗口中裁掉被遮挡的区域，使该区域内的子组件不参与曝光判定：

```kotlin
import com.tencent.kuikly.core.base.Color
import com.tencent.kuikly.core.base.ViewBuilder
import com.tencent.kuikly.core.base.event.didAppear
import com.tencent.kuikly.core.base.event.appearPercentage

@Page("visible_area_demo")
internal class VisibleAreaDemoPage : BasePager() {

    override fun body(): ViewBuilder {
        val ctx = this
        return {
            attr {
                backgroundColor(Color.WHITE)
            }

            View {
                attr {
                    height(400f)
                }

                Scroller {
                    attr {
                        flex(1f)
                        // 列表顶部 60dp 区域内的子组件不参与曝光判定（如被悬浮导航栏遮挡）
                        visibleAreaIgnoreTopMargin(60f)
                        // 列表底部 80dp 区域内的子组件不参与曝光判定（如被底部工具栏遮挡）
                        visibleAreaIgnoreBottomMargin(80f)
                    }

                    // 只有处于列表中间有效区域（总高度 - 60 - 80）内的子组件才会触发曝光
                    View {
                        attr {
                            height(120f)
                            backgroundColor(Color(0xFFE3F2FD))
                        }
                        event {
                            didAppear {
                                // 子组件完全进入有效区域时触发（排除顶部 60dp 和底部 80dp）
                            }
                            appearPercentage { percentage ->
                                // 百分比基于裁剪后的有效区域计算
                            }
                        }
                    }
                }
            }
        }
    }
}
```

---

## 案例 3：带去重的曝光上报（appearPercentage 阈值方案）

当需要基于可见百分比阈值（如 50%）进行曝光上报时，需要加去重标记避免重复上报：

```kotlin
import com.tencent.kuikly.core.base.Color
import com.tencent.kuikly.core.base.ViewBuilder
import com.tencent.kuikly.core.base.ViewContainer
import com.tencent.kuikly.core.base.event.appearPercentage
import com.tencent.kuikly.core.reactive.handler.observable

@Page("threshold_exposure")
internal class ThresholdExposurePage : BasePager() {

    override fun body(): ViewBuilder {
        val ctx = this
        return {
            attr {
                backgroundColor(Color.WHITE)
            }

            Scroller {
                attr {
                    flex(1f)
                }

                // 多个列表项，每个都有独立的曝光去重标记
                for (i in 0 until 20) {
                    ExposureItem(itemId = "item_$i", title = "列表项 $i")
                }
            }
        }
    }
}

/**
 * 带去重曝光上报的列表项组件
 */
private fun ViewContainer<*, *>.ExposureItem(itemId: String, title: String) {
    // 使用闭包变量作为去重标记
    var hasReported = false

    View {
        attr {
            height(100f)
            backgroundColor(Color(0xFFE3F2FD))
            marginBottom(10f)
            justifyContentCenter()
        }
        Text {
            attr {
                fontSize(16f)
                text(title)
            }
        }
        event {
            appearPercentage { percentage ->
                // 超过 50% 可见且未上报过时执行曝光
                if (percentage >= 0.5f && !hasReported) {
                    hasReported = true
                    // 执行曝光上报逻辑
                    // reportExposure(itemId)
                }
            }
        }
    }
}
```

---

## 案例 4：List 组件中的曝光统计

在 List（vfor 循环渲染）中为每个列表项添加曝光监听：

```kotlin
import com.tencent.kuikly.core.base.Color
import com.tencent.kuikly.core.base.ViewBuilder
import com.tencent.kuikly.core.base.event.didAppear
import com.tencent.kuikly.core.base.event.didDisappear
import com.tencent.kuikly.core.reactive.handler.observable
import com.tencent.kuikly.core.reactive.handler.observableList

@Page("list_exposure")
internal class ListExposurePage : BasePager() {

    private val dataList = observableList(
        (0 until 50).map { "Item $it" }.toMutableList()
    )

    override fun body(): ViewBuilder {
        val ctx = this
        return {
            attr {
                backgroundColor(Color.WHITE)
            }

            List {
                attr {
                    flex(1f)
                }

                vfor({ ctx.dataList }) { item ->
                    View {
                        attr {
                            height(80f)
                            backgroundColor(Color(0xFFF5F5F5))
                            marginBottom(1f)
                            justifyContentCenter()
                            paddingLeft(16f)
                        }
                        Text {
                            attr {
                                fontSize(16f)
                                text(item)
                            }
                        }
                        event {
                            didAppear {
                                // 列表项完全可见，上报曝光
                            }
                            didDisappear {
                                // 列表项完全不可见
                            }
                        }
                    }
                }
            }
        }
    }
}
```

---

## 案例 5：动态调整 visibleAreaIgnoreMargin

使用响应式变量动态调整可见区域忽略的 margin，值变化时会自动重新计算所有子组件的可见性：

```kotlin
import com.tencent.kuikly.core.base.Color
import com.tencent.kuikly.core.base.ViewBuilder
import com.tencent.kuikly.core.base.event.didAppear
import com.tencent.kuikly.core.base.event.appearPercentage
import com.tencent.kuikly.core.reactive.handler.observable

@Page("dynamic_margin")
internal class DynamicMarginPage : BasePager() {

    private var ignoreTopMargin: Float by observable(60f)
    private var ignoreBottomMargin: Float by observable(80f)

    override fun body(): ViewBuilder {
        val ctx = this
        return {
            attr {
                backgroundColor(Color.WHITE)
            }

            // 控制按钮区域
            View {
                attr {
                    flexDirectionRow()
                    padding(10f)
                    justifyContentSpaceBetween()
                }
                View {
                    attr {
                        size(80f, 40f)
                        backgroundColor(Color(0xFFE0E0E0))
                        borderRadius(5f)
                        allCenter()
                    }
                    Text {
                        attr {
                            text("Top +10")
                            fontSize(12f)
                        }
                    }
                    event {
                        click {
                            ctx.ignoreTopMargin = minOf(150f, ctx.ignoreTopMargin + 10f)
                        }
                    }
                }
                View {
                    attr {
                        size(80f, 40f)
                        backgroundColor(Color(0xFFE0E0E0))
                        borderRadius(5f)
                        allCenter()
                    }
                    Text {
                        attr {
                            text("Bottom +10")
                            fontSize(12f)
                        }
                    }
                    event {
                        click {
                            ctx.ignoreBottomMargin = minOf(150f, ctx.ignoreBottomMargin + 10f)
                        }
                    }
                }
            }

            // 列表区域
            Scroller {
                attr {
                    flex(1f)
                    // 响应式变量驱动，值变化时自动重新计算可见性
                    visibleAreaIgnoreTopMargin(ctx.ignoreTopMargin)
                    visibleAreaIgnoreBottomMargin(ctx.ignoreBottomMargin)
                }

                // 列表项...
            }
        }
    }
}
```

---

## 案例 6：Compose DSL 中使用 appearPercentage

在 Compose DSL 页面中，通过自定义 `Modifier.appearPercentage` 扩展实现可见百分比监听：

```kotlin
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.tencent.kuikly.compose.foundation.background
import com.tencent.kuikly.compose.foundation.layout.Box
import com.tencent.kuikly.compose.foundation.layout.fillMaxWidth
import com.tencent.kuikly.compose.foundation.layout.height
import com.tencent.kuikly.compose.foundation.lazy.LazyColumn
import com.tencent.kuikly.compose.foundation.lazy.items
import com.tencent.kuikly.compose.material3.Text
import com.tencent.kuikly.compose.ui.Alignment
import com.tencent.kuikly.compose.ui.Modifier
import com.tencent.kuikly.compose.ui.graphics.Color
import com.tencent.kuikly.compose.ui.layout.boundsInRoot
import com.tencent.kuikly.compose.ui.layout.onGloballyPositioned
import com.tencent.kuikly.compose.ui.unit.IntSize
import com.tencent.kuikly.compose.ui.unit.dp
import com.tencent.kuikly.compose.ui.unit.sp

// 自定义 Modifier 扩展
fun Modifier.appearPercentage(
    onPercentageChanged: (Float) -> Unit
): Modifier = this.then(
    Modifier.onGloballyPositioned { layoutCoordinates ->
        val windowBounds = layoutCoordinates.parentLayoutCoordinates
            ?.size?.let { IntSize(it.width, it.height) }
        val layoutBounds = layoutCoordinates.boundsInRoot()
        windowBounds?.let { bounds ->
            val visibleHeight = layoutBounds.height
                .coerceAtMost(bounds.height.toFloat())
            val visibleWidth = layoutBounds.width
                .coerceAtMost(bounds.width.toFloat())
            val percentageHeight = visibleHeight / bounds.height.toFloat()
            val percentageWidth = visibleWidth / bounds.width.toFloat()
            onPercentageChanged(
                kotlin.math.min(percentageWidth, percentageHeight)
            )
        }
    }
)

// 使用示例
@Page("AppearDemo")
class AppearDemo : ComposeContainer() {
    override fun willInit() {
        super.willInit()
        setContent {
            LazyColumn(modifier = Modifier.fillMaxSize()) {
                items((1..20).toList()) { index ->
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(150.dp)
                    ) {
                        var appearPercent by remember { mutableStateOf(0f) }
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(100.dp)
                                .background(Color(0xFF6200EE))
                                .appearPercentage { percent ->
                                    appearPercent = percent
                                }
                        )
                        Text(
                            text = "Item $index: ${(appearPercent * 100).toInt()}%",
                            modifier = Modifier.align(Alignment.Center),
                            color = Color.White,
                            fontSize = 16.sp
                        )
                    }
                }
            }
        }
    }
}
```
