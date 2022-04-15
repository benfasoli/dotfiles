#!/bin/zsh

# disable parallel limits in MacOS for python multiprocessing
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# use virtual environments in project
export PIPENV_VENV_IN_PROJECT=1
export POETRY_VIRTUALENVS_IN_PROJECT=1

# disable autocd
unsetopt AUTO_CD

# avoid creating .pyc files during development
PYTHONDONTWRITEBYTECODE=1

# command aliases
alias ghistory="git log --oneline --decorate --graph --all"
alias ls="exa --icons --time-style=long-iso --git --color-scale --long"
alias tree="ls --tree --git-ignore"

alias hidedesktop="defaults write com.apple.finder CreateDesktop false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop true && killall Finder"
alias hd="hidedesktop"
alias sd="showdesktop"

# preempt PATH with brew installs
eval "$(brew shellenv -)"

# source starship prompt
eval "$(starship init zsh)"
