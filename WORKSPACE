#-----------------------------------------------------------------------------
# Workspace setup
#-----------------------------------------------------------------------------

workspace(name = "encryption_lib")

# Load the common tools rules used to set up http archives. We will use http_archive rules to
# bootstrap other rule types (e.g. for maven and protos).
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Load the common tools rules used to clone git repos. We will use this to reference a Tink
# proto_library that doesn't currently have a Maven artifact.
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")



#-----------------------------------------------------------------------------
# Rules JVM External setup
#-----------------------------------------------------------------------------

RULES_JVM_EXTERNAL_TAG = "6.0"

RULES_JVM_EXTERNAL_SHA = "85fd6bad58ac76cc3a27c8e051e4255ff9ccd8c92ba879670d195622e7c0a9b7"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
)


#-----------------------------------------------------------------------------
# Rules Kotlin External setup
#-----------------------------------------------------------------------------


rules_kotlin_version = "1.9.0"
rules_kotlin_sha = "5766f1e599acf551aa56f49dab9ab9108269b03c557496c54acaf41f98e2b8d6"
http_archive(
    name = "io_bazel_rules_kotlin",
    urls = ["https://github.com/bazelbuild/rules_kotlin/releases/download/v%s/rules_kotlin-v%s.tar.gz" % (rules_kotlin_version, rules_kotlin_version)],
    sha256 = rules_kotlin_sha,
)

load("@io_bazel_rules_kotlin//kotlin:repositories.bzl", "kotlin_repositories", "kotlinc_version")

kotlin_repositories(
    compiler_release = kotlinc_version(
        release = "1.9.20",
        sha256 = "15a8a2825b74ccf6c44e04e97672db802d2df75ce2fbb63ef0539bf3ae5006f0",
    ),
)

## Kotlin jvm11 toolchain

register_toolchains("//:kotlin_jvm11_toolchain")  # Custom toolchain, default toolchain targets jvm1.8.