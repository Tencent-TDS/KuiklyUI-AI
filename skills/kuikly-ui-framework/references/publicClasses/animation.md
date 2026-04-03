
# 动画类

## Animation

```kotlin
import com.tencent.kuikly.core.base.Animation
```

动画配置类，通过 `companion object` 工厂方法创建。

**普通动画：**

| 工厂方法 | 说明 |
|----------|------|
| `Animation.linear(durationS, key)` | 线性动画 |
| `Animation.easeIn(durationS, key)` | 渐入 |
| `Animation.easeOut(durationS, key)` | 渐出 |
| `Animation.easeInOut(durationS, key)` | 渐入渐出 |

**弹簧动画：**

| 工厂方法 | 说明 |
|----------|------|
| `Animation.springLinear(durationS, damping, velocity, key)` | 线性弹簧 |
| `Animation.springEaseIn(durationS, damping, velocity, key)` | 渐入弹簧 |
| `Animation.springEaseOut(durationS, damping, velocity, key)` | 渐出弹簧 |
| `Animation.springEaseInOut(durationS, damping, velocity, key)` | 渐入渐出弹簧 |

**键盘动画（iOS）：**

| 工厂方法 | 说明 |
|----------|------|
| `Animation.keyboard(durationS, curve, key)` | iOS 键盘动画曲线 |

**链式配置：**

```kotlin
Animation.easeInOut(0.3f)
    .delay(0.1f)           // 延时 0.1 秒开始
    .repeatForever(true)   // 无限循环
```

**参数说明：**
- `durationS`：动画持续时间，单位秒
- `key`：业务方设置，动画结束回调会回传，用于区分是哪个动画结束（可选，默认空字符串）
- `damping`：弹簧阻尼
- `velocity`：弹簧初始速度

**在 attr 中使用（旧接口）：**

```kotlin
attr {
    animation(Animation.easeInOut(0.3f), value = someReactiveVar)
    opacity(if (show) 1f else 0f)
}
```

**在 attr 中使用（新接口，推荐）：**

```kotlin
attr {
    animate(Animation.easeInOut(0.3f), value = someReactiveVar)
    opacity(if (show) 1f else 0f)
}
```

> **注意：** 新旧动画接口（`animation` 和 `animate`）不能在同一个 attr 中同时使用。
