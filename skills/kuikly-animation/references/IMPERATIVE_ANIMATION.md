# 命令式动画详细参考

## 核心模式

命令式动画通过 `ViewRef` 获取视图引用，直接调用 `animateToAttr` 执行动画：

```kotlin
// 1. 声明 ViewRef
var viewRef: ViewRef<DivView>? = null

// 2. 绑定引用
View {
    ref { ctx.viewRef = it }
    attr { size(100f, 100f); backgroundColor(Color.RED) }
}

// 3. 执行动画
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    backgroundColor(Color.GREEN)
})
```

## animateToAttr 方法签名

```kotlin
fun animateToAttr(
    animation: Animation,                    // 动画配置
    completion: ((Boolean) -> Unit)? = null,  // 动画结束回调（true=完成, false=取消）
    attrBlock: Attr.() -> Unit               // 动画目标属性
)
```

## 各属性动画示例

### opacity 动画

```kotlin
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    opacity(0f)
})
```

### backgroundColor 动画

```kotlin
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    backgroundColor(Color.RED)
})
```

### transform 位移动画

```kotlin
viewRef?.view?.animateToAttr(Animation.easeIn(0.5f), attrBlock = {
    transform(Translate(0.5f, 0.5f))
})
```

### transform 缩放动画

```kotlin
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    transform(Scale(0.5f, 0.5f))
})
```

### transform 旋转动画

```kotlin
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    transform(Rotate(20f))
})
```

> **注意**：transform 默认以组件中心点为轴心，可通过 `Anchor(x, y)` 自定义

### frame 动画

```kotlin
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    size(100f, 200f)
})
```

## 动画结束回调

命令式动画通过 `completion` 参数直接获取回调，比声明式更简洁：

```kotlin
viewRef?.view?.animateToAttr(
    Animation.easeInOut(0.5f),
    attrBlock = {
        transform(Translate(0f, 0.5f))
    },
    completion = { finished ->
        if (finished) {
            // 动画完成，可启动下一段动画
        } else {
            // 动画被取消
        }
    }
)
```

## 多属性同时动画

将多个属性放在同一个 `attrBlock` 中，共享同一个 Animation：

```kotlin
viewRef?.view?.animateToAttr(Animation.linear(1f), attrBlock = {
    absolutePosition(top = 10f, left = 110f)
    transform(Rotate(90f))
    backgroundColor(Color.BLUE)
})
```

## 命令式 vs 声明式选择建议

| 场景 | 推荐方式 |
|------|---------|
| 简单状态切换（显示/隐藏、颜色变化） | 声明式 |
| 串行动画链 | 命令式（completion 链式调用） |
| 动画中途启动另一个动画 | 两者均可 |
| 需要精确控制动画结束时机 | 命令式 |
| 多个属性不同动画参数 | 声明式（同级作用域）或命令式（多次调用） |
| 复杂交互动画 | 命令式 |
