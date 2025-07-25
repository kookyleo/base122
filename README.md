# Base122 Encoding Library

一个高性能的 Base122 编码/解码 Rust 库。

## 特性

- **高效编码**: 使用 122 个安全 ASCII 字符进行编码
- **安全传输**: 排除了 6 个在文本、网页、URI 传输中有风险的字符：`"`, `'`, `\`, `&`, `\n`, `\r`
- **二进制数据保护**: 正确处理前导零和所有字节值
- **高性能**: 使用 BigInt 算法实现最优性能
- **完整测试**: 包含全面的测试用例和性能基准测试

## 安装

将以下内容添加到您的 `Cargo.toml`:

```toml
[dependencies]
base122 = "0.1.0"
```

## 使用方法

### 基本编码/解码

```rust
use base122::{encode, decode};

fn main() {
    let data = b"Hello, World!";
    
    // 编码
    let encoded = encode(data);
    println!("编码结果: {}", encoded);
    
    // 解码
    let decoded = decode(&encoded).unwrap();
    assert_eq!(decoded, data);
    println!("解码成功!");
}
```

### 处理二进制数据

```rust
use base122::{encode, decode};

fn main() {
    // 处理任意二进制数据
    let binary_data: Vec<u8> = (0..256).collect();
    let encoded = encode(&binary_data);
    let decoded = decode(&encoded).unwrap();
    assert_eq!(decoded, binary_data);
}
```

## 命令行工具

本库还提供了一个命令行演示工具：

```bash
# 编码文本
cargo run --bin base122-demo encode "Hello, World!"

# 解码文本
cargo run --bin base122-demo decode "<encoded_string>"

# 运行演示
cargo run --bin base122-demo demo
```

## 测试

运行所有测试：

```bash
cargo test
```

运行性能测试（带输出）：

```bash
cargo test -- --nocapture
```

## 算法说明

Base122 使用 122 个可打印的 ASCII 字符进行编码：

- 数字：0-9 (10个字符)
- 大写字母：A-Z (26个字符)  
- 小写字母：a-z (26个字符)
- 安全标点符号：60个字符（排除危险字符后）

编码过程：
1. 在输入数据前添加标记字节以保护前导零
2. 将字节数据转换为大整数（base 256）
3. 将大整数转换为 base 122 表示
4. 使用字符集映射每个数字到对应字符

解码过程是编码的逆过程。

## 性能

在现代硬件上，该库能够：
- 处理大容量数据（测试了 1KB+ 数据）
- 保持合理的编码开销比率
- 提供快速的编码/解码操作

## 安全性

本库排除了以下 6 个"危险字符"以确保在各种环境中安全传输：

- `"` (双引号, 0x22)
- `'` (单引号, 0x27) 
- `\` (反斜杠, 0x5C)
- `&` (和号, 0x26)
- `\n` (换行符, 0x0A)
- `\r` (回车符, 0x0D)

## 许可证

MIT 许可证

## 贡献

欢迎提交 issue 和 pull request！