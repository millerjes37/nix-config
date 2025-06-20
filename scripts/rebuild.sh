#!/usr/bin/env bash
# Cross-platform rebuild script for Nix configurations

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common utilities if available
if [ -f "$NIX_CONFIG_DIR/scripts/utils/common.sh" ]; then
  source "$NIX_CONFIG_DIR/scripts/utils/common.sh"
else
  echo "Error: scripts/utils/common.sh not found. Please ensure it exists."
  exit 1
fi

# Platform detection
if [[ "$(uname)" == "Darwin" ]]; then
  PLATFORM="darwin"
  if [[ "$USER" == "" ]]; then
    USER="jacksonmiller"
  fi
  FLAKE_TARGET="$USER@mac"
else
  PLATFORM="linux"
  if [[ "$USER" == "" ]]; then
    USER="jackson"
  fi
  FLAKE_TARGET="$USER@linux"
fi

# Check for arguments
VERBOSE=0
DARWIN_REBUILD=0
UPGRADE_LOCK=0
SKIP_GIT=0

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -v|--verbose) VERBOSE=1; shift ;;
    -d|--darwin) DARWIN_REBUILD=1; shift ;;
    -u|--upgrade) UPGRADE_LOCK=1; shift ;;
    -s|--skip-git) SKIP_GIT=1; shift ;;
    -h|--help) 
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -v, --verbose     Enable verbose output"
      echo "  -d, --darwin      Use darwin-rebuild instead of home-manager on macOS"
      echo "  -u, --upgrade     Update flake lock file (upgrade all dependencies)"
      echo "  -s, --skip-git    Skip git operations"
      echo "  -h, --help        Show this help message"
      exit 0
      ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
done

function sync_with_remote() {
  print_header "SYNCING WITH REMOTE REPOSITORY"
  
  # Define the remote repository URL
  REMOTE_URL="https://github.com/millerjes37/nix-config.git"
  
  # Check if we're in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Skipping sync."
    return 1
  fi
  
  # Fetch the latest changes from remote
  print_step "Fetching latest changes from remote repository..."
  if ! git fetch origin; then
    print_error "Failed to fetch from remote repository."
    return 1
  fi
  
  # Check if we have local changes
  if [[ -n "$(git status --porcelain)" ]]; then
    print_warning "Local changes detected. Stashing changes before sync..."
    git stash push -m "Auto-stash before sync $(date '+%Y-%m-%d %H:%M:%S')"
    stashed_changes=true
  else
    stashed_changes=false
  fi
  
  # Get current branch
  current_branch=$(git branch --show-current)
  
  # Pull the latest changes
  print_step "Pulling latest changes from origin/$current_branch..."
  if git pull origin "$current_branch"; then
    print_success "Successfully synced with remote repository."
  else
    print_error "Failed to pull from remote repository."
    
    # Restore stashed changes if we stashed them
    if [[ "$stashed_changes" = true ]]; then
      print_step "Restoring previously stashed changes..."
      git stash pop
    fi
    return 1
  fi
  
  # Restore stashed changes if we stashed them
  if [[ "$stashed_changes" = true ]]; then
    print_step "Restoring previously stashed changes..."
    if git stash pop; then
      print_success "Successfully restored stashed changes."
    else
      print_warning "There were conflicts restoring stashed changes. Please resolve manually."
      print_step "Use 'git stash list' to see stashed changes and 'git stash pop' to restore them."
    fi
  fi
  
  return 0
}

function handle_git_changes() {
  print_header "GIT STATUS"
  
  # Show git status and check if there are changes
  print_step "Current Git Status:"
  git_status=$(git status -s)
  echo "$git_status"
  
  # Check if there are any changes
  if [[ -z "$git_status" ]]; then
    print_success "No changes detected in git."
    return 1  # No changes
  else
    # Show git diff
    print_step "Changes to be applied:"
    git diff --color=always | head -n 100
    
    # Prompt for confirmation
    echo
    print_step "Do you want to commit these changes? [Y/n]"
    read -r response
    # Default to "yes" if response is empty
    if [[ -z "$response" || "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      # Auto-generate commit message based on changed files
      commit_msg="Update configuration: "
      
      if command -v mapfile &> /dev/null; then
        mapfile -t changed_files < <(git diff --name-only)
      else
        # Fallback for platforms without mapfile (older bash)
        IFS=$'\n' read -d '' -ra changed_files < <(git diff --name-only)
      fi
      
      if [[ ${#changed_files[@]} -eq 0 ]]; then
        print_warning "No files changed. Skipping commit."
        return 1  # No changes
      else
        for file in "${changed_files[@]}"; do
          basename=$(basename "$file")
          if [[ "$commit_msg" != *"$basename"* ]]; then
            commit_msg+="$basename, "
          fi
        done
        
        # Remove trailing comma and space
        commit_msg=${commit_msg%, }
        
        # Allow user to edit the commit message
        print_step "Commit message: $commit_msg"
        print_step "Edit commit message? [y/N]"
        read -r edit_msg
        # Default to "no" if response is empty
        if [[ "$edit_msg" =~ ^([yY][eE][sS]|[yY])$ ]]; then
          print_step "Enter new commit message:"
          read -r new_msg
          commit_msg="$new_msg"
        fi
        
        # Commit changes
        git add .
        git commit -m "$commit_msg"
        print_success "Changes committed with message: $commit_msg"
        
        return 0  # Changes committed
      fi
    else
      print_warning "Skipping commit, proceeding with rebuild..."
      return 1  # No changes committed
    fi
  fi
}

function run_post_rebuild() {
  print_header "POST-REBUILD ACTIONS"
  
  if [[ "$PLATFORM" == "darwin" ]]; then
    # macOS post-rebuild tasks
    if command -v yabai &> /dev/null && [[ -f "$HOME/.config/yabai/yabairc" ]]; then
      print_step "Restarting yabai..."
      yabai --restart-service
    fi
    
    if command -v skhd &> /dev/null && [[ -f "$HOME/.config/skhd/skhdrc" ]]; then
      print_step "Restarting skhd..."
      skhd --restart-service
    fi
  else
    # Linux post-rebuild tasks
    if command -v i3-msg &> /dev/null; then
      print_step "Reloading i3..."
      i3-msg reload > /dev/null
    fi
    
    if command -v systemctl &> /dev/null; then
      print_step "Reloading user services..."
      systemctl --user daemon-reload
    fi
  fi
  
  # Check if post-rebuild hook script exists and run it
  if [ -f "$SCRIPT_DIR/post-rebuild-hooks.sh" ]; then
    print_step "Running post-rebuild hooks..."
    "$SCRIPT_DIR/post-rebuild-hooks.sh"
  fi
}

function rebuild_configuration() {
  print_header "REBUILDING NIX CONFIGURATION"
  
  # Environment variables for allowing unfree packages
  export NIXPKGS_ALLOW_UNFREE=1
  export NIXPKGS_ALLOW_INSECURE=1
  
  # Determine command to run based on platform
  if [[ "$PLATFORM" == "darwin" && "$DARWIN_REBUILD" -eq 1 ]]; then
    print_step "Rebuilding macOS configuration with darwin-rebuild..."
    CMD="darwin-rebuild switch --flake \"$NIX_CONFIG_DIR#macbook-air\""
  else
    print_step "Rebuilding with home-manager on $PLATFORM..."
    CMD="home-manager switch --flake \"$NIX_CONFIG_DIR#$FLAKE_TARGET\""
  fi
  
  # Add upgrade flag if requested
  if [[ "$UPGRADE_LOCK" -eq 1 ]]; then
    CMD="$CMD --recreate-lock-file"
  fi
  
  # Add backup flag for home-manager
  if [[ "$DARWIN_REBUILD" -eq 0 ]]; then
    CMD="$CMD -b backup"
  fi
  
  # Add verbosity if requested
  if [[ "$VERBOSE" -eq 1 ]]; then
    CMD="$CMD --verbose"
  fi
  
  # Run the command
  print_step "Running: $CMD"
  eval "$CMD"
  
  print_success "Configuration successfully rebuilt!"
}

function handle_git_push() {
  # Provide option to push changes if we made commits
  print_step "Do you want to push the changes to the remote repository? [y/N]"
  read -r push_changes
  if [[ "$push_changes" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_step "Pushing changes to remote repository..."
    git push
    print_success "Changes successfully pushed!"
  else
    print_warning "Skipping push to remote repository."
  fi
}

# Main function
function main() {
  print_header "NIX CONFIG REBUILD SCRIPT"
  print_step "Platform: $PLATFORM"
  print_step "User: $USER"
  print_step "Flake target: $FLAKE_TARGET"
  
  # Go to the nix-config directory
  cd "$NIX_CONFIG_DIR" || exit
  
  # Sync with remote repository unless git operations are skipped
  if [[ "$SKIP_GIT" -eq 0 ]]; then
    sync_with_remote
  fi
  
  # Handle git changes unless skipped
  if [[ "$SKIP_GIT" -eq 0 ]]; then
    if handle_git_changes; then
      made_commits=true
    else
      made_commits=false
    fi
  else
    print_warning "Skipping git operations as requested."
    made_commits=false
  fi
  
  # Rebuild nix configuration
  rebuild_configuration
  
  # Run post-rebuild hooks
  run_post_rebuild
  
  # Offer to push if we made commits
  if [[ "$made_commits" = true ]]; then
    handle_git_push
  fi
  
  print_header "REBUILD COMPLETE"
}

# Make the script executable
chmod +x "$0"

# Run the script
main "$@"