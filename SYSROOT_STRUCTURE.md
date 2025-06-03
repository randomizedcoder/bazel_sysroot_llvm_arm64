# Bazel LLVM Sysroot Structure (ARM64)

This sysroot is designed for compatibility with Bazel's `toolchains_llvm` extension for ARM64 architecture. It contains the LLVM tools required for building applications on ARM64 architectures.

## Directory Layout

```
sysroot/
  bin/
    clang*     # Clang compiler tools
    lld*       # LLVM linker tools
    llvm-*     # Other LLVM tools
    llvm-dwp   # DWARF packaging tool
  BUILD.sysroot.bazel
```

## BUILD File Structure

The `BUILD.sysroot.bazel` file defines the following targets:

```python
package(default_visibility = ["//visibility:public"])

# Main filegroup that includes everything
filegroup(
    name = "all",
    srcs = [":sysroot"],
)

# Sysroot filegroup for bin directory
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

### LLVM Core Tools
- llvm-ar
- llvm-nm
- llvm-objcopy
- llvm-objdump
- llvm-readelf
- llvm-strip
- llvm-dwp

### Clang Compiler Tools
- clang
- clang++
- clang-cpp
- clang-format
- clang-tidy
- clangd

### LLVM Linker Tools
- lld
- ld.lld

## Usage

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

## Notes

- All binaries are placed in the `bin/` directory
- The sysroot is designed to work in conjunction with:
  - `bazel_sysroot_library` for common headers and system libraries
  - `bazel_sysroot_lib_arm64` for ARM64-specific shared libraries
- The BUILD file provides granular access to individual tools through filegroups
- Each tool is exposed with public visibility for use in Bazel builds