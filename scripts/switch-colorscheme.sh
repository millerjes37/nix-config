#!/usr/bin/env bash

# Color Scheme Switcher for Brown/Tan themes
# Usage: ./scripts/switch-colorscheme.sh [scheme-name]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
THEMING_FILE="$CONFIG_DIR/modules/common/theming.nix"

# Available color schemes that match brown/tan preference
declare -A SCHEMES=(
    ["gruvbox-dark-medium"]="Gruvbox Dark Medium - Warmer browns (current default)"
    ["gruvbox-dark-soft"]="Gruvbox Dark Soft - Softer browns and tans"
    ["atelier-cave"]="Atelier Cave - Dark purple/brown cave theme"
    ["atelier-dune"]="Atelier Dune - Sandy dune colors with browns and tans"
    ["atelier-heath"]="Atelier Heath - Muted earth tones with browns"
    ["ir-black"]="IR Black - Dark with brown/orange accents"
    ["mocha"]="Mocha - Rich coffee browns"
    ["espresso"]="Espresso - Dark coffee theme"
)

print_header() {
    echo "🎨 Color Scheme Switcher - Brown/Tan Themes"
    echo "=============================================="
}

print_available_schemes() {
    echo "Available color schemes:"
    echo
    local i=1
    for scheme in "${!SCHEMES[@]}"; do
        echo "  $i) $scheme - ${SCHEMES[$scheme]}"
        ((i++))
    done
    echo
}

get_current_scheme() {
    if [[ -f "$THEMING_FILE" ]]; then
        grep -o 'inputs\.nix-colors\.colorSchemes\.[^;]*' "$THEMING_FILE" | head -1 | sed 's/inputs\.nix-colors\.colorSchemes\.//'
    else
        echo "unknown"
    fi
}

switch_scheme() {
    local new_scheme="$1"
    
    if [[ ! "${SCHEMES[$new_scheme]+_}" ]]; then
        echo "❌ Error: Unknown scheme '$new_scheme'"
        echo "Available schemes: ${!SCHEMES[*]}"
        exit 1
    fi
    
    echo "🔄 Switching to: $new_scheme"
    echo "   ${SCHEMES[$new_scheme]}"
    
    # Create backup
    cp "$THEMING_FILE" "$THEMING_FILE.backup"
    
    # Update the theming file
    sed -i.tmp "s/colorScheme = inputs\.nix-colors\.colorSchemes\.[^;]*/colorScheme = inputs.nix-colors.colorSchemes.$new_scheme/" "$THEMING_FILE"
    rm "$THEMING_FILE.tmp"
    
    # Also comment out other schemes and uncomment the selected one
    {
        echo "{ config, lib, pkgs, inputs, ... }:"
        echo ""
        echo "{"
        echo "  # Import nix-colors home-manager module"
        echo "  imports = ["
        echo "    inputs.nix-colors.homeManagerModules.default"
        echo "  ];"
        echo ""
        echo "  # Color scheme options for light browns, tans, and dark backgrounds:"
        echo "  # Switch schemes using: ./scripts/switch-colorscheme.sh [scheme-name]"
        echo ""
        
        for scheme in "${!SCHEMES[@]}"; do
            if [[ "$scheme" == "$new_scheme" ]]; then
                echo "  # ✅ ACTIVE: $scheme - ${SCHEMES[$scheme]}"
                echo "  colorScheme = inputs.nix-colors.colorSchemes.$scheme;"
            else
                echo "  # $scheme - ${SCHEMES[$scheme]}"
                echo "  # colorScheme = inputs.nix-colors.colorSchemes.$scheme;"
            fi
            echo ""
        done
        
        echo "  # Export color scheme for easy access in other modules"
        echo "  # This allows other modules to use config.colorScheme.palette.baseXX"
        echo "}"
    } > "$THEMING_FILE.new"
    
    mv "$THEMING_FILE.new" "$THEMING_FILE"
    
    echo "✅ Scheme switched to: $new_scheme"
    echo "🔧 Run 'nixrebuild' or 'home-manager switch --flake .#jacksonmiller@mac' to apply"
}

preview_scheme() {
    local scheme="$1"
    echo "🎨 Preview of $scheme:"
    echo "   ${SCHEMES[$scheme]}"
    
    # Try to get color palette info (this might not work with all schemes)
    nix eval --json ".#nix-colors.colorSchemes.$scheme.palette" 2>/dev/null | jq -r 'to_entries[] | "  \(.key): #\(.value)"' || echo "   (Color details not available in preview)"
}

interactive_mode() {
    print_header
    echo "Current scheme: $(get_current_scheme)"
    echo
    print_available_schemes
    
    echo "Enter the number or name of the scheme you want:"
    read -r choice
    
    # Check if it's a number
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        local schemes_array=($(printf '%s\n' "${!SCHEMES[@]}" | sort))
        if [[ "$choice" -ge 1 && "$choice" -le "${#schemes_array[@]}" ]]; then
            local selected_scheme="${schemes_array[$((choice-1))]}"
            switch_scheme "$selected_scheme"
        else
            echo "❌ Invalid number. Please choose between 1 and ${#schemes_array[@]}"
            exit 1
        fi
    else
        switch_scheme "$choice"
    fi
}

# Main logic
if [[ $# -eq 0 ]]; then
    interactive_mode
elif [[ "$1" == "--list" ]]; then
    print_available_schemes
elif [[ "$1" == "--current" ]]; then
    echo "Current scheme: $(get_current_scheme)"
elif [[ "$1" == "--preview" && $# -eq 2 ]]; then
    preview_scheme "$2"
else
    switch_scheme "$1"
fi 