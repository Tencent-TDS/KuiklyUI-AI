# 日志格式说明

## profiler_report.json

聚合报告，分析结束后由 `RecompositionProfiler.getReport()` 生成。

### 顶层字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `sessionId` | String | 本次 profiler session 唯一 ID |
| `sessionDuration` | Long | 采集时长（ms） |
| `totalFrames` | Int | 总帧数 |
| `totalRecompositions` | Int | 总重组次数 |
| `composables` | Array | 每个被追踪 Composable 的统计 |
| `hotspots` | Array | 热点组件列表（重组次数最多的 topN） |
| `filteredNames` | Array\<String\> | 本次被过滤排除的组件名列表 |
| `filteredPrefixes` | Array\<String\> | 本次被过滤排除的包名前缀列表 |

### composables[] 每项字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | String | Composable 函数短名（无包路径） |
| `sourceLocation` | String? | 源码位置，格式 `FileName.kt:lineNumber`（无包路径） |
| `recompositionCount` | Int | 总重组次数 |
| `noScopeRecompositions` | Int | 无 scope 的重组次数（首次组合，属正常行为） |
| `avgDurationMs` | Float | 平均重组耗时（ms） |
| `maxDurationMs` | Float | 最大单次重组耗时（ms） |
| `isHotspot` | Boolean | 是否被标记为热点 |
| `scopeDistribution` | Map\<String,Int\> | key=scopeKey hashCode，value=该 scope 触发的重组次数 |
| `triggerStates` | Array | 触发重组的 State 列表 |
| `paramChangeFrequency` | Map\<String,Int\> | key=`#N`（参数索引），value=该参数发生变化的次数 |
| `parentName` | String? | 父级 Composable 名称 |

> **注意**：`scopeDistribution` 的 key 是 scopeKey 的 hashCode（整数字符串），不是 scopeKey 本身。  
> **注意**：`sourceLocation` 只有文件名，没有包路径，Glob 搜索时用 `**/<FileName>.kt`。

### triggerStates[] 每项字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `stateId` | String | State 的标识符 |
| `readers` | Array\<String\> | 订阅该 State 的 Composable 名称列表 |
| `changeCount` | Int | 该 State 发生变化的次数 |

---

## profiler_frames.jsonl

逐帧详情，每行一个 JSON 对象，type 字段区分行类型。

### type=session（第一行，session header）

```json
{"type":"session","sessionId":"abc123","startTimestampMs":1776678700000}
```

### type=frame（帧数据行）

```json
{
  "type": "frame",
  "events": [
    {"eventType":"frame_start","timestampMs":1776678700100,"frameId":1},
    {"eventType":"composable_recomposed","timestampMs":1776678700110,"composableName":"CounterSection","sourceLocation":"CounterSection.kt:221","durationMs":2,"reason":"STATE_CHANGE","triggerStates":["count@StateImpl"],"scopeKey":12345678,"paramChanges":{"totalParams":2,"changedParams":[1],"unknownParams":[]}},
    {"eventType":"frame_end","timestampMs":1776678700115,"frameId":1,"durationMs":15,"recomposedCount":1}
  ]
}
```

#### composable_recomposed 事件字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `composableName` | String | 组件名 |
| `sourceLocation` | String? | 源码位置 |
| `durationMs` | Long | 本次重组耗时（ms） |
| `reason` | String | `STATE_CHANGE` 或 `UNKNOWN` |
| `triggerStates` | Array\<String\> | 触发重组的 State 标识符列表 |
| `scopeKey` | Int? | RecomposeScope 的 hashCode，null 表示首次组合 |
| `paramChanges` | Object? | 参数变化摘要 |
| `parentName` | String? | 父组件名 |

#### paramChanges 字段

| 字段 | 说明 |
|------|------|
| `totalParams` | 总参数数量 |
| `changedParams` | 发生变化的参数索引列表（如 `[1,2]` 表示第 1、2 个参数变化） |
| `unknownParams` | 无法确定是否变化的参数索引列表 |

### type=touch_context（触摸上下文事件行）

```json
{"type":"touch_context","eventType":"touchBegin","timestampMs":1776678700583,"pointerCount":1}
```

| 字段 | 说明 |
|------|------|
| `eventType` | `touchBegin` / `touchEnd`（Press/Release） |
| `timestampMs` | 时间戳 |
| `pointerCount` | 同时触摸的手指数 |

### type=scroll_context（滚动上下文事件行）

```json
{"type":"scroll_context","listId":"list_123456","firstVisibleItemFrom":3,"firstVisibleItemTo":5,"visibleItemCount":7,"timestampMs":1776678700650}
```

| 字段 | 说明 |
|------|------|
| `listId` | 列表标识符，格式 `list_<hashCode>`（LazyList）/ `grid_<hashCode>`（LazyGrid）/ `pager_<hashCode>`（Pager） |
| `firstVisibleItemFrom` | 变化前的 firstVisibleItemIndex |
| `firstVisibleItemTo` | 变化后的 firstVisibleItemIndex |
| `visibleItemCount` | 当前可见 item 数量 |

> **注意**：`touch_context` / `scroll_context` 行与 `frame` 行穿插，读取时按 `type` 字段过滤。旧版 skill 会忽略未知 type，向后兼容。
