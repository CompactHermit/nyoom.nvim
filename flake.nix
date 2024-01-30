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
          mkNeovimPlugin = src: pname:
            buildVimPlugin {
              inherit pname src;
              version = src.lastModifiedDate;
            };
          grammar = pkgs.callPackage
            "${inputs.nixpkgs}/pkgs/development/tools/parsing/tree-sitter/grammar.nix"
            { };
          NeovimConfig = makeNeovimConfig {
            extraLuaPackages = p: [ p.luarocks p.magick ];
            plugins = with pkgs;
              [
                (pkgs.symlinkJoin {
                  name = "nvim-treesitter";
                  paths = [
                    (pkgs.vimPlugins.nvim-treesitter.withAllGrammars.overrideAttrs {
                      passthru.dependencies = __filter
                        (x: (__match ".*treesitter.*(norg).*" x.name) == null)
                        pkgs.vimPlugins.nvim-treesitter.withAllGrammars.passthru.dependencies;
                    })
                  ] # NOTE:: (Hermit) Fuck overlays
                  # [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ] # In case we break, fallback to default parser
                    ++ map grammarToPlugin
                    (pkgs.vimPlugins.nvim-treesitter.allGrammars
                      ++ (with self'.packages; [
                        cabal
                        just
                        nim
                        norg-meta
                        nu
                        typst
                      ]));
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
              ]) ++ (map (x: mkNeovimPlugin inputs."${x}" (x + ".nvim")) [
                "wrapping-paper"
                "nvim-scissors"
                "luasnip_snippets"
                "nvim-dap-virtual-text"
                "neorg-chronicle"
              ]);
            withNodeJs = true;
            withRuby = true;
            withPython3 = true;
            customRC = import ./nix;
          };
          wrapperArgs = let
            binpath = l.makeBinPath (with pkgs;
              [
                #cargo
                sqlite
                deadnix
                statix
                marksman
                nixfmt
                alejandra
                nil
                biome
                ripgrep
                fd
                xxd
                python311Packages.jupytext
                stylua
              ] ++ (with pkgs.lua51Packages; [
                lua-language-server
                lua
                luarocks
              ]));
            # NOTE::(Hermit) This is so fking anal
          in l.escapeShellArgs NeovimConfig.wrapperArgs + " " + ''
            --suffix LUA_CPATH ";" "${
              lib.concatMapStringsSep ";" pkgs.lua51Packages.getLuaCPath
              (with pkgs.lua51Packages; [
                luarocks-build-rust-mlua
                toml
                toml-edit
                fidget-nvim
                nvim-nio
                fzy
              ])
            }"'' + " " + ''
              --suffix LUA_PATH ";" "${
                l.concatMapStringsSep ";" pkgs.lua51Packages.getLuaPath
                (with pkgs.lua51Packages; [ fidget-nvim nvim-nio fzy ])
              }"'' + " " + "--prefix PATH : ${binpath}";
          neovimCleaned = l.fileset.toSource {
            root = ./.;
            fileset = l.fileset.union [ ./fnl ./init.lua ./rocks.toml ];
          };
        in {
          _module.args.pkgs = import self.inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.rocks.overlays.default
              (_: _: {
                neovim-custom = pkgs.wrapNeovimUnstable
                  # self.inputs.neovim-nightly-overlay.packages."${system}".default
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
            default = pkgs.writeShellApplication {
              name = "nvim";
              text = ''
                XDG_CACHE_HOME=/tmp/nyoom ${l.getExe pkgs.neovim-custom} "$@"
              '';
            };
          } // l.genAttrs [
            "cabal"
            "norg"
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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    # Plugins/Parsers::
    #himalaya.url = "git+https://git.sr.ht/~soywod/himalaya-vim";
    wrapping-paper = {
      url = "github:benlubas/wrapping-paper.nvim";
      flake = false;
    };
    luasnip_snippets = {
      url = "github:mireq/luasnip-snippets";
      flake = false;
    };
    nvim-scissors = {
      url = "github:chrisgrieser/nvim-scissors";
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
      url = "github:nvim-neorg/tree-sitter-norg3/new-attached-modifiers";
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
