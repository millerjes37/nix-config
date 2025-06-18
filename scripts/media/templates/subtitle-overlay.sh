#!/usr/bin/env bash

# Subtitle Overlay Script
# Automatically adds professional subtitles to short-form videos
# Optimized for social media platforms with multiple styling options

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"
AUDIO_DIR="$MEDIA_DIR/audio"

# Default settings
DEFAULT_STYLE="modern"
DEFAULT_POSITION="bottom"
DEFAULT_FONT_SIZE="auto"
DEFAULT_OUTPUT_DIR="./subtitled-clips"
DEFAULT_PLATFORMS="tiktok,instagram,youtube"

# Subtitle styles
SUBTITLE_STYLES=(
    "modern"        # Clean, readable style for general content
    "political"     # Professional style with speaker names
    "social"        # Bold, engaging style for social media
    "broadcast"     # Traditional broadcast style
    "minimal"       # Simple, unobtrusive style
    "dramatic"      # High-impact style for key moments
)

# Platform-specific settings
declare -A PLATFORM_FONTS=(
    ["tiktok"]="Liberation Sans Bold"
    ["instagram"]="Liberation Sans Bold"
    ["youtube"]="Liberation Sans"
    ["twitter"]="Liberation Sans"
    ["linkedin"]="Liberation Sans"
)

declare -A PLATFORM_SIZES=(
    ["tiktok"]="32"
    ["instagram"]="28"
    ["youtube"]="24"
    ["twitter"]="22"
    ["linkedin"]="20"
)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

progress() {
    echo -e "${PURPLE}[PROGRESS]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 VIDEO_FILE [SUBTITLE_FILE] [OPTIONS]

Add professional subtitles to short-form videos for social media.

ARGUMENTS:
    VIDEO_FILE          Input video file
    SUBTITLE_FILE       Subtitle file (.srt, .vtt) - auto-generated if not provided

OPTIONS:
    -s, --style STYLE       Subtitle style (default: $DEFAULT_STYLE)
                           Available: ${SUBTITLE_STYLES[*]}
    -p, --platforms LIST    Target platforms (default: $DEFAULT_PLATFORMS)
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    --position POS          Subtitle position: top, center, bottom (default: $DEFAULT_POSITION)
    --font-size SIZE        Font size or 'auto' (default: $DEFAULT_FONT_SIZE)
    --font-family FONT      Font family (platform default if not specified)
    --primary-color COLOR   Primary text color (hex, default: #FFFFFF)
    --outline-color COLOR   Outline color (hex, default: #000000)
    --background-alpha N    Background transparency 0-1 (default: 0.8)
    --max-words-per-line N  Maximum words per subtitle line (default: 6)
    --animation TYPE        Animation: none, fade, slide, typewriter (default: fade)
    --speaker-names         Include speaker names in subtitles
    --keyword-highlight     Highlight political keywords
    --auto-transcribe       Auto-generate transcript if missing
    --quality LEVEL         Output quality: fast, balanced, high (default: balanced)
    --burn-in               Permanently burn subtitles into video
    --soft-subs             Generate separate subtitle tracks
    --batch-process         Process multiple files in directory
    --dry-run              Show what would be processed
    -h, --help             Show this help message

SUBTITLE STYLES:
    modern      - Clean, readable with subtle background
    political   - Professional with speaker identification
    social      - Bold, high-contrast for social media
    broadcast   - Traditional TV-style subtitles
    minimal     - Simple text without background
    dramatic    - High-impact with animations

PLATFORM OPTIMIZATIONS:
    tiktok      - Large, bold text optimized for mobile
    instagram   - Balanced sizing for stories and reels
    youtube     - Clean, readable for horizontal viewing
    twitter     - Compact text for short clips
    linkedin    - Professional styling

EXAMPLES:
    # Auto-transcribe and add modern subtitles
    $0 speech.mp4 --auto-transcribe -s modern

    # Add political-style subtitles with speaker names
    $0 debate.mp4 transcript.srt -s political --speaker-names

    # Create social media versions with bold styling
    $0 rally.mp4 -s social -p tiktok,instagram --keyword-highlight

    # Batch process directory with custom styling
    $0 /path/to/clips --batch-process -s dramatic --animation typewriter

EOF
}

check_dependencies() {
    local missing_deps=()
    
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v ffprobe >/dev/null 2>&1 || missing_deps+=("ffprobe")
    
    # Check if transcription script exists
    [[ -x "$AUDIO_DIR/transcribe.sh" ]] || missing_deps+=("transcribe.sh")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

get_video_info() {
    local video_file="$1"
    
    local video_info
    video_info=$(ffprobe -v quiet -print_format json -show_streams "$video_file")
    
    WIDTH=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | .width')
    HEIGHT=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | .height')
    DURATION=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | .duration // empty')
    
    # Determine video orientation
    if [[ $WIDTH -gt $HEIGHT ]]; then
        ORIENTATION="landscape"
    elif [[ $HEIGHT -gt $WIDTH ]]; then
        ORIENTATION="portrait"
    else
        ORIENTATION="square"
    fi
    
    log "Video info: ${WIDTH}x${HEIGHT} ($ORIENTATION), Duration: ${DURATION}s"
}

auto_transcribe() {
    local video_file="$1"
    local output_dir="$2"
    
    log "Auto-generating transcript for: $(basename "$video_file")"
    
    local base_name
    base_name=$(basename "$video_file" | sed 's/\.[^.]*$//')
    local transcript_dir="$output_dir/transcripts"
    
    mkdir -p "$transcript_dir"
    
    # Use our transcription script
    local transcribe_cmd="$AUDIO_DIR/transcribe.sh \"$video_file\""
    transcribe_cmd="$transcribe_cmd -o \"$transcript_dir\""
    transcribe_cmd="$transcribe_cmd -f srt"
    transcribe_cmd="$transcribe_cmd -m base"  # Fast model for quick processing
    
    if [[ "$POLITICAL_KEYWORDS" == "true" ]]; then
        transcribe_cmd="$transcribe_cmd --political-keywords"
    fi
    
    if [[ "$SPEAKER_NAMES" == "true" ]]; then
        transcribe_cmd="$transcribe_cmd --speaker-detection"
    fi
    
    if eval "$transcribe_cmd"; then
        echo "$transcript_dir/srt/${base_name}.srt"
    else
        error "Auto-transcription failed"
        return 1
    fi
}

process_subtitle_file() {
    local subtitle_file="$1"
    local temp_dir="$2"
    
    log "Processing subtitle file: $(basename "$subtitle_file")"
    
    # Convert to SRT if needed
    local processed_srt="$temp_dir/processed.srt"
    
    case "${subtitle_file##*.}" in
        srt)
            cp "$subtitle_file" "$processed_srt"
            ;;
        vtt)
            # Convert VTT to SRT
            python3 << EOF > "$processed_srt"
import re

with open('$subtitle_file', 'r') as f:
    content = f.read()

# Remove VTT header and convert timestamps
content = re.sub(r'WEBVTT\n\n', '', content)
content = re.sub(r'NOTE.*?\n\n', '', content, flags=re.DOTALL)
content = re.sub(r'(\d{2}):(\d{2}):(\d{2})\.(\d{3})', r'\1:\2:\3,\4', content)

# Add sequence numbers
lines = content.strip().split('\n\n')
numbered_lines = []
for i, line in enumerate(lines, 1):
    if line.strip():
        numbered_lines.append(f"{i}\n{line}")

print('\n\n'.join(numbered_lines))
EOF
            ;;
        *)
            error "Unsupported subtitle format: ${subtitle_file##*.}"
            return 1
            ;;
    esac
    
    # Process subtitles based on options
    if [[ "$MAX_WORDS_PER_LINE" -gt 0 ]]; then
        python3 << EOF > "$temp_dir/word_wrapped.srt"
import re

def wrap_subtitle_text(text, max_words):
    words = text.split()
    if len(words) <= max_words:
        return text
    
    # Split into lines of max_words
    lines = []
    for i in range(0, len(words), max_words):
        lines.append(' '.join(words[i:i + max_words]))
    
    return '\n'.join(lines)

with open('$processed_srt', 'r') as f:
    content = f.read()

# Process each subtitle
blocks = content.strip().split('\n\n')
processed_blocks = []

for block in blocks:
    lines = block.split('\n')
    if len(lines) >= 3:
        number = lines[0]
        timestamp = lines[1]
        text = ' '.join(lines[2:])
        
        # Wrap text
        wrapped_text = wrap_subtitle_text(text, $MAX_WORDS_PER_LINE)
        
        processed_blocks.append(f"{number}\n{timestamp}\n{wrapped_text}")

print('\n\n'.join(processed_blocks))
EOF
        mv "$temp_dir/word_wrapped.srt" "$processed_srt"
    fi
    
    echo "$processed_srt"
}

generate_subtitle_filter() {
    local subtitle_file="$1"
    local platform="$2"
    
    # Get platform-specific settings
    local font_family="${PLATFORM_FONTS[$platform]:-Liberation Sans}"
    local base_font_size="${PLATFORM_SIZES[$platform]:-24}"
    
    # Calculate font size
    local font_size="$base_font_size"
    if [[ "$FONT_SIZE" != "auto" ]]; then
        font_size="$FONT_SIZE"
    else
        # Auto-size based on video dimensions
        if [[ $WIDTH -lt 720 ]]; then
            font_size=$((base_font_size - 4))
        elif [[ $WIDTH -gt 1920 ]]; then
            font_size=$((base_font_size + 6))
        fi
    fi
    
    # Override font family if specified
    if [[ -n "$FONT_FAMILY" ]]; then
        font_family="$FONT_FAMILY"
    fi
    
    # Position calculation
    local y_position
    case "$POSITION" in
        top)
            y_position="h*0.1"
            ;;
        center)
            y_position="(h-text_h)/2"
            ;;
        bottom)
            y_position="h*0.85-text_h"
            ;;
        *)
            y_position="h*0.85-text_h"  # Default to bottom
            ;;
    esac
    
    # Build subtitle filter based on style
    local subtitle_filter=""
    
    case "$STYLE" in
        modern)
            subtitle_filter="subtitles='$subtitle_file':force_style='"
            subtitle_filter+="FontName=$font_family,"
            subtitle_filter+="FontSize=$font_size,"
            subtitle_filter+="PrimaryColour=$PRIMARY_COLOR,"
            subtitle_filter+="OutlineColour=$OUTLINE_COLOR,"
            subtitle_filter+="BackColour=&H80000000,"
            subtitle_filter+="BorderStyle=3,"
            subtitle_filter+="Outline=2,"
            subtitle_filter+="Shadow=1,"
            subtitle_filter+="Alignment=2,"
            subtitle_filter+="MarginV=60'"
            ;;
            
        political)
            subtitle_filter="subtitles='$subtitle_file':force_style='"
            subtitle_filter+="FontName=$font_family,"
            subtitle_filter+="FontSize=$font_size,"
            subtitle_filter+="PrimaryColour=&HFFFFFF,"
            subtitle_filter+="OutlineColour=&H000000,"
            subtitle_filter+="BackColour=&H80000080,"
            subtitle_filter+="BorderStyle=3,"
            subtitle_filter+="Outline=3,"
            subtitle_filter+="Shadow=2,"
            subtitle_filter+="Alignment=2,"
            subtitle_filter+="MarginV=50'"
            ;;
            
        social)
            subtitle_filter="subtitles='$subtitle_file':force_style='"
            subtitle_filter+="FontName=$font_family Bold,"
            subtitle_filter+="FontSize=$((font_size + 4)),"
            subtitle_filter+="PrimaryColour=&HFFFFFF,"
            subtitle_filter+="OutlineColour=&H000000,"
            subtitle_filter+="BackColour=&HC0000000,"
            subtitle_filter+="BorderStyle=1,"
            subtitle_filter+="Outline=4,"
            subtitle_filter+="Shadow=0,"
            subtitle_filter+="Alignment=2,"
            subtitle_filter+="MarginV=80'"
            ;;
            
        broadcast)
            subtitle_filter="subtitles='$subtitle_file':force_style='"
            subtitle_filter+="FontName=$font_family,"
            subtitle_filter+="FontSize=$font_size,"
            subtitle_filter+="PrimaryColour=&HFFFFFF,"
            subtitle_filter+="OutlineColour=&H000000,"
            subtitle_filter+="BackColour=&H80000000,"
            subtitle_filter+="BorderStyle=1,"
            subtitle_filter+="Outline=1,"
            subtitle_filter+="Shadow=1,"
            subtitle_filter+="Alignment=2,"
            subtitle_filter+="MarginV=40'"
            ;;
            
        minimal)
            subtitle_filter="subtitles='$subtitle_file':force_style='"
            subtitle_filter+="FontName=$font_family,"
            subtitle_filter+="FontSize=$font_size,"
            subtitle_filter+="PrimaryColour=&HFFFFFF,"
            subtitle_filter+="OutlineColour=&H000000,"
            subtitle_filter+="BorderStyle=0,"
            subtitle_filter+="Outline=2,"
            subtitle_filter+="Shadow=0,"
            subtitle_filter+="Alignment=2,"
            subtitle_filter+="MarginV=60'"
            ;;
            
        dramatic)
            subtitle_filter="subtitles='$subtitle_file':force_style='"
            subtitle_filter+="FontName=$font_family Bold,"
            subtitle_filter+="FontSize=$((font_size + 6)),"
            subtitle_filter+="PrimaryColour=&H00FFFF,"
            subtitle_filter+="OutlineColour=&H000000,"
            subtitle_filter+="BackColour=&H80000000,"
            subtitle_filter+="BorderStyle=3,"
            subtitle_filter+="Outline=4,"
            subtitle_filter+="Shadow=2,"
            subtitle_filter+="Alignment=2,"
            subtitle_filter+="MarginV=70'"
            ;;
    esac
    
    echo "$subtitle_filter"
}

create_subtitled_video() {
    local video_file="$1"
    local subtitle_file="$2"
    local platform="$3"
    local output_file="$4"
    
    log "Creating subtitled video for $platform: $(basename "$output_file")"
    
    # Generate subtitle filter
    local subtitle_filter
    subtitle_filter=$(generate_subtitle_filter "$subtitle_file" "$platform")
    
    # Quality settings
    local video_settings=""
    case "$QUALITY" in
        fast)
            video_settings="-c:v libx264 -preset ultrafast -crf 28"
            ;;
        balanced)
            video_settings="-c:v libx264 -preset medium -crf 23"
            ;;
        high)
            video_settings="-c:v libx264 -preset slow -crf 18"
            ;;
    esac
    
    # Platform-specific video adjustments
    local platform_filter=""
    case "$platform" in
        tiktok)
            # Ensure 9:16 aspect ratio
            platform_filter="scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920"
            ;;
        instagram)
            # Square format for posts, vertical for stories
            if [[ "$ORIENTATION" == "portrait" ]]; then
                platform_filter="scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920"
            else
                platform_filter="scale=1080:1080:force_original_aspect_ratio=increase,crop=1080:1080"
            fi
            ;;
        youtube)
            # 16:9 horizontal format
            platform_filter="scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080"
            ;;
        twitter|linkedin)
            # Balanced horizontal format
            platform_filter="scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720"
            ;;
    esac
    
    # Build FFmpeg command
    local ffmpeg_cmd="ffmpeg -i \"$video_file\""
    
    # Add video filters
    local video_filter=""
    if [[ -n "$platform_filter" ]]; then
        video_filter="$platform_filter"
    fi
    
    if [[ -n "$video_filter" ]]; then
        ffmpeg_cmd="$ffmpeg_cmd -vf \"$video_filter,$subtitle_filter\""
    else
        ffmpeg_cmd="$ffmpeg_cmd -vf \"$subtitle_filter\""
    fi
    
    # Add audio and output settings
    ffmpeg_cmd="$ffmpeg_cmd -c:a aac -b:a 128k $video_settings"
    ffmpeg_cmd="$ffmpeg_cmd -movflags +faststart \"$output_file\" -y"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would create: $output_file"
        echo "Command: $ffmpeg_cmd"
        return 0
    fi
    
    # Execute FFmpeg command
    if eval "$ffmpeg_cmd" 2>/dev/null; then
        success "Created: $(basename "$output_file")"
        return 0
    else
        error "Failed to create subtitled video for $platform"
        return 1
    fi
}

process_single_video() {
    local video_file="$1"
    local subtitle_file="$2"
    local output_dir="$3"
    
    local base_name
    base_name=$(basename "$video_file" | sed 's/\.[^.]*$//')
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Auto-transcribe if no subtitle file provided
    if [[ -z "$subtitle_file" && "$AUTO_TRANSCRIBE" == "true" ]]; then
        subtitle_file=$(auto_transcribe "$video_file" "$temp_dir") || {
            error "Failed to auto-transcribe: $video_file"
            rm -rf "$temp_dir"
            return 1
        }
    elif [[ -z "$subtitle_file" ]]; then
        error "No subtitle file provided and auto-transcribe not enabled"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Process subtitle file
    local processed_srt
    processed_srt=$(process_subtitle_file "$subtitle_file" "$temp_dir") || {
        error "Failed to process subtitle file"
        rm -rf "$temp_dir"
        return 1
    }
    
    # Get video information
    get_video_info "$video_file"
    
    # Create subtitled versions for each platform
    for platform in ${PLATFORMS//,/ }; do
        local platform_dir="$output_dir/$platform"
        mkdir -p "$platform_dir"
        
        local output_file="$platform_dir/${base_name}_subtitled.mp4"
        
        create_subtitled_video "$video_file" "$processed_srt" "$platform" "$output_file"
    done
    
    # Cleanup
    rm -rf "$temp_dir"
}

main() {
    local video_file=""
    local subtitle_file=""
    
    # Set defaults
    STYLE="$DEFAULT_STYLE"
    PLATFORMS="$DEFAULT_PLATFORMS"
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    POSITION="$DEFAULT_POSITION"
    FONT_SIZE="$DEFAULT_FONT_SIZE"
    FONT_FAMILY=""
    PRIMARY_COLOR="&HFFFFFF"
    OUTLINE_COLOR="&H000000"
    BACKGROUND_ALPHA="0.8"
    MAX_WORDS_PER_LINE=6
    ANIMATION="fade"
    SPEAKER_NAMES="false"
    POLITICAL_KEYWORDS="false"
    AUTO_TRANSCRIBE="false"
    QUALITY="balanced"
    BURN_IN="true"
    SOFT_SUBS="false"
    BATCH_PROCESS="false"
    DRY_RUN="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--style)
                STYLE="$2"
                shift 2
                ;;
            -p|--platforms)
                PLATFORMS="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            --position)
                POSITION="$2"
                shift 2
                ;;
            --font-size)
                FONT_SIZE="$2"
                shift 2
                ;;
            --font-family)
                FONT_FAMILY="$2"
                shift 2
                ;;
            --primary-color)
                PRIMARY_COLOR="$2"
                shift 2
                ;;
            --outline-color)
                OUTLINE_COLOR="$2"
                shift 2
                ;;
            --background-alpha)
                BACKGROUND_ALPHA="$2"
                shift 2
                ;;
            --max-words-per-line)
                MAX_WORDS_PER_LINE="$2"
                shift 2
                ;;
            --animation)
                ANIMATION="$2"
                shift 2
                ;;
            --speaker-names)
                SPEAKER_NAMES="true"
                shift
                ;;
            --keyword-highlight)
                POLITICAL_KEYWORDS="true"
                shift
                ;;
            --auto-transcribe)
                AUTO_TRANSCRIBE="true"
                shift
                ;;
            --quality)
                QUALITY="$2"
                shift 2
                ;;
            --burn-in)
                BURN_IN="true"
                shift
                ;;
            --soft-subs)
                SOFT_SUBS="true"
                shift
                ;;
            --batch-process)
                BATCH_PROCESS="true"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                if [[ -z "$video_file" ]]; then
                    video_file="$1"
                elif [[ -z "$subtitle_file" ]]; then
                    subtitle_file="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Validate style
    if [[ ! " ${SUBTITLE_STYLES[*]} " =~ " $STYLE " ]]; then
        error "Invalid style: $STYLE"
        echo "Available styles: ${SUBTITLE_STYLES[*]}"
        exit 1
    fi
    
    # Validate input
    if [[ -z "$video_file" ]]; then
        error "Video file required"
        usage
        exit 1
    fi
    
    if [[ ! -e "$video_file" ]]; then
        error "Video file not found: $video_file"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    log "Starting subtitle overlay process..."
    log "Style: $STYLE"
    log "Platforms: $PLATFORMS"
    log "Output: $OUTPUT_DIR"
    
    # Process video(s)
    if [[ "$BATCH_PROCESS" == "true" && -d "$video_file" ]]; then
        # Batch processing
        find "$video_file" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" \) | \
        while read -r file; do
            local sub_file=""
            # Look for matching subtitle file
            local base_name
            base_name=$(basename "$file" | sed 's/\.[^.]*$//')
            for ext in srt vtt; do
                local potential_sub="$(dirname "$file")/${base_name}.${ext}"
                if [[ -f "$potential_sub" ]]; then
                    sub_file="$potential_sub"
                    break
                fi
            done
            
            process_single_video "$file" "$sub_file" "$OUTPUT_DIR"
        done
    else
        # Single file processing
        process_single_video "$video_file" "$subtitle_file" "$OUTPUT_DIR"
    fi
    
    success "Subtitle overlay complete! Output saved to: $OUTPUT_DIR"
    
    # Show summary
    if [[ "$DRY_RUN" == "false" ]]; then
        local total_videos=0
        for platform in ${PLATFORMS//,/ }; do
            local platform_count
            platform_count=$(find "$OUTPUT_DIR/$platform" -name "*.mp4" 2>/dev/null | wc -l || echo 0)
            total_videos=$((total_videos + platform_count))
            log "$platform: $platform_count videos"
        done
        log "Total subtitled videos created: $total_videos"
    fi
}

# Run main function
main "$@" 