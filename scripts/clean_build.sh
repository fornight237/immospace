#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Cleaning build artifacts in $ROOT_DIR"
rm -rf "$ROOT_DIR/build" || true
rm -rf "$ROOT_DIR/app/build" || true
rm -rf "$ROOT_DIR/.gradle" || true
rm -rf "$ROOT_DIR/app/.gradle" || true
find "$ROOT_DIR" -type d -name "build" -prune -exec rm -rf '{}' + || true
echo "Done. You can now open the project in Android Studio and run a clean build."
