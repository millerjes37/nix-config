# applications/common/fonts.nix
# This module defines a collection of fonts to be installed via Home Manager.
# It includes fonts suitable for programming, typesetting, and icon packs.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- Programming Fonts ---
    # Monospaced fonts ideal for code editors, terminals, and development.
    # Many of these include "Nerd Font" variants which add extra glyphs/icons.

    meslo-lg            # Meslo LGS Nerd Font (great for terminals with icons)
    fira-code           # Monospaced font with programming ligatures
    fira-code-symbols   # Extra glyphs for FiraCode
    nerd-fonts.fira-code  # Fira Code with Nerd Font icons
    nerd-fonts.jetbrains-mono # JetBrains Mono Nerd Font
    nerd-fonts.iosevka    # Iosevka Nerd Font
    jetbrains-mono      # Free and open source typeface for developers
    source-code-pro     # Adobe's monospaced font family
    hack-font           # A typeface designed for source code
    iosevka             # Slender, configurable monospaced font family (this is a common variant)
                        # For more specific Iosevka variants, you might explore `iosevka-bin` or other specific packages.
    victor-mono         # Monospaced font with cursive italics and ligatures

    # --- Typesetting Fonts ---
    # Serif, Sans-serif, and other fonts suitable for documents, UI, and general reading.

    libertine-g         # Linux Libertine and Biolinum fonts (requested)
    libertinus          # An extended version of Linux Libertine & Biolinum, offering more glyphs and features.
    eb-garamond         # EB Garamond font family (Garamond variant) (added)
    garamond-libre      # Garamond Libre font family
    liberation_ttf      # Liberation fonts (metric equivalents of Times, Arial, Courier - includes Times New Roman alternative) (re-enabled)
    inter               # A typeface specially designed for user interfaces
    roboto              # Google's signature font family (sans-serif)
    roboto-slab         # Slab serif companion to Roboto
    noto-fonts          # Google Noto Fonts (aims to support all languages with a harmonious look and feel)
    noto-fonts-cjk-sans # Noto fonts for Chinese, Japanese, and Korean
    noto-fonts-emoji    # Noto emoji font
    lato                # A sanserif typeface family
    cantarell-fonts     # Default font for GNOME (modern sans-serif)
    dejavu_fonts        # Font family based on Bitstream Vera, good Unicode coverage
    freefont_ttf        # GNU FreeFont (Serif, Sans, Mono - includes Times New Roman alternative)

    # --- Icon Fonts ---
    # Fonts that primarily provide icons and symbols.

    font-awesome        # The iconic SVG, font, and CSS toolkit
    material-design-icons # Official icon set from Google Material Design
               # A meta-package that installs a collection of popular Nerd Fonts.
                        # This is a large package. If you only need specific Nerd Fonts (like MesloLGS NF already listed),
                        # you might prefer to list them individually to save space.
                        # Consider commenting this out if `meslo-lgs-nf` and `fira-code-nerdfont` are sufficient.
    nerd-fonts.meslo-lg


    # --- Other Useful Font Packages ---
    # (Optional, uncomment if needed)
    # mplus-outline-fonts # Japanese font family
    # ubuntu_font_family  # Ubuntu's default font
  ];

  # Optional: Fontconfig settings for better font rendering (especially on Linux)
  # On macOS, font rendering is generally good out-of-the-box.
  # These settings might be more relevant if you are also using this on Linux.
  fonts.fontconfig.enable = true; # Default is usually true with home-manager

  # Example of enabling specific fontconfig settings (uncomment and adjust as needed):
  # fonts.fontconfig.defaultFonts = {
  #   serif = [ "EB Garamond" "Linux Libertine O" "Liberation Serif" "Noto Serif" "DejaVu Serif" ];
  #   sansSerif = [ "Inter" "Roboto" "Noto Sans" "DejaVu Sans" ];
  #   monospace = [ "MesloLGS NF" "Fira Code" "JetBrains Mono" "Source Code Pro" ];
  #   emoji = [ "Noto Color Emoji" ];
  # };

  # To improve rendering, especially for CJK or specific styles:
  # fonts.fontconfig.ultimate.enable = true; # Provides a curated set of fontconfig rules
  # fonts.fontconfig.subpixel.rgba = "rgb"; # Example: "rgb", "bgr", "vrgb", "vbgr", "none"
  # fonts.fontconfig.subpixel.lcdfilter = "lcddefault"; # Example: "lcddefault", "lcdlight", "lcdlegacy"

  # If you use specific Nerd Fonts and want to ensure they are preferred for icons:
  # (This is an advanced example, usually Nerd Fonts work well by default if installed)
  # fonts.fontconfig.confFiles = [
  #   (pkgs.writeText "50-nerd-fonts.conf" ''
  #     <?xml version="1.0"?>
  #     <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #     <fontconfig>
  #       <alias>
  #         <family>sans-serif</family>
  #         <prefer><family>MesloLGS NF</family></prefer>
  #       </alias>
  #       <alias>
  #         <family>serif</family>
  #         <prefer><family>MesloLGS NF</family></prefer>
  #       </alias>
  #       <alias>
  #         <family>monospace</family>
  #         <prefer><family>MesloLGS NF</family></prefer>
  #       </alias>
  #     </fontconfig>
  #   '')
  # ];
}
