# Compose 稳定性规则（已实测验证）

---

## 编译器如何判断稳定性

| 类型 | 编译器判断 | 说明 |
|------|-----------|------|
| 全 `val` + 属性类型均稳定 | **stable（自动）** | 无需任何注解 |
| 含 `var` 属性 | **unstable** | var 可随时被外部修改 |
| 含 `List`/`Map`/`Set` 属性 | **unstable** | 集合接口存在可变实现 |
| 含跨模块类型 | **unstable** | 编译器无法推断 |
| 加了 `@Stable` 或 `@Immutable` | **stable（注解覆盖）** | 编译器信任开发者承诺，不再因上述原因判为不稳定 |
| `interface` 类型参数 | **unstable（默认）** | 无法推断实现类；给接口加 `@Stable` 可覆盖 |

可用编译器报告验证：`composeCompiler { reportsDestination.set(...) }` 生成 `*-classes.txt`。

---

## Skip 发生的条件

编译器判为 stable **不等于** skip 一定发生。Skip 还需要新旧参数相等：

| 类型 | 相等判断方式 | 含义 |
|------|------------|------|
| `data class` | `equals()`（内容比较） | 每次 `copy()` 同内容 → skip |
| 普通 `class`（含 `@Stable`） | `===`（引用比较） | 每次 `new` → 引用不等 → 不 skip |

---

## 注解的有效使用场景

### `@Immutable` 何时有效
- 全 `val` 属性但含**跨模块类型**（编译器无法推断），且调用方会复用实例或内容相同
- 含 `List` 属性且**无法改为 ImmutableList**，且调用方不会每次传新 List

### `@Stable` 何时有效
- 普通类内部用 `mutableStateOf` 管理状态，变化通过 MutableState 通知 Compose
- 接口类型，所有实现类满足稳定性承诺

### 注解何时无效或危险

| 场景 | 结果 |
|------|------|
| 含 `var` 加 `@Stable`，但 `var` 被直接赋值（不通过 MutableState） | Skip 发生，但界面不更新（显示过时数据的 **bug**） |
| 含 `List` 加 `@Immutable`，但调用方每次传新 List 实例 | 注解被覆盖推断为 stable，但每次引用不等 → 不 skip（data class 因 equals() 仍可 skip） |
| `@Stable` 普通类，调用方每次 `new` 新实例 | `===` 引用不等 → 不 skip |

---

## 推荐修复方案（优先级排序）

1. **含 `List` 属性** → 改为 `ImmutableList`（根本修复，无需注解）
2. **含 `var` 属性** → 改为 `val` + `mutableStateOf`，或拆成独立 StateFlow
3. **跨模块类型** → 加 `@Immutable`（确认构造后不变）或 stability config 文件
4. **接口类型参数** → 给接口加 `@Stable`，确认所有实现类稳定

---

## Profiler 中的表现差异（C11）

不稳定类型的组件，在 Profiler 中表现与稳定类型不同：

| 情况 | scopeKey | 含义 |
|------|---------|------|
| 稳定类型，参数不变 → skip | 无记录 | 函数体完全不执行，零开销 |
| 稳定类型，参数变化 → 重组 | 有具体值 | 函数体执行，scope 复用 |
| **不稳定类型 → 无法 skip** | **null（首次组合）** | **函数体每次执行，且每次创建新 scope** |

**为什么 scopeKey = null**：不稳定类型的组件，Compose 无法复用旧的 RecomposeScope（参数被视为「可能已变化」），每次都创建新 scope，Profiler 因此记录为「首次组合」而非「重组」。

**性能含义**：核心开销是**函数体每次都执行**（等同于不 skip）。scope 创建本身是轻量操作，不是主要开销。

**重要限制**：`scopeKey=null` 无法可靠区分「真正的首次组合」和「不稳定类型反复执行」，两者的 `paramChanges`/`reason`/`triggerStates` 数据特征存在重叠（经实测验证）。最可靠的检测方式是编译器稳定性报告（`*-classes.txt`），而非运行时日志分析。

---

## Strong Skipping（Kotlin 2.0+ 默认开启）

- 编译器自动对 lambda 参数做 `remember`，无需手写
- 手写 `remember { { ... } }` 包裹 lambda 是**多余的**，不是有效优化
- lambda 参数仍高频变化 → 问题在 lambda **捕获的变量**的稳定性，不是 lambda 本身
