{
  description = "A basic deno2nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      flake = {};
      perSystem = {
        pkgs,
        system,
        config,
        ...
      }: let
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
        };
      in {
        treefmt = {
          projectRootFile = "";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            gofmt.enable = true;
          };
        };
        devShells.default = pkgs.mkShell {
          name = "denoDev Devshells";
          nativeBuildInputs = [
          ];
        };
        packages.default = pkgs.stdenvNoCC.mkderivation {
          pname = "denoDev Package";
        };
      };
    };
}
