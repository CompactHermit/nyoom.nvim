(import-macros {: use-package!} :macros)

;; A fucking broken git checker
(use-package! :pwntester/octo.nvim {:nyoom-module tools.octo
                                    :event :BufReadPost
                                    :dependencies [:nvim-lua/plenary.nvim
                                                   :nvim-telescope/telescope.nvim
                                                   :nvim-tree/nvim-web-devicons]
                                    :call-setup octo})
