(import-macros {: use-package!} :macros)

(use-package! :anuvyklack/hydra.nvim
              {:nyoom-module ui.hydra
               :module :hydra
               :keys [:<leader>g
                      :<leader>v
                      :<leader>t
                      :<leader>d
                      :<leader>m
                      :<leader>q
                      :<leader>n
                      :<leader>w
                      :<leader>o
                      :<leader>z]})
