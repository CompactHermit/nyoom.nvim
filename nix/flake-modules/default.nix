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
                      # options.lazy = mkOption { type = listOf str; };
                      # options.eager = mkOption { type = listOf str; };
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
                  description = "Whether to remove unnecasry paths";
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
            concatMapStringsSep ";" pkgs.lua51Packages.getLuaCPath (with pkgs.lua51Packages; cfg.lua.extraPacks)
          }"''
          + " "
          + ''--suffix LUA_PATH ";" "${
            concatMapStringsSep ";" pkgs.lua51Packages.getLuaPath (with pkgs.lua51Packages; cfg.lua.extraPacks)
          };${
            concatMapStringsSep ";" pkgs.luajitPackages.getLuaPath (with pkgs.luajitPackages; cfg.lua.jit)
          }"''
          + " "
          + "--prefix PATH : ${binpath}"
          + " "
          + ''--set LIBSQLITE_CLIB_PATH "${pkgs.sqlite.out}/lib/libsqlite3.so"''
          + " "
          + ''--set LIBSQLITE "${pkgs.sqlite.out}/lib/libsqlite3.so"'';
        Dhaos = pkgs.wrapNeovimUnstable (cfg.package.overrideAttrs (oa: {
          src = cfg.src;
          version = inputs.nvim-git.shortRev or "dirty";
          #lua = pkgs.luajit.override ({ enable52Compat = false; }); #NOTE (Hermit): <04/22> There might be a way to merge all luaAttrs here, rather then export them with the wrapper, hmmm
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
