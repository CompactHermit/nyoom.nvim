(import-macros {: use-package!} :macros)
;
; (use-package! :torbjo/calendar.vim {:nyoom-module app.calendar
;                                     :cmd :Calendar})
(use-package! :lalitmee/browse.nvim
              {:nyoom-module tools.browse
               :after :telescope.nvim})


(use-package! :luckasRanarison/nvim-devdocs
              {:opt true
               :event [:BufReadPost]
               :call-setup nvim-devdocs})
