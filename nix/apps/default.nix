{
  lib,
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    NeovimConfig = pkgs.neovimUtils.makeNeovimConfig {
      extraLuaPackages = p: [p.luarocks p.magick p.libluv];
      withNodeJs = true;
      withRuby = true;
      withPython3 = true;
      customRC = "luafile ~/.config/nvim/init.lua";
    };

    /*
    TODO:: DELTE AFTER TESTS
    */
    test_norg_ts = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [tree-sitter-norg tree-sitter-lua]);

    extraLuaPacks = [test_norg_ts];
    extraPackages = [];
    extraMakeWrapperArgs =
      lib.optionalString (extraPackages != [])
      ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';

    extraMakeWrapperLuaCArgs = lib.optionalString (extraLuaPacks != []) ''
      --suffix LUA_CPATH ";" "${
        lib.concatMapStringsSep ";" pkgs.luaPackages.getLuaCPath
        extraLuaPacks
      }"'';

    extraMakeWrapperLuaArgs =
      lib.optionalString (extraLuaPacks != [])
      ''
        --suffix LUA_PATH ";" "${
          lib.concatMapStringsSep ";" pkgs.luaPackages.getLuaPath
          extraLuaPacks
        }"'';

    ## For now, we'll test with nightly for binary cahce
    nvim_nightly_wrapped = pkgs.wrapNeovimUnstable inputs.neovim-nightly-overlay.packages."${system}".default (NeovimConfig
      // {
        wrapperArgs =
          (lib.escapeShellArgs NeovimConfig.wrapperArgs)
          + " "
          + extraMakeWrapperArgs
          + " "
          + extraMakeWrapperLuaCArgs
          + " "
          + extraMakeWrapperLuaArgs;
        wrapRc = false;
      });
  in {
    apps = {
      default = {
        program = nvim_nightly_wrapped;
      };
      nyoom = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "Nyoom:: Sync";
          text = ''
            ~/.config/nvim/bin/nyoom "$@"
          '';
        };
      };
    };
  };
}
