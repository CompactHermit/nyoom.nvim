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
                      };
                      doCheck = false;
                    });
                    luajit = super.luajit.override {
                      packageOverrides = luafinal: luaprev: {
                        rtp-nvim = luaprev.rtp-nvim.overrideAttrs {
                          inherit (fetches.rtp-nvim) src;
                        };
                        pathlib-nvim = luaprev.pathlib-nvim.overrideAttrs {
                          inherit (fetches.pathlib) src;
                        };
                        lz-n = luaprev.lz-n.overrideAttrs {
                          inherit (fetches.lz-n) src;
                        };
                        # https://github.com/NixOS/nixpkgs/issues/333761
                        dkjson = luaprev.dkjson.overrideAttrs (oa: {
                          src = self.fetchurl {
                            inherit (oa.src) url;
                            hash = "sha256-JOjNO+uRwchh63uz+8m9QYu/+a1KpdBHGBYlgjajFTI=";
                          };
                        });
                        busted = luaprev.busted.overrideAttrs (oa: {
                          inherit (fetches.busted) src version;
                          knownRockspec = "${fetches.busted.src}/busted-scm-1.rockspec";
                          propagatedBuildInputs =
                            oa.propagatedBuildInputs
                            ++ builtins.attrValues {
                              inherit (luafinal)
                                nlua
                                plenary-nvim
                                nvim-nio
                                pathlib-nvim
                                lua_cliargs
                                ;
                            };
                          nativeBuildInputs = oa.nativeBuildInputs ++ [ super.makeWrapper ];
                          postConfigure = ''
                            substituteInPlace ./busted-scm-1.rockspec \
                               --replace-fail "'lua_cliargs >= 3.0'," ""
                          '';
                          postInstall =
                            oa.postInstall
                            # bash
                            + ''
                              wrapProgram $out/bin/busted --add-flags "--lua=nlua"
                            '';
                        });
                        nvim-nio = luaprev.nvim-nio.overrideAttrs (_: {
                          inherit (fetches.nvim-nio) src;
                          version = "1.10.0-1";
                        });
                        sha1 = luaprev.buildLuarocksPackage {
                          pname = "sha1";
                          src = fetches.sha1.src;
                          version = "scm-1";
                          knownRockspec = "${fetches.sha1.src}/sha1-scm-1.rockspec";
                          disabled = luaprev.luaOlder "5.1";
                        };
                        neturl = luaprev.buildLuarocksPackage rec {
                          pname = "neturl";
                          src = fetches.neturl.src;
                          version = "1.1-1";
                          knownRockspec = "${fetches.neturl.src}/rockspec/net-url-1.1-1.rockspec";
                          disabled = luaprev.luaOlder "5.1";
                        };
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
                    zf
                    selene
                    faith
                    fnlfmt
                    nvfetcher
                    just
                    fenneldoc
                    fennel-unstable-luajit
                    ;
                  #inherit (inputs.zon2nix.packages."${system}") default;
                };
                DIRENV_LOG_FORMAT = ""; # NOTE:: Makes direnv shutup
                FENNEL_PATH = "${pkgs.faith}/bin/?;./src/?.fnl;./src/?/init.fnl";
                FENNEL_MACRO_PATH = "./fnl/macros.fnl;./fnl/util/macros.fnl";
              };
            };
            packages =
              #TODO:: Unshittify this mess, prob with some `lib.fix` stuff
              {
                fnl-linter = pkgs.stdenv.mkDerivation {
                  inherit (fetches.Fnl-linter) name version src;
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
                fenneldoc = pkgs.stdenv.mkDerivation {
                  inherit (fetches.fenneldoc) name version src;
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
                # fennel-language-server = pkgs.rustPlatform.buildRustPackage {
                #   inherit (fetches.fennel-language-server) src pname version;
                #   cargoLock = {
                #     inherit (fetches.fennel-language-server.cargoLock."Cargo.lock") lockFile;
                #     allowBuiltinFetchGit = true;
                #   };
                # };
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
                ztags = pkgs.stdenv.mkDerivation {
                  inherit (fetches.ztags) src pname version;
                  nativeBuildInputs = [
                    pkgs.zig.hook
                  ];
                  zigBuildFlags = [
                    "--release=fast"
                  ];
                  # zigCheckFlags = [
                  #   #"-Dnix=${lib.getExe nix}"
                  # ];
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixfmt-rfc.url = "github:NixOS/nixfmt";
    # zon2nix = {
    #   url = "github:matdibu/zon2nix/add-support-for-git-https-sources";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.flake-parts.follows = "parts";
    # };
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
    fnl-tools = {
      url = "github:m15a/flake-fennel-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
