#!/usr/bin/env bash

# Common utility functions for nix-config scripts

# Colors for output
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# Print a section header
function print_header() {
  echo -e "\n${BLUE}====== $1 ======${NC}"
}

# Print a success message
function print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Print a warning message
function print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

# Print an error message
function print_error() {
  echo -e "${RED}$1${NC}"
}

# Print a step message
function print_step() {
  echo -e "${YELLOW}$1${NC}"
}

# Check if a command exists, install with brew if it doesn't
function ensure_command() {
  local cmd=$1
  local pkg=${2:-$1}  # Use command name as package name if not specified
  
  if ! command -v "$cmd" &> /dev/null; then
    print_warning "$cmd not found, installing with brew..."
    brew install "$pkg"
    return $?
  fi
  
  return 0
}

# Check if a process is running
function is_process_running() {
  pgrep -x "$1" >/dev/null
  return $?
}

# Safely stop a process if it's running
function stop_process() {
  local process_name=$1
  
  if is_process_running "$process_name"; then
    print_step "Stopping $process_name..."
    pkill -x "$process_name"
    sleep 1
    return 0
  else
    print_success "No running $process_name process found."
    return 1
  fi
}

# Check command availability
function check_command() {
  if command -v "$1" &> /dev/null; then
    echo "✅ $1 is available at: $(which $1)"
  else
    echo "❌ $1 is not available"
  fi
}