{
  fetches,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  /**
    module mkLib where
  */

  /**
    import':: Imports a path
  */
  import' =
    path:
    let
      func' = import path;
      functor = {
        __functor = self: p: self.set p;
        varg = builtins.functionArgs func';
        inherit fetches pkgs;
      };
    in
    functor;
  mkRock =
    rockName: deps:
    pkgs.luajitPackages.callPackage (
      {
        buildLuarocksPackage,
        fetchgit,
        lua,
        luaOlder,
        luarocks-build-rust-mlua,
        __useRust ? false,
      }:
      buildLuarocksPackage {
        inherit (fetches."{rockName}")
          pname
          version
          src
          ;
        knownrockspec = { };
        disabled = (luaOlder "5.1");
        propagatedBuildInputs = [ lua ] ++ (mkIf __useRust [ luarocks-build-rust-mlua ]);
      }
    ) { };

  _file = "./mklib.nix";
}
