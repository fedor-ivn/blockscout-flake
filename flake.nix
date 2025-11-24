{
  description = "A flake for Blockscout";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # TODO: uncomment when https://github.com/zoedsoupe/elixir-overlay/pull/2 is merged
    # elixir-overlay.url = "github:zoedsoupe/elixir-overlay";
    elixir-overlay.url = "github:zoedsoupe/elixir-overlay/update-elixir-manifests";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      elixir-overlay
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs.lib) optional optionals;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ elixir-overlay.overlays.default ];
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

              foundry
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

