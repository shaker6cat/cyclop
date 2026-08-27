#!/bin/bash
# Build the helper beside the SwiftPM debug executable and run Cyclop in the
# foreground, so media-source diagnostics remain visible in this terminal.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-/private/tmp/cyclop-clang-module-cache}"
export SWIFT_MODULECACHE_PATH="${SWIFT_MODULECACHE_PATH:-/private/tmp/cyclop-swift-module-cache}"
mkdir -p "$CLANG_MODULE_CACHE_PATH" "$SWIFT_MODULECACHE_PATH"

echo "==> building Swift debug executable"
swift build --package-path "$ROOT"
BIN_DIR="$(swift build --package-path "$ROOT" --show-bin-path)"

echo "==> building development Now Playing helper"
clang -dynamiclib -fobjc-arc -O2 \
    -mmacosx-version-min=15.0 \
    -framework Foundation \
    -o "$BIN_DIR/libcyclopmedia.dylib" \
    "$ROOT/Sources/CyclopMediaHelper/helper.m"

echo "==> checking helper"
"$ROOT/Scripts/test-helper.sh" "$BIN_DIR/libcyclopmedia.dylib"
echo "==> launching $BIN_DIR/Cyclop"
exec "$BIN_DIR/Cyclop"
