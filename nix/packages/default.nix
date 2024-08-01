{ inputs, self, ... }:
{
  imports = [ inputs.parts.flakeModules.easyOverlay ];
  perSystem =
    {
      pkgs,
      lib,
      self',
      config,
    }:
    {
      overlayAttrs = {
        inherit (self'.packages) neorg-se norg-fmt luarocks-build-fennel;
        default = (
          self: super: {
            inherit (self.packages)
              neorg-se
              norg-fmt
              luarocks-build-fennel
              fnl-Docgen
              fnl-linter
              ;
            lua5_1 = super.lua5_1.override {
              packageOverrides = (lself: lsuper: { inherit (self.packages) neorg-se luarocks-build-fennel; });
            };
          }
        );
      };
    };
  #   perSystem =
  #     {
  #       pkgs,
  #       lib,
  #       self',
  #       config,
  #     #system,
  #     }:
  #     {
  #       _module.args.pkgs = import self.inputs.nixpkgs {
  #         #inherit system;
  #         overlays =
  #           with inputs;
  #           [
  #             fnl-tools.overlays.default
  #             neorocks.overlays.default
  #           ]
  #           ++ [
  #             (_: super: {
  #               tree-sitter = inputs.ts-nightly.legacyPackages."${system}".tree-sitter;
  #               /*
  #                 NOTE: at this point, it'd be better to define our own TS Submodule and hard-link all ts-plugins together.
  #                  Though, we might as well as pass the parsers properly through this. But I want to avoid overlays as much as possible.
  #                  Hmph
  #               */
  #               # vimPlugins = super.vimPlugins.extend (
  #               #   (self: super: {
  #               #     nvim-treesitter = super.nvim-treesitter.overrideAttrs (_: {
  #               #       src = inputs.nvim-treesitter;
  #               #     });
  #               #   })
  #               # );
  #             })
  #           ];
  #       };
  #
  #       packages =
  #         let
  #           fetches = pkgs.callPackage ./deps/plugins/_sources/generated.nix { };
  #         in
  #         #TODO:: Unshittify this mess
  #         {
  #           fnl-linter = pkgs.stdenv.mkDerivation {
  #             name = "Fnl-linter";
  #             src = inputs.fnl-linter;
  #             nativeBuildInputs = builtins.attrValues { inherit (pkgs) lua5_1 fennel; };
  #             configurePhase = ''
  #               substituteInPlace Makefile \
  #               --replace "/usr/lib64/liblua.so"  ${pkgs.lua5_1}/lib/liblua.so \
  #               --replace "/usr/include/lua" ${pkgs.lua5_1}/bin/lua
  #             '';
  #             buildPhase = ''
  #               make binary
  #             '';
  #             installPhase = ''
  #               mkdir -p $out/bin
  #               cp ./check.fnl $out/bin
  #             '';
  #           };
  #           fnl-Docgen = pkgs.stdenv.mkDerivation {
  #             name = "fenneldoc";
  #             version = "0.0.1";
  #             src = inputs.fnl-Docgen;
  #             strictDeps = true;
  #             nativeBuildInputs = builtins.attrValues { inherit (pkgs) fennel; };
  #             configurePhase = ''
  #               substituteInPlace Makefile \
  #               --replace '$(shell git describe --abbrev=0 || "unknown")'  "1.0.1"\
  #               --replace './fenneldoc --config --project-version $(VERSION)' ""
  #             '';
  #             buildPhase = ''
  #               make
  #             '';
  #             installPhase = ''
  #               mkdir -p $out/bin
  #               cp fenneldoc $out/bin
  #             '';
  #           };
  #           luarocks-build-fennel = pkgs.lua51Packages.callPackage (
  #             { buildLuarocksPackage, luaOlder }:
  #             buildLuarocksPackage rec {
  #               inherit (fetches.luarocks-build-fennel) pname src;
  #               version = "scm-1";
  #               knownRockspec = "${fetches.luarocks-build-fennel.src}/rockspecs/luarocks-build-fennel-scm-1.rockspec";
  #               disabled = luaOlder "5.1";
  #             }
  #           ) { };
  #           norg-fmt = pkgs.rustPlatform.buildRustPackage {
  #             inherit (fetches.norg-fmt) pname src version;
  #             cargoLock = {
  #               lockFile = fetches.norg-fmt.cargoLock."Cargo.lock".lockFile;
  #             };
  #           };
  #           neorg-se = pkgs.lua51Packages.callPackage (
  #             {
  #               buildLuarocksPackage,
  #               luaOlder,
  #               luarocks-build-rust-mlua,
  #               telescope-nvim,
  #               rustPlatform,
  #               cargo,
  #             }:
  #             (buildLuarocksPackage rec {
  #               pname = "neorg-se";
  #               version = "scm-1";
  #               src = fetches.neorg-se.src;
  #               knownRockspec = "${fetches.neorg-se.src}/neorg-se-scm-1.rockspec";
  #               disabled = luaOlder "5.1";
  #               propagatedBuildInputs = [
  #                 telescope-nvim
  #                 cargo
  #                 luarocks-build-rust-mlua
  #                 rustPlatform.cargoSetupHook
  #               ];
  #               cargoDeps = rustPlatform.fetchCargoTarball {
  #                 src = src;
  #                 hash = "sha256-uhfgW2OlZEhNwRuZHXuZ2L1zzg8iVSRh54l26p0Bsyg=";
  #               };
  #               postConfigure = ''
  #                 cat ''${rockspecFilename}
  #                 substituteInPlace ''${rockspecFilename} \
  #                     --replace-fail '"neorg ~> 8",' ""
  #               '';
  #               meta = {
  #                 homepage = "https://github.com/benluas/neorg-se";
  #                 description = "The power of a search engine for your Neorg notes";
  #                 license.fullName = "MIT";
  #               };
  #             })
  #           ) { };
  #           #     norgopolis-client-lua = pkgs.rustPlatform.buildRustPackage {
  #           #       pname = "norgopolis-lua";
  #           #       src = inputs.norgopolis-client-lua;
  #           #       version = "0.2.0";
  #           #       buildFeatures = [ "luajit" ];
  #           #       nativeBuildInputs = [ pkgs.protobuf ];
  #           #       cargoLock = {
  #           #         lockFileContents = builtins.readFile ("${inputs.norgopolis-client-lua}" + "/Cargo.lock");
  #           #         allowBuiltinFetchGit = true;
  #           #       };
  #           #       postInstall = ''
  #           #         mkdir -p $out/share/lib/lua/5.1
  #           #         cp $out/lib/libnorgopolis.so $out/lib/lua/5.1
  #           #       '';
  #           #     };
  #         };
  #       # overlayAttrs = {
  #       #   inherit (config.packages) "";
  #       # };
  #     };
}
