#!/usr/bin/env bash

# Scene Detection Utility
# Advanced scene change detection and transition analysis for video content

set -euo pipefail

# Default settings
DEFAULT_THRESHOLD=0.3
DEFAULT_MIN_SCENE_LENGTH=2.0
DEFAULT_OUTPUT_FORMAT="json"

# Color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 INPUT_VIDEO [OPTIONS]

Advanced scene detection and transition analysis.

OPTIONS:
    -t, --threshold FLOAT   Scene change threshold (default: $DEFAULT_THRESHOLD)
    -m, --min-length FLOAT  Minimum scene length in seconds (default: $DEFAULT_MIN_SCENE_LENGTH)
    -o, --output FILE       Output file for scene data
    -f, --format FORMAT     Output format: json, csv, txt (default: $DEFAULT_OUTPUT_FORMAT)
    --transitions           Analyze transition types
    --thumbnails           Generate scene thumbnails
    -h, --help             Show this help message

EXAMPLES:
    # Basic scene detection
    $0 video.mp4 -t 0.4

    # Generate thumbnails for each scene
    $0 video.mp4 --thumbnails -o scenes.json

EOF
}

detect_scenes() {
    local input_file="$1"
    local threshold="$2"
    local min_length="$3"
    local temp_dir="$4"
    
    log "Detecting scenes with threshold: $threshold"
    
    # Run scene detection
    ffmpeg -i "$input_file" \
           -filter:v "select='gt(scene,$threshold)',showinfo" \
           -f null - 2> "$temp_dir/scene_detect.log"
    
    # Parse scene changes
    grep "pts_time:" "$temp_dir/scene_detect.log" | \
    sed 's/.*pts_time:\([0-9.]*\).*/\1/' | \
    awk -v min_len="$min_length" '
    BEGIN { prev_time = 0; scene_num = 1 }
    {
        current_time = $1
        duration = current_time - prev_time
        
        if (duration >= min_len || NR == 1) {
            if (NR > 1) {
                print scene_num, prev_time, current_time, duration
                scene_num++
            }
            prev_time = current_time
        }
    }' > "$temp_dir/scenes.txt"
    
    log "Found $(wc -l < "$temp_dir/scenes.txt") scenes"
}

main() {
    local input_file=""
    local threshold="$DEFAULT_THRESHOLD"
    local min_length="$DEFAULT_MIN_SCENE_LENGTH"
    local output_file=""
    local output_format="$DEFAULT_OUTPUT_FORMAT"
    local analyze_transitions="false"
    local generate_thumbnails="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--threshold)
                threshold="$2"
                shift 2
                ;;
            -m|--min-length)
                min_length="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -f|--format)
                output_format="$2"
                shift 2
                ;;
            --transitions)
                analyze_transitions="true"
                shift
                ;;
            --thumbnails)
                generate_thumbnails="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                exit 1
                ;;
            *)
                input_file="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$input_file" ]]; then
        echo "Input file required" >&2
        usage
        exit 1
    fi
    
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT
    
    detect_scenes "$input_file" "$threshold" "$min_length" "$temp_dir"
    
    if [[ -n "$output_file" ]]; then
        cp "$temp_dir/scenes.txt" "$output_file"
        log "Scene data saved to: $output_file"
    else
        cat "$temp_dir/scenes.txt"
    fi
}

main "$@" 