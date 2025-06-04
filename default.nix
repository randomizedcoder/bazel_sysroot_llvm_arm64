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

    # Create GNU tool symlinks
    cd $out/sysroot/bin
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

    cat > $out/sysroot/BUILD.bazel << 'EOF'
${build_file_content}
EOF
  '';
}