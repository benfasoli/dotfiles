#!/bin/zsh

# increase maximum number of files that can be open concurrently
ulimit -S -n 2048

# disable parallel limits in MacOS for python multiprocessing
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# use virtual environments in project
export PIP_REQUIRE_VIRTUALENV=true
export PIPENV_VENV_IN_PROJECT=1
export POETRY_VIRTUALENVS_IN_PROJECT=1

# avoid creating .pyc files during development
export PYTHONDONTWRITEBYTECODE=1

# disable autocd
unsetopt AUTO_CD

# stop running containers and prune docker artifacts
dockerclean() {
    docker stop $(docker ps -aq)
    docker container prune --force
    docker image prune --all --force
    docker system prune --force --volumes
}

# prune local branches not on remote
gitclean() {
    git fetch --prune
    BRANCHES=$(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}')

    TEMPFILE=$(mktemp)
    echo $BRANCHES >$TEMPFILE
    vim $TEMPFILE
    while read BRANCH; do
        git branch -D $BRANCH
    done <$TEMPFILE
}

# load environment variables from dotenv file
loadenv() {
    local DOTENV="${1:-.env}"
    if [ ! -e "$DOTENV" ]; then
        echo "❌ $DOTENV not found"
        return 1
    fi
    export $(grep -v '^#' $DOTENV | xargs)
    grep -v '^#' $DOTENV
    echo
    echo "✅ Set environment variables from $DOTENV"
}

# show tree view of git branch / commit history
alias githistory="git log --oneline --decorate --graph --all"

alias ls="lsd"
alias venv="source .venv/bin/activate"

# desktop cleanup utils for screen sharing
alias hidedesktop="defaults write com.apple.finder CreateDesktop false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop true && killall Finder"

# preempt PATH with brew installs
eval "$(/opt/homebrew/bin/brew shellenv)"
export C_INCLUDE_PATH="/opt/homebrew/opt/python3/Frameworks/Python.framework/Headers"

# preempt PATH with user-scoped installs
export PATH="$HOME/.local/bin:$PATH"

# source starship prompt
eval "$(starship init zsh)"

# source uv
. "$HOME/.cargo/env"
