{
  description = "Nyoom Interfaces with Nix";
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
              overlays = with inputs; [
                #rocks.overlays.default
                fnl-tools.overlays.default
              ];
            };
            # TODO (Hermit):: Remove the plugins.*.lazy option -> plugins.lazy and hard check for attrs there;
            neohermit = {
              src = inputs.nvim-git;
              strip = true;
              plugins = {
                lazy = [
                  "actions-preview"
                  "bufferline"
                  "diffview"
                  "cmp-treesitter" # For whatever reason, cmp-sources get packadded automagically? WTF CMP
                  "cmp-latexsym"
                  "direnv"
                  "galore"
                  "gitconflict"
                  "gitignore"
                  "ibl"
                  "image-nvim"
                  "multicursor"
                  "neodev"
                  "neogit"
                  "neorg"
                  "neorg-telescope"
                  "neorg-chronicle"
                  "neorg-exec"
                  "neorg-roam"
                  "neorg-timelog"
                  "neorg-hop-extras"
                  "nui-components"
                  "nvim-dap-rr"
                  "nfnl"
                  "nvim-dap-python"
                  "nvim-nio" # Needed for Docs, will just igrnore for now
                  "smuggler"
                  "go-nvim"
                  "harpoon"
                  "resession"
                  "ts-error-translator"
                  "tsplayground"
                  "rainbow-delimiters"
                  "ts-context"
                  "ts-context-commentstring"
                  "ts-refactor"
                  "ts-textobjects"
                  "ts-node-action"
                  "telescope_hoogle"
                  "octo"
                  "otter"
                  "oqt"
                  "overseer"
                  "pathlib"
                  "quarto"
                  "reactive"
                  "ratatoskr"
                  "tailwind-tools"
                  "yeet"
                ];
                eager = [
                  "nightfox"
                  "haskellTools"
                  "haskell-snippets"
                  "luasnip_snippets"
                  "lua-utils"
                  "molten"
                  "nvim-dap-virtual-text"
                  "rustaceanvim"
                  "nvim-scissors"
                  "nu-syntax"
                  "wrapping-paper"
                ];
              };
              lua = {
                extraPacks = builtins.attrValues {
                  inherit (pkgs.lua51Packages)
                    rustaceanvim
                    lgi
                    toml
                    toml-edit
                    fidget-nvim
                    nvim-nio
                    fzy
                    ;
                };
                jit = builtins.attrValues { inherit (pkgs.luajitPackages) magick luarocks; };
              };
              extraParsers = [
                "cabal"
                "norg"
                "norg-meta"
                "typst"
                "just"
                "nim"
                "nu"
                "gleam"
              ];
              defaultPlugins = with pkgs.vimPlugins; [
                sqlite-lua
                mini-nvim
                markdown-preview-nvim
                #rocks-nvim
                lsp_lines-nvim
                packer-nvim # TODO (Adjoint) :: Deprecate Packer, use nix and inhouse lazy-loading with C=>>
                hotpot-nvim # TODO (Adjoint) :: Deprecate hotpot, and use nfnl
              ];
              bins = (
                builtins.attrValues {
                  inherit (pkgs)
                    selene
                    nil
                    ripgrep
                    fd
                    stylua
                    lua-language-server
                    nixfmt-rfc-style
                    ;
                  inherit (pkgs.haskellPackages) fast-tags;
                  #inherit (pkgs.lua51Packages)  lua luarocks;
                }
              );
              #++ (builtins.attrValues { inherit (pkgs.lua51Packages) lua-language-server lua luarocks; })
            };
            # };
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
                    fenneldoc
                    fennel-unstable-luajit
                    ;
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
                nativeBuildInputs = with pkgs; [
                  lua5_4_compat
                  fennel
                ];
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
                nativeBuildInputs = with pkgs; [ fennel ];
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
      url = "github:cachix/pre-commit-hooks.nix";
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
    #nixfmt-rfc.url = "github:piegamesde/nixfmt/rfc101-style";
    fnl-linter = {
      url = "github:dokutan/check.fnl";
      flake = false;
    };
    fnl-Docgen = {
      url = "gitlab:andreyorst/fenneldoc";
      flake = false;
    };
    fnl-tools.url = "github:m15a/flake-fennel-tools";
    #Vhyrro, I'm trusting you bud;
    rocks = {
      url = "github:nvim-neorocks/rocks.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "parts";
      inputs.pre-commit-hooks.follows = "pch";
    };
    #neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "parts";
      inputs.pre-commit-hooks.follows = "pch";
    };
    bufferline = {
      url = "github:akinsho/bufferline.nvim/";
      flake = false;
    };
    cmp-latexsym = {
      url = "github:kdheepak/cmp-latex-symbols";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };
    diffview = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    wrapping-paper = {
      url = "github:benlubas/wrapping-paper.nvim";
      flake = false;
    };
    actions-preview = {
      url = "github:aznhe21/actions-preview.nvim";
      flake = false;
    };
    csharp = {
      url = "github:iabdelkareem/csharp.nvim";
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
    #flash = {};
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
      url = "github:lewis6991/gitsigns.nvim/d96ef3bbff0bdbc3916a220f5c74a04c4db033f2";
      flake = false;
    };
    go-nvim = {
      url = "github:ray-x/go.nvim";
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
    hover-nvim = {
      url = "github:lewis6991/hover.nvim";
      flake = false;
    };
    ibl = {
      url = "github:lukas-reineke/indent-blankline.nvim";
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
    molten = {
      url = "github:benlubas/molten-nvim";
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
    neodev = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };
    nvim-nio = {
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };
    neogit = {
      url = "github:NeogitOrg/neogit/nightly";
      flake = false;
    };
    neorg = {
      url = "github:nvim-neorg/neorg";
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
    nfnl = {
      url = "github:Olical/nfnl";
      flake = false;
    };
    nvim-scissors = {
      url = "github:chrisgrieser/nvim-scissors";
      flake = false;
    };
    nvim-dap-rr = {
      url = "github:jonboh/nvim-dap-rr";
      flake = false;
    };
    nvim-dap-python = {
      url = "github:mfussenegger/nvim-dap-python";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
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
    overseer = {
      url = "github:stevearc/overseer.nvim";
      flake = false;
    };
    oqt = {
      url = "github:itsfrank/overseer-quick-tasks";
      flake = false;
    };
    pathlib = {
      url = "github:pysan3/pathlib.nvim";
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
    smuggler = {
      url = "github:Klafyvel/nvim-smuggler";
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
    #todoloc = {};
    ts-error-translator = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
    };
    treesitter = {
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
    yeet = {
      url = "github:samharju/yeet.nvim";
      flake = false;
    };
    #tree-sitter-agda = { };
    tree-sitter-gleam = {
      url = "github:gleam-lang/tree-sitter-gleam";
      flake = false;
    };
    tree-sitter-just = {
      url = "github:IndianBoy42/tree-sitter-just";
      flake = false;
    };
    tree-sitter-nim = {
      url = "github:alaviss/tree-sitter-nim";
      flake = false;
    };
    tree-sitter-typst = {
      url = "github:uben0/tree-sitter-typst";
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
    tree-sitter-cabal = {
      url = "git+https://gitlab.com/magus/tree-sitter-cabal";
      flake = false;
    };
  };
}
