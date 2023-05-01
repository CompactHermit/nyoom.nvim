
(import-macros {: nyoom-module-p! : command!} :macros)

(setup :harpoon {:global_settings
                   {:save_on_toggle false
                    :enter_on_sendcmd true
                    :tmux_autoclose_windows true
                    :mark_branch true}})
(nyoom-module-p! telescope
                        (do
                          (local {: load_extension} (autoload :telescope))
                          (load_extension :harpoon)))
(nyoom-module-p! harpoon
 (do
  (command! HarpoonMarks "lua require('harpoon.mark').add_file()" {:desc "Harpoon Add files"})
  (command! HarpoonMenu "lua require('harpoon.ui').toggle_quick_menu()" {:desc "Harpoon QuickMenu"})
  (command! HarpNext "lua require('harpoon.ui').nav_next()" {:desc "Harpoon Next"})
  (command! HarpPrev "lua require('harpoon.ui').nav_prev()" {:desc "Harpoon Prev"})
  (command! HarpToggle "lua require('harpoon.mark').toggle_file()")))
