{ lib, ... }:
let
  inherit (lib) mkOptionType types genAttrs;
in
#   name
#   ,description ? null
# , descriptionClass ? null
#   ,check ? (x: true)
#  , merge ? mergeDefaultOption
#   ,emptyValue ? {}
#   getSubOptions ? prefix: {}
# , getSubModules ? null
#   substSubModules ? m: null
#   typeMerge ? defaultTypeMerge functor
#   functor ? defaultFunctor name
#   deprecationMessage ? null
#   nestedTypes ? {}
{
  plugSpec = mkOptionType {
    name = "PluginSpec";
    description = # norg
      ''
        * Plugin Spec::
        Takes attrsOf `PluginSpec`, which is comprised of the following attrs::
      '';
    check = lib.isAttrs;
    merge =
      { loc, def }:
      {
        values = (loc // def);
      };
  };
}
