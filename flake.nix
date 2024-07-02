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
          ./nix/tests
          flakeModule
        ];
        debug = true;
        flake = {
          inherit flakeModule;
          templates =
            let
              inherit (inputs.nixpkgs) lib;
            in
            (lib.attrsets.genAttrs
              (lib.attrNames (lib.filterAttrs (_: v: v != "regular") (builtins.readDir ./nix/templates)))
              (name: {
                path = ./nix/templates/${name};
                description = "${name}-Template";
                welcomeText = ''
                  Welcome ya bloated fuck, ur building a devshell for ${name}, enjoy it .
                '';
              })
            );
        };
        perSystem =
          {
            self',
            lib,
            pkgs,
            config,
            system,
            ...
          }:
          {
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              overlays =
                with inputs;
                [
                  fnl-tools.overlays.default
                  neorocks.overlays.default
                ]
                ++ [
                  (_: super: {
                    tree-sitter = inputs.ts-nightly.legacyPackages."${system}".tree-sitter;
                    /*
                      NOTE: at this point, it'd be better to define our own TS Submodule and hard-link all ts-plugins together.
                       Though, we might as well as pass the parsers properly through this. But I want to avoid overlays as much as possible.
                       Hmph
                    */
                    # vimPlugins = super.vimPlugins.extend (
                    #   (self: super: {
                    #     nvim-treesitter = super.nvim-treesitter.overrideAttrs (_: {
                    #       src = inputs.nvim-treesitter;
                    #     });
                    #   })
                    # );
                  })
                ];
            };
            # TODO: (Hermit) <05/14> cfg.lua.extraRocks be a set of lazy-attrs, and make `extraRocks` build with luajit by-default!
            neohermit = {
              src = inputs.nvim-git;
              plugins = {
                lazy = [
                  "animation"
                  "actions-preview"
                  "alpha"
                  "bufferline"
                  #"bmessages" #Conjure is Better
                  "crates"
                  "clangd_extensions"
                  "nvim-scissors"
                  "nvim-cmp"
                  "colors"
                  "comment"
                  "cmp-nvim-lua"
                  "cmp-dap"
                  "cmp-conjure"
                  "cmp-lspkind"
                  "cmp-luasnip"
                  "cmp-path"
                  "cmp-buffer"
                  "cmp-cmdline"
                  "cmp-nvim-lsp"
                  "cmp-vimtex"
                  "cmp-nvim-lsp-signature-help"
                  "cmp-dap"
                  "cmp-latexsym"
                  "luasnip"
                  "haskell-snippets"
                  "luasnip_snippets"
                  "friendly-luasnip"
                  "cmp-latexsym"
                  "compiler"
                  "conjure"
                  "diffview"
                  "direnv"
                  "dynMacro" # Based
                  "folke_edgy"
                  "folke_trouble"
                  "folke_todo-comments"
                  "folke_noice"
                  "galore"
                  "gitconflict"
                  "gitignore"
                  "grug"
                  "ibl"
                  "iswap"
                  "image-nvim"
                  # "quicknote"
                  "markview"
                  "multicursor"
                  "neogit"
                  "neotest"
                  "neotest-haskell"
                  "neotest-busted"
                  "neotest-python"
                  "neotest-zig"
                  "neorg"
                  "neorg-telescope"
                  "neorg-lines"
                  "neorg-exec"
                  "neorg-interim-ls"
                  "neorg-templates"
                  #"neorg-se"
                  # "neorg-roam"
                  # "neorg-chronicle"
                  # "neorg-timelog"
                  # "neorg-hop-extras"
                  "mini-icons"
                  "nvim-parinfer"
                  "nui-components"
                  "dap"
                  "dapui"
                  "dap-lua"
                  "dap-rr"
                  "dap-python"
                  "nvim-dap-virtual-text"
                  "smuggler"
                  "gitsigns"
                  "go-nvim"
                  "harpoon"
                  "lazydev"
                  "lspconfig"
                  "nonels"
                  "luvit-meta"
                  "libmodal"
                  "lua-utils"
                  "lsp-better-diag"
                  "lsplines"
                  "lspsaga"
                  "resession"
                  "rustaceanvim"
                  "truezen"
                  "ts-error-translator"
                  "tsplayground"
                  "hydra"
                  "hlchunks"
                  "haskellTools"
                  "rainbow-delimiters"
                  "syntax-tree-surfer"
                  "ts-context"
                  "ts-context-commentstring"
                  "ts-refactor"
                  "ts-textobjects"
                  "ts-node-action"
                  "telescope"
                  "telescope_hoogle"
                  "telescope-ui-select"
                  "telescope-file-browse"
                  "telescope-project"
                  "telescope-tabs"
                  "telescope-zoxide"
                  "telescope-egrepify"
                  "tmpclone-nvim"
                  "toggleterm"
                  "ufold"
                  "psa"
                  "octo"
                  "otter"
                  "oqt"
                  "overseer"
                  "oil"
                  "oil-git-status"
                  "pathlib"
                  "profile"
                  "quarto"
                  "quickfix"
                  "reactive"
                  "ratatoskr"
                  "tailwind-tools"
                  "windows"
                  "which-key"
                  "yanky"
                  "yeet"
                  "folke_flash"
                  "matchparens"
                  "nvim-autopairs"
                  "text-case"
                  "zigTools"
                ];
                eager = [
                  "hotpot-nvim"
                  "cyberdream"
                  "moonfly"
                  "nightfox"
                  "nvim-nio" # Needed for Docs, will just igrnore for now
                  "nvim-notify"
                  "nui"
                  "oxocarbon"
                  "sweetie"
                  "wrapping-paper"
                ];
              };
              settings = {
                strip = true;
                bytecompile = true;
                plugins = {
                  neorg = {
                    patches = [
                      (pkgs.fetchpatch {
                        url = "https://github.com/nvim-neorg/neorg/pull/1390.diff";
                        hash = "sha256-F9aZFdFEPiG2NLmwnHrZaiYO6jLF0b8xu9mn8zLf7G8=";
                      })
                      (pkgs.fetchpatch {
                        url = "https://github.com/nvim-neorg/neorg/pull/1528.diff";
                        hash = "sha256-3TfsuZHZlbNM35o6M6bmL5o8pMhlNnXZYmBjBplITm8=";
                      })
                    ];
                  };
                  # bufferline = {
                  #   postInstall = ''
                  #     echo "hello"
                  #   '';
                  # };
                  # neorg = {
                  #   postInstall = ''
                  #     rm -rf $out/queries/norg
                  #     cp -r "${inputs.tree-sitter-norg}"/queries/norg $out/queries
                  #   '';
                  # };
                };
                parsers = {
                  # vala.postPatch = ''
                  #   mv queries/vala/* queries/
                  #   rmdir queries/vala
                  # '';
                  typst.postPatch = # bash
                    ''
                      mv queries/typst/* queries/
                      rmdir queries/typst
                    '';
                  nu.postPatch = # nu
                    ''
                      mv queries/nu/* queries/
                      rmdir queries/nu
                    '';
                };
              };
              lua = {
                extraPacks = builtins.attrValues {
                  inherit (pkgs.lua51Packages)
                    # lgi
                    # toml-edit
                    fidget-nvim
                    fzy
                    ;
                  inherit (inputs.lzn.packages."${system}") lz-n-luaPackage;
                  inherit (self'.packages) neorg-se;
                };
                jit = builtins.attrValues {
                  inherit (pkgs.luajitPackages)
                    magick
                    luarocks
                    nvim-nio
                    middleclass
                    ;
                };
                extraCLibs = builtins.attrValues { inherit (self'.packages) neorg-se; };
              };
              #TODO:: Add Proper Queries
              defaultPlugins = builtins.attrValues { inherit (pkgs.vimPlugins) sqlite-lua plenary-nvim; };
              bins = builtins.attrValues {
                inherit (pkgs)
                  selene
                  ripgrep
                  nvfetcher
                  fd
                  lua-language-server
                  nix-doc
                  ;
                inherit (pkgs.haskellPackages) fast-tags;
                inherit (pkgs.luajitPackages) nlua busted;
                inherit (inputs.nixfmt-rfc.packages."${system}") nixfmt;
                inherit (inputs.nil_ls.packages."${system}") nil;
                stylua = pkgs.stylua.overrideAttrs (_: {
                  cargoBuildFeatures = [ "lua52" ];
                });
                #NOTE: (Hermit) Doesn't work, we can just use the compiled fennel code for Testing
                # busted = pkgs.luajitPackages.busted.overrideAttrs (oa: {
                #   src = inputs.busted-fennel;
                #   knownRockspec = "${inputs.busted-fennel}/busted-scm-1.rockspec";
                #   propagatedBuildInputs =
                #     oa.propagatedBuildInputs
                #     ++ builtins.attrValues { inherit (pkgs.luajitPackages) nlua plenary-nvim; };
                #   nativeBuildInputs = oa.nativeBuildInputs ++ [ pkgs.makeWrapper ];
                #   postInstall =
                #     #oa.postInstall
                #     # bash
                #     ''
                #       wrapProgram $out/bin/busted --add-flags "--lua=nlua"
                #       # --add-flags "--lpath=${pkgs.luajitPackages.plenary-nvim}/lua/?.lua;${pkgs.luajitPackages.plenary-nvim}/lua/?/init.lua"
                #     '';
                # });
                #inherit (pkgs.lua51Packages) lua luarocks;
              };
            };
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
                    fennel-ls
                    fnlfmt
                    nvfetcher
                    just
                    fenneldoc
                    fennel-unstable-luajit
                    ;
                  #inherit (pkgs.texlive.combined) scheme-full;
                };
                DIRENV_LOG_FORMAT = ""; # NOTE:: Makes direnv shutup
                FENNEL_PATH = "${pkgs.faith}/bin/?;./src/?.fnl;./src/?/init.fnl";
                FENNEL_MACRO_PATH = "./fnl/macros.fnl;./fnl/util/macros.fnl";
              };
            };
            packages =
              let
                fetches = pkgs.callPackage ./deps/plugins/_sources/generated.nix { };
              in
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
                #TODO:: move ~> ./nix/packages/*
                norg-fmt = pkgs.rustPlatform.buildRustPackage {
                  inherit (fetches.norg-fmt) pname src version;
                  cargoLock = {
                    lockFile = fetches.norg-fmt.cargoLock."Cargo.lock".lockFile;
                  };
                };
                neorg-se = pkgs.lua51Packages.callPackage (
                  {
                    buildLuarocksPackage,
                    fetchFromGitHub,
                    luaOlder,
                    luarocks-build-rust-mlua,
                    telescope-nvim,
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
                      telescope-nvim
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
                          --replace-fail '"neorg ~> 8",' ""
                    '';
                    meta = {
                      homepage = "https://github.com/benluas/neorg-se";
                      description = "The power of a search engine for your Neorg notes";
                      license.fullName = "MIT";
                    };
                  })
                ) { };
                #     norgopolis-client-lua = pkgs.rustPlatform.buildRustPackage {
                #       pname = "norgopolis-lua";
                #       src = inputs.norgopolis-client-lua;
                #       version = "0.2.0";
                #       buildFeatures = [ "luajit" ];
                #       nativeBuildInputs = [ pkgs.protobuf ];
                #       cargoLock = {
                #         lockFileContents = builtins.readFile ("${inputs.norgopolis-client-lua}" + "/Cargo.lock");
                #         allowBuiltinFetchGit = true;
                #       };
                #       postInstall = ''
                #         mkdir -p $out/share/lib/lua/5.1
                #         cp $out/lib/libnorgopolis.so $out/lib/lua/5.1
                #       '';
                #     };
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
    nil_ls = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #TODO:: TO Fetcher
    nvim-git = {
      url = "github:neovim/neovim";
      flake = false;
    };
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
    neorocks = {
      url = "github:nvim-neorocks/neorocks";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        git-hooks.follows = "pch";
        flake-parts.follows = "parts";
      };
    };
    lzn.url = "github:nvim-neorocks/lz.n/";
    busted-fennel = {
      url = "github:HiPhish/busted/fennel-runner";
      flake = false;
    };
    ts-nightly.url = "github:MangoIV/nixpkgs/mangoiv/update-tree-sitter";
  };
}
