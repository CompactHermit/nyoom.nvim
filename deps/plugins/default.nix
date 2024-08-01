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
    # "neorg-se" #NOTE: we never call any of the bins anyway, we should leave this exposed, so we can just overlay this to pkgs.
    # "norg-fmt"
    "override"
    "overrideDerivation"
  ];

  /*
    HACK: (Hermit)
    We don't really need `buildVimPlugin` since we directly append PackPath
    Instead, we should be linkfarming `deps.src` and construct packpath,
    calling `buildVImPlugin ...` 200 times is really fucking stupid
  */
  reqPlugs = lib.flip lib.pipe [
    (builtins.attrValues)
    (lib.flatten)
    (e: lib.attrsets.filterAttrs (n: v: builtins.elem n e) plugins)
    (builtins.attrValues)
    (map (
      e:
      (buildVimPlugin { inherit (e) pname src version; }).overrideAttrs (oa: {
        patches = cfg.settings.plugins."${e.pname}".patches or [ ];
        postInstall = oa.postInstall + (cfg.settings.plugins.${e.pname}.postInstall or "");
      })
    ))
  ] cfg.plugins;
  #TODO: (Hermit) Remove this bullshit, and not rely on Teto's dogshit `packdir` function.
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
