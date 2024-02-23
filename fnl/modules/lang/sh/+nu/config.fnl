(import-macros {: autocmd! : packadd!} :macros)

(do
  (vim.api.nvim_create_augroup :nuSetup {:clear true})
  (autocmd! BufReadPost :*.nu
            (fn []
              (packadd! nu-nvim)
              ((->> :setup (. (require :nu)))))
            {:group :nuSetup :desc "nuShell support Setup"}))
