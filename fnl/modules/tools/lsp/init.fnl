(import-macros {: use-package! : pack} :macros)

; easy to use configurations for language servers

(use-package! :neovim/nvim-lspconfig
              {:nyoom-module tools.lsp
               :opt true
               :defer nvim-lspconfig})

(use-package! :VidocqH/lsp-lens.nvim
              {:opt true
               :cmd [:LspLensOn :LspLensOff :LspLensToggle]
               :call-setup lsp-lens})
                          
(use-package! :SmiteshP/nvim-navic
              {:requires :neovim/nvim-lspconfig})
;; NOTE:: Find a way to lazyload this
(use-package! :SmiteshP/nvim-navbuddy {:opt true
                                       :dependencies [:neovim/nvim-lspconfig
                                                      :SmiteshP/nvim-navic
                                                      :MunifTanjim/nui.nvim]
                                       :event [:BufWritePost]
                                       :config (fn []
                                                 (local {: setup} (require :nvim-navbuddy))
                                                 (setup {:lsp {:auto_attach true}}))})
