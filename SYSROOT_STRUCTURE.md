# Bazel LLVM Sysroot Structure (ARM64)

This sysroot is designed for compatibility with Bazel's `toolchains_llvm` extension for ARM64 architecture. It contains the LLVM tools required for building applications on ARM64 architectures.

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

## Directory Layout

```
sysroot/
  bin/
    clang*     # Clang compiler tools
    lld*       # LLVM linker tools
    llvm-*     # Other LLVM tools
    llvm-dwp   # DWARF packaging tool
  BUILD.bazel
```

## BUILD File Structure

The `BUILD.bazel` file defines the following targets:

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

## Usage

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