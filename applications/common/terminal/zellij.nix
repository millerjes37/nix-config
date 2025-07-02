{ config, lib, pkgs, ... }:

let
  # Claude Code Multiplexer Layout
  ccmLayout = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
        
        tab name="CCM Main" focus=true {
            pane split_direction="vertical" {
                pane size="50%" {
                    command "ccm"
                }
                pane split_direction="horizontal" {
                    pane {
                        name "Output"
                    }
                    pane size="30%" {
                        name "Logs"
                    }
                }
            }
        }
        
        tab name="Help" {
            pane {
                command "echo"
                args "Claude Code Multiplexer Help" "" "Commands:" "  ccm - Start Claude Code Multiplexer" "  Ctrl+g - Enter resize mode" "  Ctrl+o - Session manager" "  Ctrl+q - Quit Zellij" "" "Tab Navigation:" "  Alt+[1-9] - Switch to tab" "  Alt+h/l - Previous/Next tab" "" "Inside CCM:" "  Use arrow keys to select instance" "  Enter to connect" "  q to quit"
            }
        }
    }
  '';
  
  # Development Layout with multiple panes
  devLayout = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
        
        tab name="Editor" focus=true {
            pane split_direction="vertical" {
                pane size="70%" {
                    name "Main Editor"
                }
                pane split_direction="horizontal" {
                    pane {
                        name "Terminal"
                    }
                    pane size="40%" {
                        name "File Browser"
                        command "lf"
                    }
                }
            }
        }
        
        tab name="Testing" {
            pane split_direction="horizontal" {
                pane {
                    name "Test Runner"
                }
                pane size="30%" {
                    name "Test Output"
                }
            }
        }
        
        tab name="Git" {
            pane {
                command "lazygit"
            }
        }
        
        tab name="Help" {
            pane {
                command "echo"
                args "Development Layout Help" "" "Pane Navigation:" "  Alt+h/j/k/l - Move between panes" "  Ctrl+g then h/j/k/l - Resize panes" "" "Tab Navigation:" "  Alt+[1-9] - Go to tab number" "  Alt+h/l - Previous/Next tab" "" "Pane Management:" "  Ctrl+p then d - Split down" "  Ctrl+p then r - Split right" "  Ctrl+p then x - Close pane" "  Ctrl+p then f - Toggle fullscreen" "" "Session:" "  Ctrl+o - Session manager" "  Ctrl+q - Quit Zellij"
            }
        }
    }
  '';
  
  # Monitoring Layout
  monitoringLayout = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
        
        tab name="System" focus=true {
            pane split_direction="vertical" {
                pane size="50%" split_direction="horizontal" {
                    pane {
                        command "htop"
                    }
                    pane {
                        command "watch"
                        args "-n" "2" "df -h"
                    }
                }
                pane split_direction="horizontal" {
                    pane {
                        name "Network"
                        command "watch"
                        args "-n" "1" "ss -tunap"
                    }
                    pane {
                        name "Logs"
                        command "journalctl"
                        args "-f"
                    }
                }
            }
        }
        
        tab name="Docker" {
            pane split_direction="horizontal" {
                pane size="70%" {
                    command "lazydocker"
                }
                pane {
                    name "Docker Logs"
                }
            }
        }
        
        tab name="Help" {
            pane {
                command "echo"
                args "Monitoring Layout Help" "" "This layout provides system monitoring tools" "" "System Tab:" "  - htop: Process viewer" "  - df: Disk usage" "  - ss: Network connections" "  - journalctl: System logs" "" "Docker Tab:" "  - lazydocker: Docker TUI" "  - Docker logs pane" "" "Navigation:" "  Alt+[1-9] - Switch to tab" "  Alt+h/l - Previous/Next tab"
            }
        }
    }
  '';
  
  # Simple Layout
  simpleLayout = ''
    layout {
        default_tab_template {
            pane size=1 borderless=true {
                plugin location="zellij:tab-bar"
            }
            children
            pane size=2 borderless=true {
                plugin location="zellij:status-bar"
            }
        }
        
        tab name="Main" focus=true {
            pane
        }
        
        tab name="Help" {
            pane {
                command "echo"
                args "Zellij Help" "" "Basic Commands:" "  Ctrl+q - Quit" "  Ctrl+o - Session manager" "  Alt+[1-9] - Switch to tab" "  Alt+h/l - Previous/Next tab" "" "Layouts:" "  zjccm - Claude Code Multiplexer" "  zjdev - Development layout" "  zjmon - System monitoring" "  zj - Simple layout (default)"
            }
        }
    }
  '';
in
{
  programs.zellij = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
    
    settings = {
      # Theme
      theme = "dracula";
      
      # UI Configuration
      pane_frames = true;
      
      # Mouse support
      mouse_mode = true;
      
      # Copy to system clipboard
      copy_clipboard = "system";
      
      # Simplified UI
      simplified_ui = false;
      
      # Default shell
      default_shell = "bash";
      
      # Session management
      session_serialization = true;
    };
  };
  
  # Create layout files
  home.file = {
    ".config/zellij/layouts/ccm.kdl".text = ccmLayout;
    ".config/zellij/layouts/dev.kdl".text = devLayout;
    ".config/zellij/layouts/monitor.kdl".text = monitoringLayout;
    ".config/zellij/layouts/simple.kdl".text = simpleLayout;
  };
  
  # Shell aliases for quick access
  home.shellAliases = {
    # Quick layout access
    "zj" = "zellij";
    "zjccm" = "zellij -l ccm";
    "zjdev" = "zellij -l dev";
    "zjmon" = "zellij -l monitor";
    
    # Session management
    "zjls" = "zellij list-sessions";
    "zja" = "zellij attach";
    "zjk" = "zellij kill-session";
    "zjka" = "zellij kill-all-sessions";
  };
  
  # Install required packages for layouts
  home.packages = with pkgs; [
    lazygit
    lazydocker
    htop
    lf  # Terminal file manager
  ];
}