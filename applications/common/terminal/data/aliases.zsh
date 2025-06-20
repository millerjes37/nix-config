# Common aliases for both platforms

# Nix-specific commands
# Rebuild the Nix configuration
nixrebuild() {
  $HOME/nix-config/scripts/rebuild.sh "$@"
}

# Run a short-lived Nix shell with specified packages
nix-shell-with() {
  nix-shell -p "$@" --run zsh
}

# Install a package with Nix
nix-install() {
  nix-env -iA "nixpkgs.$1"
}

# Search for a package in Nixpkgs
nix-search() {
  nix search nixpkgs "$@"
}

# File system navigation and listing
alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editors and tools
alias n='nvim'
alias v='nvim'
alias vim='nvim'
alias g='git'
alias d='docker'
alias r='rails'
alias lzg='lazygit'
alias lzd='lazydocker'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gp='git push'
alias gl='git log --graph --pretty=format:"%C(blue)%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(cyan)<%an>%Creset"'
alias gll='git log --graph --pretty=format:"%C(blue)%h%Creset -%C(yellow)%d%Creset %s %C(green)(%cr) %C(cyan)<%an>%Creset" --all'

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
decompress() { tar -xzf "$1"; }

# Media conversion
webm2mp4() {
  input_file="$1"
  output_file="${input_file%.webm}.mp4"
  ffmpeg -i "$input_file" -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 192k "$output_file"
}

# Professional Media Workflow Aliases
# Video processing shortcuts
alias social-video='$HOME/Projects/Media/Scripts/ffmpeg/social-video.sh'
alias process-audio='$HOME/Projects/Media/Scripts/ffmpeg/audio-process.sh'
alias batch-resize='$HOME/Projects/Media/Scripts/ffmpeg/batch-resize.sh'

# Campaign content generation
alias campaign-post='$HOME/Projects/Media/Scripts/automation/campaign-post.sh'
alias brand-colors='$HOME/Projects/Media/Scripts/automation/brand-colors.sh'
alias create-templates='$HOME/Projects/Media/Scripts/automation/create-templates.sh'

# Media directories
alias media='cd $HOME/Projects/Media'
alias media-assets='cd $HOME/Projects/Media/Assets'
alias media-export='cd $HOME/Projects/Media/Export'
alias media-templates='cd $HOME/Projects/Media/Templates'

# Quick media operations
alias optimize-images='find . -name "*.jpg" -exec jpegoptim --max=85 {} \;'
alias optimize-pngs='find . -name "*.png" -exec optipng {} \;'
alias media-info='mediainfo'

# Social media format shortcuts
instagram() {
  if [ -f "$1" ]; then
    social-video "$1" instagram
  else
    echo "Usage: instagram video_file.mp4"
  fi
}

twitter() {
  if [ -f "$1" ]; then
    social-video "$1" twitter
  else
    echo "Usage: twitter video_file.mp4"
  fi
}

facebook() {
  if [ -f "$1" ]; then
    social-video "$1" facebook
  else
    echo "Usage: facebook video_file.mp4"
  fi
}

# Quick directory switching with zoxide
z() {
  if [ $# -eq 0 ]; then
    cd ~
  else
    cd "$(zoxide query "$@")" || return
  fi
}

# Enhanced grep and find
alias grep='rg --smart-case'
alias find='fd'

# System tools with better alternatives
alias cat='bat'
alias top='btm'  # bottom
alias du='dust'
alias ps='procs'
alias df='duf'

# Quick directory creation and navigation
mkcd() { mkdir -p "$1" && cd "$1"; }

# Quick file editing
e() { 
  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

# Git helper to clone and cd into repo
gcl() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

# Quick docker commands
dps() { docker ps "$@"; }
di() { docker images "$@"; }
drm() { docker rm "$@"; }
drmi() { docker rmi "$@"; }
dex() { docker exec -it "$@"; }
dlog() { docker logs "$@"; }

# Reload shell configuration
alias reload="source ~/.zshrc"

# Show system info
alias sysinfo="neofetch"

# Advanced Media Processing Scripts
# Core video processing
alias auto-crop='$HOME/nix-config/scripts/media/video/auto-crop.sh'
alias extract-highlights='$HOME/nix-config/scripts/media/video/highlight-detector.sh'
alias speech-analysis='$HOME/nix-config/scripts/media/video/speech-segments.sh'

# Audio and transcription
alias transcribe='$HOME/nix-config/scripts/media/audio/transcribe.sh'
alias add-subtitles='$HOME/nix-config/scripts/media/templates/subtitle-overlay.sh'

# Complete automation workflows
alias generate-shorts='$HOME/nix-config/scripts/media/automation/shorts-generator.sh'
alias media-pipeline='$HOME/nix-config/scripts/media/automation/clip-pipeline.sh'
alias bulk-process='$HOME/nix-config/scripts/media/automation/bulk-process.sh'

# Quick workflow shortcuts for political communications
alias quick-shorts='generate-shorts --viral-optimization --parallel-processing'
alias political-clips='auto-crop --type speech --extract-quotes'
alias social-ready='generate-shorts -s social -p tiktok,instagram,youtube'
alias debate-highlights='extract-highlights --type applause --audience-reactions'
alias transcribe-fast='transcribe -m tiny -f txt'
alias transcribe-quality='transcribe -m large-v3 --political-keywords'
alias add-captions='add-subtitles --auto-transcribe -s social'