{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android = {
      url = "github:tadfisher/android-nixpkgs/canary";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ parts, ... }:
    parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      imports = with inputs; [
        pch.flakeModule
        treefmt.flakeModule
        parts.flakeModules.easyOverlay
      ];
      perSystem =
        {
          pkgs,
          lib,
          config,
          system,
          ...
        }:

        {
          _module.args.pkgs = import inputs.nixpkgs {
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
              android_sdk.accept_license = true;
            };
            overlays = with inputs; [ android.overlays.default ];
            system = system; # needed , fking rust overlay
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt-rfc-style.enable = true;
            };
          };

          pre-commit = {
            settings = {
              settings = {
                treefmt.package = config.treefmt.build.wrapper;
              };
              hooks = {
                treefmt.enable = true;
              };
            };
          };

          devShells.default =
            let
              androidSdk = (
                inputs.android.sdk.${system} (
                  sdkPkgs: with sdkPkgs; [
                    cmdline-tools-latest
                    build-tools-34-0-0
                    platform-tools
                    platforms-android-34
                    emulator
                    ndk-26-1-10909125
                    skiaparser-3
                    cmake-3-18-1
                    sources-android-34
                    system-images-android-34-google-apis-playstore-x86-64
                  ]
                )
              );
            in
            pkgs.mkShell {
              name = "Kotlin";
              packages =
                [ androidSdk ]
                ++ (__attrValues {
                  inherit (pkgs)
                    kotlin-language-server
                    ktlint
                    gradle
                    openjdk17_headless
                    apk-tools
                    zlib
                    yasm
                    eza
                    firebase-tools
                    ;
                  inherit (pkgs.androidStudioPackages) canary;
                });
              inputsFrom = with config; [
                treefmt.build.devShell
                pre-commit.devShell
              ];
              ANDROID_HOME = "${androidSdk}/share/android-sdk";
              ANDROID_SDK_ROOT = "${androidSdk}/share/android-sdk";
              GRADLE_USER_HOME = "/tmp";
              ANDROID_SDK_HOME = "/tmp/.android";
              JAVA_HOME = pkgs.jdk.home;
              allowUnfree = true;
            };
        };
    };
}
