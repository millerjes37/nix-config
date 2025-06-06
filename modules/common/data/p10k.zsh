# Configure powerlevel10k in Lean style with teal, dark green, cyan colors, white text, cream icons, arrows, and a horizontal line

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Left prompt segments
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    # prompt_char           # prompt symbol
  )

  # Right prompt segments
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    time                    # current time
  )

  # Lean style configuration with arrows and line
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true            # Prompt on new line
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true           # Add newline before prompt
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''  # No prefix for first line
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{223}╰──' # Gruvbox Light Yellow prefix with icon
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR='─' # Horizontal line char
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND='106' # Gruvbox Green line

  # Arrows between segments
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%F{72}%f'  # Gruvbox Cyan arrow
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%F{108}%f' # Gruvbox Light Cyan arrow
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''              # No extra separator
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''             # No extra separator

  # Colors: Gruvbox scheme
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='223'              # Gruvbox Light Yellow text for directory
  typeset -g POWERLEVEL9K_DIR_BACKGROUND='66'               # Gruvbox Blue background
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='223'        # Gruvbox Light Yellow text for clean VCS
  typeset -g POWERLEVEL9K_VCS_CLEAN_BACKGROUND='106'         # Gruvbox Green background
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='223'     # Gruvbox Light Yellow text for modified VCS
  typeset -g POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='72'      # Gruvbox Cyan background
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='223'    # Gruvbox Light Yellow text for untracked VCS
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='66'     # Gruvbox Blue background
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='223'        # Gruvbox Light Yellow text for OK status
  typeset -g POWERLEVEL9K_STATUS_OK_BACKGROUND='106'         # Gruvbox Green background
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='223'     # Gruvbox Light Yellow text for error status
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND='124'     # Gruvbox Red background
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='223'             # Gruvbox Light Yellow text for time
  typeset -g POWERLEVEL9K_TIME_BACKGROUND='72'              # Gruvbox Cyan background

  # Prompt symbol
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='223'  # Gruvbox Light Yellow for OK prompt
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_BACKGROUND='106'   # Gruvbox Green background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='223' # Gruvbox Light Yellow for error prompt
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_BACKGROUND='124' # Gruvbox Red background
  typeset -g POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION='-'      # Unicode prompt symbol

  # Icon styling - Unicode icons
  typeset -g POWERLEVEL9K_VCS_GIT_ICON='%F{223}⭠ '              # Gruvbox Light Yellow Git icon
  typeset -g POWERLEVEL9K_VCS_STAGED_ICON='%F{223}✚'            # Gruvbox Light Yellow staged icon
  typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='%F{223}●'          # Gruvbox Light Yellow unstaged icon
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='%F{223}…'         # Gruvbox Light Yellow untracked icon

  # Truncation and other settings
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=2                  # Truncate directory to 2 segments
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"    # Truncate middle of path
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'            # Time format: HH:MM:SS
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true               # Disable hot reload for stability
  typeset -g ZLE_RPROMPT_INDENT=0                               # No extra space on right

  # Ensure UTF-8 locale is set
  typeset -g LC_ALL='en_US.UTF-8'
  typeset -g LANG='en_US.UTF-8'
}

# Initialize p10k
(( ${+functions[p10k]} )) && p10k finalize || true