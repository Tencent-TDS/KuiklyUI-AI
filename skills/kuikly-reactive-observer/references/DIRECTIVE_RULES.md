# 指令使用规则与约束

## 循环指令约束

### 规则1：闭包内必须且仅生成一个根节点

`vfor`、`vforIndex`、`vforLazy` 的闭包内必须创建**恰好一个**根节点。

源码校验（`LoopDirectivesView.kt`）：
```kotlin
if (childrenSize() - beforeChildrenSize != 1) {
    throwRuntimeError("vfor creator闭包内必须需要且仅一个孩子节点的生成")
}
```

### 规则2：根节点不能是指令节点

闭包内的根节点不能是 `vif`、`vfor` 等虚拟指令节点，需用 `View` 包裹：

```kotlin
// ✅ 正确
vfor({ ctx.list }) { item ->
    View {  // 非虚拟节点作为根
        vif({ item.isActive }) {
            Text { attr { text(item.name) } }
        }
    }
}
```

### 规则3：vforLazy 仅限 ListView

`vforLazy` 是 `ListView` 的扩展函数，只能在 `List` 组件中使用，不支持 `PageList`、`WaterfallList` 等子类。

源码校验（`LazyLoopDirectivesView.kt`）：
```kotlin
listViewContent = parent as? ListContentView
    ?: throw RuntimeException("vforLazy必须是List子节点")
```

## 条件指令约束

### 规则4：velseif / velse 必须紧跟 vif

`velseif` 和 `velse` 必须紧跟在 `vif` 或 `velseif` 之后，中间不能插入其他组件。

源码校验（`ConditionView.kt`）：
```kotlin
if (isIfConditionView(prevView) || isElseIfConditionView(prevView)) {
    rootConditionViewRef = (prevView as? ConditionView)!!.rootConditionViewRef
} else {
    throwRuntimeError("模板条件指令错误：if else 条件匹配错误")
}
```

### 规则5：条件闭包必须引用响应式字段

条件闭包 `{ ctx.xxx == value }` 中必须读取响应式字段，否则框架无法收集依赖，条件变化时不会触发更新。

## vbind 约束

### 规则6：vbind 绑定值为 null 时不执行 creator

`BindDirectivesView` 源码中，初始化和更新时都会检查 `bindValueResult` 是否为 null：

```kotlin
bindValueResult?.also {
    creator()  // 只有非 null 时才执行
}
```

因此如果 `vbind` 的闭包返回 `null`，不会创建任何子组件。

## vforIndex 的 index/count 更新规则

`vforIndex` 中，数据增删时**只有变化的元素**会触发闭包重新执行。未变化的元素即使 `index` 和 `count` 已改变，也不会更新。

**手动触发特定元素更新**：

```kotlin
// 扩展函数：显式触发指定 index 的元素更新
private inline fun <reified T> ObservableList<T>.notifyUpdate(index: Int) {
    this[index] = this[index]
}

// 使用
ctx.list.notifyUpdate(ctx.list.size - 1)
```

## diffUpdate 使用场景

当需要用新列表替换旧列表时，优先使用 `diffUpdate` 而非 `clear() + addAll()`：

```kotlin
// 方法签名
fun diffUpdate(newList: List<T>, areItemsTheSame: ((T, T) -> Boolean)? = null)

// 基本用法
list.diffUpdate(newData)

// 复杂对象：通过 id 判断是否同一元素
userList.diffUpdate(newUsers) { old, new -> old.id == new.id }
```

> **注意**：使用自定义比较器时，`areItemsTheSame` 返回 `true` 表示是"同一元素"（保留旧元素），返回 `false` 表示不同（执行增删）。
