{...}: {
  perSystem = {
    lib,
    pkgs,
    ...
  }: {
    apps = {
      sync = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "Nyoom:: Sync";
          text = ''
            cd ~/.config/nvim #Hack for weird ass fnl searching
            XDG_CACHE_HOME=/tmp/nyoom NYOOM_CLI=true ${lib.getExe pkgs.neovim-custom} --headless -c 'autocmd User PackerComplete quitall' -c 'lua require("packer").sync()'
          '';
        };
      };
    };
  };
}
