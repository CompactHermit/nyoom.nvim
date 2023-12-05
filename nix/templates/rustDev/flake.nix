{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {parts, ...}:
    parts.lib.mkFlake {inherit inputs;} {
      debug = true;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      imports = with inputs; [
        pch.flakeModule
        treefmt.flakeModule
        parts.flakeModules.easyOverlay
      ];
      perSystem = {
        pkgs,
        lib,
        config,
        system,
        ...
      }: let
        nightlyToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain:
          toolchain.default.override {
            extensions = ["rust-src" "rust-analyzer" "rustfmt" "clippy"];
            targets = ["x86_64-unknown-linux-gnu"];
          });
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          overlays = with inputs; [rust-overlay.overlays.default];
          system = system; #needed , fking rust overlay
        };
        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            deadnix.enable = true;
            rustfmt = {
              enable = true;
              package = nightlyToolchain.availableComponents.rustfmt;
            };
          };
        };

        pre-commit = {
          settings = {
            settings = {
              treefmt.package = config.treefmt.build.wrapper;
            };
            hooks = {
              treefmt.enable = true;
              clippy.enable = true;
            };
          };
        };

        # Mold Linker
        devShells.default = pkgs.mkShell.override {stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;} rec {
          name = "addname";
          packages = [nightlyToolchain];
          buildInputs = with pkgs; [fontconfig sccache evcxr];
          inputsFrom = with config; [
            treefmt.build.devShell
            pre-commit.devShell
          ];
          shellHook = let
            storedCargoConfig = pkgs.writeText "config.toml" ''
              [build]
              rustc-wrapper = "${pkgs.sccache}/bin/sccache"
            '';
            CARGO_CONFIG_PATH = CARGO_HOME + "/config.toml";
          in
            /*
            bash
            */
            ''
              echo "buildPhase PWD: $PWD"
              echo "buildPhase out: $out"
              echo "buildPhase ls: $(ls)"
              mkdir -p ${CARGO_HOME}
              cp --remove-destination  ${storedCargoConfig} ${CARGO_CONFIG_PATH}
            '';
          RUST_SRC_PATH = "${nightlyToolchain.availableComponents.rust-src}/lib/rustlib/src/rust/library";
          # LD_LIBRARY_PATH = lib.makeLibraryPath [];
          CARGO_HOME = "/home/CompactHermit/.cargo_${name}";
          SCCACHE_DIR = "/home/CompactHermit/.sccache_${name}";
          # HOME = "/home/CompactHermit";
        };
      };
    };
}
