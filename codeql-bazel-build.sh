#!/bin/bash
# A wrapper around Bazel which helps run CodeQL against Bazel targets.
# Otherwise, Bazel ignores LD_PRELOAD and CodeQL is not run

set -o errexit
set -o pipefail
set -o xtrace

export USE_BAZEL_VERSION=5.1.0

target="$1"
bazel shutdown

# Environment variables set by CodeQL and needed to pass through to Bazel
bazel_flags="--action_env=CODEQL_PLATFORM_DLL_EXTENSION "
bazel_flags+="--action_env=CODEQL_SCRATCH_DIR "
bazel_flags+="--action_env=CODEQL_THREADS "
bazel_flags+="--action_env=CODEQL_EXTRACTOR_JAVA_WIP_DATABASE "
bazel_flags+="--action_env=CODEQL_EXTRACTOR_JAVA_LOG_DIR "
bazel_flags+="--action_env=CODEQL_EXTRACTOR_JAVA_ROOT "
bazel_flags+="--action_env=CODEQL_EXTRACTOR_JAVA_TRAP_DIR "
bazel_flags+="--action_env=CODEQL_JAVA_HOME "
bazel_flags+="--action_env=CODEQL_EXTRACTOR_JAVA_SCRATCH_DIR "
bazel_flags+="--action_env=CODEQL_EXTRACTOR_JAVA_SOURCE_ARCHIVE_DIR "
bazel_flags+="--action_env=CODEQL_DIST "
bazel_flags+="--action_env=CODEQL_PLATFORM "
bazel_flags+="--action_env=SEMMLE_JAVA_TOOL_OPTIONS "
bazel_flags+="--action_env=SEMMLE_PRELOAD_libtrace "
bazel_flags+="--action_env=SEMMLE_PRELOAD_libtrace32 "
bazel_flags+="--action_env=SEMMLE_PRELOAD_libtrace64 "
bazel_flags+="--action_env=ODASA_TRACER_CONFIGURATION "
bazel_flags+="--action_env=CODEQL_RUNNER "

# Values which are hardcoded as they otherwise change and invalidate the bazel cache
bazel_flags+="--action_env=SEMMLE_EXECP=$SEMMLE_EXECP "
bazel_flags+="--action_env=CODEQL_EXEC_ARGS_OFFSET=$CODEQL_EXEC_ARGS_OFFSET "
bazel_flags+="--action_env=CODEQL_PARENT_ID=$CODEQL_PARENT_ID "
bazel_flags+="--action_env=LD_PRELOAD=$LD_PRELOAD "

# Do not inject codeql into non-bazel processes, but save the value in case we need it later.
# (otherwise breaks protoc and other bazel GenRule targets)
export CODEQL_LD_PRELOAD=$LD_PRELOAD
unset LD_PRELOAD

# Invalidate previous cached artifacts and do a full rebuild for the scan
BUILD_TIMESTAMP_FOR_CI=$(date +%s)
export BUILD_TIMESTAMP_FOR_CI
bazel_flags+="--action_env=BUILD_TIMESTAMP_FOR_CI --remote_upload_local_results=false --remote_accept_cached=false "

# Required for CodeQL
bazel_flags+="--spawn_strategy=local "

# Helpful when debugging
bazel_flags+="--verbose_failures "

# Add more memory
bazel_pre_flags="--host_jvm_args=-Xmx8g "

# First build the libraries without CodeQL enabled (by removing the LD_PRELOAD libraries)
# This lets us populate the bazel cache with these artifacts without CodeQL running
mv "${SEMMLE_PRELOAD_libtrace32}" "${SEMMLE_PRELOAD_libtrace32}.bak"
mv "${SEMMLE_PRELOAD_libtrace64}" "${SEMMLE_PRELOAD_libtrace64}.bak"

# Exclude out certain bazel deps for performance
skip_deps=$(bazel query "attr('tags', 'skip_codeql', deps($target))" | tr "\n", " ")
for skip_dep in $skip_deps; do
    bazel ${bazel_pre_flags} build ${bazel_flags} $skip_dep
done

# Re-enable CodeQL and scan the rest of the target by building it
mv "${SEMMLE_PRELOAD_libtrace32}.bak" "${SEMMLE_PRELOAD_libtrace32}"
mv "${SEMMLE_PRELOAD_libtrace64}.bak" "${SEMMLE_PRELOAD_libtrace64}"

bazel ${bazel_pre_flags} build ${bazel_flags} $target

# Replaces USE_BAZEL_VERSION=5.1.0 bazel build --spawn_strategy=local --nouse_action_cache --noremote_accept_cached --noremote_upload_local_results 