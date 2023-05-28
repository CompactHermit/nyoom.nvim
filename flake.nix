{
  description = "DevShell for neovim config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      # fennel language server overlay
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [(self: super: {fennel-language-server = super.callPackage ./nix/fennel-language-server.nix {};})];
        };
      in
        with pkgs; {
          ## Note:: Need to find what flake the "# object" is coming from
          devShells.default = mkShell {
            buildInputs = [
              # Language servers / Debuggers / Adapters
              # IDK where exectly Lazy-vim is downloaded, which is a bit annoying, fml
              act
              fennel
              # fennel-language-server dont use, will use hotpot diagnostics instead
              fnlfmt
              marksman
              #nil
              nodePackages.cspell
              nodePackages.prettier
              nodejs
              stylua
              sumneko-lua-language-server
              neovim
              # quarto
            ];
          };
        }
    );
}
