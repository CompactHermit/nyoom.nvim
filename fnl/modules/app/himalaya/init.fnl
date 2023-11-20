(import-macros {: use-package!} :macros)

(use-package! "https://git.sr.ht/~soywod/himalaya-vim"
              {:opt true :nyoom-module app.himalaya :event [:BufReadPost]})
