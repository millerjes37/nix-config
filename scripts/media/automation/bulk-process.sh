#!/usr/bin/env bash

# Bulk Video Processing Script
# Process multiple videos through the complete media pipeline
# Optimized for campaign content processing with parallel execution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"

# Default settings
DEFAULT_INPUT_DIR="./input-videos"
DEFAULT_OUTPUT_DIR="./bulk-processed"
DEFAULT_MAX_PARALLEL=4
DEFAULT_WORKFLOW="full"
DEFAULT_PLATFORMS="tiktok,instagram,youtube"

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
Usage: $0 [INPUT_DIR] [OPTIONS]

Bulk process multiple videos through the complete media pipeline.

ARGUMENTS:
    INPUT_DIR              Directory containing videos to process (default: $DEFAULT_INPUT_DIR)

OPTIONS:
    -o, --output DIR       Output directory (default: $DEFAULT_OUTPUT_DIR)
    -p, --platforms LIST   Target platforms (default: $DEFAULT_PLATFORMS)
    -w, --workflow TYPE    Workflow: full, quick, analysis-only (default: $DEFAULT_WORKFLOW)
    -j, --parallel N       Maximum parallel jobs (default: $DEFAULT_MAX_PARALLEL)
    -q, --quality LEVEL    Quality: fast, balanced, high (default: balanced)
    --filter PATTERN      Process only files matching pattern (e.g., "*.mp4")
    --recursive           Process subdirectories recursively
    --resume              Resume interrupted processing
    --dry-run             Show what would be processed
    --priority-order      Process in priority order (newest first)
    --max-size SIZE       Skip files larger than SIZE (e.g., "500M")
    --min-duration SEC    Skip videos shorter than SEC seconds
    --max-duration SEC    Skip videos longer than SEC seconds
    --speaker-detect      Auto-detect speaker names from filenames
    --event-detect        Auto-detect event names from directory structure
    -h, --help            Show this help message

WORKFLOW TYPES:
    full        - Complete pipeline with all stages
    quick       - Fast extraction with basic optimization
    analysis-only - Only analyze videos, no clip generation

EXAMPLES:
    # Process all videos in current directory
    $0 ./campaign-videos -o ./social-clips

    # Quick processing for urgent content
    $0 ./urgent -w quick -j 8 -p tiktok,instagram

    # High-quality processing with speaker detection
    $0 ./speeches -q high --speaker-detect --event-detect

    # Process only recent MP4 files
    $0 ./content --filter "*.mp4" --priority-order

EOF
}

check_dependencies() {
    local missing_deps=()
    
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v parallel >/dev/null 2>&1 || missing_deps+=("parallel")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    # Check for pipeline script
    [[ -x "$SCRIPT_DIR/clip-pipeline.sh" ]] || missing_deps+=("clip-pipeline.sh")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

setup_workspace() {
    local output_dir="$1"
    
    log "Setting up bulk processing workspace: $output_dir"
    
    mkdir -p "$output_dir"/{processing,completed,failed,logs,queue}
    
    # Create processing state files
    QUEUE_FILE="$output_dir/queue/processing_queue.txt"
    COMPLETED_FILE="$output_dir/queue/completed.txt"
    FAILED_FILE="$output_dir/queue/failed.txt"
    PROGRESS_FILE="$output_dir/queue/progress.json"
    
    # Initialize or resume state
    if [[ "$RESUME" == "true" && -f "$PROGRESS_FILE" ]]; then
        log "Resuming previous processing session"
    else
        : > "$QUEUE_FILE"
        : > "$COMPLETED_FILE"
        : > "$FAILED_FILE"
        echo '{"total": 0, "completed": 0, "failed": 0, "processing": 0}' > "$PROGRESS_FILE"
    fi
}

discover_videos() {
    local input_dir="$1"
    local temp_dir="$2"
    
    log "Discovering videos in: $input_dir"
    
    local find_opts=()
    if [[ "$RECURSIVE" == "true" ]]; then
        find_opts+=("-type" "f")
    else
        find_opts+=("-maxdepth" "1" "-type" "f")
    fi
    
    # Find video files
    local video_patterns=("*.mp4" "*.mov" "*.avi" "*.mkv" "*.webm" "*.m4v")
    
    if [[ -n "$FILTER_PATTERN" ]]; then
        video_patterns=("$FILTER_PATTERN")
    fi
    
    local discovered_videos="$temp_dir/discovered_videos.txt"
    : > "$discovered_videos"
    
    for pattern in "${video_patterns[@]}"; do
        find "$input_dir" "${find_opts[@]}" -iname "$pattern" >> "$discovered_videos" 2>/dev/null || true
    done
    
    # Filter by file size if specified
    if [[ -n "$MAX_SIZE" ]]; then
        local filtered_videos="$temp_dir/size_filtered_videos.txt"
        : > "$filtered_videos"
        
        while read -r video_file; do
            if [[ -f "$video_file" ]]; then
                local file_size
                file_size=$(stat -c%s "$video_file" 2>/dev/null || echo 0)
                local max_bytes
                max_bytes=$(numfmt --from=iec "$MAX_SIZE" 2>/dev/null || echo 0)
                
                if [[ $file_size -le $max_bytes ]]; then
                    echo "$video_file" >> "$filtered_videos"
                fi
            fi
        done < "$discovered_videos"
        
        mv "$filtered_videos" "$discovered_videos"
    fi
    
    # Filter by duration if specified
    if [[ -n "$MIN_DURATION" || -n "$MAX_DURATION" ]]; then
        local duration_filtered="$temp_dir/duration_filtered_videos.txt"
        : > "$duration_filtered"
        
        while read -r video_file; do
            if [[ -f "$video_file" ]]; then
                local duration
                duration=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video_file" 2>/dev/null || echo 0)
                
                local include_file=true
                
                if [[ -n "$MIN_DURATION" && $(echo "$duration < $MIN_DURATION" | bc -l) == 1 ]]; then
                    include_file=false
                fi
                
                if [[ -n "$MAX_DURATION" && $(echo "$duration > $MAX_DURATION" | bc -l) == 1 ]]; then
                    include_file=false
                fi
                
                if [[ "$include_file" == "true" ]]; then
                    echo "$video_file" >> "$duration_filtered"
                fi
            fi
        done < "$discovered_videos"
        
        mv "$duration_filtered" "$discovered_videos"
    fi
    
    # Sort by priority if requested
    if [[ "$PRIORITY_ORDER" == "true" ]]; then
        # Sort by modification time (newest first)
        while read -r video_file; do
            stat -c "%Y %n" "$video_file" 2>/dev/null || echo "0 $video_file"
        done < "$discovered_videos" | sort -rn | cut -d' ' -f2- > "$temp_dir/sorted_videos.txt"
        mv "$temp_dir/sorted_videos.txt" "$discovered_videos"
    fi
    
    local video_count
    video_count=$(wc -l < "$discovered_videos")
    log "Found $video_count videos to process"
    
    # Update progress
    jq --argjson total "$video_count" '.total = $total' "$PROGRESS_FILE" > "$temp_dir/progress_tmp.json"
    mv "$temp_dir/progress_tmp.json" "$PROGRESS_FILE"
    
    cat "$discovered_videos"
}

extract_metadata() {
    local video_file="$1"
    
    local speaker_name=""
    local event_name=""
    
    # Auto-detect speaker from filename
    if [[ "$SPEAKER_DETECT" == "true" ]]; then
        local filename
        filename=$(basename "$video_file")
        
        # Common patterns for speaker names in filenames
        if [[ "$filename" =~ ([A-Z][a-z]+ [A-Z][a-z]+) ]]; then
            speaker_name="${BASH_REMATCH[1]}"
        fi
    fi
    
    # Auto-detect event from directory structure
    if [[ "$EVENT_DETECT" == "true" ]]; then
        local dir_name
        dir_name=$(basename "$(dirname "$video_file")")
        
        # Use directory name as event if it's not generic
        if [[ ! "$dir_name" =~ ^(videos?|content|media|footage)$ ]]; then
            event_name="$dir_name"
        fi
    fi
    
    echo "$speaker_name|$event_name"
}

process_single_video() {
    local video_file="$1"
    local output_dir="$2"
    local job_id="$3"
    
    local video_name
    video_name=$(basename "$video_file" | sed 's/\.[^.]*$//')
    local video_output_dir="$output_dir/processing/$job_id-$video_name"
    
    log "Processing [$job_id]: $(basename "$video_file")"
    
    # Extract metadata
    local metadata
    metadata=$(extract_metadata "$video_file")
    local speaker_name
    speaker_name=$(echo "$metadata" | cut -d'|' -f1)
    local event_name
    event_name=$(echo "$metadata" | cut -d'|' -f2)
    
    # Build pipeline command
    local pipeline_cmd="$SCRIPT_DIR/clip-pipeline.sh \"$video_file\""
    pipeline_cmd="$pipeline_cmd -o \"$video_output_dir\""
    pipeline_cmd="$pipeline_cmd -w \"$WORKFLOW\""
    pipeline_cmd="$pipeline_cmd -q \"$QUALITY\""
    pipeline_cmd="$pipeline_cmd -p \"$PLATFORMS\""
    
    if [[ -n "$speaker_name" ]]; then
        pipeline_cmd="$pipeline_cmd -s \"$speaker_name\""
    fi
    
    if [[ -n "$event_name" ]]; then
        pipeline_cmd="$pipeline_cmd -e \"$event_name\""
    fi
    
    # Add processing options
    if [[ "$WORKFLOW" == "quick" ]]; then
        pipeline_cmd="$pipeline_cmd --skip-stage branding --skip-stage captions"
    fi
    
    # Create log file
    local log_file="$output_dir/logs/${job_id}-$(basename "$video_file").log"
    
    # Execute pipeline
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would process: $video_file"
        echo "Command: $pipeline_cmd"
        return 0
    else
        if eval "$pipeline_cmd" > "$log_file" 2>&1; then
            # Success - move to completed
            local completed_dir="$output_dir/completed/$video_name"
            mv "$video_output_dir" "$completed_dir" 2>/dev/null || true
            
            echo "$video_file|$(date)|SUCCESS|$completed_dir" >> "$COMPLETED_FILE"
            success "Completed [$job_id]: $(basename "$video_file")"
            return 0
        else
            # Failure - move to failed
            local failed_dir="$output_dir/failed/$video_name"
            mv "$video_output_dir" "$failed_dir" 2>/dev/null || true
            
            echo "$video_file|$(date)|FAILED|$log_file" >> "$FAILED_FILE"
            error "Failed [$job_id]: $(basename "$video_file")"
            return 1
        fi
    fi
}

update_progress() {
    local output_dir="$1"
    local status="$2"  # completed or failed
    
    local current_progress
    current_progress=$(cat "$PROGRESS_FILE")
    
    case "$status" in
        completed)
            current_progress=$(echo "$current_progress" | jq '.completed += 1 | .processing -= 1')
            ;;
        failed)
            current_progress=$(echo "$current_progress" | jq '.failed += 1 | .processing -= 1')
            ;;
        started)
            current_progress=$(echo "$current_progress" | jq '.processing += 1')
            ;;
    esac
    
    echo "$current_progress" > "$PROGRESS_FILE"
}

show_progress() {
    local output_dir="$1"
    
    local progress
    progress=$(cat "$PROGRESS_FILE")
    
    local total completed failed processing
    total=$(echo "$progress" | jq -r '.total')
    completed=$(echo "$progress" | jq -r '.completed')
    failed=$(echo "$progress" | jq -r '.failed')
    processing=$(echo "$progress" | jq -r '.processing')
    
    local percent_complete
    if [[ $total -gt 0 ]]; then
        percent_complete=$(( (completed + failed) * 100 / total ))
    else
        percent_complete=0
    fi
    
    progress "Progress: $completed/$total completed ($percent_complete%), $failed failed, $processing processing"
}

process_videos_parallel() {
    local videos_file="$1"
    local output_dir="$2"
    
    log "Starting parallel processing with $MAX_PARALLEL jobs"
    
    # Create job function for GNU parallel
    export -f process_single_video extract_metadata log error success warn
    export SCRIPT_DIR WORKFLOW QUALITY PLATFORMS SPEAKER_DETECT EVENT_DETECT DRY_RUN
    
    # Process videos in parallel
    cat "$videos_file" | parallel -j "$MAX_PARALLEL" --line-buffer \
        "process_single_video {} \"$output_dir\" {#}"
}

generate_bulk_report() {
    local output_dir="$1"
    
    log "Generating bulk processing report..."
    
    local report_file="$output_dir/bulk_processing_report.txt"
    local progress
    progress=$(cat "$PROGRESS_FILE")
    
    cat > "$report_file" << EOF
Bulk Video Processing Report
===========================

Processing Date: $(date)
Workflow: $WORKFLOW
Quality: $QUALITY
Platforms: $PLATFORMS
Parallel Jobs: $MAX_PARALLEL

Summary:
========
$(echo "$progress" | jq -r '
"Total Videos: " + (.total | tostring) + "\n" +
"Completed: " + (.completed | tostring) + "\n" +
"Failed: " + (.failed | tostring) + "\n" +
"Success Rate: " + (if .total > 0 then ((.completed * 100 / .total) | floor | tostring) + "%" else "N/A" end)
')

Completed Videos:
================
EOF
    
    if [[ -f "$COMPLETED_FILE" ]]; then
        echo "File | Date | Status | Output" >> "$report_file"
        echo "------|------|--------|--------" >> "$report_file"
        while IFS='|' read -r file date status output; do
            echo "$(basename "$file") | $date | $status | $output" >> "$report_file"
        done < "$COMPLETED_FILE"
    fi
    
    echo -e "\nFailed Videos:" >> "$report_file"
    echo "==============" >> "$report_file"
    
    if [[ -f "$FAILED_FILE" ]]; then
        echo "File | Date | Status | Log" >> "$report_file"
        echo "-----|------|--------|----" >> "$report_file"
        while IFS='|' read -r file date status log; do
            echo "$(basename "$file") | $date | $status | $log" >> "$report_file"
        done < "$FAILED_FILE"
    fi
    
    success "Bulk processing report saved: $report_file"
}

main() {
    local input_dir="$DEFAULT_INPUT_DIR"
    
    # Set defaults
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    PLATFORMS="$DEFAULT_PLATFORMS"
    WORKFLOW="$DEFAULT_WORKFLOW"
    MAX_PARALLEL="$DEFAULT_MAX_PARALLEL"
    QUALITY="balanced"
    FILTER_PATTERN=""
    RECURSIVE="false"
    RESUME="false"
    DRY_RUN="false"
    PRIORITY_ORDER="false"
    MAX_SIZE=""
    MIN_DURATION=""
    MAX_DURATION=""
    SPEAKER_DETECT="false"
    EVENT_DETECT="false"
    
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
            -j|--parallel)
                MAX_PARALLEL="$2"
                shift 2
                ;;
            -q|--quality)
                QUALITY="$2"
                shift 2
                ;;
            --filter)
                FILTER_PATTERN="$2"
                shift 2
                ;;
            --recursive)
                RECURSIVE="true"
                shift
                ;;
            --resume)
                RESUME="true"
                shift
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --priority-order)
                PRIORITY_ORDER="true"
                shift
                ;;
            --max-size)
                MAX_SIZE="$2"
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
            --speaker-detect)
                SPEAKER_DETECT="true"
                shift
                ;;
            --event-detect)
                EVENT_DETECT="true"
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
                input_dir="$1"
                shift
                ;;
        esac
    done
    
    # Validate input directory
    if [[ ! -d "$input_dir" ]]; then
        error "Input directory not found: $input_dir"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Setup workspace
    setup_workspace "$OUTPUT_DIR"
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT
    
    log "Starting bulk video processing..."
    log "Input: $input_dir"
    log "Output: $OUTPUT_DIR"
    log "Workflow: $WORKFLOW"
    log "Max Parallel: $MAX_PARALLEL"
    
    # Discover videos
    local videos_file="$temp_dir/videos_to_process.txt"
    discover_videos "$input_dir" "$temp_dir" > "$videos_file"
    
    local video_count
    video_count=$(wc -l < "$videos_file")
    
    if [[ $video_count -eq 0 ]]; then
        warn "No videos found to process"
        exit 0
    fi
    
    log "Processing $video_count videos..."
    
    # Process videos
    if [[ "$DRY_RUN" == "true" ]]; then
        log "DRY RUN - showing what would be processed:"
        cat "$videos_file"
    else
        # Show initial progress
        show_progress "$OUTPUT_DIR"
        
        # Start monitoring progress in background
        (
            while [[ -f "$videos_file" ]]; do
                sleep 10
                show_progress "$OUTPUT_DIR"
            done
        ) &
        local progress_pid=$!
        
        # Process videos
        process_videos_parallel "$videos_file" "$OUTPUT_DIR"
        
        # Stop progress monitoring
        kill $progress_pid 2>/dev/null || true
        
        # Final progress update
        show_progress "$OUTPUT_DIR"
    fi
    
    # Generate report
    generate_bulk_report "$OUTPUT_DIR"
    
    success "Bulk processing complete!"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        local final_progress
        final_progress=$(cat "$PROGRESS_FILE")
        local completed failed
        completed=$(echo "$final_progress" | jq -r '.completed')
        failed=$(echo "$final_progress" | jq -r '.failed')
        
        log "Final Results: $completed completed, $failed failed"
        log "Output directory: $OUTPUT_DIR"
    fi
}

# Run main function
main "$@" 