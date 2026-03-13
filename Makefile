.PHONY: nix brew manual dotfiles simulate upstream

nix:
	@if nix profile list 2>/dev/null | grep -q 'personal/.config/nix'; then \
		nix profile upgrade 'personal/.config/nix'; \
	else \
		nix profile add path:personal/.config/nix; \
	fi

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
