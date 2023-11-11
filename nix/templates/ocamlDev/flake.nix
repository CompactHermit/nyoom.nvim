{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opam2nix = {
      url = "github:timbertson/opam2nix";
      flake = false; # TODO:: Just rewrite a flake-parts mod for this, the fact that we need to import is so fucking stupid
    };
  };
  outputs = {
    self,
    parts,
    ...
  } @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        inputs.treefmt.flakeModule
        inputs.pch.flakeModule
      ];
      flake = {};
      perSystem = {
        system,
        config,
        pkgs,
      }: let
      in {
      };
    };
}
