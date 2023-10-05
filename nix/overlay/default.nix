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
      plugins = [
        pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      ];
      extraLuaPackages = p: [p.luarocks p.magick p.libluv];
      withNodeJs = true;
      withRuby = true;
      withPython3 = true;
      customRC = "luafile ../../init.lua";
    };
    wrapperArgs = let
      path = lib.makeBinPath (with pkgs;[
        ripgrep
        nil
        fd
        stylua
      ]);
    in
    NeovimConfig.wrapperArgs ++ [ "--prefix"
    "PATH"
    ":"
    path];
  in {
    overlayAttrs = _: super: {
      ## Override src neovim to use nightly
      neovim-custom =
        pkgs.wrapNeovimUnstable
        (super.neovim-unwrapped.overrideAttrs (p: {
          src = inputs.nvim-src;
          version = inputs.nvim-src.shortRev or "dirty";
        }))
        (NeovimConfig // {inherit wrapperArgs;});
      };
    };
  }
