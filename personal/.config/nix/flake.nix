{
  description = "Package set for personal macOS machine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  # herdr tracks the latest nixpkgs while everything else stays on the older
  # nixpkgs lock. Bump just herdr with `nix flake update nixpkgs-latest`.
  inputs.nixpkgs-latest.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, nixpkgs-latest }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      pkgs-latest = import nixpkgs-latest { inherit system; };
    in
    {
      packages.${system}.default = pkgs.buildEnv {
        name = "personal-env";
        paths = with pkgs; [
          # Shells & prompt
          bash
          fish
          oh-my-posh
          zoxide

          # Editors
          neovim
          tree-sitter

          # Terminal multiplexers
          tmux
          zellij
          sesh
          pkgs-latest.herdr

          # Git
          gh
          lazygit
          delta

          # Search & navigation
          bat
          eza
          fd
          fzf
          ripgrep

          # Dev tools
          bun
          nodejs
          rustup
          uv
          direnv
          stow

          # Nix tooling
          nil
          nixpkgs-fmt

          # GNU userland (replaces macOS BSD tools)
          coreutils
          findutils
          gnused
          gnugrep
          gawk
          gnumake
          diffutils
          wget
          curl

          # Security & encryption
          age
          gnupg

          # Misc CLI
          ffmpeg
          yazi
          atuin
          gum
          terminal-notifier
          television
        ];
      };
    };
}
