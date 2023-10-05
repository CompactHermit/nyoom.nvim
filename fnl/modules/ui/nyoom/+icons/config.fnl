(import-macros {: packadd!} :macros)

(packadd! nvim-material-icon)
(local material-icons (autoload :nvim-material-icon))
(local patched_icons (vim.tbl_deep_extend :force (material-icons.get_icons) {:norg {:icon ""
                                                                                    :color "#4878be"
                                                                                    :name "neorg"}
                                                                             :ncl {:icons ""
                                                                                   :color "#4878be"
                                                                                   :name "nickel"}}))

(setup :nvim-web-devicons {:override patched_icons})
