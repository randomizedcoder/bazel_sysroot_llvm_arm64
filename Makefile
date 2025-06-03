.PHONY: help update-flake build tarball nix-tarball copy push force-push update-all clean

# Default target
help:
	@echo "Available targets:"
	@echo "  update-flake  - Update flake.lock with latest dependencies"
	@echo "  build        - Build the ARM64 LLVM toolchain using nix build"
	@echo "  tarball      - Create a .tar.gz archive of the ARM64 LLVM toolchain"
	@echo "  push         - Push changes to GitHub with dated commit"
	@echo "  force-push   - Force push changes to GitHub (use with caution)"
	@echo "  update-all   - Update flake, build, copy, and push"
	@echo "  nix-tarball  - Create a .tar.gz archive using nix build"
	@echo "  copy         - Copy files from Nix store to sysroot directory"
	@echo "  clean        - Clean up build artifacts"
	@echo "  help         - Show this help message"

update-flake:
	nix flake update

build:
	nix build

nix-tarball:
	nix build
	tar -czf bazel-llvm-arm64.tar.gz result

tarball: build
	tar -czf bazel-llvm-arm64.tar.gz result

copy: build
	rm -rf sysroot
	mkdir -p sysroot
	rsync -av --delete --exclude 'llvm-exegesis' result/sysroot/ sysroot/
	# symlink via nix!
	#@cd sysroot/bin && ln -sf clang cc
	#@cd sysroot/bin && ln -sf clang++ cc++

push:
	git add .
	git commit -m "Update ARM64 LLVM toolchain $(shell date +%Y-%m-%d)" || true
	git remote set-url origin git@github.com:randomizedcoder/bazel_sysroot_lib_arm64.git
	git push --force

force-push:
	git add .
	git commit -m "Update ARM64 LLVM toolchain $(shell date +%Y-%m-%d)" || true
	git remote set-url origin git@github.com:randomizedcoder/bazel_sysroot_lib_arm64.git
	git push --force

update-all: update-flake build copy push

clean:
	rm -rf result sysroot bazel-llvm-arm64.tar.gz

# Show help by default
.DEFAULT_GOAL := help