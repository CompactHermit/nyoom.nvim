(import-macros {: use-package!} :macros)

(use-package! :folke/flash.nvim
             {:nyoom-module config.default.+flash
              :opt true
              :event :BufReadPost})

(use-package! :johmsalas/text-case.nvim 
               {:opt true
                :event [:BufReadPost]
                :call-setup textcase})
 
