{ ... }:
## Running Busted Tests with luarocks + .nfnl macro tests
{
  perSystem = { pkgs, ... }:
    {
      # checks.integration-nightly = pkgs.neorocksTest {
      #   name = "integration-nightly";
      #   pname = "rocks.nvim";
      #   src = ./.;
      #   neovim = pkgs.neovim-custom;
      #   luaPackages = ps:
      #     with ps; [
      #       toml-edit
      #       toml
      #       fidget-nvim
      #       fzy
      #       nvim-nio
      #     ];
      #
      #   extraPackages = with pkgs; [
      #     wget
      #     git
      #     cacert
      #   ];
      #
      #   preCheck = ''
      #     export HOME=$(realpath .)
      #   '';
      # };
      # checks.nfnl-plenary = pkgs.stdenv.mkDerivation {
      #   name = "Nfnl Macro Tests";
      #
      # };
    };
}
