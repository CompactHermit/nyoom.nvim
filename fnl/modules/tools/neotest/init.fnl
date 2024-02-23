(import-macros {: use-package! : pack} :macros)

;; Testing Adapters

;; TODO: make custom macro to handle neotest adapters
;; Note:: it might be safe to keep them here, as there's no setup call on them.
(use-package! :nvim-neotest/neotest
              {:nyoom-module tools.neotest
               :opt true
               :cmd [:TestNear
                     :TestCurrent
                     :TestOutput
                     :TestSummary
                     :TestStrat
                     :TestStop
                     :TestAttach]
               :requires [(pack :mrcjkb/neotest-haskell {:opt true})
                          (pack :rouge8/neotest-rust {:opt true})
                          (pack :nvim-neotest/neotest-python {:opt true})]})
