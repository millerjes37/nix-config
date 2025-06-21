{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.aerospace;
  defaultConfig = ''
    # AeroSpace Configuration
    # Place this file in ~/.aerospace.toml

    # After AeroSpace is started for the first time, copy the default config to ~/.aerospace.toml
    # https://github.com/nikitabobko/AeroSpace/blob/main/docs/config-examples.md

    # You can use it to add commands that run after login to macOS.
    # 'start-at-login' needs to be 'true' for 'after-login-command' to work
    # Available commands: https://github.com/nikitabobko/AeroSpace/blob/main/docs/commands.md
    start-at-login = true

    # Normalizations. See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/guide.md#normalization
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/config-guide.md#layouts
    # The 'accordion-padding' specifies the size of accordion padding
    # You can set 0 to disable the padding feature
    accordion-padding = 30

    # Possible values: tiles|accordion
    default-root-container-layout = 'tiles'

    # Possible values: horizontal|vertical|auto
    # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
    #               tall monitor (anything higher than wide) gets vertical orientation
    default-root-container-orientation = 'auto'

    # Possible values: (qwerty|dvorak)
    # See https://github.com/nikitabobko/AeroSpace/blob/main/docs/guide.md#key-mapping
    key-mapping.preset = 'qwerty'

    # Gaps between windows (inner-*) and between monitor edges (outer-*)
    # This matches your current yabai configuration
    [gaps]
    inner.horizontal = 10
    inner.vertical =   10
    outer.left =       10
    outer.bottom =     10
    outer.top =        10
    outer.right =      10

    # 'main' binding mode declaration
    # See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/guide.md#binding-modes
    # 'main' binding mode must be always presented
    [mode.main.binding]

    # All possible keys:
    # - Letters.        a, b, c, ..., z
    # - Numbers.        0, 1, 2, ..., 9
    # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
    # - F-keys.         f1, f2, ..., f20
    # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon, backtick,
    #                   leftSquareBracket, rightSquareBracket, space, enter, esc, backspace, tab
    # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
    #                   keypadMinus, keypadMultiply, keypadPlus
    # - Arrows.         left, down, up, right

    # All possible modifiers: cmd, alt, ctrl, shift

    # All possible commands: https://github.com/nikitabobko/AeroSpace/blob/main/docs/commands.md

    # See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/commands.md#exec-and-forget
    # You can uncomment the following lines to open up terminal with alt + enter shortcut (like in i3)
    alt-enter = 'exec-and-forget open -a Alacritty'

    # Window focus (matching your current keybindings)
    alt-left = 'focus left'
    alt-down = 'focus down'
    alt-up = 'focus up'
    alt-right = 'focus right'

    # Alternative hjkl navigation
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move windows (matching your current keybindings)
    alt-shift-left = 'move left'
    alt-shift-down = 'move down'
    alt-shift-up = 'move up'
    alt-shift-right = 'move right'

    # Alternative hjkl movement
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Consider using 'join-with' command as a 'move' replacement if you want to enable normalizations
    # alt-shift-h = 'join-with left'
    # alt-shift-j = 'join-with down'
    # alt-shift-k = 'join-with up'
    # alt-shift-l = 'join-with right'

    # Workspace switching (matching your current keybindings)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'

    # Move windows to workspaces (matching your current keybindings)
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'

    # Window properties (matching your current keybindings)
    alt-f = 'fullscreen'
    alt-t = 'layout floating tiling' # Toggle between floating and tiling

    # Resizing windows
    alt-shift-minus = 'resize smart -50'
    alt-shift-equal = 'resize smart +50'

    # Balance space
    alt-b = 'balance-sizes'

    # Layout operations
    alt-r = 'layout h_accordion' # Similar to rotate functionality
    alt-comma = 'layout h_tiles'
    alt-period = 'layout v_tiles'

    # Application launchers (matching your current keybindings)
    alt-e = 'exec-and-forget open -a Finder'
    alt-w = 'exec-and-forget open -a Safari'
    alt-c = 'exec-and-forget open -a "Visual Studio Code"'

    # Close window
    alt-q = 'close'

    # Reload configuration
    alt-x = 'reload-config'

    # See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/commands.md#mode
    alt-shift-semicolon = 'mode service'

    # 'service' binding mode declaration.
    # See: https://github.com/nikitabobko/AeroSpace/blob/main/docs/guide.md#binding-modes
    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main'] # reset layout
    f = ['layout floating tiling', 'mode main'] # Toggle between floating and tiling layout
    backspace = ['close-all-windows-but-current', 'mode main']

    alt-shift-h = ['join-with left', 'mode main']
    alt-shift-j = ['join-with down', 'mode main']
    alt-shift-k = ['join-with up', 'mode main']
    alt-shift-l = ['join-with right', 'mode main']

    # Window rules
    [[on-window-detected]]
    if.app-id = 'com.apple.systempreferences'
    run = ['layout floating']

    [[on-window-detected]]
    if.app-id = 'com.apple.finder'
    run = ['layout floating']

    [[on-window-detected]]
    if.app-id = 'com.apple.ActivityMonitor'
    run = ['layout floating']
  '';
in

{
  options.programs.aerospace = {
    enable = mkEnableOption "aerospace tiling window manager";
    config = mkOption {
      type = types.lines;
      default = defaultConfig;
      description = "Contents of the aerospace configuration file.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.aerospace ];

    home.file.".aerospace.toml" = {
      text = cfg.config;
    };
  };
} 