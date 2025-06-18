{ config, pkgs, lib, ... }:

{
  # System-level Hyprland configuration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Desktop Portal configuration for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Required system packages for Hyprland ecosystem
  environment.systemPackages = with pkgs; [
    # Core Wayland/Hyprland tools
    waybar                    # Status bar
    hyprpaper                 # Wallpaper daemon
    hyprlock                  # Screen locker
    hypridle                  # Idle daemon
    hyprpicker                # Color picker
    hyprshot                  # Screenshot tool
    
    # Terminal emulators
    alacritty                 # GPU-accelerated terminal
    kitty                     # Feature-rich terminal
    foot                      # Lightweight Wayland terminal
    
    # Application launchers
    rofi-wayland             # Application launcher
    wofi                     # Wayland application launcher
    fuzzel                   # Lightweight app launcher
    
    # Notification daemon
    dunst                    # Notification daemon
    libnotify                # Notification library
    
    # File managers
    thunar                   # GTK file manager
    nemo                     # Cinnamon file manager
    ranger                   # Terminal file manager
    
    # Audio/Video
    pavucontrol              # PulseAudio volume control
    playerctl                # Media player control
    
    # Screenshots and recording
    grim                     # Screenshot utility
    slurp                    # Screen area selection
    wl-clipboard             # Clipboard utilities
    
    # System monitoring
    btop                     # System monitor
    htop                     # Process viewer
    
    # Network
    networkmanagerapplet     # Network manager GUI
    
    # Image viewers
    imv                      # Wayland image viewer
    
    # PDF readers
    zathura                  # Lightweight PDF reader
    
    # Text editors
    neovim                   # Text editor
    
    # Web browsers
    firefox                  # Web browser
    
    # Theming
    gtk3                     # GTK3 theming
    gtk4                     # GTK4 theming
    adwaita-icon-theme       # Icon theme
    
    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka" ]; })
    font-awesome
    
    # Development tools
    git
    gh                       # GitHub CLI
    vscode                   # Code editor
    
    # Media
    mpv                      # Video player
    
    # Archive tools
    unzip
    p7zip
    
    # System utilities
    polkit_gnome             # Authentication agent
    gnome.gnome-keyring      # Keyring
    
    # Bluetooth
    bluez
    bluez-tools
    blueman
  ];

  # Enable essential services
  services = {
    # Display manager
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
          user = "greeter";
        };
      };
    };
    
    # Audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    # Bluetooth
    blueman.enable = true;
    
    # Network
    networkmanager.enable = true;
    
    # Printing
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    
    # Polkit
    polkit.enable = true;
    
    # GNOME Keyring
    gnome.gnome-keyring.enable = true;
    
    # Flatpak support
    flatpak.enable = true;
    
    # Thumbnails
    tumbler.enable = true;
  };

  # Security and authentication
  security = {
    pam.services.hyprlock = {};
    polkit.enable = true;
    rtkit.enable = true;
  };

  # Hardware configuration
  hardware = {
    # Graphics
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    
    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    
    # PulseAudio (disabled in favor of PipeWire)
    pulseaudio.enable = false;
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka" ]; })
    ];
  };

  # Environment variables
  environment.sessionVariables = {
    # Wayland
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    
    # NVIDIA specific (uncomment if using NVIDIA)
    # LIBVA_DRIVER_NAME = "nvidia";
    # XDG_SESSION_TYPE = "wayland";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # Programs
  programs = {
    # Hyprland
    hyprland.enable = true;
    
    # Thunar file manager
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
    
    # Dconf (for GTK applications)
    dconf.enable = true;
    
    # Steam (gaming)
    steam.enable = true;
    
    # Firefox
    firefox.enable = true;
    
    # Git
    git.enable = true;
    
    # ZSH
    zsh.enable = true;
  };

  # Home Manager integration (this will be imported by the user's home.nix)
  home-manager.users.jackson = { pkgs, ... }: {
    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Variables
        "$terminal" = "alacritty";
        "$fileManager" = "thunar";
        "$menu" = "rofi -show drun";
        "$mainMod" = "SUPER";

        # Monitors
        monitor = [
          ",preferred,auto,auto"
        ];

        # Autostart
        exec-once = [
          "waybar"
          "hyprpaper"
          "hypridle"
          "dunst"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "nm-applet"
          "blueman-applet"
        ];

        # Environment variables
        env = [
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt6ct"
        ];

        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = false;
          };
          sensitivity = 0;
        };

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          allow_tearing = false;
        };

        # Decoration
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
        };

        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Dwindle layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Master layout
        master = {
          new_is_master = true;
        };

        # Gestures
        gestures = {
          workspace_swipe = false;
        };

        # Miscellaneous
        misc = {
          force_default_wallpaper = -1;
        };

        # Key bindings
        bind = [
          # Main bindings
          "$mainMod, Return, exec, $terminal"
          "$mainMod, Q, killactive"
          "$mainMod, M, exit"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating"
          "$mainMod, Space, exec, $menu"
          "$mainMod, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, F, fullscreen"
          "$mainMod, L, exec, hyprlock"

          # Move focus
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Switch workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"

          # Move active window to workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          # Scroll through existing workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Screenshot bindings
          ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mainMod, Print, exec, grim ~/Pictures/Screenshots/$(date +'%s_grim.png')"

          # Media keys
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        # Mouse bindings
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];

        # Window rules
        windowrulev2 = [
          "suppressevent maximize, class:.*"
          "opacity 0.9 0.9,class:^(Alacritty)$"
          "opacity 0.9 0.9,class:^(kitty)$"
          "float,class:^(pavucontrol)$"
          "float,class:^(blueman-manager)$"
          "float,class:^(nm-connection-editor)$"
          "float,class:^(org.gnome.FileRoller)$"
          "float,title:^(Media viewer)$"
          "float,title:^(Volume Control)$"
          "float,title:^(Picture-in-Picture)$"
          "pin,title:^(Picture-in-Picture)$"
        ];
      };
    };

    # Waybar configuration
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 32;
          spacing = 4;
          modules-left = [ "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "tray" "pulseaudio" "network" "cpu" "memory" "battery" ];

          "hyprland/workspaces" = {
            format = "{name}: {icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "6" = "";
              "7" = "";
              "8" = "";
              "9" = "";
              "10" = "";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
            persistent-workspaces = {
              "*" = 5;
            };
          };

          "hyprland/window" = {
            format = "{}";
            separate-outputs = true;
          };

          "clock" = {
            timezone = "America/New_York";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%Y-%m-%d}";
          };

          "cpu" = {
            format = "{usage}% ";
            tooltip = false;
          };

          "memory" = {
            format = "{}% ";
          };

          "network" = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "{ipaddr}/{cidr} ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-disconnected = "Disconnected ⚠";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          "pulseaudio" = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = ["" "" "" "" ""];
          };

          "tray" = {
            icon-size = 21;
            spacing = 10;
          };
        };
      };
      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(43, 48, 59, 0.9);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
          border-bottom: 3px solid transparent;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.active {
          background-color: #64727D;
          border-bottom: 3px solid #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #network,
        #pulseaudio,
        #tray {
          padding: 0 10px;
          margin: 0 4px;
          color: #ffffff;
        }

        #window {
          margin: 0 4px;
        }

        #battery.charging, #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
        }

        #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: #000000;
          }
        }
      '';
    };

    # Terminal configurations
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 0.9;
          padding = {
            x = 10;
            y = 10;
          };
        };
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          size = 12;
        };
        colors = {
          primary = {
            background = "#1e1e2e";
            foreground = "#cdd6f4";
          };
        };
      };
    };

    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 12;
      };
      settings = {
        background_opacity = "0.9";
        window_padding_width = 10;
        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
      };
    };

    # Hyprpaper (wallpaper daemon)
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;
        
        preload = [
          "~/Pictures/Wallpapers/wallpaper.png"
        ];
        
        wallpaper = [
          ",~/Pictures/Wallpapers/wallpaper.png"
        ];
      };
    };

    # Hypridle (idle daemon)
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };
        
        listener = [
          {
            timeout = 300;
            on-timeout = "hyprlock";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };

    # Hyprlock (screen locker)
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          grace = 300;
          hide_cursor = true;
          no_fade_in = false;
        };
        
        background = [
          {
            path = "~/Pictures/Wallpapers/wallpaper.png";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
        
        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };

    # Dunst (notification daemon)
    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = 300;
          offset = "30x50";
          origin = "top-right";
          transparency = 10;
          frame_color = "#eceff1";
          font = "JetBrainsMono Nerd Font 10";
        };
        
        urgency_normal = {
          background = "#37474f";
          foreground = "#eceff1";
          timeout = 10;
        };
      };
    };

    # Rofi (application launcher)
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      theme = "Arc-Dark";
    };

    # GTK theming
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome.gnome-themes-extra;
      };
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
    };

    # Qt theming
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita-dark";
    };

    # Home packages
    home.packages = with pkgs; [
      # Additional Hyprland ecosystem tools
      wlogout                  # Logout menu
      swww                     # Wallpaper daemon alternative
      wlsunset                 # Blue light filter
      
      # Development
      postman                  # API testing
      discord                  # Communication
      slack                    # Communication
      
      # Media
      spotify                  # Music
      vlc                      # Video player
    ];

    # Create wallpaper directory
    home.file."Pictures/Wallpapers/.keep".text = "";
    
    # Create screenshots directory
    home.file."Pictures/Screenshots/.keep".text = "";
  };
}
