{ inputs, outputs, ... }:

## My Monkey Patched efforts to avoid Flake-Util Bloat
let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  # inherit (lib) mapAttrs; ## Note needed yet
in
rec {
  forEachSystem = lib.genAttrs [
    "aarch64-linux"
    "i686-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  forEachPkgs = f:
    forEachSystem
      (system:
        f nixpkgs.legacyPackages.${system});
}
