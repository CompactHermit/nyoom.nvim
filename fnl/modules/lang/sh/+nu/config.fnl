(import-macros {: autocmd! : packadd!} :macros)
;
(do
  (vim.api.nvim_create_augroup :nuSetup {:clear true})
  (autocmd! BufReadPre :*.nu
            `(fn []
               (packadd! nu-nvim)
               ((->> :setup (. (require :nu))) {:use_lsp_features true}))
            {:group :nuSetup :desc "nuShell support Setup"}))

; (vim.filetype.add {:extension {:nu :nu}})
;
; (vim.api.nvim_create_autocmd :FileType
;                              {:pattern :nu
;                               :callback (fn [event]
;                                           (= (. vim.bo event.buf :commentstring)
;                                              "# %s"))})
