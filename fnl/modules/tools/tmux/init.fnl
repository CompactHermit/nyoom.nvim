(import-macros {: use-package! : nyoom-module!} :macros)

;; Just trying to break tmux, yeeeh noooooo
; (use-package! :aserowy/tmux.nvim {:nyoom-module tools.tmux
;                                   :opt true
;                                   :event :BufRead})

(nyoom-module! tools.tmux)

