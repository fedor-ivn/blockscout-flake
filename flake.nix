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
        };

        # erlang = pkgs.erlang_26.override {
        #   version = "26.2.5.1";
        #   sha256 = "sha256-oxOynBFW++igiJtIv1ZjoMgtmumgnsWgwyVx4buhxCo=";
        # };
        erlang = pkgs.erlang_27.override {
          version = "27.0";
          sha256 = "sha256-YZWBLcpkm8B4sjoQO7I9ywXcmxXL+Dvq/JYsLsr7TO0=";
        };
        beamPkg = pkgs.beam.packagesWith erlang;
        # elixir = beamPkg.elixir_1_16;
        elixir = beamPkg.elixir_1_17;
        
        # erlang = pkgs.erlang_25.override {
        #   version = "25.3.2.8";
        #   sha256 = "sha256-oxOynBFd++igiJtIv1ZjoMgtmumgnsWgwyVx4buhxCo=";
        # };
        # elixir = beamPkg.elixir_1_14;

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
              postgresql
              foundry-bin
              kubectl
              cloudflared
              glibcLocales
              ungoogled-chromium
              chromedriver
              cspell
            ]
            ++ optional stdenv.isLinux inotify-tools
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

