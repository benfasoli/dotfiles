DOTFILES := $(HOME)/repos/dotfiles

.PHONY: install zsh git vim claude copilot brew

install: zsh git vim claude copilot

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
	mkdir -p $(HOME)/.claude/skills $(HOME)/.claude/docs $(HOME)/.claude/hooks
	ln -sfn $(DOTFILES)/home/.claude/CLAUDE.md     $(HOME)/.claude/CLAUDE.md
	ln -sfn $(DOTFILES)/home/.claude/settings.json $(HOME)/.claude/settings.json
	ln -sfn $(DOTFILES)/home/.claude/docs/engineering.md $(HOME)/.claude/docs/engineering.md
	ln -sfn $(DOTFILES)/home/.claude/docs/python.md      $(HOME)/.claude/docs/python.md
	ln -sfn $(DOTFILES)/home/.claude/docs/sql.md         $(HOME)/.claude/docs/sql.md
	ln -sfn $(DOTFILES)/home/.claude/docs/markdown.md    $(HOME)/.claude/docs/markdown.md
	ln -sfn $(DOTFILES)/home/.claude/docs/writing.md     $(HOME)/.claude/docs/writing.md
	ln -sfn $(DOTFILES)/home/.claude/skills/improve-docs   $(HOME)/.claude/skills/improve-docs
	ln -sfn $(DOTFILES)/home/.claude/skills/weekly-status  $(HOME)/.claude/skills/weekly-status
	ln -sfn $(DOTFILES)/home/.claude/hooks/block-out-of-project-edits.py $(HOME)/.claude/hooks/block-out-of-project-edits.py

copilot:
	mkdir -p $(HOME)/.copilot
	ln -sfn $(DOTFILES)/home/.copilot/copilot-instructions.md $(HOME)/.copilot/copilot-instructions.md

brew:
	brew bundle --file=$(DOTFILES)/Brewfile
