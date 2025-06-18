# Political Communications Media Suite

A complete, declarative media editing environment for political campaigns and communications, built with Nix for reproducible workflows across all platforms.

## Overview

This media suite provides professional-grade tools and automated workflows specifically designed for political communications, social media management, and campaign content creation.

### Core Philosophy

- **Consistency**: Reproducible outputs across all platforms and team members
- **Speed**: Automated workflows for rapid content turnaround
- **Professionalism**: Broadcast-quality tools and templates
- **Brand Compliance**: Built-in brand guidelines and automated enforcement
- **Scalability**: Works for local campaigns to major political operations

## Tools Included

### Video Production Suite

- **Kdenlive**: Primary video editor with templates
- **DaVinci Resolve**: Professional color grading and finishing
- **FFmpeg**: Automated video processing and conversion
- **OBS Studio**: Live streaming and screen recording
- **Handbrake**: Video compression and format conversion

### Image Editing Suite

- **GIMP**: Primary image editor with campaign plugins
- **Inkscape**: Vector graphics and logo design
- **Krita**: Digital artwork and graphics creation
- **Darktable**: RAW photo processing for events
- **ImageMagick**: Batch processing and automation

### Audio Production

- **Audacity**: Audio editing and podcast production
- **Ardour**: Professional audio mixing
- **LMMS**: Background music and jingle creation
- **SoX**: Command-line audio processing

### Specialized Tools

- **Blender**: 3D graphics and motion design
- **Scribus**: Print layout and design
- **Tesseract**: OCR for digitizing documents
- **QR Code Tools**: Generate campaign QR codes

## Automated Workflows

### Social Media Video Processing

Automatically convert videos to platform-specific formats:

```bash
# Convert to Instagram format (1:1, 1080x1080, 60s max)
social-video.sh input.mp4 instagram

# Convert to Twitter format (16:9, 1280x720, 140s max)  
social-video.sh input.mp4 twitter

# Convert to Facebook format (16:9, 1280x720)
social-video.sh input.mp4 facebook
```

### Campaign Post Generation

Create branded social media posts automatically:

```bash
# Generate campaign post with consistent branding
campaign-post.sh "Vote for Change!" photo.jpg "Jane Smith"
```

This creates:
- Instagram post (1080x1080)
- Facebook post (1200x630)
- Twitter post (1024x512)
- All with consistent branding, fonts, and hashtags

### Batch Image Processing

Process multiple images for different platforms:

```bash
# Resize all images in a directory for social media
batch-resize.sh /path/to/event/photos
```

Outputs:
- Instagram posts and stories
- Facebook covers and posts
- Twitter headers and posts
- LinkedIn format

### Audio Processing

Optimize audio for different uses:

```bash
# Process speech for clarity
audio-process.sh recording.wav speech

# Create podcast-quality audio
audio-process.sh interview.wav podcast

# Prepare voiceover for videos
audio-process.sh narration.wav voiceover
```

## AI-Powered Content Creation

### Intelligent Short-Form Content Generation

Automatically create engaging social media clips from long-form videos using AI:

```bash
# Complete automation: Extract clips, transcribe, add subtitles
generate-shorts debate.mp4

# Fast viral-optimized content for all platforms
quick-shorts rally.mp4 --viral-optimization

# Platform-specific content ready for upload
social-ready interview.mp4 -p tiktok,instagram,youtube
```

### Local AI Transcription

High-accuracy speech transcription using OpenAI's Whisper models:

```bash
# Fast transcription for quick review
transcribe-fast speech.mp4

# High-quality transcription with political keyword detection
transcribe-quality debate.mp4

# Generate subtitles with professional styling
add-captions townhall.mp4 -s political
```

### Intelligent Clip Extraction

AI-powered analysis to find the most engaging moments:

```bash
# Extract quotable political moments
political-clips speech.mp4 --extract-quotes

# Find audience reaction highlights
debate-highlights townhall.mp4 --audience-reactions

# Automatically detect scene changes and emphasis
extract-highlights event.mp4 --type auto
```

### Advanced Features

**Content Analysis**:
- Speech pattern recognition
- Vocal emphasis detection
- Audience reaction identification
- Scene change analysis
- Political keyword extraction

**Subtitle Styles**:
- `social`: Bold, high-contrast for social media
- `political`: Professional with speaker identification
- `modern`: Clean, minimal design
- `dramatic`: High-impact with animations
- `broadcast`: Traditional TV-style

**Platform Optimization**:
- TikTok: 9:16 vertical, mobile-optimized
- Instagram: 1:1 square and 9:16 stories
- YouTube: 16:9 horizontal with SEO optimization
- Twitter: Captions and engagement-focused
- LinkedIn: Professional formatting

### Batch Processing

Process multiple videos efficiently:

```bash
# Process entire directories in parallel
bulk-process ./campaign-videos --parallel-processing

# Complete pipeline for professional workflows
media-pipeline important-speech.mp4 --quality high

# Preview mode for rapid content planning
generate-shorts event.mp4 --preview-mode
```

## Directory Structure

The suite creates an organized project structure:

```
~/Projects/Media/
├── Video/           # Video projects and assets
├── Audio/           # Audio files and projects
├── Graphics/        # Image and graphics work
├── Templates/       # Platform-specific templates
├── Assets/          # Brand assets and resources
│   ├── Logos/       # Campaign logos and branding
│   ├── Fonts/       # Consistent typography
│   ├── Colors/      # Brand color palettes
│   ├── Photos/      # Photo library
│   └── Audio/       # Sound effects and music
├── Scripts/         # Automation scripts
│   ├── ffmpeg/      # Video processing scripts
│   ├── gimp/        # Image processing scripts
│   └── automation/  # Workflow automation
└── Export/          # Final output files
    ├── Social/      # Social media formats
    ├── Web/         # Web-optimized content
    ├── Print/       # Print-ready materials
    └── Video/       # Video deliverables
```

## Brand Consistency

### Color Management

Standardized brand colors automatically applied:
- **Primary Blue**: #1E3A8A (campaign primary)
- **Secondary Red**: #DC2626 (accent and highlights)
- **Accent Gold**: #FBBF24 (important elements)
- **Neutral Gray**: #6B7280 (supporting text)
- **Light Gray**: #F9FAFB (backgrounds)
- **Dark Gray**: #111827 (high contrast text)

### Typography

Consistent font usage:
- **Headers**: Arial Bold / Helvetica Bold
- **Body Text**: Arial / Helvetica
- **Accent Text**: Custom campaign fonts
- **Fallbacks**: Liberation Sans, system fonts

### Templates

Pre-built templates for:
- Instagram posts and stories
- Facebook covers and posts
- Twitter headers and graphics
- LinkedIn banners
- YouTube thumbnails
- Print materials (flyers, banners)

## Platform-Specific Optimizations

### Instagram
- **Posts**: 1080x1080, max 60s video
- **Stories**: 1080x1920, max 15s video
- **Reels**: 1080x1920, optimized for engagement

### Twitter/X
- **Posts**: 1024x512 for images
- **Headers**: 1500x500
- **Videos**: 1280x720, max 140s

### Facebook
- **Posts**: 1200x630
- **Covers**: 1200x315
- **Videos**: 1280x720, optimized for autoplay

### TikTok
- **Videos**: 1080x1920, vertical format
- **Optimized**: High engagement, quick cuts

### YouTube
- **Videos**: 1920x1080, broadcast quality
- **Thumbnails**: 1280x720

## GIMP Enhancements

### Custom Scripts
- **Campaign Watermark**: Automatic branding overlay
- **Batch Processing**: Process multiple images consistently
- **Social Media Export**: One-click export to all formats

### Brand Palettes
- Pre-loaded campaign colors in GIMP
- Consistent color usage across all graphics
- Brand compliance checking

### Keyboard Shortcuts
Optimized shortcuts for political media workflows:
- `Ctrl+E`: Quick export
- `Ctrl+Shift+E`: Export as (format selection)
- `T`: Text tool (for rapid text addition)
- `C`: Crop tool (for social media formatting)

## FFmpeg Automation

### Video Processing Profiles

Pre-configured encoding settings:
- **Social Media**: Optimized for mobile viewing
- **Web Streaming**: Balance of quality and file size
- **Archive**: High-quality preservation
- **Preview**: Low-quality for quick review

### Audio Enhancement

Automatic audio improvements:
- **Noise Reduction**: Remove background noise
- **Speech Clarity**: Enhance voice recordings
- **Normalization**: Consistent audio levels
- **Compression**: Optimize for different platforms

## Live Streaming Setup

### OBS Studio Configuration

Pre-configured scenes for:
- **Campaign Events**: Multi-camera setup
- **Interviews**: Professional talking head format
- **Town Halls**: Audience and speaker views
- **Press Conferences**: Formal presentation layout

### Streaming Targets
- Facebook Live
- YouTube Live
- Twitter Spaces
- Instagram Live
- Zoom integration

## Collaboration Features

### Version Control
- Git-based project tracking
- Asset versioning
- Change history for templates

### Team Workflows
- Standardized naming conventions
- Shared template library
- Consistent output formats

### Review Process
- Preview generation
- Approval workflows
- Archive management

## Performance Optimization

### Hardware Acceleration
- GPU-accelerated video encoding
- OpenCL support for image processing
- Multi-core rendering optimization

### Storage Management
- Automatic cleanup of temporary files
- Compressed project archives
- Cloud sync integration

## Quality Assurance

### Automated Checks
- Brand compliance verification
- Format validation
- Quality metrics
- Accessibility compliance

### Output Standards
- Consistent resolution and quality
- Proper aspect ratios
- Optimized file sizes
- Platform-specific requirements

## Training and Documentation

### Quick Start Guides
- Platform-specific workflows
- Common tasks and shortcuts
- Troubleshooting guides

### Advanced Techniques
- Custom script development
- Template creation
- Workflow optimization

## Security and Privacy

### Content Protection
- Watermarking for sensitive content
- Secure file storage
- Access control for team members

### Compliance
- Campaign finance compliance
- Copyright management
- Privacy protection

## Installation and Setup

### System Requirements
- **Linux**: Full feature support
- **macOS**: Native app integration
- **Memory**: 8GB+ recommended
- **Storage**: 500GB+ for media projects
- **GPU**: Hardware acceleration recommended

### Configuration
1. Install via Nix configuration
2. Run setup scripts for templates
3. Configure brand assets
4. Set up team collaboration

### Customization
- Modify brand colors in configuration
- Update templates with campaign assets
- Customize automation scripts
- Configure team workflows

## Support and Updates

### Maintenance
- Automated package updates via Nix
- Template library updates
- Script improvements
- Platform compatibility updates

### Community
- Share workflows and templates
- Contribute improvements
- Request new features
- Report issues

## Best Practices

### Project Organization
- Use consistent naming conventions
- Organize assets by campaign/date
- Maintain template libraries
- Archive completed projects

### Quality Control
- Review all content before publishing
- Test on target platforms
- Verify brand compliance
- Check accessibility requirements

### Efficiency Tips
- Use batch processing for similar content
- Create reusable templates
- Automate repetitive tasks
- Maintain asset libraries

This media suite transforms political communications from ad-hoc content creation into a professional, scalable, and consistent media operation that maintains quality while enabling rapid response to political events and opportunities. 