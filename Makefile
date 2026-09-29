DOTFILES := $(HOME)/repos/dotfiles

.PHONY: install zsh git vim claude copilot k9s brew

install: zsh git vim claude copilot k9s

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
	mkdir -p $(HOME)/.claude/skills $(HOME)/.claude/hooks
	ln -sfn $(DOTFILES)/home/.claude/CLAUDE.md     $(HOME)/.claude/CLAUDE.md
	ln -sfn $(DOTFILES)/home/.claude/settings.json $(HOME)/.claude/settings.json
	ln -sfn $(DOTFILES)/home/.claude/skills/improve-docs   $(HOME)/.claude/skills/improve-docs
	ln -sfn $(DOTFILES)/home/.claude/skills/weekly-status  $(HOME)/.claude/skills/weekly-status
	ln -sfn $(DOTFILES)/home/.claude/hooks/block-out-of-project-edits.py $(HOME)/.claude/hooks/block-out-of-project-edits.py

copilot:
	mkdir -p $(HOME)/.copilot/skills
	ln -sfn $(DOTFILES)/home/.copilot/copilot-instructions.md $(HOME)/.copilot/copilot-instructions.md
	ln -sfn $(DOTFILES)/home/.copilot/skills/simplify $(HOME)/.copilot/skills/simplify

k9s:
	mkdir -p "$(HOME)/Library/Application Support/k9s"
	ln -sfn "$(DOTFILES)/home/Library/Application Support/k9s/config.yaml" "$(HOME)/Library/Application Support/k9s/config.yaml"

brew:
	brew bundle --file=$(DOTFILES)/Brewfile
