#!/bin/bash

# 测试更新机制
# 此脚本用于测试自动更新流程是否正常工作

echo "=========================================="
echo "测试 Kuikly UI Skill 自动更新机制"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "步骤 1: 检查更新状态"
echo "----------------------------------------"
cd "$SCRIPT_DIR"
bash check-update.sh
CHECK_RESULT=$?

echo ""
echo "检查结果: 退出码 $CHECK_RESULT"

if [ $CHECK_RESULT -eq 1 ]; then
    echo "→ 需要更新"
    echo ""
    echo "步骤 2: 执行更新"
    echo "----------------------------------------"
    bash update-repository.sh
    UPDATE_RESULT=$?
    
    echo ""
    if [ $UPDATE_RESULT -eq 0 ]; then
        echo "✓ 更新成功！"
    else
        echo "✗ 更新失败，退出码: $UPDATE_RESULT"
    fi
else
    echo "→ 无需更新"
fi

echo ""
echo "步骤 3: 验证仓库状态"
echo "----------------------------------------"

REPO_DIR="$SCRIPT_DIR/references/KuiklyUI"

if [ -d "$REPO_DIR/.git" ]; then
    echo "✓ 仓库存在"
    cd "$REPO_DIR"
    
    LATEST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%cd)" --date=short)
    echo "  最新提交: $LATEST_COMMIT"
    
    DOCS_COUNT=$(find docs -name "*.md" 2>/dev/null | wc -l | xargs)
    echo "  文档数量: $DOCS_COUNT 个"
    
    if [ -f "core/src/commonMain/kotlin/com/tencent/kuikly/core/base/Attr.kt" ]; then
        echo "✓ 核心源码文件存在"
    else
        echo "✗ 核心源码文件缺失"
    fi
else
    echo "✗ 仓库不存在"
fi

echo ""
echo "步骤 4: 检查更新记录"
echo "----------------------------------------"

UPDATE_LOG="$SCRIPT_DIR/.last-update"
if [ -f "$UPDATE_LOG" ]; then
    LAST_UPDATE=$(cat "$UPDATE_LOG")
    echo "✓ 更新记录存在"
    echo "  上次更新: $LAST_UPDATE"
else
    echo "✗ 更新记录不存在"
fi

echo ""
echo "=========================================="
echo "测试完成！"
echo "=========================================="
