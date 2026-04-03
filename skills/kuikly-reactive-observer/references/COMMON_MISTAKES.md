# 响应式更新常见错误

## 错误1：提前取值到普通变量（断开响应式依赖）

响应式依赖收集发生在 `attr {}` 闭包执行时。提前将响应式字段值存入普通变量，闭包中读取的是普通变量，框架无法收集依赖。

```kotlin
// ❌ 错误
val content = ctx.textContent // 提前取值，后续变化不会被追踪
Text {
    attr { text(content) } // 使用普通变量，不会响应变化
}

// ✅ 正确
Text {
    attr { text(ctx.textContent) } // 直接引用，框架自动收集依赖
}
```

## 错误2：修改对象内部属性而非响应式字段本身

响应式系统只监听**响应式字段本身的赋值操作**。修改对象内部属性不触发 UI 更新。

```kotlin
class UserInfo(var name: String)
class ReactiveUser(scope: PagerScope, name: String) {
    var name by scope.observable(name)
}

// 在 Pager 中
var user1 = UserInfo("Alice")                         // 普通对象
var user2 = ReactiveUser(this, "Bob")                 // 内部字段是响应式的
var observableUser1 by observable(UserInfo(""))        // 响应式字段，值是普通对象
var observableUser2 by observable(ReactiveUser(this, "")) // 响应式字段，值也含响应式字段
```

更新操作对照表：

| 操作 | 是否触发更新 | 原因 |
|------|:---:|------|
| `user1.name = "change"` | ❌ | user1 不是响应式字段 |
| `user1 = UserInfo("change")` | ❌ | user1 不是响应式字段 |
| `user2.name = "change"` | ✅ | user2.name 是响应式字段 |
| `observableUser1.name = "change"` | ❌ | 修改的是内部属性，不是响应式字段本身 |
| `observableUser1 = UserInfo("change")` | ✅ | 整体赋值触发更新 |
| `observableUser2.name = "change"` | ✅ | name 是响应式字段 |
| `observableUser2 = ReactiveUser(...)` | ✅ | 整体赋值也触发（但内部声明响应式是冗余的） |

**规则**：要么整体替换 `observable` 字段，要么让对象内部字段也声明为 `observable`。不要同时在外层和内层都声明为响应式（冗余）。

## 错误3：vfor 闭包传值而非传闭包

```kotlin
// ❌ 错误：直接传值
vfor(ctx.list) { item -> ... }

// ✅ 正确：传返回响应式容器的闭包
vfor({ ctx.list }) { item -> ... }
```

## 错误4：vfor 闭包内生成多个或零个根节点

```kotlin
// ❌ 错误：闭包内没有子节点
vfor({ ctx.list }) { item -> }

// ❌ 错误：闭包内多个子节点
vfor({ ctx.list }) { item ->
    Text { attr { text(item.title) } }
    Text { attr { text(item.content) } }
}

// ❌ 错误：条件分支导致某些情况下没有子节点
vforIndex({ ctx.labels }) { label, index, _ ->
    if (index < 10) {
        Text { attr { text(label) } }
    }
}

// ✅ 正确：用 View 包裹多个子节点
vfor({ ctx.list }) { item ->
    View {
        Text { attr { text(item.title) } }
        Text { attr { text(item.content) } }
    }
}

// ✅ 正确：通过数据源控制数量
this.labels.addAll(getLabels().take(10))
vfor({ ctx.labels }) { label ->
    Text { attr { text(label) } }
}
```

## 错误5：指令语句直接作为循环指令子节点

```kotlin
// ❌ 错误：vif 直接作为 vfor 的子节点
vfor({ ctx.list }) { item ->
    vif({ item.isVisible }) {
        Text { attr { text(item.title) } }
    }
}

// ✅ 正确：用 View 包裹
vfor({ ctx.list }) { item ->
    View {
        vif({ item.isVisible }) {
            Text { attr { text(item.title) } }
        }
    }
}
```

## 错误6：条件指令闭包中未使用响应式字段

```kotlin
var isVisible = true // 普通变量，非响应式

// ❌ 不会响应式更新
vif({ isVisible }) { ... }

// ✅ 声明为响应式字段
var isVisible by observable(true)
vif({ ctx.isVisible }) { ... }
```

## 错误7：在 vif/velse 等指令块中调用返回 ViewBuilder 的扩展函数未显式 invoke

`ViewBuilder` 类型是 `ViewContainer<*, *>.() -> Unit`。在 `vif`、`velseif`、`velse`、`vbind` 等指令块内，返回的 `ViewBuilder` 必须**显式调用**（invoke），才能在当前 `ViewContainer` 接收者上执行。

**原因**：`vif` 的 `creator` 闭包接收者是 `ConditionView`（继承自 `ViewContainer`），扩展函数返回的 `ViewBuilder` 是 lambda 值，不会自动执行。

```kotlin
fun MyPage.conversationListBody(): ViewBuilder {
    val ctx = this
    return {
        List {
            attr { flex(1f) }
            vfor({ ctx.dataList }) { item ->
                Text { attr { text(item.title) } }
            }
        }
    }
}

// ❌ 错误：返回的 ViewBuilder 没有被 invoke
vif({ ctx.showList }) {
    ctx.conversationListBody()
}

// ✅ 正确：显式 invoke
vif({ ctx.showList }) {
    ctx.conversationListBody().invoke(this)
}

// ✅ 正确（等价写法）
vif({ ctx.showList }) {
    apply(ctx.conversationListBody())
}
```

> 在 `body()` 返回的顶层 `ViewBuilder` 闭包中，直接调用返回 `ViewBuilder` 的函数后内容会自动展开。但在 `vif` 等指令块中必须显式 invoke 或使用 `apply`。

## 错误8：observable 赋相同值期望触发更新

`ObservableProperties.setValue` 内部使用 `==` 比较新旧值，相等时直接 return，不触发更新。

```kotlin
var data by observable(MyData("hello"))

// ❌ 不会触发更新（如果 MyData 的 equals 返回 true）
ctx.data = MyData("hello")

// ✅ 确保新值与旧值不相等，或使用不同的引用
ctx.data = ctx.data.copy(field = "newValue")
```