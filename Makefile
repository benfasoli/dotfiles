DOTFILES := $(HOME)/repos/dotfiles

.PHONY: install zsh git vim claude brew

install: zsh git vim claude

zsh:
	ln -sfn $(DOTFILES)/home/.zshrc  $(HOME)/.zshrc
	ln -sfn $(DOTFILES)/home/.zshenv $(HOME)/.zshenv

git:
	mkdir -p $(HOME)/.config/git
	ln -sfn $(DOTFILES)/home/.gitconfig         $(HOME)/.gitconfig
	ln -sfn $(DOTFILES)/home/.config/git/ignore $(HOME)/.config/git/ignore

vim:
	ln -sfn $(DOTFILES)/home/.vimrc $(HOME)/.vimrc

claude:
	mkdir -p $(HOME)/.claude/skills
	ln -sfn $(DOTFILES)/home/.claude/CLAUDE.md     $(HOME)/.claude/CLAUDE.md
	ln -sfn $(DOTFILES)/home/.claude/settings.json $(HOME)/.claude/settings.json
	ln -sfn $(DOTFILES)/home/.claude/skills/ship   $(HOME)/.claude/skills/ship

brew:
	brew bundle --file=$(DOTFILES)/Brewfile
