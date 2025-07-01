{ config, lib, pkgs, ... }:

let
  # Create a custom Node.js environment with Claude tools
  nodeWithClaudeTools = pkgs.buildEnv {
    name = "nodejs-with-claude-tools";
    paths = [
      pkgs.nodejs_22  # Use latest stable Node.js
      (pkgs.writeShellScriptBin "ccmultiplexer" ''
        #!/usr/bin/env bash
        # Launch multiple Claude Code instances in Zellij tabs
        
        # Create a temporary layout file with the current directory
        CURRENT_DIR=$(pwd)
        LAYOUT_FILE=$(mktemp)
        LAYOUT_FILE="''${LAYOUT_FILE}.kdl"
        
        cat > "$LAYOUT_FILE" << 'EOL'
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
            
            tab name="ccusage" focus=true {
                pane cwd="''${CURRENT_DIR}" {
                    command "npx"
                    args "ccusage@latest" "blocks" "--live"
                }
            }
            
            tab name="claude-code-1" {
                pane split_direction="vertical" {
                    pane split_direction="horizontal" {
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                    }
                    pane split_direction="horizontal" {
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                    }
                }
            }
            
            tab name="claude-code-2" {
                pane split_direction="vertical" {
                    pane split_direction="horizontal" {
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                    }
                    pane split_direction="horizontal" {
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                    }
                }
            }
            
            tab name="claude-code-3" {
                pane split_direction="vertical" {
                    pane split_direction="horizontal" {
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                    }
                    pane split_direction="horizontal" {
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                        pane cwd="''${CURRENT_DIR}" {
                            command "claude"
                            args "--dangerously-skip-permissions"
                        }
                    }
                }
            }
        }
        EOL
        
        # Replace the CURRENT_DIR placeholder with actual directory
        sed -i "s|''${CURRENT_DIR}|$CURRENT_DIR|g" "$LAYOUT_FILE"
        
        # Launch zellij with the layout
        ${pkgs.zellij}/bin/zellij --layout "$LAYOUT_FILE"
        
        # Clean up
        rm "$LAYOUT_FILE"
      '')
      (pkgs.writeShellScriptBin "update-claude-tools" ''
        #!/usr/bin/env bash
        set -euo pipefail
        
        echo "Updating Claude Code CLI tools..."
        
        # Create npm prefix directory if it doesn't exist
        mkdir -p "$HOME/.npm-global"
        
        # Install/update Claude Code CLI
        npm install -g --prefix "$HOME/.npm-global" claude-code@latest || {
          echo "Note: Claude Code CLI package may not be publicly available yet"
          echo "Visit https://claude.ai/code for installation instructions"
        }
        
        # Install/update ccusage
        npm install -g --prefix "$HOME/.npm-global" ccusage@latest || {
          echo "Installing ccusage from alternative source..."
          npm install -g --prefix "$HOME/.npm-global" @anthropic/ccusage@latest || {
            echo "Note: ccusage may require manual installation"
            echo "Check https://github.com/anthropics/claude-code for details"
          }
        }
        
        echo "Claude tools update complete!"
        echo "Installed packages:"
        npm list -g --prefix "$HOME/.npm-global" --depth=0 2>/dev/null || true
      '')
    ];
  };
in
{
  # Install Node.js with Claude tools
  home.packages = with pkgs; [
    nodeWithClaudeTools
    
    # Additional tools that work well with Claude Code
    jq                # JSON processor for API responses
    httpie            # User-friendly HTTP client for API testing
    websocat          # WebSocket client for real-time features
    zellij            # Terminal multiplexer for ccmultiplexer
  ];

  # Configure npm to use a global directory in user's home
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
    registry=https://registry.npmjs.org/
    
    # Performance settings
    progress=false
    loglevel=warn
    
    # Security settings
    audit-level=moderate
    fund=false
    
    # Update checking
    update-notifier=false
  '';

  # Set up PATH for npm global binaries
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PATH = "$HOME/.npm-global/bin:$PATH";
  };

  # Create the npm global directory and install Claude tools on activation
  home.activation.setupClaudeTools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create npm global directory
    mkdir -p "$HOME/.npm-global"
    
    # Create package.json for global npm packages if it doesn't exist
    if [ ! -f "$HOME/.npm-global/package.json" ]; then
      cat > "$HOME/.npm-global/package.json" << 'EOF'
    {
      "name": "claude-tools-global",
      "version": "1.0.0",
      "description": "Global npm packages for Claude Code CLI tools",
      "private": true,
      "dependencies": {}
    }
    EOF
    fi
    
    # Run the update script to install/update Claude tools
    if command -v update-claude-tools >/dev/null 2>&1; then
      echo "Setting up Claude Code CLI tools..."
      update-claude-tools || true
    fi
  '';

  # Shell aliases for Claude tools
  programs.zsh.shellAliases = {
    # Claude Code CLI aliases
    "claude" = "claude-code";
    "ccode" = "claude-code";  # Changed from 'cc' to avoid conflict with cargo check
    "ccu" = "ccusage";
    
    # Claude multiplexer
    "ccm" = "ccmultiplexer";
    
    # Update Claude tools
    "claude-update" = "update-claude-tools";
    
    # Quick commands
    "claude-init" = "claude-code init";
    "claude-chat" = "claude-code chat";
    "claude-usage" = "ccusage";
  };

  # Add shell completions if available
  programs.zsh.initContent = ''
    # Source Claude Code completions if available
    if [ -f "$HOME/.npm-global/lib/node_modules/claude-code/completions/zsh/_claude-code" ]; then
      fpath=("$HOME/.npm-global/lib/node_modules/claude-code/completions/zsh" $fpath)
    fi
    
    # Source ccusage completions if available
    if [ -f "$HOME/.npm-global/lib/node_modules/ccusage/completions/zsh/_ccusage" ]; then
      fpath=("$HOME/.npm-global/lib/node_modules/ccusage/completions/zsh" $fpath)
    fi
  '';

  # Create a systemd service (Linux) or launchd agent (macOS) to check for updates
  systemd.user.services.claude-tools-updater = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Update Claude Code CLI tools";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${nodeWithClaudeTools}/bin/update-claude-tools";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };

  systemd.user.timers.claude-tools-updater = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "Update Claude Code CLI tools weekly";
    };
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # macOS launchd configuration for auto-updates
  launchd.agents.claude-tools-updater = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [ "${nodeWithClaudeTools}/bin/update-claude-tools" ];
      StartCalendarInterval = [
        {
          # Run weekly on Sundays at 2 AM
          Weekday = 0;
          Hour = 2;
          Minute = 0;
        }
      ];
      StandardOutPath = "/tmp/claude-tools-updater.log";
      StandardErrorPath = "/tmp/claude-tools-updater.error.log";
    };
  };
}