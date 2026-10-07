//! Generates the embedded core payload from `scripts/harness-install-files.txt`,
//! the one declaration of the installed file list.

use std::fmt::Write as _;
use std::path::PathBuf;
use std::{env, fs};

const MANIFEST: &str = "scripts/harness-install-files.txt";
const COMPOSE_PREFIX: &str = "compose:";
const AGENTS_HEADING: &[u8] = b"# Agent Instructions\n\n";

fn main() {
    let crate_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let repository = crate_dir.join("../..");
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let manifest = repository.join(MANIFEST);
    println!("cargo:rerun-if-changed={}", manifest.display());

    let text = fs::read_to_string(&manifest)
        .unwrap_or_else(|error| panic!("cannot read {}: {error}", manifest.display()));
    let mut generated = String::from("&[\n");
    for line in text.lines().map(str::trim) {
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let (destination, source) = line
            .split_once("<-")
            .map_or((line, line), |(d, s)| (d.trim(), s.trim()));
        let embedded = match source.strip_prefix(COMPOSE_PREFIX) {
            Some(block) => {
                assert_eq!(
                    destination, "AGENTS.md",
                    "only AGENTS.md is composed: {line}"
                );
                let block = repository.join(block);
                println!("cargo:rerun-if-changed={}", block.display());
                let mut composed = AGENTS_HEADING.to_vec();
                composed
                    .extend(fs::read(&block).unwrap_or_else(|error| {
                        panic!("cannot read {}: {error}", block.display())
                    }));
                fs::write(out_dir.join("AGENTS.md"), composed).unwrap();
                String::from("concat!(env!(\"OUT_DIR\"), \"/AGENTS.md\")")
            }
            None => {
                let path = repository.join(source);
                println!("cargo:rerun-if-changed={}", path.display());
                assert!(path.is_file(), "manifest source is missing: {line}");
                format!(
                    "concat!(env!(\"CARGO_MANIFEST_DIR\"), {:?})",
                    format!("/../../{source}")
                )
            }
        };
        writeln!(
            generated,
            "    ({destination:?}, include_bytes!({embedded})),"
        )
        .unwrap();
    }
    generated.push_str("]\n");
    fs::write(out_dir.join("core_payload.rs"), generated).unwrap();
}
