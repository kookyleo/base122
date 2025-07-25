# Base122 编码库

[![Crates.io](https://img.shields.io/crates/v/base122.svg)](https://crates.io/crates/base122)
[![文档](https://docs.rs/base122/badge.svg)](https://docs.rs/base122)
[![许可证: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

一个高性能的 Base122 编码/解码 Rust 库，基于 [kevinAlbs 的原始 Base122 算法](https://github.com/kevinAlbs/Base122)。

Base122 是一种二进制到文本的编码方式，比 Base64 **节省约 14% 的空间**，非常适合用于数据 URI 和其他空间受限的应用场景。

## 特性

- 🚀 **高性能**: 基于位操作实现最高效率
- 📦 **零依赖**: 纯 Rust 实现
- 🛡️ **内存安全**: 不使用 unsafe 代码
- 🎯 **空间高效**: ~87% 压缩效率，相比 Base64 的 ~75%
- 🔧 **易于使用**: 简单的编码/解码 API
- 📚 **文档完整**: 全面的文档和示例

## 算法概述

Base122 使用精密的位级操作方法：

1. **7位提取**: 每次从输入数据中精确提取 7 位
2. **智能字符映射**: 安全字符直接映射为单字节
3. **UTF-8 编码**: "危险字符" 使用多字节 UTF-8 序列
4. **最优效率**: 实现约 87% 的压缩效率

### 危险字符

有六个字符被认为在传输中是"危险的"，需要特殊编码：

- `\0` (空字符) - 可能截断字符串
- `\n` (换行符) - 破坏单行格式  
- `\r` (回车符) - 破坏单行格式
- `"` (双引号) - 与 JSON/HTML 属性冲突
- `&` (和号) - 与 HTML 实体冲突
- `\` (反斜杠) - 与转义序列冲突

## 快速开始

在你的 `Cargo.toml` 中添加：

```toml
[dependencies]
base122 = "0.1"
```

## 使用方法

### 基本示例

```rust
use base122::{encode, decode};

// 编码二进制数据
let data = b"Hello, World!";
let encoded = encode(data);
println!("编码结果: {}", encoded);

// 解码回原始数据
let decoded = decode(&encoded).unwrap();
assert_eq!(data, &decoded[..]);
```

### 处理二进制数据

```rust
use base122::{encode, decode};

// 包含危险字符的二进制数据
let binary_data = vec![0, 10, 13, 34, 38, 92, 65, 66, 67];
let encoded = encode(&binary_data);
let decoded = decode(&encoded).unwrap();
assert_eq!(binary_data, decoded);
```

### 命令行使用

构建并运行示例：

```bash
cargo build --example demo
cargo run --example demo -- encode "Hello, World!"
cargo run --example demo -- decode "$(cargo run --example demo -- encode 'Hello, World!')"
```

## 性能表现

### 效率对比

| 编码方式 | 膨胀率 | 效率 | 使用场景 |
|----------|--------|------|----------|
| 十六进制 | 2.00x | 50% | 调试输出 |
| Base64 | 1.33x | 75% | 邮件、HTTP |
| **Base122** | **1.14x** | **87%** | **数据 URI、空间受限** |

### 基准测试结果

```
数据大小    编码字节    膨胀率    效率      vs Base64
--------------------------------------------------------
10         12          1.200     83.3%     +16.7%
100        115         1.150     87.0%     +13.8%
1000       1143        1.143     87.5%     +14.3%
10000      11429       1.143     87.5%     +14.3%
```

## 何时使用 Base122

**✅ 理想场景:**
- HTML/CSS 中的数据 URI
- 空间受限的应用
- 二进制数据传输
- 包含二进制内容的 JSON 载荷
- 有大小限制的文本协议

**❌ 考虑其他方案:**
- 需要 Base64 兼容性的系统
- 不支持 UTF-8 的环境
- 简单性比效率更重要的场景

## 应用示例

### 数据 URI 优化

```rust
use base122::encode;

// 图片数据用于 CSS/HTML
let image_data = std::fs::read("image.png").unwrap();
let base122_uri = format!("data:image/png;base122,{}", encode(&image_data));

// 比等效的 Base64 数据 URI 小约 14%
```

### 二进制协议

```rust
use base122::{encode, decode};

// 编码二进制协议消息
let message = vec![0x01, 0x02, 0x03, 0x04];
let encoded = encode(&message);

// 通过基于文本的协议发送
send_message(&encoded);

// 在接收端解码
let received = receive_message();
let decoded = decode(&received).unwrap();
```

## 错误处理

`decode` 函数返回 `Result<Vec<u8>, String>`：

```rust
use base122::decode;

match decode("无效输入") {
    Ok(data) => println!("解码成功: {:?}", data),
    Err(e) => eprintln!("解码错误: {}", e),
}
```

## 测试

运行所有测试：

```bash
cargo test
```

运行详细基准测试：

```bash
cargo test -- --nocapture
```

运行示例：

```bash
cargo run --example demo benchmark
```

## 实际应用场景

### Web 开发
```rust
// 在 CSS 中嵌入图片，比 Base64 更节省空间
let css = format!(r#"
    .logo {{
        background-image: url("data:image/png;base122,{}");
    }}
"#, encode(&logo_data));
```

### 数据传输
```rust
// JSON API 中传输二进制数据
let response = json!({
    "file_data": encode(&file_content),
    "metadata": file_info
});
```

### 协议设计
```rust
// 文本协议中传输二进制载荷
let packet = format!("DATA:{}", encode(&binary_payload));
```

## 性能特点

- **编码速度**: 对于 1KB 数据约 240µs
- **解码速度**: 对于 1KB 数据约 146µs  
- **内存使用**: O(n) 其中 n 是输入大小
- **线程安全**: 所有函数都是线程安全的

## 与其他编码的详细对比

### 空间效率
- **vs Base64**: 节省 14.3% 空间
- **vs Hex**: 节省 43% 空间
- **vs Base85**: 节省约 10% 空间

### 兼容性
- **UTF-8**: 完全兼容
- **JSON**: 可直接用作字符串值
- **URL**: 可能需要 URL 编码（包含特殊字符）
- **HTML**: 可直接用于属性值

## 技术细节

### 位级操作
Base122 通过精确的位操作实现高效率：
1. 按 7 位边界分割输入数据
2. 将危险字符编码为 UTF-8 双字节序列
3. 使用累加器模式重建字节流

### 危险字符处理
危险字符使用 UTF-8 格式 `110xxxxx 10yyyyyy` 编码，同时包含下一个 7 位数据块，实现信息密度最大化。

## 文档

- [API 文档](https://docs.rs/base122)
- [算法详情](https://github.com/kevinAlbs/Base122)
- 运行 `cargo doc --open` 查看本地文档

## 贡献

欢迎贡献！请随时提交 Pull Request。

## 许可证

本项目使用 MIT 许可证 - 详情请参阅 [LICENSE](LICENSE) 文件。

## 致谢

- 基于 Kevin Albertson 的原始 [Base122 算法](https://github.com/kevinAlbs/Base122)
- 感谢对更高效二进制到文本编码需求的启发
- 感谢 Rust 社区提供的优秀工具和库

## 多语言版本

- [English](README.md)
- [中文](README.zh.md)

## 相关项目

- [Base64](https://docs.rs/base64) - 标准 Base64 编码
- [Hex](https://docs.rs/hex) - 十六进制编码
- [原始 Base122 JavaScript 实现](https://github.com/kevinAlbs/Base122)

## 常见问题

### Q: Base122 与 Base64 的主要区别是什么？
A: Base122 使用更多字符（122 vs 64），实现更高的信息密度，比 Base64 节省约 14% 空间。

### Q: 是否可以在所有环境中安全使用？
A: Base122 产生有效的 UTF-8 输出，但包含一些特殊字符。在需要 URL 安全或严格 ASCII 的环境中可能需要额外编码。

### Q: 性能如何？
A: Base122 的编码/解码速度与 Base64 相当，但提供更好的空间效率。

### Q: 何时不应该使用 Base122？
A: 如果你需要与现有 Base64 系统兼容，或者在不支持 UTF-8 的环境中使用。