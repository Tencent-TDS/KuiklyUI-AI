# 可见性事件详细 API

## 事件注册方式

所有可见性事件都是 `Event` 类的扩展函数，在 `event { }` 闭包中使用：

```kotlin
event {
    willAppear { /* ... */ }
    didAppear { /* ... */ }
    willDisappear { /* ... */ }
    didDisappear { /* ... */ }
    appearPercentage { percentage01 -> /* ... */ }
}
```

## didAppear 事件

**功能**：组件完全可见时触发，常用于曝光上报。

**签名**：
```kotlin
fun Event.didAppear(handler: EventHandlerFn)
```

**import**：
```kotlin
import com.tencent.kuikly.core.base.event.didAppear
```

**触发条件**：组件的整个区域都在滚动容器（或 Pager）的可见窗口内。

**注意**：
- 根节点请使用页面事件 `pageDidAppear`
- Scroller/List 中是相对于**列表位置**可见，非屏幕位置

---

## appearPercentage 事件

**功能**：组件可见百分比变化时持续触发，适用于精细化曝光控制。

**签名**：
```kotlin
fun Event.appearPercentage(handler: (percentage01: Float) -> Unit)
```

**import**：
```kotlin
import com.tencent.kuikly.core.base.event.appearPercentage
```

**回调参数**：
| 参数 | 类型 | 说明 |
|------|------|------|
| percentage01 | Float | 可见百分比，范围 [0, 1]。1 = 100% 可见，0 = 完全不可见 |

**百分比计算逻辑**（源自 `VisibilityEvent.handleAppearPercentage`）：
- **完全不可见**（相离）：percentage = 0
- **完全可见**（包含）：percentage = 1
- **部分可见**（相交）：
  - 纵向列表：`可见高度 / 组件高度`
  - 横向列表（FlexDirection.ROW/ROW_REVERSE）：`可见宽度 / 组件宽度`

---

## willAppear / willDisappear / didDisappear 事件

| 事件 | 签名 | 触发条件 |
|------|------|---------|
| `willAppear` | `fun Event.willAppear(handler: EventHandlerFn)` | 组件从完全不可见变为部分可见 |
| `willDisappear` | `fun Event.willDisappear(handler: EventHandlerFn)` | 组件从完全可见变为部分可见 |
| `didDisappear` | `fun Event.didDisappear(handler: EventHandlerFn)` | 组件完全不可见 |

**import**：
```kotlin
import com.tencent.kuikly.core.base.event.willAppear
import com.tencent.kuikly.core.base.event.willDisappear
import com.tencent.kuikly.core.base.event.didDisappear
```

---

## 状态机转换

`VisibilityEvent` 内部维护一个 `VisibilityState` 状态机：

```
enum class VisibilityState(val value: String) {
    WILL_APPEAR("willAppear"),       // 将要可见
    DID_APPEAR("didAppear"),         // 完全可见
    WILL_DISAPPEAR("willDisappear"), // 将要不可见
    DID_DISAPPEAR("didDisappear"),   // 完全不可见（初始状态）
}
```

**状态转换规则**：

```
                    ┌──────────────────────────────────────┐
                    │                                      │
                    ▼                                      │
  DID_DISAPPEAR ──→ WILL_APPEAR ──→ DID_APPEAR ──→ WILL_DISAPPEAR
       ▲                                                   │
       │                                                   │
       └───────────────────────────────────────────────────┘
```

- **相离**（组件完全在窗口外）→ 触发 `WILL_DISAPPEAR` + `DID_DISAPPEAR`
- **包含**（组件完全在窗口内）→ 触发 `WILL_APPEAR`（如果之前不可见）+ `DID_APPEAR`
- **相交**（组件部分在窗口内）→ 根据之前状态触发 `WILL_APPEAR` 或 `WILL_DISAPPEAR`

---

## Scroller/List 可见区域配置

当滚动容器顶部/底部有固定遮挡区域时，使用以下属性调整可见性计算的有效区域：

```kotlin
Scroller {
    attr {
        // 忽略顶部 60dp 区域（如悬浮导航栏遮挡）
        visibleAreaIgnoreTopMargin(60f)
        // 忽略底部 80dp 区域（如底部工具栏遮挡）
        visibleAreaIgnoreBottomMargin(80f)
    }

    // 子组件的可见性事件将基于调整后的有效区域计算
    View {
        event {
            didAppear { /* 基于有效区域判定 */ }
        }
    }
}
```

**原理**：设置后，可见窗口的高度会减去 `marginTop + marginBottom`，子组件的 Y 坐标也会减去 `marginTop`，从而使可见性判定排除被遮挡的区域。
