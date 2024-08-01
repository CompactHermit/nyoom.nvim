(import-macros {: lzn!} :macros)

;; Updating Owner
(lzn! :hydra {:nyoom-module ui.hydra
              :wants [:gitsigns :dap]
              :keys [{1 :<space>a :desc "[Hy]dra [H]arpoon"}
                     {1 :<space>cl :desc "[Hy]dra [L]SP"}
                     {1 ";h" :desc "[Hy]dra [H]askell"}
                     {1 :<space>cm :desc "[Hy]dra [R]ust"}
                     {1 ";e" :desc "[Hy]dra [F]lash"}
                     {1 ";g" :desc "[Hy]dra [G]it"}
                     {1 :<space>l :desc "[Hy]dra:: [Ov]erseer"}
                     {1 ";s" :desc "[Hy]dra [Sw]ap"}
                     {1 ";t" :desc "[Hy]dra [T]ele"}
                     {1 ";;" :desc "[Hy]dra [Her]mitage"}
                     {1 ";u" :desc "[Hy]dra [Neo]test"}
                     {1 :<space>m}
                     {1 :<space>ne}
                     {1 :<space>o}
                     {1 :<space>q}
                     {1 :<space>v}
                     {1 :<space>w}
                     {1 :<space>z}]})
