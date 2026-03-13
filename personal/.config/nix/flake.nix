{
  description = "Package set for personal macOS machine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
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
