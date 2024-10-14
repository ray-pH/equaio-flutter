#!/bin/bash

# Exit if any command fails
set -e

# Set up Rust environment
echo "Setting up Rust environment"

# Install Rust and wasm components
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustup default nightly
rustup component add rust-src
rustup target add wasm32-unknown-unknown

# Install wasm-pack and flutter_rust_bridge_codegen
cargo install wasm-pack
cargo install flutter_rust_bridge_codegen

# Run flutter_rust_bridge_codegen generate and build-web
mkdir -p lib/src/rust
flutter_rust_bridge_codegen generate
flutter_rust_bridge_codegen build-web

# Build Flutter web
flutter build web --release
