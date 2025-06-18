#!/usr/bin/env bash

# Local Audio Transcription Script
# Uses OpenAI Whisper models running locally for accurate speech transcription
# Optimized for political content with speaker identification and keyword detection

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEDIA_DIR="$(dirname "$SCRIPT_DIR")"

# Default settings
DEFAULT_MODEL="base"
DEFAULT_LANGUAGE="en"
DEFAULT_OUTPUT_DIR="./transcripts"
DEFAULT_FORMAT="all"
DEFAULT_DEVICE="cpu"

# Whisper model sizes (trade-off between speed and accuracy)
WHISPER_MODELS=(
    "tiny"      # ~39 MB, ~32x realtime
    "base"      # ~74 MB, ~16x realtime  
    "small"     # ~244 MB, ~6x realtime
    "medium"    # ~769 MB, ~2x realtime
    "large"     # ~1550 MB, ~1x realtime
    "large-v2"  # ~1550 MB, improved accuracy
    "large-v3"  # ~1550 MB, latest version
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
Usage: $0 INPUT_FILE [OPTIONS]

Transcribe audio/video files using local Whisper models.

OPTIONS:
    -m, --model MODEL       Whisper model size (default: $DEFAULT_MODEL)
                           Available: ${WHISPER_MODELS[*]}
    -l, --language LANG     Language code (default: $DEFAULT_LANGUAGE)
    -o, --output DIR        Output directory (default: $DEFAULT_OUTPUT_DIR)
    -f, --format FORMAT     Output format: srt, vtt, txt, json, all (default: $DEFAULT_FORMAT)
    -d, --device DEVICE     Device: cpu, cuda, auto (default: $DEFAULT_DEVICE)
    --speaker-detection     Enable speaker diarization (experimental)
    --political-keywords    Enhance with political keyword detection
    --confidence-threshold  Minimum confidence for segments (0.0-1.0)
    --max-segment-length    Maximum segment length in seconds
    --beam-size N          Beam search size for better accuracy
    --temperature FLOAT     Sampling temperature (0.0-1.0)
    --word-timestamps      Include word-level timestamps
    --vad-filter           Voice activity detection filtering
    --subtitle-style STYLE  Subtitle style: default, political, broadcast
    --batch-size N         Process multiple files (directory input)
    --resume               Resume interrupted batch processing
    --quality-check        Validate transcription quality
    --dry-run              Show what would be processed
    -h, --help             Show this help message

MODEL SIZES:
    tiny        - Fastest, lower accuracy (~39 MB)
    base        - Good balance of speed/accuracy (~74 MB) [Recommended]
    small       - Better accuracy, slower (~244 MB)
    medium      - High accuracy (~769 MB)
    large       - Best accuracy, slowest (~1550 MB)
    large-v2    - Improved large model
    large-v3    - Latest large model [Best Quality]

OUTPUT FORMATS:
    srt         - SubRip subtitle format (.srt)
    vtt         - WebVTT subtitle format (.vtt)
    txt         - Plain text transcript (.txt)
    json        - Detailed JSON with timestamps and confidence (.json)
    all         - Generate all formats

EXAMPLES:
    # Basic transcription with default settings
    $0 speech.mp4

    # High-accuracy transcription for important content
    $0 debate.mp4 -m large-v3 --word-timestamps --political-keywords

    # Fast transcription for quick review
    $0 interview.mp4 -m tiny -f txt

    # Batch process entire directory
    $0 /path/to/videos --batch-size 4 -m base

    # Generate professional subtitles
    $0 townhall.mp4 -f srt --subtitle-style political --speaker-detection

EOF
}

check_dependencies() {
    local missing_deps=()
    
    # Check for Python and pip
    command -v python3 >/dev/null 2>&1 || missing_deps+=("python3")
    command -v pip3 >/dev/null 2>&1 || missing_deps+=("pip3")
    
    # Check for FFmpeg
    command -v ffmpeg >/dev/null 2>&1 || missing_deps+=("ffmpeg")
    
    # Check for Whisper
    if ! python3 -c "import whisper" 2>/dev/null; then
        warn "Whisper not installed. Installing automatically..."
        install_whisper
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Install with: nix-shell -p ${missing_deps[*]// / }"
        exit 1
    fi
}

install_whisper() {
    log "Installing OpenAI Whisper..."
    
    # Install Whisper with additional dependencies
    pip3 install --user openai-whisper torch torchaudio || {
        error "Failed to install Whisper. Please install manually:"
        echo "pip3 install --user openai-whisper torch torchaudio"
        exit 1
    }
    
    success "Whisper installed successfully"
}

setup_workspace() {
    local output_dir="$1"
    
    log "Setting up transcription workspace: $output_dir"
    
    mkdir -p "$output_dir"/{srt,vtt,txt,json,audio,temp}
    
    # Set workspace variables
    SRT_DIR="$output_dir/srt"
    VTT_DIR="$output_dir/vtt"
    TXT_DIR="$output_dir/txt"
    JSON_DIR="$output_dir/json"
    AUDIO_DIR="$output_dir/audio"
    TEMP_DIR="$output_dir/temp"
}

extract_audio() {
    local input_file="$1"
    local output_audio="$2"
    
    log "Extracting audio from: $(basename "$input_file")"
    
    # Extract audio optimized for speech recognition
    ffmpeg -i "$input_file" \
           -vn \
           -acodec pcm_s16le \
           -ar 16000 \
           -ac 1 \
           -y \
           "$output_audio" 2>/dev/null || {
        error "Failed to extract audio from: $input_file"
        return 1
    }
    
    success "Audio extracted: $(basename "$output_audio")"
}

transcribe_with_whisper() {
    local audio_file="$1"
    local base_name="$2"
    local temp_dir="$3"
    
    log "Transcribing with Whisper model: $MODEL"
    progress "This may take a while depending on file length and model size..."
    
    # Build Whisper command
    local whisper_cmd="python3 -c \""
    whisper_cmd+="import whisper; "
    whisper_cmd+="import json; "
    whisper_cmd+="import sys; "
    whisper_cmd+="model = whisper.load_model('$MODEL', device='$DEVICE'); "
    
    # Set transcription options
    local whisper_options=""
    if [[ -n "$BEAM_SIZE" ]]; then
        whisper_options+=", beam_size=$BEAM_SIZE"
    fi
    if [[ -n "$TEMPERATURE" ]]; then
        whisper_options+=", temperature=$TEMPERATURE"
    fi
    if [[ "$WORD_TIMESTAMPS" == "true" ]]; then
        whisper_options+=", word_timestamps=True"
    fi
    if [[ "$VAD_FILTER" == "true" ]]; then
        whisper_options+=", vad_filter=True"
    fi
    
    whisper_cmd+="result = model.transcribe('$audio_file', language='$LANGUAGE'$whisper_options); "
    whisper_cmd+="print(json.dumps(result, indent=2, ensure_ascii=False))"
    whisper_cmd+="\""
    
    # Run transcription
    local json_output="$temp_dir/${base_name}_raw.json"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would run Whisper transcription: $whisper_cmd"
        return 0
    fi
    
    if eval "$whisper_cmd" > "$json_output" 2>"$temp_dir/whisper_error.log"; then
        success "Transcription completed"
        echo "$json_output"
    else
        error "Whisper transcription failed"
        cat "$temp_dir/whisper_error.log" >&2
        return 1
    fi
}

enhance_with_political_keywords() {
    local json_file="$1"
    local output_file="$2"
    
    if [[ "$POLITICAL_KEYWORDS" != "true" ]]; then
        cp "$json_file" "$output_file"
        return
    fi
    
    log "Enhancing transcription with political keyword detection..."
    
    # Political keywords for context enhancement
    local political_terms=(
        "healthcare" "economy" "education" "climate" "immigration"
        "democracy" "voting" "policy" "reform" "budget" "taxes"
        "infrastructure" "jobs" "families" "community" "security"
        "justice" "equality" "opportunity" "progress" "change"
        "senator" "representative" "congressman" "governor" "mayor"
        "republican" "democrat" "independent" "conservative" "liberal"
        "bill" "amendment" "legislation" "congress" "senate" "house"
    )
    
    # Use Python to enhance the JSON with keyword detection
    python3 << EOF > "$output_file"
import json
import re

# Load transcription
with open('$json_file', 'r') as f:
    data = json.load(f)

# Political keywords
keywords = $(printf '%s\n' "${political_terms[@]}" | jq -R . | jq -s .)

# Enhance segments with keyword detection
for segment in data.get('segments', []):
    text = segment.get('text', '').lower()
    found_keywords = []
    
    for keyword in keywords:
        if keyword in text:
            found_keywords.append(keyword)
    
    if found_keywords:
        segment['political_keywords'] = found_keywords
        segment['political_relevance'] = len(found_keywords)

# Add metadata
data['enhancement'] = {
    'political_keywords_detected': True,
    'total_keywords_found': sum(len(seg.get('political_keywords', [])) for seg in data.get('segments', []))
}

print(json.dumps(data, indent=2, ensure_ascii=False))
EOF
}

apply_speaker_detection() {
    local json_file="$1"
    local output_file="$2"
    
    if [[ "$SPEAKER_DETECTION" != "true" ]]; then
        cp "$json_file" "$output_file"
        return
    fi
    
    log "Applying speaker diarization (experimental)..."
    
    # Simple speaker detection based on audio characteristics
    # In production, would use pyannote.audio or similar
    python3 << EOF > "$output_file"
import json

# Load transcription
with open('$json_file', 'r') as f:
    data = json.load(f)

# Simple speaker detection based on patterns
current_speaker = "Speaker 1"
speaker_count = 1

for i, segment in enumerate(data.get('segments', [])):
    # Detect speaker changes based on silence gaps and content patterns
    if i > 0:
        prev_segment = data['segments'][i-1]
        gap = segment.get('start', 0) - prev_segment.get('end', 0)
        
        # Long pause might indicate speaker change
        if gap > 2.0:
            speaker_count += 1
            current_speaker = f"Speaker {speaker_count}"
        
        # Question patterns might indicate interviewer
        text = segment.get('text', '').strip()
        if text.endswith('?') or text.lower().startswith(('what', 'how', 'why', 'when', 'where')):
            if 'interviewer' not in current_speaker.lower():
                current_speaker = "Interviewer"
    
    segment['speaker'] = current_speaker

# Add speaker metadata
data['speakers'] = {
    'total_speakers': speaker_count,
    'speaker_detection': 'basic_heuristic'
}

print(json.dumps(data, indent=2, ensure_ascii=False))
EOF
}

generate_srt() {
    local json_file="$1"
    local srt_file="$2"
    
    log "Generating SRT subtitle file..."
    
    python3 << EOF > "$srt_file"
import json
from datetime import timedelta

def format_timestamp(seconds):
    td = timedelta(seconds=seconds)
    hours, remainder = divmod(td.total_seconds(), 3600)
    minutes, seconds = divmod(remainder, 60)
    milliseconds = int((seconds % 1) * 1000)
    return f"{int(hours):02d}:{int(minutes):02d}:{int(seconds):02d},{milliseconds:03d}"

# Load transcription
with open('$json_file', 'r') as f:
    data = json.load(f)

subtitle_style = "$SUBTITLE_STYLE"

# Generate SRT
for i, segment in enumerate(data.get('segments', []), 1):
    start_time = format_timestamp(segment.get('start', 0))
    end_time = format_timestamp(segment.get('end', 0))
    text = segment.get('text', '').strip()
    
    # Apply styling based on subtitle style
    if subtitle_style == 'political':
        # Add speaker labels for political content
        speaker = segment.get('speaker', '')
        if speaker:
            text = f"[{speaker}] {text}"
        
        # Highlight political keywords
        keywords = segment.get('political_keywords', [])
        if keywords:
            for keyword in keywords:
                text = text.replace(keyword, keyword.upper())
    
    elif subtitle_style == 'broadcast':
        # Professional broadcast style
        speaker = segment.get('speaker', '')
        if speaker:
            text = f"{speaker}: {text}"
    
    print(f"{i}")
    print(f"{start_time} --> {end_time}")
    print(f"{text}")
    print()
EOF
}

generate_vtt() {
    local json_file="$1"
    local vtt_file="$2"
    
    log "Generating VTT subtitle file..."
    
    python3 << EOF > "$vtt_file"
import json
from datetime import timedelta

def format_timestamp(seconds):
    td = timedelta(seconds=seconds)
    hours, remainder = divmod(td.total_seconds(), 3600)
    minutes, seconds = divmod(remainder, 60)
    milliseconds = int((seconds % 1) * 1000)
    return f"{int(hours):02d}:{int(minutes):02d}:{int(seconds):02d}.{milliseconds:03d}"

# Load transcription
with open('$json_file', 'r') as f:
    data = json.load(f)

print("WEBVTT")
print()

# Add metadata
print("NOTE")
print("Generated by Local Whisper Transcription")
print("Model: $MODEL")
print("Language: $LANGUAGE")
print()

# Generate VTT cues
for segment in data.get('segments', []):
    start_time = format_timestamp(segment.get('start', 0))
    end_time = format_timestamp(segment.get('end', 0))
    text = segment.get('text', '').strip()
    
    # Add speaker information if available
    speaker = segment.get('speaker', '')
    if speaker:
        print(f"<v {speaker}>{text}")
    else:
        print(f"{start_time} --> {end_time}")
        print(f"{text}")
    print()
EOF
}

generate_txt() {
    local json_file="$1"
    local txt_file="$2"
    
    log "Generating plain text transcript..."
    
    python3 << EOF > "$txt_file"
import json

# Load transcription
with open('$json_file', 'r') as f:
    data = json.load(f)

print("TRANSCRIPT")
print("=" * 50)
print(f"Generated: $(date)")
print(f"Model: $MODEL")
print(f"Language: $LANGUAGE")
print("=" * 50)
print()

# Generate readable transcript
current_speaker = ""
for segment in data.get('segments', []):
    text = segment.get('text', '').strip()
    speaker = segment.get('speaker', '')
    
    # Add speaker changes
    if speaker and speaker != current_speaker:
        print(f"\n{speaker}:")
        current_speaker = speaker
    
    # Add timestamp every few minutes
    start_time = segment.get('start', 0)
    if int(start_time) % 300 == 0 and start_time > 0:  # Every 5 minutes
        minutes = int(start_time // 60)
        print(f"\n[{minutes}:00]")
    
    print(text)

# Add summary if political keywords detected
if data.get('enhancement', {}).get('political_keywords_detected'):
    print("\n" + "=" * 50)
    print("POLITICAL KEYWORDS DETECTED:")
    keywords = set()
    for segment in data.get('segments', []):
        keywords.update(segment.get('political_keywords', []))
    
    for keyword in sorted(keywords):
        print(f"- {keyword}")
EOF
}

check_quality() {
    local json_file="$1"
    
    if [[ "$QUALITY_CHECK" != "true" ]]; then
        return 0
    fi
    
    log "Performing quality check on transcription..."
    
    python3 << EOF
import json

# Load transcription
with open('$json_file', 'r') as f:
    data = json.load(f)

# Quality metrics
total_segments = len(data.get('segments', []))
total_duration = max(seg.get('end', 0) for seg in data.get('segments', [])) if data.get('segments') else 0
avg_confidence = sum(seg.get('avg_logprob', 0) for seg in data.get('segments', [])) / total_segments if total_segments > 0 else 0

print(f"Quality Report:")
print(f"- Total segments: {total_segments}")
print(f"- Duration: {total_duration:.1f} seconds")
print(f"- Average confidence: {avg_confidence:.3f}")

# Identify potential issues
low_confidence_segments = [seg for seg in data.get('segments', []) if seg.get('avg_logprob', 0) < -1.0]
if low_confidence_segments:
    print(f"- Low confidence segments: {len(low_confidence_segments)}")
    for seg in low_confidence_segments[:3]:  # Show first 3
        print(f"  * {seg.get('start', 0):.1f}s: {seg.get('text', '')[:50]}...")

# Check for silent periods
silent_gaps = []
prev_end = 0
for seg in data.get('segments', []):
    gap = seg.get('start', 0) - prev_end
    if gap > 5.0:  # 5+ second gaps
        silent_gaps.append(gap)
    prev_end = seg.get('end', 0)

if silent_gaps:
    print(f"- Long silent periods: {len(silent_gaps)} (avg: {sum(silent_gaps)/len(silent_gaps):.1f}s)")
EOF
}

process_single_file() {
    local input_file="$1"
    local output_dir="$2"
    
    local base_name
    base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    
    log "Processing: $(basename "$input_file")"
    
    # Extract audio if input is video
    local audio_file="$AUDIO_DIR/${base_name}.wav"
    if [[ "$input_file" =~ \.(mp4|mov|avi|mkv|webm|m4v)$ ]]; then
        extract_audio "$input_file" "$audio_file" || return 1
    else
        # Input is already audio
        audio_file="$input_file"
    fi
    
    # Transcribe with Whisper
    local raw_json
    raw_json=$(transcribe_with_whisper "$audio_file" "$base_name" "$TEMP_DIR") || return 1
    
    # Enhance transcription
    local enhanced_json="$TEMP_DIR/${base_name}_enhanced.json"
    enhance_with_political_keywords "$raw_json" "$TEMP_DIR/${base_name}_keywords.json"
    apply_speaker_detection "$TEMP_DIR/${base_name}_keywords.json" "$enhanced_json"
    
    # Generate output formats
    case "$FORMAT" in
        srt)
            generate_srt "$enhanced_json" "$SRT_DIR/${base_name}.srt"
            ;;
        vtt)
            generate_vtt "$enhanced_json" "$VTT_DIR/${base_name}.vtt"
            ;;
        txt)
            generate_txt "$enhanced_json" "$TXT_DIR/${base_name}.txt"
            ;;
        json)
            cp "$enhanced_json" "$JSON_DIR/${base_name}.json"
            ;;
        all)
            generate_srt "$enhanced_json" "$SRT_DIR/${base_name}.srt"
            generate_vtt "$enhanced_json" "$VTT_DIR/${base_name}.vtt"
            generate_txt "$enhanced_json" "$TXT_DIR/${base_name}.txt"
            cp "$enhanced_json" "$JSON_DIR/${base_name}.json"
            ;;
    esac
    
    # Quality check
    check_quality "$enhanced_json"
    
    success "Completed: $(basename "$input_file")"
}

main() {
    local input_file=""
    
    # Set defaults
    MODEL="$DEFAULT_MODEL"
    LANGUAGE="$DEFAULT_LANGUAGE"
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
    FORMAT="$DEFAULT_FORMAT"
    DEVICE="$DEFAULT_DEVICE"
    SPEAKER_DETECTION="false"
    POLITICAL_KEYWORDS="false"
    CONFIDENCE_THRESHOLD=""
    MAX_SEGMENT_LENGTH=""
    BEAM_SIZE=""
    TEMPERATURE=""
    WORD_TIMESTAMPS="false"
    VAD_FILTER="false"
    SUBTITLE_STYLE="default"
    BATCH_SIZE=""
    RESUME="false"
    QUALITY_CHECK="false"
    DRY_RUN="false"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--model)
                MODEL="$2"
                shift 2
                ;;
            -l|--language)
                LANGUAGE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -f|--format)
                FORMAT="$2"
                shift 2
                ;;
            -d|--device)
                DEVICE="$2"
                shift 2
                ;;
            --speaker-detection)
                SPEAKER_DETECTION="true"
                shift
                ;;
            --political-keywords)
                POLITICAL_KEYWORDS="true"
                shift
                ;;
            --confidence-threshold)
                CONFIDENCE_THRESHOLD="$2"
                shift 2
                ;;
            --max-segment-length)
                MAX_SEGMENT_LENGTH="$2"
                shift 2
                ;;
            --beam-size)
                BEAM_SIZE="$2"
                shift 2
                ;;
            --temperature)
                TEMPERATURE="$2"
                shift 2
                ;;
            --word-timestamps)
                WORD_TIMESTAMPS="true"
                shift
                ;;
            --vad-filter)
                VAD_FILTER="true"
                shift
                ;;
            --subtitle-style)
                SUBTITLE_STYLE="$2"
                shift 2
                ;;
            --batch-size)
                BATCH_SIZE="$2"
                shift 2
                ;;
            --resume)
                RESUME="true"
                shift
                ;;
            --quality-check)
                QUALITY_CHECK="true"
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
    
    # Validate model
    if [[ ! " ${WHISPER_MODELS[*]} " =~ " $MODEL " ]]; then
        error "Invalid model: $MODEL"
        echo "Available models: ${WHISPER_MODELS[*]}"
        exit 1
    fi
    
    # Validate input
    if [[ -z "$input_file" ]]; then
        error "Input file or directory required"
        usage
        exit 1
    fi
    
    if [[ ! -e "$input_file" ]]; then
        error "Input not found: $input_file"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    # Setup workspace
    setup_workspace "$OUTPUT_DIR"
    
    log "Starting local transcription..."
    log "Model: $MODEL"
    log "Language: $LANGUAGE"
    log "Device: $DEVICE"
    log "Output: $OUTPUT_DIR"
    
    # Process input
    if [[ -d "$input_file" ]]; then
        # Batch processing
        warn "Batch processing not fully implemented yet"
        log "Processing single files for now..."
        
        find "$input_file" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.wav" -o -iname "*.mp3" \) | \
        while read -r file; do
            process_single_file "$file" "$OUTPUT_DIR"
        done
    else
        # Single file processing
        process_single_file "$input_file" "$OUTPUT_DIR"
    fi
    
    success "Transcription complete! Output saved to: $OUTPUT_DIR"
    
    # Show summary
    if [[ "$DRY_RUN" == "false" ]]; then
        local file_count=0
        for dir in "$SRT_DIR" "$VTT_DIR" "$TXT_DIR" "$JSON_DIR"; do
            if [[ -d "$dir" ]]; then
                local count
                count=$(find "$dir" -type f | wc -l)
                file_count=$((file_count + count))
            fi
        done
        log "Generated $file_count output files"
    fi
}

# Run main function
main "$@" 