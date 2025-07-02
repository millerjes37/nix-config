{ config, lib, pkgs, ... }:

# To use the Zen MCP server with Gemini API:
# 1. Copy claude-tools-secrets.nix.example to claude-tools-secrets.nix
# 2. Add your GEMINI_API_KEY to the new file
# 3. Import claude-tools-secrets.nix in your home.nix configuration
# 4. Add claude-tools-secrets.nix to .gitignore

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
        npm install -g --prefix "$HOME/.npm-global" @anthropic-ai/claude-code@latest || {
          echo "Failed to install Claude Code CLI"
          echo "Visit https://github.com/anthropics/claude-code for installation instructions"
        }
        
        # Install/update ccusage
        npm install -g --prefix "$HOME/.npm-global" ccusage@latest || {
          echo "Installing ccusage from alternative source..."
          npm install -g --prefix "$HOME/.npm-global" @anthropic/ccusage@latest || {
            echo "Note: ccusage may require manual installation"
            echo "Check https://github.com/anthropics/claude-code for details"
          }
        }
        
        # Install/update Taskmaster AI
        npm install -g --prefix "$HOME/.npm-global" task-master-ai@latest || {
          echo "Failed to install Taskmaster AI"
          echo "Visit https://github.com/eyaltoledano/claude-task-master for installation instructions"
        }
        
        echo "Claude tools update complete!"
        echo "Installed packages:"
        npm list -g --prefix "$HOME/.npm-global" --depth=0 2>/dev/null || true
      '')
      (pkgs.writeShellScriptBin "setup-claude-mcp" ''
        #!/usr/bin/env bash
        set -euo pipefail
        
        echo "Setting up Claude MCP servers..."
        
        # Check if claude CLI is installed
        if ! command -v claude >/dev/null 2>&1; then
          echo "Claude CLI not found. Please run 'update-claude-tools' first."
          exit 1
        fi
        
        # Add MCP servers to Claude CLI configuration
        echo "Adding DeepWiki MCP server..."
        claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp || echo "Failed to add DeepWiki"
        
        echo "Adding Playwright MCP server..."
        claude mcp add -s user playwright "npx @playwright/mcp@latest --headless" || echo "Failed to add Playwright"
        
        echo "Adding Context7 MCP server..."
        claude mcp add -s user context7 "npx context7-mcp@latest" || echo "Failed to add Context7"
        
        echo "Adding Zen MCP server..."
        
        # Check for .env file in nix-config
        if [ -f "$HOME/nix-config/.env" ]; then
          export $(grep -E '^(GROQ_API_KEY|GEMINI_API_KEY|OPENAI_API_KEY)=' "$HOME/nix-config/.env" | xargs)
        fi
        
        # Add Zen if any API key is available
        if [ -n "''${GROQ_API_KEY:-}" ] || [ -n "''${GEMINI_API_KEY:-}" ] || [ -n "''${OPENAI_API_KEY:-}" ]; then
          claude mcp add -s user zen "uvx zen-mcp-server@latest" || echo "Failed to add Zen"
          echo "Zen MCP configured with:"
          [ -n "''${GROQ_API_KEY:-}" ] && echo "  - Groq (DeepSeek R1 Distill 70B)"
          [ -n "''${GEMINI_API_KEY:-}" ] && echo "  - Gemini models"
          [ -n "''${OPENAI_API_KEY:-}" ] && echo "  - OpenAI models"
        else
          # Try to load from file if not in environment
          if [ -f "$HOME/.config/claude/gemini-api-key" ]; then
            export GEMINI_API_KEY=$(cat "$HOME/.config/claude/gemini-api-key")
            claude mcp add -s user zen "uvx zen-mcp-server@latest" || echo "Failed to add Zen"
          else
            echo "Skipping Zen MCP server (no API keys found)"
            echo "To enable Zen MCP, add API keys to ~/nix-config/.env:"
            echo "  GROQ_API_KEY=your-groq-key"
            echo "  GEMINI_API_KEY=your-gemini-key"
            echo "  OPENAI_API_KEY=your-openai-key"
            echo "Then run this script again"
          fi
        fi
        
        echo ""
        echo "MCP servers setup complete!"
        echo "You can verify with: claude mcp list"
        echo ""
        echo "Usage examples:"
        echo "  - Use deepwiki to search for React documentation"
        echo "  - Use playwright to automate browser tasks"
        echo "  - Use context7 to get up-to-date library docs"
        echo "  - Use zen to collaborate with AI models (DeepSeek R1, Gemini, etc.)"
        echo ""
        echo "Zen MCP examples:"
        echo "  - 'Use zen with llama-3.3-70b-versatile for complex analysis'"
        echo "  - 'Ask llama-3.1-8b-instant via zen for quick responses'"
        echo "  - 'Use zen and deepseek to reason through this problem'"
        echo "  - 'Let zen with qwen-qwq-32b explain this algorithm'"
        echo "  - 'Use gemini-2.0-flash-exp for fast code review'"
        echo ""
        echo "Available Groq models (30 free/day):"
        echo "  Production: gemma2-9b-it, llama-3.1-8b-instant, llama-3.3-70b-versatile"
        echo "  Preview: deepseek-r1-distill-llama-70b, mistral-saba-24b, qwen-qwq-32b"
        echo ""
        echo "Available Gemini models (free tier):"
        echo "  gemini-1.5-flash, gemini-2.0-flash-exp, gemma-2-27b-it, gemma-2-9b-it"
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
    
    # UV for running Zen MCP server
    uv                # Fast Python package installer and resolver
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

  # Create Zen custom models configuration
  home.file.".config/zen-mcp/custom-models.json".text = builtins.toJSON {
    models = {
      groq = {
        type = "custom";
        api_url = "https://api.groq.com/openai/v1";
        api_key_env = "GROQ_API_KEY";
        models = [
          {
            id = "deepseek-r1-distill-llama-70b";
            name = "DeepSeek R1 Distill 70B";
            description = "Powerful reasoning model (30 free/day)";
            context_window = 131072;
            max_completion_tokens = 131072;
            category = "preview";
          }
          {
            id = "gemma2-9b-it";
            name = "Gemma 2 9B";
            description = "Google's efficient open model";
            context_window = 8192;
            max_completion_tokens = 8192;
            category = "production";
          }
          {
            id = "llama-3.1-8b-instant";
            name = "Llama 3.1 8B Instant";
            description = "Fast Meta model for quick responses";
            context_window = 131072;
            max_completion_tokens = 131072;
            category = "production";
          }
          {
            id = "llama-3.3-70b-versatile";
            name = "Llama 3.3 70B Versatile";
            description = "Powerful Meta model for complex tasks";
            context_window = 131072;
            max_completion_tokens = 32768;
            category = "production";
          }
          {
            id = "mistral-saba-24b";
            name = "Mistral Saba 24B";
            description = "Mistral's efficient model";
            context_window = 32768;
            max_completion_tokens = 32768;
            category = "preview";
          }
          {
            id = "qwen-qwq-32b";
            name = "Qwen QWQ 32B";
            description = "Alibaba's reasoning model";
            context_window = 131072;
            max_completion_tokens = 131072;
            category = "preview";
          }
        ];
        default_params = {
          temperature = 0.6;
          top_p = 0.95;
          stream = true;
        };
      };
    };
  };

  # Configure MCP servers for Claude Code CLI
  home.file.".claude/mcp_settings.json".text = builtins.toJSON {
    version = "1.0";
    servers = {
      # DeepWiki MCP Server - Free, no auth required
      deepwiki = {
        type = "sse-server";
        url = "https://mcp.deepwiki.com/mcp";
        description = "Access public repository documentation and search capabilities";
      };
      
      # Playwright MCP Server - Browser automation
      playwright = {
        type = "stdio-server";
        command = "npx";
        args = ["@playwright/mcp@latest" "--headless"];
        description = "Browser automation and web scraping capabilities";
      };
      
      # Context7 MCP Server - Up-to-date code documentation
      context7 = {
        type = "stdio-server";
        command = "npx";
        args = ["context7-mcp@latest"];
        description = "Fetch up-to-date, version-specific documentation for libraries";
      };
      
      # Zen MCP Server - Multi-model AI orchestration
      zen = {
        type = "stdio-server";
        command = "uvx";
        args = ["zen-mcp-server@latest"];
        description = "AI model orchestration with Groq, Gemini, OpenAI, and more";
        env = {
          # API Keys - will be loaded from environment or .env file
          GROQ_API_KEY = "\${GROQ_API_KEY:-}";
          GEMINI_API_KEY = "\${GEMINI_API_KEY:-}";
          
          # Configure Groq as custom endpoint
          CUSTOM_API_URL = "https://api.groq.com/openai/v1";
          CUSTOM_API_KEY = "\${GROQ_API_KEY:-}";
          CUSTOM_MODEL_NAME = "llama-3.1-8b-instant";  # Default to fast production model
          
          # Custom models configuration file
          CUSTOM_MODELS_FILE = "$HOME/nix-config/applications/common/development/zen-custom-models.json";
          
          # Default to auto model selection
          DEFAULT_MODEL = "auto";
          
          # Include all available free models (Groq production + preview, Gemini)
          # Groq Production Models
          ALLOWED_MODELS = "gemma2-9b-it,llama-3.1-8b-instant,llama-3.3-70b-versatile," +
                          # Groq Preview Models
                          "deepseek-r1-distill-llama-70b,mistral-saba-24b,qwen-qwq-32b," +
                          # Gemini Models
                          "gemini-1.5-flash,gemini-1.5-flash-8b,gemini-1.5-pro,gemini-2.0-flash-exp," +
                          # Google Gemma Models (via Gemini API)
                          "gemma-2-27b-it,gemma-2-9b-it,gemma-2-2b-it";
          
          # Model parameters for Groq
          CUSTOM_MODEL_TEMPERATURE = "0.6";
          CUSTOM_MODEL_MAX_TOKENS = "4096";
          CUSTOM_MODEL_TOP_P = "0.95";
        };
      };
    };
  };

  # Set up PATH for npm global binaries
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PATH = "$HOME/.npm-global/bin:$PATH";
  };

  # Create the npm global directory and install Claude tools on activation
  home.activation.setupClaudeTools = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Create necessary directories
    mkdir -p "$HOME/.npm-global"
    mkdir -p "$HOME/.claude"
    
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
    
    # Setup MCP servers if Claude CLI is available
    if command -v claude >/dev/null 2>&1 && command -v setup-claude-mcp >/dev/null 2>&1; then
      echo "Configuring Claude MCP servers..."
      setup-claude-mcp || true
    fi
    
    # Check for API keys for Zen MCP
    if [ ! -f "$HOME/nix-config/.env" ] && [ ! -f "$HOME/.config/claude/gemini-api-key" ]; then
      echo ""
      echo "Note: Zen MCP server is configured with Groq (DeepSeek R1) support!"
      echo "The .env file has been created with your Groq API key."
      echo ""
      echo "To add more models to Zen MCP:"
      echo "  - Gemini: Get key from https://makersuite.google.com/app/apikey"
      echo "  - OpenAI: Get key from https://platform.openai.com/api-keys"
      echo "  Then add to ~/nix-config/.env"
      echo ""
    else
      # Load and check which APIs are configured
      if [ -f "$HOME/nix-config/.env" ]; then
        export $(grep -E '^(GROQ_API_KEY|GEMINI_API_KEY|OPENAI_API_KEY)=' "$HOME/nix-config/.env" | xargs) 2>/dev/null || true
        echo ""
        echo "Zen MCP server configured with:"
        [ -n "''${GROQ_API_KEY:-}" ] && echo "  ✓ Groq (6 models: Llama, DeepSeek, Mistral, Qwen) - 30 free requests/day"
        [ -n "''${GEMINI_API_KEY:-}" ] && echo "  ✓ Gemini (7 models: Gemini 1.5/2.0, Gemma 2) - free tier"
        [ -n "''${OPENAI_API_KEY:-}" ] && echo "  ✓ OpenAI models"
        echo ""
      fi
    fi
  '';

  # Shell aliases for Claude tools
  programs.zsh.shellAliases = {
    # Claude Code CLI aliases
    "ccode" = "claude";  # Changed from 'cc' to avoid conflict with cargo check
    "ccu" = "ccusage";
    
    # Claude multiplexer
    "ccm" = "ccmultiplexer";
    
    # Update Claude tools
    "claude-update" = "update-claude-tools";
    
    # Quick commands
    "claude-init" = "claude init";
    "claude-chat" = "claude chat";
    "claude-usage" = "ccusage";
    
    # Taskmaster AI aliases
    "tm" = "task-master";
    "tmi" = "task-master init";
    "tml" = "task-master list";
    "tmn" = "task-master next";
    "tmg" = "task-master generate";
    "tmp" = "task-master parse-prd";
    
    # MCP server management
    "claude-mcp-list" = "claude mcp list";
    "claude-mcp-test" = "claude mcp test";
    "claude-mcp-setup" = "setup-claude-mcp";
    "claude-mcp-info" = "cat ~/.claude/mcp_settings.json | jq .";
    
    # Test individual MCP servers
    "test-deepwiki" = "curl -s https://mcp.deepwiki.com/mcp | head -20";
    "test-zen" = "uvx zen-mcp-server@latest version";
  };

  # Add shell completions if available
  programs.zsh.initContent = ''
    # Source Claude Code completions if available
    if [ -f "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/completions/zsh/_claude-code" ]; then
      fpath=("$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/completions/zsh" $fpath)
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