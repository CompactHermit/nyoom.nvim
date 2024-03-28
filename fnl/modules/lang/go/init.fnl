(import-macros {: nyoom-module!} :macros)

; (use-package! :ray-x/go.nvim {:nyoom-module lang.go
;                               :dependencies [:neovim/nvim-lspconfig
;                                              :nvim-treesitter/nvim-treesitter]
;                               :ft [:go :gomod]})

(nyoom-module! lang.go)
