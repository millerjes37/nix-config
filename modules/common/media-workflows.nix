{ config, lib, pkgs, ... }:

{
  # Media Workflow Automation Scripts for Political Communications
  # Consistent, reproducible workflows for social media and campaign content

  home.file = {
    # FFmpeg automation scripts
    "Projects/Media/Scripts/ffmpeg/social-video.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Social Media Video Processing Script
        # Usage: social-video.sh input.mp4 platform
        # Platforms: instagram, twitter, facebook, tiktok, youtube

        set -euo pipefail

        INPUT="$1"
        PLATFORM="''${2:-instagram}"
        OUTPUT_DIR="$HOME/Projects/Media/Export/Social"
        BASENAME=$(basename "$INPUT" .mp4)

        echo "Processing $INPUT for $PLATFORM..."

        case "$PLATFORM" in
          "instagram")
            # Instagram Post (1:1, 1080x1080, max 60s)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -vf "scale=1080:1080:force_original_aspect_ratio=increase,crop=1080:1080,fps=30" \
              -c:v libx264 -preset medium -crf 23 \
              -c:a aac -b:a 128k -ac 2 \
              -t 60 \
              "$OUTPUT_DIR/''${BASENAME}_instagram.mp4"
            ;;
          
          "twitter")
            # Twitter Video (16:9, max 1280x720, max 140s)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30" \
              -c:v libx264 -preset medium -crf 25 \
              -c:a aac -b:a 128k -ac 2 \
              -t 140 \
              "$OUTPUT_DIR/''${BASENAME}_twitter.mp4"
            ;;
          
          "facebook")
            # Facebook Video (16:9, 1280x720)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,fps=30" \
              -c:v libx264 -preset medium -crf 23 \
              -c:a aac -b:a 128k -ac 2 \
              "$OUTPUT_DIR/''${BASENAME}_facebook.mp4"
            ;;
          
          "tiktok")
            # TikTok Video (9:16, 1080x1920, max 60s)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30" \
              -c:v libx264 -preset medium -crf 23 \
              -c:a aac -b:a 128k -ac 2 \
              -t 60 \
              "$OUTPUT_DIR/''${BASENAME}_tiktok.mp4"
            ;;
          
          "youtube")
            # YouTube Video (16:9, 1920x1080)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fps=30" \
              -c:v libx264 -preset medium -crf 20 \
              -c:a aac -b:a 192k -ac 2 \
              "$OUTPUT_DIR/''${BASENAME}_youtube.mp4"
            ;;
          
          *)
            echo "Unknown platform: $PLATFORM"
            echo "Supported platforms: instagram, twitter, facebook, tiktok, youtube"
            exit 1
            ;;
        esac

        echo "✅ Video processed for $PLATFORM"
      '';
    };

    "Projects/Media/Scripts/ffmpeg/audio-process.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Audio Processing Script for Political Communications
        # Usage: audio-process.sh input.wav type
        # Types: podcast, speech, music, voiceover

        set -euo pipefail

        INPUT="$1"
        TYPE="''${2:-speech}"
        OUTPUT_DIR="$HOME/Projects/Media/Export/Audio"
        BASENAME=$(basename "$INPUT" .wav)

        echo "Processing $INPUT as $TYPE..."

        case "$TYPE" in
          "podcast")
            # Podcast quality (mono, 64kbps, normalized)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -af "highpass=f=80,lowpass=f=10000,loudnorm" \
              -ac 1 -ar 44100 \
              -c:a libmp3lame -b:a 64k \
              "$OUTPUT_DIR/''${BASENAME}_podcast.mp3"
            ;;
          
          "speech")
            # Speech enhancement (noise reduction, clarity)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -af "highpass=f=100,lowpass=f=8000,compand=0.3|0.3:1|1:-90/-60|-60/-40|-40/-30|-20/-20:6:0:-90:0.2,loudnorm" \
              -ac 1 -ar 22050 \
              -c:a libmp3lame -b:a 96k \
              "$OUTPUT_DIR/''${BASENAME}_speech.mp3"
            ;;
          
          "music")
            # Music quality (stereo, high quality)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -af "loudnorm" \
              -ac 2 -ar 44100 \
              -c:a libmp3lame -b:a 192k \
              "$OUTPUT_DIR/''${BASENAME}_music.mp3"
            ;;
          
          "voiceover")
            # Voiceover for videos (optimized for speech clarity)
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$INPUT" \
              -af "highpass=f=85,lowpass=f=8000,compand=0.02|0.02:0.3|0.3:-40/-40|-30/-15|-20/-10|-5/-5:2:0:0:0.02,loudnorm" \
              -ac 1 -ar 44100 \
              -c:a aac -b:a 128k \
              "$OUTPUT_DIR/''${BASENAME}_voiceover.aac"
            ;;
          
          *)
            echo "Unknown type: $TYPE"
            echo "Supported types: podcast, speech, music, voiceover"
            exit 1
            ;;
        esac

        echo "✅ Audio processed as $TYPE"
      '';
    };

    "Projects/Media/Scripts/ffmpeg/batch-resize.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Batch Image Resizing for Social Media
        # Usage: batch-resize.sh input_directory

        set -euo pipefail

        INPUT_DIR="$1"
        OUTPUT_DIR="$HOME/Projects/Media/Export/Social"

        echo "Batch processing images from $INPUT_DIR..."

        for img in "$INPUT_DIR"/*.{jpg,jpeg,png,gif}; do
          [ -f "$img" ] || continue
          
          BASENAME=$(basename "$img")
          NAME="''${BASENAME%.*}"
          
          echo "Processing $BASENAME..."
          
          # Instagram Post (1080x1080)
          ${pkgs.imagemagick}/bin/convert "$img" \
            -resize 1080x1080^ \
            -gravity center \
            -extent 1080x1080 \
            -quality 85 \
            "$OUTPUT_DIR/''${NAME}_instagram.jpg"
          
          # Facebook/Twitter (1200x630)
          ${pkgs.imagemagick}/bin/convert "$img" \
            -resize 1200x630^ \
            -gravity center \
            -extent 1200x630 \
            -quality 85 \
            "$OUTPUT_DIR/''${NAME}_facebook.jpg"
          
          # Instagram Story (1080x1920)
          ${pkgs.imagemagick}/bin/convert "$img" \
            -resize 1080x1920^ \
            -gravity center \
            -extent 1080x1920 \
            -quality 85 \
            "$OUTPUT_DIR/''${NAME}_story.jpg"
          
          # LinkedIn (1200x1200)
          ${pkgs.imagemagick}/bin/convert "$img" \
            -resize 1200x1200^ \
            -gravity center \
            -extent 1200x1200 \
            -quality 85 \
            "$OUTPUT_DIR/''${NAME}_linkedin.jpg"
        done

        echo "✅ Batch processing complete!"
      '';
    };

    # Political campaign automation script
    "Projects/Media/Scripts/automation/campaign-post.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Campaign Post Creation Automation
        # Usage: campaign-post.sh "message" image_path candidate_name

        set -euo pipefail

        MESSAGE="$1"
        IMAGE_PATH="$2"
        CANDIDATE="''${3:-Candidate}"
        OUTPUT_DIR="$HOME/Projects/Media/Export/Social"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

        echo "Creating campaign post for $CANDIDATE..."

        # Create branded social media post
        ${pkgs.imagemagick}/bin/convert "$IMAGE_PATH" \
          -resize 1080x1080^ \
          -gravity center \
          -extent 1080x1080 \
          \( -size 1080x200 xc:'rgba(0,0,0,0.7)' \) \
          -gravity south \
          -composite \
          -font Arial-Bold \
          -pointsize 36 \
          -fill white \
          -gravity south \
          -annotate +0+120 "$CANDIDATE" \
          -pointsize 24 \
          -annotate +0+80 "$(echo "$MESSAGE" | fold -s -w 40)" \
          -pointsize 18 \
          -annotate +0+20 "#Vote2024 #LocalPolitics" \
          "$OUTPUT_DIR/campaign_post_$TIMESTAMP.jpg"

        # Create Facebook version
        ${pkgs.imagemagick}/bin/convert "$OUTPUT_DIR/campaign_post_$TIMESTAMP.jpg" \
          -resize 1200x630^ \
          -gravity center \
          -extent 1200x630 \
          "$OUTPUT_DIR/campaign_post_facebook_$TIMESTAMP.jpg"

        # Create Twitter version
        ${pkgs.imagemagick}/bin/convert "$OUTPUT_DIR/campaign_post_$TIMESTAMP.jpg" \
          -resize 1024x512^ \
          -gravity center \
          -extent 1024x512 \
          "$OUTPUT_DIR/campaign_post_twitter_$TIMESTAMP.jpg"

        echo "✅ Campaign post created: campaign_post_$TIMESTAMP.jpg"
        echo "📱 Available formats: Instagram, Facebook, Twitter"
      '';
    };

    # GIMP batch processing script
    "Projects/Media/Scripts/gimp/batch-watermark.py" = {
      text = ''
        #!/usr/bin/env python3
        # GIMP Script for Batch Watermarking
        # Place in GIMP scripts directory and run from GIMP

        from gimpfu import *
        import os

        def batch_watermark(input_dir, watermark_path, output_dir, opacity):
            """Apply watermark to all images in directory"""
            
            for filename in os.listdir(input_dir):
                if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.tiff')):
                    input_path = os.path.join(input_dir, filename)
                    output_path = os.path.join(output_dir, 'watermarked_' + filename)
                    
                    # Open image
                    image = pdb.gimp_file_load(input_path, input_path)
                    layer = pdb.gimp_image_get_active_layer(image)
                    
                    # Open watermark
                    watermark = pdb.gimp_file_load_layer(image, watermark_path)
                    pdb.gimp_image_insert_layer(image, watermark, None, 0)
                    
                    # Position watermark (bottom right)
                    img_width = pdb.gimp_image_width(image)
                    img_height = pdb.gimp_image_height(image)
                    watermark_width = pdb.gimp_drawable_width(watermark)
                    watermark_height = pdb.gimp_drawable_height(watermark)
                    
                    x_offset = img_width - watermark_width - 20
                    y_offset = img_height - watermark_height - 20
                    
                    pdb.gimp_layer_set_offsets(watermark, x_offset, y_offset)
                    pdb.gimp_layer_set_opacity(watermark, opacity)
                    
                    # Flatten and export
                    pdb.gimp_image_flatten(image)
                    pdb.gimp_file_save(image, pdb.gimp_image_get_active_layer(image), 
                                     output_path, output_path)
                    pdb.gimp_image_delete(image)

        register(
            "batch_watermark",
            "Batch Watermark Images",
            "Apply watermark to all images in a directory",
            "Media Workflow",
            "GPL",
            "2024",
            "<Toolbox>/Tools/Batch Watermark",
            "",
            [
                (PF_DIRNAME, "input_dir", "Input Directory", ""),
                (PF_FILE, "watermark_path", "Watermark File", ""),
                (PF_DIRNAME, "output_dir", "Output Directory", ""),
                (PF_SLIDER, "opacity", "Watermark Opacity", 80, (0, 100, 1))
            ],
            [],
            batch_watermark
        )

        main()
      '';
    };

    # Color palette generator for brand consistency
    "Projects/Media/Scripts/automation/brand-colors.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Brand Color Palette Generator
        # Creates consistent color swatches for campaign materials

        COLORS_DIR="$HOME/Projects/Media/Assets/Colors"
        OUTPUT_DIR="$HOME/Projects/Media/Export"

        # Define brand colors (customize these)
        BRAND_PRIMARY="#1E3A8A"    # Blue
        BRAND_SECONDARY="#DC2626"  # Red  
        BRAND_ACCENT="#FBBF24"     # Gold
        BRAND_NEUTRAL="#6B7280"    # Gray
        BRAND_LIGHT="#F9FAFB"      # Light gray
        BRAND_DARK="#111827"       # Dark gray

        echo "Generating brand color palette..."

        # Create color swatches
        ${pkgs.imagemagick}/bin/convert -size 200x200 xc:"$BRAND_PRIMARY" "$COLORS_DIR/primary.png"
        ${pkgs.imagemagick}/bin/convert -size 200x200 xc:"$BRAND_SECONDARY" "$COLORS_DIR/secondary.png"
        ${pkgs.imagemagick}/bin/convert -size 200x200 xc:"$BRAND_ACCENT" "$COLORS_DIR/accent.png"
        ${pkgs.imagemagick}/bin/convert -size 200x200 xc:"$BRAND_NEUTRAL" "$COLORS_DIR/neutral.png"
        ${pkgs.imagemagick}/bin/convert -size 200x200 xc:"$BRAND_LIGHT" "$COLORS_DIR/light.png"
        ${pkgs.imagemagick}/bin/convert -size 200x200 xc:"$BRAND_DARK" "$COLORS_DIR/dark.png"

        # Create complete palette
        ${pkgs.imagemagick}/bin/convert \
          "$COLORS_DIR/primary.png" "$COLORS_DIR/secondary.png" "$COLORS_DIR/accent.png" \
          "$COLORS_DIR/neutral.png" "$COLORS_DIR/light.png" "$COLORS_DIR/dark.png" \
          +append "$OUTPUT_DIR/brand_palette.png"

        # Create GIMP palette file
        cat > "$COLORS_DIR/brand.gpl" << EOF
        GIMP Palette
        Name: Campaign Brand Colors
        #
        ${BRAND_PRIMARY#\#} Primary Blue
        ${BRAND_SECONDARY#\#} Secondary Red
        ${BRAND_ACCENT#\#} Accent Gold
        ${BRAND_NEUTRAL#\#} Neutral Gray
        ${BRAND_LIGHT#\#} Light Gray
        ${BRAND_DARK#\#} Dark Gray
        EOF

        echo "✅ Brand color palette generated!"
        echo "📁 Swatches: $COLORS_DIR/"
        echo "🎨 Palette: $OUTPUT_DIR/brand_palette.png"
        echo "🖌️  GIMP Palette: $COLORS_DIR/brand.gpl"
      '';
    };

    # Template creation script
    "Projects/Media/Scripts/automation/create-templates.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Create Social Media Templates
        # Generates consistent template layouts for different platforms

        TEMPLATES_DIR="$HOME/Projects/Media/Templates"
        BRAND_PRIMARY="#1E3A8A"
        BRAND_LIGHT="#F9FAFB"

        echo "Creating social media templates..."

        # Instagram Post Template (1080x1080)
        ${pkgs.imagemagick}/bin/convert \
          -size 1080x1080 xc:"$BRAND_LIGHT" \
          -fill "$BRAND_PRIMARY" \
          -draw "rectangle 0,0 1080,120" \
          -draw "rectangle 0,960 1080,1080" \
          -fill white \
          -font Arial-Bold \
          -pointsize 48 \
          -gravity north \
          -annotate +0+40 "CANDIDATE NAME" \
          -pointsize 24 \
          -gravity south \
          -annotate +0+40 "#Vote2024 | @candidate" \
          "$TEMPLATES_DIR/instagram_template.png"

        # Facebook Post Template (1200x630)
        ${pkgs.imagemagick}/bin/convert \
          -size 1200x630 xc:"$BRAND_LIGHT" \
          -fill "$BRAND_PRIMARY" \
          -draw "rectangle 0,0 1200,100" \
          -draw "rectangle 0,530 1200,630" \
          -fill white \
          -font Arial-Bold \
          -pointsize 36 \
          -gravity north \
          -annotate +0+30 "CANDIDATE NAME" \
          -pointsize 18 \
          -gravity south \
          -annotate +0+30 "Your message here | #Vote2024" \
          "$TEMPLATES_DIR/facebook_template.png"

        # Twitter Header Template (1500x500)
        ${pkgs.imagemagick}/bin/convert \
          -size 1500x500 \
          -gradient "$BRAND_PRIMARY"-"$BRAND_LIGHT" \
          -fill white \
          -font Arial-Bold \
          -pointsize 72 \
          -gravity center \
          -annotate +0-50 "CANDIDATE NAME" \
          -pointsize 36 \
          -annotate +0+50 "For [OFFICE] | #Vote2024" \
          "$TEMPLATES_DIR/twitter_header_template.png"

        echo "✅ Social media templates created!"
        echo "📁 Templates location: $TEMPLATES_DIR/"
        echo "📱 Available: Instagram, Facebook, Twitter"
      '';
    };
  };

  # Add media workflow scripts to PATH
  home.sessionPath = [
    "$HOME/Projects/Media/Scripts/ffmpeg"
    "$HOME/Projects/Media/Scripts/automation"
  ];
} 