{
    description = "A basic gomod2nix flake";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
        gomod2nix.url = "github:nix-community/gomod2nix";
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
            ];
            flake = {};
            perSystem = {self',inputs',system,config,...}:
                let
                pkgs = import inputs.nixpkgs {
                    inherit system;
                    overlays = [ inputs.gomod2nix.overlays.default ];
                };
                goVersion = 20;
                goEnv = pkgs.mkGoEnv { pwd = ./.; };
                in {
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
                        nativeBuildInputs = [
                            goEnv
                            pkgs.gomod2nix
                        ];

                    };
                    packages.default = pkgs.buildGoApplication {
                        pname = "goDev Package";
                        version = "0.1";
                        modules = ./gomod2nix.toml;
                        go = "${goVersion}";
                    };
                };
        };
}

