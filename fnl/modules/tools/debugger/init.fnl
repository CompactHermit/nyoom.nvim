(import-macros {: use-package! : pack} :macros)

;; TODO (Hermit)::<PackerDeprecate> Add proper lazyloading for debooger
(use-package! :mfussenegger/nvim-dap
              {:nyoom-module tools.debugger
               :opt true
               :defer nvim-dap
               :requires [(pack :rcarriga/nvim-dap-ui {:opt true})
                          (pack :jbyuki/one-small-step-for-vimkind {:opt true})]})
