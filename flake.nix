{
  description = "Nyoom Interfaces with Nix";

  outputs = { self, parts, ... }@inputs:
    parts.lib.mkFlake { inherit inputs; } ({ flake-parts-lib, withSystem, ... }:
      let
        flakeModule = let inherit (flake-parts-lib) importApply;
        in importApply ./nix/flake-modules { inherit self withSystem; };
      in {
        systems =
          [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
        imports = [ ./nix/tests flakeModule ];
        debug = true;
        flake = {
          inherit flakeModule;
          templates = let inherit (inputs.nixpkgs) lib;
          in (lib.attrsets.genAttrs (lib.attrNames
            (lib.filterAttrs (_: v: v != "regular")
              (builtins.readDir ./nix/templates))) (name: {
                path = ./nix/templates/${name};
                description = "${name}-Template";
                welcomeText = ''
                  Welcome ya bloated fuck, ur building a devshell for ${name}, enjoy it .
                '';
              }));
        };
        perSystem = { self', lib, pkgs, config, system, ... }: {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.rocks.overlays.default ];
          };
          # TODO (Hermit):: Remove the plugins.*.lazy option -> plugins.lazy and hard check for attrs there;
          neohermit = {
            src = inputs.nvim-git;
            strip = true;
            plugins = {
              lazy = [
                "actions-preview"
                "neorg-telescope"
                "neorg-chronicle"
                "neorg-exec"
                "neorg-roam"
                "neorg-timelog"
                "neorg-hop-extras"
                "image-nvim"
                "cmp-treesitter" # For whatever reason, cmp-sources get packadded automagically? WTF CMP
                "cmp-latexsym"
                "direnv"
                "galore"
                "gitconflict"
                "gitignore"
                "nvim-dap-rr"
                "nvim-dap-python"
                "nfnl"
                "smuggler"
                "go-nvim"
                "harpoon"
                "iedit"
                "ts-error-translator"
                "telescope_hoogle"
                "otter"
                "oqt"
                "quarto"
                "reactive"
                "ratatoskr"
                "tailwind-tools"
                "yeet"
              ];
              eager = [
                "lua-utils"
                "luasnip_snippets"
                "molten"
                "nvim-dap-virtual-text"
                "nvim-scissors"
                "nu-syntax"
                "wrapping-paper"
              ];
            };
            lua = {
              extraPacks = with pkgs.lua51Packages; [
                rustaceanvim
                lgi
                toml
                toml-edit
                fidget-nvim
                nvim-nio
                fzy
              ];
              jit = with pkgs.luajitPackages; [ magick luarocks ];
            };
            extraParsers = [
              "cabal"
              "norg-meta"
              "typst"
              "just"
              "nim"
              "norg" # Note::(Hermit) We need to symlink the queries along with neorg's plugin.
            ];
            defaultPlugins = with pkgs.vimPlugins; [
              sqlite-lua
              mini-nvim
              markdown-preview-nvim
              rocks-nvim
              lsp_lines-nvim
              packer-nvim # TODO (Adjoint) :: Deprecate Packer, use nix and inhouse lazy-loading with C=>>
              hotpot-nvim # TODO (Adjoint) :: Deprecate hotpot, and use nfnl
            ];
            bins = with pkgs;
              [
                marksman
                selene
                haskellPackages.fast-tags # NOTE:: (Hermit) Im in love, marry me
                nil
                ripgrep
                fd
                stylua
              ] ++ [ inputs.nixfmt-rfc.packages."${system}".default ]
              ++ (with pkgs.lua51Packages; [
                lua-language-server
                lua
                luarocks
              ]);
          };
          devShells = {
            default = pkgs.mkShell {
              name = "Hermit:: Dev";
              inputsFrom = with config; [
                treefmt.build.devShell
                pre-commit.devShell
              ];
              packages = with pkgs; [ lua-language-server selene fnlfmt ];
              DIRENV_LOG_FORMAT = ""; # NOTE:: Makes direnv shutup
            };
          };
          packages = {
            fnl-linter = pkgs.stdenv.mkDerivation {
              name = "Fnl-linter";
              src = inputs.fnl-linter;
              nativeBuildInputs = with pkgs; [ lua5_4_compat fennel ];
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
                lockFileContents =
                  builtins.readFile ("${inputs.norg-fmt}" + "/Cargo.lock");
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
                lockFileContents = builtins.readFile
                  ("${inputs.norgopolis-client-lua}" + "/Cargo.lock");
                allowBuiltinFetchGit = true;
              };
              postInstall = ''
                mkdir -p $out/share/lib/lua/5.1
                cp $out/lib/libnorgopolis.so $out/lib/lua/5.1
              '';
            };
          };
        };
      });

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
    nixfmt-rfc.url = "github:piegamesde/nixfmt/rfc101-style";
    fnl-linter = {
      url = "github:dokutan/check.fnl";
      flake = false;
    };
    fnl-Docgen = {
      url = "gitlab:andreyorst/fenneldoc";
      flake = false;
    };
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
    cmp-latexsym = {
      url = "github:kdheepak/cmp-latex-symbols";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
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
    direnv = {
      url = "github:direnv/direnv.vim";
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
    go-nvim = {
      url = "github:ray-x/go.nvim";
      flake = false;
    };
    harpoon = {
      url = "github:ThePrimeagen/harpoon/harpoon2";
      flake = false;
    };
    hover-nvim = {
      url = "github:lewis6991/hover.nvim";
      flake = false;
    };
    iedit = {
      url = "github:altermo/iedit.nvim";
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
    norgopolis-client-lua = {
      url = "github:nvim-neorg/norgopolis-client.lua";
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
    neorg-chronicle = {
      url = "github:MartinEekGerhardsen/neorg-chronicle";
      flake = false;
    };
    otter = {
      url = "github:benlubas/otter.nvim/feat/remove_leading_whitespace/";
      flake = false;
    };
    oqt = {
      url = "github:itsfrank/overseer-quick-tasks";
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
    reactive = {
      url = "github:rasulomaroff/reactive.nvim";
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
    ts-error-translator = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
    };
    yeet = {
      url = "github:samharju/yeet.nvim";
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
      url =
        "github:boltlessengineer/tree-sitter-norg3-pr1/null_detached_modifier";
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
