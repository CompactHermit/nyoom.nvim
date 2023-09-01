{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rust-overlay = {
        url = "github:oxalica/rust-overlay";
        inputs = {
            nixpkgs.follows = "nixpkgs";
            flake-utils.follows = "flake-utils";
        };
    };
    ## Bloated POS
    flake-utils.url = "github:numtide/flake-utils";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, flake-utils, crane, ... }:
    let
      # Generate the typst package for the given nixpkgs instance.
      packageFor = pkgs:
        let
          inherit (pkgs) lib;
          Cargo-toml = lib.importTOML ./Cargo.toml;

          pname = "Choose a pkgs name";
          version = Cargo-toml.workspace.package.version;

          craneLib = crane.mkLib pkgs;

          ## Probably should use flake-roots, else flake-filter might be cleaner to look at::
          src = lib.sourceByRegex ./. [
            "(assets|tests|crate)(/.*)"
            ''Cargo\.(toml|lock)''
            ''build\.rs''
          ];

          commonCraneArgs = {
            inherit src pname version;

            ## For mac, becuase fuck you apple::
            buildInputs = lib.optionals pkgs.stdenv.isDarwin [
              pkgs.darwin.apple_sdk.frameworks.CoreServices
            ];

            nativeBuildInputs = [ pkgs.installShellFiles ];
          };

          cargoArtifacts = craneLib.buildDepsOnly commonCraneArgs;

          my-app = craneLib.buildPackage (commonCraneArgs // {
            inherit cargoArtifacts;

            postInstall = ''
            '';

            GEN_ARTIFACTS = "artifacts";
          });
        in
        my-app;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      flake = {
          overlays.default = _: prev: {
              my-app_overlay = packageFor prev;
          };
      };

      perSystem = { pkgs, ... }:
        let
          my-app = packageFor pkgs;
          inherit (pkgs) lib;
          rustToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
                  extensions = [ "rust-src" "rust-analyzer" ];
                  targets = [ "x86_64-unknown-linux-gnu" ];
                  });
         commonBuildInputs = with pkgs; [
             nil
         ];
        in
        {
          packages.default = my-app;

          apps.default = flake-utils.lib.mkApp {
            drv = my-app;
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              rustToolchain
              rustc
              cargo
              (lib.optionals pkgs.stdenv.isLinux pkgs.mold) ## Faster Link times
            ];
            buildInputs = [commonBuildInputs] ++
                lib.optionals pkgs.stdenv.isDarwin [
                pkgs.darwin.apple_sdk.frameworks.CoreServices
                    pkgs.libiconv
                ];
            ## Env Vars::
            RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
            LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.openssl pkgs.gmp ];
          };
        };
    };
}
