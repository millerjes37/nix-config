#!/usr/bin/env bash

# Speech Segments Extraction Script
# Intelligently identifies and extracts key speech moments from political content
# Optimized for speeches, debates, interviews, and town halls

set -euo pipefail

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"
UTILS_DIR="$MEDIA_DIR/utils"

# Default settings
DEFAULT_MIN_SPEECH_DURATION=10
DEFAULT_MAX_SPEECH_DURATION=45
DEFAULT_SILENCE_THRESHOLD=-40    # dB
DEFAULT_SPEECH_THRESHOLD=-25     # dB
DEFAULT_MIN_PAUSE=1.0           # seconds
DEFAULT_OUTPUT_DIR="./speech-clips"
DEFAULT_FORMAT="mp4"

# Analysis parameters
EMPHASIS_THRESHOLD=-15          # dB for emphasis detection
APPLAUSE_THRESHOLD=-20          # dB for audience reaction
KEYWORD_BOOST=2.0              # Score multiplier for keyword matches
EMOTIONAL_BOOST=1.5            # Score multiplier for emotional emphasis

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Political/campaign keywords for content scoring
POLITICAL_KEYWORDS=(
    "policy" "reform" "change" "future" "community" "families"
    "jobs" "economy" "healthcare" "education" "climate" "environment"
    "justice" "equality" "opportunity" "progress" "democracy" "vote"
    "citizens" "people" "together" "build" "fight" "stand"
    "believe" "promise" "commit" "deliver" "achieve" "ensure"
    "important" "critical" "essential" "necessary" "urgent" "priority"
)

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

Extract key speech segments from political content using intelligent analysis.

OPTIONS:
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -f, --format FORMAT     Output format: mp4, mov, webm (default: $DEFAULT_FORMAT)
    --min-duration SEC      Minimum speech segment duration (default: $DEFAULT_MIN_SPEECH_DURATION)
    --max-duration SEC      Maximum speech segment duration (default: $DEFAULT_MAX_SPEECH_DURATION)
    --silence-threshold DB  Silence detection threshold (default: $DEFAULT_SILENCE_THRESHOLD)
    --speech-threshold DB   Speech detection threshold (default: $DEFAULT_SPEECH_THRESHOLD)
    --min-pause SEC        Minimum pause between segments (default: $DEFAULT_MIN_PAUSE)
    --keywords FILE        File with additional keywords (one per line)
    --speaker-name NAME    Speaker name for context scoring
    --event-type TYPE      Event type: speech, debate, interview, townhall
    --extract-quotes       Extract individual quotable moments
    --detect-applause      Include audience reaction analysis
    --transcribe          Generate transcripts for segments (requires whisper)
    --dry-run             Show analysis without creating clips
    -h, --help            Show this help message

EVENT TYPES:
    speech      - Formal speeches, prepared remarks
    debate      - Debates, Q&A with opponents
    interview   - Media interviews, one-on-one
    townhall    - Town halls, community meetings

EXAMPLES:
    # Extract key moments from a campaign speech
    $0 campaign-speech.mp4 --event-type speech --extract-quotes

    # Analyze debate performance with applause detection
    $0 debate.mp4 --event-type debate --detect-applause --transcribe

    # Extract interview highlights with custom keywords
    $0 interview.mp4 --keywords policy-keywords.txt --speaker-name "Senator Smith"

EOF
}

check_dependencies() {
    local missing_deps=()
    
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    command -v ffprobe >/dev/null 2>&1 || missing_deps+=("ffprobe")
    command -v bc >/dev/null 2>&1 || missing_deps+=("bc")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    command -v sox >/dev/null 2>&1 || missing_deps+=("sox")
    
    if [[ "$TRANSCRIBE" == "true" ]]; then
        command -v whisper >/dev/null 2>&1 || missing_deps+=("whisper")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Install with: nix-shell -p ${missing_deps[*]// / }"
        exit 1
    fi
}

load_additional_keywords() {
    local keywords_file="$1"
    
    if [[ -f "$keywords_file" ]]; then
        log "Loading additional keywords from: $keywords_file"
        while IFS= read -r keyword; do
            if [[ -n "$keyword" && ! "$keyword" =~ ^[[:space:]]*# ]]; then
                POLITICAL_KEYWORDS+=("$keyword")
            fi
        done < "$keywords_file"
    fi
}

analyze_audio_levels() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Analyzing audio levels and speech patterns..."
    
    # Extract detailed audio statistics
    ffmpeg -i "$input_file" -af "astats=metadata=1:reset=1:length=0.5" \
           -f null - 2> "$temp_dir/audio_stats.log" || true
    
    # Detect silence and speech segments
    ffmpeg -i "$input_file" \
           -af "silencedetect=noise=${SILENCE_THRESHOLD}dB:d=${MIN_PAUSE}" \
           -f null - 2> "$temp_dir/silence_detect.log" || true
    
    # Extract volume envelope for emphasis detection
    ffmpeg -i "$input_file" \
           -af "volumedetect,astats=metadata=1:reset=1:length=1" \
           -f null - 2> "$temp_dir/volume_envelope.log" || true
    
    # Parse silence segments to identify speech blocks
    grep "silence_start\|silence_end" "$temp_dir/silence_detect.log" | \
    awk '
    BEGIN { speech_start = 0 }
    /silence_start/ { 
        if (speech_start < $5) {
            duration = $5 - speech_start
            if (duration >= min_duration) {
                print speech_start, $5, duration, "speech"
            }
        }
    }
    /silence_end/ { speech_start = $5 }
    END {
        if (speech_start < total_duration) {
            duration = total_duration - speech_start
            if (duration >= min_duration) {
                print speech_start, total_duration, duration, "speech"
            }
        }
    }' min_duration="$MIN_SPEECH_DURATION" total_duration="$DURATION" \
    > "$temp_dir/speech_segments.txt"
    
    log "Found $(wc -l < "$temp_dir/speech_segments.txt") speech segments"
}

detect_emphasis_and_emotion() {
    local input_file="$1"
    local temp_dir="$2"
    
    log "Detecting vocal emphasis and emotional content..."
    
    # Analyze frequency spectrum for emotional content
    ffmpeg -i "$input_file" \
           -af "highpass=f=200,lowpass=f=3000,astats=metadata=1:reset=1:length=2" \
           -f null - 2> "$temp_dir/emotional_analysis.log" || true
    
    # Detect volume peaks that indicate emphasis
    awk '/lavfi.astats.Overall.Peak_level/ {
        time = $1
        gsub(/.*=/, "", time)
        level = $2
        gsub(/.*=/, "", level)
        gsub(/dB.*/, "", level)
        
        if (level > emphasis_threshold) {
            print time, level, "emphasis"
        }
    }' emphasis_threshold="$EMPHASIS_THRESHOLD" \
    "$temp_dir/volume_envelope.log" > "$temp_dir/emphasis_points.txt" || true
    
    log "Found $(wc -l < "$temp_dir/emphasis_points.txt" 2>/dev/null || echo 0) emphasis points"
}

detect_audience_reactions() {
    local input_file="$1"
    local temp_dir="$2"
    
    if [[ "$DETECT_APPLAUSE" != "true" ]]; then
        return
    fi
    
    log "Detecting audience reactions (applause, cheers)..."
    
    # Filter for applause frequency range and analyze
    ffmpeg -i "$input_file" \
           -af "highpass=f=100,lowpass=f=8000,astats=metadata=1:reset=1:length=1" \
           -f null - 2> "$temp_dir/audience_analysis.log" || true
    
    # Detect sustained loud audio that could be applause
    awk '/lavfi.astats.Overall.RMS_level/ {
        time = $1
        gsub(/.*=/, "", time)
        level = $2
        gsub(/.*=/, "", level)
        gsub(/dB.*/, "", level)
        
        if (level > applause_threshold) {
            print time, level, "applause"
        }
    }' applause_threshold="$APPLAUSE_THRESHOLD" \
    "$temp_dir/audience_analysis.log" > "$temp_dir/applause_points.txt" || true
    
    log "Found $(wc -l < "$temp_dir/applause_points.txt" 2>/dev/null || echo 0) potential applause moments"
}

transcribe_segments() {
    local input_file="$1"
    local temp_dir="$2"
    
    if [[ "$TRANSCRIBE" != "true" ]]; then
        return
    fi
    
    log "Transcribing audio for content analysis..."
    
    # Extract audio for transcription
    ffmpeg -i "$input_file" -vn -acodec pcm_s16le -ar 16000 -ac 1 \
           "$temp_dir/audio_for_transcription.wav" -y 2>/dev/null || true
    
    # Transcribe using whisper (if available)
    if command -v whisper >/dev/null 2>&1; then
        whisper "$temp_dir/audio_for_transcription.wav" \
                --output_dir "$temp_dir" \
                --output_format txt \
                --language en 2>/dev/null || true
        
        if [[ -f "$temp_dir/audio_for_transcription.txt" ]]; then
            log "Transcription completed"
        else
            warn "Transcription failed"
        fi
    else
        warn "Whisper not available for transcription"
    fi
}

score_speech_segments() {
    local temp_dir="$1"
    
    log "Scoring speech segments for political relevance..."
    
    local scored_segments="$temp_dir/scored_speech_segments.txt"
    : > "$scored_segments"
    
    while read -r start_time end_time duration segment_type; do
        local score=0
        
        # Base score from duration (prefer medium-length segments)
        local optimal_duration=30
        local duration_diff
        duration_diff=$(echo "($duration - $optimal_duration)" | bc -l)
        duration_diff=${duration_diff#-}  # Absolute value
        local duration_score
        duration_score=$(echo "100 - ($duration_diff * 1.5)" | bc -l)
        score=$(echo "$score + $duration_score" | bc -l)
        
        # Check for emphasis points within this segment
        local emphasis_count=0
        if [[ -f "$temp_dir/emphasis_points.txt" ]]; then
            while read -r emphasis_time emphasis_level emphasis_type; do
                if (( $(echo "$emphasis_time >= $start_time && $emphasis_time <= $end_time" | bc -l) )); then
                    ((emphasis_count++))
                fi
            done < "$temp_dir/emphasis_points.txt"
        fi
        
        # Bonus for vocal emphasis
        if [[ $emphasis_count -gt 0 ]]; then
            local emphasis_bonus
            emphasis_bonus=$(echo "$emphasis_count * 15" | bc -l)
            score=$(echo "$score + $emphasis_bonus" | bc -l)
        fi
        
        # Check for applause within or near this segment
        local applause_bonus=0
        if [[ -f "$temp_dir/applause_points.txt" ]]; then
            while read -r applause_time applause_level applause_type; do
                # Check if applause occurs during or shortly after speech
                local applause_window_end
                applause_window_end=$(echo "$end_time + 3" | bc -l)
                if (( $(echo "$applause_time >= $start_time && $applause_time <= $applause_window_end" | bc -l) )); then
                    applause_bonus=30
                    break
                fi
            done < "$temp_dir/applause_points.txt"
        fi
        score=$(echo "$score + $applause_bonus" | bc -l)
        
        # Keyword analysis if transcription is available
        local keyword_bonus=0
        if [[ -f "$temp_dir/audio_for_transcription.txt" ]]; then
            # Extract text for this time segment (approximate)
            local segment_text
            segment_text=$(sed -n "${start_time%.*},${end_time%.*}p" "$temp_dir/audio_for_transcription.txt" 2>/dev/null || echo "")
            
            # Count political keywords
            local keyword_count=0
            for keyword in "${POLITICAL_KEYWORDS[@]}"; do
                if echo "$segment_text" | grep -qi "$keyword"; then
                    ((keyword_count++))
                fi
            done
            
            if [[ $keyword_count -gt 0 ]]; then
                keyword_bonus=$(echo "$keyword_count * 10" | bc -l)
                score=$(echo "$score + $keyword_bonus" | bc -l)
            fi
        fi
        
        # Position bonus (beginning and middle segments often more important)
        local position_ratio
        position_ratio=$(echo "$start_time / $DURATION" | bc -l)
        local position_bonus=0
        if (( $(echo "$position_ratio < 0.2" | bc -l) )); then
            position_bonus=25  # Opening statements
        elif (( $(echo "$position_ratio < 0.8" | bc -l) )); then
            position_bonus=15  # Main content
        fi
        score=$(echo "$score + $position_bonus" | bc -l)
        
        # Event type adjustments
        case "$EVENT_TYPE" in
            debate)
                # In debates, prefer segments with more emphasis and reactions
                if [[ $emphasis_count -gt 0 && $applause_bonus -gt 0 ]]; then
                    score=$(echo "$score * 1.3" | bc -l)
                fi
                ;;
            speech)
                # In speeches, prefer segments with clear messaging
                if [[ $keyword_count -gt 2 ]]; then
                    score=$(echo "$score * 1.2" | bc -l)
                fi
                ;;
            interview)
                # In interviews, prefer concise, quotable segments
                if (( $(echo "$duration >= 15 && $duration <= 35" | bc -l) )); then
                    score=$(echo "$score * 1.2" | bc -l)
                fi
                ;;
        esac
        
        echo "$score $start_time $end_time $duration $emphasis_count $applause_bonus $keyword_count" >> "$scored_segments"
        
    done < "$temp_dir/speech_segments.txt"
    
    # Sort by score and select top segments
    sort -rn "$scored_segments" > "$temp_dir/ranked_speech_segments.txt"
    
    log "Ranked $(wc -l < "$temp_dir/ranked_speech_segments.txt") speech segments by relevance"
}

extract_quote_segments() {
    local input_file="$1"
    local temp_dir="$2"
    local output_dir="$3"
    
    if [[ "$EXTRACT_QUOTES" != "true" ]]; then
        return
    fi
    
    log "Extracting quotable moments..."
    
    # Look for shorter, high-impact segments for quotes
    awk '$4 >= 8 && $4 <= 25 && $1 > 80' "$temp_dir/ranked_speech_segments.txt" | \
    head -n 10 > "$temp_dir/quote_segments.txt"
    
    local quote_num=1
    local base_name
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    
    while read -r score start_time end_time duration emphasis_count applause_bonus keyword_count; do
        local output_file="$output_dir/${base_name}_quote${quote_num}.${OUTPUT_FORMAT}"
        
        log "Extracting quote $quote_num: ${start_time}s - ${end_time}s (score: ${score%.*})"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "Would extract quote: $start_time to $end_time (${duration}s)"
        else
            ffmpeg -i "$input_file" -ss "$start_time" -t "$duration" \
                   -c:v libx264 -preset medium -crf 23 \
                   -c:a aac -b:a 128k \
                   -movflags +faststart \
                   "$output_file" -y 2>/dev/null || warn "Failed to extract quote $quote_num"
            
            if [[ -f "$output_file" ]]; then
                success "Created quote: $(basename "$output_file")"
            fi
        fi
        
        ((quote_num++))
    done < "$temp_dir/quote_segments.txt"
}

extract_speech_segments() {
    local input_file="$1"
    local temp_dir="$2"
    local output_dir="$3"
    
    log "Extracting speech segments..."
    
    local segment_num=1
    local base_name
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    
    # Extract top segments (limit to reasonable number)
    head -n 15 "$temp_dir/ranked_speech_segments.txt" | \
    while read -r score start_time end_time duration emphasis_count applause_bonus keyword_count; do
        local output_file="$output_dir/${base_name}_segment${segment_num}.${OUTPUT_FORMAT}"
        
        log "Extracting segment $segment_num: ${start_time}s - ${end_time}s (${duration%.*}s, score: ${score%.*})"
        
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "Would extract segment: $start_time to $end_time (${duration}s)"
            echo "  - Emphasis points: $emphasis_count"
            echo "  - Applause bonus: $applause_bonus"
            echo "  - Keywords found: $keyword_count"
        else
            ffmpeg -i "$input_file" -ss "$start_time" -t "$duration" \
                   -c:v libx264 -preset medium -crf 23 \
                   -c:a aac -b:a 128k \
                   -movflags +faststart \
                   "$output_file" -y 2>/dev/null || warn "Failed to extract segment $segment_num"
            
            if [[ -f "$output_file" ]]; then
                local file_size
                file_size=$(du -h "$output_file" | cut -f1)
                success "Created segment: $(basename "$output_file") (${file_size})"
            fi
        fi
        
        ((segment_num++))
    done
}

generate_analysis_report() {
    local temp_dir="$1"
    local output_dir="$2"
    
    log "Generating analysis report..."
    
    local report_file="$output_dir/speech_analysis_report.txt"
    
    cat > "$report_file" << EOF
Speech Analysis Report
Generated: $(date)
Event Type: $EVENT_TYPE
Speaker: ${SPEAKER_NAME:-"Unknown"}

=== Summary ===
Total Duration: ${DURATION%.*} seconds
Speech Segments Found: $(wc -l < "$temp_dir/speech_segments.txt" 2>/dev/null || echo 0)
Emphasis Points: $(wc -l < "$temp_dir/emphasis_points.txt" 2>/dev/null || echo 0)
Applause Moments: $(wc -l < "$temp_dir/applause_points.txt" 2>/dev/null || echo 0)

=== Top Speech Segments ===
EOF
    
    # Add top 10 segments to report
    head -n 10 "$temp_dir/ranked_speech_segments.txt" | \
    awk '{
        printf "Segment %d: %.1fs - %.1fs (%.1fs) - Score: %.0f\n", 
               NR, $2, $3, $4, $1
        printf "  Emphasis: %d, Applause: %d, Keywords: %d\n\n", 
               $5, $6, $7
    }' >> "$report_file"
    
    if [[ -f "$temp_dir/audio_for_transcription.txt" ]]; then
        echo -e "\n=== Transcript Excerpt ===" >> "$report_file"
        head -n 20 "$temp_dir/audio_for_transcription.txt" >> "$report_file"
    fi
    
    success "Analysis report saved: $report_file"
}

main() {
    local input_file=""
    
    # Set defaults
    MIN_SPEECH_DURATION="$DEFAULT_MIN_SPEECH_DURATION"
    MAX_SPEECH_DURATION="$DEFAULT_MAX_SPEECH_DURATION"
    SILENCE_THRESHOLD="$DEFAULT_SILENCE_THRESHOLD"
    SPEECH_THRESHOLD="$DEFAULT_SPEECH_THRESHOLD"
    MIN_PAUSE="$DEFAULT_MIN_PAUSE"
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    OUTPUT_FORMAT="$DEFAULT_FORMAT"
    KEYWORDS_FILE=""
    SPEAKER_NAME=""
    EVENT_TYPE="speech"
    EXTRACT_QUOTES="false"
    DETECT_APPLAUSE="false"
    TRANSCRIBE="false"
    DRY_RUN="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --min-duration)
                MIN_SPEECH_DURATION="$2"
                shift 2
                ;;
            --max-duration)
                MAX_SPEECH_DURATION="$2"
                shift 2
                ;;
            --silence-threshold)
                SILENCE_THRESHOLD="$2"
                shift 2
                ;;
            --speech-threshold)
                SPEECH_THRESHOLD="$2"
                shift 2
                ;;
            --min-pause)
                MIN_PAUSE="$2"
                shift 2
                ;;
            --keywords)
                KEYWORDS_FILE="$2"
                shift 2
                ;;
            --speaker-name)
                SPEAKER_NAME="$2"
                shift 2
                ;;
            --event-type)
                EVENT_TYPE="$2"
                shift 2
                ;;
            --extract-quotes)
                EXTRACT_QUOTES="true"
                shift
                ;;
            --detect-applause)
                DETECT_APPLAUSE="true"
                shift
                ;;
            --transcribe)
                TRANSCRIBE="true"
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
    
    # Load additional keywords if specified
    if [[ -n "$KEYWORDS_FILE" ]]; then
        load_additional_keywords "$KEYWORDS_FILE"
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT
    
    log "Starting speech segment analysis..."
    log "Input: $input_file"
    log "Event Type: $EVENT_TYPE"
    log "Speaker: ${SPEAKER_NAME:-"Unknown"}"
    
    # Get video duration
    DURATION=$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
    
    # Perform analysis
    analyze_audio_levels "$input_file" "$temp_dir"
    detect_emphasis_and_emotion "$input_file" "$temp_dir"
    detect_audience_reactions "$input_file" "$temp_dir"
    transcribe_segments "$input_file" "$temp_dir"
    score_speech_segments "$temp_dir"
    
    # Extract content
    extract_speech_segments "$input_file" "$temp_dir" "$OUTPUT_DIR"
    extract_quote_segments "$input_file" "$temp_dir" "$OUTPUT_DIR"
    
    # Generate report
    generate_analysis_report "$temp_dir" "$OUTPUT_DIR"
    
    success "Speech analysis complete! Results in: $OUTPUT_DIR"
}

# Run main function
main "$@" 