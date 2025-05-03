#!/usr/bin/env bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Go to the nix-config directory
cd "$(dirname "$0")/.." || exit

echo -e "${BLUE}====== NIX CONFIG REBUILD SCRIPT ======${NC}"

# Show git status and check if there are changes
echo -e "\n${YELLOW}Current Git Status:${NC}"
git_status=$(git status -s)
echo "$git_status"

# Check if there are any changes
if [[ -z "$git_status" ]]; then
    echo -e "\n${GREEN}No changes detected in git.${NC}"
    has_changes=false
else
    has_changes=true
    # Show git diff
    echo -e "\n${YELLOW}Changes to be applied:${NC}"
    git diff --color=always | head -n 100
fi

# Commit changes if there are any
if [[ "$has_changes" = true ]]; then
    # Prompt for confirmation
    echo -e "\n${YELLOW}Do you want to commit these changes? [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        # Auto-generate commit message based on changed files
        commit_msg="Update configuration: "
        mapfile -t changed_files < <(git diff --name-only)
        
        if [[ ${#changed_files[@]} -eq 0 ]]; then
            echo -e "\n${YELLOW}No files changed. Skipping commit.${NC}"
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
            echo -e "\n${YELLOW}Commit message:${NC} $commit_msg"
            echo -e "${YELLOW}Edit commit message? [y/N]${NC}"
            read -r edit_msg
            if [[ "$edit_msg" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                echo -e "${YELLOW}Enter new commit message:${NC}"
                read -r new_msg
                commit_msg="$new_msg"
            fi
            
            # Commit changes
            git add .
            git commit -m "$commit_msg"
            echo -e "\n${GREEN}Changes committed with message:${NC} $commit_msg"
            
            # Flag that we've made commits
            made_commits=true
        fi
    else
        echo -e "\n${YELLOW}Skipping commit, proceeding with rebuild...${NC}"
    fi
fi

# Rebuild nix configuration
echo -e "\n${BLUE}Rebuilding Nix configuration...${NC}"
home-manager switch -b backup --flake .#jacksonmiller

# Show success message
echo -e "\n${GREEN}Configuration successfully rebuilt!${NC}"

# Provide option to push changes if we made commits
if [[ "$made_commits" = true ]]; then
    echo -e "\n${YELLOW}Do you want to push the changes to the remote repository? [y/N]${NC}"
    read -r push_changes
    if [[ "$push_changes" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "\n${BLUE}Pushing changes to remote repository...${NC}"
        git push
        echo -e "\n${GREEN}Changes successfully pushed!${NC}"
    else
        echo -e "\n${YELLOW}Skipping push to remote repository.${NC}"
    fi
fi

echo -e "\n${BLUE}====== DONE ======${NC}"