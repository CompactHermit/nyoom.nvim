{ lib, ... }:
let

  inherit (lib) mkOption types genAttrs;
in
{

  mkNullableOption =
    attrs:
    mkOption (
      attrs
      // {
        type = types.nullOr attrs.type;
        default = null;
      }
    );
  nh = {
    plugins = [
      "names"
      "of"
      "plugins"
    ];
  };
}
