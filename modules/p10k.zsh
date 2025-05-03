# Generated p10k configuration in bullet train style with teal/cyan colors
# To customize, run `p10k configure` or edit ~/.p10k.zsh directly.

# Temporarily change options
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  # Define variables
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    dir                     # current directory
    vcs                     # git status
    newline                 # new line
    prompt_char             # prompt symbol
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status                  # exit code of the last command
    command_execution_time  # duration of the last command
    background_jobs         # presence of background jobs
    time                    # current time
  )

  # Basic style
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='╰─ '
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='╰─ '
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
  
  # Colors - teal and greens
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='074'
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='076'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='172'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='076'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='196'
  
  # Prompt character
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_CONTENT_EXPANSION='❯'
}

# Run powerlevel10k configuration
(( ${+functions[p10k]} )) && p10k finalize