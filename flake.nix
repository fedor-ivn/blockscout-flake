{
  description = "A flake for Blockscout";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    foundry.url = "github:shazow/foundry.nix/monthly";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      foundry,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        inherit (pkgs.lib) optional optionals;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
          config.allowUnfree = true;
        };

        erlang = pkgs.erlang_27.override {
          version = "27.0";
          sha256 = "sha256-YZWBLcpkm8B4sjoQO7I9ywXcmxXL+Dvq/JYsLsr7TO0=";
        };
        beamPkg = pkgs.beam.packagesWith erlang;
        elixir = beamPkg.elixir_1_17;

        nodejs = pkgs.nodejs-18_x;

        cspell = pkgs.nodePackages_latest.cspell;
      in
      with pkgs;
      {
        devShell = pkgs.mkShell {
          buildInputs =
            [
              elixir
              elixir_ls
              nodejs

              foundry-bin
              postgresql

              electron-chromedriver_31
              glibcLocales
              cspell

              kubectl
              rancher
              cloudflared
            ]
            ++ optional stdenv.isLinux inotify-tools
            # FIXME: doesn't build for Darwin, so you should have it installed manually
            ++ optional stdenv.isLinux ungoogled-chromium
            ++ optional stdenv.isDarwin terminal-notifier
            ++ optionals stdenv.isDarwin (
              with darwin.apple_sdk.frameworks;
              [
                CoreFoundation
                CoreServices
              ]
            );
        };
      }
    );
}

