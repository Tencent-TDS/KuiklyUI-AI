# 声明式动画详细参考

## 核心模式

声明式动画通过**响应式变量**控制属性状态，`animate` 绑定动画过程：

```kotlin
attr {
    // 1. 根据响应式变量设置不同状态的属性值
    if (ctx.flag) { opacity(0f) } else { opacity(1f) }
    // 2. 绑定动画：当 flag 变化时，上方属性以动画过渡
    animate(Animation.linear(0.5f), ctx.flag)
}
```

## animate 作用域规则

### 父子作用域

`animate` 绑定的动画**影响当前节点及其所有子节点**。子节点如有自己的 `animate`，则优先使用子节点的。

```kotlin
View {
    attr {
        // 绑定到父节点 → 影响 ViewA 和 ViewB
        animate(Animation.linear(2f), ctx.isAnimation)
    }
    ViewA {
        attr {
            height(if (ctx.isAnimation) 300f else 100f) // 受父节点动画影响
        }
    }
    ViewB { ... } // ViewB 的布局变化也有动画
}
```

如果只想让 ViewA 有动画，将 `animate` 绑定到 ViewA 的 `attr` 中。

### 同级作用域

同一个 `attr {}` 内可定义多个 `animate`，**每个 animate 的作用范围是其上方到上一个 animate（或大括号起点）之间的属性**。

```kotlin
attr {
    // 属性1：右移
    absolutePosition(top = 10f, left = if (ctx.isAnimation) 110f else 10f)
    animate(Animation.linear(1f), ctx.isAnimation)  // 控制上方的 absolutePosition

    // 属性2：旋转
    transform(Rotate(if (ctx.isAnimation) 90f else 0f))
    animate(Animation.linear(2f), ctx.isAnimation)  // 控制上方的 transform

    // 属性3：背景色
    backgroundColor(if (ctx.isAnimation) Color.BLUE else Color.YELLOW)
    animate(Animation.linear(3f, key = "bg"), ctx.isAnimation)  // 控制上方的 backgroundColor
}
```

## 各属性动画示例

### opacity 动画

```kotlin
var opacityFlag by observable(false)

View {
    attr {
        size(150f, 150f)
        backgroundColor(Color.GREEN)
        opacity(if (ctx.opacityFlag) 0f else 1f)
        animate(Animation.linear(0.5f), ctx.opacityFlag)
    }
}

// 触发
setTimeout(500) { opacityFlag = true }
```

### backgroundColor 动画

```kotlin
var bgFlag by observable(false)

View {
    attr {
        size(150f, 150f)
        backgroundColor(if (ctx.bgFlag) Color.GREEN else Color.RED)
        animate(Animation.linear(0.5f), ctx.bgFlag)
    }
}
```

### transform 位移动画

```kotlin
var translateFlag by observable(false)

View {
    attr {
        size(150f, 150f)
        if (ctx.translateFlag) { transform(Translate(0.5f, 0.5f)) }
        backgroundColor(Color.GREEN)
        animate(Animation.easeIn(0.5f), ctx.translateFlag)
    }
}
```

### transform 缩放动画

```kotlin
var scaleFlag by observable(false)

View {
    attr {
        size(100f, 100f)
        backgroundColor(Color.GREEN)
        transform(Scale(if (ctx.scaleFlag) 0.5f else 1f, if (ctx.scaleFlag) 0.5f else 1f))
        animate(Animation.linear(0.5f), ctx.scaleFlag)
    }
}
```

### transform 旋转动画

```kotlin
var rotateFlag by observable(false)

View {
    attr {
        size(100f, 100f)
        backgroundColor(Color.GREEN)
        transform(Rotate(if (ctx.rotateFlag) 20f else 0f))
        animate(Animation.linear(0.5f), ctx.rotateFlag)
    }
}
```

> **注意**：transform 默认以组件中心点为轴心，可通过 `Anchor(x, y)` 自定义

### frame 动画

```kotlin
var frameHeight by observable(100f)

View {
    attr {
        size(100f, ctx.frameHeight)
        backgroundColor(Color.GREEN)
        animate(Animation.linear(0.5f), ctx.frameHeight)
    }
}

// 触发
frameHeight = 200f
```

## 动画事件监听

```kotlin
View {
    attr {
        backgroundColor(if (ctx.flag) Color.RED else Color.YELLOW)
        animate(Animation.linear(2f, key = "bgAnimation"), ctx.flag)
    }
    event {
        animationCompletion { params ->
            // params.finish: 1=完成, 0=取消
            // params.attr: 变化的属性名（如 "backgroundColor"）
            // params.animationKey: Animation 的 key 值
        }
    }
}
```

## 注意事项

- `animate` 是新接口，`animation` 是旧接口（已废弃），**不能混用**，否则会抛出运行时错误
- `animate` 的 `value` 参数必须传入**响应式变量**，否则无法触发动画
- 同一属性一次只能绑定一个 Animation 对象
