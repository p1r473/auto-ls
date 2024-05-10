# Setup environment variables and default values
if (( ! ${+AUTO_LS_CHPWD} )); then
  AUTO_LS_CHPWD=true
fi

if [[ $#AUTO_LS_COMMANDS -eq 0 ]]; then
  AUTO_LS_COMMANDS=(ls git-status)
fi

if (( ! ${+AUTO_LS_NEWLINE} )); then
  AUTO_LS_NEWLINE=true
fi

if (( ! ${+AUTO_LS_PATH} )); then
  AUTO_LS_PATH=true
fi

typeset -g AUTO_LS_INIT_COMPLETE=false

# Define functions to perform listing and status checking
auto-ls-ls () {
  ls --color=auto -a
  [[ $AUTO_LS_NEWLINE != false ]] && echo ""
}

auto-ls-git-status () {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == true ]]; then
    git status
  fi
}

# Function that handles the automatic listing after directory changes
auto-ls () {
  if [[ $AUTO_LS_INIT_COMPLETE == false || $AUTO_LS_CHPWD == false ]]; then
    return
  fi

  local cmd
  for cmd in $AUTO_LS_COMMANDS; do
    if [[ $AUTO_LS_PATH != false && $cmd =~ '/' ]]; then
      eval $cmd
    else
      "auto-ls-$cmd"
    fi
  done
}

# Hook auto-ls into precmd for it to execute after every command
autoload -Uz add-zsh-hook
add-zsh-hook precmd auto-ls
