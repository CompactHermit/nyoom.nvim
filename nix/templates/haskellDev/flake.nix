{
    description = "A basic gomod2nix flake";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        inputs.flake-schemas.url = "github:DeterminateSystems/flake-schemas";
        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

    };
    outputs = {self,...}@inputs:
        inputs.flake-parts.lib.mkFlake {inherit inputs;} {
            systems = ["x86_64-linux" "aarch64-linux"];
            imports = [
                inputs.treefmt-nix.flakeModule
                inputs.haskellFlakeProjectModules.default
            ];
            flake = {
                schemas = inputs.flake-schemas.schemas;
                flakeModule = ./nix/flake-module.nix;
            };
            perSystem = {self', config, pkgs, ...}:
            let
                inherit (pkgs) lib;
            in
            {
                treefmt = {
                    projectRootFile = "flake.nix";
                    programs = {
                        alejandra.enable = true;
                        deadnix.enable = true;
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
                    projectRoot = ./.;
                    projectFlakeName = "Testing Haskell Support";
                    import = [];
                    autowire = ["packages" "checks" "apps"];
                    packages = {
                    ## Add Overrides here
                    };
                    devShell.tools = hp: {
                        inherit (pkgs) haskell-language-server;
                    };
                    settings = {};
                    location-updates.check = false;
                };
                devShells.default =
                    lib.addMetaAttrs {description = "A Generic Haskell Devshell, Batteries Included!";}
                    (pkgs.mkShell {
                        name = "Haskell Devshells";
                        nativeBuildInputs = [
                        ];
                        inputsFrom = [
                            config.treefmt.build.devShell
                            config.haskellProjects.default.outputs.devShell
                        ];
                    });
                packages.appname = "";
            };
        };
}

