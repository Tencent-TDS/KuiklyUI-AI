
# 响应式数据

## observable

```kotlin
import com.tencent.kuikly.core.reactive.handler.observable
```

声明响应式变量，值变化时自动触发依赖该变量的 UI 更新。

```kotlin
class MyPage : Pager() {
    // 声明响应式变量，可设置初始值
    var title by observable("")
    var count by observable(0)
    var show by observable(true)
}
```

---

## observableList

```kotlin
import com.tencent.kuikly.core.reactive.handler.observableList
```

声明响应式列表，用于 `vfor`、`vforIndex` 循环。声明时需指定泛型类型 `<T>`，**不支持设置初始值**，请在 `created()` 中添加数据。

```kotlin
class MyPage : Pager() {
    // 声明时指定泛型，不能设置初始值
    var itemList by observableList<ItemData>()

    override fun created() {
        super.created()
        // 在 created 中添加数据
        itemList.addAll(listOf(
            ItemData("item1"),
            ItemData("item2")
        ))
    }
}
```

---

## ObservableList 列表操作

```kotlin
import com.tencent.kuikly.core.reactive.collection.ObservableList
```

实现了 `MutableList<T>` 接口，所有标准列表操作都支持，并内置 Myers diff 算法。

**常用方法：**

```kotlin
// 标准 MutableList 操作
itemList.add(newItem)
itemList.addAll(newItems)
itemList.add(index, element)
itemList.addAll(index, elements)
itemList.removeAt(index)
itemList.remove(element)
itemList.removeAll(elements)
itemList.clear()
itemList[index] = updatedItem

// Myers diff 更新（高效局部更新，避免全量刷新）
itemList.diffUpdate(newList)

// 自定义比较函数的 diff 更新
itemList.diffUpdate(newList) { old, new -> old.id == new.id }
```
