(import-macros {: use-package!} :macros)

;; Testing Adapters

;; TODO: make custom macro to handle neotest adapters
;; Note:: it might be safe to keep them here, as there's no setup call on them.
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
                                     ;;:require [(pack ;; ADD the modules here)]})

