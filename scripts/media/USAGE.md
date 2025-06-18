# Media Scripts Library - Usage Guide

Complete automation for political video content creation, from long-form speeches to social media shorts with AI-powered transcription and subtitles.

## 🎯 Quick Start

### Generate Complete Shorts from Long Video
```bash
# One command to rule them all - extract clips, transcribe, add subtitles
generate-shorts campaign-speech.mp4

# Viral-optimized content for maximum engagement
quick-shorts rally.mp4

# Platform-specific ready-to-upload content
social-ready debate.mp4 -p tiktok,instagram,youtube
```

### Individual Processing Steps
```bash
# 1. Extract engaging clips automatically
auto-crop townhall.mp4 -c 5 -t speech

# 2. Transcribe with local AI (OpenAI Whisper)
transcribe speech-clip.mp4 -m base --political-keywords

# 3. Add professional subtitles
add-subtitles clip.mp4 transcript.srt -s social

# 4. Find specific highlights
extract-highlights debate.mp4 --type applause
```

## 📚 Core Scripts

### 🎬 Video Processing

#### `auto-crop.sh` - Intelligent Clip Extraction
```bash
# Extract 5 clips of 30 seconds each
auto-crop speech.mp4 -c 5 -d 30

# Focus on speech segments with quotes
auto-crop debate.mp4 --type speech --extract-quotes

# Multiple platforms simultaneously
auto-crop rally.mp4 -p tiktok,instagram,youtube
```

#### `highlight-detector.sh` - Find Key Moments
```bash
# Auto-detect all types of highlights
highlight-detector.sh event.mp4 --type auto

# Focus on audience reactions
highlight-detector.sh townhall.mp4 --type applause --audience-reactions

# Find vocal emphasis and passionate moments
highlight-detector.sh interview.mp4 --type emphasis --speaker-focus
```

#### `speech-segments.sh` - Political Speech Analysis
```bash
# Analyze speech patterns and extract key segments
speech-segments.sh debate.mp4 --event-type debate --speaker-name "Senator Smith"

# Extract quotable moments with transcription
speech-segments.sh speech.mp4 --extract-quotes --transcribe

# Detect applause and audience engagement
speech-segments.sh rally.mp4 --detect-applause --keyword-highlight
```

### 🎤 Audio & Transcription

#### `transcribe.sh` - Local AI Transcription
```bash
# Fast transcription for quick review
transcribe speech.mp4 -m tiny -f txt

# High-quality transcription with features
transcribe debate.mp4 -m large-v3 --political-keywords --speaker-detection

# Generate multiple formats
transcribe interview.mp4 -f all --word-timestamps
```

**Whisper Models Available:**
- `tiny`: Fastest, good for previews (~39 MB)
- `base`: Balanced speed/accuracy (~74 MB) **[Recommended]**
- `small`: Better accuracy (~244 MB)
- `medium`: High accuracy (~769 MB)
- `large`: Best accuracy (~1550 MB)
- `large-v3`: Latest, highest quality (~1550 MB)

### 🎨 Subtitle & Templates

#### `subtitle-overlay.sh` - Professional Subtitles
```bash
# Auto-transcribe and add social media subtitles
add-subtitles video.mp4 --auto-transcribe -s social

# Political style with speaker names
add-subtitles debate.mp4 transcript.srt -s political --speaker-names

# Dramatic style with keyword highlighting
add-subtitles rally.mp4 --style dramatic --keyword-highlight
```

**Subtitle Styles:**
- `social`: Bold, high-contrast for social media
- `political`: Professional with speaker identification  
- `modern`: Clean, minimal design
- `dramatic`: High-impact with animations
- `broadcast`: Traditional TV-style
- `minimal`: Simple text without background

### 🤖 Complete Automation

#### `shorts-generator.sh` - End-to-End Automation
```bash
# Complete pipeline with all features
generate-shorts debate.mp4 \
  --speaker-name "Senator Johnson" \
  --event-name "Healthcare Debate" \
  --viral-optimization \
  --parallel-processing

# Quick social media content
generate-shorts interview.mp4 \
  -s social \
  -p tiktok,instagram \
  --keyword-highlight

# High-quality professional content
generate-shorts speech.mp4 \
  -q high \
  -s political \
  --speaker-detection \
  --brand-overlay
```

#### `clip-pipeline.sh` - Professional Workflow
```bash
# Complete professional pipeline
media-pipeline townhall.mp4 \
  --speaker "Mayor Davis" \
  --event-name "Infrastructure Town Hall" \
  --auto-captions

# Quick workflow for urgent content
media-pipeline breaking-news.mp4 \
  --workflow quick \
  --platforms tiktok,twitter
```

#### `bulk-process.sh` - Batch Processing
```bash
# Process entire directory
bulk-process ./campaign-videos \
  --parallel 4 \
  --workflow full \
  --speaker-detect

# Resume interrupted processing
bulk-process ./videos --resume --priority-order
```

## 🎯 Platform-Specific Examples

### TikTok & Instagram Reels
```bash
# Vertical format with bold subtitles
generate-shorts rally.mp4 \
  -p tiktok,instagram \
  -s social \
  --viral-optimization \
  -d 30
```

### YouTube Shorts
```bash
# Horizontal format with clean subtitles
generate-shorts speech.mp4 \
  -p youtube \
  -s modern \
  --keyword-highlight \
  -d 45
```

### Professional Platforms (LinkedIn, Twitter)
```bash
# Professional styling with speaker identification
generate-shorts debate.mp4 \
  -p linkedin,twitter \
  -s political \
  --speaker-detection \
  --brand-overlay
```

## 🚀 Advanced Workflows

### Campaign Event Processing
```bash
# Process full campaign event
bulk-process ./campaign-rally/ \
  --event-detect \
  --speaker-detect \
  --viral-optimization \
  --parallel-processing

# Extract highlights from long events
extract-highlights 3-hour-townhall.mp4 \
  --type auto \
  -n 10 \
  --audience-reactions
```

### Debate Analysis
```bash
# Comprehensive debate processing
generate-shorts debate.mp4 \
  --content-type debate \
  --speaker-name "Candidate Smith" \
  --detection-type applause \
  --keyword-highlight \
  --speaker-detection
```

### Interview Content
```bash
# Interview highlights with quotable moments
political-clips interview.mp4 \
  --type interview \
  --extract-quotes \
  --min-duration 15 \
  --max-duration 45
```

## 🔧 Configuration Options

### Quality Levels
- `fast`: Quick processing for previews
- `balanced`: Good quality/speed balance **[Default]**
- `high`: Maximum quality for final content

### Detection Types
- `auto`: Combine all detection methods
- `applause`: Audience reaction moments
- `emphasis`: Vocal emphasis and passion
- `scene`: Visual scene changes
- `motion`: Significant motion and gestures

### Content Types
- `speech`: Formal speeches and prepared remarks
- `debate`: Multi-speaker debates and panels
- `interview`: Q&A sessions and interviews
- `event`: Campaign events and rallies

## 📊 Output Organization

All scripts create organized output directories:

```
./output-directory/
├── final-shorts/
│   ├── tiktok/          # 9:16 vertical clips
│   ├── instagram/       # 1:1 square and 9:16 stories
│   ├── youtube/         # 16:9 horizontal shorts
│   ├── twitter/         # 16:9 with captions
│   └── linkedin/        # Professional 16:9
├── transcripts/
│   ├── srt/            # Subtitle files
│   ├── txt/            # Plain text transcripts
│   └── json/           # Detailed metadata
├── analysis/           # Processing reports
└── logs/              # Detailed processing logs
```

## 🎨 Customization

### Brand Colors
Edit in `modules/common/media-workflows.nix`:
```nix
BRAND_PRIMARY = "#1E3A8A";    # Campaign blue
BRAND_SECONDARY = "#DC2626";  # Accent red
BRAND_ACCENT = "#FBBF24";     # Gold highlights
```

### Political Keywords
Add to transcription for enhanced detection:
```bash
transcribe speech.mp4 --keywords custom-keywords.txt
```

### Subtitle Styling
Customize colors, fonts, and positioning:
```bash
add-subtitles video.mp4 \
  --primary-color "#FFFFFF" \
  --outline-color "#000000" \
  --font-family "Arial Bold" \
  --position bottom
```

## 🚨 Tips for Political Communications

### Best Practices
1. **Speed**: Use `quick-shorts` for rapid response content
2. **Quality**: Use `generate-shorts -q high` for important announcements
3. **Engagement**: Always use `--viral-optimization` for social media
4. **Accessibility**: Include `--speaker-detection` for diverse audiences
5. **Compliance**: Use `--keyword-highlight` to ensure message consistency

### Content Strategy
- **Debates**: Focus on `--type applause` for winning moments
- **Speeches**: Use `--extract-quotes` for shareable content
- **Town Halls**: Combine `--audience-reactions` with `--speaker-detection`
- **Interviews**: Process with `--political-keywords` for message tracking

### Platform Targeting
- **TikTok**: Short (15-30s), bold styling, vertical format
- **Instagram**: Multiple formats, story-friendly content
- **YouTube**: Longer form (30-60s), SEO-optimized
- **Twitter**: Quick, captioned, horizontal format
- **LinkedIn**: Professional, speaker-identified content

## 🔍 Troubleshooting

### Common Issues
```bash
# FFmpeg not found
nix-shell -p ffmpeg

# Whisper not installed
pip3 install --user openai-whisper

# Scripts not executable
chmod +x scripts/media/**/*.sh

# Python dependencies missing
pip3 install torch torchaudio
```

### Performance Optimization
```bash
# Use parallel processing for large batches
bulk-process --parallel 8

# Preview mode for quick testing
generate-shorts video.mp4 --preview-mode

# Fast transcription for previews
transcribe video.mp4 -m tiny
```

### Quality Issues
```bash
# Increase transcription quality
transcribe video.mp4 -m large-v3 --beam-size 5

# Better subtitle positioning
add-subtitles video.mp4 --position center --font-size 28

# High-quality video processing
generate-shorts video.mp4 -q high --no-duplicates
```

---

## 🎉 Complete Example Workflow

Transform a 2-hour campaign event into viral social media content:

```bash
# 1. Extract the best moments
extract-highlights campaign-event.mp4 \
  --type auto \
  -n 8 \
  --audience-reactions \
  --speaker-focus

# 2. Generate platform-ready shorts with AI transcription
generate-shorts campaign-event.mp4 \
  --speaker-name "Candidate Johnson" \
  --event-name "Healthcare for All Rally" \
  --viral-optimization \
  --parallel-processing \
  --keyword-highlight \
  -p tiktok,instagram,youtube,twitter

# 3. Result: 24+ ready-to-upload clips across all platforms
#    with professional subtitles and optimized for engagement
```

This complete workflow transforms hours of campaign footage into dozens of platform-optimized clips in minutes, each with professional subtitles and maximum viral potential! 🚀 