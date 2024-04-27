{
  description = "Dev flake for C/c++ projects";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          config,
          self',
          pkgs,
          ...
        }:
        {
          packages.default = pkgs.stdenv.mkDerivation rec {
            name = "CLOX Interpreter";
            version = "0.1.0";

            src = ./.;
            buildInputs = with pkgs; [ cmake ] ++ (with self'.packages; [ ]);

            configurePhase = "\n";

            buildPhase = "\n";

            installPhase = ''
              mkdir -p $out/bin
              cp build_release/src/${name} $out/bin
            '';
          };

          devShells.default =
            pkgs.mkShell.override { stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv; }
              {
                hardeningDisable = [ "all" ];
                inputsFrom = [ ];
                packages = with pkgs; [
                  #Builds
                  ninja
                  pkg-config
                  cmake
                  just
                  meson
                  bear
                  mold

                  # Debugging
                  gdb
                  gf
                  vim
                  (vscode-extensions.ms-vscode.cpptools.overrideAttrs (_: {
                    meta.unfree = false;
                  }))
                  rr-unstable

                  #Libs
                  glibc.dev
                  libclang.lib
                ];
                CLANGD_PATH = "${pkgs.clang-tools}/bin/clangd";
                CPATH = "${pkgs.libclang.lib}/lib/clang/16/include/";
                LIBCLANG_PATH = "${pkgs.libclang.lib}/lib/clang/16/include";
                ASAN_SYMBOLIZER_PATH = "${pkgs.llvmPackages_latest.bintools-unwrapped}/bin/llvm-symbolizer"; # ASAN
                CXX_LD = "mold"; # FOR DYN LINKER
                C_INCLUDE_PATH = "${pkgs.glibc.dev}/include"; # FOR GCC HEADERS
              };
        };
    };
}
