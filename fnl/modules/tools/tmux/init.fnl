(import-macros {: lzn!} :macros)

;; Fakes a load, since this plugin is in the user dir, we just load the script
(lzn! :tmux {:nyoom-module tools.tmux
             :enable #(not= vim.env.TMUX nil)
             :cmd [:Tmux :TMSession :TMPaneSelect]
             :load (fn [])})
