# { lua, ... }:
# * Will make the ../init.lua file permenant in the nix store, thus avoiding GC
((builtins.concatStringsSep "\n") (
  map (x: "luafile ${x}") [
    #
    ../init.lua
  ]
)
  /**
      NOTE:
      Convert the base wrappers::
              ``"'--inherit-argv0' '--set' 'GEM_HOME' '/nix/store/2dpri5qnagqp15prpz36h0c5sghk2azn-neovim-ruby-env/lib/ruby/gems/3.1.0' '--suffix' 'PATH' ':' '/nix/store/2dpri5qnagqp15prpz36h0c5sghk2azn-neovim-ruby-env/bin' '--prefix' 'LUA_PATH' ';' '/nix/store/ivb32bi4wk08xi6zjvh7wp3iyj7qq0l3-luajit-2.1.1693350652-env/share/lua/5.1/?.lua;/nix/store/ivb32bi4wk08xi6zjvh7wp3iyj7qq0l3-luajit-2.1.1693350652-env/share/lua/5.1/?/init.lua' '--prefix' 'LUA_CPATH' ';' '/nix/store/ivb32bi4wk08xi6zjvh7wp3iyj7qq0l3-luajit-2.1.1693350652-env/lib/lua/5.1/?.so' "``
    To neovim-defaults like below. Specifically, set `vim.env.BIN` to the output of `mkBinPath`
  */
  # ++ [
  #   #lua 
  #   ''
  #     package.path = package.path .. ';' .. ${lua.luaPaths};
  #     package.cpath = package.cpath  .. ';' .. ${lua.luaCPaths}
  #   ''
  # ]
)
