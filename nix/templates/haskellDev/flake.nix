{
  description = "Haskell Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, parts, ... }@inputs:
    parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      debug = true;
      imports = with inputs; [
        treefmt-nix.flakeModule
        pch.flakeModule
        haskellFlakeProjectModules.default
      ];
      flake = { };
      perSystem = { system, config, pkgs, ... }: {
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            ormolu = {
              enable = true;
              package = pkgs.haskellPackages.fourmolu;
            };
            cabal-fmt.enable = true;
            hlint.enable = true;
          };
          settings = {
            formatter.ormolu = {
              options = [
                "--ghc-opt"
                "-XImportQualifiedPost"
                "--ghc-opt"
                "-XTypeApplications"
              ];
            };
          };
        };

        haskellProjects.default = {
          autoWire = [ "packages" "checks" ];
          devShell.tools = hp: {
            inherit (pkgs) haskell-language-server ghci-dap;
          };
          settings = { };
          location-updates.check = false;
        };

        pre-commit = {
          check.enable = true;
          settings.settings = {
            excludes = [ "flake.lock" "r'.+.age$'" ];
            treefmt.package = config.treefmt.build.wrapper;
          };
          hooks = {
            alejandra.enable = true;
            deadnix.enable = true;
            treefmt.enable = true;
            fourmolu.enable = true;
            hpack.enable = true;
            hlint.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          name = "Haskell Devshells";
          inputsFrom = [
            config.treefmt.build.devShell
            config.pre-commit.devSHell
            config.haskellProjects.default.outputs.devShell
          ];
          packages = [ ];
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
            nu
          '';
        };
      };
    };
}
