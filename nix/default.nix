# * Will make the ../init.lua file permenant in the nix store, thus avoiding GC
((builtins.concatStringsSep "\n") (
  map (x: "luafile ${x}") [
    #
    ../init.lua
  ]
))
