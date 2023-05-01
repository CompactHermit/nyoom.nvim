(import-macros {: use-package!} :macros)
;
; (use-package! :torbjo/calendar.vim {:nyoom-module app.calendar
;                                     :cmd :Calendar})
(use-package! :lalitmee/browse.nvim
              {:nyoom-module tools.browse
               :after :telescope.nvim})

