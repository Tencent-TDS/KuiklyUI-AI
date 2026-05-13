# 报告模板

生成文件名：`recomp-analysis-YYYYMMDD-HHmm.md`

---

```markdown
# Recomposition 分析报告

**生成时间**：YYYY-MM-DD HH:mm  
**Session ID**：{sessionId}  
**分析工具**：kuikly-recomposition-analyzer

---

## 数据概览

| 指标 | 值 |
|------|----|
| 采集时长 | {sessionDuration}ms |
| 总帧数 | {totalFrames} |
| 总重组次数 | {totalRecompositions} |
| 分析组件数 | {composables.length} |
| 慢帧（>{frameDurationThreshold}ms） | {slowFrameCount} 帧 |
| 热点帧（>{frameEventThreshold}事件） | {hotFrameCount} 帧 |
| 发现问题数 | {issues.length} |

> ⚠️ **数据量告警**（如有）：总帧数 {totalFrames} < {minFramesThreshold}，建议采集至少 30 秒的数据以获得更准确的分析。

---

## 正常重组清单

以下组件的重组行为属于预期行为，无需优化：

| 组件 | 重组次数 | 归因 |
|------|----------|------|
| {name} | {count} | 列表滑动时的首次渲染 |
| {name} | {count} | 滚动进入视口，item 首次出现（scroll_context 确认） |
| ... | | |

---

## 问题诊断

> 按严重度降序排列（单次耗时 × 重组频率）

### 🔴 [高] {ComponentName}

**源码位置**：`{sourceLocation}`  
**重组次数**：{recompositionCount} 次，同一 scope 最多被触发 {maxScopeCount} 次  
**平均单次耗时**：{avgDurationMs}ms（最大 {maxDurationMs}ms）

**问题描述**：
{用用户能理解的语言描述问题。例如：「每次列表滚动，该组件都会因为坐标 State 更新而重新渲染，且同时带动 X 个关联组件一起重渲染。」不要出现 RULE-A/B/C/SCOPE 等内部术语。}

**触发来源**：`{stateId}` 被 {readersCount} 个组件同时订阅

**源码片段**（如已定位）：
```kotlin
// {sourceLocation}
{相关代码片段}
```

**优化建议**：
{具体优化方案，用代码示例说明，引用 optimization-patterns.md}

---

### 🟡 [中] {ComponentName}

**源码位置**：`{sourceLocation}`  
**重组次数**：{recompositionCount} 次  
**平均单次耗时**：{avgDurationMs}ms

**问题描述**：
{用用户能理解的语言描述问题。}

**优化建议**：
{具体优化方案}

---

### 🟢 [低] {ComponentName}

...

---

## 帧级卡顿

> 仅列出耗时超过 {frameDurationThreshold}ms 或单帧事件数超过 {frameEventThreshold} 的帧

### 正常渲染帧（无需优化）

| 帧 ID | 耗时 | 事件数 | 归因 |
|-------|------|--------|------|
| {frameId} | {durationMs}ms | {eventCount} | 例：列表滑入时 N 个 item 首次渲染（noScope 占比 >90%） |

### 问题帧分析

#### 帧 {frameId}（{durationMs}ms，{eventCount} 个事件）

**耗时最高的组件**：

| 组件 | 单次耗时 | 触发 State |
|------|----------|-----------|
| {componentName} | {durationMs}ms | {stateId} |

**根因分析**：
{分析该帧为什么耗时高。是级联重组（多个组件被同一 State 触发）？还是单个组件本身耗时长？State 是在什么时机写入的？}

**优化建议**：
{具体方向。若根因不明，说明需要补充什么信息才能进一步排查。}

---

## 优先级建议

| 优先级 | 问题 | 预期收益 |
|--------|------|----------|
| P0 🔴 | {问题简述} | {修复后可消除 N 次/帧 无效重组} |
| P1 🟡 | {问题简述} | {预期收益} |

---

## 过滤配置声明

本次分析使用以下配置：

| 配置项 | 值 |
|--------|-----|
| scopeCountThreshold | {value} |
| durationThreshold | {value}ms |
| frameEventThreshold | {value} |
| frameDurationThreshold | {value}ms |
| paramChangeRateThreshold | {value} |
| stateReadersThreshold | {value} |
| minFramesThreshold | {value} |

**排除组件**：{filteredNames.join(", ")}（如无则填"无"）  
**排除前缀**：{filteredPrefixes.join(", ")}（如无则填"无"）
```
