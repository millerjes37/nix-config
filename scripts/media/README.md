# Media Scripts Library

Professional video processing and automation scripts for political communications and social media content creation.

## Overview

This library provides intelligent automation for extracting short-form content from long-form videos, with specialized tools for political communications, speeches, interviews, and campaign content.

## Scripts Directory Structure

```
scripts/media/
├── video/
│   ├── auto-crop.sh          # Intelligent short-form extraction
│   ├── speech-segments.sh    # Extract key speech moments
│   ├── highlight-detector.sh # Find highlights automatically
│   ├── batch-clips.sh        # Generate multiple clips
│   └── smart-crop.sh         # AI-assisted cropping
├── audio/
│   ├── speech-analysis.sh    # Analyze speech patterns
│   ├── silence-detect.sh     # Find natural break points
│   └── volume-peaks.sh       # Identify loud/important moments
├── templates/
│   ├── social-formats.sh     # Platform-specific formatting
│   ├── caption-overlay.sh    # Add captions automatically
│   └── brand-overlay.sh      # Add consistent branding
├── automation/
│   ├── clip-pipeline.sh      # Full processing pipeline
│   ├── bulk-process.sh       # Process multiple videos
│   └── content-scheduler.sh  # Prepare content for scheduling
└── utils/
    ├── scene-detect.sh       # Scene change detection
    ├── face-track.sh         # Track speaker/candidate
    └── quality-check.sh      # Validate output quality
```

## Core Features

### Intelligent Short-Form Extraction
- **Auto-Crop**: Automatically identify and extract engaging segments
- **Speech Segments**: Extract key quotes and talking points
- **Scene Detection**: Find natural break points for clips
- **Volume Analysis**: Identify emphatic or important moments

### Platform Optimization
- **TikTok/Reels**: 9:16 vertical format, 15-60 seconds
- **YouTube Shorts**: Optimized for discovery and engagement
- **Instagram Stories**: 15-second segments with branding
- **Twitter**: Horizontal format with captions

### Political Communication Features
- **Quote Extraction**: Automatically identify quotable moments
- **Speaker Tracking**: Keep candidate/speaker centered in frame
- **Applause Detection**: Include audience reaction moments
- **Key Point Identification**: Extract policy statements and key messages

### Automation Workflows
- **Batch Processing**: Process multiple long-form videos
- **Template Application**: Apply consistent branding and styling
- **Caption Generation**: Auto-generate and overlay captions
- **Multi-Platform Export**: Create versions for all social platforms

## Quick Start

### Extract Short Clips from Long Video
```bash
# Automatically extract 5 best clips from a speech
./video/auto-crop.sh speech.mp4 --clips 5 --duration 30

# Extract all segments with high audience engagement
./video/highlight-detector.sh town-hall.mp4 --type applause

# Create platform-specific versions
./automation/clip-pipeline.sh interview.mp4 --platforms tiktok,instagram,youtube
```

### Batch Process Multiple Videos
```bash
# Process all videos in a directory
./automation/bulk-process.sh /path/to/campaign/videos --output /path/to/clips

# Generate daily social content from events
./automation/content-scheduler.sh event-footage/ --schedule daily
```

## Advanced Features

### AI-Assisted Content Detection
- Scene change detection for natural break points
- Face tracking to keep speakers in frame
- Audio analysis for speech emphasis and emotional peaks
- Automatic quality assessment and filtering

### Brand Consistency
- Automatic watermarking with campaign logos
- Consistent color grading and filters
- Standardized caption styling and fonts
- Platform-specific optimization

### Content Strategy
- Keyword and topic extraction from audio
- Sentiment analysis for positive messaging
- Engagement prediction based on content analysis
- A/B testing preparation with multiple versions

## Installation and Setup

1. **Dependencies**: FFmpeg, ImageMagick, SoX, Python (with speech recognition)
2. **Configuration**: Set brand colors, logos, and templates
3. **Calibration**: Train on your specific content type and speaking style
4. **Integration**: Connect with social media scheduling tools

## Best Practices

### Input Preparation
- Use high-quality source material (1080p minimum)
- Ensure clean audio with minimal background noise
- Film with multiple camera angles when possible
- Plan for key quotes and moments during recording

### Output Optimization
- Test clips on target platforms before bulk processing
- Verify caption accuracy and timing
- Check brand compliance and visual consistency
- Monitor engagement metrics to refine algorithms

### Workflow Integration
- Process content immediately after events
- Create multiple versions for A/B testing
- Schedule releases for optimal engagement times
- Archive source material and successful clips

This library transforms hours of campaign footage into engaging, platform-optimized content that maintains professional quality while maximizing reach and engagement across all social media platforms. 