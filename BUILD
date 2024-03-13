load("@io_bazel_rules_kotlin//kotlin:core.bzl", "define_kt_toolchain")

# https://github.com/bazelbuild/rules_kotlin#custom-toolchain
define_kt_toolchain(
    name = "kotlin_jvm11_toolchain",
    api_version = "1.9",
    experimental_strict_kotlin_deps = "error",
    experimental_use_abi_jars = True,
    jvm_target = "11", 
    language_version = "1.9",
)