---
name: kuikly-animation
description: Kuikly DSL 动画开发助手(Kuikly DSL)。指导使用声明式和命令式两种方式实现 transform、opacity、backgroundColor、frame 等属性动画，涵盖串行/并行编排与动画取消。当用户需要实现动画效果时使用。
---
Kuikly 动画系统开发助手（Kuikly DSL）。指导如何使用声明式动画（animate + 响应式变量）和命令式动画（animateToAttr + ViewRef）实现 opacity、backgroundColor、transform（位移/缩放/旋转/倾斜）、frame 等属性动画，涵盖 Animation 曲线配置、串行/并行动画编排、动画取消与循环等高级模式。当用户在 Kuikly 中需要实现动画效果、排查动画不生效、进行复杂动画编排时使用。

# Kuikly 动画系统

## 核心概念

Kuikly 动画描述视图从**状态 A** 到**状态 B** 的属性过渡过程。三大要素：

1. **可动画属性**：transform（位移/缩放/旋转/倾斜）、opacity、backgroundColor、frame（位置和大小）
2. **Animation 对象**：控制动画曲线、时长、延迟、是否循环
3. **触发方式**：声明式（响应式变量驱动）或命令式（直接调用 animateToAttr）

## 两种动画方式对比

| 特性 | 声明式动画 | 命令式动画 |
|------|-----------|-----------|
| 触发方式 | 响应式变量变化自动触发 | 手动调用 `animateToAttr` |
| 核心 API | `attr { animate(animation, value) }` | `viewRef?.view?.animateToAttr(animation) { ... }` |
| 适用场景 | 简单状态切换动画 | 复杂动画编排、串行动画 |
| 结束回调 | `event { animationCompletion { } }` | `completion` 参数回调 |
| 推荐度 | 简单动画首选 | 复杂动画推荐 |

---

## Animation 对象

### 动画曲线类型

```kotlin
// 基础曲线
Animation.linear(durationS, key = "")        // 线性
Animation.easeIn(durationS, key = "")        // 先慢后快
Animation.easeOut(durationS, key = "")       // 先快后慢
Animation.easeInOut(durationS, key = "")     // 两端慢中间快

// 弹簧曲线（额外参数：damping 阻尼, velocity 初速度）
Animation.springLinear(durationS, damping, velocity, key = "")
Animation.springEaseIn(durationS, damping, velocity, key = "")
Animation.springEaseOut(durationS, damping, velocity, key = "")
Animation.springEaseInOut(durationS, damping, velocity, key = "")
```

### 动画过程控制

```kotlin
Animation.linear(0.5f)
    .delay(0.3f)              // 延迟 0.3 秒启动
    .repeatForever(true)      // 无限循环
```

### 参数说明

| 参数 | 类型 | 说明 |
|------|------|------|
| durationS | Float | 动画持续时间（秒） |
| key | String | 动画标识，animationCompletion 回调中用于区分动画 |
| damping | Float | 弹簧阻尼系数 |
| velocity | Float | 弹簧初始速度 |

---

## 可动画属性与 Transform 类

### Transform 类型

| 类 | 构造参数 | 说明 |
|----|---------|------|
| `Translate(percentageX, percentageY)` | X/Y 位移百分比 [-1,1]，可超出 | 位移，支持 offsetX/offsetY (dp) |
| `Scale(x, y)` | 缩放比例 [0, max] | 缩放 |
| `Rotate(angle)` | 角度 [-360, 360] | 2D 旋转（围绕 Z 轴） |
| `Rotate(angle, xAngle, yAngle)` | 各轴角度 | 3D 旋转 |
| `Skew(horizontalAngle, verticalAngle)` | 倾斜角度 (-90, 90) | 倾斜 |
| `Anchor(x, y)` | 锚点 [0, 1] | transform 中心点，默认 (0.5, 0.5) |

### transform 方法签名

```kotlin
fun transform(
    rotate: Rotate = Rotate.DEFAULT,
    scale: Scale = Scale.DEFAULT,
    translate: Translate = Translate.DEFAULT,
    anchor: Anchor = Anchor.DEFAULT,
    skew: Skew = Skew.DEFAULT
)

// 便捷重载（只传单个 transform 类型）
fun transform(rotate: Rotate)
fun transform(scale: Scale)
fun transform(translate: Translate)
fun transform(skew: Skew)
```

---

## 声明式动画快速入门

```kotlin
var flag by observable(false)

View {
    attr {
        size(100f, 100f)
        backgroundColor(if (ctx.flag) Color.GREEN else Color.RED)
        animate(Animation.linear(0.5f), ctx.flag)
    }
}

// 触发动画
flag = true
```

**详细用法**（animate 作用域、同级作用域、父子作用域）：见 [DECLARATIVE_ANIMATION.md](references/DECLARATIVE_ANIMATION.md)

## 命令式动画快速入门

```kotlin
var viewRef: ViewRef<DivView>? = null

View {
    ref { ctx.viewRef = it }
    attr {
        size(100f, 100f)
        backgroundColor(Color.RED)
    }
}

// 触发动画
viewRef?.view?.animateToAttr(Animation.linear(0.5f), attrBlock = {
    backgroundColor(Color.GREEN)
}, completion = { finished ->
    // finished: true=完成, false=被取消
})
```

**详细用法**：见 [IMPERATIVE_ANIMATION.md](references/IMPERATIVE_ANIMATION.md)

## 高级动画模式

串行动画、并行动画、动画中途启动、动画取消等：见 [ANIMATION_PATTERNS.md](references/ANIMATION_PATTERNS.md)
