{
  inputs,
  lib,
  config,
  runCommand,
  fetchurl,
  stdenvNoCC,
  pkgs,
  autoreconfHook,
  ...
}:
let

  inherit (lib) concatStringsSep;

  cfg = config.neohermit;

  stringSeps = concatStringsSep "\n" (
    map (file: "rm -rf $out/share/nvim/${file}") [
      # "runtime/ftplugin.vim"
      "runtime/tutor"
      # "runtime/indent.vim"
      "runtime/menu.vim"
      "runtime/mswin.vim"
      "runtime/plugin/gzip.vim"
      "runtime/plugin/man.lua"
      "runtime/plugin/matchit.vim"
      "runtime/plugin/matchparen.vim"
      "runtime/plugin/netrwPlugin.vim"
      "runtime/plugin/rplugin.vim"
      "runtime/plugin/shada.vim"
      "runtime/plugin/spellfile.vim"
      "runtime/plugin/tarPlugin.vim"
      "runtime/plugin/tohtml.vim"
      "runtime/plugin/tutor.vim"
      "runtime/plugin/zipPlugin.vim"
    ]
  );
  /**
    DOCS:
    mkDeps :: <PATH::nvim-src> -> [<dep::NVIM-DEP>]
        Build Neovim With Correct dep hashes, uses the `cmake.deps/deps.txt` file to generate them
        nvim's cmake.deps/deps.txt has deps in form::
            `DEPS_TRIVAL_UNDERSCOPE_(URL|SHA256) (<HASH>|<URL>)`
            [e.g::LPEG_URL https://github.com/neovim/deps/raw/d495ee6f79e7962a53ad79670cb92488abe0b9b4/opt/lpeg-1.1.0.tar.gz]
        Since the last underscore gives a (URL/SHA256), we can convert them to an attrset and obtain the following deplist
            {depname = {url = ...; hash = ...;}}
        We then promptly pass that onto `fetchurl` and make the source from there
  */
  mkDeps = lib.pipe "${inputs.nvim-git}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([[:alnum:]_]+)_(URL|SHA256)[[:blank:]]+([^[:blank:]]+)[[:blank:]]*"))
    #(map (builtins.match "([(?!TREESITTER)[:alnum:]_]+)_(URL|SHA256)[[:blank:]]+([^[:blank:]]+)[[:blank:]]*")) 
    (lib.remove null)
    #(__filter (x: __match "(TREESITTER).*" (__head x) == null)) # TODO: To stupid for a proper regex-lookbehinds, will try to understand how nix implements them fml
    (builtins.foldl' (
      acc: elem:
      let
        name = lib.toLower (builtins.elemAt elem 0);
        key = lib.toLower (builtins.elemAt elem 1);
        value = builtins.elemAt elem 2;
      in
      lib.recursiveUpdate acc { ${name}.${key} = value; }
    ) { })
    (builtins.mapAttrs (_: attrs: fetchurl attrs))
  ];
  versionFromSrc =
    src:
    # Hacky Way for neovim to get the right src-drv
    lib.pipe src.name [
      # Remove .tar.* extension
      (lib.splitString ".tar.")
      builtins.head
      builtins.parseDrvName
      (parsed: if parsed.version != "" then parsed.version else lib.removePrefix "v" parsed.name)
      (builtins.substring 0 12)
    ];

  replaceInput = prev: drv: builtins.filter (i: lib.getName i != lib.getName drv) prev ++ [ drv ];
  rockspecUpdateVersion =
    orig: name: version:
    let
      # Revision is required after version
      v = if lib.hasInfix "-" version then version else "${version}-1";
    in
    runCommand "${name}-${v}.rockspec" { } ''
      sed -E "s/(version[[:blank:]]*=[[:blank:]]*[\"'])(.*)([\"'])/\1${v}\3/" ${orig} >$out
    '';

  # nlua::
  luaPackageOverrides = final: prev: {
    luv =
      (prev.luaLib.overrideLuarocks prev.luv rec {
        version = versionFromSrc mkDeps.luv;
        src = mkDeps.luv;
        # Update version in rockspec file
        knownRockspec = rockspecUpdateVersion prev.luv.knownRockspec "luv" version;
      }).overrideAttrs
        (prevAttrs: {
          buildInputs = replaceInput prevAttrs.buildInputs libuv;
        });
    libluv = prev.libluv.overrideAttrs (prevAttrs: {
      inherit (final.luv) version src;
      buildInputs = replaceInput prevAttrs.buildInputs libuv;
    });
    lpeg = prev.luaLib.overrideLuarocks prev.lpeg rec {
      version = versionFromSrc mkDeps.lpeg;
      src = mkDeps.lpeg;
      knownRockspec = rockspecUpdateVersion prev.lpeg.knownRockspec "lpeg" version;
    };
  };
  # libuv::
  libuv = pkgs.libuv.overrideAttrs {
    version = versionFromSrc mkDeps.libuv;
    src = mkDeps.libuv;
  };
  # LuaJIT::
  lua = pkgs.luajit.override rec {
    version =
      let
        relverFile = stdenvNoCC.mkDerivation {
          name = "luajit-relver";
          inherit src;
          phases = [
            "unpackPhase"
            "installPhase"
          ];
          installPhase = "cp .relver $out";
        };
        relver = lib.fileContents relverFile;
      in
      "2.1." + relver;
    src = mkDeps.luajit;
    packageOverrides = luaPackageOverrides;
    #enable52Compat = true;
    self = lua;
  };

  # msgPack ::
  msgpack-c = pkgs.msgpack-c.overrideAttrs {
    version = versionFromSrc mkDeps.msgpack;
    src = mkDeps.msgpack;
  };

  # Unibilium::
  unibilium = pkgs.unibilium.overrideAttrs (prev: {
    version = versionFromSrc mkDeps.unibilium;
    src = mkDeps.unibilium;
    # autoreconf is needed for newer versions to generate Makefile
    nativeBuildInputs = lib.unique (prev.nativeBuildInputs ++ [ autoreconfHook ]);
  });

  # libvterm neovim fork
  libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs {
    version = versionFromSrc mkDeps.libvterm;
    src = mkDeps.libvterm;
  };

in
(cfg.package.override {
  inherit
    libuv
    lua
    msgpack-c
    unibilium
    libvterm-neovim
    ;
}).overrideAttrs
  (oa: {
    src = cfg.src;
    version = cfg.src.shortRev or "dirty";
    buildInputs = (oa.buildInputs or [ ]) ++ [ ];
    preConfigure = ''
      sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/"
    '';
    postInstall = ''
      #${if oa ? postInstall then oa.postInstall else ""}
      ${stringSeps}
    '';
  })
