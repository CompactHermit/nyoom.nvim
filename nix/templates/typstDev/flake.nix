{
  description = "Notes on Category theory, from McClane's and Avodey Reference";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
  outputs = {self, ...} @ inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      flake = {};
      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.mission-control.flakeModule
        inputs.flake-root.flakeModule
      ];
      perSystem = {
        self',
        config,
        pkgs,
        inputs',
        system,
        ...
      }: let
        inherit (pkgs) lib;
        typst-wrapped = pkgs.linkFarm "typst" [
          {
            name = "typst";
            path = "${inputs.typst-packages}";
          }
        ];
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = with inputs; [typst.overlays.default];
        };

        packages = {
          default = pkgs.stdenv.mkDerivation {
            name = "Test Docs";
            src = ./.;
            buildInputs = with pkgs; [typst-dev];
            # TODO:: (CompactHermit) <09/27> Fix this, very broken
            buildPhase = ''
              XDG_CACHE_HOME=${typst-wrapped} ${
                lib.getExe pkgs.typst-dev
              } compile main.typ
            '';
            installPhase = ''
              mkdir $out
              cp ./main.pdf $out/Docs
            '';
          };
        };

        treefmt = {
          inherit (config.flake-root) projectRootFile;
          package = pkgs.treefmt;
          programs = {nixfmt.enable = true;};
        };

        mission-control.scripts = {
          typst_wrapped = {
            description = "A wrapper around typst, with custom XDG_CACHE_HOME";
            exec = ''
              XDG_CACHE_HOME=${typst-wrapped} ${lib.getExe pkgs.typst-dev}
            '';
          };
          treefmt_extend = {
            description = "treefmt autowrapper";
            exec = config.treefmt.build.wrapper;
          };
        };

        devShells = rec {
          default = pkgs.mkShell {
            name = "A Generic Typst Devshell, for the sane devs";
            inherit (nightly) buildInputs;
            shellHook = ''
              zsh
            '';
          };
          nightly = pkgs.mkShell {
            name = "Nightly Branch, needed to test directories and shiz";
            inputsFrom = [
              config.treefmt.build.devShell
              config.mission-control.devShell
              config.flake-root.devShell
            ];
            buildInputs = with pkgs; [typst-lsp typst-fmt];
            ## NOTE:: (CompactHermit) <09/27> Cannot change cache dirs in Shell, will be using a typst-wrapper
            shellHook = ''
              nu
            '';
          };
        };
      };
    };
}
