#!/bin/bash
# Build Cyclop.app, then run its signed bundle executable in the foreground so
# stdout/stderr diagnostics remain visible in this terminal. The bundle was
# already launched through LaunchServices once to establish TCC identity.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-/private/tmp/cyclop-clang-module-cache}"
export SWIFT_MODULECACHE_PATH="${SWIFT_MODULECACHE_PATH:-/private/tmp/cyclop-swift-module-cache}"
mkdir -p "$CLANG_MODULE_CACHE_PATH" "$SWIFT_MODULECACHE_PATH"

APP="$ROOT/build/Cyclop.app"
echo "==> assembling signed development app bundle"
"$ROOT/Scripts/bundle.sh" debug
echo "==> launching $APP in the foreground"
exec "$APP/Contents/MacOS/Cyclop"
