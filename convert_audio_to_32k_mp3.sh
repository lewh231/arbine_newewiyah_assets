#!/usr/bin/env bash

# Usage:
#   ./convert_to_32k_mp3.sh <input_folder> <output_folder>
#
# Example:
#   ./convert_to_32k_mp3.sh ./audios ./output

set -euo pipefail

INPUT_FOLDER="${1:-.}"
OUTPUT_FOLDER="${2:-output}"

if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: '$INPUT_FOLDER' is not a directory."
    exit 1
fi

mkdir -p "$OUTPUT_FOLDER"

shopt -s nullglob

for FILE in "$INPUT_FOLDER"/*; do
    [ -f "$FILE" ] || continue

    BASENAME="$(basename "$FILE")"
    NAME="${BASENAME%.*}"

    # Get bitrate in bits/sec
    BITRATE=$(ffprobe -v error \
        -select_streams a:0 \
        -show_entries stream=bit_rate \
        -of default=noprint_wrappers=1:nokey=1 \
        "$FILE")

    # Skip files with unknown bitrate
    if [ -z "$BITRATE" ]; then
        echo "Skipping '$BASENAME' (could not detect bitrate)"
        continue
    fi

    KBPS=$((BITRATE / 1000))

    echo "Processing: $BASENAME (${KBPS} kbps)"

    OUTPUT="${OUTPUT_FOLDER}/${NAME}.mp3"

    if [ "$KBPS" -gt 32 ]; then
        echo "  -> Converting to 32 kbps MP3"

        ffmpeg -y -i "$FILE" \
            -vn \
            -c:a libmp3lame \
            -b:a 32k \
            "$OUTPUT"

    else
        echo "  -> Keeping original bitrate"

        ffmpeg -y -i "$FILE" \
            -vn \
            -c:a libmp3lame \
            -b:a "${KBPS}k" \
            "$OUTPUT"
    fi

    echo "  -> Saved as: $(basename "$OUTPUT")"
    echo
done