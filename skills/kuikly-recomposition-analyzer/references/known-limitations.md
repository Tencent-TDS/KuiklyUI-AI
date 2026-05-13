# 已知限制

## 1. paramChanges 索引无法映射到参数名

`paramChangeFrequency` 的 key 是 `#N`（参数索引，从 0 开始），无法直接知道参数名。

**影响**：skill 只能提示「第 N 个参数变化率高」，需要用户结合 `sourceLocation` 读源码，按参数声明顺序手动对应。

**建议**：读取源码后，按函数签名中参数的声明顺序告知用户：「`#1` 对应参数 `onClick: () -> Unit`」。

---

## 2. sourceLocation 无包路径

`sourceLocation` 格式为 `FileName.kt:lineNumber`，只有文件名，没有完整包路径。

**影响**：若项目中存在同名文件（如多个模块都有 `ItemCard.kt`），Glob 会匹配多个结果。

**处理方式**：
- 唯一匹配 → 直接读取
- 多个匹配 → 标注「文件歧义」，列出所有候选路径，让用户确认
- 无匹配 → 标注「源码未定位」，继续分析其他项

---

## 3. frames.jsonl 时间戳精度

同一毫秒内多帧的时间戳可能相同，无法严格按时间排序帧。

**影响**：touch/scroll 上下文事件与帧的时序关联可能存在 ±1ms 误差。

**处理方式**：按文件行序（不按时间戳）推断上下文关系。

---

## 4. layoutInfoState neverEqualPolicy 产生大量 state change

KuiklyUI 内部 `LazyListState.layoutInfoState` 使用 `neverEqualPolicy`，导致每次布局都会产生 state change 记录。

**影响**：`triggerStates` 中会出现大量 `layoutInfoState` 相关的记录，干扰 State 广播检测。

**处理方式**：在报告中说明此现象属于框架内部行为，不计入 RULE-B 统计。读取时可过滤掉 stateId 包含 `layoutInfoState` 的条目。

---

## 5. touch 上下文缺少 touchCancel

当前实现中，平台层（KuiklyUI 的 `PointerEventType`）不包含 `Cancel` 枚举值，因此 `touch_context` 只有 `touchBegin` 和 `touchEnd`，没有 `touchCancel`。

**影响**：用户手指滑出屏幕后的取消操作，只能看到 `touchBegin` 没有对应的结束事件。

---

## 6. 框架内部 Composable 已被过滤

Profiler 默认过滤框架内部的 Composable（如 `Row`、`Column` 的 measure policy、Runtime 内部函数等）。

**影响**：report.json 中只包含业务代码的 Composable，framework 层的性能问题不在分析范围内。

---

## 7. 动画上下文事件暂未实现

当前 profiler 不输出动画相关的上下文事件（如 AnimationState 变化）。

**影响**：动画驱动的持续重组无法通过上下文事件区分是否正常。

**临时方案**：检查 `triggerStates` 中 State 名称是否包含 `animation`、`AnimationState` 等关键词，作为「疑似动画 State」的提示。

---

## 8. 多页面日志覆盖

同一 App 内多个页面共用同一 `FileModule` 目录，新 session 启动时会覆盖上一次的文件。

**影响**：如果在分析过程中再次启动 Profiler，文件会被覆盖。

**提示**：分析前先保存好文件副本。

---

## 9. paramChangeFrequency 不区分参数类型

`paramChangeFrequency` 只记录参数**索引**（`#0`、`#1`...）和变化次数，**不包含**：
- 参数名
- 参数类型（是 data class / List / lambda / 还是基本类型）
- 参数旧值 → 新值的具体变化内容

**影响**：无法仅凭 profiler 数据判断 RULE-C 的根因是「数据类不稳定」还是「lambda 捕获不稳定」还是「业务数据真的在变」。

**处理方式**：
- 必须读取 `sourceLocation` 对应源码，按声明顺序对应参数
- 按参数类型分类处理（详见 `optimization-patterns.md` RULE-C 的前置判断表）
- 报告中明确标注「参数类型：X」和「假设：项目已开启 Strong Skipping」

---

## 10. 无法从 profiler 数据确认 Strong Skipping 开启状态

Profiler 输出中不包含项目的 Compose Compiler 配置。

**影响**：无法直接判断「lambda 参数 100% 变化」是否因为 Strong Skipping 未开启导致。

**处理方式**：
- 优先在项目构建脚本中查找：`composeCompiler { ... }`、`ComposeFeatureFlag.StrongSkipping`、Compose Compiler 版本
- 找不到时在报告中声明「按 Strong Skipping 已开启推断」
- Strong Skipping 在 Kotlin 2.0+ / Compose Compiler 1.5.4+ 默认开启，大多数现代项目应该是开启状态

---

## 11. 不稳定类型的组件在 Profiler 中表现为「首次组合」而非「重组」

**现象**：含 `var` 属性、`List` 属性或无 `equals()` 的普通 class 参数的组件，每次父重组时 Profiler 记录的 `scopeKey = null`（首次组合），而不是有具体值的 scopeKey（真实重组）。

**原因**：对不稳定类型，Compose 每次都创建新的 RecomposeScope，所以每次执行都是「新 scope 的首次组合」。

**影响**：
- `recompositionCount` 不会增加（首次组合不计入），可能误以为组件 skip 了
- 实际上函数体每次都在执行，等同于不 skip

**无法可靠区分**：`scopeKey=null` 同时出现在两种情况：
1. 列表滑入时 item 的真正首次组合（正常）
2. 不稳定类型组件被反复执行（有问题）

这两种情况的 `paramChanges`、`reason`、`triggerStates` 数据特征存在重叠，**不能用单条事件数据可靠区分**（经实测验证：真正的首次组合中也有 72% 含 `paramChanges` 变化数据）。

**目前可用的识别方式**：
- 通过 report.json 的 `paramChangeFrequency` 高频率（接近 recompositionCount 次数）判断参数不稳定
- 结合编译器稳定性报告（`composeCompiler { reportsDestination }` 生成的 `*-classes.txt`）直接确认类型稳定性
- 本质上：如果类型是 unstable，就存在此问题；最可靠的检测是在编译期而非运行期
