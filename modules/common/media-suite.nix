{ config, lib, pkgs, ... }:

{
  # Professional Media Editing Suite for Political Communications
  # Complete workflow tools for social media, video production, and digital campaigns

  home.packages = with pkgs; [
    # === VIDEO EDITING SUITE ===
    kdePackages.kdenlive        # Primary video editor - professional, open source
    davinci-resolve            # Professional color grading and video editing
    ffmpeg                      # Video processing and conversion engine
    ffmpeg-full                 # Full FFmpeg with all codecs
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
    jpegoptim                   # JPEG optimization
    optipng                     # PNG optimization
    libwebp                     # WebP conversion tools
    
    # === SPECIALIZED POLITICAL COMMUNICATION TOOLS ===
    qrencode                    # QR code generation
    zbar                        # QR code reading
    tesseract                   # OCR for text extraction from images
    
    # === FILE MANAGEMENT ===
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

  # XDG file associations for media files
  xdg.mimeApps.defaultApplications = lib.mkIf pkgs.stdenv.isLinux {
    # Video files -> Kdenlive for editing, VLC for viewing
    "video/mp4" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
    "video/avi" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
    "video/mkv" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
    "video/mov" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
    "video/webm" = ["org.kde.kdenlive.desktop" "vlc.desktop"];
    
    # Audio files -> Audacity for editing
    "audio/wav" = ["audacity.desktop"];
    "audio/mp3" = ["audacity.desktop" "vlc.desktop"];
    "audio/ogg" = ["audacity.desktop" "vlc.desktop"];
    "audio/flac" = ["audacity.desktop" "vlc.desktop"];
    
    # Image files -> GIMP for editing
    "image/png" = ["gimp.desktop" "org.gnome.eog.desktop"];
    "image/jpeg" = ["gimp.desktop" "org.gnome.eog.desktop"];
    "image/jpg" = ["gimp.desktop" "org.gnome.eog.desktop"];
    "image/gif" = ["gimp.desktop" "org.gnome.eog.desktop"];
    "image/bmp" = ["gimp.desktop" "org.gnome.eog.desktop"];
    "image/tiff" = ["gimp.desktop" "org.gnome.eog.desktop"];
    "image/webp" = ["gimp.desktop" "org.gnome.eog.desktop"];
    
    # Vector graphics -> Inkscape
    "image/svg+xml" = ["org.inkscape.Inkscape.desktop"];
    
    # RAW files -> Darktable
    "image/x-canon-cr2" = ["darktable.desktop"];
    "image/x-canon-crw" = ["darktable.desktop"];
    "image/x-nikon-nef" = ["darktable.desktop"];
    "image/x-sony-arw" = ["darktable.desktop"];
    "image/x-adobe-dng" = ["darktable.desktop"];
  };

  # Environment variables for media applications
  home.sessionVariables = {
    # FFmpeg optimizations
    FFMPEG_DATADIR = "${pkgs.ffmpeg}/share/ffmpeg";
    
    # GIMP configuration
    GIMP2_DIRECTORY = "$HOME/.config/GIMP/2.10";
    
    # Blender configuration
    BLENDER_USER_CONFIG = "$HOME/.config/blender";
    BLENDER_USER_SCRIPTS = "$HOME/.config/blender/scripts";
    
    # Default media directories
    MEDIA_PROJECTS = "$HOME/Projects/Media";
    MEDIA_ASSETS = "$HOME/Projects/Media/Assets";
    MEDIA_EXPORT = "$HOME/Projects/Media/Export";
  };
} 