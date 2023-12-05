{
  description = "Dev flake for C/c++ projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    {
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        self',
        pkgs,
        ...
      }: let
        imports = with inputs;
          [
          ]
          ++ (import ./dependencies_dir {inherit pkgs inputs;});
      in {
        packages.default = pkgs.stdenv.mkDerivation rec {
          name = "C project";
          version = "0.1.0";

          src = ./.;
          buildInputs = with pkgs;
            [
            ]
            ++ (with self'.packages; []);

          /*
          * Run the configuration
          */
          configurePhase =
            /*
            sh
            */
            ''
            '';

          /*
          * Run the meson build
          */
          buildPhase =
            /*
            sh
            */
            ''
            '';

          installPhase = ''
            mkdir -p $out/bin
            cp build_release/src/${name} $out/bin
          '';
        };

        devShells.default = pkgs.mkShell.override {stdenv = pkgs.clangStdenv;} {
          hardeningDisable = ["all"];
          inputsFrom = [];

          buildInputs = with pkgs; [
            lld
            cmake
            just
            meson
            gdb
            bear
          ];

          env = {
            CLANGD_PATH = "${pkgs.clang-tools}/bin/clangd";
            ASAN_SYMBOLIZER_PATH = "${pkgs.llvmPackages_15.bintools-unwrapped}/bin/llvm-symbolizer";
            CXX_LD = "lld";
          };
        };
      };
    };
}
