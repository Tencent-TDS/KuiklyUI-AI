#!/bin/bash

# KuiklyUI 仓库自动更新脚本
# 用于定期从 GitHub 拉取最新的 KuiklyUI 框架代码

set -e  # 遇到错误立即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_DIR="$SKILL_DIR/references/KuiklyUI"
REPO_URL="https://github.com/Tencent-TDS/KuiklyUI.git"
UPDATE_LOG="$SCRIPT_DIR/.last-update"

echo "=========================================="
echo "KuiklyUI 仓库更新脚本"
echo "=========================================="
echo ""

# 检查是否已存在仓库
if [ -d "$REPO_DIR/.git" ]; then
    echo "✓ 检测到现有仓库，开始更新..."
    cd "$REPO_DIR"
    
    # 保存当前分支
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")
    
    # 获取远程更新
    echo "→ 获取远程更新..."
    git fetch origin
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠ 警告：检测到本地修改，将暂存这些更改"
        git stash save "Auto-stash before update $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    # 拉取最新代码
    echo "→ 拉取最新代码..."
    git pull origin "$CURRENT_BRANCH" || {
        echo "❌ 拉取失败，尝试重置到远程分支..."
        git reset --hard "origin/$CURRENT_BRANCH"
    }
    
    # 获取最新的提交信息
    LATEST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%cd)" --date=short)
    echo ""
    echo "✓ 更新成功！"
    echo "  最新提交: $LATEST_COMMIT"
    
else
    echo "✓ 首次运行，开始克隆仓库..."
    
    # 确保父目录存在
    mkdir -p "$(dirname "$REPO_DIR")"
    
    # 克隆仓库
    echo "→ 克隆仓库: $REPO_URL"
    git clone "$REPO_URL" "$REPO_DIR"
    
    cd "$REPO_DIR"
    
    # 获取提交信息
    LATEST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%cd)" --date=short)
    echo ""
    echo "✓ 克隆成功！"
    echo "  最新提交: $LATEST_COMMIT"
fi

# 记录更新时间
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "$CURRENT_DATE" > "$UPDATE_LOG"

echo ""
echo "=========================================="
echo "✓ 更新完成！更新时间: $CURRENT_DATE"
echo "=========================================="

exit 0
