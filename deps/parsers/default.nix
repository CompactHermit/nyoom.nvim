{
  config,
  callPackage,
  lib,
  tree-sitter-nightly,
  neovimUtils,
  symlinkJoin,
  importNpmLock,
  nodejs,
#grammars ? [ ],
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
  grammars_name = lib.flip lib.pipe [
    (builtins.attrNames)
    (map (name: lib.removePrefix "treesitter-grammar-" name))
  ] grammars;
  #TODO: Unshittify this garbage
  parsers = builtins.map (
    n:
    let
      grammarT = deps."treesitter-grammar-${n}";
      #Thank you AYAT, VERY COOL::
      npmDeps = builtins.pathExists ./_sources/treesitter-grammar-${n}-${grammarT.version};
      builder =
        p:
        #TODO:: Rewrite the `buildGrammar` dogshit, Teto should not be in the kitchen
        tree-sitter-nightly.buildGrammar.override ({ tree-sitter = tree-sitter-nightly; }) (
          {
            inherit (grammarT) src version;
            # nativeBuildInputs = [
            #   nodejs
            #   tree-sitter-nightly
            # ];
            # buildInputs = (
            #   lib.optional npmDeps [
            #     importNpmLock.npmConfigHook
            #   ]
            # );
            # useNpm = if npmDeps then true else null;
            # npmDeps =
            #   if npmDeps then
            #     importNpmLock {
            #       npmRoot = ./_sources/treesitter-grammar-${n}-${grammarT.version};
            #     }
            #   else
            #     null;
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
