{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf genAttrs;
  inherit (pkgs.tree-sitter) buildGrammar;
  inherit (pkgs.neovimUtils) grammarToPlugin;
in
{
  /**
    module mkLib where
    mkLib::mkNeovim -
    mkLib::mkWrapper -
    mkLib:: mkTreesitter -
  */
  import' =
    path:
    let
      func' = import path;
      functor = {
        __functor = self: p: self.set p;
        varg = builtins.functionArgs func';
        inherit inputs pkgs;
      };
    in
    functor;
  mkRock =
    src: deps:
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
        pname = "${src}";
        version = inputs."${src}".lastModifiedDate; # TODO::(Hermit)<02/07> Find a better way to add versions from the luarockSpec
        src = inputs."${src}";
        knownrockspec = { };
        disabled = (luaOlder "5.1");
        propagatedBuildInputs = [ lua ] ++ (mkIf __useRust [ luarocks-build-rust-mlua ]);
      }
    ) { };

  mkTreesitter =
    __parsers: __patches:
    genAttrs __parsers (
      x:
      (
        buildGrammar {
          language = x;
          src = inputs."tree-sitter-${x}";
          version = "${inputs."tree-sitter-${x}".shortRev}";
        }
        // __patches.${x} or { }
      )
    );
  _file = "./mklib.nix";
}
