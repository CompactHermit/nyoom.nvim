(import-macros {: use-package!} :macros)

;; Testing Adapters



(use-package! :MrcJkb/neotest-haskell)
(use-package! :rouge8/neotest-rust)
(use-package! :nvim-neotest/neotest-python)
(use-package! :nvim-neotest/neotest {:nyoom-module tools.neotest
                                     :opt true
                                     :cmd [:TestNear
                                           :TestCurrent
                                           :TestOutput
                                           :TestSummary
                                           :TestStrat
                                           :TestStop
                                           :TestAttach]})
                                     ;;:require [(pack )]})

