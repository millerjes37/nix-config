#!/usr/bin/env bash

# Shorts Generator - Complete Automation
# Automatically creates engaging short-form content with subtitles
# From long-form video to platform-ready shorts with transcripts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"
VIDEO_DIR="$MEDIA_DIR/video"
AUDIO_DIR="$MEDIA_DIR/audio"
TEMPLATES_DIR="$MEDIA_DIR/templates"

# Default settings
DEFAULT_OUTPUT_DIR="./shorts-ready"
DEFAULT_PLATFORMS="tiktok,instagram,youtube"
DEFAULT_CLIPS_COUNT=5
DEFAULT_CLIP_DURATION=30
DEFAULT_SUBTITLE_STYLE="social"
DEFAULT_QUALITY="balanced"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

stage_log() {
    echo -e "${PURPLE}[STAGE: $1]${NC} $2"
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
    echo -e "${CYAN}[PROGRESS]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 INPUT_VIDEO [OPTIONS]

Complete automation: Extract engaging clips → Transcribe → Add subtitles → Platform optimization

OPTIONS:
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -p, --platforms LIST    Target platforms (default: $DEFAULT_PLATFORMS)
    -n, --clips-count N     Number of clips to generate (default: $DEFAULT_CLIPS_COUNT)
    -d, --duration SEC      Target clip duration (default: $DEFAULT_CLIP_DURATION)
    -s, --subtitle-style ST Subtitle style: social, political, modern, dramatic (default: $DEFAULT_SUBTITLE_STYLE)
    -q, --quality LEVEL     Quality: fast, balanced, high (default: $DEFAULT_QUALITY)
    -t, --content-type TYPE Content type: speech, debate, interview, event (default: auto-detect)
    --speaker-name NAME     Speaker/candidate name
    --event-name NAME       Event name for branding
    --detection-type TYPE   Clip detection: auto, applause, emphasis, highlights (default: auto)
    --whisper-model MODEL   Transcription model: tiny, base, small, medium, large (default: base)
    --subtitle-position POS Position: top, center, bottom (default: bottom)
    --keyword-highlight     Highlight political keywords in subtitles
    --speaker-detection     Include speaker identification
    --brand-overlay         Add campaign branding to clips
    --viral-optimization    Optimize for viral potential (hooks, cuts, pacing)
    --engagement-features   Add engagement elements (progress bars, etc.)
    --parallel-processing   Process clips in parallel for speed
    --preview-mode          Generate preview versions only
    --skip-transcription    Skip transcription (use existing or no subtitles)
    --skip-subtitles        Generate clips without subtitles
    --keep-intermediates    Keep intermediate files for debugging
    --dry-run              Show processing plan without execution
    -h, --help             Show this help message

PLATFORMS:
    tiktok      - 9:16 vertical, 15-60s, optimized for mobile engagement
    instagram   - Multiple formats (1:1 posts, 9:16 stories/reels)
    youtube     - 16:9 horizontal shorts, YouTube algorithm optimized
    twitter     - 16:9 horizontal with captions, tweet-ready
    linkedin    - Professional 16:9 format with clean subtitles
    facebook    - Multiple formats for posts and stories

SUBTITLE STYLES:
    social      - Bold, high-contrast, perfect for social media
    political   - Professional with speaker names and context
    modern      - Clean, readable, minimal distraction
    dramatic    - High-impact with emphasis and animations
    broadcast   - Traditional TV-style professional subtitles

CONTENT TYPES:
    speech      - Political speeches, keynotes, prepared remarks
    debate      - Debates, panels, multi-speaker discussions  
    interview   - Media interviews, Q&A sessions
    event       - Campaign events, rallies, town halls
    auto-detect - Automatically determine content type

DETECTION TYPES:
    auto        - Combine all detection methods for best results
    applause    - Focus on audience reaction moments
    emphasis    - Detect vocal emphasis and passionate delivery
    highlights  - General highlight detection (motion, scenes)

EXAMPLES:
    # Complete automation with defaults
    $0 campaign-speech.mp4

    # High-quality political content with branding
    $0 debate.mp4 -q high -s political --speaker-name "Senator Smith" --brand-overlay

    # Viral-optimized social media content
    $0 rally.mp4 -p tiktok,instagram -s social --viral-optimization -n 8

    # Fast preview generation
    $0 townhall.mp4 --preview-mode --parallel-processing

    # Interview clips with speaker detection
    $0 interview.mp4 -t interview --speaker-detection --keyword-highlight

    # Batch process multiple videos
    find ./videos -name "*.mp4" -exec $0 {} -o ./all-shorts \\;

EOF
}

check_dependencies() {
    local missing_deps=()
    
    # Core tools
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v parallel >/dev/null 2>&1 || missing_deps+=("parallel")
    
    # Our scripts
    [[ -x "$VIDEO_DIR/auto-crop.sh" ]] || missing_deps+=("auto-crop.sh")
    [[ -x "$VIDEO_DIR/highlight-detector.sh" ]] || missing_deps+=("highlight-detector.sh")
    [[ -x "$AUDIO_DIR/transcribe.sh" ]] || missing_deps+=("transcribe.sh")
    [[ -x "$TEMPLATES_DIR/subtitle-overlay.sh" ]] || missing_deps+=("subtitle-overlay.sh")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Ensure all media scripts are present and executable"
        exit 1
    fi
}

setup_workspace() {
    local output_dir="$1"
    
    log "Setting up shorts generation workspace: $output_dir"
    
    # Create organized directory structure
    mkdir -p "$output_dir"/{raw-clips,transcripts,subtitled-clips,final-shorts,logs,temp}
    
    # Platform directories
    for platform in ${PLATFORMS//,/ }; do
        mkdir -p "$output_dir/final-shorts/$platform"
    done
    
    # Set workspace variables
    RAW_CLIPS_DIR="$output_dir/raw-clips"
    TRANSCRIPTS_DIR="$output_dir/transcripts"
    SUBTITLED_CLIPS_DIR="$output_dir/subtitled-clips"
    FINAL_SHORTS_DIR="$output_dir/final-shorts"
    LOGS_DIR="$output_dir/logs"
    TEMP_DIR="$output_dir/temp"
    
    # Processing log
    PROCESSING_LOG="$LOGS_DIR/shorts_generation.log"
    echo "Shorts generation started: $(date)" > "$PROCESSING_LOG"
}

detect_content_type() {
    local video_file="$1"
    
    if [[ "$CONTENT_TYPE" != "auto-detect" ]]; then
        echo "$CONTENT_TYPE"
        return
    fi
    
    log "Auto-detecting content type..."
    
    # Analyze filename and duration for hints
    local filename
    filename=$(basename "$video_file" | tr '[:upper:]' '[:lower:]')
    
    local duration
    duration=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null || echo 0)
    
    # Simple heuristics for content type detection
    if [[ "$filename" =~ (debate|panel|discussion) ]]; then
        echo "debate"
    elif [[ "$filename" =~ (interview|q.*a|media) ]]; then
        echo "interview"
    elif [[ "$filename" =~ (speech|address|keynote|remarks) ]]; then
        echo "speech"
    elif [[ "$filename" =~ (rally|event|townhall|town.*hall) ]]; then
        echo "event"
    elif (( $(echo "$duration > 3600" | bc -l) )); then
        echo "event"  # Long videos likely events
    elif (( $(echo "$duration > 1800" | bc -l) )); then
        echo "speech" # Medium videos likely speeches
    else
        echo "interview" # Short videos likely interviews
    fi
}

stage_extract_clips() {
    local video_file="$1"
    
    stage_log "EXTRACTION" "Extracting engaging clips from source video..."
    
    # Build extraction command based on detection type
    local extraction_cmd=""
    
    case "$DETECTION_TYPE" in
        auto)
            # Use auto-crop for comprehensive detection
            extraction_cmd="$VIDEO_DIR/auto-crop.sh \"$video_file\""
            extraction_cmd="$extraction_cmd -c $CLIPS_COUNT"
            extraction_cmd="$extraction_cmd -d $CLIP_DURATION"
            extraction_cmd="$extraction_cmd -o \"$RAW_CLIPS_DIR\""
            extraction_cmd="$extraction_cmd -p $(echo "$PLATFORMS" | tr ',' ' ' | head -1)"  # Use first platform for now
            extraction_cmd="$extraction_cmd -t $CONTENT_TYPE"
            extraction_cmd="$extraction_cmd -q $QUALITY"
            ;;
        applause|emphasis|highlights)
            # Use highlight detector for specific detection
            extraction_cmd="$VIDEO_DIR/highlight-detector.sh \"$video_file\""
            extraction_cmd="$extraction_cmd -t $DETECTION_TYPE"
            extraction_cmd="$extraction_cmd -n $CLIPS_COUNT"
            extraction_cmd="$extraction_cmd -d $CLIP_DURATION"
            extraction_cmd="$extraction_cmd -o \"$RAW_CLIPS_DIR\""
            extraction_cmd="$extraction_cmd -p $(echo "$PLATFORMS" | tr ',' ' ' | head -1)"
            extraction_cmd="$extraction_cmd -q $QUALITY"
            ;;
    esac
    
    # Add viral optimization flags
    if [[ "$VIRAL_OPTIMIZATION" == "true" ]]; then
        extraction_cmd="$extraction_cmd --audience-reactions --no-duplicates"
    fi
    
    # Execute extraction
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would run: $extraction_cmd"
        return 0
    fi
    
    log "Running clip extraction..."
    if eval "$extraction_cmd" >> "$PROCESSING_LOG" 2>&1; then
        local clip_count
        clip_count=$(find "$RAW_CLIPS_DIR" -name "*.mp4" | wc -l)
        success "Extracted $clip_count clips"
    else
        error "Clip extraction failed"
        return 1
    fi
}

stage_transcribe_clips() {
    local skip_transcription="$1"
    
    if [[ "$skip_transcription" == "true" ]]; then
        stage_log "TRANSCRIPTION" "Skipped (user request)"
        return 0
    fi
    
    stage_log "TRANSCRIPTION" "Generating transcripts for all clips..."
    
    # Find all extracted clips
    local clips
    clips=$(find "$RAW_CLIPS_DIR" -name "*.mp4" | head -"$CLIPS_COUNT")
    
    if [[ -z "$clips" ]]; then
        warn "No clips found for transcription"
        return 1
    fi
    
    # Transcribe each clip
    local transcribe_jobs=()
    while read -r clip_file; do
        if [[ -f "$clip_file" ]]; then
            local transcribe_cmd="$AUDIO_DIR/transcribe.sh \"$clip_file\""
            transcribe_cmd="$transcribe_cmd -o \"$TRANSCRIPTS_DIR\""
            transcribe_cmd="$transcribe_cmd -m $WHISPER_MODEL"
            transcribe_cmd="$transcribe_cmd -f srt"
            transcribe_cmd="$transcribe_cmd -l en"
            
            # Add enhancement options
            if [[ "$KEYWORD_HIGHLIGHT" == "true" ]]; then
                transcribe_cmd="$transcribe_cmd --political-keywords"
            fi
            
            if [[ "$SPEAKER_DETECTION" == "true" ]]; then
                transcribe_cmd="$transcribe_cmd --speaker-detection"
            fi
            
            transcribe_jobs+=("$transcribe_cmd")
        fi
    done <<< "$clips"
    
    # Run transcription jobs
    if [[ "$DRY_RUN" == "true" ]]; then
        for job in "${transcribe_jobs[@]}"; do
            echo "Would run: $job"
        done
        return 0
    fi
    
    log "Transcribing ${#transcribe_jobs[@]} clips..."
    
    if [[ "$PARALLEL_PROCESSING" == "true" && ${#transcribe_jobs[@]} -gt 1 ]]; then
        # Run in parallel
        printf '%s\n' "${transcribe_jobs[@]}" | parallel --will-cite >> "$PROCESSING_LOG" 2>&1
    else
        # Run sequentially
        for job in "${transcribe_jobs[@]}"; do
            eval "$job" >> "$PROCESSING_LOG" 2>&1 || warn "Transcription job failed: $job"
        done
    fi
    
    local transcript_count
    transcript_count=$(find "$TRANSCRIPTS_DIR" -name "*.srt" | wc -l)
    success "Generated $transcript_count transcripts"
}

stage_add_subtitles() {
    local skip_subtitles="$1"
    
    if [[ "$skip_subtitles" == "true" ]]; then
        stage_log "SUBTITLES" "Skipped (user request)"
        # Copy raw clips to final directory
        for platform in ${PLATFORMS//,/ }; do
            local platform_dir="$FINAL_SHORTS_DIR/$platform"
            mkdir -p "$platform_dir"
            find "$RAW_CLIPS_DIR" -name "*.mp4" | while read -r clip; do
                local base_name
                base_name=$(basename "$clip")
                cp "$clip" "$platform_dir/${base_name%.*}_${platform}.mp4"
            done
        done
        return 0
    fi
    
    stage_log "SUBTITLES" "Adding professional subtitles to clips..."
    
    # Find clips and their corresponding transcripts
    local subtitle_jobs=()
    find "$RAW_CLIPS_DIR" -name "*.mp4" | while read -r clip_file; do
        local base_name
        base_name=$(basename "$clip_file" | sed 's/\.[^.]*$//')
        
        # Look for corresponding SRT file
        local srt_file
        srt_file=$(find "$TRANSCRIPTS_DIR" -name "${base_name}*.srt" | head -1)
        
        if [[ -f "$srt_file" ]]; then
            # Build subtitle overlay command
            local subtitle_cmd="$TEMPLATES_DIR/subtitle-overlay.sh \"$clip_file\" \"$srt_file\""
            subtitle_cmd="$subtitle_cmd -s $SUBTITLE_STYLE"
            subtitle_cmd="$subtitle_cmd -p $PLATFORMS"
            subtitle_cmd="$subtitle_cmd -o \"$SUBTITLED_CLIPS_DIR\""
            subtitle_cmd="$subtitle_cmd --position $SUBTITLE_POSITION"
            subtitle_cmd="$subtitle_cmd --quality $QUALITY"
            
            # Add enhancement options
            if [[ "$KEYWORD_HIGHLIGHT" == "true" ]]; then
                subtitle_cmd="$subtitle_cmd --keyword-highlight"
            fi
            
            if [[ "$SPEAKER_DETECTION" == "true" ]]; then
                subtitle_cmd="$subtitle_cmd --speaker-names"
            fi
            
            subtitle_jobs+=("$subtitle_cmd")
        else
            warn "No transcript found for: $(basename "$clip_file")"
        fi
    done
    
    # Execute subtitle jobs
    if [[ "$DRY_RUN" == "true" ]]; then
        for job in "${subtitle_jobs[@]}"; do
            echo "Would run: $job"
        done
        return 0
    fi
    
    log "Adding subtitles to ${#subtitle_jobs[@]} clips..."
    
    if [[ "$PARALLEL_PROCESSING" == "true" && ${#subtitle_jobs[@]} -gt 1 ]]; then
        printf '%s\n' "${subtitle_jobs[@]}" | parallel --will-cite >> "$PROCESSING_LOG" 2>&1
    else
        for job in "${subtitle_jobs[@]}"; do
            eval "$job" >> "$PROCESSING_LOG" 2>&1 || warn "Subtitle job failed: $job"
        done
    fi
    
    success "Added subtitles to clips"
}

stage_final_optimization() {
    stage_log "OPTIMIZATION" "Final optimization and platform formatting..."
    
    # Move subtitled clips to final directories with platform-specific naming
    for platform in ${PLATFORMS//,/ }; do
        local platform_source="$SUBTITLED_CLIPS_DIR/$platform"
        local platform_final="$FINAL_SHORTS_DIR/$platform"
        
        if [[ -d "$platform_source" ]]; then
            find "$platform_source" -name "*.mp4" | while read -r clip_file; do
                local base_name
                base_name=$(basename "$clip_file" .mp4)
                local final_name="$platform_final/${base_name}_${platform}_ready.mp4"
                
                if [[ "$PREVIEW_MODE" == "true" ]]; then
                    # Generate thumbnail preview instead
                    ffmpeg -i "$clip_file" -vf "scale=320:240" -frames:v 1 \
                           "${final_name%.*}.jpg" -y 2>/dev/null || true
                else
                    # Apply final optimizations
                    optimize_for_platform "$clip_file" "$final_name" "$platform"
                fi
            done
        fi
    done
    
    success "Final optimization complete"
}

optimize_for_platform() {
    local input_file="$1"
    local output_file="$2"
    local platform="$3"
    
    # Platform-specific final optimizations
    local optimization_args=""
    
    case "$platform" in
        tiktok)
            # TikTok-specific optimizations
            optimization_args="-movflags +faststart -metadata title='Generated by Shorts Generator'"
            if [[ "$ENGAGEMENT_FEATURES" == "true" ]]; then
                # Could add progress bar or other engagement elements
                optimization_args="$optimization_args -vf \"drawtext=text='👆 Follow for more':fontcolor=white:fontsize=24:x=10:y=10\""
            fi
            ;;
        instagram)
            # Instagram optimizations
            optimization_args="-movflags +faststart"
            ;;
        youtube)
            # YouTube Shorts optimizations
            optimization_args="-movflags +faststart -metadata comment='#Shorts'"
            ;;
        twitter|linkedin)
            # Professional platform optimizations
            optimization_args="-movflags +faststart"
            ;;
    esac
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would optimize: $input_file -> $output_file"
        return 0
    fi
    
    # Simple copy with optimizations (in production, would apply more sophisticated processing)
    ffmpeg -i "$input_file" -c copy $optimization_args "$output_file" -y 2>/dev/null || \
    cp "$input_file" "$output_file"
}

generate_final_report() {
    local output_dir="$1"
    local input_file="$2"
    
    log "Generating shorts generation report..."
    
    local report_file="$output_dir/shorts_report.txt"
    
    cat > "$report_file" << EOF
Shorts Generation Report
=======================

Source Video: $(basename "$input_file")
Generated: $(date)
Content Type: $CONTENT_TYPE
Detection Type: $DETECTION_TYPE
Subtitle Style: $SUBTITLE_STYLE
Quality: $QUALITY

Configuration:
=============
- Clips Count: $CLIPS_COUNT
- Clip Duration: ${CLIP_DURATION}s
- Platforms: $PLATFORMS
- Whisper Model: $WHISPER_MODEL
- Parallel Processing: $PARALLEL_PROCESSING
- Viral Optimization: $VIRAL_OPTIMIZATION

Results Summary:
===============
EOF
    
    # Count final outputs by platform
    local total_shorts=0
    for platform in ${PLATFORMS//,/ }; do
        local platform_dir="$FINAL_SHORTS_DIR/$platform"
        local count=0
        if [[ -d "$platform_dir" ]]; then
            count=$(find "$platform_dir" -name "*.mp4" -o -name "*.jpg" | wc -l)
        fi
        echo "$platform: $count clips" >> "$report_file"
        total_shorts=$((total_shorts + count))
    done
    
    echo -e "\nTotal Shorts Generated: $total_shorts" >> "$report_file"
    
    # Add file sizes
    local total_size
    total_size=$(du -sh "$output_dir" | cut -f1 2>/dev/null || echo "Unknown")
    echo "Total Output Size: $total_size" >> "$report_file"
    
    # Add processing log summary
    if [[ -f "$PROCESSING_LOG" ]]; then
        echo -e "\nProcessing Log Summary:" >> "$report_file"
        echo "======================" >> "$report_file"
        tail -n 20 "$PROCESSING_LOG" >> "$report_file"
    fi
    
    success "Report generated: $report_file"
}

cleanup() {
    if [[ "$KEEP_INTERMEDIATES" != "true" && -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        log "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

main() {
    local input_file=""
    
    # Set defaults
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    PLATFORMS="$DEFAULT_PLATFORMS"
    CLIPS_COUNT="$DEFAULT_CLIPS_COUNT"
    CLIP_DURATION="$DEFAULT_CLIP_DURATION"
    SUBTITLE_STYLE="$DEFAULT_SUBTITLE_STYLE"
    QUALITY="$DEFAULT_QUALITY"
    CONTENT_TYPE="auto-detect"
    SPEAKER_NAME=""
    EVENT_NAME=""
    DETECTION_TYPE="auto"
    WHISPER_MODEL="base"
    SUBTITLE_POSITION="bottom"
    KEYWORD_HIGHLIGHT="false"
    SPEAKER_DETECTION="false"
    BRAND_OVERLAY="false"
    VIRAL_OPTIMIZATION="false"
    ENGAGEMENT_FEATURES="false"
    PARALLEL_PROCESSING="false"
    PREVIEW_MODE="false"
    SKIP_TRANSCRIPTION="false"
    SKIP_SUBTITLES="false"
    KEEP_INTERMEDIATES="false"
    DRY_RUN="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -p|--platforms)
                PLATFORMS="$2"
                shift 2
                ;;
            -n|--clips-count)
                CLIPS_COUNT="$2"
                shift 2
                ;;
            -d|--duration)
                CLIP_DURATION="$2"
                shift 2
                ;;
            -s|--subtitle-style)
                SUBTITLE_STYLE="$2"
                shift 2
                ;;
            -q|--quality)
                QUALITY="$2"
                shift 2
                ;;
            -t|--content-type)
                CONTENT_TYPE="$2"
                shift 2
                ;;
            --speaker-name)
                SPEAKER_NAME="$2"
                shift 2
                ;;
            --event-name)
                EVENT_NAME="$2"
                shift 2
                ;;
            --detection-type)
                DETECTION_TYPE="$2"
                shift 2
                ;;
            --whisper-model)
                WHISPER_MODEL="$2"
                shift 2
                ;;
            --subtitle-position)
                SUBTITLE_POSITION="$2"
                shift 2
                ;;
            --keyword-highlight)
                KEYWORD_HIGHLIGHT="true"
                shift
                ;;
            --speaker-detection)
                SPEAKER_DETECTION="true"
                shift
                ;;
            --brand-overlay)
                BRAND_OVERLAY="true"
                shift
                ;;
            --viral-optimization)
                VIRAL_OPTIMIZATION="true"
                shift
                ;;
            --engagement-features)
                ENGAGEMENT_FEATURES="true"
                shift
                ;;
            --parallel-processing)
                PARALLEL_PROCESSING="true"
                shift
                ;;
            --preview-mode)
                PREVIEW_MODE="true"
                shift
                ;;
            --skip-transcription)
                SKIP_TRANSCRIPTION="true"
                shift
                ;;
            --skip-subtitles)
                SKIP_SUBTITLES="true"
                shift
                ;;
            --keep-intermediates)
                KEEP_INTERMEDIATES="true"
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
    
    # Validate input
    if [[ -z "$input_file" ]]; then
        error "Input video file required"
        usage
        exit 1
    fi
    
    if [[ ! -f "$input_file" ]]; then
        error "Input file not found: $input_file"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Setup workspace
    setup_workspace "$OUTPUT_DIR"
    
    # Set cleanup trap
    trap cleanup EXIT
    
    # Auto-detect content type if needed
    CONTENT_TYPE=$(detect_content_type "$input_file")
    
    log "Starting complete shorts generation pipeline..."
    log "Input: $(basename "$input_file")"
    log "Content Type: $CONTENT_TYPE"
    log "Output: $OUTPUT_DIR"
    log "Platforms: $PLATFORMS"
    log "Quality: $QUALITY"
    
    # Execute pipeline stages
    stage_extract_clips "$input_file"
    stage_transcribe_clips "$SKIP_TRANSCRIPTION"
    stage_add_subtitles "$SKIP_SUBTITLES"
    stage_final_optimization
    
    # Generate final report
    generate_final_report "$OUTPUT_DIR" "$input_file"
    
    success "🎉 Shorts generation complete!"
    
    # Show final summary
    if [[ "$DRY_RUN" == "false" ]]; then
        local total_shorts=0
        for platform in ${PLATFORMS//,/ }; do
            local platform_count
            platform_count=$(find "$FINAL_SHORTS_DIR/$platform" -name "*.mp4" -o -name "*.jpg" 2>/dev/null | wc -l || echo 0)
            total_shorts=$((total_shorts + platform_count))
            log "$platform: $platform_count ready-to-upload shorts"
        done
        
        log "📊 Total platform-ready shorts: $total_shorts"
        log "📁 Output directory: $OUTPUT_DIR/final-shorts/"
        
        if [[ "$PREVIEW_MODE" == "true" ]]; then
            log "🖼️  Preview thumbnails generated (use without --preview-mode for full videos)"
        fi
    fi
}

# Run main function
main "$@" 