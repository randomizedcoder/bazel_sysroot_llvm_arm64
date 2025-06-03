{ pkgs ? import <nixpkgs> {} }:

let
  # ARM64-specific LLVM tools
  arm64Tools = with pkgs; [
    llvmPackages_20.llvm
    llvmPackages_20.clang
    llvmPackages_20.lld
    llvmPackages_20.compiler-rt
    llvmPackages_20.libcxx
    llvmPackages_20.libcxxClang
    llvmPackages_20.bintools
    llvmPackages_20.clang-tools
  ];

  build_file_content = ''
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
'';
in
pkgs.stdenv.mkDerivation {
  name = "bazel-sysroot-llvm-arm64";
  version = "1.0.0";

  buildInputs = arm64Tools;

  buildCommand = ''
    # Create sysroot directory structure
    mkdir -p $out/sysroot/bin

    # Copy LLVM tools
    echo "Copying LLVM tools..."
    if [ -d "${pkgs.llvmPackages_20.llvm}/bin" ]; then cp -r ${pkgs.llvmPackages_20.llvm}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.clang}/bin" ]; then cp -r ${pkgs.llvmPackages_20.clang}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.lld}/bin" ]; then cp -r ${pkgs.llvmPackages_20.lld}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.compiler-rt}/bin" ]; then cp -r ${pkgs.llvmPackages_20.compiler-rt}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.libcxx}/bin" ]; then cp -r ${pkgs.llvmPackages_20.libcxx}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.libcxxClang}/bin" ]; then cp -r ${pkgs.llvmPackages_20.libcxxClang}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.bintools}/bin" ]; then cp -r ${pkgs.llvmPackages_20.bintools}/bin/* $out/sysroot/bin/ || true; fi
    if [ -d "${pkgs.llvmPackages_20.clang-tools}/bin" ]; then cp -r ${pkgs.llvmPackages_20.clang-tools}/bin/* $out/sysroot/bin/ || true; fi

    cat > $out/sysroot/BUILD.bazel << 'EOF'
${build_file_content}
EOF
  '';
}