# Mac Studio (Elad's machine, shared with other users) environment for POSIX shells

# Tools live in ~/.local (mise, release binaries), never in Elad's /opt/homebrew.
# Prepend after the shared exports so they win over Homebrew.
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
