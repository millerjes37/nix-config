{ config, lib, pkgs, ... }:

{
  # Configure Rofi - application launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = "gruvbox-dark";
    font = "FiraMono Nerd Font Mono 12";
    extraConfig = {
      modi = "drun,run,window,ssh";
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      disable-history = false;
      sort = true;
      sorting-method = "fzf";
      case-sensitive = false;
      cycle = true;
      sidebar-mode = true;
      eh = 1;
      auto-select = false;
      combi-modi = "window,drun,run";
      matching = "fuzzy";
      dpi = 0;
      threads = 0;
    };
  };
  
  # Additional Rofi theme configuration
  home.file.".config/rofi/gruvbox-custom.rasi".text = ''
    /* Enhanced Gruvbox theme - Riced version */
    * {
      bg0: #1d2021;          /* Darker background */
      bg1: #3c3836;
      bg2: #504945;
      bg3: #665c54;
      bg4: #7c6f64;
      fg0: #fbf1c7;
      fg1: #ebdbb2;
      fg2: #d5c4a1;
      red: #fb4934;
      green: #b8bb26;
      yellow: #fabd2f;
      blue: #83a598;
      purple: #d3869b;
      aqua: #8ec07c;
      gray: #928374;
      orange: #fe8019;
      
      /* Enhanced colors for more visual appeal */
      accent: #689d6a;       /* Custom accent color */
      highlight: #458588;    /* Highlight color */
      urgent: #cc241d;       /* Urgent color */
      
      background-color: transparent;
      text-color: @fg1;
      
      margin: 0;
      padding: 0;
      spacing: 0;
    }
    
    window {
      background-color: @bg0;
      border: 2px;
      border-color: @accent;
      border-radius: 15px;
      padding: 25px;
      width: 45%;
      height: 55%;
      /* Add subtle shadow effect */
      box-shadow: 0px 0px 20px rgba(0,0,0,0.8);
      location: center;
      anchor: center;
    }
    
    mainbox {
      border: 0;
      border-color: @bg1;
      padding: 0;
    }
    
    inputbar {
      children: [prompt,entry];
      background-color: @bg1;
      border-radius: 8px;
      padding: 10px;
      margin: 0px 0px 20px 0px;
    }
    
    prompt {
      background-color: @accent;
      text-color: @bg0;
      padding: 8px 12px;
      border-radius: 8px;
      margin: 0px 15px 0px 0px;
      font: "FiraMono Nerd Font Bold 13";
      str: "🚀";
    }
    
    entry {
      placeholder: "Search...";
      placeholder-color: @gray;
      padding: 5px;
    }
    
    listview {
      border: 0px;
      padding: 0;
      margin: 0;
      columns: 1;
      lines: 10;
      scrollbar: true;
    }
    
    scrollbar {
      width: 4px;
      border: 0;
      handle-width: 8px;
      handle-color: @bg3;
      background-color: @bg1;
      padding: 0px 5px;
    }
    
    element {
      border-radius: 5px;
      padding: 10px;
      margin: 2px 0px;
    }
    
    element normal.normal, element alternate.normal {
      background-color: @bg0;
      text-color: @fg1;
    }
    
    element normal.urgent, element alternate.urgent {
      background-color: @red;
      text-color: @bg0;
    }
    
    element normal.active, element alternate.active {
      background-color: @aqua;
      text-color: @bg0;
    }
    
    element selected.normal {
      background-color: @highlight;
      text-color: @fg0;
      border: 0px 0px 0px 4px;
      border-color: @accent;
      border-radius: 8px;
    }
    
    element selected.urgent {
      background-color: @orange;
      text-color: @bg0;
    }
    
    element selected.active {
      background-color: @aqua;
      text-color: @bg0;
    }
    
    element-icon {
      background-color: transparent;
      size: 24px;
      margin: 0px 10px 0px 0px;
    }
    
    element-text {
      background-color: transparent;
      text-color: inherit;
      highlight: bold;
    }
    
    mode-switcher {
      background-color: @bg1;
      padding: 5px;
      border-radius: 5px;
      margin: 20px 0px 0px 0px;
    }
    
    button {
      padding: 5px;
      background-color: @bg1;
      text-color: @gray;
      border-radius: 5px;
      margin: 0px 5px;
    }
    
    button selected {
      background-color: @bg2;
      text-color: @fg1;
    }
  '';
}