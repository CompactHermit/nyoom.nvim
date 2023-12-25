(import-macros {: use-package!} :macros)

;; Just trying to break tmux, yeeeh noooooo
(use-package! :ThePrimeagen/harpoon {:nyoom-module tools.harpoon
                                     :opt true
                                     :branch :harpoon2
                                     :event :BufReadPost})

