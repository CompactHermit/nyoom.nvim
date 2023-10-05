{
  description = "Nyoom Interfaces with Nix";

  inputs = {
    #A really fucking bad idea
    #nix_staged.url = "github:NixOS/nixpkgs/staging";
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
        ./nix/overlay/default.nix
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
          plugins = with pkgs; [vimPlugins.nvim-treesitter.withAllGrammars];
          withNodeJs = true;
          withRuby = true;
          withPython3 = true;
          customRC = "luafile ~/.config/nvim/init.lua";
        };

        wrapperArgs = let
          path = l.makeBinPath [
            #
            # Runtime dependencies
            #
            pkgs.deadnix
            pkgs.statix
            pkgs.alejandra
            pkgs.nil
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
        nvim_overlay = self: super: {
          neovim-custom =
            pkgs.wrapNeovimUnstable
            (final.neovim-unwrapped.overrideAttrs (oa: {
              version = "Flying spaghetti Monster";
              src = inputs.nvim-src;
              preConfigure =
                oa.preConfigure
                or ""
                +
                /*
                bash
                */
                ''
                  ln -s ${pkgs.tree-sitter-grammars.tree-sitter-norg}/parser $out/lib/nvim/parser/norg.so
                '';
              nativeBuildInputs =
                oa.nativeBuildInputs
                ++ [
                  super.libiconv
                ];
            }))
            (NeovimConfig // {inherit wrapperArgs;});
        };
      in {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            nvim_overlay
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
              nu
            '';
          };
        };
        packages.default = pkgs.hello;
      };
    };
}
