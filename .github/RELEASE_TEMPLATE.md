# Release Template

## 版本发布步骤

1. **更新版本号**
   ```bash
   # 在 Cargo.toml 中更新版本号
   sed -i 's/version = "0.1.0"/version = "0.1.1"/' Cargo.toml
   ```

2. **运行测试**
   ```bash
   cargo test
   cargo clippy
   cargo fmt --check
   ```

3. **提交更改**
   ```bash
   git add Cargo.toml
   git commit -m "chore: bump version to 0.1.1"
   ```

4. **创建标签**
   ```bash
   git tag v0.1.1
   git push origin v0.1.1
   ```

5. **GitHub Actions 自动发布**
   - 推送标签后，GitHub Actions 会自动：
     - 运行所有测试
     - 验证版本号匹配
     - 发布到 crates.io
     - 创建 GitHub Release

## 发布检查清单

- [ ] 版本号已在 Cargo.toml 中更新
- [ ] 所有测试通过 (`cargo test`)
- [ ] 代码格式正确 (`cargo fmt --check`)
- [ ] Clippy 检查通过 (`cargo clippy`)
- [ ] 文档构建成功 (`cargo doc`)
- [ ] 示例可正常运行 (`cargo run --example demo`)
- [ ] CHANGELOG.md 已更新 (如果有)
- [ ] 标签格式正确 (v0.1.1)

## 版本号规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

- **MAJOR**: 不兼容的 API 修改
- **MINOR**: 向下兼容的功能性新增
- **PATCH**: 向下兼容的问题修正

示例：
- `v1.0.0` - 首个稳定版本
- `v1.1.0` - 新增功能
- `v1.1.1` - Bug 修复