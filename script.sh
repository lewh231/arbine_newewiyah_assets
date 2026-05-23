#!/usr/bin/env bash

# Generates manifest.json for all audio files in current directory
# Usage:
#   chmod +x generate_manifest.sh
#   ./generate_manifest.sh v1.0 https://github.com/USER/REPO/releases/download/v1.0

VERSION="$1"
BASE_URL="$2"

if [ -z "$VERSION" ] || [ -z "$BASE_URL" ]; then
  echo "Usage:"
  echo "./generate_manifest.sh <version> <base_url>"
  exit 1
fi

OUTPUT="manifest.json"

echo "{" > "$OUTPUT"
echo "  \"version\": \"$VERSION\"," >> "$OUTPUT"
echo "  \"baseUrl\": \"$BASE_URL\"," >> "$OUTPUT"
echo "  \"voicedBy\": [\"ኣቡ ዩሱፍ ዓብዳሏህ ኢብኑ ዑመር\", \"ኣቡበከር ኣቡ ዓብዲላህ\"]," >> "$OUTPUT"
echo "  \"hashingAlgorithm\": \"SHA-256\"," >> "$OUTPUT"
echo "  \"files\": [" >> "$OUTPUT"

FIRST=true

find . -maxdepth 3 -type f \( -iname "*.mp3" -o -iname "*.wav" -o -iname "*.m4a" \) | sort | while read -r FILE; do
  FILENAME=$(basename "$FILE")
  PARENT_FOLDER=$(basename "$(dirname "$FILE")")

  # Generate ID:
  # H001_name.mp3 -> 001
  ID=$(echo "$FILENAME" | sed -E 's/^H([0-9]+)_(.*)\.(mp3|wav|m4a)$/\1/I')

  # Cross-platform file size
  if stat --version >/dev/null 2>&1; then
    SIZE=$(stat -c%s "$FILE")
  else
    SIZE=$(stat -f%z "$FILE")
  fi

  # Cross-platform SHA-256 hash
  if command -v sha256sum >/dev/null 2>&1; then
    HASH=$(sha256sum "$FILE" | awk '{print $1}')
  else
    HASH=$(shasum -a 256 "$FILE" | awk '{print $1}')
  fi

  if [ "$FIRST" = true ]; then
    FIRST=false
  else
    echo "," >> "$OUTPUT"
  fi

  cat >> "$OUTPUT" <<EOF
    {
      "id": "$ID",
      "name": "$FILENAME",
      "size": $SIZE,
      "hash": "$HASH",
      "url": "$BASE_URL/$PARENT_FOLDER/$FILENAME",
      "voicedBy": "$PARENT_FOLDER"
    }
EOF

done

echo "" >> "$OUTPUT"
echo "  ]" >> "$OUTPUT"
echo "}" >> "$OUTPUT"

echo "Generated $OUTPUT"