use base122::{encode, decode};
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
        },
        "decode" => {
            if args.len() > 2 {
                match decode(&args[2]) {
                    Ok(data) => {
                        io::stdout().write_all(&data).unwrap();
                    },
                    Err(e) => {
                        eprintln!("Decode error: {}", e);
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
                    },
                    Err(e) => {
                        eprintln!("Decode error: {}", e);
                        std::process::exit(1);
                    }
                }
            }
        },
        "demo" => run_demo(),
        _ => print_usage(),
    }
}

fn print_usage() {
    println!("Base122 Encoding/Decoding Demo");
    println!("Usage:");
    println!("  {} encode [text]    - Encode text (or read from stdin)", env::args().next().unwrap());
    println!("  {} decode [encoded] - Decode text (or read from stdin)", env::args().next().unwrap());
    println!("  {} demo             - Run demonstration", env::args().next().unwrap());
}

fn run_demo() {
    println!("=== Base122 Encoding Demo ===\n");

    let test_cases = vec![
        "",
        "A",
        "Hello",
        "Hello, World!",
        "The quick brown fox jumps over the lazy dog",
        "Base122 is more efficient than Base64!",
    ];

    for (i, &test) in test_cases.iter().enumerate() {
        println!("Test case {}: {:?}", i + 1, test);
        let encoded = encode(test.as_bytes());
        println!("Encoded: {}", encoded);
        
        match decode(&encoded) {
            Ok(decoded) => {
                let decoded_str = String::from_utf8_lossy(&decoded);
                println!("Decoded: {:?}", decoded_str);
                println!("✓ Round-trip successful");
            },
            Err(e) => {
                println!("✗ Decode failed: {}", e);
            }
        }
        
        let base64_len = (test.len() + 2) / 3 * 4;
        let base122_len = encoded.len();
        let efficiency = if base64_len > 0 {
            100.0 * (base64_len as f64 - base122_len as f64) / base64_len as f64
        } else {
            0.0
        };
        
        println!("Length comparison - Original: {}, Base64: {}, Base122: {} ({:.1}% smaller)",
                test.len(), base64_len, base122_len, efficiency);
        println!();
    }

    println!("=== Binary Data Test ===");
    let binary_data: Vec<u8> = (0..100).collect();
    println!("Binary data: {:?}...", &binary_data[..10]);
    let encoded = encode(&binary_data);
    println!("Encoded length: {}", encoded.len());
    
    match decode(&encoded) {
        Ok(decoded) => {
            if decoded == binary_data {
                println!("✓ Binary round-trip successful");
            } else {
                println!("✗ Binary round-trip failed");
            }
        },
        Err(e) => {
            println!("✗ Binary decode failed: {}", e);
        }
    }
}
