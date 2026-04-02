#!/bin/zsh

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
    local DOTENV=${1:-.env}
    echo $DOTENV
    if [ ! -e "$DOTENV" ]; then
        echo "❌ $DOTENV not found"
        return 1
    fi
    export $(grep -v '^#' $DOTENV | xargs)
    grep -v '^#' $DOTENV
    echo
    echo "✅ Set environment variables from $DOTENV"
}

# format github PR URL as markdown link
prshare() {
    local url=$1
    if [[ -z "$url" ]]; then
        echo "Usage: prshare <github-pr-url>" >&2
        return 1
    fi
    if [[ ! "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
        echo "Invalid GitHub PR URL" >&2
        return 1
    fi
    local repo="${match[2]}"
    local pr_num="${match[3]}"
    local title=$(gh pr view "$url" --json title --jq '.title')
    echo "[${repo}#${pr_num}](${url}): ${title}"
}

# show tree view of git branch / commit history
alias githistory="git log --oneline --decorate --graph --all"

alias ls="lsd"

alias hidedesktop="defaults write com.apple.finder CreateDesktop false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop true && killall Finder"

# source starship prompt
eval "$(starship init zsh)"
