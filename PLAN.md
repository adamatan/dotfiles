# Dotfiles Stow Plan

Checklist to stow — or explicitly ignore with reason — every entry in `shared/.stow-local-ignore` and `personal/.stow-local-ignore`.

> ⚠️ **Conflict** = a file/dir already exists at the target path on this machine and must be removed or merged before stowing.

---

## Packages to Add

- [ ] `age` — modern file encryption tool (simpler alternative to GPG for encrypting secrets/files)
- [ ] `gnupg` — GNU Privacy Guard; GPG key management, signing commits, encrypting files
- [ ] `tree` — display directory structure as a tree (note: `eza --tree` already available via `tree` alias)

---

## Enhancements

- [ ] Go over Ubuntu packages — review `ubuntu-server/` stow profile; ensure Nix packages, shell config, and tools are up to date for the server setup
- [ ] Add `make ubuntu` target — stow target for `shared ubuntu-server` profile, parallel to `make dotfiles`
- [ ] Improve README — reflect new repo structure (personal/shared/ubuntu-server profiles, Nix flake, Makefile), keep attribution to Joe Schmitt, consolidate installation steps into a single section
- [ ] Simplify installation steps — collapse multi-step fresh machine setup (Nix, brew, manual, stow) into one place; cross-reference `FORK.md` and `Makefile` targets
- [ ] Unify shell history across processes — configure fish and zsh to share a single history file, and enable history sync across concurrent sessions (e.g. via `atuin`, which is already in the Nix flake)

---

## `shared/` — Not Yet Stowed

- [ ] `.ssh` ⚠️ conflict: `~/.ssh` exists
  - **Dir**: `shared/.ssh/`
  - **Purpose**: SSH client configuration
  - **Config**: `config-base` with a single `Host *` block (defaults: no strict host checking on new hosts, forwarding settings). Personal host entries were removed.
  - **Action needed**: Decide whether to stow — contains no secrets but is sensitive. Consider stowing only `config-base` and symlinking manually.

- [ ] `.claude` ⚠️ conflict: `~/.claude` exists
  - **Dir**: `shared/.claude/`
  - **Purpose**: Claude Code CLI configuration (skills, settings)
  - **Config**: Skills directory with custom slash commands (e.g. implement-linear-issue). Ignored to avoid syncing API keys or session state.
  - **Action needed**: Stow or keep ignored. Skills are safe; settings may contain tokens.

- [ ] `.config/astronvim` — no conflict
  - **Dir**: `shared/.config/astronvim/`
  - **Purpose**: AstroNvim — 3rd Neovim config (launched via `astrovim` alias)
  - **Config**: Full AstroNvim v5+ setup with AstroCommunity plugins, AstroCore/AstroLSP/AstroUI overrides. Completely isolated from kickstart and lazyvim configs.
  - **Action needed**: Stow if you want to use AstroNvim.

- [ ] `.config/helix` — no conflict
  - **Dir**: `shared/.config/helix/`
  - **Purpose**: Helix modal editor (secondary editor, simpler than Neovim)
  - **Config**: Catppuccin Mocha theme, relative line numbers, 100-char ruler. LSP for TS/Rust/Python. Yazi file picker (`Space+e`), lazygit (`Space+l`), tmux pane navigation (`Ctrl+hjkl`).
  - **Action needed**: Stow if you want to use Helix.

- [ ] `.config/leader-key` — no conflict
  - **Dir**: `shared/.config/leader-key/`
  - **Purpose**: Leader Key — macOS keyboard-driven app launcher
  - **Config**: Groups: `a` apps (Ghostty, Slack…), `b` browsers, `e` editors, `f` Finder folders, `m` music control, `r` Raycast, `w` window management (Moom layouts).
  - **Action needed**: Stow. No secrets. Update paths/apps to match your setup first.

- [ ] `.config/mcphub` — no conflict
  - **Dir**: `shared/.config/mcphub/`
  - **Purpose**: MCP Hub — MCP server manager for Neovim (mcphub.nvim)
  - **Config**: `servers.json` with Context7 remote MCP server (live code docs for LLMs). Auto-approve enabled.
  - **Action needed**: Stow if using mcphub.nvim plugin in Neovim.

- [ ] `.config/nix-darwin` ⚠️ conflict: `~/.config/nix-darwin` exists
  - **Dir**: `shared/.config/nix-darwin/`
  - **Purpose**: nix-darwin — macOS system-level Nix configuration
  - **Config**: System packages, services, machine-specific configs for mac-mini and work machines.
  - **Action needed**: Keep ignored. You use the simpler Nix package flake (`personal/.config/nix`) instead of nix-darwin.

- [ ] `.config/television` ⚠️ conflict: `~/.config/television` exists
  - **Dir**: `shared/.config/television/`
  - **Purpose**: Television — fast fuzzy finder (alternative to fzf)
  - **Config**: Local copy exists at `~/.config/television`. Merge before stowing.
  - **Action needed**: Compare local vs repo config, merge, then stow.

- [ ] `.config/workmux` — no conflict
  - **Dir**: `shared/.config/workmux/`
  - **Purpose**: workmux — tmux workspace manager for development sessions
  - **Config**: Window prefix `wm-`, default layout with nvim (focused) + Claude agent pane + small vertical split. Uses Nerd Fonts, agent set to `claude`.
  - **Action needed**: Stow if using workmux.

- [ ] `.config/zed` — no conflict
  - **Dir**: `shared/.config/zed/`
  - **Purpose**: Zed editor — high-performance Rust-based editor
  - **Config**: Vim mode, space-leader keymaps, Claude Sonnet 4 + Copilot AI, lazygit (`Space+g g`), Catppuccin Mocha theme, JetBrains Mono font. Format on save disabled.
  - **Action needed**: Stow if using Zed.

- [ ] `.config/zellij` — no conflict
  - **Dir**: `shared/.config/zellij/`
  - **Purpose**: Zellij — modern terminal multiplexer (tmux alternative)
  - **Config**: Vim-style navigation (`hjkl`), Catppuccin Macchiato theme, zjstatus bar with git/datetime, autolock when entering nvim/fzf/git/zoxide. Two configs: with and without autolock.
  - **Action needed**: Stow if using Zellij.

---

## `personal/` — Not Yet Stowed

- [ ] `.ssh` ⚠️ conflict: `~/.ssh` exists
  - **Dir**: `personal/.ssh/` *(if exists)*
  - **Purpose**: Personal SSH keys/config overrides
  - **Action needed**: Check contents; keep ignored if it contains private keys.

- [ ] `.claude` ⚠️ conflict: `~/.claude` exists
  - **Dir**: `personal/.claude/`
  - **Purpose**: Personal Claude Code config (skills, CLAUDE.md, settings)
  - **Config**: Personal skills directory. May contain API keys or session tokens.
  - **Action needed**: Stow skills only; keep settings ignored.

- [ ] `bin` ⚠️ conflict: `~/bin` exists
  - **Dir**: `personal/bin/`
  - **Purpose**: Personal scripts (`brew-install`, `manual-install`, `immich-sync`)
  - **Config**: Install scripts for this machine. Safe to stow.
  - **Action needed**: Merge `~/bin` into `personal/bin/`, then stow.

- [ ] `.gitconfig` ⚠️ conflict: `~/.gitconfig` exists
  - **Dir**: `personal/.gitconfig`
  - **Purpose**: Personal git identity (name, email, GPG signing key)
  - **Config**: Name: Adam Matan, email: adam@matan.name, GPG key `12B06DB2D8C232B740CD3E0F789AFB08DA8A8308`, `gpgSign = true`.
  - **Action needed**: Remove or back up local `~/.gitconfig`, then stow.

- [ ] `.config/immich-sync` — no conflict
  - **Dir**: `personal/.config/immich-sync/`
  - **Purpose**: Immich photo sync — syncs local photos to self-hosted Immich instance
  - **Config**: Template only (`config.example`). Actual config needs `IMMICH_URL` and `IMMICH_API_KEY` filled in — never commit those values.
  - **Action needed**: Stow the template; fill in values in the live config file separately.

- [ ] `.config/opencode` ⚠️ conflict: `~/.config/opencode` exists
  - **Dir**: `personal/.config/opencode/`
  - **Purpose**: OpenCode — AI coding assistant config
  - **Config**: Local copy exists at `~/.config/opencode`. Compare before stowing.
  - **Action needed**: Compare local vs repo, merge, then stow.

- [ ] `.config/pj` *(permanent ignore)*
  - **Dir**: `personal/.config/pj/`
  - **Purpose**: `pj` project-jump tool — search paths are machine-specific
  - **Config**: Searches `~/development` and `~/dotfiles`.
  - **Action needed**: **Never stow.** Already marked permanent in ignore file.
