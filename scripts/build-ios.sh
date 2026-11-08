#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
REFLEX_REV=2b992b7eddbf0420a8dcc66630b3d3abfe1a9a48
WORK="${RUNNER_TEMP:-/tmp}/nbflex-reflex-build"
mkdir -p "$WORK" "$ROOT/Sources/Reflex" "$ROOT/dist" "$ROOT/build-logs"
echo "== Toolchain =="
xcodebuild -version
xcrun swift --version
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
if [[ ! -d "$WORK/reflex/.git" ]]; then
  git clone https://github.com/FLEXTool/Reflex.git "$WORK/reflex"
fi
git -C "$WORK/reflex" checkout --detach "$REFLEX_REV"
cp "$WORK/reflex/Reflex/"*.swift "$ROOT/Sources/Reflex/"
cp "$WORK/reflex/LICENSE" "$ROOT/dist/LICENSE-Reflex.txt"
# Compile a constructor which selects FLEX's existing Swift mirror integration.
xcrun --sdk iphoneos clang -arch arm64 -miphoneos-version-min=13.0 \
  -fobjc-arc -fblocks -c "$ROOT/Support/ReflexBootstrap.m" -o "$WORK/Bootstrap.o"
BUILD="$WORK/ios"
xcrun swift build --configuration release --product NBFLEXReflex \
  --triple arm64-apple-ios13.0 --sdk "$SDK" --scratch-path "$BUILD" \
  -Xlinker -L -Xlinker "$ROOT/Support/link" \
  -Xlinker "$WORK/Bootstrap.o" \
  2>&1 | tee "$ROOT/build-logs/swift-build.log"
BIN_DIR="$(xcrun swift build --configuration release --show-bin-path \
  --triple arm64-apple-ios13.0 --sdk "$SDK" --scratch-path "$BUILD")"
LIB="$BIN_DIR/libNBFLEXReflex.dylib"
test -f "$LIB"
cp "$LIB" "$ROOT/dist/libNBFLEXReflex.dylib"
cp "$ROOT/README.md" "$ROOT/dist/README.md"
cp "$ROOT/Support/LICENSE-FLEX.txt" "$ROOT/dist/LICENSE-FLEX.txt"
cp "$ROOT/Support/provenance.json" "$ROOT/dist/provenance.json"
ECHO_LICENSE="$(find "$BUILD/checkouts" -ipath '*/echo/LICENSE*' -type f | head -n 1)"
if [[ -n "$ECHO_LICENSE" ]]; then cp "$ECHO_LICENSE" "$ROOT/dist/LICENSE-Echo.txt"; fi
ATOMICS_LICENSE="$(find "$BUILD/checkouts" -path '*/swift-atomics/LICENSE*' -type f | head -n 1)"
if [[ -n "$ATOMICS_LICENSE" ]]; then cp "$ATOMICS_LICENSE" "$ROOT/dist/LICENSE-swift-atomics.txt"; fi
codesign --force --sign - "$ROOT/dist/libNBFLEXReflex.dylib"
codesign --verify --verbose=2 "$ROOT/dist/libNBFLEXReflex.dylib"
xcrun lipo -info "$ROOT/dist/libNBFLEXReflex.dylib" | tee "$ROOT/build-logs/architecture.txt"
otool -L "$ROOT/dist/libNBFLEXReflex.dylib" | tee "$ROOT/build-logs/dependencies.txt"
nm -gU "$ROOT/dist/libNBFLEXReflex.dylib" > "$ROOT/build-logs/exports.txt"
grep -q 'FLEXSwiftMirror' "$ROOT/build-logs/exports.txt"
grep -q '@loader_path/FakeTools.dylib' "$ROOT/build-logs/dependencies.txt"
if grep -q ' _OBJC_CLASS_\$_FLEXIvar$' "$ROOT/build-logs/exports.txt"; then
  echo 'Unexpected duplicate FLEXIvar definition' >&2
  exit 1
fi
shasum -a 256 "$ROOT/dist/libNBFLEXReflex.dylib" > "$ROOT/dist/SHA256SUMS.txt"
echo 'Build and static validation succeeded; iPhone runtime testing is still required.'
