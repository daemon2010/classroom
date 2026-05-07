#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

credentials_path="assets/credentials.json"

if [[ ! -f "$credentials_path" ]]; then
  echo "Missing $credentials_path"
  echo "Place the Google Desktop app connection file there before building."
  exit 1
fi

credentials_base64="$(base64 < "$credentials_path" | tr -d '\n')"

flutter build macos --dart-define="GOOGLE_CREDENTIALS_BASE64=$credentials_base64"
