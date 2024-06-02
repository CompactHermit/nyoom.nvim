{ withSystem, ... }:
{
  inputs,
  flake-parts-lib,
  lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { pkgs, ... }:
      let
        inherit (lib) mkOption types genAttrs;
      in
      {
        options.neohermit = mkOption {
          description = "Neovim Loader";
          type =
            with types;
            submodule {
              options = {
                name = mkOption {
                  type = str;
                  description = "APPNAME to use";
                  default = "Faker";
                };
                src = mkOption {
                  type = path;
                  description = "Path for Building Nightly Source";
                  default = "${pkgs.neovim-unwrapped}";
                };
                package = mkOption {
                  type = package;
                  description = ''
                    Which Neovim Package to use
                  '';
                  default = pkgs.neovim-unwrapped;
                };
                settings = {
                  bytecompile = mkOption {
                    type = bool;
                    description = ''
                      Whether to use the `vim.loader` or our own bytecompiled cache
                    '';
                    default = false;
                  };
                  strip = mkOption {
                    type = bool;
                    description = "Whether to remove unnecessary paths";
                    default = false;
                  };
                  temp = mkOption {
                    type = path;
                    description = "TempDir for XDG_CACHE_HOME";
                    default = "/tmp/nyoom";
                  };
                  plugins = mkOption {
                    /**
                      HACK: Very, very bad way of handling submodules.
                      TODO: (Hermit) Understand and fking use `types.deferredModule`, pass these types into an eval-module and then
                    */
                    type = lazyAttrsOf (submodule {
                      options =
                        let
                          plugopts = {
                            patches = listOf (either path str);
                            postInstall = str;
                            docs = bool;
                          };
                        in
                        genAttrs (__attrNames plugopts) (
                          x:
                          mkOption {
                            type = nullOr plugopts."${x}";
                            description = "${x}";
                            default = null;
                          }
                        )
                        // {
                          dependencies = mkOption {
                            type = nullOr (listOf package);
                            description = "Packages Deps";
                            default = [ ];
                          };
                        };
                    });
                  };
                };
                lua = {
                  extraPacks = mkOption {
                    type = listOf package;
                    description = "Extra Lua Packages";
                    default = [ ];
                  };
                  jit = mkOption {
                    type = listOf package;
                    description = "Extra Lua Packages";
                    default = [ ];
                  };
                };
                /**
                  NOTE: (Hermit)
                      Would be pretty fking useful to have some kind of plugin-wide scope.
                      This means dependency checking will be done by nix, and failure to find dependency result no Output,
                          rather then waiting for failure on lua-side.
                    OR, we could, you know, fucking use `vimPlugin.extend` and define dependencies there?
                */
                plugins = mkOption {
                  type = (
                    submodule {
                      options =
                        let
                          _types = [
                            "lazy"
                            "eager"
                          ];
                        in
                        genAttrs _types (
                          _:
                          mkOption {
                            type = listOf str;
                            description = "${types}-Loaded Plugin";
                          }
                        );
                    }
                  );
                  description = ''
                    Strings of Plugins::
                        name:: Of form ::input.<String::name>
                        lazy:: Of form ::<True|False>
                  '';
                  default = [ ];
                };
                extraParsers = mkOption {
                  type = listOf str;
                  description = ''
                    Treesitter Parsers to build:: Will default to the flake's inputs
                  '';
                  default = [ ];
                };
                defaultPlugins = mkOption {
                  type = listOf package;
                  description = ''
                    List of Nix-Inbuilt VimPlugins
                    TODO (Hermit):: Add typechecking for this
                  '';
                  default = [ ];
                };
                bins = mkOption {
                  type = listOf package;
                  description = ''
                    Extra Bins to wrap in $PATH
                  '';
                  default = [ ];
                };
              };
            };
        };
      }
    );
  };
  config = {
    perSystem =
      {
        config,
        lib,
        pkgs,
        system,
        ...
      }:
      let
        inherit (lib)
          getExe
          makeBinPath
          escapeShellArgs
          concatStringsSep
          concatMapStringsSep
          concatLists
          ;
        inherit (pkgs.neovimUtils) makeNeovimConfig grammarToPlugin;
        cfg = config.neohermit;
        __lib = import ./mklib.nix { inherit inputs lib pkgs; };
        neovimPatched = pkgs.callPackage ./mkNeovim.nix { inherit config inputs; };
        __wrapper = import ./mkWrapper.nix { inherit config; };
        __plugins = import ./mkPlugin.nix {
          inherit
            pkgs
            inputs
            lib
            config
            ;
        };

        /*
          NOTE: (Hermit)
          For the direction I'm heading with this build, we really don't need `makeNeovimConfig`
          The plan is just to have an init.lua with the following setup::
                1. PackDir (bytecompiled) set as rtp (shouldnt be a problem, really it's just)
                2. each luaPackage setup with package.luaPath and package.luacpath
                3. Hotpot Compile Hook
                    - (using nightly fennel, might require patching the fennel dir, but I'd need to ask)
                4. Make default fennel files -> luaTbl -> Plugin, and deprecate the use of config dir and `luafile`.
          This would imply completely revamping the module system, as well as removing packer.
          Additionally, the monkey-patched
        */
        NeovimConfig = makeNeovimConfig {
          customRC = import ../default.nix;
          plugins =
            with pkgs;
            [
              /**
                NOTE: (Hermit)
              */
              parinfer-rust
              (symlinkJoin {
                name = "nvim-treesitter";
                paths = [
                  vimPlugins.nvim-treesitter.withAllGrammars
                  (map grammarToPlugin ((__attrValues (__lib.mkTreesitter cfg.extraParsers))))
                  (__attrValues (builtins.removeAttrs vimPlugins.nvim-treesitter.grammarPlugins cfg.extraParsers))
                ];
              })
            ]
            ++ (lib.trivial.pipe cfg.plugins [
              __plugins
              __attrValues
              concatLists
            ])
            ++ (cfg.defaultPlugins);
          #++ (pkgs.vimUtils.builVimPlugin (pname = "hermit"; version = "adjoint-rev"; src = (<todo>); )) #TODO: (Hermit) <4> Some kind of hotpot-compile hook?
        };

        /*
          TODO:
           Just add them to package.preload in the init.lua file
        */
        wrapperArgs =
          let
            binpath = makeBinPath cfg.bins;
          in
          escapeShellArgs NeovimConfig.wrapperArgs
          + " "
          + "--prefix PATH : ${binpath}"
          + " "
          + ''--set LIBSQLITE_CLIB_PATH "${pkgs.sqlite.out}/lib/libsqlite3.so"''
          + " "
          + ''--set LIBSQLITE "${pkgs.sqlite.out}/lib/libsqlite3.so"'';

        Dhaos = pkgs.wrapNeovimUnstable neovimPatched (
          NeovimConfig
          // {
            inherit wrapperArgs;
            luaRcContent = # lua
              ''
                -- HACK: (Hermit) Temporary hack for all the`wrapperArg` hell. Simply expose rtp here, all package paths here.
                --      Once We remove the wrapper, we can simply make this a luafile with::
                --       ```lua
                --              <wrapperArgsHere>, set rtp + $\{custom-packdir}/start, and set preload here::
                --               "vim.opt.rtp:prepend($\{packDir-start})" 
                --              vim.loader.enable()
                --                  ...........
                --       ```
                vim.loader.enable()
                vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')

                local default_plugins = {"2html_plugin", "getscript", "getscriptPlugin", "gzip", "logipat", "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers", "matchit", "tar", "tarPlugin", "rrhelper", "spellfile_plugin", "vimball", "vimballPlugin", "zip", "zipPlugin", "tutor", "rplugin", "syntax", "synmenu", "optwin", "compiler", "bugreport"}

                for _, plugin in pairs(default_plugins) do vim.g[("loaded_" .. plugin)] = 1 end

                -- Setup lua/luaCPATH, would've loved this in fennel but we cant, fml
                package.cpath = package.cpath .. ";" .. "${
                  (concatMapStringsSep ";" pkgs.lua51Packages.getLuaCPath (cfg.lua.extraPacks ++ cfg.lua.jit))
                }" 
                package.path = package.path .. ";" .. "${
                  (concatMapStringsSep ";" pkgs.lua51Packages.getLuaPath (cfg.lua.extraPacks ++ cfg.lua.jit))
                }"

                -- HACK: Temporary hack for lazyDev, will redo-this when we deprecate the wrapper
                vim.g.PACKDIR = "${(pkgs.vimUtils.packDir NeovimConfig.packpathDirs)}"

                -- NOTE: Hotpot doesn't need a config dir yet, so we can just set it up now
                require("hotpot").setup({enable_hotpot_diagnostics = true, provide_require_fennel = true, compiler = {macros = {allowGlobals = true, compilerEnv = _G, env = "_COMPILER"}, modules = {correlate = true, useBitLib = true}}})

                -- We can also call stdlib here
                local stdlib = require("core.lib")
                for k, v in pairs(stdlib) do rawset(_G, k, v) end
              '';
          }
        );
      in
      {
        packages = {
          Dhaos = Dhaos; # HACK: (Hermit) for easier debugging
          faker = neovimPatched;
          default = withSystem system (
            { config, ... }:
            pkgs.writeShellApplication {
              name = "nvim";
              text = ''
                XDG_CACHE_HOME=${cfg.settings.temp} ${getExe Dhaos} "$@"
              '';
            }
          );
        };
        apps = {
          sync = {
            type = "app";
            program = pkgs.writeShellApplication {
              name = "Nyoom:: Sync";
              text = ''
                cd ~/.config/nvim
                echo "Deleting Temp Cache"
                rm -rf /tmp/nyoom
                export XDG_CACHE_HOME=/tmp/nyoom
                NYOOM_CLI=true  ${getExe Dhaos} --headless -c 'autocmd User PackerComplete quitall' -c 'lua require("packer").sync()'
              '';
            };
          };
        };
      };
  };
}
