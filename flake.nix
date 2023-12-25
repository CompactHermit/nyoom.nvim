{
  description = "Nyoom Interfaces with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fnl-linter = {
      url = "github:dokutan/check.fnl";
      flake = false;
    };
    neorocks.url = "github:nvim-neorocks/neorocks";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # Plugins/Parsers::
    himalaya.url = "git+https://git.sr.ht/~soywod/himalaya-vim";
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
      url = "github:nvim-neorg/tree-sitter-norg3/new-attached-modifiers";
      flake = false;
    };
    tree-sitter-norg-meta = {
      url = "github:nvim-neorg/tree-sitter-norg-meta";
      flake = false;
    };
  };
  outputs = {
    self,
    parts,
    ...
  } @ inputs:
    parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [
        ./nix/tests
      ];
      debug = true;

      flake = {
        templates = let
          inherit (inputs.nixpkgs) lib;
        in
          ## Ooga Booga spaghetti powers, this is probably not even O(1), rofl
          (lib.attrsets.genAttrs
            (lib.attrNames
              (lib.filterAttrs
                (n: v: v != "regular")
                (builtins.readDir ./nix/templates)))
            (name: {
              path = ./nix/templates/${name};
              description = "${name}-Template";
              welcomeText = ''
                Welcome ya bloated fuck, ur building a devshell for ${name}, enjoy it .
              '';
            }));
      };
      perSystem = {
        self',
        lib,
        pkgs,
        config,
        system,
        ...
      }: let
        l = lib // builtins;
        grammar = pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/tools/parsing/tree-sitter/grammar.nix" {};
        NeovimConfig = pkgs.neovimUtils.makeNeovimConfig {
          extraLuaPackages = p: [p.luarocks p.magick];
          # TODO:: (Hermit) add https://github.com/nvim-neorocks/rocks-config.nvim/, and replace packer
          plugins = with pkgs;
            [
              (pkgs.symlinkJoin {
                name = "nvim-treesitter";
                paths =
                  [pkgs.vimPlugins.nvim-treesitter.withAllGrammars] #NOTE:: (Hermit) Use NageFire's branch and rewrite
                  ++ map pkgs.neovimUtils.grammarToPlugin (pkgs.vimPlugins.nvim-treesitter.allGrammars
                    ++ (with self'.packages; [tree-sitter-nim tree-sitter-just tree-sitter-typst tree-sitter-norg tree-sitter-norg-meta])
                    ++ (with pkgs.tree-sitter-grammars; [tree-sitter-nu]));
              })
              parinfer-rust
            ]
            ++ (with vimPlugins; [
              sqlite-lua
              mini-nvim
              markdown-preview-nvim
            ])
            ++ (with inputs; [
              himalaya.packages."${system}".default
            ]);
          withNodeJs = true;
          withRuby = true;
          withPython3 = true;
          customRC = import ./nix;
        };
        #(Hermit) Dump all wrapper args here
        wrapperArgs = let
          path = l.makeBinPath (with pkgs; [
            sqlite
            deadnix
            statix
            marksman
            alejandra
            nil
            biome
            ripgrep
            fd
            xxd
            lua-language-server
            python311Packages.jupytext
            stylua
          ]);
        in
          NeovimConfig.wrapperArgs
          ++ [
            "--prefix"
            "PATH"
            ":"
            path
          ];
      in {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.neorocks.overlays.default #NOTE:: (Hermitl) This overlay is bloated, need to reduce the amount of packages, we only realy need neorocks
            (_: _: {
              neovim-custom =
                pkgs.wrapNeovimUnstable
                self.inputs.neovim-nightly-overlay.packages."${system}".default ## Until I learn how to avoid the vim.re issue, this stays
                
                (NeovimConfig // {inherit wrapperArgs;});
            })
          ];
        };
        devShells = {
          default = pkgs.mkShell {
            name = "Awooga";
            inputsFrom = with config; [
              treefmt.build.devShell
              pre-commit.devShell
            ];
            packages = with pkgs; [
              lua-language-server
              selene
              fnlfmt
            ];
            DIRENV_LOG_FORMAT = ""; #NOTE:: Makes direnv shutup
          };
        };
        packages = {
          # NOTE:: (Hemrit) If we can get hotpot to just compile within a sandbox, we should be fine
          #cached_bytecode  = pkgs.stdenv.mkDerivation {};
          fnl-linter = pkgs.stdenv.mkDerivation {
            name = "Fnl-linter";
            src = inputs.fnl-linter;
            nativeBuildInputs = with pkgs; [lua5_4_compat fennel];
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
          default = pkgs.writeShellApplication {
            name = "nvim";
            text = ''
              XDG_CACHE_HOME=/tmp/nyoom ${l.getExe pkgs.neovim-custom} "$@"
            '';
          };
          tree-sitter-nim = grammar {
            language = "nim";
            src = inputs.tree-sitter-nim;
            inherit (pkgs.tree-sitter) version;
          };
          tree-sitter-just = grammar {
            language = "just";
            src = inputs.tree-sitter-just;
            inherit (pkgs.tree-sitter) version;
          };
          tree-sitter-typst = grammar {
            language = "typst";
            src = inputs.tree-sitter-typst;
            inherit (pkgs.tree-sitter) version;
          };
          tree-sitter-norg = grammar {
            language = "norg";
            src = inputs.tree-sitter-norg;
            inherit (pkgs.tree-sitter) version;
          };
          tree-sitter-norg-meta = grammar {
            language = "norg-meta";
            src = inputs.tree-sitter-norg-meta;
            inherit (pkgs.tree-sitter) version;
          };
        };
        apps = {
          sync = {
            type = "app";
            program = pkgs.writeShellApplication {
              name = "Nyoom:: Sync";
              text =
                /*
                bash
                */
                ''
                  cd ~/.config/nvim
                  echo "Deleting Temp Cache"
                  rm -rf /tmp/nyoom
                  XDG_CACHE_HOME=/tmp/nyoom NYOOM_CLI=true ${l.getExe pkgs.neovim-custom} --headless -c 'autocmd User PackerComplete quitall' -c 'lua require("packer").sync()'
                '';
            };
          };
        };
      };
    };
}
