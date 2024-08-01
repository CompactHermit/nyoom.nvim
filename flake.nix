{
  description = "Nyoom :: Schizo Edition";
  outputs =
    { self, parts, ... }@inputs:
    parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, withSystem, ... }:
      let
        flakeModule =
          let
            inherit (flake-parts-lib) importApply;
          in
          importApply ./nix/flake-modules { inherit self withSystem; };
      in
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
        ];
        imports = [
          flakeModule
          ./nix/tests
          ./nix/templates
          ./nix/hermitM.nix
          # ./nix/packages
        ];
        debug = true;
        flake = {
          inherit flakeModule;
        };
        perSystem =
          {
            self',
            lib,
            pkgs,
            config,
            fetches,
            system,
            ...
          }:
          {
            _module.args = {
              pkgs = import self.inputs.nixpkgs {
                inherit system;
                overlays = with inputs; [
                  vimcats.overlays.default
                  fnl-tools.overlays.default
                  neorocks.overlays.default
                  (self: super: {
                    tree-sitter-nightly = super.rustPlatform.buildRustPackage ({
                      inherit (fetches.tree-sitter) src version pname;
                      inherit (super.tree-sitter)
                        buildInputs
                        nativeBuildInputs
                        patches
                        postInstall
                        passthru
                        ;
                      cargoLock = {
                        inherit (fetches.tree-sitter.cargoLock."Cargo.lock") lockFile;
                        #allowBuiltinFetchGit = true;
                      };

                      doCheck = false;
                    });
                    luajit = super.luajit.override {
                      packageOverrides = luafinal: luaprev: {
                        # https://github.com/NixOS/nixpkgs/issues/333761
                        rtp-nvim = luaprev.rtp-nvim.overrideAttrs {
                          inherit (fetches.rtp-nvim) src;
                        };
                        pathlib-nvim = luaprev.pathlib-nvim.overrideAttrs {
                          inherit (fetches.pathlib) src;
                        };
                        lz-n = luaprev.lz-n.overrideAttrs {
                          inherit (fetches.lz-n) src;
                        };
                        # dkjson = luaprev.dkjson.overrideAttrs (oa: {
                        #   src = self.fetchurl {
                        #     inherit (oa.src) url;
                        #     hash = "sha256-JOjNO+uRwchh63uz+8m9QYu/+a1KpdBHGBYlgjajFTI=";
                        #   };
                        # });
                        busted = luaprev.busted.overrideAttrs (
                          oa:
                          let
                            luaPacks = builtins.attrValues {
                              inherit (luafinal)
                                nlua
                                plenary-nvim
                                nvim-nio
                                pathlib-nvim
                                ;
                            };
                          in
                          {
                            #src = inputs.busted-fennel;
                            #knownRockspec = "${inputs.busted-fennel}/busted-scm-1.rockspec";
                            propagatedBuildInputs = oa.propagatedBuildInputs ++ luaPacks;
                            nativeBuildInputs = oa.nativeBuildInputs ++ [ super.makeWrapper ];
                            postInstall =
                              oa.postInstall
                              # bash
                              + ''
                                wrapProgram $out/bin/busted --add-flags "--lua=nlua"
                              '';
                          }
                        );
                        nvim-nio = luaprev.nvim-nio.overrideAttrs (_: {
                          inherit (fetches.nvim-nio) src;
                          version = "1.10.0-1";
                        });
                      };
                    };
                    luajitPackages = self.luajit.pkgs;
                    lua51Packages = self.lua5_1.pkgs;
                  })
                ];
              };
              fetches = pkgs.callPackage ./deps/plugins/_sources/generated.nix { };
            };
            # TODO: (Hermit) <05/14> cfg.lua.extraRocks be a set of lazy-attrs, and make `extraRocks` build with luajit by-default!
            devShells = {
              default = pkgs.mkShell {
                name = "Hermit:: Dev";
                inputsFrom = with config; [
                  treefmt.build.devShell
                  pre-commit.devShell
                ];
                packages = builtins.attrValues {
                  inherit (pkgs)
                    lua-language-server
                    selene
                    faith
                    fnlfmt
                    nvfetcher
                    just
                    fenneldoc
                    fennel-unstable-luajit
                    ;
                  #inherit (self'.packages) fennel-language-server;
                };
                DIRENV_LOG_FORMAT = ""; # NOTE:: Makes direnv shutup
                FENNEL_PATH = "${pkgs.faith}/bin/?;./src/?.fnl;./src/?/init.fnl";
                FENNEL_MACRO_PATH = "./fnl/macros.fnl;./fnl/util/macros.fnl";
              };
            };
            packages =
              #TODO:: Unshittify this mess
              {
                fnl-linter = pkgs.stdenv.mkDerivation {
                  name = "Fnl-linter";
                  src = inputs.fnl-linter;
                  nativeBuildInputs = builtins.attrValues { inherit (pkgs) lua5_1 fennel; };
                  configurePhase = ''
                    substituteInPlace Makefile \
                    --replace "/usr/lib64/liblua.so"  ${pkgs.lua5_1}/lib/liblua.so \
                    --replace "/usr/include/lua" ${pkgs.lua5_1}/bin/lua
                  '';
                  buildPhase = ''
                    make binary
                  '';
                  installPhase = ''
                    mkdir -p $out/bin
                    cp ./check.fnl $out/bin
                  '';
                };
                fnl-Docgen = pkgs.stdenv.mkDerivation {
                  name = "fenneldoc";
                  version = "0.0.1";
                  src = inputs.fnl-Docgen;
                  strictDeps = true;
                  nativeBuildInputs = builtins.attrValues { inherit (pkgs) fennel; };
                  configurePhase = ''
                    substituteInPlace Makefile \
                    --replace '$(shell git describe --abbrev=0 || "unknown")'  "1.0.1"\
                    --replace './fenneldoc --config --project-version $(VERSION)' ""
                  '';
                  buildPhase = ''
                    make
                  '';
                  installPhase = ''
                    mkdir -p $out/bin
                    cp fenneldoc $out/bin
                  '';
                };
                lzn-auto-require = pkgs.luajitPackages.callPackage (
                  {
                    buildLuarocksPackage,
                    luaOlder,
                    lz-n,
                    fetchurl,
                  }:
                  (buildLuarocksPackage {
                    pname = "lzn-auto-require";
                    src = fetches.lzn-auto-require.src;
                    version = "0.1.0-1";
                    knownRockspec =
                      (fetchurl {
                        url = "https://luarocks.org/manifests/horriblename/lzn-auto-require-0.1.0-1.rockspec";
                        sha256 = "sha256-o7UoO8zqHem8CBuD7BSOt8E7Yl17SM8EgboauT0g3Qc=";
                      }).outPath;
                    disabled = luaOlder "5.1";
                    propagatedBuildInputs = [
                      lz-n
                    ];
                  })
                ) { };
                luarocks-build-fennel = pkgs.lua51Packages.callPackage (
                  { buildLuarocksPackage, luaOlder }:
                  buildLuarocksPackage {
                    inherit (fetches.luarocks-build-fennel) pname src;
                    version = "scm-1";
                    knownRockspec = "${fetches.luarocks-build-fennel.src}/rockspecs/luarocks-build-fennel-scm-1.rockspec";
                    disabled = luaOlder "5.1";
                  }
                ) { };
                fennel-language-server = pkgs.rustPlatform.buildRustPackage {
                  inherit (fetches.fennel-language-server) src pname version;
                  cargoLock = {
                    inherit (fetches.fennel-language-server.cargoLock."Cargo.lock") lockFile;
                    allowBuiltinFetchGit = true;
                  };
                };
                norg-fmt = pkgs.rustPlatform.buildRustPackage {
                  inherit (fetches.norg-fmt) pname src version;
                  cargoLock = {
                    lockFile = fetches.norg-fmt.cargoLock."Cargo.lock".lockFile;
                    allowBuiltinFetchGit = true;
                  };
                };
                neorg-se = pkgs.luajitPackages.callPackage (
                  {
                    buildLuarocksPackage,
                    luaOlder,
                    luarocks-build-rust-mlua,
                    rustPlatform,
                    cargo,
                  }:
                  (buildLuarocksPackage rec {
                    pname = "neorg-se";
                    version = "scm-1";
                    src = fetches.neorg-se.src;
                    knownRockspec = "${fetches.neorg-se.src}/neorg-se-scm-1.rockspec";
                    disabled = luaOlder "5.1";
                    propagatedBuildInputs = [
                      cargo
                      luarocks-build-rust-mlua
                      rustPlatform.cargoSetupHook
                    ];
                    cargoDeps = rustPlatform.fetchCargoTarball {
                      src = src;
                      hash = "sha256-uhfgW2OlZEhNwRuZHXuZ2L1zzg8iVSRh54l26p0Bsyg=";
                    };
                    postConfigure = ''
                      cat ''${rockspecFilename}
                      substituteInPlace ''${rockspecFilename} \
                          --replace-fail '"neorg ~> 8",' ""\
                          --replace-fail '"telescope.nvim",' ""
                    '';
                    meta = {
                      homepage = "https://github.com/benluas/neorg-se";
                      description = "The power of a search engine for your Neorg notes";
                      license.fullName = "MIT";
                    };
                  })
                ) { };
                harper-ls = pkgs.rustPlatform.buildRustPackage {
                  inherit (fetches.harper-ls) pname src version;
                  cargoLock = {
                    lockFile = fetches.harper-ls.cargoLock."Cargo.lock".lockFile;
                  };
                };
              };
          };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    pch = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hci = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #Fucking Christ Zimbatm:: Nix Congressional Member not fking things up and yapping BS <challenge impossible>
    treefmt-nix = {
      #url = "github:numtide/treefmt-nix/fix-214";
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixfmt-rfc.url = "github:NixOS/nixfmt";
    nil_ls = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vimcats = {
      url = "github:mrcjkb/vimcats";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "pch";
        flake-parts.follows = "parts";
      };
    };
    neorocks = {
      url = "github:nvim-neorocks/neorocks";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "pch";
        flake-parts.follows = "parts";
      };
    };
    #TODO:: TO Fetcher
    fnl-linter = {
      url = "github:dokutan/check.fnl";
      flake = false;
    };
    fnl-Docgen = {
      url = "gitlab:andreyorst/fenneldoc";
      flake = false;
    };
    fnl-tools = {
      url = "github:m15a/flake-fennel-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nightly Rocks/New Luarocks ::
  };
}
