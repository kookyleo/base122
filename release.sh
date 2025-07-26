#!/bin/bash

# Base122 Release Script
# 自动化版本发布流程

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 图标
CHECK="✅"
CROSS="❌"
ROCKET="🚀"
GEAR="⚙️"
PACKAGE="📦"
TAG="🏷️"
PUSH="⬆️"

# 打印带颜色的消息
print_step() {
    echo -e "${BLUE}${GEAR} $1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${WHITE}"
    echo "=================================================="
    echo "  ${ROCKET} Base122 Release Manager ${ROCKET}"
    echo "=================================================="
    echo -e "${NC}"
}

# 检查是否在git仓库中
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "当前目录不是Git仓库"
        exit 1
    fi
}

# 检查工作目录是否干净
check_clean_working_dir() {
    if ! git diff-index --quiet HEAD --; then
        print_error "工作目录有未提交的更改，请先提交或暂存"
        git status --short
        exit 1
    fi
}

# 检查是否在master分支
check_master_branch() {
    current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "master" && "$current_branch" != "main" ]]; then
        print_warning "当前不在master/main分支 (当前: $current_branch)"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "发布已取消"
            exit 0
        fi
    fi
}

# 获取当前版本
get_current_version() {
    grep -E '^version = ' Cargo.toml | sed 's/version = "\([^"]*\)"/\1/'
}

# 验证版本号格式
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "无效的版本号格式: $version (应为 x.y.z)"
        return 1
    fi
    return 0
}

# 比较版本号
version_gt() {
    test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

# 运行预发布检查
run_pre_release_checks() {
    print_step "运行预发布检查..."
    
    echo "📋 运行测试..."
    if ! cargo test --quiet; then
        print_error "测试失败"
        exit 1
    fi
    print_success "所有测试通过"
    
    echo "🔍 检查代码格式..."
    if ! cargo fmt --all --check; then
        print_error "代码格式不正确，运行 'cargo fmt --all' 修复后重试"
        exit 1
    fi
    print_success "代码格式检查通过"
    
    echo "🔧 运行Clippy检查..."
    if ! cargo clippy --all-targets --all-features -- -D warnings; then
        print_error "Clippy检查失败，请修复以上问题"
        exit 1
    fi
    print_success "Clippy检查通过"
    
    echo "📚 检查文档构建..."
    if ! cargo doc --no-deps --quiet > /dev/null 2>&1; then
        print_error "文档构建失败"
        exit 1
    fi
    print_success "文档构建成功"
    
    echo "🔗 测试示例..."
    if ! cargo build --examples --quiet; then
        print_error "示例构建失败"
        exit 1
    fi
    print_success "示例构建成功"
    
    print_success "所有预发布检查通过"
}

# 显示发布预览
show_release_preview() {
    local current_version=$1
    local new_version=$2
    
    echo -e "${WHITE}"
    echo "=========================================="
    echo "           📋 发布预览"
    echo "=========================================="
    echo -e "${NC}"
    echo "📦 包名: base122-rs"
    echo "🔄 版本: $current_version → $new_version"
    echo "🏷️  标签: v$new_version"
    echo "🌐 仓库: https://github.com/kookyleo/base122"
    echo "📦 Crates.io: https://crates.io/crates/base122-rs"
    echo ""
    echo "🚀 发布步骤:"
    echo "  1. 更新 Cargo.toml 版本号"
    echo "  2. 提交版本更改"
    echo "  3. 创建并推送 Git 标签"
    echo "  4. GitHub Actions 自动:"
    echo "     - 运行完整测试套件"
    echo "     - 发布到 crates.io"
    echo "     - 创建 GitHub Release"
    echo ""
}

# 更新版本号
update_version() {
    local new_version=$1
    print_step "更新 Cargo.toml 中的版本号到 $new_version..."
    
    # 使用 sed 替换版本号
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
    else
        # Linux
        sed -i "s/^version = \".*\"/version = \"$new_version\"/" Cargo.toml
    fi
    
    print_success "版本号已更新"
}

# 提交更改
commit_version_bump() {
    local new_version=$1
    print_step "提交版本更改..."
    
    git add Cargo.toml
    git commit -m "chore: bump version to $new_version

🚀 准备发布 v$new_version

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    print_success "版本更改已提交"
}

# 创建并推送标签
create_and_push_tag() {
    local new_version=$1
    local tag="v$new_version"
    
    print_step "创建 Git 标签 $tag..."
    git tag -a "$tag" -m "Release $tag

🎉 Base122-rs $new_version 发布

## 特性
- 高性能 Base122 编码/解码
- ~87% 压缩效率
- 零依赖纯 Rust 实现
- UTF-8 安全输出

## 安装
\`\`\`toml
[dependencies]
base122-rs = \"$new_version\"
\`\`\`

🤖 Generated with [Claude Code](https://claude.ai/code)"
    
    print_success "Git 标签已创建"
    
    print_step "推送标签到远程仓库..."
    git push origin "$tag"
    print_success "标签已推送，GitHub Actions 将开始自动发布流程"
}

# 显示发布后信息
show_post_release_info() {
    local new_version=$1
    
    echo -e "${WHITE}"
    echo "=========================================="
    echo "        🎉 发布流程已启动!"
    echo "=========================================="
    echo -e "${NC}"
    echo ""
    echo "🔄 下一步将自动进行:"
    echo ""
    echo "1. ${GEAR} GitHub Actions 运行测试"
    echo "2. ${PACKAGE} 自动发布到 crates.io"
    echo "3. ${TAG} 创建 GitHub Release"
    echo ""
    echo "📊 监控发布进度:"
    echo "   GitHub Actions: https://github.com/kookyleo/base122/actions"
    echo ""
    echo "📦 发布完成后可在以下位置找到:"
    echo "   Crates.io: https://crates.io/crates/base122-rs"
    echo "   GitHub: https://github.com/kookyleo/base122/releases"
    echo ""
    echo "⏱️  通常需要 2-5 分钟完成整个发布流程"
    echo ""
    print_success "发布流程启动成功! 🚀"
}

# 主函数
main() {
    print_header
    
    # 基础检查
    check_git_repo
    check_clean_working_dir
    check_master_branch
    
    # 获取当前版本
    current_version=$(get_current_version)
    print_info "当前版本: $current_version"
    
    # 获取新版本号
    echo ""
    echo "请输入新版本号 (当前: $current_version):"
    echo "提示: 遵循语义化版本 (major.minor.patch)"
    echo "  - major: 不兼容的API变更"
    echo "  - minor: 向下兼容的功能新增"  
    echo "  - patch: 向下兼容的问题修正"
    echo ""
    read -p "新版本号: " new_version
    
    # 验证版本号
    if ! validate_version "$new_version"; then
        exit 1
    fi
    
    # 检查版本号是否递增
    if ! version_gt "$new_version" "$current_version"; then
        print_error "新版本号 ($new_version) 必须大于当前版本 ($current_version)"
        exit 1
    fi
    
    # 运行预发布检查
    echo ""
    run_pre_release_checks
    
    # 显示发布预览
    echo ""
    show_release_preview "$current_version" "$new_version"
    
    # 确认发布
    echo ""
    read -p "确认发布 v$new_version? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "发布已取消"
        exit 0
    fi
    
    echo ""
    print_step "开始发布流程..."
    
    # 执行发布步骤
    update_version "$new_version"
    commit_version_bump "$new_version"
    create_and_push_tag "$new_version"
    
    echo ""
    show_post_release_info "$new_version"
}

# 运行主函数
main "$@"