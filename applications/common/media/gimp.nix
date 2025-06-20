{ config, lib, pkgs, ... }:

{
  # GIMP Configuration for Political Communications
  # Professional image editing with consistent branding tools

  home.packages = with pkgs; [
    gimp                        # Primary image editor
    gimpPlugins.gmic           # G'MIC plugin for advanced effects
    gimpPlugins.resynthesizer  # Content-aware fill and healing
  ];

  # GIMP configuration and templates
  home.file = {
    # Custom GIMP brushes for political graphics
    ".config/GIMP/2.10/brushes/campaign-brush.gbr".source = pkgs.writeText "campaign-brush.gbr" ''
      GIMP Brush File
      # Campaign graphics brush
    '';

    # GIMP color palettes for brand consistency
    ".config/GIMP/2.10/palettes/campaign-brand.gpl".text = ''
      GIMP Palette
      Name: Campaign Brand Colors
      Columns: 6
      #
      30 58 138    Primary Blue
      220 38 38    Secondary Red  
      251 191 36   Accent Gold
      107 114 128  Neutral Gray
      249 250 251  Light Gray
      17 24 39     Dark Gray
      255 255 255  White
      0 0 0        Black
    '';

    # Social media templates as XCF files would go here
    # Note: These would be actual GIMP XCF files with layers
    "Projects/Media/Templates/instagram-post.xcf.info".text = ''
      Instagram Post Template (1080x1080)
      Layers:
      - Background (brand colors)
      - Logo placeholder
      - Text overlay
      - Campaign hashtags
    '';

    "Projects/Media/Templates/facebook-cover.xcf.info".text = ''
      Facebook Cover Template (1200x630)  
      Layers:
      - Background gradient
      - Candidate photo placeholder
      - Name text
      - Slogan text
      - Contact info
    '';

    # GIMP Script-Fu scripts for automation
    ".config/GIMP/2.10/scripts/campaign-watermark.scm".text = ''
      ; Campaign Watermark Script for GIMP
      ; Adds consistent branding to images
      
      (define (script-fu-campaign-watermark image drawable candidate-name)
        (let* ((text-layer (car (gimp-text-fontname image -1 10 10 candidate-name 0 TRUE 24 PIXELS "Arial Bold"))))
          ; Position text in bottom right
          (gimp-layer-set-offsets text-layer 
                                  (- (car (gimp-drawable-width drawable)) 200)
                                  (- (car (gimp-drawable-height drawable)) 50))
          ; Set text color to brand blue
          (gimp-context-set-foreground '(30 58 138))
          (gimp-text-layer-set-color text-layer '(30 58 138))
          ; Add drop shadow
          (plug-in-drop-shadow RUN-NONINTERACTIVE image text-layer 2 2 8 '(0 0 0) 80 FALSE)
          (gimp-displays-flush)))
      
      (script-fu-register "script-fu-campaign-watermark"
                          "Campaign Watermark"
                          "Add campaign branding to image"
                          "Media Workflow"
                          "GPL"
                          "2024"
                          "RGB*"
                          SF-IMAGE "Image" 0
                          SF-DRAWABLE "Drawable" 0
                          SF-STRING "Candidate Name" "Candidate")
      
      (script-fu-menu-register "script-fu-campaign-watermark" "<Image>/Tools")
    '';

    # GIMP keyboard shortcuts for media workflows
    ".config/GIMP/2.10/menurc".text = ''
      ; Custom keyboard shortcuts for political media workflows
      (gtk_accel_path "<Actions>/tools/tools-transform-tool" "t")
      (gtk_accel_path "<Actions>/tools/tools-text-tool" "t")
      (gtk_accel_path "<Actions>/tools/tools-crop-tool" "c")
      (gtk_accel_path "<Actions>/tools/tools-scale-tool" "s")
      (gtk_accel_path "<Actions>/select/select-none" "<Primary>d")
      (gtk_accel_path "<Actions>/tools/tools-clone-tool" "c")
      (gtk_accel_path "<Actions>/tools/tools-healing-tool" "h")
      ; Quick export shortcuts
      (gtk_accel_path "<Actions>/file/file-export-as" "<Primary><Shift>e")
      (gtk_accel_path "<Actions>/file/file-export" "<Primary>e")
    '';
  };

  # Environment variables for GIMP
  home.sessionVariables = {
    GIMP2_DIRECTORY = "$HOME/.config/GIMP/2.10";
    GIMP_PLUGIN_DIRS = "$HOME/.config/GIMP/2.10/plug-ins";
  };
} 