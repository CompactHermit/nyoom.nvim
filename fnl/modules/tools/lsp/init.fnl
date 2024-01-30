(import-macros {: use-package! : pack} :macros)

; easy to use configurations for language servers

(use-package! :neovim/nvim-lspconfig
              {:nyoom-module tools.lsp :opt true :defer nvim-lspconfig})

(use-package! :VidocqH/lsp-lens.nvim
              {:opt true
               :cmd [:LspLensOn :LspLensOff :LspLensToggle]
               :call-setup lsp-lens})
