{ config, lib, pkgs, ... }:

{
  # Ensure the local bin directory exists
  home.activation.createLocalBin = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/.local/bin
    mkdir -p $HOME/.config/alacritty
  '';

  # Configuration for a quick terminal application
  home.file.".config/alacritty/quick_terminal.yml" = {
    text = ''
      window:
        opacity: 0.75
        padding:
          x: 50
          y: 10
        decorations: none
        dynamic_title: true
        dimensions:
          columns: 100
          lines: 25
      
      font:
        normal:
          family: "FiraCode Nerd Font"
          style: Regular
        size: 20
      
      colors:
        primary:
          background: "#282828"
          foreground: "#ebdbb2"
        normal:
          black: "#282828"
          red: "#cc241d"
          green: "#98971a"
          yellow: "#d79921"
          blue: "#458588"
          magenta: "#b16286"
          cyan: "#689d6a"
          white: "#a89984"
        bright:
          black: "#928374"
          red: "#fb4934"
          green: "#b8bb26"
          yellow: "#fabd2f"
          blue: "#83a598"
          magenta: "#d3869b"
          cyan: "#8ec07c"
          white: "#ebdbb2"
        cursor:
          text: "#282828"
          cursor: "#b8bb26"
        selection:
          text: "#ebdbb2"
          background: "#504945"
    '';
  };
  
  # Create a script to launch the quick terminal
  home.file.".local/bin/quick_terminal" = {
    text = ''
      #!/bin/sh
      ${pkgs.alacritty}/bin/alacritty --config-file ~/.config/alacritty/quick_terminal.yml --title "quick_terminal"
    '';
    executable = true;
  };
}