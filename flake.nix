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
                    vimPlugins = super.vimPlugins.extend (
                      (self: super: {
                        nvim-treesitter = super.nvim-treesitter.overrideAttrs (_: {
                          src = inputs.nvim-treesitter;
                        });
                      })
                    );
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
                  "nvim-cmp"
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
                  "quicknote"
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
                  "neorg-chronicle"
                  "neorg-exec"
                  "neorg-roam"
                  "neorg-interim-ls"
                  "neorg-timelog"
                  "neorg-hop-extras"
                  "nvim-webdev-icons"
                  # "nvim-material-icons"
                  "nvim-parinfer"
                  "nui-components"
                  "dap"
                  "dapui"
                  "dap-lua"
                  "dap-rr"
                  "dap-python"
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
                  "lsplines"
                  "lspsaga"
                  "resession"
                  "rustaceanvim"
                  "truezen"
                  "ts-error-translator"
                  "tsplayground"
                  "hydra"
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
                  "haskell-snippets"
                  "luasnip_snippets"
                  "molten"
                  "nightfox"
                  "nvim-nio" # Needed for Docs, will just igrnore for now
                  "nvim-notify"
                  "nvim-dap-virtual-text"
                  "nvim-scissors"
                  "nu-syntax"
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
              };
              lua = {
                extraPacks = builtins.attrValues {
                  inherit (pkgs.lua51Packages)
                    lgi
                    toml-edit
                    middleclass
                    fidget-nvim
                    nvim-nio
                    fzy
                    ;
                  inherit (inputs.lzn.packages."${system}") lz-n-luaPackage;
                };
                jit = builtins.attrValues { inherit (pkgs.luajitPackages) magick luarocks; };
              };
              #TODO:: Add Proper Queires
              extraParsers = [
                "ada"
                "cabal"
                "gleam"
                "just"
                # "norg"
                "norg-meta"
                "nim"
                "nu"
                "vimdoc"
                "roc"
                "typst"
              ];
              defaultPlugins = builtins.attrValues {
                inherit (pkgs.vimPlugins) sqlite-lua mini-nvim plenary-nvim;
              };
              bins = builtins.attrValues {
                inherit (pkgs)
                  selene
                  ripgrep
                  #nil
                  fd
                  lua-language-server
                  nix-doc
                  ;
                inherit (pkgs.haskellPackages) fast-tags;
                inherit (pkgs.luajitPackages) nlua;
                inherit (inputs.nixfmt-rfc.packages."${system}") nixfmt;
                inherit (inputs.nil_ls.packages."${system}") nil;
                stylua = pkgs.stylua.overrideAttrs (_: {
                  cargoBuildFeatures = [ "lua52" ];
                });
                #NOTE: (Hermit) Doesn't work
                busted = pkgs.luajitPackages.busted.overrideAttrs (_: {
                  knownRockspec = "${inputs.busted-fennel}/busted-scm-1.rockspec";
                  src = inputs.busted-fennel;
                });
                #inherit (pkgs.lua51Packages) lua luarocks;
              };
            };
            devShells = {
              default = pkgs.mkShell {
                name = "Hermit:: Dev";
                #TODO: https://github.com/rktjmp/hotpot.nvim/issues/125 .hotpot.lua as shellhook
                # shellHook = ''
                #     ln - s
                # '';
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
                    just
                    fenneldoc
                    fennel-unstable-luajit
                    ;
                  inherit (pkgs.texlive.combined) scheme-full;
                };
                DIRENV_LOG_FORMAT = ""; # NOTE:: Makes direnv shutup
                FENNEL_PATH = "${pkgs.faith}/bin/?;./src/?.fnl;./src/?/init.fnl";
                FENNEL_MACRO_PATH = "./fnl/macros.fnl;./fnl/util/macros.fnl";
              };
            };
            packages = {
              fnl-linter = pkgs.stdenv.mkDerivation {
                name = "Fnl-linter";
                src = inputs.fnl-linter;
                nativeBuildInputs = builtins.attrValues { inherit (pkgs) lua5_4_compat fennel; };
                configurePhase = ''
                  substituteInPlace Makefile \
                  --replace "/usr/lib64/liblua.so"  ${pkgs.lua5_4_compat}/lib/liblua.so \
                  --replace "/usr/include/lua" ${pkgs.lua5_4_compat}/bin/lua
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
              norg-fmt = pkgs.rustPlatform.buildRustPackage {
                pname = "norg-fmt";
                src = inputs.norg-fmt;
                version = "1.1.0";
                cargoLock = {
                  # VHYRO STOP USING GIT DEPS U FKING BASTARD!!!!!!!
                  lockFileContents = builtins.readFile ("${inputs.norg-fmt}" + "/Cargo.lock");
                  allowBuiltinFetchGit = true;
                };
              };
              norgopolis-client-lua = pkgs.rustPlatform.buildRustPackage {
                pname = "norgopolis-lua";
                src = inputs.norgopolis-client-lua;
                version = "0.2.0";
                buildFeatures = [ "luajit" ];
                nativeBuildInputs = [ pkgs.protobuf ];
                cargoLock = {
                  lockFileContents = builtins.readFile ("${inputs.norgopolis-client-lua}" + "/Cargo.lock");
                  allowBuiltinFetchGit = true;
                };
                postInstall = ''
                  mkdir -p $out/share/lib/lua/5.1
                  cp $out/lib/libnorgopolis.so $out/lib/lua/5.1
                '';
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
    nvim-git = {
      url = "github:neovim/neovim";
      flake = false;
    };
    norg-fmt = {
      url = "github:nvim-neorg/norg-fmt";
      flake = false;
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

    #NOTE: (Hermit) Make these npins
    #VimPlugins::
    actions-preview = {
      url = "github:aznhe21/actions-preview.nvim";
      flake = false;
    };
    animation = {
      url = "github:anuvyklack/animation.nvim";
      flake = false;
    };
    alpha = {
      url = "github:goolord/alpha-nvim";
      flake = false;
    };
    bmessage = {
      url = "github:ariel-frischer/bmessages.nvim";
      flake = false;
    };
    bufferline = {
      url = "github:akinsho/bufferline.nvim/";
      flake = false;
    };
    csharp = {
      url = "github:iabdelkareem/csharp.nvim";
      flake = false;
    };
    crates = {
      url = "github:saecki/crates.nvim";
      flake = false;
    };
    clangd_extensions = {
      url = "github:p00f/clangd_extensions.nvim";
      flake = false;
    };
    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-conjure = {
      url = "github:PaterJason/cmp-conjure";
      flake = false;
    };
    cmp-lspkind = {
      url = "github:onsails/lspkind.nvim";
      flake = false;
    };
    cmp-luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-cmdline = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-nvim-lua = {
      url = "github:hrsh7th/cmp-nvim-lua";
      flake = false;
    };
    cmp-vimtex = {
      url = "github:micangl/cmp-vimtex";
      flake = false;
    };
    cmp-nvim-lsp-signature-help = {
      url = "github:hrsh7th/cmp-nvim-lsp-signature-help";
      flake = false;
    };
    cmp-dap = {
      url = "github:rcarriga/cmp-dap";
      flake = false;
    };
    cmp-latexsym = {
      url = "github:kdheepak/cmp-latex-symbols";
      flake = false;
    };
    luasnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    friendly-luasnip = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };
    comment = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    compiler = {
      url = "github:Zeioth/compiler.nvim";
      flake = false;
    };
    conjure = {
      url = "github:Olical/conjure";
      flake = false;
    };
    diffview = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };
    dapui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    dap-lua = {
      url = "github:jbyuki/one-small-step-for-vimkind";
      flake = false;
    };
    dap-rr = {
      url = "github:jonboh/nvim-dap-rr";
      flake = false;
    };
    dap-python = {
      url = "github:mfussenegger/nvim-dap-python";
      flake = false;
    };
    dynMacro = {
      url = "github:tani/dmacro.nvim";
      flake = false;
    };
    direnv = {
      url = "github:direnv/direnv.vim";
      flake = false;
    };
    flutter-tools = {
      url = "github:akinsho/flutter-tools.nvim";
      flake = false;
    };
    gitconflict = {
      url = "github:akinsho/git-conflict.nvim";
      flake = false;
    };
    gitignore = {
      url = "github:wintermute-cell/gitignore.nvim";
      flake = false;
    };
    galore = {
      url = "github:dagle/galore";
      flake = false;
    };
    gitsigns = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    go-nvim = {
      url = "github:ray-x/go.nvim";
      flake = false;
    };
    grug = {
      url = "github:MagicDuck/grug-far.nvim/";
      flake = false;
    };
    harpoon = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    haskellTools = {
      url = "github:mrcjkb/haskell-tools.nvim";
      flake = false;
    };
    haskell-snippets = {
      url = "github:mrcjkb/haskell-snippets.nvim";
      flake = false;
    };
    hotpot-nvim = {
      url = "github:rktjmp/hotpot.nvim";
      flake = false;
    };
    hover-nvim = {
      url = "github:lewis6991/hover.nvim";
      flake = false;
    };
    ibl = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    hlchunks = {
      url = "github:shellRaining/hlchunk.nvim";
      flake = false;
    };
    hydra = {
      url = "github:nvimtools/hydra.nvim";
      flake = false;
    };

    lazydev = {
      url = "github:folke/lazydev.nvim";
      flake = false;
    };
    luvit-meta = {
      url = "github:Bilal2453/luvit-meta";
      flake = false;
    };
    #Marry Me
    libmodal = {
      url = "github:Iron-E/nvim-libmodal";
      flake = false;
    };
    litee = {
      url = "github:ldelossa/litee-calltree.nvim";
      flake = false;
    };
    lua-utils = {
      url = "github:nvim-neorg/lua-utils.nvim";
      flake = false;
    };
    luasnip_snippets = {
      url = "github:mireq/luasnip-snippets";
      flake = false;
    };
    lsplines = {
      url = "git+https://git.sr.ht/~whynothugo/lsp_lines.nvim";
      flake = false;
    };
    lspsaga = {
      url = "github:nvimdev/lspsaga.nvim";
      flake = false;
    };
    molten = {
      url = "github:benlubas/molten-nvim";
      flake = false;
    };
    markview = {
      url = "github:OXY2DEV/markview.nvim";
      flake = false;
    };
    multicursor = {
      url = "github:smoka7/multicursors.nvim";
      flake = false;
    };
    nightfox = {
      url = "github:EdenEast/nightfox.nvim";
      flake = false;
    };
    norgopolis-client-lua = {
      url = "github:nvim-neorg/norgopolis-client.lua";
      flake = false;
    };
    neotest = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };
    neotest-busted = {
      url = "gitlab:HiPhish/neotest-busted";
      flake = false;
    };
    neotest-zig = {
      url = "github:lawrence-laz/neotest-zig";
      flake = false;
    };
    neotest-haskell = {
      url = "github:mrcjkb/neotest-haskell";
      flake = false;
    };
    # neotest-rust = {
    #   url = "github:rouge8/neotest-rust";
    #   flake = false;
    # };
    neotest-python = {
      url = "github:nvim-neotest/neotest-python";
      flake = false;
    };
    neogit = {
      url = "github:NeogitOrg/neogit/";
      flake = false;
    };
    neorg = {
      url = "github:nvim-neorg/neorg";
      flake = false;
    };
    neorg-lines = {
      url = "github:benlubas/neorg-conceal-wrap";
      flake = false;
    };
    neorg-telescope = {
      url = "github:nvim-neorg/neorg-telescope";
      flake = false;
    };
    neorg-exec = {
      url = "github:laher/neorg-exec";
      flake = false;
    };
    neorg-interim-ls = {
      url = "github:benlubas/neorg-interim-ls/";
      flake = false;
    };
    neorg-roam = {
      url = "github:Jarvismkennedy/neorg-roam.nvim";
      flake = false;
    };
    neorg-timelog = {
      url = "github:phenax/neorg-timelog";
      flake = false;
    };
    neorg-hop-extras = {
      url = "github:phenax/neorg-hop-extras";
      flake = false;
    };
    image-nvim = {
      url = "github:3rd/image.nvim";
      flake = false;
    };
    quicknote = {
      url = "github:RutaTang/quicknote.nvim";
      flake = false;
    };
    # nfnl = {
    #   url = "github:Olical/nfnl";
    #   flake = false;
    # };
    nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    nvim-scissors = {
      url = "github:chrisgrieser/nvim-scissors";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    nvim-notify = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };
    nvim-nu = {
      url = "github:lhkipp/nvim-nu";
      flake = false;
    };
    nu-syntax = {
      url = "github:elkasztano/nushell-syntax-vim";
      flake = false;
    };
    nui = {
      url = "github:ofseed/nui.nvim";
      flake = false;
    };
    nui-components = {
      url = "github:grapp-dev/nui-components.nvim";
      flake = false;
    };
    neorg-chronicle = {
      url = "github:MartinEekGerhardsen/neorg-chronicle";
      flake = false;
    };
    octo = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    otter = {
      url = "github:benlubas/otter.nvim/feat/remove_leading_whitespace/";
      flake = false;
    };
    oil = {
      url = "github:stevearc/oil.nvim/";
      flake = false;
    };
    overseer = {
      url = "github:stevearc/overseer.nvim/";
      flake = false;
    };
    oil-git-status = {
      url = "github:mrcjkb/oil-git-status.nvim/";
      flake = false;
    };
    oqt = {
      url = "github:itsfrank/overseer-quick-tasks";
      flake = false;
    };
    oxocarbon = {
      url = "github:nyoom-engineering/oxocarbon.nvim";
      flake = false;
    };
    pathlib = {
      url = "github:pysan3/pathlib.nvim";
      flake = false;
    };
    profile = {
      url = "github:stevearc/profile.nvim";
      flake = false;
    };
    quarto = {
      url = "github:quarto-dev/quarto-nvim";
      flake = false;
    };
    ratatoskr = {
      url = "github:vigoux/ratatoskr.nvim";
      flake = false;
    };
    roslyn = {
      url = "github:jmederosalvarado/roslyn.nvim";
      flake = false;
    };
    reactive = {
      url = "github:rasulomaroff/reactive.nvim";
      flake = false;
    };
    resession = {
      url = "github:stevearc/resession.nvim";
      flake = false;
    };
    rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "parts";
      inputs.pre-commit-hooks.follows = "pch";
    };
    smuggler = {
      url = "github:Klafyvel/nvim-smuggler";
      flake = false;
    };
    sweetie = {
      url = "github:NTBBloodbath/sweetie.nvim";
      flake = false;
    };
    tailwind-tools = {
      url = "github:luckasRanarison/tailwind-tools.nvim";
      flake = false;
    };
    telescope_hoogle = {
      url = "github:luc-tielen/telescope_hoogle";
      flake = false;
    };
    folke_edgy = {
      url = "github:willothy/edgy.nvim"; # NOTE: (Hermit) TO->PATCH
      flake = false;
    };
    folke_trouble = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    folke_todo-comments = {
      url = "github:LunarLambda/todo-comments.nvim/enhanced-matching";
      flake = false;
    };
    folke_noice = {
      url = "github:folke/noice.nvim";
      flake = false;
    };
    ts-error-translator = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
    };
    nvim-webdev-icons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    nvim-material-icons = {
      url = "github:DaikyXendo/nvim-material-icon";
      flake = false;
    };
    nvim-parinfer = {
      url = "github:gpanders/nvim-parinfer/";
      flake = false;
    };
    nvim-treesitter = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    tsplayground = {
      url = "github:nvim-treesitter/playground";
      flake = false;
    };
    rainbow-delimiters = {
      url = "gitlab:HiPhish/rainbow-delimiters.nvim";
      flake = false;
    };
    truezen = {
      url = "github:Pocco81/true-zen.nvim";
      flake = false;
    };
    ts-autotags = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };
    ts-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    ts-context-commentstring = {
      url = "github:JoosepAlviste/nvim-ts-context-commentstring";
      flake = false;
    };
    ts-refactor = {
      url = "github:nvim-treesitter/nvim-treesitter-refactor";
      flake = false;
    };
    ts-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects";
      flake = false;
    };
    ts-node-action = {
      url = "github:Ckolkey/ts-node-action";
      flake = false;
    };
    toggleterm = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    ufold = {
      url = "github:kevinhwang91/nvim-ufo";
      flake = false;
    };
    quickfix = {
      url = "github:kevinhwang91/nvim-bqf";
      flake = false;
    };
    nonels = {
      url = "github:nvimtools/none-ls.nvim";
      flake = false;
    };
    lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    yanky = {
      url = "github:gbprod/yanky.nvim";
      flake = false;
    };
    wrapping-paper = {
      url = "github:benlubas/wrapping-paper.nvim";
      flake = false;
    };
    psa = {
      url = "github:kevinhwang91/promise-async";
      flake = false;
    };
    windows = {
      url = "github:anuvyklack/windows.nvim";
      flake = false;
    };

    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    yeet = {
      url = "github:samharju/yeet.nvim";
      flake = false;
    };
    zigTools = {
      url = "github:tacogips/zig-tools.nvim";
      flake = false;
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

    # Telescope Junk::
    telescope = {
      url = "github:nvim-lua/telescope.nvim";
      flake = false;
    };
    telescope-ui-select = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    telescope-file-browse = {
      url = "github:nvim-telescope/telescope-file-browser.nvim";
      flake = false;
    };
    telescope-project = {
      url = "github:nvim-telescope/telescope-project.nvim";
      flake = false;
    };
    telescope-tabs = {
      url = "github:LukasPietzschmann/telescope-tabs";
      flake = false;
    };
    telescope-zoxide = {
      url = "github:jvgrootveld/telescope-zoxide";
      flake = false;
    };
    telescope-egrepify = {
      url = "github:fdschmidt93/telescope-egrepify.nvim";
      flake = false;
    };
    tmpclone-nvim = {
      url = "github:danielhp95/tmpclone-nvim";
      flake = false;
    };
    folke_flash = {
      url = "github:folke/flash.nvim";
      flake = false;
    };
    text-case = {
      url = "github:johmsalas/text-case.nvim";
      flake = false;
    };
    matchparens = {
      url = "github:monkoose/matchparen.nvim";
      flake = false;
    };
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    syntax-tree-surfer = {
      url = "github:ziontee113/syntax-tree-surfer";
      flake = false;
    };
    iswap = {
      url = "github:mizlan/iswap.nvim";
      flake = false;
    };

    # Nightly TreeSitter Parsers::
    ts-nightly.url = "github:MangoIV/nixpkgs/mangoiv/update-tree-sitter";
    ts-src = {
      url = "github:tree-sitter/tree-sitter";
      flake = false;
    };
    tree-sitter-ada = {
      url = "github:briot/tree-sitter-ada";
      flake = false;
    };
    tree-sitter-cabal = {
      url = "github:sisypheus-dev/tree-sitter-cabal";
      flake = false;
    };
    tree-sitter-gleam = {
      url = "github:gleam-lang/tree-sitter-gleam";
      flake = false;
    };
    tree-sitter-just = {
      url = "github:IndianBoy42/tree-sitter-just";
      flake = false;
    };
    tree-sitter-norg = {
      url = "github:boltlessengineer/tree-sitter-norg3-pr1/null_detached_modifier";
      flake = false;
    };
    tree-sitter-norg-meta = {
      url = "github:nvim-neorg/tree-sitter-norg-meta";
      flake = false;
    };
    tree-sitter-nu = {
      url = "github:nushell/tree-sitter-nu";
      flake = false;
    };
    tree-sitter-nim = {
      url = "github:alaviss/tree-sitter-nim";
      flake = false;
    };
    tree-sitter-vimdoc = {
      url = "github:neovim/tree-sitter-vimdoc";
      flake = false;
    };
    tree-sitter-roc = {
      url = "github:faldor20/tree-sitter-roc";
      flake = false;
    };
    tree-sitter-typst = {
      url = "github:uben0/tree-sitter-typst";
      flake = false;
    };
  };
}
