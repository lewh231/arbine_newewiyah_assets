#!/usr/bin/env bash

# Usage:
#   ./rename_with_suffix.sh <folder> <suffix>
#
# Example:
#   ./rename_with_suffix.sh ./photos _backup
#
# Result:
#   image.jpg -> image_backup.jpg

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <folder> <suffix>"
    exit 1
fi

FOLDER="$1"
SUFFIX="$2"

if [ ! -d "$FOLDER" ]; then
    echo "Error: '$FOLDER' is not a valid directory."
    exit 1
fi

for FILE in "$FOLDER"/*; do
    # Skip if not a regular file
    [ -f "$FILE" ] || continue

    DIRNAME=$(dirname "$FILE")
    FILENAME=$(basename "$FILE")

    # Split filename and extension
    NAME="${FILENAME%.*}"
    EXT="${FILENAME##*.}"

    # Handle files without extension
    if [ "$NAME" = "$EXT" ]; then
        NEW_NAME="${DIRNAME}/${NAME}${SUFFIX}"
    else
        NEW_NAME="${DIRNAME}/${NAME}${SUFFIX}.${EXT}"
    fi

    mv "$FILE" "$NEW_NAME"

    echo "Renamed: $FILENAME -> $(basename "$NEW_NAME")"
done
