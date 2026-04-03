
# 布局类

## Percentage

```kotlin
import com.tencent.kuikly.core.base.Percentage
```

百分比单位，用于 `top`/`left`/`right`/`bottom` 百分比定位。

```kotlin
attr {
    top(Percentage(50f))   // 相对父容器高度的 50%
    left(Percentage(10f))  // 相对父容器宽度的 10%
}
```

---

## EdgeInsets

```kotlin
import com.tencent.kuikly.core.base.EdgeInsets
```

表示矩形边缘的内边距/安全区域。

```kotlin
val insets = EdgeInsets(top = 44f, left = 0f, bottom = 34f, right = 0f)

// 访问页面安全区域
val safeArea: EdgeInsets = pagerData.safeAreaInsets
val topInset = safeArea.top
val bottomInset = safeArea.bottom
```

---

## FlexDirection

```kotlin
import com.tencent.kuikly.core.layout.FlexDirection
```

| 枚举值 | 说明 |
|--------|------|
| `FlexDirection.COLUMN` | 垂直排列（默认） |
| `FlexDirection.COLUMN_REVERSE` | 垂直反向排列 |
| `FlexDirection.ROW` | 水平排列 |
| `FlexDirection.ROW_REVERSE` | 水平反向排列 |

---

## FlexJustifyContent

```kotlin
import com.tencent.kuikly.core.layout.FlexJustifyContent
```

| 枚举值 | 说明 |
|--------|------|
| `FlexJustifyContent.FLEX_START` | 起始对齐（默认） |
| `FlexJustifyContent.CENTER` | 居中 |
| `FlexJustifyContent.FLEX_END` | 末尾对齐 |
| `FlexJustifyContent.SPACE_BETWEEN` | 两端对齐 |
| `FlexJustifyContent.SPACE_AROUND` | 均匀分布 |
| `FlexJustifyContent.SPACE_EVENLY` | 等间距分布 |

---

## FlexAlign

```kotlin
import com.tencent.kuikly.core.layout.FlexAlign
```

| 枚举值 | 说明 |
|--------|------|
| `FlexAlign.AUTO` | 自动 |
| `FlexAlign.FLEX_START` | 起始对齐 |
| `FlexAlign.CENTER` | 居中 |
| `FlexAlign.FLEX_END` | 末尾对齐 |
| `FlexAlign.STRETCH` | 拉伸（默认 alignItems） |

---

## FlexPositionType

```kotlin
import com.tencent.kuikly.core.layout.FlexPositionType
```

| 枚举值 | 说明 |
|--------|------|
| `FlexPositionType.RELATIVE` | 相对定位（默认） |
| `FlexPositionType.ABSOLUTE` | 绝对定位 |

---

## FlexWrap

```kotlin
import com.tencent.kuikly.core.layout.FlexWrap
```

| 枚举值 | 说明 |
|--------|------|
| `FlexWrap.NOWRAP` | 不换行（默认） |
| `FlexWrap.WRAP` | 换行 |
