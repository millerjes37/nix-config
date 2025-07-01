#!/usr/bin/env bash
# Cross-platform configuration validation script

set -e

# Detect platform
if [[ "$(uname)" == "Darwin" ]]; then
  PLATFORM="darwin"
  PLATFORM_NAME="macOS"
else
  PLATFORM="linux"
  PLATFORM_NAME="Linux"
fi

echo "==== Configuration Validation on $PLATFORM_NAME ===="

# Check for required tools
echo "Checking for required tools..."
REQUIRED_TOOLS=(
  "nix"
  "home-manager"
  "git"
)

MISSING_TOOLS=()
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &> /dev/null; then
    MISSING_TOOLS+=("$tool")
  else
    echo "✓ $tool is installed"
  fi
done

if [[ ${#MISSING_TOOLS[@]} -gt 0 ]]; then
  echo "❌ Missing required tools: ${MISSING_TOOLS[*]}"
  exit 1
fi

# Check if the current directory is a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo "❌ Not inside a git repository. Please run this script from the nix-config directory."
  exit 1
fi

# Check that we're in the root of the repository
REPO_ROOT=$(git rev-parse --show-toplevel)
if [[ "$PWD" != "$REPO_ROOT" ]]; then
  echo "❌ Not in the root of the repository. Please run this script from the nix-config directory."
  exit 1
fi

# Check that flake.nix exists
if [[ ! -f "flake.nix" ]]; then
  echo "❌ flake.nix not found."
  exit 1
else
  echo "✓ flake.nix exists"
fi

# Check that home.nix exists
if [[ ! -f "home.nix" ]]; then
  echo "❌ home.nix not found."
  exit 1
else
  echo "✓ home.nix exists"
fi

# Check for required module directories
for dir in "modules/common" "modules/darwin" "modules/linux"; do
  if [[ ! -d "$dir" ]]; then
    echo "❌ Directory $dir not found."
    exit 1
  else
    echo "✓ Directory $dir exists"
  fi
done

# Check for specific platform files
if [[ "$PLATFORM" == "darwin" ]]; then
  REQUIRED_FILES=(
    "modules/darwin/default.nix"
    "modules/darwin/window-management/skhd.nix"
    "modules/darwin/window-management/yabai.nix"
  )
else
  REQUIRED_FILES=(
    "modules/linux/default.nix"
    "modules/linux/window-management/i3.nix"
    "modules/linux/gtk.nix"
  )
fi

# Add common files to the required files list
REQUIRED_FILES+=(
  "modules/common/default.nix"
  "applications/common/terminal/zsh.nix"
  "applications/common/terminal/alacritty.nix"
  "scripts/rebuild.sh"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    MISSING_FILES+=("$file")
  else
    echo "✓ $file exists"
  fi
done

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
  echo "❌ Missing required files: ${MISSING_FILES[*]}"
  exit 1
fi

# Check if rebuild script is executable
if [[ ! -x "scripts/rebuild.sh" ]]; then
  echo "❌ scripts/rebuild.sh is not executable."
  chmod +x scripts/rebuild.sh
  echo "✓ Fixed permissions on scripts/rebuild.sh"
else
  echo "✓ scripts/rebuild.sh is executable"
fi

# Try to parse flake.nix with nix-instantiate
echo "Validating flake.nix..."
if ! nix flake check --no-build; then
  echo "❌ flake.nix validation failed."
  exit 1
else
  echo "✓ flake.nix is valid"
fi

# Success message
echo ""
echo "✅ Configuration validation successful!"
echo "You can now build your configuration with:"
echo "  ./scripts/rebuild.sh"
echo ""