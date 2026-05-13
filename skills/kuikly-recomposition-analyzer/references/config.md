# Recomposition Analyzer — 可配置阈值

调用 skill 时可通过参数覆盖以下默认值。

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `scopeCountThreshold` | 5 | 某 scopeKey 重组次数超过此值 → 标记为嫌疑 |
| `durationThreshold` | 5 | 单次重组耗时超过此值（ms）→ RULE-A 嫌疑 |
| `singleRecompDurationThreshold` | 10 | 单次重组耗时超过此值（ms）→ 无论次数多少，必须输出到报告 |
| `frameEventThreshold` | 50 | 单帧 composable 事件数超过此值 → 帧级热点告警 |
| `frameDurationThreshold` | 16 | 单帧耗时超过此值（ms）→ 帧级卡顿告警 |
| `paramChangeRateThreshold` | 0.9 | 参数变化率超过此值 → RULE-C lambda 不稳定嫌疑 |
| `stateReadersThreshold` | 3 | State 的 readers 数超过此值 → RULE-B State 广播嫌疑 |
| `minFramesThreshold` | 30 | 总帧数低于此值 → 数据不足告警 |

## 用法示例

用户在请求中指定参数即可覆盖默认值：

```
重组分析，scopeCountThreshold=10，durationThreshold=8ms
```

Skill 应在报告"过滤配置声明"段中列出本次实际使用的阈值（包括用户覆盖的值）。
