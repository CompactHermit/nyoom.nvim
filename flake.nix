{
  description = "Nyoom Interfaces with Nix";

  outputs = { self, parts, ... }@inputs:
    parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [ ./nix/tests ];
      debug = true;
      flake = {
        templates = let inherit (inputs.nixpkgs) lib;
        in (lib.attrsets.genAttrs (lib.attrNames
          (lib.filterAttrs (_: v: v != "regular")
            (builtins.readDir ./nix/templates))) (name: {
              path = ./nix/templates/${name};
              description = "${name}-Template";
              welcomeText = ''
                Welcome ya bloated fuck, ur building a devshell for ${name}, enjoy it .
              '';
            }));
      };
      perSystem = { self', lib, pkgs, config, system, ... }:
        let
          inherit (pkgs.vimUtils) buildVimPlugin;
          inherit (pkgs.neovimUtils) makeNeovimConfig grammarToPlugin;

          l = lib // builtins;
          mkNeovimPlugin = src: pname: __extraOpts: __opt: {
            plugin = buildVimPlugin ({
              inherit pname src;
              version = src.lastModifiedDate;
            } // __extraOpts);
            optional = __opt;
          };
          grammar = pkgs.tree-sitter.buildGrammar;
          __mkLuaRock = src: deps:
            pkgs.callPackage ({ buildLuarocksPackage, fetchgit, lua, luaOlder
              , luarocks-build-rust-mlua, }:
              { __useRust ? false, }:
              buildLuarocksPackage {
                pname = "${src}";
                version =
                  inputs."${src}".lastModifiedDate; # TODO::(Hermit)<02/07> Find a better way to add versions from the luarockSpec
                src = inputs."${src}";
                knownrockspec = { };
                disabled = (luaOlder "5.1");
                propagatedBuildInputs = [ lua ] ++ (l.mkIf __useRust [ ]);
              }) { };

          NeovimConfig = makeNeovimConfig {
            withPython3 = true;
            extraLuaPackages = p: [ p.luarocks p.magick ];
            customRC = import ./nix;
            plugins = with pkgs;
              [
                (pkgs.symlinkJoin {
                  name = "nvim-treesitter";
                  paths = [
                    pkgs.vimPlugins.nvim-treesitter.withAllGrammars
                    (map grammarToPlugin
                      (pkgs.vimPlugins.nvim-treesitter.allGrammars
                        # ((__filter (x: __match ".*(norg).*" x.name == null)
                        #   pkgs.vimPlugins.nvim-treesitter.allGrammars)
                        ++ (with self'.packages; [
                          cabal
                          just
                          nim
                          norg-meta
                          #norg
                          nu
                          typst
                        ])))
                  ];
                })
                parinfer-rust
              ] ++ (with vimPlugins; [
                sqlite-lua
                mini-nvim
                markdown-preview-nvim
                rocks-nvim
                nfnl
                lsp_lines-nvim
                packer-nvim
                hotpot-nvim
              ]) ++ (map
                #TODO:: (Hermit) <02/24> Use Partition
                (x: mkNeovimPlugin inputs."${x}" (x + "-nvim") { } false) [
                  "wrapping-paper"
                  "nvim-scissors"
                  "luasnip_snippets"
                  "nvim-dap-virtual-text"
                  "molten"
                ]) ++ (map (x: mkNeovimPlugin inputs."${x}" x { } true) [
                  "neorg-telescope"
                  "neorg-chronicle"
                  "cmp-treesitter" # For whatever reason, cmp-sources get packadded automagically? WTF CMP
                  "cmp-latexsym"
                  "galore"
                  "nvim-dap-rr"
                  "actions-preview"
                  "gitconflict"
                  "gitignore"
                  "otter"
                  "quarto"
                ]) ++ [
                  (mkNeovimPlugin inputs.reactive "reactive-nvim" {
                    dontFixup = true;
                    postInstall = "";
                  } true)
                  # (mkNeovimPlugin inputs.neorg "neorg-nvim" {
                  #     buildPhase = ''
                  #       echo "Removing Stale Queries::"
                  #       rm -rf ./queries/
                  #       #rm -rf ./queries/highlights.scm 
                  #       #rm -rf ./queries/injections.scm
                  #       echo "Adding Nightly Queries::"
                  #         #cp -r ${inputs.tree-sitter-norg}/queries ./.
                  #     '';
                  #   }true)
                ]
              ++ (with inputs; [ rustaceanvim.packages."${system}".default ]);
          };
          wrapperArgs = let
            binpath = l.makeBinPath (with pkgs;
              [
                deadnix
                marksman
                alejandra
                haskellPackages.fast-tags # NOTE:: (Hermit) Im in love, marry me
                nil
                ripgrep
                fd
                xxd
                stylua
              ] ++ [ inputs.nixfmt-rfc.packages."${system}".default ]
              ++ (with pkgs.lua51Packages; [
                lua-language-server
                lua
                luarocks
              ]));
            # NOTE::(Hermit) This is so fking anal
          in l.escapeShellArgs NeovimConfig.wrapperArgs + " " + ''
            --suffix LUA_CPATH ";" "${
              lib.concatMapStringsSep ";" pkgs.lua51Packages.getLuaCPath
              (with pkgs.lua51Packages; [
                #luarocks-build-rust-mlua
                rustaceanvim
                lgi
                toml
                toml-edit
                fidget-nvim
                nvim-nio
                fzy
              ])
            }"'' + " " + ''
              --suffix LUA_PATH ";" "${
                l.concatMapStringsSep ";" pkgs.lua51Packages.getLuaPath
                (with pkgs.lua51Packages; [ fidget-nvim nvim-nio fzy lgi ])
              }"'' + " " + "--prefix PATH : ${binpath}" + " "
          + ''--set LIBSQLITE_CLIB_PATH "${pkgs.sqlite.out}/lib/libsqlite3.so"''
          + " " + ''--set LIBSQLITE "${pkgs.sqlite.out}/lib/libsqlite3.so"'';
        in {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.rocks.overlays.default
              (_: super: {
                tree-sitter =
                  inputs.tree-sitter-0290.legacyPackages.${system}.tree-sitter;
                neovim-custom = pkgs.wrapNeovimUnstable
                  (pkgs.neovim-unwrapped.overrideAttrs (oa: {
                    src = inputs.nvim-git;
                    version = inputs.nvim-git.shortRev or "dirty";
                    buildInputs = (oa.buildInputs or [ ]) ++ [ ];
                    preConfigure = ''
                      sed -i cmake.config/versiondef.h.in -e "s/@NVIM_VERSION_PRERELEASE@/-dev-$version/" #NOTE::(Hermit)Avoids all the Vim.re bullshit by renaming nvim -> nvim-dev*.
                    '';
                  })) (NeovimConfig // { inherit wrapperArgs; });
              })
            ];
          };
          devShells = {
            default = pkgs.mkShell {
              name = "Awooga";
              inputsFrom = with config; [
                treefmt.build.devShell
                pre-commit.devShell
              ];
              packages = with pkgs; [ lua-language-server selene fnlfmt ];
              DIRENV_LOG_FORMAT = ""; # NOTE:: Makes direnv shutup
            };
          };
          packages = {
            fnl-linter = pkgs.stdenv.mkDerivation {
              name = "Fnl-linter";
              src = inputs.fnl-linter;
              nativeBuildInputs = with pkgs; [ lua5_4_compat fennel ];
              configurePhase = ''
                substituteInPlace Makefile \
                --replace "/usr/lib64/liblua.so"  ${pkgs.lua5_4_compat}/lib/liblua.so \
                --replace "/usr/include/lua" ${pkgs.lua5_4_compat}/bin/lua
              '';
              buildPhase = ''
                make binary
              '';
              installPhase = ''
                mkdir -p $out/bin
                cp ./check.fnl $out/bin
              '';
            };
            fnl-Docgen = pkgs.stdenv.mkDerivation {
              name = "fenneldoc";
              version = "0.0.1";
              src = inputs.fnl-Docgen;
              strictDeps = true;
              nativeBuildInputs = with pkgs; [ fennel ];
              configurePhase = ''
                substituteInPlace Makefile \
                --replace '$(shell git describe --abbrev=0 || "unknown")'  "1.0.1"\
                --replace './fenneldoc --config --project-version $(VERSION)' ""
              '';
              buildPhase = ''
                make
              '';
              installPhase = ''
                mkdir -p $out/bin
                cp fenneldoc $out/bin
              '';
            };
            norg-fmt = pkgs.rustPlatform.buildRustPackage {
              pname = "norg-fmt";
              src = inputs.norg-fmt;
              version = "1.1.0";
              cargoLock = {
                # VHYRO STOP USING GIT DEPS U FKING BASTARD!!!!!!!
                lockFileContents =
                  builtins.readFile ("${inputs.norg-fmt}" + "/Cargo.lock");
                allowBuiltinFetchGit = true;
              };
            };
            default = pkgs.writeShellApplication {
              name = "nvim";
              text = ''
                XDG_CACHE_HOME=/tmp/nyoom ${l.getExe pkgs.neovim-custom} "$@"
              '';
            };
          } // l.genAttrs [
            "cabal"
            #"norg" # Note::(Hermit) We need to symlink the queries along with neorg's plugin.
            "norg-meta"
            "typst"
            "just"
            "nim"
            "nu"
          ] (x:
            (grammar {
              language = x;
              src = inputs."tree-sitter-${x}";
              version = "${inputs."tree-sitter-${x}".shortRev}";
            }));
          apps = {
            sync = {
              type = "app";
              program = pkgs.writeShellApplication {
                name = "Nyoom:: Sync";
                text =
                  # bash
                  ''
                    cd ~/.config/nvim
                    echo "Deleting Temp Cache"
                    rm -rf /tmp/nyoom
                    export XDG_CACHE_HOME=/tmp/nyoom
                      # git clone --depth 1 https://github.com/wbthomason/packer.nvim "XDG_CACHE_HOME/site/pack/packer/opt/packer.nvim"
                      # git clone --depth 1 https://github.com/rktjmp/hotpot.nvim.git "XDG_CACHE_HOME/site/pack/packer/start/hotpot.nvim"
                      NYOOM_CLI=true  ${
                        l.getExe pkgs.neovim-custom
                      } --headless -c 'autocmd User PackerComplete quitall' -c 'lua require("packer").sync()'
                  '';
              };
            };
          };
        };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts.url = "github:hercules-ci/flake-parts";
    pch = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-git = {
      url = "github:neovim/neovim";
      flake = false;
    };
    norg-fmt = {
      url = "github:nvim-neorg/norg-fmt";
      flake = false;
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixfmt-rfc.url = "github:piegamesde/nixfmt/rfc101-style";
    fnl-linter = {
      url = "github:dokutan/check.fnl";
      flake = false;
    };
    fnl-Docgen = {
      url = "gitlab:andreyorst/fenneldoc";
      flake = false;
    };
    #Vhyrro, I'm trusting you bud;
    rocks = {
      url = "github:nvim-neorocks/rocks.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "parts";
      inputs.pre-commit-hooks.follows = "pch";
    };
    #neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "parts";
      inputs.pre-commit-hooks.follows = "pch";
    };
    tree-sitter-0290.url = "github:polarmutex/nixpkgs/update-treesitter";
    cmp-latexsym = {
      url = "github:kdheepak/cmp-latex-symbols";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };
    otter = {
      url = "github:benlubas/otter.nvim/feat/remove_leading_whitespace/";
      flake = false;
    };
    quarto = {
      url = "github:quarto-dev/quarto-nvim";
      flake = false;
    };
    molten = {
      url = "github:benlubas/molten-nvim";
      flake = false;
    };
    wrapping-paper = {
      url = "github:benlubas/wrapping-paper.nvim";
      flake = false;
    };
    luasnip_snippets = {
      url = "github:mireq/luasnip-snippets";
      flake = false;
    };
    actions-preview = {
      url = "github:aznhe21/actions-preview.nvim";
      flake = false;
    };
    gitconflict = {
      url = "github:akinsho/git-conflict.nvim";
      flake = false;
    };
    gitignore = {
      url = "github:wintermute-cell/gitignore.nvim";
      flake = false;
    };
    galore = {
      url = "github:dagle/galore";
      flake = false;
    };
    neorg = {
      url = "github:nvim-neorg/neorg";
      flake = false;
    };
    neorg-telescope = {
      url = "github:nvim-neorg/neorg-telescope";
      flake = false;
    };
    nvim-scissors = {
      url = "github:chrisgrieser/nvim-scissors";
      flake = false;
    };
    nvim-dap-rr = {
      url = "github:jonboh/nvim-dap-rr";
      flake = false;
    };
    nvim-dap-virtual-text = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    neorg-chronicle = {
      url = "github:MartinEekGerhardsen/neorg-chronicle";
      flake = false;
    };
    reactive = {
      url = "github:rasulomaroff/reactive.nvim";
      flake = false;
    };
    smuggler = {
      url = "github:Klafyvel/nvim-smuggler";
      flake = false;
    };
    tree-sitter-just = {
      url = "github:IndianBoy42/tree-sitter-just";
      flake = false;
    };
    tree-sitter-nim = {
      url = "github:alaviss/tree-sitter-nim";
      flake = false;
    };
    tree-sitter-typst = {
      url = "github:uben0/tree-sitter-typst";
      flake = false;
    };
    tree-sitter-norg = {
      url = "github:nvim-neorg/tree-sitter-norg3";
      # "github:boltlessengineer/tree-sitter-norg3-pr1/null_detached_modifier";
      flake = false;
    };
    tree-sitter-norg-meta = {
      url = "github:nvim-neorg/tree-sitter-norg-meta";
      flake = false;
    };
    tree-sitter-nu = {
      url = "github:nushell/tree-sitter-nu";
      flake = false;
    };
    tree-sitter-cabal = {
      url = "git+https://gitlab.com/magus/tree-sitter-cabal";
      flake = false;
    };
  };
}
