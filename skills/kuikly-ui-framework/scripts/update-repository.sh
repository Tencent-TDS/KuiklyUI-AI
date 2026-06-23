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

is_git_repo() {
    git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

clone_repo() {
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
}

# 检查是否已存在仓库。不要只判断 .git 目录：worktree / 打包后的仓库里
# .git 可能是一个文件，旧判断会误走 clone 分支并在非空目录上失败。
if [ -d "$REPO_DIR" ] && is_git_repo; then
    echo "✓ 检测到现有仓库，开始更新..."
    cd "$REPO_DIR"
    
    # 获取远程更新
    echo "→ 获取远程更新..."
    git fetch origin
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠ 警告：检测到本地修改，将暂存这些更改"
        git stash save "Auto-stash before update $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    # 拉取最新代码。优先使用当前分支 upstream；worktree/local 分支没有
    # upstream 时，切到 origin 的默认分支，避免误拉一个不存在的同名远端分支。
    UPSTREAM_REF=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)
    if [ -n "$UPSTREAM_REF" ]; then
        echo "→ 拉取最新代码..."
        git pull --ff-only || {
            echo "❌ 拉取失败，重置到 $UPSTREAM_REF..."
            git reset --hard "$UPSTREAM_REF"
        }
    else
        DEFAULT_BRANCH=$(git remote show origin | sed -n 's/.*HEAD branch: //p' | head -n 1)
        if [ -z "$DEFAULT_BRANCH" ]; then
            DEFAULT_BRANCH="main"
        fi
        echo "→ 未发现 upstream，切换到 origin/$DEFAULT_BRANCH..."
        git checkout -B "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"
    fi
    
    # 获取最新的提交信息
    LATEST_COMMIT=$(git log -1 --pretty=format:"%h - %s (%cd)" --date=short)
    echo ""
    echo "✓ 更新成功！"
    echo "  最新提交: $LATEST_COMMIT"
    
else
    if [ -e "$REPO_DIR" ] && [ -n "$(find "$REPO_DIR" -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
        BROKEN_DIR="$REPO_DIR.broken-$(date '+%Y%m%d-%H%M%S')"
        echo "⚠ 目标目录已存在但不是可更新的 Git 仓库: $REPO_DIR"
        echo "→ 移动到备份目录: $BROKEN_DIR"
        mv "$REPO_DIR" "$BROKEN_DIR"
    fi

    clone_repo
fi

# 记录更新时间
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "$CURRENT_DATE" > "$UPDATE_LOG"

echo ""
echo "=========================================="
echo "✓ 更新完成！更新时间: $CURRENT_DATE"
echo "=========================================="

exit 0
