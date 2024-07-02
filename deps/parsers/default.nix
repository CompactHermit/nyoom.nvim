{
  config,
  callPackage,
  lib,
  tree-sitter,
  neovimUtils,
  symlinkJoin,

  grammars ? [ ],
}:
let
  inherit (neovimUtils) grammarToPlugin;
  cfg = config.settings.parsers;
  deps = callPackage ./_sources/generated.nix { };
  grammars = builtins.removeAttrs deps [
    "override"
    "nvim-treesitter"
    "overrideDerivation"
  ];
  grammars_name = lib.pipe grammars [
    (builtins.attrNames)
    (map (name: lib.removePrefix "treesitter-grammar-" name))
  ];
  #TODO: Unshittify this garbage
  parsers = builtins.map (
    n:
    let
      grammarT = deps."treesitter-grammar-${n}";
      builder =
        p:
        tree-sitter.buildGrammar (
          {
            inherit (grammarT) src version;
            language = n;
            generate = lib.hasAttr "generate" grammarT;
            location = grammarT.location or null;
          }
          #NOTE: Not all parsers can overrides, some can be null
          // cfg."${p}" or { }
        );
    in
    lib.pipe n [
      builder
      grammarToPlugin
    ]
  ) grammars_name;
in
symlinkJoin {
  name = deps.nvim-treesitter.pname;
  version = deps.nvim-treesitter.date;
  paths = [
    deps.nvim-treesitter.src
    parsers
  ];
}
