#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-platform=iOS Simulator,name=iPhone 17,OS=26.2}"
REPORT="$ROOT/BUILD_REPORT_4.0.0.txt"

demos=(
  sdkmobile-demo-selphi-pods
  sdkmobile-demo-nfc-pods
  sdkmobile-demo-videoid
  sdkmobile-demo-videocall-pods
  sdkmobile-demo-voiceid-pods
  sdkmobile-demo-phingers-pods
  sdkmobile-demo-signature-pods
  sdkmobile-demo-selphi-classic-pods
  sdkmobile-demo-selphid-classic-pods
  sdkmobile-demo-classic-pods
  sdkmobile-demo-classic-videorcording.pods
  sdkmobile-demo-idv
  onboarding-fileuploader.demo
  sdkmobile-demo-full
)

: > "$REPORT"

for demo in "${demos[@]}"; do
  dir="$ROOT/$demo"
  echo "==== $demo ====" | tee -a "$REPORT"
  if [[ ! -d "$dir" ]]; then
    echo "MISSING dir" | tee -a "$REPORT"
    continue
  fi
  (
    cd "$dir"
    if ! pod install --repo-update >>"$REPORT" 2>&1; then
      echo "FAIL pod install" | tee -a "$REPORT"
      exit 1
    fi
    ws="demosdk.xcworkspace"
    if [[ ! -d "$ws" ]]; then
      echo "FAIL no workspace" | tee -a "$REPORT"
      exit 1
    fi
    if xcodebuild -workspace "$ws" -scheme demosdk -destination "$DEST" -quiet build >>"$REPORT" 2>&1; then
      echo "OK build" | tee -a "$REPORT"
    else
      echo "FAIL build" | tee -a "$REPORT"
      exit 1
    fi
  ) || true
  echo "" >> "$REPORT"
done

echo "Report: $REPORT"
