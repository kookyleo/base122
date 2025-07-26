//! Base122 Encoding/Decoding Demo
//!
//! This example demonstrates the usage of the Base122 encoding library,
//! showing encoding/decoding operations and efficiency comparisons.

use base122_rs::{decode, encode};
use std::env;
use std::io::{self, Read, Write};

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        print_usage();
        return;
    }

    match args[1].as_str() {
        "encode" => {
            if args.len() > 2 {
                let input = args[2].as_bytes();
                println!("{}", encode(input));
            } else {
                let mut buffer = Vec::new();
                io::stdin().read_to_end(&mut buffer).unwrap();
                println!("{}", encode(&buffer));
            }
        }
        "decode" => {
            if args.len() > 2 {
                match decode(&args[2]) {
                    Ok(data) => {
                        io::stdout().write_all(&data).unwrap();
                    }
                    Err(e) => {
                        eprintln!("Decode error: {e}");
                        std::process::exit(1);
                    }
                }
            } else {
                let mut input = String::new();
                io::stdin().read_to_string(&mut input).unwrap();
                let input = input.trim();
                match decode(input) {
                    Ok(data) => {
                        io::stdout().write_all(&data).unwrap();
                    }
                    Err(e) => {
                        eprintln!("Decode error: {e}");
                        std::process::exit(1);
                    }
                }
            }
        }
        "demo" => run_demo(),
        "benchmark" => run_benchmark(),
        _ => print_usage(),
    }
}

fn print_usage() {
    let program = env::args().next().unwrap_or_else(|| "demo".to_string());
    println!("Base122 Encoding/Decoding Demo");
    println!();
    println!("USAGE:");
    println!("  {program} encode [TEXT]     Encode text (or read from stdin)");
    println!("  {program} decode [ENCODED]  Decode text (or read from stdin)");
    println!("  {program} demo              Run demonstration with examples");
    println!("  {program} benchmark         Run performance benchmarks");
    println!();
    println!("EXAMPLES:");
    println!("  {program} encode \"Hello, World!\"");
    println!("  {program} decode \"$(echo 'Hello' | {program} encode)\"");
    println!("  echo 'Test data' | {program} encode | {program} decode");
}

fn run_demo() {
    println!("=== Base122 Encoding Demo ===");
    println!();

    let test_cases = vec![
        ("", "Empty string"),
        ("A", "Single character"),
        ("Hello", "Simple text"),
        ("Hello, World!", "Text with punctuation"),
        ("The quick brown fox jumps over the lazy dog", "Long text"),
        (
            "Text with\ndangerous\rcharacters\"&\\",
            "Dangerous characters",
        ),
    ];

    for (input, description) in test_cases {
        println!("Test: {description}");
        println!("  Input: {input:?}");

        let encoded = encode(input.as_bytes());
        println!("  Encoded: {encoded:?}");

        match decode(&encoded) {
            Ok(decoded) => {
                let decoded_str = String::from_utf8_lossy(&decoded);
                println!("  Decoded: {decoded_str:?}");

                if decoded_str == input {
                    println!("  ✅ Round-trip successful");
                } else {
                    println!("  ❌ Round-trip failed");
                }
            }
            Err(e) => {
                println!("  ❌ Decode failed: {e}");
            }
        }

        // Compare with Base64 theoretical size
        let base64_size = (input.len() * 4).div_ceil(3);
        let base122_size = encoded.len();
        let savings = if base64_size > 0 {
            100.0 * (base64_size as f64 - base122_size as f64) / base64_size as f64
        } else {
            0.0
        };

        println!("  📊 Size comparison:");
        println!("     Original: {} bytes", input.len());
        println!("     Base64:   {base64_size} bytes (theoretical)");
        println!("     Base122:  {base122_size} bytes ({savings:.1}% savings)");
        println!();
    }

    // Binary data demonstration
    println!("=== Binary Data Test ===");
    let binary_data: Vec<u8> = (0..32).collect();
    println!("Binary data: {:?}...", &binary_data[..8]);

    let encoded = encode(&binary_data);
    println!("Encoded length: {} bytes", encoded.len());

    match decode(&encoded) {
        Ok(decoded) => {
            if decoded == binary_data {
                println!("✅ Binary round-trip successful");
            } else {
                println!("❌ Binary round-trip failed");
            }
        }
        Err(e) => {
            println!("❌ Binary decode failed: {e}");
        }
    }

    let expansion_ratio = encoded.len() as f64 / binary_data.len() as f64;
    println!("📊 Binary expansion ratio: {expansion_ratio:.3}x");
}

fn run_benchmark() {
    println!("=== Base122 Performance Benchmark ===");
    println!();

    let test_sizes = vec![10, 100, 1000, 10000];

    println!(
        "{:>10} {:>12} {:>12} {:>10} {:>12}",
        "Size", "Encoded", "Ratio", "Efficiency", "vs Base64"
    );
    println!("{:-<60}", "");

    for &size in &test_sizes {
        // Generate test data with mixed content
        let test_data: Vec<u8> = (0..size).map(|i| ((i * 37 + i * i) % 256) as u8).collect();

        let start = std::time::Instant::now();
        let encoded = encode(&test_data);
        let encode_time = start.elapsed();

        let start = std::time::Instant::now();
        let _decoded = decode(&encoded).unwrap();
        let decode_time = start.elapsed();

        let expansion_ratio = encoded.len() as f64 / size as f64;
        let efficiency = (size as f64 / encoded.len() as f64) * 100.0;

        // Base64 comparison
        let base64_size = (size * 4 + 2) / 3;
        let vs_base64 = (base64_size as f64 - encoded.len() as f64) / base64_size as f64 * 100.0;

        println!(
            "{:>10} {:>12} {:>12.3} {:>9.1}% {:>11.1}%",
            size,
            encoded.len(),
            expansion_ratio,
            efficiency,
            vs_base64
        );

        if size <= 1000 {
            // Only show timing for smaller sizes
            println!("           Encode: {encode_time:?}, Decode: {decode_time:?}");
        }
    }

    println!();
    println!("=== Dangerous Character Density Test ===");

    let densities = vec![0.0, 0.1, 0.2, 0.5];
    for &density in &densities {
        let mut test_data = Vec::new();
        for i in 0..1000 {
            if (i as f64 / 1000.0) < density {
                // Insert dangerous characters
                let dangerous_chars = [0u8, 10, 13, 34, 38, 92];
                test_data.push(dangerous_chars[i % dangerous_chars.len()]);
            } else {
                test_data.push(((i * 7) % 256) as u8);
            }
        }

        let encoded = encode(&test_data);
        let efficiency = (test_data.len() as f64 / encoded.len() as f64) * 100.0;

        println!(
            "Dangerous char density {:.0}%: efficiency {:.1}%",
            density * 100.0,
            efficiency
        );
    }

    println!();
    println!("📈 Benchmark complete!");
}
