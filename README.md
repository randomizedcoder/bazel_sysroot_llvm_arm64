# Bazel LLVM Sysroot for ARM64

This repository contains a statically compiled LLVM toolchain for ARM64 architecture that can be used with Bazel builds. Built using Nix, all components are statically linked, ensuring consistent behavior across different environments. The sysroot also includes coreutils to provide essential Unix tools needed during Bazel builds.

Excluding llvm-exegesis as it's a large benchmarking tool (75MB) not needed for compilation
See https://llvm.org/docs/CommandGuide/llvm-exegesis.html for details

## Available Make Targets

- `make help` - Show available targets and their descriptions
- `make update-flake` - Update flake.lock with latest dependencies
- `make build` - Build the ARM64 LLVM toolchain using nix build
- `make tarball` - Create a .tar.gz archive of the ARM64 LLVM toolchain
- `make nix-tarball` - Create a .tar.gz archive using nix build
- `make copy` - Copy files from Nix store to sysroot directory
- `make push` - Push changes to GitHub with dated commit
- `make update-all` - Update flake, build, copy, and push
- `make clean` - Clean up build artifacts

## Repository Structure

```
.
├── default.nix      # Nix package definition
├── flake.nix        # Nix flake configuration
├── Makefile         # Build and maintenance targets
├── sysroot/         # Sysroot files (generated)
│   ├── include/     # Header files
│   ├── lib/         # Library files
│   └── bin/         # Binary files (LLVM tools and coreutils)
└── .gitignore      # Git ignore rules
```

## Usage

1. Build the sysroot:
   ```bash
   make build
   ```

2. Copy files to the repository:
   ```bash
   make copy
   ```

3. Create a tarball:
   ```bash
   make tarball
   # or
   make nix-tarball
   ```

4. Update everything and push:
   ```bash
   make update-all
   ```

## Dependencies

- Nix package manager
- rsync (for copying files)
- git (for version control)
