{
  description = "A flake for Blockscout";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    elixir-overlay.url = "github:zoedsoupe/elixir-overlay";
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
        # elixir-with-otp27 = pkgs.elixir-with-otp pkgs.erlang_27;
        # elixir = elixir-with-otp27."1.19.3";
        # elixir = elixir-bin."1.19.3";
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs =
            [
              elixir-bin."1.19.3"
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

