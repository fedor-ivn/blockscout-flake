{
  description = "A flake for Blockscout";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    foundry.url = "github:shazow/foundry.nix/monthly";
    elixir-overlay.url = "github:zoedsoupe/elixir-overlay/update-elixir-manifests";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      foundry,
      elixir-overlay
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs.lib) optional optionals;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ 
            foundry.overlay 
            elixir-overlay.overlays.default
          ];
          config.allowUnfree = true;
        };

        cspell = pkgs.nodePackages_latest.cspell;
        elixir = pkgs.elixir-bin."1.19.3";
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs =
            [
              elixir
              elixir-ls
              nodejs

              foundry-bin
              postgresql

              electron-chromedriver
              glibcLocales
              cspell

              kubectl
              rancher
              cloudflared
            ]
            ++ optional stdenv.isLinux inotify-tools
            # FIXME: doesn't build for Darwin, so you should have it installed manually
            ++ optional stdenv.isLinux ungoogled-chromium
            ++ optional stdenv.isDarwin terminal-notifier;
        };
      }
    );
}

