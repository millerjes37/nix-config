#!/usr/bin/env bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source common utilities
source "$NIX_CONFIG_DIR/scripts/utils/common.sh"

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
    print_step "Do you want to commit these changes? [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      # Auto-generate commit message based on changed files
      commit_msg="Update configuration: "
      mapfile -t changed_files < <(git diff --name-only)
      
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
  # Check if post-rebuild hook script exists and run it
  if [ -f "$SCRIPT_DIR/post-rebuild-hooks.sh" ]; then
    print_step "Running post-rebuild hooks..."
    "$SCRIPT_DIR/post-rebuild-hooks.sh"
  else
    print_warning "No post-rebuild hooks found."
  fi
}

function rebuild_configuration() {
  print_header "REBUILDING NIX CONFIGURATION"
  
  # Rebuild nix configuration
  print_step "Rebuilding Home Manager configuration..."
  home-manager switch -b backup --flake "$NIX_CONFIG_DIR#jacksonmiller"
  
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
  
  # Go to the nix-config directory
  cd "$NIX_CONFIG_DIR" || exit
  
  # Handle git changes
  if handle_git_changes; then
    made_commits=true
  else
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

# Run the script
main "$@"