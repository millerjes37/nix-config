{ config, lib, pkgs, ... }:

{
  # Professional Media Editing Suite for Political Communications
  # Complete workflow tools for social media, video production, and digital campaigns

  home.packages = with pkgs; [
    # === VIDEO EDITING SUITE ===
    kdePackages.kdenlive        # Primary video editor - professional, open source
    ffmpeg-full                 # Full FFmpeg with all codecs (includes everything)
    yt-dlp                      # Video downloads for content research
    mediainfo                   # Media file information
    mkvtoolnix                  # Matroska video tools
    handbrake                   # Video transcoding

    # === IMAGE EDITING SUITE ===
    gimp                        # Primary image editor
    inkscape                    # Vector graphics and logo design
    krita                       # Digital painting and graphics
    darktable                   # RAW photo processing
    rawtherapee                 # Alternative RAW processor
    imagemagick                 # Command-line image processing
    
    # === AUDIO EDITING ===
    audacity                    # Audio editing and podcast production
    ardour                      # Professional DAW
    lmms                        # Music production (for jingles/background)
    sox                         # Audio processing command-line tools
    
    # === 3D/MOTION GRAPHICS ===
    blender                     # 3D modeling, animation, and motion graphics
    
    # === SCREEN RECORDING & STREAMING ===
    obs-studio                  # Screen recording and live streaming
    simplescreenrecorder        # Alternative screen recorder
    peek                        # GIF screen recorder
    
    # === DESIGN & TYPOGRAPHY ===
    scribus                     # Desktop publishing for print materials
    fontforge                   # Font editing and creation
    
    # === WORKFLOW TOOLS ===
    exiftool                    # Metadata management
    
    # === SYSTEM UTILITIES FOR MEDIA ===
    p7zip                       # Compression
    unzip                       # Archives
    rsync                       # File synchronization
    rclone                      # Cloud storage sync
  ];

  # Create organized directory structure for media projects
  home.file = {
    # Main project structure
    "Projects/Media/.keep".text = "";
    "Projects/Media/Video/.keep".text = "";
    "Projects/Media/Audio/.keep".text = "";
    "Projects/Media/Graphics/.keep".text = "";
    "Projects/Media/Templates/.keep".text = "";
    "Projects/Media/Assets/.keep".text = "";
    "Projects/Media/Scripts/.keep".text = "";
    "Projects/Media/Export/.keep".text = "";
    
    # Brand assets directory
    "Projects/Media/Assets/Logos/.keep".text = "";
    "Projects/Media/Assets/Fonts/.keep".text = "";
    "Projects/Media/Assets/Colors/.keep".text = "";
    "Projects/Media/Assets/Photos/.keep".text = "";
    "Projects/Media/Assets/Graphics/.keep".text = "";
    "Projects/Media/Assets/Audio/.keep".text = "";
    
    # Export formats directory
    "Projects/Media/Export/Social/.keep".text = "";
    "Projects/Media/Export/Web/.keep".text = "";
    "Projects/Media/Export/Print/.keep".text = "";
    "Projects/Media/Export/Video/.keep".text = "";
    
    # Workflow scripts directory
    "Projects/Media/Scripts/ffmpeg/.keep".text = "";
    "Projects/Media/Scripts/gimp/.keep".text = "";
    "Projects/Media/Scripts/automation/.keep".text = "";
  };

  # Create media production workspace directories
  home.file.".local/share/media-templates/.keep".text = "";
  
  # TODO: Add actual media workflow templates when available
  # home.file.".local/share/media-workflows" = {
  #   source = ./data/media-workflows;
  #   recursive = true;
  # };

  # Environment variables for media applications
  home.sessionVariables = {
    # Media production directories
    MEDIA_PROJECTS = "$HOME/Projects/Media";
    MEDIA_TEMPLATES = "$HOME/.local/share/media-templates";
    MEDIA_EXPORT = "$HOME/Projects/Media/Export";
  };

  # NOTE: File associations moved to platform-specific modules
  # Linux: modules/linux/default.nix
  # macOS: modules/darwin/default.nix (if needed)
  # This ensures platform-appropriate application associations
} 