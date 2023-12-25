(import-macros {: use-package!} :macros)

(use-package! :akinsho/toggleterm.nvim {:opt true
                                        :cmd :ToggleTerm
                                        :event :BufWritePost
                                        :call-setup toggleterm})
