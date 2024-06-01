(import-macros {: nyoom-module! : autocmd!} :macros)

;(use-package! :lewis6991/gitsigns.nvim
;              {:nyoom-module ui.vc-gutter
;               :ft :gitcommit
;               :commit :d96ef3bbff0bdbc3916a220f5c74a04c4db033f2
;               :module :gitsigns
;               :setup (fn []
;                        (autocmd! BufRead *
;                                  `(fn []
;                                     (vim.fn.system (.. "git -C "
;                                                        (vim.fn.expand "%:p:h")
;                                                        " rev-parse"))
;                                     (when (= vim.v.shell_error 0)
;                                       (vim.schedule (fn []
;                                                       ((. (require :packer)
;                                                           :loader) :gitsigns.nvim)))))))})
(nyoom-module! ui.vc-gutter)
