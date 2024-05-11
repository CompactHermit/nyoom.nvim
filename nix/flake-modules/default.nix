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
                  type = anything;
                  description = "Src to use";
                  default = "${pkgs.neovim-unwrapped}";
                };
                package = mkOption {
                  type = anything;
                  description = ''
                    Which Neovim Package to use
                  '';
                  default = pkgs.neovim-unwrapped;
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
                      /**
                        TODO: Add this shit to lib.types, following the same design as treefmt
                        TEST:
                        Try using::
                        ```nix
                            \\ {setting = {type = attrsOf ({plugin = str;
                                           patch = path;
                                           phaseOverride = []; #Custom OverrdeAttrs for Plugin
                                           disableHook = listOf (some strict set of strings, wonder if nix has such options?);
                                })
                            };}
                        ```
                      */
                    }
                  );
                  description = ''
                    Strings of Plugins::
                        name:: Of form ::input.<String::name>
                        lazy:: Of form ::<True|False>
                  '';
                  default = [ ];
                };
                strip = mkOption {
                  type = bool;
                  description = "Whether to remove unnecessary paths";
                  default = false;
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
                temp = mkOption {
                  type = path;
                  description = "TempDir for XDG_CACHE_HOME";
                  default = "/tmp/nyoom";
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
        #TODO (Hermit):: Abstract Away the makeNeovimConfig option
        inherit (pkgs.neovimUtils) makeNeovimConfig grammarToPlugin;
        __lib = import ./mklib.nix { inherit inputs lib pkgs; };
        __plugins = import ./mkPlugin.nix { inherit pkgs inputs lib; };
        cfg = config.neohermit;
        NeovimConfig = makeNeovimConfig {
          customRC = import ../default.nix;
          plugins =
            with pkgs;
            [
              parinfer-rust
              (symlinkJoin {
                name = "nvim-treesitter";
                paths = [
                  pkgs.vimPlugins.nvim-treesitter.withAllGrammars
                  (map grammarToPlugin (
                    # (__filter (x: __match ".*(norg).*" x.pname == null)
                    pkgs.vimPlugins.nvim-treesitter.allGrammars ++ (__attrValues (__lib.mkTreesitter cfg.extraParsers))
                  ))
                ];
              })
            ]
            /**
              TODO: Find A way to just add a patch, or add a `options.plugins.*.doCheck = <bool>`, to patch or change certain plugins.
              HACK::
              From:: https://github.com/MagicDuck/grug-far.nvim/blob/main/doc/grug-far.txt
              Grug Currently has a Double Call to setup in it's docs.
              This just fixes that bullshit by ignoring the gendock hook completely. Because fuck docs
            */
            ++ [
              {
                optional = true;
                plugin = (__head (__plugins { lazy = [ "grug" ]; }).lazy).plugin.overrideAttrs (_: {
                  nativeBuildInputs = [ ];
                });
              }
            ]
            ++ (lib.trivial.pipe cfg.plugins [
              __plugins
              __attrValues
              concatLists
            ])
            ++ (cfg.defaultPlugins);
        };
        stringSeps = concatStringsSep "\n" (
          map (file: "rm -rf $out/share/nvim/${file}") [
            #"runtime/ftplugin.vim"
            "runtime/tutor"
            #"runtime/indent.vim"
            "runtime/menu.vim"
            "runtime/mswin.vim"
            "runtime/plugin/gzip.vim"
            "runtime/plugin/man.lua"
            "runtime/plugin/matchit.vim"
            "runtime/plugin/matchparen.vim"
            "runtime/plugin/netrwPlugin.vim"
            "runtime/plugin/rplugin.vim"
            # "runtime/plugin/shada.vim"
            "runtime/plugin/spellfile.vim"
            "runtime/plugin/tarPlugin.vim"
            "runtime/plugin/tohtml.vim"
            "runtime/plugin/tutor.vim"
            "runtime/plugin/zipPlugin.vim"
          ]
        );
        wrapperArgs =
          let
            binpath = makeBinPath cfg.bins;
          in
          escapeShellArgs NeovimConfig.wrapperArgs
          + " "
          + ''--suffix LUA_CPATH ";" "${
            concatMapStringsSep ";" pkgs.lua51Packages.getLuaCPath (cfg.lua.extraPacks)
          }"''
          + " "
          + ''--suffix LUA_PATH ";" "${
            concatMapStringsSep ";" pkgs.lua51Packages.getLuaPath (cfg.lua.extraPacks)
          };${concatMapStringsSep ";" pkgs.luajitPackages.getLuaPath (cfg.lua.jit)}"''
          + " "
          + "--prefix PATH : ${binpath}"
          + " "
          + ''--set LIBSQLITE_CLIB_PATH "${pkgs.sqlite.out}/lib/libsqlite3.so"''
          + " "
          + ''--set LIBSQLITE "${pkgs.sqlite.out}/lib/libsqlite3.so"'';
        Dhaos = pkgs.wrapNeovimUnstable (cfg.package.overrideAttrs (oa: {
          src = cfg.src;
          version = inputs.nvim-git.shortRev or "dirty";
          #lua = pkgs.luajit.override ({ enable52Compat = false; }); #NOTE: (Hermit): <05/05> This is on by default
          buildInputs = (oa.buildInputs or [ ]) ++ [ ];
          cmakeFlags = [ "" ];
          preConfigure = ''
            sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/"
          '';
          postInstall = ''
            #${if oa ? postInstall then oa.postInstall else ""}
            ${stringSeps}
          '';
        })) (NeovimConfig // { inherit wrapperArgs; });
      in
      {
        packages = {
          Dhaos = Dhaos;
          #faker = "";
          default = withSystem system (
            { config, ... }:
            pkgs.writeShellApplication {
              name = "nvim";
              text = ''
                XDG_CACHE_HOME=${cfg.temp} ${getExe Dhaos} "$@"
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
