# Common aliases for both platforms

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
alias gl='git log --graph --pretty=format:"%Cblue%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold cyan)<%an>%Creset"'
alias gll='git log --graph --pretty=format:"%Cblue%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold cyan)<%an>%Creset" --all'

# Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
decompress() { tar -xzf "$1"; }

# Media conversion
webm2mp4() {
  input_file="$1"
  output_file="${input_file%.webm}.mp4"
  ffmpeg -i "$input_file" -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 192k "$output_file"
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