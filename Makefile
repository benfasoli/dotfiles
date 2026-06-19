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
	mkdir -p $(HOME)/.claude/skills $(HOME)/.claude/docs
	ln -sfn $(DOTFILES)/home/.claude/CLAUDE.md     $(HOME)/.claude/CLAUDE.md
	ln -sfn $(DOTFILES)/home/.claude/settings.json $(HOME)/.claude/settings.json
	ln -sfn $(DOTFILES)/home/.claude/docs/engineering.md $(HOME)/.claude/docs/engineering.md
	ln -sfn $(DOTFILES)/home/.claude/docs/python.md      $(HOME)/.claude/docs/python.md
	ln -sfn $(DOTFILES)/home/.claude/docs/sql.md         $(HOME)/.claude/docs/sql.md
	ln -sfn $(DOTFILES)/home/.claude/docs/markdown.md    $(HOME)/.claude/docs/markdown.md
	ln -sfn $(DOTFILES)/home/.claude/skills/ship         $(HOME)/.claude/skills/ship
	ln -sfn $(DOTFILES)/home/.claude/skills/improve-docs $(HOME)/.claude/skills/improve-docs

brew:
	brew bundle --file=$(DOTFILES)/Brewfile
