{
  description = "Nyoom Interfaces with Nix";

  inputs = {
    # Pull in only dependency patches
    nix_staged.url = "github:nixos/nixpkgs/staging";
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
    tree-sitter-nu = {
      url = "github:nushell/tree-sitter-nu";
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
        inputs.parts.flakeModules.easyOverlay
        inputs.pch.flakeModule
        ./nix/apps/default.nix
        #./nix/overlay/default.nix
      ];

      debug = true;

      flake = {
        homeManagerModules = {
          nyoom = {
            imports = [
              ## (fn Nyoom [packages inputs])
              (import ./nix/modules/nyoom self.packages inputs)
            ];
          };
        };
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
        ## Wait for upstream PR to merge
        #nixosModule = inputs.organist.flake.outputsFromNickel ./. inputs {};
      };
      perSystem = {
        self',
        lib,
        pkgs,
        config,
        system,
        final,
        ...
      }: let
        l = lib // builtins;
        grammar = pkgs.callPackage "${inputs.nixpkgs}/pkgs/development/tools/parsing/tree-sitter/grammar.nix" {};
        mkHook = n: prev:
          {
            description = "pre-commit hook for ${n}";
            fail_fast = true;
            excludes = ["flake.lock" "index.norg" "r.'+\.age$'"];
          }
          // prev;

        NeovimConfig = pkgs.neovimUtils.makeNeovimConfig {
          extraLuaPackages = p: [p.luarocks p.magick];
          plugins = with pkgs;
            [
              (vimPlugins.nvim-treesitter.withPlugins (_:
                pkgs.vimPlugins.nvim-treesitter.allGrammars
                ++ [
                  pkgs.tree-sitter-grammars.tree-sitter-nu
                  self'.packages.tree-sitter-nim
                  self'.packages.tree-sitter-just
                ]))
              vimPlugins.sqlite-lua
              parinfer-rust
              vimPlugins.nvim-treesitter.builtGrammars.tree-sitter-norg-meta
              #vimPlugins.overseer-nvim
            ]
            ++ [
              inputs.himalaya.packages."${system}".default
            ];
          withNodeJs = true;
          withRuby = true;
          withPython3 = true;
          customRC = "luafile ~/.config/nvim/init.lua";
        };

        #(Hermit) Dump all wrapper args here
        wrapperArgs = let
          path = l.makeBinPath [
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
            (_: super: {
              neovim-custom =
                pkgs.wrapNeovimUnstable
                # self.inputs.neovim-nightly-overlay.packages."${system}".default
                (pkgs.neovim-unwrapped.overrideAttrs (oa: {
                  #src = inputs.nvim-src;
                  name = "neovim";
                  version = "v10.0.0";
                  patches = [];
                  preConfigure = ''
                    sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/"
                  '';
                  buildInputs =
                    ## Avoid a global overlay
                    lib.remove pkgs.libvterm-neovim oa.buildInputs
                    ++ lib.singleton (
                      pkgs.libvterm-neovim.overrideAttrs {
                        version = "0.3.3";
                        src = pkgs.fetchurl {
                          url = "https://github.com/neovim/libvterm/archive/v0.3.3.tar.gz";
                          hash = "sha256-C6vjq0LDVJJdre3pDTUvBUqpxK5oQuqAOiDJdB4XLlY=";
                        };
                      }
                    );
                }))
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
            name = "Neovim DevShell, batteries included";
            inputsFrom = with config; [
              treefmt.build.devShell
              pre-commit.devShell
            ];
            packages = with pkgs; [
              lua-language-server
              selene
              fnlfmt
            ];
          };
        };
        packages = {
          default = pkgs.writeShellApplication {
            name = "nvim";
            text = ''
              XDG_CACHE_HOME=/tmp/nyoom ${lib.getExe pkgs.neovim-custom} "$@"
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
        };
      };
    };
}
