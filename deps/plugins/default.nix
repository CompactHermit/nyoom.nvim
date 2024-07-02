{
  buildEnv,
  config,
  callPackage,
  lib,
  vimUtils,
  self,
}:
let
  inherit (vimUtils) buildVimPlugin packDir;
  cfg = config;
  deps = callPackage ./_sources/generated.nix { };
  nvim-treesitter = callPackage ../parsers/default.nix { config = cfg; };
  plugins = builtins.removeAttrs deps [
    "norg-fmt"
    "override"
    "overrideDerivation"
  ];

  #HACK: (Hermit) This needs a serious fix, this actually is a perf hit without a cache
  reqPlugs = lib.flip lib.pipe [
    (builtins.attrValues)
    (lib.flatten)
    (e: lib.attrsets.filterAttrs (n: v: builtins.elem n e) plugins)
    (builtins.attrValues)
    (map (
      e:
      (buildVimPlugin { inherit (e) pname src version; }).overrideAttrs (oa: {
        patches = cfg.settings.plugins."${e.pname}".patches or [ ];
      })
    ))
  ] cfg.plugins;
  partition =
    let
      pluginsPartitioned = lib.partition (x: builtins.elem x.pname cfg.plugins.lazy or false) reqPlugs;
    in
    {
      start =
        pluginsPartitioned.wrong ++ (config.defaultPlugins)
      #NOTE:: We need hotpot to recompile on changes for now, so for now we unset the plugin opt.
      # ++ [
      #   (buildVimPlugin {
      #     pname = "hermitage";
      #     version = "adjoint-rev";
      #     src = "${self}";
      #   })
      # ]
      ;
      opt = pluginsPartitioned.right ++ [ nvim-treesitter ];
    };
  hermitPacks.all = partition;
in
#TODO: Remove Usage of `packDir` and just buildEnv the entire thing, and allow for `makeExtensible` and shits
{
  customPackdir = packDir hermitPacks;
}
