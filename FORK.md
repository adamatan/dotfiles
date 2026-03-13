# Fork Workflow

This is a fork of [josephschmitt/dotfiles](https://github.com/josephschmitt/dotfiles). This document describes the workflow for staying in sync with upstream while maintaining local customizations.

## Remote Setup

| Remote | Repository | Purpose |
|--------|-----------|---------|
| `origin` | `adamatan/dotfiles` | Your fork (push here) |
| `upstream` | `josephschmitt/dotfiles` | Original repo (pull from here) |

## Branch Strategy

```
upstream/main ──────────────────────────── (josephschmitt's repo)
       |
       +-- main (your fork) ──────────── tracks upstream/main, carries YOUR customizations
       |
       +-- pr/feature-name ───────────── clean branches for PRs back to upstream
```

- **`main`** -- your working branch with local customizations (username changes, extra packages, etc.). Periodically merged from `upstream/main`.
- **`pr/*` branches** -- branched from `upstream/main` (not your `main`), contain ONLY the changes you want to contribute back.

## Day-to-Day Workflow

### Staying in Sync with Upstream

```bash
git fetch upstream
git merge upstream/main
```

### Sending PRs to Upstream

```bash
# Start from upstream's main, NOT your customized main
git fetch upstream
git checkout -b pr/add-cool-feature upstream/main

# Make changes (only the ones you want to contribute)
# ...edit files...

git push -u origin pr/add-cool-feature
gh pr create --repo josephschmitt/dotfiles --head adamatan:pr/add-cool-feature
```

PR branches are based on `upstream/main` so they don't include your personal customizations.

### Quick Reference

| Task | Command |
|------|---------|
| Sync with upstream | `git fetch upstream && git merge upstream/main` |
| Push your changes | `git push origin main` |
| Start a PR for upstream | `git checkout -b pr/topic upstream/main` |
| Submit the PR | `gh pr create --repo josephschmitt/dotfiles --head adamatan:pr/topic` |

## Fresh Machine Setup (Manual Steps)

Steps not covered by `install.sh` or the README — do these once on a new machine.

### 1. Install Nix
```bash
sh <(curl -L https://nixos.org/nix/install)
```

### 2. Install Nix packages
```bash
git add personal/.config/nix/flake.nix  # must be staged
nix --extra-experimental-features "nix-command flakes" profile install ~/dotfiles/personal/.config/nix
```

### 3. Install Homebrew packages
```bash
./personal/bin/brew-install
```

### 4. Install Nerd Fonts (for tmux/neovim icons)
Already included in `brew-install`. If installing manually:
```bash
brew install --cask font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font font-fira-code-nerd-font
```

### 5. Set fish as default shell
```bash
echo /Users/adam/.nix-profile/bin/fish | sudo tee -a /etc/shells
chsh -s /Users/adam/.nix-profile/bin/fish
```

### 6. Install dotfiles
```bash
./install.sh shared personal
```

### 7. Install TPM (tmux plugin manager) and plugins
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Then inside tmux: press `Ctrl-s I` to install plugins.

### 8. Create `~/repos` directory
```bash
mkdir -p ~/repos
```

## Known Merge Conflicts

The `flake.nix` has a hardcoded username. When upstream updates that file, expect a trivial one-line conflict on the `user = "..."` line.

## Personalization Checklist

When this repo was forked, the following identity replacements were made.

### What Was Replaced

| Field | Original (josephschmitt) | Replaced With (adamatan) |
|-------|--------------------------|--------------------------|
| Git name | `Joe Schmitt` / `josephschmitt` | `Adam Matan` |
| Git email (personal) | `dev@joe.sh` | `adam@matan.name` |
| Git email (server) | `josephschmitt@users.noreply.github.com` | `adamatan@users.noreply.github.com` |
| macOS username | `josephschmitt` | `adam` |
| Linux username | `josephschmitt` | `adam` |
| GitHub clone URLs | `josephschmitt/dotfiles` | `adamatan/dotfiles` |
| Raycast extension author | `josephschmitt` | `adamatan` |
| SSH named hosts | `mac-mini`, `krang`, `buntubox` | Removed (Joe's machines) |
| Work submodule | `dotfiles-work-private` | Removed entirely |
| Linear skill example URL | `linear.app/josephschmitt/` | Genericized |

### What Was Intentionally Kept

| Item | Location | Reason |
|------|----------|--------|
| Upstream attribution | `FORK.md` | Documents fork relationship |
| `josephschmitt/pj.nvim` | Neovim plugin specs | GitHub plugin repo, not identity |
| Blog post link & image | `README.md` (`joe.sh`) | Upstream author's content |
| "JoeVim" branding | Neovim dashboard/docs | Upstream branding |
| `joe@synology` | Crontab, README | NAS-specific, not a repo username |
| `hbojoe`, `schmitt.town` | Docker Compose scripts | Joe's project names, not identity |
| Homebrew taps | `darwin.nix` (`josephschmitt/tap`) | Points to Joe's tap repo for `pj` |

### If You Fork This Repo

1. Search for `adamatan` and replace with your GitHub username
2. Search for `adam@matan.name` and replace with your email
3. Search for `/Users/adam/` and `/home/adam/` and replace with your username
4. Update `flake.nix` user field
5. Update `darwin.nix` primaryUser field
6. Update or remove SSH host entries in `.ssh/config-base`
7. Update Raycast extension author in `leader-key/config.json`
8. Remove or update the work submodule in `.gitmodules`
