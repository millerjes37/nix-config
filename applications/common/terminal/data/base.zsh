# Common ZSH functions and utilities

# Change directory and list contents
cdl() {
    cd "$1" && ls -l
}

# Extract most archive types
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create a new directory and enter it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find text in files
ftext() {
    grep -rni "$1" .
}

# Find files by name
ffind() {
    find . -name "*$1*"
}

# Copy with progress
cp_p() {
    rsync -aP "$@"
}

# Better find using fd
find() {
    command fd "$@"
}

# Go up directory levels easily
up() {
    local d=""
    local limit=$1
    
    # Default to 1 level
    if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
        limit=1
    fi
    
    for ((i=1;i<=limit;i++)); do
        d="../$d"
    done
    
    # Change directory and print the new path
    cd "$d" || return
    pwd
}

# Create a temporary directory and enter it
tmpd() {
    local dir
    if [ $# -eq 0 ]; then
        dir=$(mktemp -d)
    else
        dir=$(mktemp -d -t "$1.XXXXXXXXXX")
    fi
    cd "$dir" || exit
}

# Backup a file
bak() {
    cp "$1"{,.bak}
}

# Simplified git commands
gco() { git checkout "$@"; }
gpo() { git push origin "$@"; }
gplo() { git pull origin "$@"; }
gc() { git commit -m "$@"; }
ga() { git add "$@"; }
gs() { git status; }

# Get HTTP status code of a URL
http_status() {
    curl -s -o /dev/null -w "%{http_code}" "$1"
}

# Get weather information
weather() {
    curl -s "wttr.in/$1?format=3"
}

# Quick nix shell with packages
ns() {
    nix-shell -p "$@"
}

# Get information about a command
cmdinfo() {
    which "$1" && 
    echo "Type: $(type -t "$1")" && 
    man -f "$1" 2>/dev/null
}

# Convert a file to HTML using pygments
2html() {
    pygmentize -f html -O full "$1" > "${1}.html"
}

# Easy calculator
calc() {
    echo "scale=3; $*" | bc -l
}

# Show IP address
myip() {
    curl -s ifconfig.me
}

# Simplified docker commands
dps() { docker ps "$@"; }
di() { docker images "$@"; }
drmi() { docker rmi "$@"; }
drmif() { docker rmi -f "$@"; }
dst() { docker stats "$@"; }
dex() { docker exec -it "$@"; }
dlo() { docker logs "$@"; }