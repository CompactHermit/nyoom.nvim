{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (lib) mapAttrs;
  /*
    *
    Plugin:: {lazy = <Bool::bool>; pname = <String::Plugin>;}
    __functor:: self: __plugins -> [vimPlugins::vimplugins]
  */
  mkNeovimPlugin = src: pname: __extraOpts: __opt: {
    plugin = buildVimPlugin (
      {
        inherit pname src;
        version = src.lastModifiedDate;
      }
      // __extraOpts
    );
    optional = __opt;
  };
in
#TODO: (Hermit) Refactor this, I mean look at this, aren't you ashamed of this?
{
  __functor =
    self: p:
    mapAttrs (
      n: v:
      if (n == "lazy") then
        (map (x: mkNeovimPlugin inputs."${x}" x { } true) v)
      else if (n == "eager") then
        (map (x: mkNeovimPlugin inputs."${x}" x { } false) v)
      else
        throw "Neovim Plugin Not specified"
    ) p;
}
