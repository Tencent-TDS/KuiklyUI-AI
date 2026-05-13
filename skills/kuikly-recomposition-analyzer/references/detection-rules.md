# 检测规则

## report 层规则（Phase 2）

### RULE-B：State 广播

**信号**：`triggerStates[i].readers.length > stateReadersThreshold`（默认 3）

**含义**：某个 State 被多个 Composable 订阅，State 变化时触发大面积重组（广播效应）。

**判断逻辑**：
```
for state in composable.triggerStates:
    if state.readers.length > stateReadersThreshold:
        → 标记 RULE-B，记录该 State 和所有 readers
```

---

### RULE-C：参数高频变化（需先判断变化本质）

**信号**：`paramChangeFrequency["#N"] / recompositionCount > paramChangeRateThreshold`（默认 0.9）

**含义**：第 N 个参数几乎每次重组都发生变化，导致当前组件无法 skip。

**分析前必须先回答**：这个参数的值每次**确实不同**，还是**内容相同但每次传入新实例**？

| 情况 | 典型场景 | 根因方向 |
|------|---------|---------|
| 值确实每次不同 | 滚动时坐标变化、每帧递增的计数器 | 写入逻辑问题（写入太频繁），不是类型稳定性 |
| 值相同但引用不等 | 每次 `copy()`、`listOf()`、新建对象 | 对象创建问题（用 `remember` 缓存）或类型稳定性 |

**常见根因**（确认是「引用不等」后再考虑以下）：

1. **每次重组都新建对象**（最常见）：`copy()`、`listOf()`、lambda 表达式在重组时创建新实例 → 用 `remember` 缓存
2. **集合类型非 Immutable**：`List<T>`/`Map<K,V>`/`Set<T>` 标准集合接口被视为不稳定 → 改用 `ImmutableList` 等
3. **data class 含不稳定属性**：有 `var` 字段、属性含集合接口、或含跨模块类型 → 修复属性类型。注意：全 `val` + 稳定属性类型的 `data class` **自动稳定，无需注解**
4. **Lambda 捕获不稳定变量**：Strong Skipping 已开启时，lambda 自动 `remember`，问题在捕获变量本身的稳定性

**判断逻辑**：
```
for (param, changeCount) in composable.paramChangeFrequency:
    rate = changeCount / composable.recompositionCount
    if rate > paramChangeRateThreshold:
        → 标记，读源码找到 #N 对应的参数
        → 先判断：值确实每次不同 OR 引用不等但值相同？
        → 再选对应根因方向
```

> **关于 Lambda**：Strong Skipping 模式（Kotlin 2.0+ / Compose Compiler 1.5.4+ 默认开启）下，编译器自动 `remember` lambda，无需手写。若 lambda 参数仍高频变化，问题在 lambda 捕获的变量，而不是 lambda 本身。

> **关于 data class**：全 `val` + 属性类型均稳定 → 编译器自动稳定，不需要 `@Immutable`/`@Stable`。只有含 `var`/集合接口/跨模块类型时才需要处理稳定性。

---

### noScope 归正常

**条件**：`noScopeRecompositions == recompositionCount`（scopeDistribution 为空）

**含义**：所有重组都是首次组合（first composition），不是真正的重组，直接归入正常清单。

---

### scope 高频预筛

**信号**：`scopeDistribution` 中某 scopeKey 计数 > `scopeCountThreshold`（默认 5）

**含义**：某个具体的 RecomposeScope 被反复触发，进入 frames 层深挖。

---

## frames 层规则（Phase 3）

### RULE-A：单次重组耗时长

**信号**：帧内 `composable_recomposed` 事件的 `durationMs > durationThreshold`（默认 5ms）

**含义**：单次重组耗时过长，可能有复杂计算或大量 State 读取。

---

### 帧级卡顿告警

**信号**：frame 行的 `durationMs > frameDurationThreshold`（默认 16ms）

**含义**：该帧超过 16ms 预算，会导致掉帧/卡顿。

---

### 帧级热点告警

**信号**：frame 内 `composable_recomposed` 事件数 > `frameEventThreshold`（默认 50）

**含义**：单帧内大量组件重组，可能是 State 广播或级联重组。

---

### 级联重组

**信号**：同帧内多个不同组件的 `triggerStates` 包含相同 State 标识符

**含义**：同一个 State 在单帧内触发了多个组件重组，可能存在过粗的 State 粒度。

---

## 上下文规则（有 touch/scroll 上下文时）

### touch 辅助判断

| 场景 | 判断 |
|------|------|
| touchBegin ~ touchEnd 之间重组 1 次 | 正常（点击响应） |
| touchBegin ~ touchEnd 之间某 scope 重组 > 3 次 | 疑似可优化，标注「一次点击触发 N 次重组」 |

### scroll 辅助判断

| 场景 | 判断 |
|------|------|
| scroll_context 中 firstVisibleItemIndex 变化 + item 重组次数 ≈ 滑入数量 | 正常（滚动进入视口的首次组合） |
| scroll_context 中 index 未变 + item 出现重组 | 异常，标注「非滚动导致的重组，需分析」 |

---

## 严重度评级与排序

### 评级标准

严重度以**总耗时**为第一优先级，**重组次数**为次要参考：

| 级别 | 条件 |
|------|------|
| 🔴 高 | 组件总耗时 > 50ms，或单帧内某组件耗时 > 10ms |
| 🟡 中 | 组件总耗时 10~50ms，或重组次数多但单次耗时低（总耗时 < 50ms） |
| 🟢 低 | 总耗时 < 10ms，或接近阈值但实际影响有限 |

### 排序规则

报告中问题诊断段按以下优先级降序排列：

1. **总耗时**（`recompositionCount × avgDurationMs`）：耗时越高排越前
2. 总耗时相近时，以**单次最大耗时**（`maxDurationMs`）决定顺序
3. 耗时都很低时，以**重组次数**作为参考

> **注意**：重组次数多但单次耗时极低（< 0.1ms）的问题，即使次数上百，总耗时也可能不足 10ms，应评为低级别，排在真正耗时高的问题之后。
