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
    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
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
        # ./nix/apps/default.nix
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
        pkgs,
        config,
        system,
        final,
        ...
      }: let
        l = pkgs.lib // builtins;
        mkHook = n: prev:
          {
            description = "pre-commit hook for ${n}";
            fail_fast = true;
            excludes = ["flake.lock" "index.norg" "r.'+\.age$'"];
          }
          // prev;
        NeovimConfig = pkgs.neovimUtils.makeNeovimConfig {
          extraLuaPackages = p: [p.luarocks p.magick p.libluv];
          plugins = with pkgs; [
            vimPlugins.nvim-treesitter.withAllGrammars 
            parinfer-rust
            vimPlugins.nvim-treesitter.builtGrammars.tree-sitter-norg-meta
            # vimPlugins.neogit ## Werid Breaks, will just use this verison lolz
          ];
          withNodeJs = true;
          withRuby = true;
          withPython3 = true;
          customRC = "luafile ~/.config/nvim/init.lua"; 
        };

        wrapperArgs = let
          path = l.makeBinPath [
            pkgs.deadnix
            pkgs.statix
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
            (self: super: {
              neovim-custom =
                pkgs.wrapNeovimUnstable
                (self.neovim-unwrapped.overrideAttrs (oa: {
                  version = "Flying spaghetti Monster";
                  src = inputs.nvim-src;
                }))
                (NeovimConfig // {inherit wrapperArgs;});
              })
            (self: super: {
              libvterm-neovim = inputs.nix_staged.legacyPackages.x86_64-linux.libvterm-neovim;
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
              nvim_test = mkHook "NvimTest" {
                enable = true;
                entry = "${pkgs.hello}";
              };
              treefmt = mkHook "treefmt" {enable = true;};
              nixpkgs-fmt = mkHook "nixpkgs-fmt" {enable = true;};
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
            shellHook = ''
            ${config.pre-commit.shellHook}
            nu
            '';
          };
        };
        packages.default = pkgs.neovim-custom;
      };
    };
}
