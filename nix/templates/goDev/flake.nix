{
  description = "A basic gomod2nix flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [ inputs.treefmt-nix.flakeModule ];
      flake = { };
      perSystem =
        {
          self',
          pkgs,
          system,
          config,
          ...
        }:

        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
          };
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              alejandra.enable = true;
              deadnix.enable = true;
              gofmt.enable = true;
            };
          };
          devShells.default = pkgs.mkShell {
            name = "goDev Devshells";
            packages = [ ];
            shellHook = ''
              export XDG_CACHE_HOME=$(mktemp -d)
              #export XDG_DATA_HOME=$(mktemp -d)
              export XDG_STATE_HOME=$(mktemp -d)
            '';
          };
          packages.default = pkgs.buildGoApplication {
            pname = "goDev Package";
            version = "0.1";
          };
        };
    };
}
