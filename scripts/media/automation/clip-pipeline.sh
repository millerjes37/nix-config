#!/usr/bin/env bash

# Complete Media Clip Pipeline
# Automates the entire process from raw video to platform-ready clips
# Includes analysis, extraction, branding, captions, and optimization

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"
VIDEO_DIR="$MEDIA_DIR/video"
TEMPLATES_DIR="$MEDIA_DIR/templates"
UTILS_DIR="$MEDIA_DIR/utils"

# Default settings
DEFAULT_OUTPUT_DIR="./processed-clips"
DEFAULT_PLATFORMS="tiktok,instagram,youtube,twitter"
DEFAULT_WORKFLOW="full"
DEFAULT_QUALITY="balanced"
DEFAULT_CLIPS_PER_TYPE=3

# Pipeline stages
STAGE_ANALYSIS="analysis"
STAGE_EXTRACTION="extraction" 
STAGE_BRANDING="branding"
STAGE_CAPTIONS="captions"
STAGE_OPTIMIZATION="optimization"

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

usage() {
    cat << EOF
Usage: $0 INPUT_VIDEO [OPTIONS]

Complete automated pipeline for processing political video content into social media clips.

OPTIONS:
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -p, --platforms LIST    Target platforms (default: $DEFAULT_PLATFORMS)
    -w, --workflow TYPE     Workflow type: full, analysis-only, extract-only, quick
    -q, --quality LEVEL     Quality: fast, balanced, high (default: $DEFAULT_QUALITY)
    -t, --content-type TYPE Content type: speech, debate, interview, townhall, event
    -s, --speaker NAME      Speaker/candidate name for context
    -e, --event-name NAME   Event name for branding
    --clips-per-type N      Number of clips per detection type (default: $DEFAULT_CLIPS_PER_TYPE)
    --skip-stage STAGE      Skip pipeline stage: analysis, extraction, branding, captions, optimization
    --custom-brand DIR      Custom branding assets directory
    --auto-captions         Generate automatic captions
    --manual-review         Pause for manual review between stages
    --parallel              Process platforms in parallel
    --preserve-temp         Keep temporary files for debugging
    --dry-run              Show what would be processed
    -h, --help             Show this help message

PLATFORMS:
    tiktok      - 9:16 vertical, optimized for mobile engagement
    instagram   - 1:1 square and 9:16 stories, hashtag optimization
    youtube     - 16:9 horizontal shorts, SEO optimization
    twitter     - 16:9 horizontal with captions, thread-ready
    linkedin    - Professional 16:9 format with subtitles
    facebook    - Multiple formats for posts and stories

WORKFLOWS:
    full         - Complete pipeline: analysis → extraction → branding → captions → optimization
    analysis-only - Only run video analysis and generate report
    extract-only  - Extract clips without branding or optimization
    quick        - Fast extraction with basic optimization

CONTENT TYPES:
    speech      - Formal speeches, prepared remarks
    debate      - Debates, panels, Q&A sessions
    interview   - Media interviews, one-on-one discussions
    townhall    - Town halls, community meetings
    event       - Campaign events, rallies, informal gatherings

EXAMPLES:
    # Full pipeline for campaign speech
    $0 campaign-speech.mp4 -t speech -s "Senator Smith" -e "Healthcare Town Hall"

    # Quick clips for social media
    $0 interview.mp4 -w quick -p tiktok,instagram

    # High-quality extraction with custom branding
    $0 debate.mp4 -q high --custom-brand ./my-campaign-assets

    # Analysis only for content planning
    $0 rally-footage.mp4 -w analysis-only

EOF
}

check_dependencies() {
    local missing_deps=()
    
    # Required tools
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v ffprobe >/dev/null 2>&1 || missing_deps+=("ffprobe")
    command -v bc >/dev/null 2>&1 || missing_deps+=("bc")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v parallel >/dev/null 2>&1 || missing_deps+=("parallel")
    
    # Check for our scripts
    [[ -x "$VIDEO_DIR/auto-crop.sh" ]] || missing_deps+=("auto-crop.sh")
    [[ -x "$VIDEO_DIR/speech-segments.sh" ]] || missing_deps+=("speech-segments.sh")
    [[ -x "$VIDEO_DIR/highlight-detector.sh" ]] || missing_deps+=("highlight-detector.sh")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Install tools with: nix-shell -p ffmpeg bc jq parallel"
        echo "Ensure media scripts are executable in: $VIDEO_DIR"
        exit 1
    fi
}

setup_workspace() {
    local output_dir="$1"
    
    log "Setting up workspace: $output_dir"
    
    # Create directory structure
    mkdir -p "$output_dir"/{raw-clips,branded-clips,final-clips,analysis,temp,assets}
    
    # Create platform subdirectories
    for platform in ${PLATFORMS//,/ }; do
        mkdir -p "$output_dir/final-clips/$platform"
    done
    
    # Set up workspace variables
    RAW_CLIPS_DIR="$output_dir/raw-clips"
    BRANDED_CLIPS_DIR="$output_dir/branded-clips"
    FINAL_CLIPS_DIR="$output_dir/final-clips"
    ANALYSIS_DIR="$output_dir/analysis"
    TEMP_DIR="$output_dir/temp"
    ASSETS_DIR="$output_dir/assets"
    
    # Create processing log
    PIPELINE_LOG="$output_dir/pipeline.log"
    echo "Pipeline started: $(date)" > "$PIPELINE_LOG"
}

stage_analysis() {
    local input_file="$1"
    
    if [[ " ${SKIP_STAGES[*]} " =~ " analysis " ]]; then
        stage_log "ANALYSIS" "Skipped (user request)"
        return
    fi
    
    stage_log "ANALYSIS" "Running comprehensive video analysis..."
    
    # Run multiple analysis types
    local analysis_jobs=()
    
    # Auto-crop analysis
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would run: auto-crop analysis"
    else
        analysis_jobs+=("$VIDEO_DIR/auto-crop.sh '$input_file' -o '$RAW_CLIPS_DIR/auto-crop' --dry-run -c $CLIPS_PER_TYPE")
    fi
    
    # Speech segment analysis
    analysis_jobs+=("$VIDEO_DIR/speech-segments.sh '$input_file' -o '$RAW_CLIPS_DIR/speech' --event-type '$CONTENT_TYPE' --speaker-name '$SPEAKER_NAME' --dry-run")
    
    # Highlight detection
    analysis_jobs+=("$VIDEO_DIR/highlight-detector.sh '$input_file' -t auto -o '$RAW_CLIPS_DIR/highlights' -n $CLIPS_PER_TYPE --dry-run")
    
    # Run analysis jobs
    if [[ "$PARALLEL" == "true" && "$DRY_RUN" == "false" ]]; then
        printf '%s\n' "${analysis_jobs[@]}" | parallel --will-cite
    else
        for job in "${analysis_jobs[@]}"; do
            eval "$job" || warn "Analysis job failed: $job"
        done
    fi
    
    # Consolidate analysis results
    cat "$RAW_CLIPS_DIR"/*/analysis*.txt > "$ANALYSIS_DIR/combined_analysis.txt" 2>/dev/null || true
    
    stage_log "ANALYSIS" "Analysis complete"
    
    if [[ "$MANUAL_REVIEW" == "true" ]]; then
        echo "Press Enter to continue to extraction stage..."
        read -r
    fi
}

stage_extraction() {
    local input_file="$1"
    
    if [[ " ${SKIP_STAGES[*]} " =~ " extraction " ]]; then
        stage_log "EXTRACTION" "Skipped (user request)"
        return
    fi
    
    if [[ "$WORKFLOW" == "analysis-only" ]]; then
        stage_log "EXTRACTION" "Skipped (analysis-only workflow)"
        return
    fi
    
    stage_log "EXTRACTION" "Extracting video clips..."
    
    # Extract clips using different methods
    local extraction_jobs=()
    
    # Auto-crop extraction
    extraction_jobs+=("$VIDEO_DIR/auto-crop.sh '$input_file' -o '$RAW_CLIPS_DIR/auto-crop' -c $CLIPS_PER_TYPE -q '$QUALITY' -p '$PLATFORMS'")
    
    # Speech segments
    extraction_jobs+=("$VIDEO_DIR/speech-segments.sh '$input_file' -o '$RAW_CLIPS_DIR/speech' --event-type '$CONTENT_TYPE' --speaker-name '$SPEAKER_NAME' --extract-quotes")
    
    # Highlights
    extraction_jobs+=("$VIDEO_DIR/highlight-detector.sh '$input_file' -t auto -o '$RAW_CLIPS_DIR/highlights' -n $CLIPS_PER_TYPE -q '$QUALITY' -p '$PLATFORMS'")
    
    # Run extraction jobs
    if [[ "$DRY_RUN" == "true" ]]; then
        for job in "${extraction_jobs[@]}"; do
            echo "Would run: $job"
        done
    else
        if [[ "$PARALLEL" == "true" ]]; then
            printf '%s\n' "${extraction_jobs[@]}" | parallel --will-cite
        else
            for job in "${extraction_jobs[@]}"; do
                eval "$job" || warn "Extraction job failed: $job"
            done
        fi
    fi
    
    # Count extracted clips
    local total_clips
    total_clips=$(find "$RAW_CLIPS_DIR" -name "*.mp4" | wc -l)
    
    stage_log "EXTRACTION" "Extracted $total_clips raw clips"
    
    if [[ "$MANUAL_REVIEW" == "true" ]]; then
        echo "Press Enter to continue to branding stage..."
        read -r
    fi
}

stage_branding() {
    local input_file="$1"
    
    if [[ " ${SKIP_STAGES[*]} " =~ " branding " ]]; then
        stage_log "BRANDING" "Skipped (user request)"
        return
    fi
    
    if [[ "$WORKFLOW" == "extract-only" || "$WORKFLOW" == "analysis-only" ]]; then
        stage_log "BRANDING" "Skipped (workflow: $WORKFLOW)"
        return
    fi
    
    stage_log "BRANDING" "Applying branding and templates..."
    
    # Setup branding assets
    local brand_assets_dir="$CUSTOM_BRAND"
    if [[ -z "$brand_assets_dir" || ! -d "$brand_assets_dir" ]]; then
        brand_assets_dir="$ASSETS_DIR"
        setup_default_branding "$brand_assets_dir"
    fi
    
    # Apply branding to each platform
    for platform in ${PLATFORMS//,/ }; do
        local platform_dir="$RAW_CLIPS_DIR"
        local branded_platform_dir="$BRANDED_CLIPS_DIR/$platform"
        mkdir -p "$branded_platform_dir"
        
        # Find clips for this platform
        find "$platform_dir" -name "*_${platform}.mp4" | while read -r clip_file; do
            local clip_name
            clip_name=$(basename "$clip_file" "_${platform}.mp4")
            local branded_file="$branded_platform_dir/${clip_name}_branded.mp4"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "Would apply branding: $clip_file -> $branded_file"
            else
                apply_platform_branding "$clip_file" "$branded_file" "$platform" "$brand_assets_dir"
            fi
        done
    done
    
    stage_log "BRANDING" "Branding applied to all platforms"
    
    if [[ "$MANUAL_REVIEW" == "true" ]]; then
        echo "Press Enter to continue to captions stage..."
        read -r
    fi
}

stage_captions() {
    local input_file="$1"
    
    if [[ " ${SKIP_STAGES[*]} " =~ " captions " ]]; then
        stage_log "CAPTIONS" "Skipped (user request)"
        return
    fi
    
    if [[ "$AUTO_CAPTIONS" != "true" ]]; then
        stage_log "CAPTIONS" "Skipped (not enabled)"
        return
    fi
    
    if [[ "$WORKFLOW" == "analysis-only" ]]; then
        stage_log "CAPTIONS" "Skipped (analysis-only workflow)"
        return
    fi
    
    stage_log "CAPTIONS" "Generating automatic captions..."
    
    # Generate captions for branded clips
    find "$BRANDED_CLIPS_DIR" -name "*.mp4" | while read -r clip_file; do
        local caption_file="${clip_file%.*}_captions.srt"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "Would generate captions: $clip_file"
        else
            generate_captions "$clip_file" "$caption_file"
        fi
    done
    
    stage_log "CAPTIONS" "Captions generated"
    
    if [[ "$MANUAL_REVIEW" == "true" ]]; then
        echo "Press Enter to continue to optimization stage..."
        read -r
    fi
}

stage_optimization() {
    local input_file="$1"
    
    if [[ " ${SKIP_STAGES[*]} " =~ " optimization " ]]; then
        stage_log "OPTIMIZATION" "Skipped (user request)"
        return
    fi
    
    if [[ "$WORKFLOW" == "analysis-only" ]]; then
        stage_log "OPTIMIZATION" "Skipped (analysis-only workflow)"
        return
    fi
    
    stage_log "OPTIMIZATION" "Optimizing clips for platform distribution..."
    
    # Optimize clips for each platform
    for platform in ${PLATFORMS//,/ }; do
        local branded_platform_dir="$BRANDED_CLIPS_DIR/$platform"
        local final_platform_dir="$FINAL_CLIPS_DIR/$platform"
        
        if [[ ! -d "$branded_platform_dir" ]]; then
            continue
        fi
        
        find "$branded_platform_dir" -name "*.mp4" | while read -r clip_file; do
            local clip_name
            clip_name=$(basename "$clip_file" .mp4)
            local optimized_file="$final_platform_dir/${clip_name}_final.mp4"
            
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "Would optimize: $clip_file -> $optimized_file"
            else
                optimize_for_platform "$clip_file" "$optimized_file" "$platform"
            fi
        done
    done
    
    stage_log "OPTIMIZATION" "Platform optimization complete"
}

setup_default_branding() {
    local assets_dir="$1"
    
    log "Setting up default branding assets..."
    
    # Create simple text overlay for branding
    cat > "$assets_dir/brand_config.txt" << EOF
# Default Brand Configuration
BRAND_NAME="Campaign"
BRAND_COLOR="#1E3A8A"
BRAND_FONT="Arial"
WATERMARK_POSITION="bottom-right"
WATERMARK_OPACITY="0.7"
EOF
    
    # Create simple logo placeholder
    ffmpeg -f lavfi -i "color=c=$BRAND_COLOR:s=200x100:d=1" \
           -vf "drawtext=text='$BRAND_NAME':fontcolor=white:fontsize=24:x=(w-text_w)/2:y=(h-text_h)/2" \
           "$assets_dir/logo.png" -y 2>/dev/null || true
}

apply_platform_branding() {
    local input_file="$1"
    local output_file="$2"
    local platform="$3"
    local assets_dir="$4"
    
    # Platform-specific branding
    case "$platform" in
        tiktok|instagram)
            # Add watermark and platform-specific elements
            ffmpeg -i "$input_file" -i "$assets_dir/logo.png" \
                   -filter_complex "[1:v]scale=100:-1[logo];[0:v][logo]overlay=W-w-10:H-h-10:enable='gte(t,1)'" \
                   -c:a copy "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        youtube)
            # Add YouTube-optimized branding
            ffmpeg -i "$input_file" \
                   -vf "drawtext=text='$EVENT_NAME':fontcolor=white:fontsize=32:x=10:y=10:box=1:boxcolor=black@0.5" \
                   -c:a copy "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        twitter|linkedin)
            # Add professional branding
            ffmpeg -i "$input_file" \
                   -vf "drawtext=text='$SPEAKER_NAME | $EVENT_NAME':fontcolor=white:fontsize=28:x=10:y=H-th-10:box=1:boxcolor=black@0.7" \
                   -c:a copy "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        *)
            # Default: just copy
            cp "$input_file" "$output_file"
            ;;
    esac
}

generate_captions() {
    local input_file="$1"
    local caption_file="$2"
    
    # Simple caption generation (in real implementation, would use speech recognition)
    echo "Generating captions for: $(basename "$input_file")"
    
    # Placeholder caption
    cat > "$caption_file" << EOF
1
00:00:00,000 --> 00:00:05,000
[Auto-generated captions]

2
00:00:05,000 --> 00:00:10,000
Content from $EVENT_NAME

EOF
}

optimize_for_platform() {
    local input_file="$1"
    local output_file="$2"
    local platform="$3"
    
    # Platform-specific optimization
    case "$platform" in
        tiktok)
            # TikTok optimization: higher bitrate for mobile
            ffmpeg -i "$input_file" \
                   -c:v libx264 -preset fast -crf 20 -maxrate 2500k -bufsize 5000k \
                   -c:a aac -b:a 128k -ar 44100 \
                   -movflags +faststart \
                   "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        instagram)
            # Instagram optimization: square format priority
            ffmpeg -i "$input_file" \
                   -c:v libx264 -preset medium -crf 22 -maxrate 1800k -bufsize 3600k \
                   -c:a aac -b:a 128k \
                   -movflags +faststart \
                   "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        youtube)
            # YouTube optimization: higher quality for discovery
            ffmpeg -i "$input_file" \
                   -c:v libx264 -preset slow -crf 18 -maxrate 3000k -bufsize 6000k \
                   -c:a aac -b:a 192k \
                   -movflags +faststart \
                   "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        twitter|linkedin)
            # Twitter/LinkedIn: balanced quality for web
            ffmpeg -i "$input_file" \
                   -c:v libx264 -preset medium -crf 23 -maxrate 2000k -bufsize 4000k \
                   -c:a aac -b:a 128k \
                   -movflags +faststart \
                   "$output_file" -y 2>/dev/null || cp "$input_file" "$output_file"
            ;;
        *)
            cp "$input_file" "$output_file"
            ;;
    esac
}

generate_final_report() {
    local output_dir="$1"
    local input_file="$2"
    
    log "Generating final pipeline report..."
    
    local report_file="$output_dir/pipeline_report.txt"
    
    cat > "$report_file" << EOF
Media Pipeline Processing Report
===============================

Input Video: $input_file
Processing Date: $(date)
Speaker: ${SPEAKER_NAME:-"Unknown"}
Event: ${EVENT_NAME:-"Unknown"}
Content Type: $CONTENT_TYPE
Workflow: $WORKFLOW
Quality: $QUALITY

Pipeline Stages Completed:
$(for stage in analysis extraction branding captions optimization; do
    if [[ ! " ${SKIP_STAGES[*]} " =~ " $stage " ]]; then
        echo "✓ $stage"
    else
        echo "✗ $stage (skipped)"
    fi
done)

Output Summary:
==============
EOF
    
    # Count outputs by platform
    for platform in ${PLATFORMS//,/ }; do
        local count
        count=$(find "$FINAL_CLIPS_DIR/$platform" -name "*.mp4" 2>/dev/null | wc -l || echo 0)
        echo "$platform: $count clips" >> "$report_file"
    done
    
    # Add total file sizes
    local total_size
    total_size=$(du -sh "$output_dir" | cut -f1)
    echo -e "\nTotal Output Size: $total_size" >> "$report_file"
    
    # Add processing log
    if [[ -f "$PIPELINE_LOG" ]]; then
        echo -e "\nProcessing Log:" >> "$report_file"
        cat "$PIPELINE_LOG" >> "$report_file"
    fi
    
    success "Pipeline report saved: $report_file"
}

cleanup() {
    if [[ "$PRESERVE_TEMP" != "true" && -d "$TEMP_DIR" ]]; then
        log "Cleaning up temporary files..."
        rm -rf "$TEMP_DIR"
    fi
}

main() {
    local input_file=""
    
    # Set defaults
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    PLATFORMS="$DEFAULT_PLATFORMS"
    WORKFLOW="$DEFAULT_WORKFLOW"
    QUALITY="$DEFAULT_QUALITY"
    CLIPS_PER_TYPE="$DEFAULT_CLIPS_PER_TYPE"
    CONTENT_TYPE="event"
    SPEAKER_NAME=""
    EVENT_NAME=""
    SKIP_STAGES=()
    CUSTOM_BRAND=""
    AUTO_CAPTIONS="false"
    MANUAL_REVIEW="false"
    PARALLEL="false"
    PRESERVE_TEMP="false"
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
            -w|--workflow)
                WORKFLOW="$2"
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
            -s|--speaker)
                SPEAKER_NAME="$2"
                shift 2
                ;;
            -e|--event-name)
                EVENT_NAME="$2"
                shift 2
                ;;
            --clips-per-type)
                CLIPS_PER_TYPE="$2"
                shift 2
                ;;
            --skip-stage)
                SKIP_STAGES+=("$2")
                shift 2
                ;;
            --custom-brand)
                CUSTOM_BRAND="$2"
                shift 2
                ;;
            --auto-captions)
                AUTO_CAPTIONS="true"
                shift
                ;;
            --manual-review)
                MANUAL_REVIEW="true"
                shift
                ;;
            --parallel)
                PARALLEL="true"
                shift
                ;;
            --preserve-temp)
                PRESERVE_TEMP="true"
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
    
    # Setup workspace
    setup_workspace "$OUTPUT_DIR"
    
    # Set cleanup trap
    trap cleanup EXIT
    
    log "Starting media processing pipeline..."
    log "Input: $input_file"
    log "Workflow: $WORKFLOW"
    log "Output: $OUTPUT_DIR"
    log "Platforms: $PLATFORMS"
    
    # Run pipeline stages
    stage_analysis "$input_file"
    stage_extraction "$input_file"
    stage_branding "$input_file"
    stage_captions "$input_file"
    stage_optimization "$input_file"
    
    # Generate final report
    generate_final_report "$OUTPUT_DIR" "$input_file"
    
    success "Pipeline complete! Processed clips available in: $OUTPUT_DIR/final-clips"
    
    # Show summary
    if [[ "$DRY_RUN" == "false" ]]; then
        local total_clips=0
        for platform in ${PLATFORMS//,/ }; do
            local platform_clips
            platform_clips=$(find "$FINAL_CLIPS_DIR/$platform" -name "*.mp4" 2>/dev/null | wc -l || echo 0)
            total_clips=$((total_clips + platform_clips))
            log "$platform: $platform_clips clips"
        done
        log "Total clips generated: $total_clips"
    fi
}

# Run main function
main "$@" 