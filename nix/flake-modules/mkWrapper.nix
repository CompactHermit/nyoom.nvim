{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  /**
    DOCS:
     mkWrapperUnshittified :: Custom Neovim Wrapper without bashscripting-bullshit
        The key to the wrapper is setting everything within the `init.lua` we give to neovim at the start.
        Since our neovim dotfiles is created as a plugin, we just load it after sourcing the init.lua.
  */

  mkWrapperUnshittified = { };
in
#lua
''''
