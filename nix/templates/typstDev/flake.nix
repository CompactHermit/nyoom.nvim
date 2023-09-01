{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    typst = {
      url = "github:typst/typst";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst-packages = {
      url = "github:/typst/packages";
      flake = false;
    };

  };
  outputs = {
    self,
    ...
  } @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
        systems = [
            "x86_64-linux"
            "aarch64-linux"
        ];
        flake = {};

        imports = [];


        perSystem = {self',inputs',system,...}:
        let
            pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = with inputs; [
                    typst.overlays.default
                ];
            };
            inherit (pkgs) lib;
            ## Modofy this to whatever sets u want::
            wanted_packages = ["lemmify" "algo"];
            typst-packages = builtins.listToAttrs
            (lib.lists.forEach wanted_packages (package:
                    let
                    drv = pkgs.stdenvNoCC.mkDerivation {
                        pname = "typst-${package}";
                        version = "0.1.0";
                        src = self;
                        installPhase = ''
                            mkdir -p $out/cache/packages/${package}
                            cp -r ${inputs.typst-packages}/packages/preview/${package} $out/cache/packages/
                        '';
                        };
                        in
                        {name = "${package}"; value = drv;}
                        ));
        in {
            packages = {
                docs = pkgs.stdenv.mkDerivation {
                    name = "Test Docs";
                    src = ./.;
                    buildInputs = with pkgs; [
                        typst
                        noto-fonts-cjk-serif
                        fontconfig
                    ];
                };
                default = pkgs.linkFarmFromDrv "Default" [typst-packages.algo typst-packages.lemmify];
                algo = typst-packages.algo;
                lemmify = typst-packages.lemmify;
            };
            devshells = {
                default = pkgs.mkShell {
                    name = "A Generic Typst Devshell, for the sane devs";
                    buildInputs = with pkgs; [typst-lsp typst fontutils python311Packages.brotli];
                };
                nightly = pkgs.mkShell{
                    name = "";
                    buildInputs = with pkgs; [typst-dev] ++ [typst-packages.algo typst-packages.lemmify];
                    ## TODO:: Link Libraries::
                    shellHook = ''
                    '';
                    ## Hacky handling of cache
                    XDG_CACHE_DIR = ./cache;
                };
            };
        };
    };
}
