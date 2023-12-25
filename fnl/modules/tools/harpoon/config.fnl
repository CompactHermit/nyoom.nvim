
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
 (do))
 
