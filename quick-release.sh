#!/bin/bash

# 快速发布脚本 - 用于补丁版本快速发布

set -e

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}🔧 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# 获取当前版本并自动递增补丁版本
current_version=$(grep -E '^version = ' Cargo.toml | sed 's/version = "\([^"]*\)"/\1/')
IFS='.' read -ra VERSION_PARTS <<< "$current_version"
major=${VERSION_PARTS[0]}
minor=${VERSION_PARTS[1]}
patch=${VERSION_PARTS[2]}

new_patch=$((patch + 1))
new_version="$major.$minor.$new_patch"

echo "🚀 快速发布: $current_version → $new_version"
echo ""

# 快速检查
print_info "运行快速检查..."

# 检查代码格式
print_info "检查代码格式..."
if ! cargo fmt --all --check; then
    print_error "代码格式不正确，请运行 'cargo fmt --all' 修复后重试"
    exit 1
fi

# 运行测试
if ! cargo test --lib --quiet; then
    print_error "测试失败"
    exit 1
fi

# 严格Clippy检查
if ! cargo clippy --all-targets --all-features -- -D warnings; then
    print_error "Clippy检查失败，请修复以上问题"
    exit 1
fi

print_success "检查通过"

# 确认
read -p "确认快速发布 v$new_version? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "取消发布"
    exit 0
fi

# 更新版本
print_info "更新版本..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
else
    sed -i "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
fi

# 提交并推送标签
print_info "提交并创建标签..."
git add Cargo.toml
git commit -m "chore: bump version to $new_version"
git tag "v$new_version"
git push origin "v$new_version"

print_success "v$new_version 发布流程已启动!"
echo "📊 查看进度: https://github.com/kookyleo/base122/actions"