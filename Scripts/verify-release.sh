#!/bin/bash
#
# verify-release.sh
# swift-components
#
# Locally reproduces everything CI/release.yml checks: `swift build`/`swift test`
# on macOS, `swift build --package-path Tools`, and an `xcodebuild` build of both
# the SharedComponents and UIComponents schemes for iOS and watchOS. Run this
# before tagging a release so a platform-specific compile error (e.g. an API
# unavailable on watchOS) is caught locally instead of surfacing only in CI.
#
# Usage: Scripts/verify-release.sh

set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> swift build (macOS)"
swift build

echo "==> swift test (macOS)"
swift test

echo "==> swift build --package-path Tools (macOS)"
swift build --package-path Tools

for platform in iOS watchOS; do
    destination="generic/platform=$platform"
    for scheme in SharedComponents UIComponents; do
        echo "==> xcodebuild build -scheme $scheme -destination '$destination'"
        xcodebuild build -scheme "$scheme" -destination "$destination" | xcbeautify 2>/dev/null \
            || xcodebuild build -scheme "$scheme" -destination "$destination"
    done
done

echo "==> All platforms build successfully."
