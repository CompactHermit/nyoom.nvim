{ inputs, lib, pkgs, ... }:
let l = lib // builtins;
in {
  /* module mkLib where
     mkLib::mkNeovim -
     mkLib::mkWrapper -
  */

  mkWrapper = { };
  mkNeovim = { };
  mkTreesitter = __parsers:
    l.genAttrs __parsers (x:
      (pkgs.tree-sitter.buildGrammar {
        language = x;
        src = inputs."tree-sitter-${x}";
        version = "${inputs."tree-sitter-${x}".shortRev}";
      }));
  __mkLuaRock = src: deps:
    pkgs.callPackage ({ buildLuarocksPackage, fetchgit, lua, luaOlder
      , luarocks-build-rust-mlua, }:
      { __useRust ? false, }:
      buildLuarocksPackage {
        pname = "${src}";
        version =
          inputs."${src}".lastModifiedDate; # TODO::(Hermit)<02/07> Find a better way to add versions from the luarockSpec
        src = inputs."${src}";
        knownrockspec = { };
        disabled = (luaOlder "5.1");
        propagatedBuildInputs = [ lua ] ++ (l.mkIf __useRust [ ]);
      }) { };
}
