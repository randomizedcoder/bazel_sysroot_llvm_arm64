# bazel_sysroot_llvm_arm64

This sysroot provides ARM64-specific LLVM tools for Bazel builds. It is part of a larger system of sysroots that work together to provide a complete build environment.

## Purpose

The `bazel_sysroot_llvm_arm64` sysroot is responsible for providing ARM64-specific LLVM tools that are required for building applications on ARM64 architectures. It works in conjunction with:

- `bazel_sysroot_library` - Provides common headers and system libraries
- `bazel_sysroot_lib_arm64` - Provides ARM64-specific shared libraries

## Directory Structure

```
sysroot/
└── bin/           # ARM64-specific LLVM tools
    ├── clang*     # Clang compiler tools
    ├── lld*       # LLVM linker tools
    ├── llvm-*     # Other LLVM tools
    └── llvm-dwp   # DWARF packaging tool
```

## BUILD File Targets

The `BUILD.sysroot.bazel` file defines the following targets:

```python
filegroup(
    name = "all",
    srcs = [":sysroot"],
)

filegroup(
    name = "sysroot",
    srcs = glob(["bin/**"]),
    allow_empty = True,
)

# Individual tool targets
filegroup(
    name = "clang",
    srcs = glob(["bin/clang*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lld",
    srcs = glob(["bin/lld*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-ar",
    srcs = ["bin/llvm-ar"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-nm",
    srcs = ["bin/llvm-nm"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-objcopy",
    srcs = ["bin/llvm-objcopy"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-objdump",
    srcs = ["bin/llvm-objdump"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-readelf",
    srcs = ["bin/llvm-readelf"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-strip",
    srcs = ["bin/llvm-strip"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "llvm-dwp",
    srcs = ["bin/llvm-dwp"],
    visibility = ["//visibility:public"],
)
```

## Included Tools

This sysroot includes ARM64-specific versions of:

- LLVM core tools:
  - llvm-ar
  - llvm-nm
  - llvm-objcopy
  - llvm-objdump
  - llvm-readelf
  - llvm-strip
  - llvm-dwp
- Clang compiler tools:
  - clang
  - clang++
  - clang-cpp
  - clang-format
  - clang-tidy
  - clangd
- LLVM linker tools:
  - lld
  - ld.lld

## Usage in Bazel

This sysroot is typically used as part of the LLVM toolchain configuration in your `MODULE.bazel`:

```python
llvm_toolchain(
    name = "llvm_arm64",
    llvm_version = "20.1.2",
    build_file = "//:llvm.BUILD",
    sysroot = {
        "include_prefix": "@bazel_sysroot_library//sysroot",
        "lib_prefix": "@bazel_sysroot_lib_arm64//sysroot",
    },
)
```

## Building

To build this sysroot:

```bash
nix-build default.nix
```

The resulting sysroot will be available in the `result/sysroot` directory.

## Structure

The sysroot follows a specific structure to ensure compatibility with Bazel's LLVM toolchain. For details, see [SYSROOT_STRUCTURE.md](SYSROOT_STRUCTURE.md).

## Building

To build the sysroot:

```bash
nix build
```

## Usage

The sysroot can be used in Bazel projects by adding it as a dependency in your `MODULE.bazel` file:

```python
http_archive(
    name = "bazel_sysroot_tarball_arm64",
    urls = ["https://github.com/yourusername/bazel_sysroot_llvm_arm64/archive/refs/heads/main.tar.gz"],
    strip_prefix = "bazel_sysroot_llvm_arm64-main",
)
```

Excluding llvm-exegesis as it's a large benchmarking tool (75MB) not needed for compilation
See https://llvm.org/docs/CommandGuide/llvm-exegesis.html for details

clang is symlinked into cc

## GNU tool symlinks

Bazel and some build systems expect standard GNU tool names (e.g., `ld`, `objcopy`, `strip`), but this sysroot only provides LLVM equivalents (e.g., `ld.lld`, `llvm-objcopy`, `llvm-strip`). We create symlinks from the GNU tool names to the LLVM equivalents to ensure compatibility with Bazel's toolchain expectations.

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

## Dependencies

- Nix package manager
- rsync (for copying files)
- git (for version control)
