packages: _inputs: {
  inputs,
  lib,
  pkgs,
  config,
}:
with lib; let
  cfg = config.programs.nyoom;
in {
  ##User Options for user to pass
  options.programs.nyoom = {
    enable = mkEnableOption "Nyoom:: A modular Neovim IDE";
    ## TODO:: Add support for certain Lang features, or perhaps add luarocks support Instead of packer
    viAlias = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Symlinks "vi" -> "nvim" binaries
      '';
    };
    vimdiffAlias = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Alias vimdiff -> nvim -d
      '';
    };
    appName = mkOption {
      type = types.str;
      default = "nyoom";
      description = ''
        Appname to choose for neovim, default is "nyoom"
      '';
    };
    isIsolated = mkOption {};
    nightly = mkOption {};
    envVars = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether or not to make nvim the defaulty editor/visual/GitEditor
      '';
    };
    #rollback = mkOption {type = types.bool; default = true; descriptions = ''Whether to enable rollbacks caching with nix''}
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = mkIf cfg.nightly {
      overlays = [
        inputs.neovim-nightly-overlay.overlay
      ];
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      package = pkgs.neovim-nightly;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
    home.sessionVariables = mkIf cfg.envVars {
      EDITOR = "nvim -u NORC";
      VISUAL = "nvim -u NORC";
      GIT_EDITOR = "nvim -u NONE";
    };

    # Thanks to srid and Konradmalik for this::
    xdg.configFile.${cfg.appName} = {
      enable = !cfg.isIsolated;
      # TODO:: safety test this, ya fking doof. U nearly broke ur config with this one!!
      # onChange = ''
      # rm -rf ${config.xdg.cacheHome}/${cfg.appName}
      # '';
      ".config/nvim" = {
        source = ./.;
        recursive = true;
      };
    };
  };
}
