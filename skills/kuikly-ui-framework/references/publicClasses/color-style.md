
# 颜色与样式类

## Color

```kotlin
import com.tencent.kuikly.core.base.Color
```

颜色类，支持多种构造方式。

**预置颜色常量：**

| 常量 | 值 |
|------|------|
| `Color.BLACK` | `0xff000000` |
| `Color.WHITE` | `0xffFFFFFF` |
| `Color.RED` | `0xffFF0000` |
| `Color.GREEN` | `0xff00FF00` |
| `Color.BLUE` | `0xff0000FF` |
| `Color.YELLOW` | `0xffFFFF00` |
| `Color.GRAY` | `0xff999999` |
| `Color.TRANSPARENT` | `0x00000000` |
| `Color.TRANSPARENT_WHITE` | 白色透明 |

**构造方法：**

```kotlin
// 1. 十六进制 ARGB（最高 2 位为 alpha）
Color(0xffFF5500L)

// 2. 十六进制 + 透明度（0.0 ~ 1.0）
Color(0xFFFFFF, 0.5f)

// 3. RGBA 方式（各通道 0~255，alpha 0.0~1.0）
Color(red255 = 255, green255 = 128, blue255 = 0, alpha01 = 1.0f)

// 4. 宿主扩展字符串（如颜色 token）
Color("colorTokenName")

// 5. 从 16 进制字符串解析
val colorLong = Color.parseString16ToLong("0xffFF5500")
Color(colorLong)
```

**方法：**

```kotlin
// 生成指定透明度的新颜色
val semiTransparent = Color.RED.opacity(0.5f)
```

---

## Border

```kotlin
import com.tencent.kuikly.core.base.Border
import com.tencent.kuikly.core.base.BorderStyle
import com.tencent.kuikly.core.base.Color
```

设置视图边框线样式。

```kotlin
Border(
    lineWidth = 1f,                // 边框宽度
    lineStyle = BorderStyle.SOLID, // 边框样式
    color = Color.RED              // 边框颜色
)

// 在 attr 中使用
attr {
    border(Border(1f, BorderStyle.SOLID, Color(0xff333333L)))
}
```

---

## BorderStyle

```kotlin
import com.tencent.kuikly.core.base.BorderStyle
```

| 枚举值 | 说明 |
|--------|------|
| `BorderStyle.SOLID` | 实线 |
| `BorderStyle.DOTTED` | 点线 |
| `BorderStyle.DASHED` | 虚线 |

---

## BorderRectRadius

```kotlin
import com.tencent.kuikly.core.base.BorderRectRadius
```

四个角独立设置圆角半径。

```kotlin
// 四角独立
attr {
    borderRadius(BorderRectRadius(
        topLeftCornerRadius = 10f,
        topRightCornerRadius = 10f,
        bottomLeftCornerRadius = 0f,
        bottomRightCornerRadius = 0f
    ))
}

// 便捷方法：统一圆角
attr { borderRadius(10f) }

// 便捷方法：四角独立
attr { borderRadius(10f, 10f, 0f, 0f) }
```

> **注意：** 设置圆角后子视图无法超出自身区域显示（overflow 失效），需通过 wrapper 一个 View 来变向实现。

---

## BoxShadow

```kotlin
import com.tencent.kuikly.core.base.BoxShadow
import com.tencent.kuikly.core.base.Color
```

设置视图的盒子阴影。

```kotlin
attr {
    boxShadow(BoxShadow(
        offsetX = 0f,                       // X 轴偏移
        offsetY = 2f,                       // Y 轴偏移
        shadowRadius = 8f,                  // 模糊半径
        shadowColor = Color(0x33000000L),   // 阴影颜色
        fill = true                         // 是否填充（默认 true）
    ))

    // iOS 性能优化：使用 shadowPath（推荐设置为 true）
    boxShadow(
        BoxShadow(0f, 2f, 8f, Color(0x33000000L)),
        useShadowPath = true
    )
}
```

---

## Direction

```kotlin
import com.tencent.kuikly.core.base.Direction
```

渐变方向枚举，用于 `backgroundLinearGradient`。

| 枚举值 | 说明 |
|--------|------|
| `Direction.TO_TOP` | 向上 |
| `Direction.TO_BOTTOM` | 向下 |
| `Direction.TO_LEFT` | 向左 |
| `Direction.TO_RIGHT` | 向右 |
| `Direction.TO_TOP_LEFT` | 向左上 |
| `Direction.TO_TOP_RIGHT` | 向右上 |
| `Direction.TO_BOTTOM_LEFT` | 向左下 |
| `Direction.TO_BOTTOM_RIGHT` | 向右下 |

---

## ColorStop

```kotlin
import com.tencent.kuikly.core.base.ColorStop
import com.tencent.kuikly.core.base.Color
```

渐变色值停靠点，用于 `backgroundLinearGradient`。

```kotlin
attr {
    backgroundLinearGradient(
        Direction.TO_BOTTOM,
        ColorStop(Color.RED, 0f),     // 起始位置 0%
        ColorStop(Color.BLUE, 1f)     // 终止位置 100%
    )
}
```

---

## InterfaceStyle

```kotlin
import com.tencent.kuikly.core.base.InterfaceStyle
```

暗黑模式枚举（仅 iOS 生效）。

| 枚举值 | 说明 |
|--------|------|
| `InterfaceStyle.AUTO` | 跟随系统主题 |
| `InterfaceStyle.LIGHT` | 强制亮色模式 |
| `InterfaceStyle.DARK` | 强制暗色模式 |

```kotlin
attr {
    interfaceStyle(InterfaceStyle.LIGHT)
}
```
