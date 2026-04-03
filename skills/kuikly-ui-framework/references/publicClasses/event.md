
# 事件系统

## Event 事件中心

```kotlin
import com.tencent.kuikly.core.base.event.Event
```

所有 View 的事件入口，提供便捷的事件监听方法。

**内置事件：**

```kotlin
event {
    // 单击
    click { params: ClickParams ->
        val x = params.x       // 触摸点在自身 View 坐标系下 X
        val y = params.y       // 触摸点在自身 View 坐标系下 Y
        val pageX = params.pageX // 触摸点在根视图 Page 下的 X
        val pageY = params.pageY // 触摸点在根视图 Page 下的 Y
    }

    // 双击
    doubleClick { params: ClickParams -> }

    // 长按
    longPress { params: LongPressParams ->
        val state = params.state   // "start" | "move" | "end"
        val isCancel = params.isCancel
    }

    // 滑动手势
    pan { params: PanGestureParams ->
        val state = params.state   // "start" | "move" | "end"
    }

    // 捏合手势
    pinch { params: PinchGestureParams ->
        val scale = params.scale
        val state = params.state
    }

    // 动画结束
    animationCompletion { params: AnimationCompletionParams ->
        val finish = params.finish
        val attr = params.attr
        val key = params.animationKey
    }
}
```

---

## 事件参数类

```kotlin
import com.tencent.kuikly.core.base.event.ClickParams
import com.tencent.kuikly.core.base.event.LongPressParams
import com.tencent.kuikly.core.base.event.PanGestureParams
import com.tencent.kuikly.core.base.event.PinchGestureParams
import com.tencent.kuikly.core.base.event.AnimationCompletionParams
import com.tencent.kuikly.core.base.event.TouchParams
import com.tencent.kuikly.core.base.event.Touch
```

| 类名 | 说明 | 核心属性 |
|------|------|----------|
| `ClickParams` | 单击/双击参数 | `x`, `y`, `pageX`, `pageY` |
| `LongPressParams` | 长按参数 | `x`, `y`, `pageX`, `pageY`, `state`, `isCancel` |
| `PanGestureParams` | 滑动参数 | `x`, `y`, `state`, `pageX`, `pageY` |
| `PinchGestureParams` | 捏合参数 | `x`, `y`, `pageX`, `pageY`, `scale`, `state` |
| `AnimationCompletionParams` | 动画结束参数 | `finish`, `attr`, `animationKey` |
| `TouchParams` | 触摸参数 | `x`, `y`, `pageX`, `pageY`, `timestamp`, `pointerId`, `action`, `touches`, `consumed` |
| `Touch` | 多指触摸信息 | `x`, `y`, `pageX`, `pageY`, `hash`, `pointerId` |

> `state` 值：`"start"` / `"move"` / `"end"`

---

## 可见性事件

```kotlin
import com.tencent.kuikly.core.base.event.willAppear
import com.tencent.kuikly.core.base.event.didAppear
import com.tencent.kuikly.core.base.event.willDisappear
import com.tencent.kuikly.core.base.event.didDisappear
import com.tencent.kuikly.core.base.event.appearPercentage
```

在最近的 ListView/ScrollerView 中监听 View 的可见性状态变化，若找不到最近的 ScrollerView，则以 Pager 作为可见窗口。

```kotlin
event {
    // 将要可见
    willAppear { }

    // 完全可见
    didAppear { }

    // 将要不可见
    willDisappear { }

    // 完全不可见
    didDisappear { }

    // 可见百分比变化（0.0 ~ 1.0）
    appearPercentage { percentage01 ->
        // percentage01 = 1.0 表示 100% 可见
    }
}
```

**VisibilityState 枚举：**

| 枚举值 | 说明 |
|--------|------|
| `VisibilityState.WILL_APPEAR` | 将要可见 |
| `VisibilityState.DID_APPEAR` | 完全可见 |
| `VisibilityState.WILL_DISAPPEAR` | 将要不可见 |
| `VisibilityState.DID_DISAPPEAR` | 完全不可见 |
