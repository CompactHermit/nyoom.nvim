(import-macros {: use-package!} :macros)

;; Just trying to break tmux, yeeeh noooooo
(use-package! :otavioschwanck/tmux-awesome-manager.nvim {:nyoom-module tools.tmux
                                                         :call-setup tmux-awesome-manager
                                                         :opt true})


