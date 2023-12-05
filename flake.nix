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
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # Plugins/Parsers::
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
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
        inputs.treefmt-nix.flakeModule
        inputs.pch.flakeModule
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
        mkHook = n: prev:
        /*
        * SANITIZE:: (Hermit) Move to ./nix/checks folder
        */
          {
            description = "pre-commit hook for ${n}";
            fail_fast = true;
            excludes = ["flake.lock" "index.norg" "r.'+\.yml$'"];
          }
          // prev;
        src = ./.;
        #let
        #__functor = {};
        #in
        #l.filterSource (path: type: l.lists.foldr (x: y: __functor // x // y)) ./.; # There might  be a way to work around this with absolute store paths, like having a default.nix file here using a vimscript

        grammar = pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/tools/parsing/tree-sitter/grammar.nix" {};
        NeovimConfig = pkgs.neovimUtils.makeNeovimConfig {
          extraLuaPackages = p: [p.luarocks p.magick];
          plugins = with pkgs;
            [
              (pkgs.symlinkJoin {
                name = "nvim-treesitter";
                paths =
                  [pkgs.vimPlugins.nvim-treesitter.withAllGrammars]
                  ++ map pkgs.neovimUtils.grammarToPlugin (pkgs.vimPlugins.nvim-treesitter.allGrammars
                    ++ (with self'.packages; [tree-sitter-nim tree-sitter-just tree-sitter-typst tree-sitter-norg])
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
          customRC = ''luafile ${src}/init.lua''; # Weird issue where it doesn't respect store init.lua
        };
        #(Hermit) Dump all wrapper args here
        wrapperArgs = let
          path = l.makeBinPath [
            pkgs.sqlite
            pkgs.deadnix
            pkgs.statix
            pkgs.marksman
            pkgs.alejandra
            pkgs.nil
            pkgs.biome
            pkgs.ripgrep
            pkgs.fd
            pkgs.lua-language-server
            pkgs.stylua
          ];
        in
          NeovimConfig.wrapperArgs
          ++ [
            "--prefix"
            "PATH"
            ":"
            path
          ];
        # TODO:: Move to overlays
      in {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.neorg-overlay.overlays.default
            (_: _: {
              neovim-custom =
                pkgs.wrapNeovimUnstable
                self.inputs.neovim-nightly-overlay.packages."${system}".default ## Until I learn how to avoid the vim.re issue, this stays
                
                # (pkgs.neovim-unwrapped.overrideAttrs (oa: {
                #   #src = inputs.nvim-src;
                #   name = "neovim";
                #   patches = [];
                #   preConfigure = os.preConfigure + ''
                #     sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/"
                #   '';
                #   buildInputs =
                #     ## Avoid a global overlay
                #     lib.remove pkgs.libvterm-neovim oa.buildInputs
                #     ++ lib.singleton (
                #       pkgs.libvterm-neovim.overrideAttrs {
                #         version = "0.3.3";
                #         src = pkgs.fetchurl {
                #           url = "https://github.com/neovim/libvterm/archive/v0.3.3.tar.gz";
                #           hash = "sha256-C6vjq0LDVJJdre3pDTUvBUqpxK5oQuqAOiDJdB4XLlY=";
                #         };
                #       }
                #     );
                # }))
                (NeovimConfig // {inherit wrapperArgs;});
            })
          ];
        };

        treefmt = {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            fnlfmt.enable = true;
          };
        };

        pre-commit = {
          settings = {
            settings = {
              treefmt.package = config.treefmt.build.wrapper;
            };
            hooks = {
              treefmt = mkHook "treefmt" {enable = true;};
            };
          };
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
            DIRENV_LOG_FORMAT = "";
          };
        };
        packages = {
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
                  XDG_CACHE_HOME=/tmp/nyoom NYOOM_CLI=true ${lib.getExe pkgs.neovim-custom} --headless -c 'autocmd User PackerComplete quitall' -c 'lua require("packer").sync()'
                '';
            };
          };
        };
      };
    };
}
