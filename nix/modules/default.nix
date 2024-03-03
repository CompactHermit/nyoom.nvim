_:
{ self, config, lib, flake-parts-lib, pkgs, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  mkLib' = import ./mklib.nix { };
  mkPlugin' = import ./mkPlugin.nix { };
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (pkgs.neovimUtils) makeNeovimConfig grammarToPlugin;
in {
  options = let inherit (lib) mkOption types;
  in {
    perSystem = mkPerSystemOption ({ pkgs, ... }: {

      options.neohermit = mkOption {
        description = "Neovim Loader::";
        type = types.submodule {
          options = {
            package = mkOption {
              type = types.package;
              description = "Neovim:: Package to use?";
              default = pkgs.neovim-unwrapped;
            };
          };
        };
      };

      config = {
        perSystem = { config, lib, pkgs, ... }: {
          packages.fennel-vim = makeNeovimConfig {
            withPython3 = true;
            extraLuaPackages = p: [ p.luarocks p.magick ];
            customRC = import ./nix;
          };
        };
      };
    });
  };
}
