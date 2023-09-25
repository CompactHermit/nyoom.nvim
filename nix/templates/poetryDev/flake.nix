{
  description = "Poetry2nix Builds";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    poetry2nix.url = "github:nix-community/poetry2nix";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      flake = {
      };
      perSystem = {
        pkgs,
        system,
        config,
        ...
      }: let
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [];
        };
        inherit (inputs.poetry2nix.legacyPackages.${system}) mkPoetryApplication defaultPoetryOverrides mkPoetryEnv;
        myPoetryEnv = mkPoetryEnv {
          projectDir = ./.;
          poetrylock = ./.;
          extraPackages = with pkgs; [pip install-tools];
        };
      in {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            isort.enable = true;
            black.enable = true;
          };
        };
        devShells.default = pkgs.mkShell {
          name = "Poetry Tooling Devshells";
          packages = [inputs.poetry2nix.packages.${system}.poetry];
          buildInputs = with pkgs; [python310] ++ [myPoetryEnv];
          inputsFrom = [
            config.treefmt.build.devShell
          ];
          shellHook = ''
          '';
        };

        packages.default = mkPoetryApplication {
          src = ./.;
          projectDir = self;
          overrides =
            defaultPoetryOverrides.extend
            (self: super: {
              pkg_to_override = super.pkg_to_override.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or []) ++ [super.setuptools];
              });
              ## Note:: This will stunt compile times, but the optimization is worth the extra few mins
              mypy = super.mypy.override {
                preferWheel = true;
              };
            });
        };
      };
    };
}
