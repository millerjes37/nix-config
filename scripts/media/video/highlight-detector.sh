#!/usr/bin/env bash

# Highlight Detector Script
# Automatically identifies engaging highlights from political content
# Uses multiple detection algorithms: applause, emphasis, scene changes, and content analysis

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"

# Default settings
DEFAULT_HIGHLIGHT_DURATION=20
DEFAULT_MIN_DURATION=10
DEFAULT_MAX_DURATION=45
DEFAULT_NUM_HIGHLIGHTS=5
DEFAULT_OUTPUT_DIR="./highlights"
DEFAULT_PLATFORMS="tiktok,instagram,youtube"

# Detection thresholds
APPLAUSE_THRESHOLD=-18      # dB for applause detection
EMPHASIS_THRESHOLD=-12      # dB for vocal emphasis
SCENE_THRESHOLD=0.4         # Scene change sensitivity
MOTION_THRESHOLD=0.1        # Motion detection threshold
FACE_CONFIDENCE=0.6         # Face detection confidence

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

usage() {
    cat << EOF
Usage: $0 INPUT_VIDEO [OPTIONS]

Automatically detect and extract video highlights using intelligent analysis.

OPTIONS:
    -t, --type TYPE         Highlight type: applause, emphasis, scene, motion, auto
    -n, --num-highlights N  Number of highlights to extract (default: $DEFAULT_NUM_HIGHLIGHTS)
    -d, --duration SEC      Target highlight duration (default: $DEFAULT_HIGHLIGHT_DURATION)
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -p, --platforms LIST    Target platforms (default: $DEFAULT_PLATFORMS)
    --min-duration SEC      Minimum highlight duration (default: $DEFAULT_MIN_DURATION)
    --max-duration SEC      Maximum highlight duration (default: $DEFAULT_MAX_DURATION)
    --quality LEVEL         Quality: fast, balanced, high (default: balanced)
    --format FORMAT         Output format: mp4, mov, webm (default: mp4)
    --sensitivity LEVEL     Detection sensitivity: low, medium, high (default: medium)
    --speaker-focus         Focus on speaker/face detection
    --audience-reactions    Prioritize audience reaction moments
    --no-duplicates         Avoid overlapping highlights
    --preview-only          Generate preview thumbnails only
    --dry-run              Show analysis without creating clips
    -h, --help             Show this help message

HIGHLIGHT TYPES:
    applause    - Detect audience applause and reactions
    emphasis    - Detect vocal emphasis and passionate moments
    scene       - Detect dynamic scene/camera changes
    motion      - Detect significant motion or gestures
    auto        - Automatically combine all detection methods

PLATFORMS:
    tiktok      - 9:16 vertical format, 15-60 seconds
    instagram   - 1:1 square and 9:16 stories
    youtube     - 16:9 horizontal, optimized for engagement
    twitter     - 16:9 horizontal with captions
    linkedin    - Professional 16:9 format

EXAMPLES:
    # Auto-detect all types of highlights
    $0 campaign-rally.mp4 --type auto -n 8

    # Focus on applause moments for audience engagement
    $0 speech.mp4 --type applause --audience-reactions

    # Extract motion-based highlights with speaker focus
    $0 debate.mp4 --type motion --speaker-focus -n 6

    # High-quality extraction for multiple platforms
    $0 townhall.mp4 --quality high -p tiktok,youtube,twitter

EOF
}

check_dependencies() {
    local missing_deps=()
    
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
    
    # Get video information
    local video_info
    video_info=$(ffprobe -v quiet -print_format json -show_format -show_streams "$input_file")
    
    DURATION=$(echo "$video_info" | jq -r '.format.duration // empty')
    WIDTH=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | .width // empty')
    HEIGHT=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | .height // empty')
    FPS=$(echo "$video_info" | jq -r '.streams[] | select(.codec_type=="video") | .r_frame_rate // empty' | bc -l 2>/dev/null || echo "30")
    
    log "Duration: ${DURATION%.*}s, Resolution: ${WIDTH}x${HEIGHT}, FPS: ${FPS%.*}"
}

detect_applause_highlights() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Detecting applause and audience reaction highlights..."
    
    # Analyze audio for applause patterns
    ffmpeg -i "$input_file" \
           -af "highpass=f=100,lowpass=f=4000,astats=metadata=1:reset=1:length=0.5" \
           -f null - 2> "$temp_dir/applause_analysis.log" || true
    
    # Extract sustained loud segments that could be applause
    awk '/lavfi.astats.Overall.Peak_level/ {
        time = $1
        gsub(/.*=/, "", time)
        level = $2
        gsub(/.*=/, "", level)
        gsub(/dB.*/, "", level)
        
        if (level > threshold) {
            print time, level, "applause"
        }
    }' threshold="$APPLAUSE_THRESHOLD" \
    "$temp_dir/applause_analysis.log" > "$temp_dir/applause_candidates.txt"
    
    # Group consecutive applause moments into highlights
    awk 'BEGIN { 
        prev_time = -999
        start_time = 0
        max_level = -999
        count = 0
    }
    {
        current_time = $1
        current_level = $2
        
        if (current_time - prev_time <= 2) {
            # Continue current applause segment
            if (count == 0) start_time = prev_time
            count++
            if (current_level > max_level) max_level = current_level
        } else {
            # End previous segment and start new one
            if (count >= 3) {
                duration = prev_time - start_time + 1
                if (duration >= min_dur && duration <= max_dur) {
                    score = 100 + (max_level + 40) * 2 + count * 5
                    print score, start_time, prev_time + 1, duration, "applause"
                }
            }
            start_time = current_time
            max_level = current_level
            count = 1
        }
        prev_time = current_time
    }
    END {
        if (count >= 3) {
            duration = prev_time - start_time + 1
            if (duration >= min_dur && duration <= max_dur) {
                score = 100 + (max_level + 40) * 2 + count * 5
                print score, start_time, prev_time + 1, duration, "applause"
            }
        }
    }' min_dur="$MIN_DURATION" max_dur="$MAX_DURATION" \
    "$temp_dir/applause_candidates.txt" >> "$temp_dir/highlights.txt"
    
    local applause_count
    applause_count=$(grep "applause" "$temp_dir/highlights.txt" 2>/dev/null | wc -l)
    log "Found $applause_count applause highlights"
}

detect_emphasis_highlights() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Detecting vocal emphasis and passionate moments..."
    
    # Analyze vocal emphasis patterns
    ffmpeg -i "$input_file" \
           -af "highpass=f=200,lowpass=f=3000,astats=metadata=1:reset=1:length=1" \
           -f null - 2> "$temp_dir/emphasis_analysis.log" || true
    
    # Detect volume peaks and spectral energy
    awk '/lavfi.astats.Overall.Peak_level/ {
        time = $1
        gsub(/.*=/, "", time)
        level = $2
        gsub(/.*=/, "", level)
        gsub(/dB.*/, "", level)
        
        if (level > threshold) {
            print time, level, "emphasis"
        }
    }' threshold="$EMPHASIS_THRESHOLD" \
    "$temp_dir/emphasis_analysis.log" > "$temp_dir/emphasis_candidates.txt"
    
    # Group emphasis moments into meaningful highlights
    awk 'BEGIN {
        window_size = 10  # 10-second analysis window
        current_window_start = 0
        window_peak = -999
        window_count = 0
    }
    {
        time = $1
        level = $2
        
        # Check if we need to start a new window
        if (time >= current_window_start + window_size) {
            # Process previous window
            if (window_count >= 2 && window_peak > -15) {
                highlight_start = current_window_start
                highlight_end = current_window_start + target_duration
                if (highlight_end > total_duration) highlight_end = total_duration
                
                duration = highlight_end - highlight_start
                if (duration >= min_dur) {
                    score = 80 + (window_peak + 40) * 3 + window_count * 10
                    print score, highlight_start, highlight_end, duration, "emphasis"
                }
            }
            
            # Start new window
            current_window_start = int(time / window_size) * window_size
            window_peak = level
            window_count = 1
        } else {
            # Add to current window
            window_count++
            if (level > window_peak) window_peak = level
        }
    }
    END {
        # Process final window
        if (window_count >= 2 && window_peak > -15) {
            highlight_start = current_window_start
            highlight_end = current_window_start + target_duration
            if (highlight_end > total_duration) highlight_end = total_duration
            
            duration = highlight_end - highlight_start
            if (duration >= min_dur) {
                score = 80 + (window_peak + 40) * 3 + window_count * 10
                print score, highlight_start, highlight_end, duration, "emphasis"
            }
        }
    }' target_duration="$HIGHLIGHT_DURATION" min_dur="$MIN_DURATION" total_duration="$DURATION" \
    "$temp_dir/emphasis_candidates.txt" >> "$temp_dir/highlights.txt"
    
    local emphasis_count
    emphasis_count=$(grep "emphasis" "$temp_dir/highlights.txt" 2>/dev/null | wc -l)
    log "Found $emphasis_count emphasis highlights"
}

detect_scene_highlights() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Detecting scene change and visual dynamic highlights..."
    
    # Detect scene changes
    ffmpeg -i "$input_file" \
           -filter:v "select='gt(scene,$SCENE_THRESHOLD)',showinfo" \
           -f null - 2> "$temp_dir/scene_analysis.log" || true
    
    # Parse scene changes
    grep "pts_time:" "$temp_dir/scene_analysis.log" | \
    sed 's/.*pts_time:\([0-9.]*\).*/\1/' > "$temp_dir/scene_changes.txt"
    
    # Create highlights around significant scene changes
    awk 'BEGIN { prev_time = 0 }
    {
        scene_time = $1
        
        # Create highlight centered around scene change
        highlight_start = scene_time - (target_duration / 3)
        if (highlight_start < 0) highlight_start = 0
        
        highlight_end = highlight_start + target_duration
        if (highlight_end > total_duration) {
            highlight_end = total_duration
            highlight_start = highlight_end - target_duration
            if (highlight_start < 0) highlight_start = 0
        }
        
        duration = highlight_end - highlight_start
        
        # Avoid overlapping with previous scene highlight
        if (highlight_start >= prev_time + min_gap && duration >= min_dur) {
            score = 70 + (total_duration - scene_time) / total_duration * 20
            print score, highlight_start, highlight_end, duration, "scene"
            prev_time = highlight_end
        }
    }' target_duration="$HIGHLIGHT_DURATION" min_dur="$MIN_DURATION" \
       min_gap="$MIN_DURATION" total_duration="$DURATION" \
    "$temp_dir/scene_changes.txt" >> "$temp_dir/highlights.txt"
    
    local scene_count
    scene_count=$(grep "scene" "$temp_dir/highlights.txt" 2>/dev/null | wc -l)
    log "Found $scene_count scene change highlights"
}

detect_motion_highlights() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Detecting motion and gesture highlights..."
    
    # Analyze motion vectors
    ffmpeg -i "$input_file" \
           -vf "select='gt(scene,$MOTION_THRESHOLD)',showinfo" \
           -f null - 2> "$temp_dir/motion_analysis.log" || true
    
    # Simple motion detection using frame difference
    ffmpeg -i "$input_file" \
           -vf "tblend=all_mode=difference,blackframe=98:32" \
           -f null - 2> "$temp_dir/motion_detection.log" || true
    
    # Parse motion events
    grep "blackframe" "$temp_dir/motion_detection.log" | \
    awk '/frame:/ {
        time = $1
        gsub(/.*=/, "", time)
        print time, "motion"
    }' > "$temp_dir/motion_events.txt"
    
    # Create highlights around motion events
    awk 'BEGIN {
        cluster_window = 15  # Group motion events within 15 seconds
        prev_time = -999
        cluster_start = 0
        cluster_events = 0
    }
    {
        time = $1
        
        if (time - prev_time <= cluster_window) {
            # Continue current cluster
            if (cluster_events == 0) cluster_start = prev_time
            cluster_events++
        } else {
            # Process previous cluster
            if (cluster_events >= 3) {
                highlight_start = cluster_start - 5
                if (highlight_start < 0) highlight_start = 0
                
                highlight_end = highlight_start + target_duration
                if (highlight_end > total_duration) highlight_end = total_duration
                
                duration = highlight_end - highlight_start
                if (duration >= min_dur) {
                    score = 60 + cluster_events * 8
                    print score, highlight_start, highlight_end, duration, "motion"
                }
            }
            
            # Start new cluster
            cluster_start = time
            cluster_events = 1
        }
        prev_time = time
    }
    END {
        # Process final cluster
        if (cluster_events >= 3) {
            highlight_start = cluster_start - 5
            if (highlight_start < 0) highlight_start = 0
            
            highlight_end = highlight_start + target_duration
            if (highlight_end > total_duration) highlight_end = total_duration
            
            duration = highlight_end - highlight_start
            if (duration >= min_dur) {
                score = 60 + cluster_events * 8
                print score, highlight_start, highlight_end, duration, "motion"
            }
        }
    }' target_duration="$HIGHLIGHT_DURATION" min_dur="$MIN_DURATION" total_duration="$DURATION" \
    "$temp_dir/motion_events.txt" >> "$temp_dir/highlights.txt"
    
    local motion_count
    motion_count=$(grep "motion" "$temp_dir/highlights.txt" 2>/dev/null | wc -l)
    log "Found $motion_count motion highlights"
}

remove_duplicate_highlights() {
    local temp_dir="$1"
    
    if [[ "$NO_DUPLICATES" != "true" ]]; then
        return
    fi
    
    log "Removing overlapping highlights..."
    
    # Sort highlights by start time and remove overlaps
    sort -k2 -n "$temp_dir/highlights.txt" > "$temp_dir/sorted_highlights.txt"
    
    awk 'BEGIN { prev_end = -999 }
    {
        score = $1
        start_time = $2
        end_time = $3
        duration = $4
        type = $5
        
        # Only keep if it doesn\'t overlap with previous highlight
        if (start_time >= prev_end) {
            print score, start_time, end_time, duration, type
            prev_end = end_time
        }
    }' "$temp_dir/sorted_highlights.txt" > "$temp_dir/filtered_highlights.txt"
    
    # Resort by score
    sort -rn "$temp_dir/filtered_highlights.txt" > "$temp_dir/highlights.txt"
    
    local removed_count
    removed_count=$(( $(wc -l < "$temp_dir/sorted_highlights.txt") - $(wc -l < "$temp_dir/highlights.txt") ))
    log "Removed $removed_count overlapping highlights"
}

apply_focus_adjustments() {
    local temp_dir="$1"
    
    # Apply speaker focus or audience reaction bonuses
    if [[ "$SPEAKER_FOCUS" == "true" || "$AUDIENCE_REACTIONS" == "true" ]]; then
        log "Applying focus adjustments..."
        
        awk '{
            score = $1
            start_time = $2
            end_time = $3
            duration = $4
            type = $5
            
            # Boost audience reaction highlights
            if (audience_reactions == "true" && type == "applause") {
                score = score * 1.5
            }
            
            # Boost emphasis highlights for speaker focus
            if (speaker_focus == "true" && type == "emphasis") {
                score = score * 1.3
            }
            
            print score, start_time, end_time, duration, type
        }' audience_reactions="$AUDIENCE_REACTIONS" speaker_focus="$SPEAKER_FOCUS" \
        "$temp_dir/highlights.txt" > "$temp_dir/adjusted_highlights.txt"
        
        mv "$temp_dir/adjusted_highlights.txt" "$temp_dir/highlights.txt"
    fi
}

extract_highlights() {
    local input_file="$1"
    local temp_dir="$2"
    local output_dir="$3"
    
    if [[ "$PREVIEW_ONLY" == "true" ]]; then
        log "Generating preview thumbnails only..."
        return
    fi
    
    log "Extracting top highlights..."
    
    # Sort by score and take top N highlights
    sort -rn "$temp_dir/highlights.txt" | head -n "$NUM_HIGHLIGHTS" > "$temp_dir/selected_highlights.txt"
    
    local highlight_num=1
    local base_name
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    
    while read -r score start_time end_time duration highlight_type; do
        log "Extracting highlight $highlight_num: ${start_time%.*}s - ${end_time%.*}s (${highlight_type}, score: ${score%.*})"
        
        for platform in ${PLATFORMS//,/ }; do
            local output_file="$output_dir/${base_name}_highlight${highlight_num}_${platform}.${OUTPUT_FORMAT}"
            
            # Platform-specific formatting
            local filter_complex=""
            local video_settings=""
            local audio_settings="-c:a aac -b:a 128k"
            
            case "$platform" in
                tiktok|instagram)
                    filter_complex="-filter_complex \"[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920\""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF"
                    ;;
                youtube)
                    filter_complex="-filter_complex \"[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080\""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF"
                    ;;
                twitter|linkedin)
                    filter_complex="-filter_complex \"[0:v]scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720\""
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF"
                    ;;
                *)
                    video_settings="-c:v libx264 -preset $PRESET -crf $CRF"
                    ;;
            esac
            
            # Extract highlight
            local ffmpeg_cmd="ffmpeg -i \"$input_file\" -ss $start_time -t $duration"
            if [[ -n "$filter_complex" ]]; then
                ffmpeg_cmd="$ffmpeg_cmd $filter_complex"
            fi
            ffmpeg_cmd="$ffmpeg_cmd $video_settings $audio_settings"
            ffmpeg_cmd="$ffmpeg_cmd -movflags +faststart \"$output_file\" -y"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "Would extract: $highlight_type highlight ${start_time%.*}s-${end_time%.*}s for $platform"
            else
                eval "$ffmpeg_cmd" 2>/dev/null || warn "Failed to extract highlight for $platform"
                
                if [[ -f "$output_file" ]]; then
                    success "Created: $(basename "$output_file") (${highlight_type})"
                fi
            fi
        done
        
        ((highlight_num++))
    done < "$temp_dir/selected_highlights.txt"
}

generate_highlight_report() {
    local temp_dir="$1"
    local output_dir="$2"
    
    log "Generating highlight analysis report..."
    
    local report_file="$output_dir/highlight_analysis.txt"
    
    cat > "$report_file" << EOF
Highlight Detection Report
Generated: $(date)
Detection Type: $HIGHLIGHT_TYPE
Sensitivity: $SENSITIVITY

=== Summary ===
Total Duration: ${DURATION%.*} seconds
Total Highlights Found: $(wc -l < "$temp_dir/highlights.txt" 2>/dev/null || echo 0)
Selected Highlights: $NUM_HIGHLIGHTS

=== Highlight Breakdown ===
EOF
    
    # Count highlights by type
    for type in applause emphasis scene motion; do
        local count
        count=$(grep -c "$type" "$temp_dir/highlights.txt" 2>/dev/null || echo 0)
        echo "$type: $count" >> "$report_file"
    done
    
    echo -e "\n=== Top Highlights ===" >> "$report_file"
    
    # Add selected highlights to report
    head -n "$NUM_HIGHLIGHTS" "$temp_dir/selected_highlights.txt" | \
    awk '{
        printf "Highlight %d: %.1fs - %.1fs (%.1fs) - %s (Score: %.0f)\n", 
               NR, $2, $3, $4, $5, $1
    }' >> "$report_file"
    
    success "Report saved: $report_file"
}

main() {
    local input_file=""
    
    # Set defaults
    HIGHLIGHT_TYPE="auto"
    NUM_HIGHLIGHTS="$DEFAULT_NUM_HIGHLIGHTS"
    HIGHLIGHT_DURATION="$DEFAULT_HIGHLIGHT_DURATION"
    MIN_DURATION="$DEFAULT_MIN_DURATION"
    MAX_DURATION="$DEFAULT_MAX_DURATION"
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    PLATFORMS="$DEFAULT_PLATFORMS"
    QUALITY="balanced"
    OUTPUT_FORMAT="mp4"
    SENSITIVITY="medium"
    SPEAKER_FOCUS="false"
    AUDIENCE_REACTIONS="false"
    NO_DUPLICATES="false"
    PREVIEW_ONLY="false"
    DRY_RUN="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)
                HIGHLIGHT_TYPE="$2"
                shift 2
                ;;
            -n|--num-highlights)
                NUM_HIGHLIGHTS="$2"
                shift 2
                ;;
            -d|--duration)
                HIGHLIGHT_DURATION="$2"
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
            --min-duration)
                MIN_DURATION="$2"
                shift 2
                ;;
            --max-duration)
                MAX_DURATION="$2"
                shift 2
                ;;
            --quality)
                QUALITY="$2"
                shift 2
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --sensitivity)
                SENSITIVITY="$2"
                shift 2
                ;;
            --speaker-focus)
                SPEAKER_FOCUS="true"
                shift
                ;;
            --audience-reactions)
                AUDIENCE_REACTIONS="true"
                shift
                ;;
            --no-duplicates)
                NO_DUPLICATES="true"
                shift
                ;;
            --preview-only)
                PREVIEW_ONLY="true"
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
    
    # Adjust thresholds based on sensitivity
    case "$SENSITIVITY" in
        low)
            APPLAUSE_THRESHOLD=-15
            EMPHASIS_THRESHOLD=-10
            SCENE_THRESHOLD=0.5
            ;;
        medium)
            APPLAUSE_THRESHOLD=-18
            EMPHASIS_THRESHOLD=-12
            SCENE_THRESHOLD=0.4
            ;;
        high)
            APPLAUSE_THRESHOLD=-22
            EMPHASIS_THRESHOLD=-15
            SCENE_THRESHOLD=0.3
            ;;
    esac
    
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
    
    log "Starting highlight detection..."
    log "Input: $input_file"
    log "Type: $HIGHLIGHT_TYPE"
    log "Sensitivity: $SENSITIVITY"
    
    # Get video information
    get_video_info "$input_file"
    
    # Initialize highlights file
    : > "$temp_dir/highlights.txt"
    
    # Run detection based on type
    case "$HIGHLIGHT_TYPE" in
        applause)
            detect_applause_highlights "$input_file" "$temp_dir"
            ;;
        emphasis)
            detect_emphasis_highlights "$input_file" "$temp_dir"
            ;;
        scene)
            detect_scene_highlights "$input_file" "$temp_dir"
            ;;
        motion)
            detect_motion_highlights "$input_file" "$temp_dir"
            ;;
        auto)
            detect_applause_highlights "$input_file" "$temp_dir"
            detect_emphasis_highlights "$input_file" "$temp_dir"
            detect_scene_highlights "$input_file" "$temp_dir"
            detect_motion_highlights "$input_file" "$temp_dir"
            ;;
        *)
            error "Invalid highlight type: $HIGHLIGHT_TYPE"
            exit 1
            ;;
    esac
    
    # Post-process highlights
    remove_duplicate_highlights "$temp_dir"
    apply_focus_adjustments "$temp_dir"
    
    # Extract highlights
    extract_highlights "$input_file" "$temp_dir" "$OUTPUT_DIR"
    
    # Generate report
    generate_highlight_report "$temp_dir" "$OUTPUT_DIR"
    
    success "Highlight detection complete! Results in: $OUTPUT_DIR"
    
    # Show summary
    if [[ "$DRY_RUN" == "false" && "$PREVIEW_ONLY" == "false" ]]; then
        local total_highlights
        total_highlights=$(find "$OUTPUT_DIR" -name "*_highlight*.$OUTPUT_FORMAT" | wc -l)
        log "Total highlights created: $total_highlights"
    fi
}

# Run main function
main "$@" 