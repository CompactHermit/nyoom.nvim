{
  description = "DevShell for neovim config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    neovim-nightly-overlay = {
        url = "github:nix-community/neovim-nightly-overlay";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    neovim-nightly-overlay,
    flake-utils,
    ...
  } @ inputs:
  let 
      inherit (self) outputs;
      util = import ./nix/utils.nix {
            inherit inputs outputs;
      };
      in
          flake-utils.lib.eachDefaultSystem (
      # fennel language server overlay
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
        with pkgs; {

          # Devshells ('nix develop')
          devShells.default = mkShell {
            buildInputs = [
              nil
              stylua
              sumneko-lua-language-server
            ];
          };

          formatter = alejandra;

          ## nix build
          # packages = util.forEachPkgs (pkgs:
          #         import ./nix/pkgs { inherit pkgs; }
          #         );

          # Apps (`nix run`)
          # apps = util.forEachPkgs (pkgs:
          #         import ./nix/apps { inherit pkgs; }
          #         );

          # Home Manager modules
          homeManagerModules = import ./nix/modules/home-manager {
              inherit inputs outputs;
          };
        }
    );
}
