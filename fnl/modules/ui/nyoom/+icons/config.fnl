(import-macros {: packadd!} :macros)

;(packadd! nvim-material-icons)
(packadd! nvim-webdev-icons)
;; NOTE: (Hermit) <05/27> Developer is fucking with highlight groups, and since I'm too lazy to patch his bs, we just ignore this completely from now on
;; (local material-icons (autoload :nvim-material-icon))

(local new-icons {:norg {:icon "" :color "#4878be" :name :neorg}
                  :ncl {:icons "" :color "#4878be" :name :nickel}
                  :py {:icon ""
                       :color "#ffbc03"
                       :cterm_color :214
                       :name :Py}})

;(local patched_icons (vim.tbl_deep_extend :force (material-icons.get_icons)
;                                          new-icons))

((->> :setup (. (require :nvim-web-devicons))) {:override new-icons})
