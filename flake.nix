{
    description = "Custom Nyoom HM-Module";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-utils.url = "github:numtide/flake-utils";
        flake-parts.url = "github:hercules-ci/flake-parts";
        hercules-ci-effects = {
            url = "github:hercules-ci/hercules-ci-effects";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        neovim-nightly-overlay = {
            url = "github:nix-community/neovim-nightly-overlay";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    outputs = {
        self,
        flake-parts,
        ...
    } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
        systems = [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
        ];

        imports = [
            inputs.treefmt-nix.flakeModule
            # inputs.hercules-ci-effects.flakeModule ## Fmt/Flake.lock Actions
            # inputs.flake-parts.flakeModules.easyOverlay
        ];
        flake = {
            homeManagerModules = {
                nyoom = {
                    imports = [
                        ## (fn Nyoom [packages inputs])
                        (import ./nix/modules/nyoom self.packages inputs)
                    ];
                };
            };
            # overlay = {
            #     import = [./nix/overlays];
            # };
            templates = let
                inherit (inputs.nixpkgs) lib;
            in
                ## Ooga Booga spaghetti powers, this is probably not even O(1), rofl
                (lib.attrsets.genAttrs
                 (lib.attrNames
                  (lib.filterAttrs
                   (n: v: v!="regular")
                   (builtins.readDir ./nix/templates)))
                 (name: {path = ./nix/templates/${name}; description = "${name}-Template";}));
        };
        perSystem = {
            pkgs,
            config,
            ...
        }: {
            treefmt = {
                ## https://github.com/numtide/treefmt-nix
                projectRootFile = "flake.nix";
                programs = {
                    alejandra.enable = true;
                    deadnix.enable = true;
                    fnlfmt.enable = true;
                };
            };

            devShells.default = pkgs.mkShell {
                inputsFrom = [
                    config.treefmt.build.devShell
                ];

                nativeBuildInputs = with pkgs; [
                    cmake
                ];
            };
        };
    };
}


