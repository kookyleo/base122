# Base122 Encoding Library

[![Crates.io](https://img.shields.io/crates/v/base122-rs.svg)](https://crates.io/crates/base122-rs)
[![Documentation](https://docs.rs/base122-rs/badge.svg)](https://docs.rs/base122-rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance Base122 encoding/decoding library for Rust, based on the original [kevinAlbs Base122 algorithm](https://github.com/kevinAlbs/Base122).

Base122 is a binary-to-text encoding that is approximately **14% more space-efficient than Base64**, making it ideal for data URIs and other space-constrained applications.

## Features

- 🚀 **High Performance**: Bitwise operations for maximum efficiency
- 📦 **Zero Dependencies**: Pure Rust implementation
- 🛡️ **Memory Safe**: No unsafe code
- 🎯 **Space Efficient**: ~87% compression efficiency vs ~75% for Base64
- 🔧 **Easy to Use**: Simple encode/decode API
- 📚 **Well Documented**: Comprehensive documentation and examples

## Algorithm Overview

Base122 uses a sophisticated bitwise approach:

1. **7-bit Extraction**: Extracts exactly 7 bits at a time from input data
2. **Smart Character Mapping**: Safe characters map directly to single bytes
3. **UTF-8 Encoding**: "Dangerous characters" use multi-byte UTF-8 sequences
4. **Optimal Efficiency**: Achieves ~87% compression efficiency

### Dangerous Characters

Six characters are considered "dangerous" for transmission and are specially encoded:

- `\0` (null) - can truncate strings
- `\n` (newline) - breaks single-line formats  
- `\r` (carriage return) - breaks single-line formats
- `"` (double quote) - conflicts with JSON/HTML attributes
- `&` (ampersand) - conflicts with HTML entities
- `\` (backslash) - conflicts with escape sequences

## Quick Start

Add this to your `Cargo.toml`:

```toml
[dependencies]
base122-rs = "0.1"
```

## Usage

### Basic Example

```rust
use base122_rs::{encode, decode};

// Encode binary data
let data = b"Hello, World!";
let encoded = encode(data);
println!("Encoded: {}", encoded);

// Decode back to original
let decoded = decode(&encoded).unwrap();
assert_eq!(data, &decoded[..]);
```

### Working with Binary Data

```rust
use base122_rs::{encode, decode};

// Binary data with dangerous characters
let binary_data = vec![0, 10, 13, 34, 38, 92, 65, 66, 67];
let encoded = encode(&binary_data);
let decoded = decode(&encoded).unwrap();
assert_eq!(binary_data, decoded);
```

### Command Line Usage

Build and run the demo:

```bash
cargo build --example demo
cargo run --example demo -- encode "Hello, World!"
cargo run --example demo -- decode "$(cargo run --example demo -- encode 'Hello, World!')"
```

## Performance

### Efficiency Comparison

| Encoding | Expansion Ratio | Efficiency | Use Case |
|----------|----------------|------------|----------|
| Hexadecimal | 2.00x | 50% | Debug output |
| Base64 | 1.33x | 75% | Email, HTTP |
| **Base122** | **1.14x** | **87%** | **Data URIs, Space-constrained** |

### Benchmark Results

```
Size       Encoded      Ratio    Efficiency    vs Base64
--------------------------------------------------------
10         12          1.200     83.3%        +16.7%
100        115         1.150     87.0%        +13.8%
1000       1143        1.143     87.5%        +14.3%
10000      11429       1.143     87.5%        +14.3%
```

## When to Use Base122

**✅ Ideal for:**
- Data URIs in HTML/CSS
- Space-constrained applications
- Binary data transmission
- JSON payloads with binary content
- Text protocols with size limits

**❌ Consider alternatives for:**
- Systems requiring Base64 compatibility
- Environments without UTF-8 support
- Cases where simplicity trumps efficiency

## Examples

### Data URI Optimization

```rust
use base122_rs::encode;

// Image data for CSS/HTML
let image_data = std::fs::read("image.png").unwrap();
let base122_uri = format!("data:image/png;base122,{}", encode(&image_data));

// ~14% smaller than equivalent Base64 data URI
```

### Binary Protocol

```rust
use base122_rs::{encode, decode};

// Encode binary protocol message
let message = vec![0x01, 0x02, 0x03, 0x04];
let encoded = encode(&message);

// Send over text-based protocol
send_message(&encoded);

// Decode on receiver
let received = receive_message();
let decoded = decode(&received).unwrap();
```

## Error Handling

The `decode` function returns a `Result<Vec<u8>, String>`:

```rust
use base122_rs::decode;

match decode("invalid input") {
    Ok(data) => println!("Decoded: {:?}", data),
    Err(e) => eprintln!("Decode error: {}", e),
}
```

## Testing

Run all tests:

```bash
cargo test
```

Run with output for detailed benchmarks:

```bash
cargo test -- --nocapture
```

Run the example:

```bash
cargo run --example demo benchmark
```

## Documentation

- [API Documentation](https://docs.rs/base122-rs)
- [Algorithm Details](https://github.com/kevinAlbs/Base122)
- Run `cargo doc --open` for local documentation

## Development

### Release Management

This project includes automated release scripts for easy version management:

**📋 Full Release Process:**
```bash
./release.sh
```
- Interactive guided release with comprehensive checks
- Runs full test suite, format checks, and documentation build
- Updates version, creates commits and tags
- Triggers automated publishing to crates.io

**⚡ Quick Patch Release:**
```bash
./quick-release.sh
```
- Auto-increments patch version (0.1.0 → 0.1.1)
- Runs basic checks only
- Fast release for bug fixes

**🤖 Automated Publishing:**
- GitHub Actions automatically publishes to crates.io when version tags are pushed
- Creates GitHub releases with detailed changelogs
- Runs comprehensive CI across multiple platforms and Rust versions

### Manual Release Steps
1. Update version in `Cargo.toml`
2. Commit changes: `git commit -m "chore: bump version to x.y.z"`
3. Create tag: `git tag vx.y.z`
4. Push tag: `git push origin vx.y.z`
5. GitHub Actions handles the rest!

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on the original [Base122 algorithm](https://github.com/kevinAlbs/Base122) by Kevin Albertson
- Inspired by the need for more efficient binary-to-text encoding
- Thanks to the Rust community for excellent tooling and libraries

## Languages

- [English](README.md)
- [中文](README.zh.md)

## See Also

- [Base64](https://docs.rs/base64) - Standard Base64 encoding
- [Hex](https://docs.rs/hex) - Hexadecimal encoding
- [Original Base122 JavaScript implementation](https://github.com/kevinAlbs/Base122)