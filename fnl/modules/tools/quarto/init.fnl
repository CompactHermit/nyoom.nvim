(import-macros {: nyoom-module! : use-package!} :macros)

; (use-package! :quarto-dev/quarto-nvim
;               {:nyoom-module tools.quarto
;                ;;:ft [:norg :md]
;                :event :BufWritePost
;                :cmd [:QuartoPreview]
;                :requires [:neovim/nvim-lspconfig
;                           :jmbuhr/otter.nvim
;                           :benlubas/nvim-cmp
;                           :neovim/nvim-lspconfig
;                           :nvim-treesitter/nvim-treesitter]})

(nyoom-module! tools.quarto)
