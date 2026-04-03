#!/bin/bash

# 检查是否需要更新 KuiklyUI 仓库
# 如果距离上次更新超过 7 天，则返回退出码 1（需要更新）
# 否则返回退出码 0（不需要更新）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_LOG="$SCRIPT_DIR/.last-update"
UPDATE_INTERVAL_DAYS=7

# 如果从未更新过，需要更新
if [ ! -f "$UPDATE_LOG" ]; then
    echo "需要更新：从未更新过"
    exit 1
fi

# 读取上次更新时间
LAST_UPDATE=$(cat "$UPDATE_LOG")
LAST_UPDATE_TIMESTAMP=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_UPDATE" "+%s" 2>/dev/null || echo "0")

# 获取当前时间
CURRENT_TIMESTAMP=$(date "+%s")

# 计算时间差（秒）
TIME_DIFF=$((CURRENT_TIMESTAMP - LAST_UPDATE_TIMESTAMP))

# 转换为天数
DAYS_DIFF=$((TIME_DIFF / 86400))

if [ $DAYS_DIFF -ge $UPDATE_INTERVAL_DAYS ]; then
    echo "需要更新：距离上次更新已 $DAYS_DIFF 天（超过 $UPDATE_INTERVAL_DAYS 天）"
    echo "上次更新时间：$LAST_UPDATE"
    exit 1
else
    echo "无需更新：距离上次更新仅 $DAYS_DIFF 天"
    echo "上次更新时间：$LAST_UPDATE"
    exit 0
fi
