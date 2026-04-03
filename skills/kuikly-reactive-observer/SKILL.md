---
name: kuikly-reactive-observer
description: Kuikly 响应式更新与指令系统开发助手(Kuikly DSL)。指导如何使用 observable、observableList、observableSet 实现 UI 响应式更新，以及 vfor、vforIndex、vforLazy、vif、velseif、velse、vbind 等指令的正确用法。当用户在 Kuikly 中需要以下场景时使用：(1) 声明响应式字段并绑定到 UI 属性 (2) 列表渲染（vfor/vforIndex/vforLazy） (3) 条件渲染（vif/velseif/velse） (4) 值绑定渲染（vbind） (5) 高效列表更新（diffUpdate） (6) 响应式数据不生效、UI 不更新等问题排查 (7) observableList/observableSet 的增删改操作 (8) 复杂对象的响应式更新策略
---

# Kuikly 响应式更新与指令系统

## 核心机制

`attr {}` 闭包中读取响应式字段时，框架自动收集依赖；字段值变化时，自动更新绑定的 UI 属性。**只需更新数据，UI 自动响应。**

> 注意：`observable` 内部使用 `==` 比较新旧值，**相等时不触发更新**。

---

## 响应式字段声明

在 `Pager`（实现了 `PagerScope` 接口）或任何 `PagerScope` 子类中使用：

```kotlin
// 推荐：PagerScope 扩展函数
import com.tencent.kuikly.core.reactive.handler.observable
import com.tencent.kuikly.core.reactive.handler.observableList
import com.tencent.kuikly.core.reactive.handler.observableSet

var counter by observable(0)                    // 单值
var list by observableList<String>()            // 响应式列表，配合 vfor
var tags by observableSet<String>()             // 响应式集合
```

### 绑定到 UI

```kotlin
var title by observable("Hello")

Text {
    attr {
        text(ctx.title) // 直接引用响应式字段，自动绑定
    }
}
// 更新 ctx.title = "World" 后，Text 自动刷新
```

---

## 指令系统

### 循环指令：vfor / vforIndex

```kotlin
var list by observableList<String>()

// vfor：遍历 observableList，增删时自动增量更新
List {
    attr { flex(1f) }
    vfor({ ctx.list }) { item ->
        Text { attr { text(item) } }
    }
}

// vforIndex：额外提供 index 和 count
vforIndex({ ctx.list }) { item, index, count ->
    View {
        attr { backgroundColor(if (index % 2 == 0) Color.GRAY else Color.TRANSPARENT) }
        Text { attr { text("$index: $item") } }
    }
}
```

> **必须传闭包** `{ ctx.list }`，不是直接传值 `ctx.list`。

### 循环指令：vforLazy（超大列表）

仅在 `ListView` 中使用（不含 PageList、WaterfallList），动态增删可见范围外的虚拟节点：

```kotlin
List {
    attr { flex(1f) }
    vforLazy({ ctx.list }, maxLoadItem = 50) { item, index, count ->
        Text { attr { text(item) } }
    }
}
```

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| itemList | `() -> ObservableList<T>` | — | 数据源闭包 |
| maxLoadItem | `Int` | 30 | 内存中最大虚拟节点数，建议为一屏可见数的 2~3 倍 |
| itemCreator | `(T, Int, Int) -> Unit` | — | 构建闭包 |

### 条件指令：vif / velseif / velse

```kotlin
var state by observable(0)

View {
    vif({ ctx.state == 1 }) {
        Text { attr { text("状态1") } }
    }
    velseif({ ctx.state == 2 }) {
        View { attr { size(100f, 100f); backgroundColor(Color.GREEN) } }
    }
    velse {
        Text { attr { text("其他状态") } }
    }
}
```

> `velseif` / `velse` 必须紧跟 `vif` 或 `velseif`，中间不能插入其他组件。

### 绑定指令：vbind

类似 `when` 语句，绑定值变化时**移除所有子组件并重建**：

```kotlin
var state by observable(0)

View {
    vbind({ ctx.state }) {
        when (ctx.state) {
            1 -> Text { attr { text("状态1") } }
            2 -> View { attr { size(100f, 100f); backgroundColor(Color.GREEN) } }
        }
    }
}
```

> `vbind` 绑定值为 `null` 时不执行 creator 闭包。

---

## 高效更新列表：diffUpdate

```kotlin
// 基本用法（基于 Myers diff 算法，只增删变化的 Item）
list.diffUpdate(newData)

// 自定义比较（通过 id 判断是否同一元素）
userList.diffUpdate(newUsers) { old, new -> old.id == new.id }
```

| 方式 | 行为 | 性能 |
|------|------|------|
| `clear() + addAll()` | 销毁所有 Item → 重建 | 差 |
| `diffUpdate(newList)` | 只增删变化的 Item | 优 |

---

## 常见错误与约束规则

详见以下参考文件：

- **常见错误**：[COMMON_MISTAKES.md](references/COMMON_MISTAKES.md) — 响应式依赖断开、对象内部属性修改不触发更新、vfor 闭包传值而非传闭包、ViewBuilder 未 invoke 等 8 类典型错误
- **指令约束规则**：[DIRECTIVE_RULES.md](references/DIRECTIVE_RULES.md) — vfor 闭包必须且仅生成一个根节点、根节点不能是指令节点、vforLazy 仅限 ListView、velseif/velse 必须紧跟 vif、vforIndex 的 index/count 更新规则等

---