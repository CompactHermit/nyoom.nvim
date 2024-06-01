(import-macros {: packadd!} :macros)
;
;
(vim.api.nvim_create_autocmd :BufReadPre
                             {:pattern :*.nu
                              :once true
                              :callback (fn [event]
                                          (packadd! nu-nvim)
                                          ((->> :setup (. (require :nu))) {:use_lsp_features true}))})
