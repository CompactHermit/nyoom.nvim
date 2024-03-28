(import-macros {: use-package!} :macros)

;; Updating Owner
(use-package! :nvimtools/hydra.nvim
              {:nyoom-module ui.hydra
               :module :hydra
               :keys [:<leader>a
                      :<leader>cl
                      :<leader>ch
                      :<leader>d
                      :<leader>e
                      :<leader>f
                      :<leader>g
                      :<leader>G
                      :<leader>l
                      :<leader>m
                      :<leader>ne
                      :<leader>o
                      :<leader>q
                      :<leader>s
                      :<leader>t
                      :<leader>u
                      :<leader>v
                      :<leader>w
                      :<leader>z]})
