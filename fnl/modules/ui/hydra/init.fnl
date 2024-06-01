(import-macros {: use-package!} :macros)

;; Updating Owner
(use-package! :nvimtools/hydra.nvim
              {:nyoom-module ui.hydra
               :module :hydra
               :keys [:<leader>a
                      :<leader>cl
                      ";h"
                      :<leader>cm
                      :<leader>e
                      :<leader>f
                      :<leader>g
                      ";g"
                      :<leader>l
                      :<leader>m
                      :<leader>ne
                      :<leader>o
                      :<leader>q
                      ";s"
                      ";t"
                      :<leader>u
                      :<leader>v
                      :<leader>w
                      :<leader>z]})
