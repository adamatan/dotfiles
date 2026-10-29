# Mac Studio: env.fish prepends /opt/homebrew/bin, so move our own tools back in front
fish_add_path --global --move --prepend "$HOME/.local/share/mise/shims"
fish_add_path --global --move --prepend "$HOME/.local/bin"
