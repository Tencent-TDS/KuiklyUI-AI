# 高级动画模式

## 串行动画

### 方案一：通过 delay 模拟串行

给不同属性的动画设置递增的 delay 时间：

**声明式写法：**
```kotlin
attr {
    // 第1段：右移（立即开始，持续1秒）
    absolutePosition(top = 10f, left = if (ctx.isAnimation) 110f else 10f)
    animate(Animation.linear(1f), ctx.isAnimation)

    // 第2段：旋转（延迟1秒，持续1秒）
    transform(Rotate(if (ctx.isAnimation) 90f else 0f))
    animate(Animation.linear(1f).delay(1f), ctx.isAnimation)

    // 第3段：变色（延迟2秒，持续1秒）
    backgroundColor(if (ctx.isAnimation) Color.BLUE else Color.YELLOW)
    animate(Animation.linear(1f).delay(2f), ctx.isAnimation)
}
```

**命令式写法：**
```kotlin
viewRef?.view?.animateToAttr(Animation.linear(1f), attrBlock = {
    absolutePosition(top = 10f, left = 110f)
})
viewRef?.view?.animateToAttr(Animation.linear(1f).delay(1f), attrBlock = {
    transform(Rotate(90f))
})
viewRef?.view?.animateToAttr(Animation.linear(1f).delay(2f), attrBlock = {
    backgroundColor(Color.BLUE)
})
```

> ⚠️ **限制**：同一属性不能用 delay 方案做串行，因为同一属性一次只能绑定一个 Animation。需要使用方案二。

### 方案二：通过结束回调链式串行

**声明式写法：**
```kotlin
var transformFlag by observable(false)
var bgColorFlag by observable(false)

View {
    attr {
        size(100f, 100f)
        backgroundColor(if (ctx.bgColorFlag) Color.GREEN else Color.RED)
        animate(Animation.easeIn(0.5f), ctx.bgColorFlag)

        transform(if (ctx.transformFlag) Translate(0f, 0.5f) else Translate(0f, 0f))
        animate(Animation.easeInOut(0.5f), ctx.transformFlag)
    }
    event {
        animationCompletion {
            if (it.attr == Attr.StyleConst.TRANSFORM) {
                ctx.bgColorFlag = true  // transform 结束后启动背景色动画
            }
        }
    }
}

// 启动第一段
transformFlag = true
```

**命令式写法（更简洁）：**
```kotlin
viewRef?.view?.animateToAttr(Animation.easeInOut(0.5f), attrBlock = {
    transform(Translate(0f, 0.5f))
}, completion = {
    viewRef?.view?.animateToAttr(Animation.easeIn(0.5f), attrBlock = {
        backgroundColor(Color.GREEN)
    })
})
```

---

## 并行动画

### 场景1：相同动画参数

所有属性共享同一个 Animation：

**声明式：**
```kotlin
attr {
    absolutePosition(top = 10f, left = if (ctx.isAnimation) 110f else 10f)
    transform(Rotate(if (ctx.isAnimation) 90f else 0f))
    backgroundColor(if (ctx.isAnimation) Color.BLUE else Color.YELLOW)
    animate(Animation.linear(2f), ctx.isAnimation)  // 一个 animate 控制上方所有属性
}
```

**命令式：**
```kotlin
viewRef?.view?.animateToAttr(Animation.linear(2f), attrBlock = {
    absolutePosition(top = 10f, left = 110f)
    transform(Rotate(90f))
    backgroundColor(Color.BLUE)
})
```

### 场景2：不同动画参数

每个属性绑定不同的 Animation：

**声明式（同级作用域）：**
```kotlin
attr {
    absolutePosition(top = 10f, left = if (ctx.isAnimation) 110f else 10f)
    animate(Animation.linear(1f), ctx.isAnimation)

    transform(Rotate(if (ctx.isAnimation) 90f else 0f))
    animate(Animation.linear(2f), ctx.isAnimation)

    backgroundColor(if (ctx.isAnimation) Color.BLUE else Color.YELLOW)
    animate(Animation.linear(3f), ctx.isAnimation)
}
```

**命令式（多次调用 animateToAttr，不设 delay）：**
```kotlin
viewRef?.view?.animateToAttr(Animation.linear(1f), attrBlock = {
    absolutePosition(top = 10f, left = 110f)
})
viewRef?.view?.animateToAttr(Animation.linear(2f), attrBlock = {
    transform(Rotate(90f))
})
viewRef?.view?.animateToAttr(Animation.linear(3f), attrBlock = {
    backgroundColor(Color.BLUE)
})
```

---

## 动画执行过程中启动另一个动画

使用 `setTimeout` 在动画执行中途启动新动画：

**声明式：**
```kotlin
var transformFlag by observable(false)
var bgColorFlag by observable(false)

override fun viewDidLayout() {
    super.viewDidLayout()
    transformFlag = true
    setTimeout(300) {
        bgColorFlag = true  // transform 动画执行到 300ms 时启动背景色动画
    }
}
```

**命令式：**
```kotlin
override fun viewDidLayout() {
    super.viewDidLayout()
    viewRef?.view?.animateToAttr(Animation.easeInOut(0.5f), attrBlock = {
        transform(Translate(0f, 0.5f))
    })
    setTimeout(300) {
        viewRef?.view?.animateToAttr(Animation.easeIn(0.5f), attrBlock = {
            backgroundColor(Color.GREEN)
        })
    }
}
```

---

## 动画取消

在动画执行过程中，通过重置一个新动画 reset 到初始状态来取消动画。

**命令式取消示例：**
```kotlin
// 启动动画
viewRef?.view?.animateToAttr(Animation.linear(2f), attrBlock = {
    transform(Translate(0.5f, 0.5f))
}, completion = { finished ->
    if (!finished) {
        // 动画被取消
    }
})

// 取消：用一个极短的动画重置到初始状态
viewRef?.view?.animateToAttr(Animation.linear(0.01f), attrBlock = {
    transform(Translate(0f, 0f))
})
```

> 具体实现可参考 [AnimationCancelDemo](https://github.com/Tencent-TDS/KuiklyUI/blob/main/demo/src/commonMain/kotlin/com/tencent/kuikly/demo/pages/demo/AnimationCancelDemo.kt)

---

## 循环动画

使用 `repeatForever(true)` 实现无限循环：

```kotlin
// 声明式
attr {
    transform(Rotate(if (ctx.rotateFlag) 360f else 0f))
    animate(Animation.linear(2f).repeatForever(true), ctx.rotateFlag)
}

// 命令式
viewRef?.view?.animateToAttr(Animation.linear(2f).repeatForever(true), attrBlock = {
    transform(Rotate(360f))
})
```
