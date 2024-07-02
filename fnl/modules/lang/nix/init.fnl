(import-macros {: lzn!} :macros)

(lzn! :direnv {:nyoom-module lang.nix
               :cmd [:Direnv]
               :ft :nix
               :keys [{1 :<space>cr :desc "[R]epl [N]ix"}]
               :wants [:toggleterm]})
