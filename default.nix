{ pkgs ? import <nixpkgs> {} }:

let
  # LLVM toolchain for ARM64
  llvmToolchain = pkgs.llvmPackages_20.llvm;
  clang = pkgs.llvmPackages_20.libcxxClang;
  lld = pkgs.llvmPackages_20.lld;
  libcxx = pkgs.llvmPackages_20.libcxx;
  # List of GNU tool symlinks to LLVM equivalents
  symlinks = [
    { link = "ld"; target = "ld.lld"; }
    { link = "objcopy"; target = "llvm-objcopy"; }
    { link = "strip"; target = "llvm-strip"; }
    { link = "ar"; target = "llvm-ar"; }
    { link = "nm"; target = "llvm-nm"; }
    { link = "ranlib"; target = "llvm-ranlib"; }
    { link = "size"; target = "llvm-size"; }
    { link = "strings"; target = "llvm-strings"; }
    { link = "addr2line"; target = "llvm-addr2line"; }
    { link = "c++filt"; target = "llvm-cxxfilt"; }
    { link = "readelf"; target = "llvm-readelf"; }
    { link = "elfedit"; target = "llvm-elfedit"; }
    { link = "as"; target = "llvm-as"; }
    { link = "cc"; target = "clang"; }
    { link = "cc++"; target = "clang++"; }
  ];
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

    # Create symlinks for GNU tool names to LLVM equivalents
    # This is required because Bazel and some build systems expect standard GNU tool names (e.g., 'ld', 'objcopy', 'strip'),
    # but the sysroot only provides LLVM equivalents (e.g., 'ld.lld', 'llvm-objcopy', 'llvm-strip').
    # By creating these symlinks, we ensure compatibility with Bazel's toolchain expectations.
    cd $out/bin
    for symlink in ${builtins.toString (map (s: ''${s.link}:${s.target}'') symlinks)}; do
      link="$(echo $symlink | cut -d: -f1)"
      target="$(echo $symlink | cut -d: -f2)"
      if [ -e "$target" ]; then
        ln -sf $target $link
      fi
    done
    cd -

    # Copy LLVM libraries
    echo "Copying LLVM libraries..."
    if [ -d "${llvmToolchain}/lib" ]; then
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

    cat > $out/BUILD.sysroot.bazel << 'EOF'
filegroup(
    name = "sysroot",
    srcs = glob(["**"]),
    visibility = ["//visibility:public"]
)
EOF
  '';
}