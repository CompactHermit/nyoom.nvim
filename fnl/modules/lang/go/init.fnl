(import-macros {: use-package!} :macros)

(use-package! :ray-x/go.nvim
              {:nyoom-module lang.go
               :dependencies [:neovim/nvim-lspconfig :nvim-treesitter/nvim-treesitter]
               :ft [:go :gomod]
               :event :CmdlineEnter
               :build "lua require('go.install').update_all_sync()"
               :call-setup go})



