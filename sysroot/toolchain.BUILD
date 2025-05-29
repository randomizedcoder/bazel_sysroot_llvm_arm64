cc_library(
    name = "llvm_toolchain",
    srcs = glob(["lib/*.so*"]),
    hdrs = glob(["include/**/*.h"]),
    includes = ["include"],
    linkstatic = 1,
    visibility = ["//visibility:public"],
)

filegroup(
    name = "binaries",
    srcs = glob(["bin/*"]),
    visibility = ["//visibility:public"],
)
