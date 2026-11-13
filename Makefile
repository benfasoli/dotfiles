DOTFILES := $(HOME)/repos/dotfiles

# Every folder in skills/ is linked into both ~/.claude/skills and ~/.copilot/skills.
SKILLS := $(notdir $(wildcard $(DOTFILES)/skills/*))

# Usage: $(call link-skills,<destination skills folder>)
define link-skills
	mkdir -p $(1)
	for skill in $(SKILLS); do ln -sfn $(DOTFILES)/skills/$$skill $(1)/$$skill; done
endef

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
	mkdir -p $(HOME)/.claude/hooks
	ln -sfn $(DOTFILES)/home/.claude/CLAUDE.md     $(HOME)/.claude/CLAUDE.md
	ln -sfn $(DOTFILES)/home/.claude/settings.json $(HOME)/.claude/settings.json
	ln -sfn $(DOTFILES)/home/.claude/hooks/block-out-of-project-edits.py $(HOME)/.claude/hooks/block-out-of-project-edits.py
	$(call link-skills,$(HOME)/.claude/skills)

copilot:
	mkdir -p $(HOME)/.copilot
	ln -sfn $(DOTFILES)/home/.copilot/copilot-instructions.md $(HOME)/.copilot/copilot-instructions.md
	[ ! -L $(HOME)/.copilot/skills/finish-pr ] || rm $(HOME)/.copilot/skills/finish-pr
	$(call link-skills,$(HOME)/.copilot/skills)

k9s:
	mkdir -p "$(HOME)/Library/Application Support/k9s"
	ln -sfn "$(DOTFILES)/home/Library/Application Support/k9s/config.yaml" "$(HOME)/Library/Application Support/k9s/config.yaml"

brew:
	brew bundle --file=$(DOTFILES)/Brewfile
