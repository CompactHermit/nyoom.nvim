(import-macros {: use-package! : pack} :macros)

;; Window animation, For the obsidian feel::
(use-package! :anuvyklack/windows.nvim
              {:nyoom-module ui.animate
               :event :BufWritePost
               :requires [(pack :anuvyklack/middleclass)
                          (pack :anuvyklack/animation.nvim)]})
