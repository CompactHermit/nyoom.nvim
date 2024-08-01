{ lib, ... }:
let
  mkTypes = import ../flake-modules/mkTypes.nix { inherit lib; };

  inherit (lib) mkOption types genAttrs;

in
{
  /**
    Unit Tests for Custom
  */

  moduleTest = lib.evalModules {
    modules = [
      {
        options.a = lib.mkOption {
          type = mkTypes.plugSpec;
          default = { };
        };
      }
    ];
  };
}
