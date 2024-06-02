{ self, ... }:
## Running Busted Tests with luarocks +  hotpot tests
{
  perSystem =
    { pkgs, self', ... }:
    {
      checks.neorocks-test = pkgs.neorocksTest {
        src = self;
        name = "Nyoom-Test-Suite";
        neovim = self'.packages.faker;
        luaPackages = ps: with ps; [ plenary-nvim ];
      };
    };
}
