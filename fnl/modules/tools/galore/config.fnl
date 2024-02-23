(import-macros {: autocmd! : augroup!} :macros)

; (do
;   (vim.api.create_augroup :GaloreSetup {:clear true})
;   (autocmd! [:BufReadPost] "*" `((->> :setup (. (require :galore))))
;             {:group :GaloreSetup}))
