
# 变换类

## Rotate

```kotlin
import com.tencent.kuikly.core.base.Rotate
```

支持 2D（Z 轴）和 3D（X/Y 轴）旋转，角度范围 [-360, 360]。

```kotlin
// 2D 旋转 45 度
attr { transform(Rotate(angle = 45f)) }

// 3D 旋转
attr { transform(Rotate(angle = 0f, xAngle = 30f, yAngle = 45f)) }
```

**默认值：** `Rotate.DEFAULT` → `Rotate(0f)`

---

## Scale

```kotlin
import com.tencent.kuikly.core.base.Scale
```

X/Y 轴缩放，范围 [0, max]。

```kotlin
attr { transform(Scale(x = 1.5f, y = 1.5f)) }
```

**默认值：** `Scale.DEFAULT` → `Scale(1f, 1f)`

---

## Translate

```kotlin
import com.tencent.kuikly.core.base.Translate
```

基于百分比和 dp 偏移的位移变换。

| 参数 | 说明 |
|------|------|
| `percentageX` | X 轴位移百分比，[-1, 1]，1 = 100%（可超过 1） |
| `percentageY` | Y 轴位移百分比，默认 0 |
| `offsetX` | 在百分比基础上追加的 dp 偏移，默认 0 |
| `offsetY` | 在百分比基础上追加的 dp 偏移，默认 0 |

```kotlin
attr {
    // 向右偏移自身宽度的 50%
    transform(Translate(percentageX = 0.5f))

    // 百分比 + dp 偏移
    transform(Translate(percentageX = 0f, percentageY = 0f, offsetX = 10f, offsetY = 20f))
}
```

**默认值：** `Translate.DEFAULT` → `Translate(0f, 0f)`

---

## Skew

```kotlin
import com.tencent.kuikly.core.base.Skew
```

水平和垂直方向倾斜变换，单位角度，范围 (-90, 90)。正数逆时针，负数顺时针。

> **注意：** 倾斜 90 度时元素将不可见。

```kotlin
attr { transform(Skew(horizontalSkewAngle = 10f, verticalSkewAngle = 0f)) }
```

**默认值：** `Skew.DEFAULT` → `Skew(0f, 0f)`

---

## Anchor

```kotlin
import com.tencent.kuikly.core.base.Anchor
```

变换的锚点，X/Y 范围 [0, 1]。

```kotlin
attr {
    // 以左上角为锚点
    transform(rotate = Rotate(45f), anchor = Anchor(0f, 0f))
}
```

**默认值：** `Anchor.DEFAULT` → `Anchor(0.5f, 0.5f)`（中心点）

---

## 组合 transform

```kotlin
import com.tencent.kuikly.core.base.*

attr {
    transform(
        rotate = Rotate(45f),
        scale = Scale(1.2f, 1.2f),
        translate = Translate(0.5f, 0f),
        anchor = Anchor(0.5f, 0.5f),
        skew = Skew.DEFAULT
    )
}
```
