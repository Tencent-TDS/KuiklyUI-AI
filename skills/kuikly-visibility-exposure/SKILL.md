---
name: kuikly-visibility-exposure
description: Kuikly 曝光与可见性事件开发助手(Kuikly DSL)。指导如何使用 didAppear、didDisappear、willAppear、willDisappear、appearPercentage 五种可见性事件实现组件曝光上报、可见百分比监听、列表项曝光统计等功能。当用户在 Kuikly 中需要实现曝光上报、可见性监听、列表项曝光统计、可见百分比计算等场景时使用。
---

# Kuikly 曝光与可见性事件

## 核心概念

Kuikly 提供了一套完整的**组件可见性事件系统**，用于监听组件在滚动容器或页面中的可见状态变化。四大要素：

1. **可见窗口**：最近的滚动容器（Scroller/List/WaterfallList）、ModalView 或 Pager
2. **可见性状态**：四种状态 + 百分比（WILL_APPEAR → DID_APPEAR → WILL_DISAPPEAR → DID_DISAPPEAR）
3. **触发时机**：滚动偏移变化、子视图布局完成、可见区域 margin 变化、组件被移除
4. **应用场景**：曝光上报、懒加载、播放控制、可见百分比监听

### 可见窗口查找规则

系统从组件的 parent 开始**向上遍历**，找到第一个匹配的祖先作为可见窗口：

```
组件 → parent → ... → ScrollerView（Scroller/List/WaterfallList/PageList）→ 命中
                     → ModalView → 命中
                     → Pager → 命中（兜底）
```

- 对于 **ScrollerView**（Scroller/List/WaterfallList）：可见性基于**列表可见区域**计算，会减去滚动偏移量
- 对于 **ModalView**：可见性基于 Modal 的布局 frame 计算
- 对于 **Pager**：可见性基于页面的布局 frame 计算

> **重要**：可见性是相对于**最近滚动容器的可见区域**，而非屏幕位置。若需屏幕位置可见性，如果嵌套滚动容器场景，可使用外层滚动容器的 scroll 事件回调，结合列表偏移量计算节点真实位置。

### 状态机

```
                    ┌──────────────────────────────────────────────┐
                    │                                              │
                    ▼                                              │
  DID_DISAPPEAR ──→ WILL_APPEAR ──→ DID_APPEAR ──→ WILL_DISAPPEAR ─┘
  (完全不可见)       (部分可见)       (完全可见)       (部分可见)
```

**三种空间关系与状态转换：**

| 空间关系 | 判定条件 | 状态转换 |
|---------|---------|---------|
| **相离**（组件完全在窗口外） | 组件 frame 与窗口无交集 | → WILL_DISAPPEAR → DID_DISAPPEAR |
| **包含**（组件完全在窗口内） | 组件 frame 完全在窗口内 | → WILL_APPEAR → DID_APPEAR |
| **相交**（组件部分在窗口内） | 组件 frame 与窗口部分重叠 | 从 DID_DISAPPEAR → WILL_APPEAR；从 DID_APPEAR → WILL_DISAPPEAR |

**特殊行为：**
- 组件被**移除**（v-if 移除、页面销毁等）时，会自动触发 WILL_DISAPPEAR → DID_DISAPPEAR，并将 percentage 置为 0
- 状态变更是**异步**的（通过 `addNextTickTask` 调度），页面销毁时除外（同步执行）

---

## API 速查

### 可见性事件

| 事件 | 描述 | 回调参数 | import |
|------|------|---------|--------|
| `willAppear { }` | 组件将要可见（部分进入窗口） | 无 | `com.tencent.kuikly.core.base.event.willAppear` |
| `didAppear { }` | 组件完全可见（完全在窗口内） | 无 | `com.tencent.kuikly.core.base.event.didAppear` |
| `willDisappear { }` | 组件将要不可见（部分离开窗口） | 无 | `com.tencent.kuikly.core.base.event.willDisappear` |
| `didDisappear { }` | 组件完全不可见（完全在窗口外） | 无 | `com.tencent.kuikly.core.base.event.didDisappear` |
| `appearPercentage { }` | 组件可见百分比变化 | `percentage01: Float`（[0,1]） | `com.tencent.kuikly.core.base.event.appearPercentage` |

### appearPercentage 百分比计算逻辑

| 空间关系 | percentage 值 |
|---------|--------------|
| **完全不可见**（相离） | 0 |
| **完全可见**（包含） | 1 |
| **部分可见**（相交） | 纵向列表：`可见高度 / 组件高度`；横向列表（FlexDirection.ROW / ROW_REVERSE）：`可见宽度 / 组件宽度` |

> percentage 值始终被 clamp 到 [0, 1] 范围内。只有当 percentage 发生变化时才会触发回调。

### Scroller/List/WaterfallList 辅助属性

| 属性 | 描述 | 参数类型 | 支持的容器 |
|------|------|---------|-----------|
| `visibleAreaIgnoreTopMargin(margin)` | 从可见窗口顶部裁掉指定高度 | Float | Scroller、List、WaterfallList |
| `visibleAreaIgnoreBottomMargin(margin)` | 从可见窗口底部裁掉指定高度 | Float | Scroller、List、WaterfallList |

> **作用原理**：缩小列表的"可见性判定窗口"。设置后，可见窗口高度 = 列表高度 - marginTop - marginBottom，子组件 Y 坐标也会减去 marginTop。例如列表高度 500dp，设置 `visibleAreaIgnoreTopMargin(60f)` 和 `visibleAreaIgnoreBottomMargin(80f)` 后，只有列表中间 360dp 区域内的子组件才会被判定为可见。
>
> **典型场景**：列表顶部/底部有固定遮挡 UI（如悬浮导航栏、半透明蒙层、底部工具栏），被遮挡区域内的子组件虽然在列表坐标系内"可见"，但实际上用户看不到，需要从曝光判定中排除。


---

## 快速入门

### didAppear 曝光上报

```kotlin
import com.tencent.kuikly.core.base.event.didAppear

View {
    attr {
        size(100f, 100f)
        backgroundColor(Color.GREEN)
    }
    event {
        didAppear {
            // 组件完全可见，执行曝光上报
        }
    }
}
```

### appearPercentage 可见百分比监听

```kotlin
import com.tencent.kuikly.core.base.event.appearPercentage

View {
    attr {
        size(100f, 100f)
        backgroundColor(Color.GREEN)
    }
    event {
        appearPercentage { percentage01 ->
            // percentage01 为 [0,1] 的露出百分比
            // 1 表示 100% 可见，0 表示 0% 可见
            if (percentage01 >= 0.5f) {
                // 超过 50% 可见时执行逻辑
            }
        }
    }
}
```

### 完整生命周期监听

```kotlin
import com.tencent.kuikly.core.base.event.willAppear
import com.tencent.kuikly.core.base.event.didAppear
import com.tencent.kuikly.core.base.event.willDisappear
import com.tencent.kuikly.core.base.event.didDisappear
import com.tencent.kuikly.core.base.event.appearPercentage

View {
    event {
        willAppear {
            // 组件将要可见（部分进入窗口）
        }
        didAppear {
            // 组件完全可见 → 曝光上报
        }
        willDisappear {
            // 组件将要不可见（部分离开窗口）
        }
        didDisappear {
            // 组件完全不可见
        }
        appearPercentage { percentage ->
            // 可见百分比变化
        }
    }
}
```

### visibleAreaIgnoreMargin 排除遮挡区域

```kotlin
import com.tencent.kuikly.core.base.event.didAppear

Scroller {
    attr {
        flex(1f)
        // 顶部 60dp 区域内的子组件不参与曝光判定
        visibleAreaIgnoreTopMargin(60f)
        // 底部 80dp 区域内的子组件不参与曝光判定
        visibleAreaIgnoreBottomMargin(80f)
    }

    View {
        attr {
            height(120f)
            backgroundColor(Color(0xFFE3F2FD))
        }
        event {
            didAppear {
                // 只有完全进入中间有效区域（500 - 60 - 80 = 360dp）时才触发
            }
        }
    }
}
```

---

## 常见错误与陷阱

| 错误做法 | 正确做法 | 原因 |
|---------|---------|------|
| ❌ 根节点使用 `didAppear` 监听页面曝光 | ✅ 使用页面生命周期 `pageDidAppear()` | 根节点没有滚动容器作为可见窗口，行为不可预期 |
| ❌ 认为可见性是相对于屏幕位置 | ✅ 可见性是相对于**最近滚动容器的可见区域** | 需要屏幕位置请结合 scroll 事件偏移量计算 |
| ❌ 在 `appearPercentage` 中直接执行曝光上报 | ✅ 曝光上报用 `didAppear`，或加阈值 + 去重标记 | `appearPercentage` 每次滚动都触发，频率极高 |
| ❌ 忘记 import 可见性事件扩展函数 | ✅ 添加对应的 import 语句 | 这些是 `Event` 的扩展函数，需要显式 import |

---

## 完整使用案例

见 [EXAMPLES.md](references/EXAMPLES.md)
