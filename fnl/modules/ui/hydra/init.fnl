(import-macros {: lzn!} :macros)

;; Updating Owner
(lzn! :hydra {:nyoom-module ui.hydra
              :wants [:which-key :gitsigns]
              :keys [{1 :<space>a :desc "[Hy]dra [H]arpoon"}
                     {1 :<space>cl :desc "[Hy]dra [L]SP"}
                     {1 ";h" :desc "[Hy]dra [H]askell"}
                     {1 :<space>cm :desc "[Hy]dra [R]ust"}
                     {1 :<space>e :desc "[Hy]dra [F]lash"}
                     {1 ";g" :desc "[Hy]dra [G]it"}
                     {1 :<space>l :desc "[Hy]dra:: [Ov]erseer"}
                     {1 ";s" :desc "[Hy]dra [Sw]ap"}
                     {1 ";t" :desc "[Hy]dra [T]ele"}
                     {1 :<leader>u :desc "[Hy]dra [Neo]test"}
                     :<leader>f
                     :<leader>m
                     :<leader>ne
                     :<leader>o
                     :<leader>q
                     :<leader>v
                     :<leader>w
                     :<leader>z]})
