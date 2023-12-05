(import-macros {: use-package!} :macros)

(use-package! :jmbuhr/otter.nvim 
              {:nyoom-module tools.otter
               :opt true
               :ft [:md :nix]})
