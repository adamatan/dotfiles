.PHONY: nix brew manual dotfiles simulate upstream

nix:
	nix profile upgrade 'personal/.config/nix'

brew:
	./personal/bin/brew-install

manual:
	./personal/bin/manual-install

dotfiles:
	./install.sh shared personal

simulate:
	stow --simulate -v --target="$(HOME)" shared personal

upstream:
	git fetch upstream
	git merge upstream/main
