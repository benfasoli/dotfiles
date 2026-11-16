# /etc/zprofile runs path_helper after .zshenv and moves /usr/bin ahead of the
# brew and user-scoped entries, so source .zshenv again to put them back first
source "${ZDOTDIR:-$HOME}/.zshenv"
