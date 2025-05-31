{ pkgs ? import <nixpkgs> {} }:

let
  # LLVM toolchain for ARM64
  llvmToolchain = pkgs.llvmPackages_20.llvm;
  clang = pkgs.llvmPackages_20.libcxxClang;
  lld = pkgs.llvmPackages_20.lld;
  libcxx = pkgs.llvmPackages_20.libcxx;
in
pkgs.stdenv.mkDerivation {
  name = "bazel-llvm-arm64";
  version = "1.0.0";

  buildInputs = [ llvmToolchain clang lld libcxx pkgs.coreutils ];

  buildCommand = ''
    # Create toolchain directory structure
    mkdir -p $out/{bin,lib}

    # Copy LLVM binaries
    echo "Copying LLVM binaries..."
    if [ -d "${llvmToolchain}/bin" ]; then
      # Exclude llvm-exegesis as it's a large benchmarking tool not needed for compilation
      find "${llvmToolchain}/bin" -type f ! -name "llvm-exegesis" -exec cp -L {} $out/bin/ \;
    fi
    if [ -d "${clang}/bin" ]; then
      find "${clang}/bin" -type f ! -name "llvm-exegesis" -exec cp -L {} $out/bin/ \;
    fi
    if [ -d "${lld}/bin" ]; then
      find "${lld}/bin" -type f ! -name "llvm-exegesis" -exec cp -L {} $out/bin/ \;
    fi

    # Copy coreutils binaries
    echo "Copying coreutils binaries..."
    if [ -d "${pkgs.coreutils}/bin" ]; then
      cp -r ${pkgs.coreutils}/bin/* $out/bin/ || true
    fi

    # Create cc and cc++ symlinks in the same directory
    (cd $out/bin && ln -sf clang cc && ln -sf clang++ cc++)

    # Copy LLVM libraries
    echo "Copying LLVM libraries..."
    if [ -d "${llvmToolchain}/lib" ]; then
      # Exclude llvm-exegesis as it's a large benchmarking tool (75MB) not needed for compilation
      # See https://llvm.org/docs/CommandGuide/llvm-exegesis.html for details
      find "${llvmToolchain}/lib" -type f -name "*.so*" ! -name "*exegesis*" -exec cp -L {} $out/lib/ \;
    fi
    if [ -d "${clang}/lib" ]; then
      find "${clang}/lib" -type f -name "*.so*" ! -name "*exegesis*" -exec cp -L {} $out/lib/ \;
    fi
    if [ -d "${lld}/lib" ]; then
      find "${lld}/lib" -type f -name "*.so*" ! -name "*exegesis*" -exec cp -L {} $out/lib/ \;
    fi
    if [ -d "${libcxx}/lib" ]; then
      find "${libcxx}/lib" -type f -name "*.so*" ! -name "*exegesis*" -exec cp -L {} $out/lib/ \;
    fi

    # Create toolchain.BUILD file
    cat > $out/toolchain.BUILD << 'EOF'
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all",
    srcs = glob(["**"]),
)

filegroup(
    name = "binaries",
    srcs = glob(["bin/*"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "lib",
    srcs = glob(["lib/**"]),
    visibility = ["//visibility:public"],
)

cc_library(
    name = "llvm_toolchain",
    srcs = glob(["lib/*.so*"]),
    linkstatic = 1,
    visibility = ["//visibility:public"],
)
EOF
  '';
}