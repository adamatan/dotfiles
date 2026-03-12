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

## Known Merge Conflicts

The `flake.nix` has a hardcoded username. When upstream updates that file, expect a trivial one-line conflict on the `user = "..."` line.
