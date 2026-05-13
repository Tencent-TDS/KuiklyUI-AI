# LazyList Item 重组分析规则

## 1. item {} 闭包重建 ≠ 内部组件无法 skip

`item {}` 闭包在滚动时会重新执行（因为 `LazyListItemProviderImpl` 每次布局创建新实例，`derivedStateOf(referentialEqualityPolicy())` 触发），但这是**闭包层级**的重组，不影响内部业务组件的 skip。

Compose 的 skip 机制按**组件粒度**工作：
- 闭包重新执行 → 内部的业务 Composable（如 `ChatReceive`）会被调用
- 业务 Composable 能否 skip，取决于**自身参数是否稳定 + 参数值是否相等**
- 参数类型稳定且值未变 → skip 成功，函数体不执行
- 参数值确实变了 → 正常重组，不是 skip 失败

**关键判断**：看业务组件的 `scopeDistribution` 是否有 scope（有 scope = skip 机制正常工作），而不是看闭包是否重新执行。

---

## 2. LazyLayoutItemProvider 的分析方式

Profiler 中 `triggerStates` 出现 `LazyListItemProviderImpl` 是**正常现象**，因为它是 `item {}` 闭包重建的触发源。分析时：

- **不要**将 `LazyListItemProviderImpl` 出现在 `triggerStates` 中直接定性为「框架 bug」或「State 广播问题」
- 应该**往下看一层**：闭包重建后，内部业务组件的参数是否稳定？能否 skip？
- 如果业务组件有 scope（`scopeDistribution` 有值）→ skip 机制正常，问题在参数
- 如果业务组件 scope 全为 null（`noScope == recompositionCount`）→ 才需要怀疑参数类型不稳定

---

## 3. 业务参数稳定性的分析流程

当 item 下的业务组件重组次数高时：

1. **查 `paramChangeFrequency`**：哪个参数变化率高？
2. **读源码定位参数**：按函数签名声明顺序，将 `#N` 对应到具体参数名和类型
3. **判断变化的本质**：
   - 值确实每次不同（业务数据在变）→ 正常重组，做高频风险提醒
   - 值相同但引用不等（每次新建对象、`copy()`）→ 参数稳定性问题，给出优化方案
   - 参数类型不稳定（含 `var`、`List`、接口等）→ 类型稳定性问题，按 `stability-rules.md` 处理

---

## 4. 高频重组的风险提醒

当确认是正常重组（数据确实在变），但频率过高时：

- **不要说**「这是 bug 需要修复」
- **应该提示**：数据变更频率高，每次变更触发 N 个组件级联重组，建议评估是否可以降低变更频率或拆分订阅粒度
- **具体建议**：如果一个大对象任何字段变化都导致整棵子树重组，可以拆分为细粒度 State，让子组件只订阅自己关心的字段

**风险提醒模板**：
> 该组件因 {参数名} 变更触发重组，变更频率 X 次/Y 帧，每次变更导致 N 个子组件级联重组。数据变更本身合理，但建议评估是否可以拆分订阅粒度，减少级联范围。

---

## 5. 需要规避的错误结论

| 错误结论 | 正确分析 |
|---------|---------|
| `LazyListItemProviderImpl` 是框架 bug 导致无法 skip | item 闭包重建是正常行为，业务组件的 skip 取决于自身参数 |
| `triggerStates` 中出现框架 State = 框架有问题 | 框架 State 是闭包重建的触发源，不影响业务组件的 skip |
| `neverEqualPolicy` 导致所有组件无法 skip | `neverEqualPolicy` 只影响 `layoutInfoState` 的变化通知，不直接影响业务组件的 skip |
| 重组次数高 = 有问题需要优化 | 需要先判断数据是否真的在变，正常重组只做风险提醒 |
