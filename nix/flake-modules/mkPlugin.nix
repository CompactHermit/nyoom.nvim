{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (pkgs.vimUtils) buildVimPlugin;
  inherit (lib) mapAttrs;
  /**
    TYPE:
    Plugin =  {lazy :: <Bool.bool>; pname :: <String.Plugin>;}
    __functor:: self: __plugins -> [plugin]
  */
  mkNeovimPlugin = src: pname: __extraOpts: __opt: {
    plugin = buildVimPlugin (
      {
        inherit pname src;
        version = src.lastModifiedDate;
      }
      // __extraOpts
    );
    optional = __opt;
  };

  luaByte =
    pkgs.writeText "lua-byte-compile.lua" # lua
      ''
        for _, file in ipairs(_G.arg) do
          local chunk = assert(loadfile(file))
          -- Re-create symbolic link as a regular file
          assert(os.remove(file))
          local out = assert(io.open(file, "wb"))
          assert(out:write(string.dump(chunk)))
          out:close()
        end
      '';
  luaByteHook =
    pkgs.makeSetupHook
      {
        name = "lua-byte";
        substitutions = {
          nvimBin = "${pkgs.Dhaos}/bin/nvim";
          luaBHook = "${luaByte}";
        };
      }
      (
        pkgs.writeShellApplication "lua-hook.sh" # sh
          ''
            luaByteCompile() {
                echo "Executing luaByteCompile, stolen shameless from stasjoks"
                if [[ -f $out ]]; then
                    if [[ $out = *.lua ]]; then
                        @nvimBin@ -l @luaByteCompileScript@ $out
                    fi
                else
                    (
                        shopt -s nullglob globstar
                        @nvimBin@ -l @luaByteCompileScript@ $out/**/*.lua
                    )
                fi
            }

            preFixupHooks+=(luaByteCompile)
          ''
      );
  fnlTrans = pkgs.makeSetupHook {
    name = "fennel-compile-hook";
    substitutions = { };
  };
in
/**
  TODO: (Hermit) Refactor this, I mean look at this, aren't you ashamed of this?
  HACK:
  Just hardcheck for the type. Once we define a proper deferredModule, then we only need to apply this step to objects
  NOTE: Inspired by @stasjoks work with neovim, we remove the gen-doc hooks and add a byte-hook + doc-hook
*/
{
  __functor =
    self: p:
    mapAttrs (
      n: v:
      if (n == "lazy") then
        (map (
          x:
          let
            cfg =
              if (builtins.elem x (builtins.attrNames config.neohermit.settings.plugins)) then
                {
                  inherit (config.neohermit.settings.plugins."${x}")
                    postInstall
                    patches
                    docs
                    dependencies
                    ;
                }
              else
                { };

          in
          mkNeovimPlugin inputs."${x}" x cfg true
        ) v)
      else if (n == "eager") then
        (map (x: mkNeovimPlugin inputs."${x}" x { } false) v)
      else
        throw "Neovim Plugin Not specified"
    ) p;
}
