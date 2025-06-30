#!/usr/bin/env bash
# Enhanced Nix Configuration Rebuild Script with Git Integration
# Handles cross-platform builds, validation, and automatic git operations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Enhanced global error handling
# -----------------------------------------------------------------------------
# Whenever any command in the script fails, this trap prints a helpful message
# and exits with the failing command's status code.  Use --verbose for the full
# command trace that led to the error.

on_error() {
  local exit_code=$?
  local line_no=$1
  local cmd=$2
  echo -e "${RED}[ERROR]${NC} Command '${cmd}' failed on line ${line_no} with exit code ${exit_code}" | tee -a "$LOG_FILE"
  echo -e "${YELLOW}[HINT]${NC} Review the log at $LOG_FILE or rerun with the --verbose flag for a command-by-command trace." | tee -a "$LOG_FILE"
  exit "$exit_code"
}
trap 'on_error $LINENO "$BASH_COMMAND"' ERR
trap 'echo -e "${YELLOW}[INTERRUPTED]${NC} Build was interrupted." | tee -a "$LOG_FILE"; exit 130' INT TERM

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CONFIG_ROOT="$(cd "$SCRIPT_DIR/.." &> /dev/null && pwd)"
LOG_FILE="/tmp/nix-rebuild.log"

# Platform detection
if [[ "$(uname)" == "Darwin" ]]; then
    PLATFORM="darwin"
    PLATFORM_NAME="macOS"
    DEFAULT_USER="jacksonmiller"
    DEFAULT_TARGET="jacksonmiller@mac"
    REBUILD_CMD="darwin-rebuild"
else
    PLATFORM="linux"
    PLATFORM_NAME="Linux"
    DEFAULT_USER="jackson"
    DEFAULT_TARGET="jackson@linux"
    REBUILD_CMD="home-manager"
fi

# Functions
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo
    echo "====== NIX CONFIG REBUILD SCRIPT ======"
    echo "Platform: $PLATFORM_NAME"
    echo "User: $DEFAULT_USER"
    echo "Target: $DEFAULT_TARGET"
    echo "Config Root: $CONFIG_ROOT"
    echo
}

check_prerequisites() {
    log "Checking prerequisites..."
    
    local missing_tools=()
    local target="${1:-$DEFAULT_TARGET}"
    
    # Check for required tools
    command -v nix >/dev/null 2>&1 || missing_tools+=("nix")
    command -v home-manager >/dev/null 2>&1 || missing_tools+=("home-manager")
    
    # Only check for darwin-rebuild if we're on macOS and not using a home-manager target
    if [[ "$PLATFORM" == "darwin" && "$target" != *"@mac" ]]; then
        command -v darwin-rebuild >/dev/null 2>&1 || missing_tools+=("darwin-rebuild")
    fi
    
    # Only check for nixos-rebuild if we're targeting a nixos configuration
    if [[ "$target" == "nixos-desktop" ]]; then
        command -v nixos-rebuild >/dev/null 2>&1 || missing_tools+=("nixos-rebuild")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
        exit 1
    fi
    
    success "All prerequisites satisfied"
}

check_git_status() {
    log "Skipping git status check (git sync disabled)"
    return 0
}

commit_and_push() {
    log "Skipping git commit and push (git sync disabled)"
    return 0
}

validate_flake() {
    log "Validating flake configuration..."
    
    cd "$CONFIG_ROOT"
    
    local attempts=1
    local max_attempts=3
    while (( attempts <= max_attempts )); do
        if nix flake check --no-build 2>&1 | tee -a "$LOG_FILE"; then
            success "Flake validation passed on attempt $attempts"
            return 0
        fi
        if (( attempts == max_attempts )); then
            error "Flake validation failed after $max_attempts attempts"
            return 1
        fi
        warn "Flake validation failed (attempt $attempts/$max_attempts). Retrying in 5 seconds..."
        attempts=$((attempts+1))
        sleep 5
    done
}

backup_config() {
    log "Creating backup..."
    
    local backup_dir="$HOME/.config/nix-backups/$(date +'%Y-%m-%d_%H-%M-%S')"
    mkdir -p "$backup_dir"
    
    # Backup important config files
    if [[ "$PLATFORM" == "linux" ]]; then
        cp -r "$HOME/.config/home-manager" "$backup_dir/" 2>/dev/null || true
        cp "$HOME/.config/mimeapps.list" "$backup_dir/" 2>/dev/null || true
    fi
    
    success "Backup created at $backup_dir"
}

rebuild_config() {
    local target="${1:-$DEFAULT_TARGET}"
    
    log "Rebuilding configuration for target: $target"
    
    cd "$CONFIG_ROOT"
    
    # Clear any stale backup file that can trip home-manager
    [[ -f "$HOME/.config/mimeapps.list.backup" ]] && rm -f "$HOME/.config/mimeapps.list.backup"
    
    # ---------------------------------------------------------------------------
    # Build the appropriate command for the current platform/target
    # ---------------------------------------------------------------------------
    local cmd=""
    local force_flags=""
    
    # Add force rebuild flags if requested
    if [[ "$FORCE_REBUILD" == true ]]; then
        force_flags="--impure"
        log "Force rebuild enabled - using --impure flag"
    fi
    
    if [[ "$PLATFORM" == "darwin" ]]; then
        if [[ "$target" == *"@mac" ]]; then
            cmd="home-manager switch --flake .#${target} -b backup $force_flags"
        else
            cmd="darwin-rebuild switch --flake .#${target} $force_flags"
        fi
    else
        if [[ "$target" == "nixos-desktop" ]]; then
            cmd="sudo nixos-rebuild switch --flake .#${target} $force_flags"
        else
            cmd="home-manager switch --flake .#${target} -b backup $force_flags"
        fi
    fi

    log "Running rebuild command: $cmd"
    if eval $cmd 2>&1 | tee -a "$LOG_FILE"; then
        success "Configuration rebuilt successfully"
        return 0
    fi

    # If we get here the first attempt failed – retry with --show-trace for detail
    warn "Rebuild failed – retrying once with --show-trace for detailed diagnostics"
    if [[ "$cmd" != *"--show-trace"* ]]; then
        cmd+=" --show-trace"
    fi
    eval $cmd 2>&1 | tee -a "$LOG_FILE"
}

update_flake() {
    log "Updating flake inputs..."
    
    cd "$CONFIG_ROOT"
    nix flake update
    
    success "Flake inputs updated"
}

update_nixpkgs() {
    log "Updating nixpkgs input..."
    
    cd "$CONFIG_ROOT"
    nix flake lock --update-input nixpkgs
    
    success "Nixpkgs input updated"
}

show_help() {
    echo "Usage: $0 [OPTIONS] [TARGET]"
    echo ""
    echo "Enhanced Nix configuration rebuild script"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help          Show this help message"
    echo "  -u, --update        Update flake inputs before rebuilding"
    echo "  -f, --force         Force rebuild even if no changes detected"
    echo "  --update-nixpkgs    Update only nixpkgs input"
    echo "  -c, --commit        Commit and push changes after successful rebuild"
    echo "  -s, --skip-check    Skip flake validation"
    echo "  -b, --backup        Create backup before rebuilding"
    echo "  -v, --verbose       Enable verbose output"
    echo ""
    echo "TARGETS:"
    echo "  Linux:"
    echo "    jackson@linux     Home Manager configuration (default)"
    echo "    nixos-desktop     NixOS system configuration"
    echo ""
    echo "  macOS:"
    echo "    jacksonmiller@mac Home Manager configuration (default)"
    echo "    macbook-air       nix-darwin system configuration"
    echo ""
    echo "Examples:"
    echo "  $0                  # Rebuild default configuration"
    echo "  $0 -uc              # Update, rebuild, and commit"
    echo "  $0 -f               # Force rebuild"
    echo "  $0 --update-nixpkgs # Update nixpkgs and rebuild"
    echo "  $0 nixos-desktop    # Rebuild NixOS system"
}

# Parse command line arguments
UPDATE_FLAKE=false
UPDATE_NIXPKGS=false
FORCE_REBUILD=false
COMMIT_CHANGES=false
SKIP_CHECK=false
CREATE_BACKUP=false
VERBOSE=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--update)
            UPDATE_FLAKE=true
            shift
            ;;
        -f|--force)
            FORCE_REBUILD=true
            shift
            ;;
        --update-nixpkgs)
            UPDATE_NIXPKGS=true
            shift
            ;;
        -c|--commit)
            COMMIT_CHANGES=true
            shift
            ;;
        -s|--skip-check)
            SKIP_CHECK=true
            shift
            ;;
        -b|--backup)
            CREATE_BACKUP=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        -*)
            error "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

# Use default target if none specified
TARGET="${TARGET:-$DEFAULT_TARGET}"

# Main execution
main() {
    print_header
    
    # Initialize log
    echo "Rebuild started at $(date)" > "$LOG_FILE"
    
    # Check prerequisites
    check_prerequisites "$TARGET"
    
    # Backup if requested
    if [[ "$CREATE_BACKUP" == true ]]; then
        backup_config
    fi
    
    # Update flake if requested
    if [[ "$UPDATE_FLAKE" == true ]]; then
        update_flake
    fi
    
    # Update nixpkgs if requested
    if [[ "$UPDATE_NIXPKGS" == true ]]; then
        update_nixpkgs
    fi
    
    # Validate flake
    if [[ "$SKIP_CHECK" != true ]]; then
        if ! validate_flake; then
            error "Flake validation failed. Use --skip-check to bypass."
            exit 1
        fi
    fi
    
    # Rebuild configuration
    if ! rebuild_config "$TARGET"; then
        error "Configuration rebuild failed!"
        exit 1
    fi
    
    # Commit and push if requested
    if [[ "$COMMIT_CHANGES" == true ]]; then
        commit_and_push
    fi
    
    success "Rebuild completed successfully!"
    log "Log saved to: $LOG_FILE"
}

# Run main function
main "$@"