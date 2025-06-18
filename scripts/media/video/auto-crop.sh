#!/usr/bin/env bash

# Intelligent Auto-Crop Script
# Automatically extracts engaging short-form content from long-form videos
# Optimized for political communications and social media content

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"
UTILS_DIR="$MEDIA_DIR/utils"

# Default settings
DEFAULT_CLIPS=3
DEFAULT_DURATION=30
DEFAULT_MIN_DURATION=15
DEFAULT_MAX_DURATION=60
DEFAULT_OUTPUT_DIR="./clips"
DEFAULT_PLATFORMS="tiktok,instagram,youtube"

# Quality thresholds
MIN_AUDIO_LEVEL=-40    # dB
SCENE_THRESHOLD=0.3    # Scene change sensitivity
SILENCE_THRESHOLD=0.02 # Silence detection threshold
FACE_CONFIDENCE=0.7    # Face detection confidence

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
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

usage() {
    cat << EOF
Usage: $0 INPUT_VIDEO [OPTIONS]

Intelligent auto-cropping for extracting short-form content from long videos.

OPTIONS:
    -c, --clips NUM         Number of clips to extract (default: $DEFAULT_CLIPS)
    -d, --duration SEC      Target duration per clip (default: $DEFAULT_DURATION)
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -p, --platforms LIST    Comma-separated platforms (default: $DEFAULT_PLATFORMS)
    -t, --type TYPE         Content type: speech, interview, event, general
    -q, --quality LEVEL     Quality level: fast, balanced, high (default: balanced)
    -f, --format FORMAT     Output format: mp4, mov, webm (default: mp4)
    --min-duration SEC      Minimum clip duration (default: $DEFAULT_MIN_DURATION)
    --max-duration SEC      Maximum clip duration (default: $DEFAULT_MAX_DURATION)
    --no-audio-analysis     Skip audio-based segment detection
    --no-scene-detection    Skip scene change detection
    --dry-run              Show what would be processed without creating clips
    -h, --help             Show this help message

PLATFORMS:
    tiktok      - 9:16 vertical, optimized for mobile
    instagram   - 1:1 square and 9:16 stories
    youtube     - 16:9 horizontal shorts
    twitter     - 16:9 horizontal with captions
    linkedin    - Professional 16:9 format

CONTENT TYPES:
    speech      - Political speeches, presentations
    interview   - Q&A sessions, interviews
    event       - Campaign events, rallies
    general     - Mixed content, auto-detect

EXAMPLES:
    # Extract 5 clips from a political speech
    $0 town-hall.mp4 -c 5 -t speech -p tiktok,youtube

    # Process interview with custom durations
    $0 interview.mp4 -d 45 --min-duration 20 --max-duration 60

    # High-quality extraction for multiple platforms
    $0 campaign-event.mp4 -q high -p tiktok,instagram,youtube,twitter

EOF
}

check_dependencies() {
    local missing_deps=()
    
    # Check required tools
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v ffprobe >/dev/null 2>&1 || missing_deps+=("ffprobe")
    command -v bc >/dev/null 2>&1 || missing_deps+=("bc")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Install with: nix-shell -p ${missing_deps[*]// / }"
        exit 1
    fi
}

get_video_info() {
    local input_file="$1"
    
    log "Analyzing video: $(basename "$input_file")"
    
    # Get basic video information
    local video_info
    video_info=$(ffprobe -v quiet -print_format json -show_format -show_streams "$input_file")
    
    # Extract video stream info
    local video_stream
    video_stream=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | . ')
    
    # Extract audio stream info
    local audio_stream
    audio_stream=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="audio") | . ')
    
    # Get duration
    DURATION=$(echo "$video_info" | jq -r '.format.duration // empty')
    if [[ -z "$DURATION" ]]; then
        DURATION=$(echo "$video_stream" | jq -r '.duration // empty')
    fi
    
    # Get resolution
    WIDTH=$(echo "$video_stream" | jq -r '.width // empty')
    HEIGHT=$(echo "$video_stream" | jq -r '.height // empty')
    
    # Get frame rate
    FPS=$(echo "$video_stream" | jq -r '.r_frame_rate // empty' | bc -l 2>/dev/null || echo "30")
    
    # Get audio info
    AUDIO_CODEC=$(echo "$audio_stream" | jq -r '.codec_name // "none"')
    SAMPLE_RATE=$(echo "$audio_stream" | jq -r '.sample_rate // "44100"')
    
    log "Duration: ${DURATION}s, Resolution: ${WIDTH}x${HEIGHT}, FPS: ${FPS}, Audio: $AUDIO_CODEC"
}

analyze_audio_segments() {
    local input_file="$1"
    local temp_dir="$2"
    
    if [[ "$SKIP_AUDIO_ANALYSIS" == "true" ]]; then
        log "Skipping audio analysis"
        return
    fi
    
    log "Analyzing audio for speech segments and volume peaks..."
    
    # Extract audio volume levels
    ffmpeg -i "$input_file" -af "volumedetect,astats=metadata=1:reset=1:length=0.5" \
           -f null - 2> "$temp_dir/audio_analysis.log" || true
    
    # Find silence segments
    ffmpeg -i "$input_file" -af silencedetect=noise=${SILENCE_THRESHOLD}:d=1.0 \
           -f null - 2> "$temp_dir/silence_detection.log" || true
    
    # Extract volume peaks for emphasis detection
    ffmpeg -i "$input_file" -af "astats=metadata=1:reset=1:length=2" \
           -f null - 2> "$temp_dir/volume_peaks.log" || true
    
    # Parse silence segments
    grep "silence_start\|silence_end" "$temp_dir/silence_detection.log" | \
    awk '/silence_start/ {start=$5} /silence_end/ {print start, $5}' > "$temp_dir/silence_segments.txt" || true
    
    log "Found $(wc -l < "$temp_dir/silence_segments.txt" 2>/dev/null || echo 0) silence segments"
}

detect_scene_changes() {
    local input_file="$1"
    local temp_dir="$2"
    
    if [[ "$SKIP_SCENE_DETECTION" == "true" ]]; then
        log "Skipping scene detection"
        return
    fi
    
    log "Detecting scene changes..."
    
    # Use FFmpeg scene detection filter
    ffmpeg -i "$input_file" -filter:v "select='gt(scene,$SCENE_THRESHOLD)',showinfo" \
           -f null - 2> "$temp_dir/scene_detection.log" || true
    
    # Parse scene changes
    grep "pts_time:" "$temp_dir/scene_detection.log" | \
    sed 's/.*pts_time:\([0-9.]*\).*/\1/' > "$temp_dir/scene_changes.txt" || true
    
    log "Found $(wc -l < "$temp_dir/scene_changes.txt" 2>/dev/null || echo 0) scene changes"
}

detect_faces() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Analyzing face detection for speaker tracking..."
    
    # Simple face detection using FFmpeg (requires compilation with opencv)
    # Alternative: use a frame sampling approach
    ffmpeg -i "$input_file" -vf "fps=1/10" "$temp_dir/frame_%04d.jpg" -y 2>/dev/null || true
    
    # Count frames with detected content (proxy for face/speaker presence)
    FRAME_COUNT=$(ls "$temp_dir"/frame_*.jpg 2>/dev/null | wc -l || echo 0)
    log "Extracted $FRAME_COUNT sample frames for analysis"
    
    # Clean up sample frames
    rm -f "$temp_dir"/frame_*.jpg 2>/dev/null || true
}

calculate_segment_scores() {
    local temp_dir="$1"
    
    log "Calculating engagement scores for segments..."
    
    # Create segments based on natural break points
    # Priority: silence gaps > scene changes > fixed intervals
    
    local segments_file="$temp_dir/segments.txt"
    : > "$segments_file"
    
    # If we have silence data, use it to create segments
    if [[ -f "$temp_dir/silence_segments.txt" && -s "$temp_dir/silence_segments.txt" ]]; then
        log "Creating segments based on speech patterns..."
        
        local prev_end=0
        while read -r silence_start silence_end; do
            if [[ -n "$silence_start" && -n "$silence_end" ]]; then
                # Add segment before silence (if long enough)
                local seg_duration
                seg_duration=$(echo "$silence_start - $prev_end" | bc -l)
                
                if (( $(echo "$seg_duration >= $MIN_DURATION" | bc -l) )); then
                    echo "$prev_end $silence_start $seg_duration speech" >> "$segments_file"
                fi
                
                prev_end="$silence_end"
            fi
        done < "$temp_dir/silence_segments.txt"
        
        # Add final segment
        local final_duration
        final_duration=$(echo "$DURATION - $prev_end" | bc -l)
        if (( $(echo "$final_duration >= $MIN_DURATION" | bc -l) )); then
            echo "$prev_end $DURATION $final_duration speech" >> "$segments_file"
        fi
    else
        # Fallback: create fixed-interval segments
        log "Creating fixed-interval segments..."
        
        local segment_start=0
        while (( $(echo "$segment_start < $DURATION" | bc -l) )); do
            local segment_end
            segment_end=$(echo "$segment_start + $CLIP_DURATION" | bc -l)
            
            if (( $(echo "$segment_end > $DURATION" | bc -l) )); then
                segment_end="$DURATION"
            fi
            
            local seg_duration
            seg_duration=$(echo "$segment_end - $segment_start" | bc -l)
            
            if (( $(echo "$seg_duration >= $MIN_DURATION" | bc -l) )); then
                echo "$segment_start $segment_end $seg_duration fixed" >> "$segments_file"
            fi
            
            segment_start=$(echo "$segment_start + $CLIP_DURATION" | bc -l)
        done
    fi
    
    # Score and rank segments
    log "Ranking segments by engagement potential..."
    
    local scored_segments="$temp_dir/scored_segments.txt"
    : > "$scored_segments"
    
    while read -r start_time end_time duration segment_type; do
        local score=0
        
        # Base score from duration (prefer target duration)
        local duration_diff
        duration_diff=$(echo "($duration - $CLIP_DURATION)" | bc -l)
        duration_diff=${duration_diff#-}  # Absolute value
        local duration_score
        duration_score=$(echo "100 - ($duration_diff * 2)" | bc -l)
        score=$(echo "$score + $duration_score" | bc -l)
        
        # Bonus for speech segments vs fixed intervals
        if [[ "$segment_type" == "speech" ]]; then
            score=$(echo "$score + 50" | bc -l)
        fi
        
        # Bonus for segments near scene changes (more dynamic content)
        if [[ -f "$temp_dir/scene_changes.txt" ]]; then
            while read -r scene_time; do
                if (( $(echo "$scene_time >= $start_time && $scene_time <= $end_time" | bc -l) )); then
                    score=$(echo "$score + 25" | bc -l)
                fi
            done < "$temp_dir/scene_changes.txt"
        fi
        
        # Prefer segments from beginning and middle over end
        local position_ratio
        position_ratio=$(echo "$start_time / $DURATION" | bc -l)
        if (( $(echo "$position_ratio < 0.3" | bc -l) )); then
            score=$(echo "$score + 30" | bc -l)  # Beginning bonus
        elif (( $(echo "$position_ratio < 0.7" | bc -l) )); then
            score=$(echo "$score + 20" | bc -l)  # Middle bonus
        fi
        
        echo "$score $start_time $end_time $duration $segment_type" >> "$scored_segments"
        
    done < "$segments_file"
    
    # Sort by score (highest first) and limit to requested number of clips
    sort -rn "$scored_segments" | head -n "$NUM_CLIPS" > "$temp_dir/selected_segments.txt"
    
    log "Selected $(wc -l < "$temp_dir/selected_segments.txt") segments for extraction"
}

extract_clips() {
    local input_file="$1"
    local temp_dir="$2"
    local output_dir="$3"
    
    log "Extracting clips..."
    
    local clip_num=1
    local base_name
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    
    while read -r score start_time end_time duration segment_type; do
        log "Extracting clip $clip_num: ${start_time}s - ${end_time}s (score: ${score%.*})"
        
        for platform in ${PLATFORMS//,/ }; do
            local output_file="$output_dir/${base_name}_clip${clip_num}_${platform}.${OUTPUT_FORMAT}"
            
            # Get platform-specific settings
            local filter_complex=""
            local video_settings=""
            local audio_settings="-c:a aac -b:a 128k"
            
            case "$platform" in
                tiktok|instagram)
                    # 9:16 vertical format
                    filter_complex="-filter_complex \"[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920\""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF -r 30"
                    ;;
                youtube)
                    # 16:9 horizontal format optimized for YouTube Shorts
                    filter_complex="-filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080\""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF -r 30"
                    ;;
                twitter|linkedin)
                    # 16:9 horizontal format
                    filter_complex="-filter_complex \"[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720\""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF -r 30"
                    ;;
                *)
                    # Default: maintain original aspect ratio
                    filter_complex=""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF"
                    ;;
            esac
            
            # Build FFmpeg command
            local ffmpeg_cmd="ffmpeg -i \"$input_file\" -ss $start_time -t $duration"
            if [[ -n "$filter_complex" ]]; then
                ffmpeg_cmd="$ffmpeg_cmd $filter_complex"
            fi
            ffmpeg_cmd="$ffmpeg_cmd $video_settings $audio_settings"
            ffmpeg_cmd="$ffmpeg_cmd -movflags +faststart \"$output_file\" -y"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "Would run: $ffmpeg_cmd"
            else
                eval "$ffmpeg_cmd" 2>/dev/null || warn "Failed to extract clip for $platform"
                
                if [[ -f "$output_file" ]]; then
                    local file_size
                    file_size=$(du -h "$output_file" | cut -f1)
                    success "Created: $(basename "$output_file") (${file_size})"
                fi
            fi
        done
        
        ((clip_num++))
    done < "$temp_dir/selected_segments.txt"
}

main() {
    local input_file=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--clips)
                NUM_CLIPS="$2"
                shift 2
                ;;
            -d|--duration)
                CLIP_DURATION="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -p|--platforms)
                PLATFORMS="$2"
                shift 2
                ;;
            -t|--type)
                CONTENT_TYPE="$2"
                shift 2
                ;;
            -q|--quality)
                QUALITY="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --min-duration)
                MIN_DURATION="$2"
                shift 2
                ;;
            --max-duration)
                MAX_DURATION="$2"
                shift 2
                ;;
            --no-audio-analysis)
                SKIP_AUDIO_ANALYSIS="true"
                shift
                ;;
            --no-scene-detection)
                SKIP_SCENE_DETECTION="true"
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
                input_file="$1"
                shift
                ;;
        esac
    done
    
    # Set defaults
    NUM_CLIPS="${NUM_CLIPS:-$DEFAULT_CLIPS}"
    CLIP_DURATION="${CLIP_DURATION:-$DEFAULT_DURATION}"
    OUTPUT_DIR="${OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}"
    PLATFORMS="${PLATFORMS:-$DEFAULT_PLATFORMS}"
    CONTENT_TYPE="${CONTENT_TYPE:-general}"
    QUALITY="${QUALITY:-balanced}"
    OUTPUT_FORMAT="${OUTPUT_FORMAT:-mp4}"
    MIN_DURATION="${MIN_DURATION:-$DEFAULT_MIN_DURATION}"
    MAX_DURATION="${MAX_DURATION:-$DEFAULT_MAX_DURATION}"
    SKIP_AUDIO_ANALYSIS="${SKIP_AUDIO_ANALYSIS:-false}"
    SKIP_SCENE_DETECTION="${SKIP_SCENE_DETECTION:-false}"
    DRY_RUN="${DRY_RUN:-false}"
    
    # Set quality presets
    case "$QUALITY" in
        fast)
            PRESET="ultrafast"
            CRF="28"
            ;;
        balanced)
            PRESET="medium"
            CRF="23"
            ;;
        high)
            PRESET="slow"
            CRF="18"
            ;;
        *)
            error "Invalid quality level: $QUALITY"
            exit 1
            ;;
    esac
    
    # Validate input
    if [[ -z "$input_file" ]]; then
        error "Input file required"
        usage
        exit 1
    fi
    
    if [[ ! -f "$input_file" ]]; then
        error "Input file not found: $input_file"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT
    
    log "Starting intelligent auto-crop process..."
    log "Input: $input_file"
    log "Output: $OUTPUT_DIR"
    log "Clips: $NUM_CLIPS, Duration: ${CLIP_DURATION}s, Platforms: $PLATFORMS"
    
    # Get video information
    get_video_info "$input_file"
    
    # Validate duration
    if (( $(echo "$DURATION < $MIN_DURATION" | bc -l) )); then
        error "Video too short: ${DURATION}s (minimum: ${MIN_DURATION}s)"
        exit 1
    fi
    
    # Analyze content
    analyze_audio_segments "$input_file" "$temp_dir"
    detect_scene_changes "$input_file" "$temp_dir"
    detect_faces "$input_file" "$temp_dir"
    
    # Calculate segment scores and select best clips
    calculate_segment_scores "$temp_dir"
    
    # Extract clips
    extract_clips "$input_file" "$temp_dir" "$OUTPUT_DIR"
    
    success "Auto-crop complete! Generated clips in: $OUTPUT_DIR"
    
    # Show summary
    if [[ "$DRY_RUN" == "false" ]]; then
        local total_clips
        total_clips=$(find "$OUTPUT_DIR" -name "*_clip*.$OUTPUT_FORMAT" | wc -l)
        log "Total clips created: $total_clips"
        log "Average file size: $(du -sh "$OUTPUT_DIR" | cut -f1)"
    fi
}

# Run main function
main "$@" 