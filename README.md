# bazel_sysroot_llvm_arm64

This sysroot provides ARM64-specific LLVM tools for Bazel builds. It is part of a larger system of sysroots that work together to provide a complete build environment.

## Purpose

The `bazel_sysroot_llvm_arm64` sysroot is responsible for providing ARM64-specific LLVM tools that are required for building applications on ARM64 architectures. It works in conjunction with:

- `bazel_sysroot_library` - Provides common headers and system libraries
- `bazel_sysroot_lib_arm64` - Provides ARM64-specific shared libraries

## Required Tools

This sysroot must provide all tools required by both `rules_cc` and `toolchain_llvm`:

### Core Tools (from rules_cc)
- `ar` (aliased from `llvm-ar`)
- `ld` (aliased from `ld.lld`)
- `llvm-cov`
- `llvm-profdata`
- `cpp` (aliased from `clang-cpp`)
- `gcc` (aliased from `clang`)
- `dwp` (aliased from `llvm-dwp`)
- `gcov`
- `nm` (aliased from `llvm-nm`)
- `objcopy` (aliased from `llvm-objcopy`)
- `objdump` (aliased from `llvm-objdump`)
- `strip` (aliased from `llvm-strip`)
- `c++filt` (aliased from `llvm-c++filt`)

### Additional Tools (from toolchain_llvm)
- `clang-cpp`
- `clang-format` (required since toolchain_llvm 1.4.0)
- `clang-tidy` (required since toolchain_llvm 1.4.0)
- `clangd` (required since toolchain_llvm 1.4.0)
- `ld.lld`
- `llvm-ar`
- `llvm-dwp`
- `llvm-profdata`
- `llvm-cov`
- `llvm-nm`
- `llvm-objcopy`
- `llvm-objdump`
- `llvm-strip`

## Tool Aliasing Strategy

This sysroot implements a dual aliasing strategy to ensure compatibility with both Bazel's expectations and direct tool usage:

1. **Filesystem-level aliases**: During the build process, GNU tool symlinks are created in the `bin/` directory:
   ```bash
   ln -sf clang gcc
   ln -sf clang-cpp cpp
   ln -sf llvm-ar ar
   ln -sf ld.lld ld
   ln -sf llvm-nm nm
   ln -sf llvm-objcopy objcopy
   ln -sf llvm-objdump objdump
   ln -sf llvm-strip strip
   ln -sf llvm-dwp dwp
   ln -sf llvm-c++filt c++filt
   ```

2. **Bazel-level aliases**: The `BUILD.bazel` file defines filegroups that map GNU tool names to their LLVM equivalents:
   ```python
   filegroup(
       name = "gcc",
       srcs = [":clang"],
       visibility = ["//visibility:public"],
   )
   # ... other aliases ...
   ```

This dual approach ensures compatibility at both the filesystem level (for direct tool usage) and the Bazel level (for build system integration). While either approach alone might be sufficient, using both provides maximum compatibility and flexibility.

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
package(default_visibility = ["//visibility:public"])

# Main sysroot filegroup
filegroup(
    name = "sysroot",
    srcs = glob(["bin/**"]),
    visibility = ["//visibility:public"],
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
    name = "llvm-as",
    srcs = ["bin/llvm-as"],
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

# Tool aliases
filegroup(
    name = "gcc",
    srcs = [":clang"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "cpp",
    srcs = [":clang-cpp"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ar",
    srcs = [":llvm-ar"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "ld",
    srcs = [":lld"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "nm",
    srcs = [":llvm-nm"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objcopy",
    srcs = [":llvm-objcopy"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "objdump",
    srcs = [":llvm-objdump"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "strip",
    srcs = [":llvm-strip"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "dwp",
    srcs = [":llvm-dwp"],
    visibility = ["//visibility:public"],
)
```

## Usage in Bazel

This sysroot is used as part of the LLVM toolchain configuration in your `MODULE.bazel`:

```python
llvm.toolchain(
    name = "llvm_arm64",
    llvm_version = "20.1.2",
    stdlib = {
        "linux-aarch64": "stdc++",
    },
)

llvm.sysroot(
    name = "llvm_arm64",
    targets = ["linux-aarch64"],
    # Main sysroot containing the LLVM tools
    label = "@bazel_sysroot_llvm_arm64//:sysroot",
    # Additional sysroots for headers and libraries
    include_prefix = "@bazel_sysroot_library//:include",
    lib_prefix = "@bazel_sysroot_lib_arm64//:lib",
    # System libraries from both common and architecture-specific sysroots
    system_libs = [
        "@bazel_sysroot_library//:system_deps",
        "@bazel_sysroot_library//:system_deps_static",
        "@bazel_sysroot_lib_arm64//:system_libs",
    ],
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

## Notes

- All binaries are placed in the `bin/` directory
- The sysroot is designed to work in conjunction with:
  - `bazel_sysroot_library` for common headers and system libraries
  - `bazel_sysroot_lib_arm64` for ARM64-specific shared libraries
- The BUILD file provides granular access to individual tools through filegroups
- Each tool is exposed with public visibility for use in Bazel builds
- GNU tool symlinks are created to ensure compatibility with Bazel's expectations
- Excluding llvm-exegesis as it's a large benchmarking tool (75MB) not needed for compilation
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

## Dependencies

- Nix package manager
- rsync (for copying files)
- git (for version control)
