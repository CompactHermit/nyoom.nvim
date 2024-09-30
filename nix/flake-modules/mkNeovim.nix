{
  lib,
  config,
  runCommand,
  fetchurl,
  stdenvNoCC,
  pkgs,
  autoreconfHook,
  applyPatches,
  stdenv,
  fetches,
  tree-sitter-nightly,
  fetchpatch,
}:
let

  inherit (lib) concatStringsSep;

  cfg = config.neohermit;

  patches = [
    #feat(lsp): LSP doc Highlight API
    # (fetchpatch {
    #   url = "https://github.com/neovim/neovim/pull/30841.diff";
    #   sha256 = "sha256-uISrPBuA4MqP2qw7THtFL1d4QF+SxOtDKj7aDD5Otas=";
    # })
    # (fetchpatch {
    #   url = "https://github.com/neovim/neovim/pull/30884.diff";
    #   sha256 = "sha256-fcwBAatd1mlrEtyxvyEt713rMPLC23dbFOEdb8WAkNw=";
    # })
    # (fetchpatch {
    #   url = "https://github.com/neovim/neovim/pull/30319.diff";
    #   sha256 = "sha256-XtM4Dgd+ywLUih67DqacBXPvFkz94Nyp+qXVOMATqBo=";
    # })
    # (fetchpatch {
    #   url = "https://github.com/neovim/neovim/pull/30227.patch";
    #   sha256 = "sha256-IMd3xb7VLWZG6iDHapavRDt4B2lN84yhjXcSBlQ7BPo=";
    # })
    #perf(treesitter): cache the parser check in foldexpr
    # (fetchpatch {
    #   url = "https://github.com/neovim/neovim/pull/30164.patch";
    #   sha256 = "sha256-HjEWsqMwi8G7eoBYWxJrhRM4RJSYj9YqSbqvzDHfoTA=";
    # })
  ];
  patched-src = applyPatches {
    name = "neovim-source";
    src = cfg.src;
    inherit patches;
    patchFlags = [
      "-p1"
      "--no-backup-if-mismatch"
    ];
  };

  stringSeps = concatStringsSep "\n" (
    map (file: "rm -rf $out/share/nvim/${file}") [
      #"runtime/ftplugin.vim"
      "runtime/tutor"
      "runtime/indent.vim"
      "runtime/menu.vim"
      "runtime/mswin.vim"
      "runtime/plugin/gzip.vim"
      "runtime/plugin/tohtml.lua"
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
  mkDeps = lib.pipe "${fetches.nvim-git.src}/cmake.deps/deps.txt" [
    builtins.readFile
    (lib.splitString "\n")
    (map (builtins.match "([[:alnum:]_]+)_(URL|SHA256)[[:blank:]]+([^[:blank:]]+)[[:blank:]]*"))
    (lib.remove null)
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
        knownRockspec = rockspecUpdateVersion prev.luv.knownRockspec "luv" version;
      }).overrideAttrs
        (oa: {
          buildInputs = replaceInput oa.buildInputs libuv;
        });
    libluv = prev.libluv.overrideAttrs (oa: {
      inherit (final.luv) version src;
      buildInputs = replaceInput oa.buildInputs libuv;
    });
    lpeg = prev.luaLib.overrideLuarocks prev.lpeg rec {
      version = versionFromSrc mkDeps.lpeg;
      src = mkDeps.lpeg;
      knownRockspec = rockspecUpdateVersion prev.lpeg.knownRockspec "lpeg" version;
    };
  };

  # libuv::
  #NOTE: (Hermit) https://github.com/nix-community/neovim-nightly-overlay/pull/541
  libuv =
    if (pkgs.stdenv.isLinux) then
      pkgs.libuv.overrideAttrs {
        version = versionFromSrc mkDeps.libuv;
        src = mkDeps.libuv;
      }
    else
      pkgs.libuv;

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
  };

  utf8proc = pkgs.utf8proc.overrideAttrs {
    version = versionFromSrc mkDeps.utf8proc;
    src = mkDeps.utf8proc;
  };

  # Unibilium::
  unibilium = pkgs.unibilium.overrideAttrs (prev: {
    version = versionFromSrc mkDeps.unibilium;
    src = mkDeps.unibilium;
    # autoreconf is needed for newer versions to generate Makefile
    nativeBuildInputs = lib.unique (prev.nativeBuildInputs ++ [ autoreconfHook ]);
  });

  # libvterm neovim fork
  # libvterm-neovim = pkgs.libvterm-neovim.overrideAttrs {
  #   version = versionFromSrc mkDeps.libvterm;
  #   src = mkDeps.libvterm;
  # };
  gettext = pkgs.gettext.overrideAttrs {
    src = mkDeps.gettext;
    version = versionFromSrc mkDeps.gettext;
  };
  # libiconv = pkgs.libiconv.overrideAttrs {
  #   src = mkDeps.libiconv;
  #   version = versionFromSrc mkDeps.libiconv;
  # };

in
(cfg.package.override {
  inherit
    libuv
    lua
    # msgpack-c
    unibilium
    #libvterm-neovim
    gettext
    #libiconv
    ;
  tree-sitter = tree-sitter-nightly;
}).overrideAttrs
  (oa: {
    src = patched-src;
    version = cfg.src.shortRev or "dirty";
    buildInputs = (oa.buildInputs or [ ]) ++ [ utf8proc ];
    __structuredAttrs = true;
    outputChecks.out.disallowedRequisites = [
      stdenv.cc
    ];
    preConfigure = ''
      sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/"
    '';
    cmakeFlag = oa.cmakeFlags ++ [
      "-DLUACHECK_PRG=${pkgs.luajit.pkgs.luacheck}/bin/luacheck"
      "-DENABLE_LTO=OFF"
      # "-DENABLE_WASMTIME=ON"
      #"-DENABLE_ASAN_UBSAN=ON"
    ];
    postInstall = ''
      #${if oa ? postInstall then oa.postInstall else ""}
      ${stringSeps}
    '';
  })
