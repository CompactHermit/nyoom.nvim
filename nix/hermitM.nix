{ inputs, ... }:
{
  perSystem =
    {
      self',
      fetches,
      lib,
      pkgs,
      config,
      system,
      ...
    }:
    {
      neohermit = {
        src = fetches.nvim-git.src;
        plugins = {
          lazy = [
            "animation"
            "actions-preview"
            "alpha"
            "bufferline"
            #"bufferlist"
            #"bmessages" #Conjure is Better
            "crates"
            "clangd_extensions"
            #"colors"
            "conform" # Needed for feed.nvim: Will try to quickhack this with none-null-ls using package.preload
            "comment"
            "care"
            "care-cmp"
            "cmp-nvim-lua"
            "cmp-dap"
            "cmp-conjure"
            "cmp-lspkind"
            "cmp-luasnip"
            "cmp-path"
            "cmp-buffer"
            "cmp-cmdline"
            "cmp-nvim-lsp"
            "cmp-vimtex"
            "cmp-nvim-lsp-signature-help"
            "cmp-dap"
            "cmp-latexsym"
            "luasnip"
            "haskell-snippets"
            "luasnip_snippets"
            "friendly-luasnip"
            "cmp-latexsym"
            "compiler"
            "conjure"
            "diagram-nvim"
            "diffview"
            "direnv"
            "dynMacro" # Based
            "feed-nvim"
            "foldtext"
            "folke_edgy"
            "folke_trouble"
            "folke_todo-comments"
            "folke_flash"
            "galore"
            "gitconflict"
            "gitignore"
            "grug"
            "ibl"
            "iswap"
            "image-nvim"
            # "quicknote"
            "markview"
            "minty"
            "mini-icons"
            "multicursor"
            "music-controler"
            "neogit"
            "neotest"
            "neotest-haskell"
            "neotest-plenary"
            "neotest-busted"
            "neotest-python"
            "neotest-zig"
            "neorg"
            "neorg-telescope"
            "neorg-lines"
            "neorg-exec"
            "neorg-interim-ls"
            "neorg-templates"
            "neorg-extras"
            # "neorg-roam"
            # "neorg-chronicle"
            # "neorg-timelog"
            # "neorg-hop-extras"
            "nvim-notify"
            "nvim-scissors"
            #"nvim-cmp"
            "nvim-parinfer"
            "nvim-various-textobjs"
            "nui-components"
            "dap"
            "dapui"
            "dap-lua"
            "dap-rr"
            "dap-python"
            "nvim-dap-virtual-text"
            "smuggler"
            "gitsigns"
            "gitgraph"
            "go-nvim"
            "harpoon"
            "lazydev"
            "lspconfig"
            "nonels"
            "luvit-meta"
            "ffi-reflect"
            "lpeg"
            "libmodal"
            "lua-utils"
            #"lsplines"
            # "lsp-better-diag"
            "lsplines"
            "lspsaga"
            "live-rename"
            "resession"
            "rustaceanvim"
            "truezen"
            "ts-error-translator"
            "hydra"
            "hlchunks"
            "haskellTools"
            "helpview-nvim"
            "rainbow-delimiters"
            "syntax-tree-surfer"
            "substitute"
            "ts-context"
            "ts-context-commentstring"
            "ts-refactor"
            "ts-textobjects"
            "ts-node-action"
            "typescriptTools"
            "typst-preview"
            "timerly"
            "telescope"
            "telescope_hoogle"
            "telescope-ui-select"
            "telescope-file-browse"
            "telescope-zf-native"
            "telescope-project"
            "telescope-tabs"
            "telescope-zoxide"
            "telescope-egrepify"
            "treedoc"
            "tmpclone-nvim"
            "toggleterm"
            "ufold"
            "psa"
            "octo"
            "otter"
            "oqt"
            "overseer"
            "oil"
            "oil-git-status"
            "profile"
            "quarto"
            "quickfix"
            "quicker-nvim"
            "reactive"
            "rest-nvim"
            "ratatoskr"
            "rosalyn"
            "tailwind-tools"
            "volt" # Needed for minty
            "windows"
            "which-key"
            "wrapping-paper"
            "yanky"
            "yeet"
            "matchparens"
            "nvim-autopairs"
            "text-case"
            "zigTools"
          ];
          #TODO:: Don't handle any logic with `start` dirs, simply linkfarm
          eager = [
            "hotpot-nvim"
            "fzy-lua-native"
            "cyberdream"
            "moonfly"
            "nightfox"
            "nui"
            "oxocarbon"
            "sweetie"
          ];
        };
        settings = {
          strip = true;
          bytecompile = true;
          plugins = {
            # telescope-zf-native = {
            #   nativeBuildInputs = [
            #     pkgs.installShellFiles
            #     pkgs.zig_0_13.hook
            #   ];
            #   postPatch = ''
            #     cp -a ${pkgs.callPackage ./deps.nix { }}/. $ZIG_GLOBAL_CACHE_DIR/p
            #   '';
            #   postInstall = ''
            #     rm -rf lib/*
            #   '';
            # };
            fzy-lua-native = {
              postInstall = ''
                rm -rf static/*
                make
              '';
            };
            # neorg = {
            #   #   postInstall = ''
            #   #     rm -rf $out/queries/norg
            #   #     cp -r "${inputs.tree-sitter-norg}"/queries/norg $out/queries
            #   #   '';
            #   patches = [
            #     # (pkgs.fetchpatch {
            #     #   url = "https://github.com/nvim-neorg/neorg/pull/1390.diff";
            #     #   hash = "sha256-F9aZFdFEPiG2NLmwnHrZaiYO6jLF0b8xu9mn8zLf7G8=";
            #     # })
            #     # (pkgs.fetchpatch {
            #     #   url = "https://github.com/nvim-neorg/neorg/pull/1528.diff";
            #     #   hash = "sha256-3TfsuZHZlbNM35o6M6bmL5o8pMhlNnXZYmBjBplITm8=";
            #     # })
            #   ];
            # };
          };
          parsers = {
            # vala.postPatch = ''
            #   mv queries/vala/* queries/
            #   rmdir queries/vala
            # '';
            typst.postPatch = # bash
              ''
                mv queries/typst/* queries/
                rmdir queries/typst
              '';
            nu.postPatch = # nu
              ''
                mv queries/nu/* queries/
                rmdir queries/nu
              '';
          };
        };
        lua = {
          extraPacks = builtins.attrValues {
            inherit (pkgs.luajitPackages)
              # lgi
              # toml-edit
              fidget-nvim
              fzy
              ;
            inherit (self'.packages) neorg-se lzn-auto-require;
          };
          jit = builtins.attrValues {
            inherit (pkgs.luajitPackages)
              lz-n
              pathlib-nvim
              magick
              luarocks
              rtp-nvim
              middleclass
              xml2lua
              mimetypes
              nvim-nio
              neturl
              sha1
              ;
          };
          extraCLibs = builtins.attrValues { inherit (self'.packages) neorg-se; };
          extraCATS = [
            "luvit-meta"
            "busted-meta"
            "luassert-meta"
            "lpeg-meta"
          ];
        };
        #TODO:: Add Proper Queries
        defaultPlugins = builtins.attrValues { inherit (pkgs.vimPlugins) sqlite-lua plenary-nvim; };
        bins = builtins.attrValues {
          inherit (pkgs)
            selene
            ripgrep
            nvfetcher
            fd
            zf
            lua-language-server
            universal-ctags
            nix-tree
            vimcats
            ;
          inherit (pkgs.haskellPackages) fast-tags;
          inherit (pkgs.luajitPackages) nlua busted;
          inherit (self'.packages) harper-ls norg-fmt ztags;
          inherit (inputs.nixfmt-rfc.packages."${system}") nixfmt;
          inherit (inputs.nil_ls.packages."${system}") nil;
          nix-doc = pkgs.nix-doc.overrideAttrs (_: {
            env = lib.optionalAttrs pkgs.stdenv.isLinux { RUSTFLAGS = "-C relro-level=partial"; };
          });
          stylua = pkgs.stylua.overrideAttrs (_: {
            cargoBuildFeatures = [ "lua52" ];
          });
        };
      };
    };
}
