# Universal Theming with nix-colors

This configuration uses [nix-colors](https://github.com/misterio77/nix-colors) for universal theming across all applications. This provides consistent color schemes based on the [base16](https://github.com/chriskempson/base16) standard.

## Overview

nix-colors provides:
- 220+ pre-built color schemes
- Universal theming across applications
- Base16 standard compliance
- Easy scheme switching
- Custom scheme creation

## Current Setup

The theming is configured in `modules/common/theming.nix` and automatically applied to:
- **Alacritty** - Terminal emulator colors
- **Zsh** - Environment variables and prompt colors
- **Bat** - Syntax highlighting theme
- All other applications can be themed using the same color palette

## Default Color Scheme

The configuration defaults to `gruvbox-dark-hard`, which provides a warm, comfortable dark theme that's easy on the eyes.

## Available Color Schemes

Here are some popular schemes you can switch to:

### Dark Themes
- `gruvbox-dark-hard` - Current default, warm and comfortable
- `dracula` - Popular purple-based theme
- `tokyo-night` - Modern dark theme with blue accents
- `catppuccin-mocha` - Soothing pastel dark theme
- `nord` - Cool blue/gray theme
- `onedark` - Atom's One Dark theme
- `solarized-dark` - Classic high-contrast theme
- `monokai` - Sublime Text's default theme

### Light Themes
- `gruvbox-light-hard` - Light version of Gruvbox
- `solarized-light` - Classic light theme
- `catppuccin-latte` - Light pastel theme
- `tokyo-night-light` - Light version of Tokyo Night

### Fun/Colorful Themes
- `rainbow` - Bright and colorful
- `pasque` - Purple and pink theme
- `outrun-dark` - Synthwave-inspired theme
- `cyberpunk` - Neon-inspired theme

## Changing Color Schemes

### Method 1: Edit the theming module
Edit `modules/common/theming.nix` and change the colorScheme line:

```nix
# Current:
colorScheme = inputs.nix-colors.colorSchemes.gruvbox-dark-hard;

# Change to any of these:
colorScheme = inputs.nix-colors.colorSchemes.dracula;
colorScheme = inputs.nix-colors.colorSchemes.nord;
colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
colorScheme = inputs.nix-colors.colorSchemes.tokyo-night;
```

### Method 2: Override in your profile
You can override the colorScheme in your profile (e.g., `profiles/workstation.nix`):

```nix
{ config, lib, pkgs, inputs, ... }: {
  # Override the default color scheme
  colorScheme = inputs.nix-colors.colorSchemes.dracula;
  
  # ... rest of your profile
}
```

### Method 3: Per-user override
Override in your specific home configuration by editing the flake's `mkHomeConfig` calls.

## Custom Color Schemes

You can create your own color scheme:

```nix
colorScheme = {
  slug = "my-theme";
  name = "My Custom Theme";
  author = "Your Name";
  palette = {
    base00 = "1a1a1a"; # background
    base01 = "2a2a2a"; # lighter background
    base02 = "3a3a3a"; # selection background
    base03 = "4a4a4a"; # comments, invisibles
    base04 = "5a5a5a"; # dark foreground
    base05 = "dadada"; # default foreground
    base06 = "eaeaea"; # light foreground
    base07 = "ffffff"; # light background
    base08 = "ff6b6b"; # red
    base09 = "ff9559"; # orange
    base0A = "ffeb3b"; # yellow
    base0B = "4caf50"; # green
    base0C = "26c6da"; # cyan
    base0D = "42a5f5"; # blue
    base0E = "ab47bc"; # purple
    base0F = "8d6e63"; # brown
  };
};
```

## Base16 Color Mapping

The base16 standard defines 16 colors with specific purposes:

- `base00` - Default Background
- `base01` - Lighter Background (Used for status bars, line number and folding marks)
- `base02` - Selection Background
- `base03` - Comments, Invisibles, Line Highlighting
- `base04` - Dark Foreground (Used for status bars)
- `base05` - Default Foreground, Caret, Delimiters, Operators
- `base06` - Light Foreground (Not often used)
- `base07` - Light Background (Not often used)
- `base08` - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
- `base09` - Integers, Boolean, Constants, XML Attributes, Markup Link Url
- `base0A` - Classes, Markup Bold, Search Text Background
- `base0B` - Strings, Inherited Class, Markup Code, Diff Inserted
- `base0C` - Support, Regular Expressions, Escape Characters, Markup Quotes
- `base0D` - Functions, Methods, Attribute IDs, Headings
- `base0E` - Keywords, Storage, Selector, Markup Italic, Diff Changed
- `base0F` - Deprecated, Opening/Closing Embedded Language Tags, e.g. `<?php ?>`

## Applying to Additional Applications

To theme additional applications, reference the colors in your configuration:

```nix
programs.someapp = {
  colors = {
    background = "#${config.colorScheme.palette.base00}";
    foreground = "#${config.colorScheme.palette.base05}";
    accent = "#${config.colorScheme.palette.base0D}";
  };
};
```

See `applications/common/theming-examples.nix` for comprehensive examples.

## Rebuilding After Changes

After changing your color scheme:

```bash
# For home-manager
home-manager switch --flake .#your-config

# Or using the rebuild script
./scripts/rebuild.sh
```

## Troubleshooting

### Colors not applying
1. Make sure you've rebuilt your configuration
2. Restart applications that don't auto-reload configs
3. Check that the application configuration references `config.colorScheme.palette.baseXX`

### Scheme not found
1. Verify the scheme name exists in nix-colors
2. Check the [nix-colors documentation](https://github.com/misterio77/nix-colors) for available schemes
3. Ensure you're using the correct syntax: `inputs.nix-colors.colorSchemes.scheme-name`

## Contributing New Schemes

If you create a nice custom scheme, consider contributing it to the [base16-schemes](https://github.com/chriskempson/base16-schemes) repository so others can use it!

## Further Reading

- [nix-colors repository](https://github.com/misterio77/nix-colors)
- [Base16 project](https://github.com/chriskempson/base16)
- [Base16 Gallery](https://tinted-theming.github.io/base16-gallery/) - Preview all available schemes 