(import-macros {: packadd!} :macros)

(packadd! nvim-material-icon)
(local material-icons (autoload :nvim-material-icon))

(local new-icons {:norg {:icon "" :color "#4878be" :name "neorg"}
                  :ncl {:icons "" :color "#4878be" :name "nickel"}
                  :py  {:icon "" :color "#ffbc03" :cterm_color "214" :name "Py"}})
(local patched_icons (vim.tbl_deep_extend :force (material-icons.get_icons) new-icons))

(setup :nvim-web-devicons {:override patched_icons})
