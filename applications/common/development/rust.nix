{ config, lib, pkgs, ... }:

{
  # Comprehensive Rust development environment
  # This provides a complete Rust toolchain with modern development tools

  home.packages = with pkgs; [
    # Core Rust toolchain
    rustup                          # Rust toolchain manager (will install Rust 1.85)
    
    # Development utilities
    cargo-watch                     # Auto-rebuild on file changes (uses cargo via rustup)
    cargo-edit                      # Commands for editing Cargo.toml
    cargo-expand                    # Expand macros in Rust code
    cargo-udeps                     # Find unused dependencies
    cargo-audit                     # Security vulnerability scanner
    cargo-outdated                  # Check for outdated dependencies
    cargo-bloat                     # Find what takes space in executables
    cargo-deny                      # Cargo plugin for linting dependencies
    cargo-machete                   # Remove unused Cargo dependencies
    cargo-nextest                   # Next-generation test runner
    cargo-cross                     # Cross-compilation made easy
    cargo-make                      # Task runner and build tool
    cargo-generate                 # Generate projects from templates
    cargo-criterion                # Benchmarking tool integration
    cargo-tarpaulin                # Code coverage tool for Rust
    
    # WASM and web development
    wasm-pack                       # Build Rust-generated WebAssembly
    wasmtime                        # WASM runtime
    dioxus-cli                      # Dioxus CLI for fullstack Rust web development
    trunk                           # WASM web application bundler
    http-server                     # Simple HTTP server for development (node-based)
    wasm-bindgen-cli                # WebAssembly bindings generator
    
    # Performance and debugging tools
    cargo-flamegraph                # Flamegraph profiling for Rust
    
    # Cross-platform build tools
    cmake                           # Build system generator
    pkg-config                      # Helper for compiling applications
    openssl                         # SSL/TLS toolkit
    
    # Build cache for faster compilation
    sccache                         # Shared compilation cache

    # Additional useful tools
    tokei                           # Count lines of code
    hyperfine                       # Command-line benchmarking

    # Protocol buffer support
    protobuf                        # Protocol buffer compiler

    # Database development
    diesel-cli                      # Diesel ORM CLI
    sqlx-cli                        # SQLx database toolkit CLI

    # Network and crypto libraries commonly needed
    curl                            # HTTP client library
    wget                            # File download utility
    
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-specific development tools
    gdb                             # GNU debugger
    strace                          # System call tracer
    binutils                        # Binary utilities
    gcc                             # GNU Compiler Collection
    gnumake                         # GNU Make
    valgrind                        # Memory debugging
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-specific development tools
    darwin.apple_sdk.frameworks.Security    # Security framework
    darwin.apple_sdk.frameworks.CoreServices # Core Services framework
    darwin.apple_sdk.frameworks.SystemConfiguration # System Configuration framework
    libiconv                        # Character encoding conversion
  ];

  # Environment variables for Rust development
  home.sessionVariables = {
    # Rust environment
    RUST_BACKTRACE = "1";                           # Enable backtraces
    RUST_LOG = "debug";                             # Set default log level
    RUSTC_WRAPPER = "sccache";                      # Use sccache for compilation caching
    
    # Pin Rust toolchain managed by rustup to LTS 1.85
    RUSTUP_TOOLCHAIN = "1.85.0";
    RUSTUP_DIST_SERVER = "https://static.rust-lang.org";
    RUSTUP_UPDATE_ROOT = "https://static.rust-lang.org/rustup";
    
    # Cargo configuration
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    CARGO_TARGET_DIR = "${config.home.homeDirectory}/.cargo/target";
    
    # Cross-compilation support
    PKG_CONFIG_PATH = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.isLinux "${pkgs.openssl.dev}/lib/pkgconfig")
      (lib.mkIf pkgs.stdenv.isDarwin "${pkgs.openssl}/lib/pkgconfig")
    ];
    
    # WASM development
    WASM_PACK_CACHE = "${config.home.homeDirectory}/.cache/wasm-pack";
  };

  # Cargo configuration
  home.file.".cargo/config.toml".text = ''
    [build]
    # Use all available CPU cores for compilation
    jobs = 0
    
    # Enable incremental compilation for faster rebuilds
    incremental = true
    
    # Default target for cross-compilation
    ${lib.optionalString pkgs.stdenv.isLinux ''
    target-dir = "target"
    ''}
    
    [cargo-new]
    # Default template for new projects
    name = "Your Name"
    email = "your.email@example.com"
    
    [term]
    # Colored output
    color = "always"
    
    [profile.dev]
    # Development profile optimizations
    debug = true
    opt-level = 0
    overflow-checks = true
    
    [profile.release]
    # Release profile optimizations
    debug = false
    lto = true
    codegen-units = 1
    panic = "abort"
    strip = true
    
    [profile.bench]
    # Benchmarking profile
    debug = true
    
    [target.x86_64-unknown-linux-gnu]
    # Linux-specific linker configuration
    ${lib.optionalString pkgs.stdenv.isLinux ''
    linker = "gcc"
    ''}
    
    [target.aarch64-apple-darwin]
    # macOS ARM64-specific configuration
    ${lib.optionalString pkgs.stdenv.isDarwin ''
    linker = "cc"
    ''}
    
    [target.x86_64-apple-darwin]
    # macOS x86_64-specific configuration
    ${lib.optionalString pkgs.stdenv.isDarwin ''
    linker = "cc"
    ''}
    
    # Registry configuration
    [registries.crates-io]
    protocol = "sparse"
    
    # Git configuration for private registries
    [net]
    retry = 2
    git-fetch-with-cli = true
    
    # Source replacement for faster dependency resolution
    [source.crates-io]
    replace-with = "vendored-sources"
    
    [source.vendored-sources]
    directory = "vendor"
  '';

  # Rustfmt configuration for consistent code formatting
  home.file.".rustfmt.toml".text = ''
    # Rustfmt configuration for consistent code style
    edition = "2021"
    max_width = 100
    hard_tabs = false
    tab_spaces = 4
    newline_style = "Unix"
    use_small_heuristics = "Default"
    reorder_imports = true
    reorder_modules = true
    remove_nested_parens = true
    merge_derives = true
    imports_granularity = "Crate"
    group_imports = "StdExternalCrate"
    wrap_comments = true
    comment_width = 80
    normalize_comments = true
    format_code_in_doc_comments = true
    format_strings = false
    format_macro_matchers = true
    format_macro_bodies = true
    hex_literal_case = "Preserve"
    empty_item_single_line = true
    struct_lit_single_line = true
    fn_single_line = false
    where_single_line = false
    imports_layout = "Mixed"
    merge_imports = false
    inline_attribute_width = 0
    binop_separator = "Front"
    remove_blank_lines_at_start_or_end_of_blocks = true
    match_block_trailing_comma = false
    trailing_comma = "Vertical"
    trailing_semicolon = true
    use_field_init_shorthand = false
    use_try_shorthand = false
    version = "Two"
  '';

  # Clippy configuration for advanced linting
  home.file.".clippy.toml".text = ''
    # Clippy configuration for enhanced linting
    avoid-breaking-exported-api = false
    msrv = "1.70.0"
    cognitive-complexity-threshold = 30
    type-complexity-threshold = 250
    single-char-binding-names-threshold = 4
    trivial-copy-size-limit = 0
    pass-by-value-size-limit = 256
    too-many-arguments-threshold = 7
    too-many-lines-threshold = 100
    large-type-threshold = 200
    enum-variant-size-threshold = 200
    verbose-bit-mask-threshold = 1
    literal-representation-threshold = 10
    trivially-copy-pass-by-ref-size-limit = 256
    pass-by-value-size-limit = 256
    too-many-arguments-threshold = 7
    type-complexity-threshold = 250
    single-char-binding-names-threshold = 4
    doc-comment-code-block-attribute-threshold = 3
    blacklisted-names = ["foo", "baz", "quux"]
  '';

  # Shell aliases for Rust development
  programs.zsh.shellAliases = {
    # Cargo shortcuts
    "cg" = "cargo";
    "cb" = "cargo build";
    "cr" = "cargo run";
    "ct" = "cargo test";
    "cc" = "cargo check";
    "cf" = "cargo fmt";
    "ccl" = "cargo clippy";
    "cu" = "cargo update";
    "cw" = "cargo watch -x check -x test -x run";
    "cbr" = "cargo build --release";
    "crr" = "cargo run --release";
    "ctr" = "cargo test --release";
    
    # Advanced cargo commands
    "cexpand" = "cargo expand";
    "caudit" = "cargo audit";
    "coutdated" = "cargo outdated";
    "cbloat" = "cargo bloat";
    "cudeps" = "cargo udeps";
    "cdeny" = "cargo deny check";
    "cmachete" = "cargo machete";
    "cnextest" = "cargo nextest run";
    "ctarpaulin" = "cargo tarpaulin";
    "cflame" = "cargo flamegraph";
    
    # Rust-specific development
    "rustdoc" = "cargo doc --open";
    "rustbench" = "cargo bench";
    
    # WASM development
    "wasm-build" = "wasm-pack build";
    "wasm-test" = "wasm-pack test --node";
    
    # Dioxus development
    "dx" = "dioxus";
    "dx-new" = "dioxus new";
    "dx-serve" = "dioxus serve";
    "dx-build" = "dioxus build";
    "dx-translate" = "dioxus translate";
    
    # Web development
    "trunk-serve" = "trunk serve";
    "trunk-build" = "trunk build";
  };



  # Configure development shell
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      # Rust-specific direnv functions
      layout_rust() {
        export RUST_LOG=debug
        export RUST_BACKTRACE=1
        PATH_add "$PWD/target/debug"
        PATH_add "$PWD/target/release"
      }
      
      # WASM development
      layout_wasm() {
        export WASM_PACK_CACHE="$PWD/.wasm-pack-cache"
        PATH_add "$PWD/pkg"
      }
      
      # Dioxus development
      layout_dioxus() {
        export DIOXUS_LOG=debug
        export DIOXUS_HOT_RELOAD=true
        PATH_add "$PWD/dist"
        PATH_add "$PWD/target/dx"
      }
    '';
  };
}