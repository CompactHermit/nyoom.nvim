{ inputs, ... }: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pch.flakeModule
    ./busted.nix
    ./docs.nix
  ];

  perSystem = { pkgs, config, self', lib, system, ... }:
    let
      l = lib // builtins;
      mkHook = n: _args:
        # * SANITIZE:: (Hermit) Move to ./nix/checks folder
        {
          description = "pre-commit hook for ${n}";
          fail_fast = true;
          excludes = [ "flake.lock" "index.norg" "r.'+.yml$'" ];
        } // _args;
      __fnl-config = pkgs.writeTextFile {
        name = "config.fnl";
        text =
          # fennel
          ''
            {
              :color true
              :max-line-length 150
              :checks {
                :symbols false
                :if->when false
              }
            }
          '';
      };
    in {
      pre-commit = {
        settings = {
          settings = { treefmt.package = config.treefmt.build.wrapper; };
          hooks = {
            treefmt = mkHook "treefmt" { enable = true; };
            norg-fmt = mkHook "norg-fmt" {
              enable = false;
              name = "Norg-fmt";
              entry = "${self'.packages.norg-fmt}/bin/norg-fmt";
              files = ".norg$";
              fail_fast = true;
            };
            fnl-lint = mkHook "fnl-linter" {
              enable = false;
              name = "Fennel Linter";
              entry =
                "${self'.packages.fnl-linter}/bin/check.fnl -c ${__fnl-config}";
              files = ".fnl$";
              language = "system";
              fail_fast = false;
            };
          };
        };
      };
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          fnlfmt.enable = true;
        };
      };
      # checks = {
      #   testSuite = pkgs.writeShellApplication {
      #     name = "Check Hotpot Cache";
      #     runtimeInputs = [pkgs.lua pkgs.neovim-custom];
      #     text = ''
      #       set -e
      #         export logpath="$(mktemp -d)"
      #       echo "TODO:: Setup Busted Checks Here"
      #     '';
      #   };
      #
      #   macro = pkgs.stdenv.mkDerivation {
      #     name = "Run Macro Tests";
      #     buildInputs = [];
      #     buildPhase = ''
      #       echo "Find a way for us to interface with hotpot's fennel-luajit compiler without neovim"
      #     '';
      #   };
      # };
      #
    };
}
