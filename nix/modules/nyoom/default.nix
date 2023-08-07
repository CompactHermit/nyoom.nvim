{ inputs, outputs, ... }:
{ lib, pkgs, config, ... }:

let
  ## Set cfg flag for nyoom
  cfg = config.programs.nyoom;
in 
{
    imports =
        [
        ## TODO:: add Mason Module
        ];

    options =
    {
        programs.nyoom = {
            enable = lib.mkEnableOption "Nyoom";
        };
    };

    config =
        lib.mkIf cfg.enable {
            nixpkgs = {
                overlays = [
                    inputs.neovim-nightly-overlay.overlay
                    # inputs.cornelis.overlays.cornelis
                ];
            };

            programs.neovim = {
                enable = true;
                package = pkgs.neovim-nightly;
                defaultEditor = true;
                viAlias = true;
                vimAlias = true;
                vimdiffAlias = true;
                ##plugins = with pkgs.vimPlugins; [
                        ##nvim-treesitter.withAllGrammars
                        ##cornelis
                ##];
            };

            home.packages = with pkgs; [
            ## CLI dependencies
                    ripgrep
                    fd
                    git

                    rust-analyzer
                    statix
                    sumneko-lua-language-server
                    stylua
                    nodePackages.bash-language-server
                    nodePackages.yaml-language-server
                    nodePackages.typescript-language-server
                    clang-tools
                    # gopls
                    ## Compiling native extensions
                    # gcc
                    gnumake
                    ];
        };
}
